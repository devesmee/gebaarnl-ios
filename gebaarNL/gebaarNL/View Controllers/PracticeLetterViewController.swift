//
//  PracticeLetterViewController.swift
//  gebaarNL
//
//  Created by Angelica Dewi on 26/11/2020.
//

import UIKit
import AVFoundation
import Vision

class PracticeLetterViewController: UIViewController {

    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var showWholeHandLabel: UILabel!
    @IBOutlet weak var letterImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
//    private var evidenceBuffer = [HandGestureProcessor.PointsThree]()
    private var evidenceBuffer = [HandGestureProcessor.AllPointsOneHand]()
    private var lastObservationTimestamp = Date()
    
    private var gestureProcessor = HandGestureProcessor()
    var currentLevel = Level.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get current level.
        currentLevel = ProgressTracker.shared.GetCurrentLevel()
        // This sample app detects one hand only.
        handPoseRequest.maximumHandCount = 1
        // Add state change handler to hand gesture processor.
        
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        gestureProcessor.isMiniGame = false
                
        // Set up UI
        letterLabel.text = "Nog \(gestureProcessor.countdownCorrect) keer"
        showWholeHandLabel.isHidden = false
        showWholeHandLabel.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
        letterImageView.image = UIImage(named: gestureProcessor.currentLevel.rawValue)
        letterImageView.layer.cornerRadius = 0.1 * letterImageView.bounds.size.width
        cancelButton.layer.cornerRadius = 0.5 * cancelButton.bounds.size.width
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
    
    @IBAction func buttonPressed(sender: UIButton){
        sender.backgroundColor = #colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1)
        sender.setImage(UIImage(named: "cancel-orange"), for: .highlighted)
    }
    
    @IBAction func buttonReleased(sender: UIButton){
        sender.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
        sender.setImage(UIImage(named: "cancel-green"), for: .normal)
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
                letterLabel.text = "Nog \(gestureProcessor.countdownCorrect) keer"
                showWholeHandLabel.isHidden = false
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
                
        // Process new points
        letterLabel.text = gestureProcessor.countdownString
        showWholeHandInstruction(waitForWholeHands: gestureProcessor.waitForFullHand)
        gestureProcessor.processPoints((thumbPointConverted, indexPointConverted, middlePointConverted, ringPointConverted, littlePointConverted, wristPointConverted))
        
        if(gestureProcessor.countdownCorrect == 0){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PracticeResultViewController") as! PracticeResultViewController
            nextViewController.previousViewController = "PracticeLetter"
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated: true, completion: nil)
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
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PracticeLetterViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
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
            
            // Observe if letter is correctly done.
            // Show/hide label based on the results.

        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}
