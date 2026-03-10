import Foundation
import AVFoundation

@Observable
final class CameraManager: NSObject {
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    var isAuthorized: Bool = false
    var currentError: TrackingError? = nil
    
    /// Delegate to receive the video frames (usually hooked up to VisionManager)
    weak var frameDelegate: AVCaptureVideoDataOutputSampleBufferDelegate? {
        didSet {
            // Re-assign the delegate if it changes
            videoOutput.setSampleBufferDelegate(frameDelegate, queue: videoQueue)
        }
    }
    
    private let videoQueue = DispatchQueue(label: "com.kaizen.videoQueue")
    
    override init() {
        super.init()
    }
    
    func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
            self.setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.currentError = .unauthorized
                    }
                }
            }
        case .denied, .restricted:
            self.isAuthorized = false
            self.currentError = .unauthorized
        @unknown default:
            self.isAuthorized = false
            self.currentError = .unauthorized
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        
        // 1. Select the front-facing wide angle camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get front camera")
            captureSession.commitConfiguration()
            return
        }
        
        // 2. Create the input
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("Failed to add front camera input")
            }
        } catch {
            print("Error creating camera input: \(error)")
            captureSession.commitConfiguration()
            return
        }
        
        // 3. Configure the output
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            // Ensure pixel format is suitable for Vision
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            videoOutput.alwaysDiscardsLateVideoFrames = true
        } else {
            print("Failed to add video output")
        }
        
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        guard isAuthorized else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
}
