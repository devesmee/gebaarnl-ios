//
//  BoterhamDetectionViewController.swift
//  gebaarNL
//
//  Created by Esmee Kluijtmans on 30/11/2020.
//

import UIKit
import AVFoundation
import Vision

class BoterhamDetectionViewController: UIViewController {

    @IBOutlet weak var wordLabel: UILabel!
    
    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handsPoseRequest = VNDetectHumanHandPoseRequest()
    
//    private var evidenceBuffer = [HandGestureProcessor.PointsThree]()
    private var evidenceBuffer = [HandGestureProcessor.AllPointsTwoHands]()
    private var lastObservationTimestamp = Date()
    
    private var gestureProcessor = HandGestureProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This sample app detects two hands.
        handsPoseRequest.maximumHandCount = 2
        // Add state change handler to hand gesture processor.
        
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        
        wordLabel.text = " "
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
    
    func processPoints(leftThumbTip: CGPoint?, leftIndexTip: CGPoint?, leftMiddleTip: CGPoint?, leftRingTip: CGPoint?, leftLittleTip: CGPoint?, leftWrist: CGPoint?, rightThumbTip: CGPoint?, rightIndexTip: CGPoint?, rightMiddleTip: CGPoint?, rightRingTip: CGPoint?, rightLittleTip: CGPoint?, rightWrist: CGPoint?) {
        // Check that we have both points.
        guard let leftThumbPoint = leftThumbTip, let leftIndexPoint = leftIndexTip, let leftMiddlePoint = leftMiddleTip, let leftRingPoint = leftRingTip, let leftLittlePoint = leftLittleTip , let leftWristPoint = leftWrist, let rightThumbPoint = rightThumbTip, let rightIndexPoint = rightIndexTip, let rightMiddlePoint = rightMiddleTip, let rightRingPoint = rightRingTip, let rightLittlePoint = rightLittleTip , let rightWristPoint = rightWrist else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            cameraView.showPoints([], color: .clear)
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        let leftThumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: leftThumbPoint)
        let leftIndexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: leftIndexPoint)
        let leftMiddlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: leftMiddlePoint)
        let leftRingPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: leftRingPoint)
        let leftLittlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: leftLittlePoint)
        let leftWristPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: leftWristPoint)
        
        let rightThumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: rightThumbPoint)
        let rightIndexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: rightIndexPoint)
        let rightMiddlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: rightMiddlePoint)
        let rightRingPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: rightRingPoint)
        let rightLittlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: rightLittlePoint)
        let rightWristPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: rightWristPoint)
        // Process new points
        // wordLabel.text = gestureProcessor.processPoints((leftThumbPointConverted, leftIndexPointConverted, leftMiddlePointConverted, leftRingPointConverted, leftLittlePointConverted, leftWristPointConverted, rightThumbPointConverted, rightIndexPointConverted, rightMiddlePointConverted, rightRingPointConverted, rightLittlePointConverted, rightWristPointConverted))
    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
//        let pointsPair = gestureProcessor.lastProcessedPointsPair
//        let pointsThree = gestureProcessor.lastProcessedPointsThree
        let points = gestureProcessor.lastProcessedPointsTwoHands
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
        cameraView.showPoints([points.leftThumbTip, points.leftIndexTip, points.leftMiddleTip, points.leftRingTip, points.leftLittleTip, points.leftWrist, points.rightThumbTip, points.rightIndexTip, points.rightMiddleTip, points.rightRingTip, points.rightLittleTip, points.rightWrist], color: tipsColor)
    }
}

