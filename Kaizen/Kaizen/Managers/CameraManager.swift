import Foundation
import AVFoundation
import ImageIO

@Observable
final class CameraManager: NSObject {
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    let videoQueue = DispatchQueue(label: "com.kaizen.videoQueue", qos: .userInitiated)
    private let sessionQueue = DispatchQueue(label: "com.kaizen.sessionQueue", qos: .userInitiated)

    var isAuthorized: Bool = false
    var currentError: TrackingError? = nil
    var isFrontCamera: Bool = false
    private var hasConfiguredSession = false
    private var prefersExerciseMode = false
    private var currentPosition: AVCaptureDevice.Position = .back

    /// Delegate to receive the video frames (hooked up to VisionManager)
    weak var frameDelegate: AVCaptureVideoDataOutputSampleBufferDelegate? {
        didSet {
            videoOutput.setSampleBufferDelegate(frameDelegate, queue: videoQueue)
        }
    }

    override init() {
        super.init()
    }

    func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
            self.configureSession(position: currentPosition, exerciseMode: prefersExerciseMode)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.configureSession(position: self?.currentPosition ?? .back, exerciseMode: self?.prefersExerciseMode ?? false)
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

    func switchToExerciseMode() {
        prefersExerciseMode = true
        currentPosition = .back
        isFrontCamera = false
        configureSession(position: .back, exerciseMode: true)
    }

    /// Toggle between front and back camera mid-session
    func toggleCamera() {
        currentPosition = currentPosition == .front ? .back : .front
        isFrontCamera = currentPosition == .front
        configureSession(position: currentPosition, exerciseMode: currentPosition == .back && prefersExerciseMode)
    }

    var visionOrientation: CGImagePropertyOrientation {
        isFrontCamera ? .leftMirrored : .right
    }

    func startSession() {
        guard isAuthorized else { return }
        sessionQueue.async { [weak self] in
            guard let self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    private func configureSession(position: AVCaptureDevice.Position, exerciseMode: Bool) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = exerciseMode ? .hd1920x1080 : .high

            for input in self.captureSession.inputs {
                self.captureSession.removeInput(input)
            }

            guard let camera = self.selectCamera(position: position, exerciseMode: exerciseMode) else {
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.currentError = .cameraUnavailable
                }
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                }
            } catch {
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.currentError = .cameraUnavailable
                }
                return
            }

            if !self.hasConfiguredSession, self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
                self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.hasConfiguredSession = true
            }

            self.applyConnectionConfiguration(position: position)
            self.captureSession.commitConfiguration()
        }
    }

    private func applyConnectionConfiguration(position: AVCaptureDevice.Position) {
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = position == .front
            }
        }
    }

    private func selectCamera(position: AVCaptureDevice.Position, exerciseMode: Bool) -> AVCaptureDevice? {
        let preferredTypes: [AVCaptureDevice.DeviceType]

        if exerciseMode && position == .back {
            preferredTypes = [.builtInUltraWideCamera, .builtInWideAngleCamera]
        } else {
            preferredTypes = [.builtInWideAngleCamera, .builtInUltraWideCamera]
        }

        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: preferredTypes,
            mediaType: .video,
            position: position
        )

        return discovery.devices.first
    }
}
