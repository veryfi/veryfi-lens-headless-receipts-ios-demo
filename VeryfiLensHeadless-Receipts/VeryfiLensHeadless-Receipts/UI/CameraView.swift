//
//  CameraView.swift
//  Veryfi-Lens
//
//  Created by Alex Levnikov on 4/4/22.
//  Copyright © 2022 Veryfi. All rights reserved.
//

import UIKit
import AVFoundation
import VeryfiLensHeadlessReceipts

protocol CameraViewDelegate: AnyObject {
    func cameraView(_ cameraView: CameraView, didCapture frame: CMSampleBuffer)
    func cameraView(_ cameraView: CameraView, didCapture image: UIImage)
}

class CameraView: UIView {
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    let sessionQueue = DispatchQueue(label: "session queue")
    private var setupResult: SessionSetupResult = .success
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    private let photoOutput = AVCapturePhotoOutput()
    private let dataOutput = AVCaptureVideoDataOutput()
    private var shapeLayer: CAShapeLayer?
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    weak var delegate: CameraViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.previewLayer.frame = self.bounds
        self.shapeLayer?.frame = self.bounds
    }
    
    var torchMode: AVCaptureDevice.TorchMode = .off {
        didSet {
            if self.videoDeviceInput?.device.hasTorch == true {
                do {
                    try videoDeviceInput?.device.lockForConfiguration()
                    videoDeviceInput?.device.torchMode = torchMode
                    videoDeviceInput?.device.unlockForConfiguration()
                } catch (_) {
                    
                }
            }
        }
    }
    
    func configure() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.frame = self.bounds
        self.layer.insertSublayer(self.previewLayer, at: 0)
        shapeLayer?.removeFromSuperlayer()
        shapeLayer = CAShapeLayer()
        shapeLayer?.frame = self.bounds
        shapeLayer?.fillColor = UIColor.green.withAlphaComponent(0.3).cgColor
        self.layer.insertSublayer(shapeLayer!, above: previewLayer)
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
            
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            setupResult = .notAuthorized
        }
        configureSession()
    }
    
    func update(orientation: AVCaptureVideoOrientation) {
        var previewOrientation = orientation
        switch orientation {
        case .portrait:
            previewOrientation = .portrait
        case .portraitUpsideDown:
            previewOrientation = .portraitUpsideDown
        case .landscapeRight:
            previewOrientation = .landscapeLeft
        case .landscapeLeft:
            previewOrientation = .landscapeRight
        @unknown default:
            previewOrientation = .portrait
        }
        dataOutput.connections.first?.videoOrientation = previewOrientation
    }
    
    func capture() {
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = [(kCVPixelBufferPixelFormatTypeKey as String):settings.availablePreviewPhotoPixelFormatTypes.first ?? UInt32(0),
                                       (kCVPixelBufferWidthKey as String):160,
                                       (kCVPixelBufferHeightKey as String):160]
        settings.isHighResolutionPhotoEnabled = true
        self.photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func drawBorders(_ rectangles: [RectangleFeature]) {
        if rectangles.count > 0 {
            let path: CGMutablePath = CGMutablePath()
            for rect in rectangles {
                let rectPath = UIBezierPath()
                rectPath.move(to: rect.topLeft)
                rectPath.addLine(to: rect.topRight)
                rectPath.addLine(to: rect.bottomRight)
                rectPath.addLine(to: rect.bottomLeft)
                rectPath.addLine(to: rect.topLeft)
                shapeLayer?.path = rectPath.cgPath
            }
            shapeLayer?.didChangeValue(forKey: "path")
        } else {
            cleanBorders()
        }
        
    }
    
    func cleanBorders() {
        shapeLayer?.path = UIBezierPath().cgPath
    }
    
    func startSession() {
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                break
            case .configurationFailed:
                break
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
    }
    
    private func addObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    
                }
            }
        } else {
        }
    }
    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = .high
        
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            try videoDevice.lockForConfiguration()
            videoDevice.videoZoomFactor = 1.0
            
            if videoDevice.isFocusModeSupported(.continuousAutoFocus) {
                videoDevice.focusMode = .continuousAutoFocus
            } else if videoDevice.isFocusModeSupported(.autoFocus) {
                videoDevice.focusMode = .autoFocus
            }
            videoDevice.unlockForConfiguration()
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]
        dataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if (session.canAddOutput(dataOutput)) {
            session.addOutput(dataOutput)
        } else {
            print("Couldn't add video data output to the session.")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        dataOutput.connections.first?.videoOrientation = AVCaptureVideoOrientation(interfaceOrientation:UIApplication.shared.statusBarOrientation)
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            
            photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
            if #available(iOS 13.0, *) {
                photoOutput.maxPhotoQualityPrioritization = .quality
            }
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
       
        
        session.commitConfiguration()
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
}


extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.cameraView(self, didCapture: sampleBuffer)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage.init(data: imageData) else {
                  return
              }
        
        delegate?.cameraView(self, didCapture: image)
    }
}
