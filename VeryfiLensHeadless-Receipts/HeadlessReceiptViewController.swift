//
//  UIViewController.swift
//  Veryfi-Lens
//
//  Created by Veryfi on 25/07/23.
//  Copyright © 2022 Veryfi. All rights reserved.
//

import UIKit
import VeryfiLensHeadlessReceipts
import AVFoundation

class HeadlessReceiptViewController: UIViewController {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBAction func didTapCapture(_ sender: UIButton) {
        if !isCapturingImage {
            isCapturingImage = !isCapturingImage
            cameraView.capture()
        }
    }
    
    @IBAction func willClose(_ sender: Any) {
        VeryfiLensHeadless.shared().close()
    }
    
    private var isLensInitialized: Bool = false
    private(set) var isCapturingImage: Bool = false
    private var isTorchOn = false
    private var shouldCaptureFrames = true
    var credentials: Credentials!
    var settings: VeryfiLensReceiptSettings!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.configure()
        startSessionAfterConfigured()

        cameraView.delegate = self
        
        presentationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isLensInitialized {
            cameraView.startSession()
            VeryfiLensHeadless.shared().startProcessingBuffer()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if cameraView.previewLayer.connection?.isVideoOrientationSupported ?? false {
            cameraView.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(interfaceOrientation:UIApplication.shared.statusBarOrientation)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        close()
        super.viewWillDisappear(animated)
    }
    
    // Call only after veryfing that the lens in configured
    func startSessionAfterConfigured() {
        isLensInitialized = true
        cameraView.startSession()
        VeryfiLensHeadless.shared().startProcessingBuffer()
    }
    
    //MARK: Private
    private func openSuccessViewController() {
        isTorchOn = false
        cameraView.stopSession()
        VeryfiLensHeadless.shared().reset()
        shouldCaptureFrames = false
        performSegue(withIdentifier: "creditCardResult", sender: self)
    }
    
    func close() {
        self.cameraView.stopSession()
        cameraView.sessionQueue.async { [weak self] in
            self?.isLensInitialized = false
            self?.shouldCaptureFrames = false
            VeryfiLensHeadless.shared().stopProcessingBuffer()
            VeryfiLensHeadless.shared().close()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as?  HeadlessReceiptsResultViewController {
            destination.resultImages = sender as? [UIImage]
        }
    }
}

extension HeadlessReceiptViewController: CameraViewDelegate {
    func cameraView(_ cameraView: CameraView, didCapture image: UIImage) {
        if isLensInitialized {
            VeryfiLensHeadless.shared().stopProcessingBuffer()
            let rotatedImage = VeryfiLensHeadless.shared().rotate(image: image)
            let croppedImages = VeryfiLensHeadless.shared().crop(image: rotatedImage)
            performSegue(withIdentifier: "showHeadlessReceiptResult", sender: croppedImages)
            isCapturingImage = false
        }
    }
    
    func cameraView(_ cameraView: CameraView, didCapture frame: CMSampleBuffer) {
        if isLensInitialized && shouldCaptureFrames {
            VeryfiLensHeadless.shared().process(buffer: frame)
            let rectangles = VeryfiLensHeadless.shared().detectedDocuments(for: frame, videoPreviewLayer: cameraView.previewLayer)
            DispatchQueue.main.async {
                cameraView.drawBorders(rectangles)
            }
        }
    }
}

extension HeadlessReceiptViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        close()
    }
}
