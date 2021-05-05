//
//  MiniGameViewController.swift
//  gebaarNL
//
//  Created by Esmee Kluijtmans on 10/12/2020.
//

import UIKit
import AVFoundation
import Vision

class MiniGameViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var practiceLetter: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var grayOverlayView: UIView!
    @IBOutlet weak var startCountdownLabel: UILabel!
    @IBOutlet weak var showWholeHandLabel: UILabel!
    
    var countdownTimer = Timer()
    var countdownStartTimer = Timer()
    var countdownStartInt = 3
    var countdownInt = 60;
    var lettersToPractice = [Level]()
    var currentLevel = Level.none
    var score = 0;
    var randomizedLetter = Level.none
    var previousLetter = Level.none
    let audioUrlCountdown = NSURL(fileURLWithPath: Bundle.main.path(forResource: "countdown", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    
    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
//    private var evidenceBuffer = [HandGestureProcessor.PointsThree]()
    private var evidenceBuffer = [HandGestureProcessor.AllPointsOneHand]()
    private var lastObservationTimestamp = Date()
    
    private var gestureProcessor = HandGestureProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get current level.
        currentLevel = ProgressTracker.shared.GetCurrentLevel()
        // Get letters to practice of current level.
        lettersToPractice = ProgressTracker.shared.GetTestLetters(of: currentLevel)
        // This sample app detects one hand only.
        handPoseRequest.maximumHandCount = 1
        // Add state change handler to hand gesture processor.
        
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        
        // Set up UI
        cancelButton.layer.cornerRadius = 0.5 * cancelButton.bounds.size.width
        skipButton.layer.cornerRadius = 0.3 * skipButton.bounds.size.height
        grayOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor, constant:0).isActive = true
        countdownLabel.isHidden = true
        practiceLetter.isHidden = true
        
        do {
        audioPlayer = try AVAudioPlayer(contentsOf: audioUrlCountdown as URL)
        }
        catch {
            print("No file found")
        }
        
        audioPlayer.play()
        
        countdownStartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.countdownStartInt == 0 {
                timer.invalidate()
                if(self.currentLevel == .final1) {
                    self.startLevelTest()
                    self.showWholeHandLabel.isHidden = false
                } else {
                    self.startMiniGame()
                }
            } else {
                self.countdownStartInt -= 1
                self.startCountdownLabel.text = String(self.countdownStartInt)
                if(self.countdownStartInt == 0) {
                    self.startCountdownLabel.text = "Start!"
                }
            }
        })
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func startMiniGame(){
        grayOverlayView.fadeOut()
        countdownLabel.isHidden = false
        practiceLetter.isHidden = false
        startCountdownLabel.isHidden = true
        countdownLabel.text = String(countdownInt)
        gestureProcessor.isFinalTest = false
        gestureProcessor.isMiniGame = true
        
        // Set up Timer
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.countdownInt == 0 {
                timer.invalidate()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "PracticeResultViewController") as! PracticeResultViewController
                resultViewController.modalPresentationStyle = .fullScreen
                resultViewController.score = self.score
                resultViewController.completedLevel = self.currentLevel
                resultViewController.previousViewController = "MiniGame"
                self.present(resultViewController, animated: true, completion: nil)
            } else {
                self.countdownInt -= 1
                self.countdownLabel.text = String(self.countdownInt)
            }
        })
        
        // Randomize first letter
        randomizedLetter = lettersToPractice.randomElement()!
        practiceLetter.text = ProgressTracker.shared.GetLetter(of: randomizedLetter)
        gestureProcessor.currentLevel = randomizedLetter
    }
    
    func startLevelTest(){
        grayOverlayView.fadeOut()
        practiceLetter.isHidden = false
        startCountdownLabel.isHidden = true
        gestureProcessor.isFinalTest = true
        gestureProcessor.isMiniGame = false
        
        // Randomize first letter
        randomizedLetter = lettersToPractice.randomElement()!
        practiceLetter.text = ProgressTracker.shared.GetLetter(of: randomizedLetter)
        gestureProcessor.currentLevel = randomizedLetter
    }
    
    @IBAction func buttonsPressed(sender: UIButton){
        sender.backgroundColor = #colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1)
        if sender == cancelButton {
            sender.setImage(UIImage(named: "cancel-orange"), for: .highlighted)
        } else {
            sender.setTitleColor(#colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1), for: .normal)
        }
    }
    
    @IBAction func buttonsReleased(sender: UIButton){
        sender.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
        if sender == cancelButton {
            sender.setImage(UIImage(named: "cancel-green"), for: .normal)
        } else {
            sender.setTitleColor(#colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1), for: .normal)
        }
    }
    
    @IBAction func skipLetter(_ sender: Any) {
        // Randomize new letter when skipped
        gestureProcessor.correctGesture = false
        previousLetter = randomizedLetter
        if(lettersToPractice.count == 1){
            randomizedLetter = previousLetter
        } else {
            randomizedLetter = lettersToPractice.randomElement()!
            if(currentLevel == Level.checkpoint3){
                while ((previousLetter == Level.letterM && randomizedLetter == Level.letterN) || (previousLetter == Level.letterN && randomizedLetter == Level.letterM) || randomizedLetter == previousLetter) {
                    randomizedLetter = lettersToPractice.randomElement()!
                }
            } else if(currentLevel == Level.checkpoint5){
                while ((previousLetter == Level.letterR && randomizedLetter == Level.letterS) || (previousLetter == Level.letterS && randomizedLetter == Level.letterR) || randomizedLetter == previousLetter) {
                    randomizedLetter = lettersToPractice.randomElement()!
                }
            } else {
                while(randomizedLetter == previousLetter){
                    randomizedLetter = lettersToPractice.randomElement()!
                }
            }
        }
        practiceLetter.text = ProgressTracker.shared.GetLetter(of: randomizedLetter)
        gestureProcessor.currentLevel = randomizedLetter
    }
    
    func setupAVSession() throws {
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
}
    
    func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?, middleTip: CGPoint?, ringTip: CGPoint?, littleTip: CGPoint?, wrist: CGPoint?) {
        // Check that we have both points.
        guard let thumbPoint = thumbTip, let indexPoint = indexTip, let middlePoint = middleTip, let ringPoint = ringTip,
              let littlePoint = littleTip , let wristPoint = wrist else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            cameraView.showPoints([], color: .clear)
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        let middlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middlePoint)
        let ringPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringPoint)
        let littlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: littlePoint)
        let wristPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: wristPoint)
        
        showWholeHandInstruction(waitForWholeHands: gestureProcessor.waitForFullHand)
        
        // Process new points
        gestureProcessor.processPoints((thumbPointConverted, indexPointConverted, middlePointConverted, ringPointConverted, littlePointConverted, wristPointConverted))
        
        if(gestureProcessor.correctGesture)
        {
            previousLetter = randomizedLetter
            // UPDATE SCORE LABEL IF WE WANT TO ADD IT
            
            // Remove letter from array once completed, so all letters will be practiced
            if(currentLevel == .final1)
            {
                lettersToPractice = lettersToPractice.filter {$0 != previousLetter}
            }
            
            if(lettersToPractice.isEmpty) {
                score = 26
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "PracticeResultViewController") as! PracticeResultViewController
                resultViewController.modalPresentationStyle = .fullScreen
                resultViewController.score = self.score
                resultViewController.completedLevel = self.currentLevel
                resultViewController.previousViewController = "LevelTest"
                self.present(resultViewController, animated: true, completion: nil)
            } else {
                randomizedLetter = lettersToPractice.randomElement()!
                if(currentLevel == Level.checkpoint3){
                    while ((previousLetter == Level.letterM && randomizedLetter == Level.letterN) || (previousLetter == Level.letterN && randomizedLetter == Level.letterM) || randomizedLetter == previousLetter) {
                        randomizedLetter = lettersToPractice.randomElement()!
                    }
                } else if(currentLevel == Level.checkpoint5){
                    while ((previousLetter == Level.letterR && randomizedLetter == Level.letterS) || (previousLetter == Level.letterS && randomizedLetter == Level.letterR) || randomizedLetter == previousLetter) {
                        randomizedLetter = lettersToPractice.randomElement()!
                    }
                } else {
                    while(randomizedLetter == previousLetter){
                        randomizedLetter = lettersToPractice.randomElement()!
                    }
                }
                practiceLetter.text = ProgressTracker.shared.GetLetter(of: randomizedLetter)
                gestureProcessor.currentLevel = randomizedLetter
                gestureProcessor.correctGesture = false
                score += 1
                print(score)
            }
            
        }
    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