extension BoterhamDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var leftThumbTip: CGPoint?
        var leftIndexTip: CGPoint?
        var leftMiddleTip: CGPoint?
        var leftRingTip: CGPoint?
        var leftLittleTip: CGPoint?
        var leftWrist: CGPoint?
        var rightThumbTip: CGPoint?
        var rightIndexTip: CGPoint?
        var rightMiddleTip: CGPoint?
        var rightRingTip: CGPoint?
        var rightLittleTip: CGPoint?
        var rightWrist: CGPoint?

        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(leftThumbTip: leftThumbTip, leftIndexTip: leftIndexTip, leftMiddleTip: leftMiddleTip, leftRingTip: leftRingTip, leftLittleTip: leftLittleTip, leftWrist: leftWrist, rightThumbTip: rightThumbTip, rightIndexTip: rightIndexTip, rightMiddleTip: rightMiddleTip, rightRingTip: rightRingTip, rightLittleTip: rightLittleTip, rightWrist: rightWrist)
            }
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handsPoseRequest])
            // Continue only when a hand was detected in the frame.
            guard let observationLeftHand = handsPoseRequest.results?.first else {
                return
            }
            guard let observationRightHand = handsPoseRequest.results?.last else {
                return
            }
            // Get points for all fingers & wrist
            let leftHandPoints = try observationLeftHand.recognizedPoints(.all)
            let rightHandPoints = try observationRightHand.recognizedPoints(.all)

            // Look for tip points.
            guard let leftThumbTipPoint = leftHandPoints[.thumbTip], let leftIndexTipPoint = leftHandPoints[.indexTip], let leftMiddleTipPoint = leftHandPoints[.middleTip], let leftRingTipPoint = leftHandPoints[.ringTip], let leftLittleTipPoint = leftHandPoints[.littleTip], let leftWristPoint = leftHandPoints[.wrist], let rightThumbTipPoint = rightHandPoints[.thumbTip], let rightIndexTipPoint = rightHandPoints[.indexTip], let rightMiddleTipPoint = rightHandPoints[.middleTip], let rightRingTipPoint = rightHandPoints[.ringTip], let rightLittleTipPoint = rightHandPoints[.littleTip], let rightWristPoint = rightHandPoints[.wrist] else {
                return
            }
            // Ignore low confidence points.
            guard leftThumbTipPoint.confidence > 0.3 && leftIndexTipPoint.confidence > 0.3 && leftMiddleTipPoint.confidence > 0.3 && leftRingTipPoint.confidence > 0.3 && leftLittleTipPoint.confidence > 0.3 && leftWristPoint.confidence > 0.3 else {
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            leftThumbTip = CGPoint(x: leftThumbTipPoint.location.x, y: 1 - leftThumbTipPoint.location.y)
            leftIndexTip = CGPoint(x: leftIndexTipPoint.location.x, y: 1 - leftIndexTipPoint.location.y)
            leftMiddleTip = CGPoint(x: leftMiddleTipPoint.location.x, y: 1 - leftMiddleTipPoint.location.y)
            leftRingTip = CGPoint(x: leftRingTipPoint.location.x, y: 1 - leftRingTipPoint.location.y)
            leftLittleTip = CGPoint(x: leftLittleTipPoint.location.x, y: 1 - leftLittleTipPoint.location.y)
            leftWrist = CGPoint(x: leftWristPoint.location.x, y: 1 - leftWristPoint.location.y)
            
            rightThumbTip = CGPoint(x: rightThumbTipPoint.location.x, y: 1 - rightThumbTipPoint.location.y)
            rightIndexTip = CGPoint(x: rightIndexTipPoint.location.x, y: 1 - rightIndexTipPoint.location.y)
            rightMiddleTip = CGPoint(x: rightMiddleTipPoint.location.x, y: 1 - rightMiddleTipPoint.location.y)
            rightRingTip = CGPoint(x: rightRingTipPoint.location.x, y: 1 - rightRingTipPoint.location.y)
            rightLittleTip = CGPoint(x: rightLittleTipPoint.location.x, y: 1 - rightLittleTipPoint.location.y)
            rightWrist = CGPoint(x: rightWristPoint.location.x, y: 1 - rightWristPoint.location.y)

        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}