//        let pointsPair = gestureProcessor.lastProcessedPointsPair
//        let pointsThree = gestureProcessor.lastProcessedPointsThree
        let points = gestureProcessor.lastProcessedPointsOneHand
        let tipsColor: UIColor = .red
//        switch state {
//        case .possiblePinch, .possibleApart:
//            // We are in one of the "possible": states, meaning there is not enough evidence yet to determine
//            // if we want to draw or not. For now, collect points in the evidence buffer, so we can add them
//            // to a drawing path when required.
////            evidenceBuffer.append(pointsPair)
//            evidenceBuffer.append(points)
//            tipsColor = .orange
//        case .pinched:
//            // Clear the evidence buffer.
//            evidenceBuffer.removeAll()
//            tipsColor = .green
//        case .apart, .unknown:
//            // We have enough evidence to not draw. Discard any evidence buffer points.
//            evidenceBuffer.removeAll()
//            tipsColor = .red
//        }
//        cameraView.showPoints([pointsPair.thumbTip, pointsPair.indexTip], color: tipsColor)
//        cameraView.showPoints([pointsThree.thumbTip, pointsThree.indexTip, pointsThree.middleTip], color: tipsColor)
        cameraView.showPoints([points.thumbTip, points.indexTip, points.middleTip, points.ringTip, points.littleTip, points.wrist], color: tipsColor)
    }
    
    public func showWholeHandInstruction(waitForWholeHands: Bool){
        showWholeHandLabel.isHidden = !waitForWholeHands
    }
    
    @IBAction func cancelButtonTouchDown(_ sender: Any) {
        countdownTimer.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        countdownTimer.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension MiniGameViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        var middleTip: CGPoint?
        var ringTip: CGPoint?
        var littleTip: CGPoint?
        var wrist: CGPoint?

        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, littleTip: littleTip, wrist: wrist)
            }
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            // Get points for thumb and index finger.
            let handPoints = try observation.recognizedPoints(.all)

            // Look for tip points.
            guard let thumbTipPoint = handPoints[.thumbTip], let indexTipPoint = handPoints[.indexTip], let middleTipPoint = handPoints[.middleTip], let ringTipPoint = handPoints[.ringTip], let littleTipPoint = handPoints[.littleTip], let wristPoint = handPoints[.wrist] else {
                return
            }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 && middleTipPoint.confidence > 0.3 && ringTipPoint.confidence > 0.3 && littleTipPoint.confidence > 0.3 && wristPoint.confidence > 0.3 else {
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
            middleTip = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
            ringTip = CGPoint(x: ringTipPoint.location.x, y: 1 - ringTipPoint.location.y)
            littleTip = CGPoint(x: littleTipPoint.location.x, y: 1 - littleTipPoint.location.y)
            wrist = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)

        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
        
}

