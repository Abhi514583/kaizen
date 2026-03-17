import Foundation
import Vision
import AVFoundation
import CoreGraphics

// MARK: - Supporting Types

enum PositioningState: Equatable {
    case notReady(reason: String)
    case ready
    case countdown(Int) // 3, 2, 1
}

enum RepPhase {
    case idle
    case goingDown
    case atBottom
    case goingUp
    case completed
}

enum FormIssue: String {
    case coreNotStraight = "Keep your core straight"
    case notDeepEnough   = "Go deeper"
    case outOfFrame      = "Move into frame"
    case tooClose        = "Step back"
    case tooFar          = "Step closer"
    case badAngle        = "Turn sideways"
    case lowConfidence   = "Hold still"
    case good            = "Good form"
}

// MARK: - VisionManager

@Observable
@MainActor
final class VisionManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Public State
    var trackingState: TrackingState = .active
    var positioningState: PositioningState = .notReady(reason: "Waiting for camera…")
    var formIssue: FormIssue = .good
    var currentReps: Int = 0
    var plankIsAligned: Bool = false
    var jointPositions: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    var activeExercise: ExerciseType? = nil
    var frameSize: CGSize = .zero
    weak var cameraManager: CameraManager?

    // MARK: - Callbacks (bound by WorkoutManager)
    var onRepCounted: ((Int) -> Void)?
    var onPlankAlignmentChanged: ((Bool) -> Void)?
    var onSessionShouldEnd: (() -> Void)?
    var onReadyStateChanged: ((PositioningState) -> Void)?

    // MARK: - Private: Positioning
    private var readyHoldStartTime: Date? = nil
    private let readyHoldDuration: TimeInterval = 2.0

    // MARK: - Private: Rep Tracking
    private var repPhase: RepPhase = .idle
    private var lastRepTime: Date = .distantPast
    private var wristStartX: Double = 0.5 // normalized

    // MARK: - Private: Plank
    private var plankBreakStartTime: Date? = nil
    private let plankBreakGrace: TimeInterval = 10.0

    // MARK: - Config
    private let minimumConfidence: Float = 0.5
    private let positioningConfidence: Float = 0.6

    // MARK: - AVCapture delegate
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest()
        let orientation = cameraManager?.visionOrientation ?? .right
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])

        do {
            try handler.perform([request])
            guard let observation = request.results?.first else {
                Task { @MainActor [weak self] in
                    self?.handleNoBodyDetected()
                }
                return
            }
            let points = try observation.recognizedPoints(.all)
            Task { @MainActor [weak self] in
                self?.process(points: points)
            }
        } catch {
            // silently drop frame
        }
    }

    // MARK: - Core Processing

    private func process(points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        // Filter to confident points
        let confident = points.filter { $0.value.confidence >= minimumConfidence }
        let positioningConfidentPoints = points.filter { $0.value.confidence >= positioningConfidence }

        // Convert normalized Vision coords (Y flipped) to CGPoints
        var mapped: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        for (joint, point) in confident {
            mapped[joint] = CGPoint(x: point.location.x, y: 1.0 - point.location.y)
        }
        jointPositions = mapped

        // Choose best-visible side joints (side-view: pick the one with higher confidence)
        guard let shoulder = bestPoint(for: [.leftShoulder, .rightShoulder], in: points),
              let hip      = bestPoint(for: [.leftHip, .rightHip], in: points),
              let ankle    = bestPoint(for: [.leftAnkle, .rightAnkle], in: points) else {
            evaluatePositioning(confidentCount: positioningConfidentPoints.count,
                                allPoints: points,
                                shoulder: nil, hip: nil, ankle: nil)
            return
        }

        let shoulderPt = toScreen(shoulder)
        let hipPt      = toScreen(hip)
        let anklePt    = toScreen(ankle)

        evaluatePositioning(confidentCount: positioningConfidentPoints.count,
                            allPoints: points,
                            shoulder: shoulderPt, hip: hipPt, ankle: anklePt)

        // Only run exercise logic if we have an active exercise and user is positioned
        guard let exercise = activeExercise else { return }
        if case .notReady = positioningState { return }

        switch exercise {
        case .pushups:
            runPushupDetection(points: points, shoulder: shoulderPt, hip: hipPt, ankle: anklePt)
        case .squats:
            runSquatDetection(points: points, shoulder: shoulderPt, hip: hipPt, ankle: anklePt)
        case .plank:
            runPlankDetection(shoulder: shoulderPt, hip: hipPt, ankle: anklePt)
        }
    }

    private func handleNoBodyDetected() {
        positioningState = .notReady(reason: "Step into frame")
        formIssue = .outOfFrame
        jointPositions = [:]
        resetPlankBreakTimer()
    }

    // MARK: - Positioning Evaluation

    private func evaluatePositioning(
        confidentCount: Int,
        allPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        shoulder: CGPoint?,
        hip: CGPoint?,
        ankle: CGPoint?
    ) {
        guard confidentCount >= 5, let shoulder, let _ = hip, let ankle else {
            positioningState = .notReady(reason: confidentCount < 5 ? "Move into frame" : "Hold still")
            readyHoldStartTime = nil
            return
        }

        // Check side-view: left/right shoulder should overlap (small horizontal gap = side-on)
        let leftConf  = allPoints[.leftShoulder]?.confidence ?? 0
        let rightConf = allPoints[.rightShoulder]?.confidence ?? 0

        var shoulderSpread: Double = 0
        if let ls = allPoints[.leftShoulder]?.location, let rs = allPoints[.rightShoulder]?.location {
            shoulderSpread = abs(ls.x - rs.x)
        }

        // In side-view both shoulders won't be visible simultaneously at high confidence
        // Good side view: max one shoulder seen well, OR spread < 0.15 in normalized space
        let facingCamera = shoulderSpread > 0.20 && leftConf > 0.5 && rightConf > 0.5
        if facingCamera {
            positioningState = .notReady(reason: "Turn sideways to camera")
            readyHoldStartTime = nil
            return
        }

        // Body height in frame
        let bodyHeight = abs(ankle.y - shoulder.y)
        if bodyHeight < 0.30 {
            positioningState = .notReady(reason: "Step closer")
            readyHoldStartTime = nil
            return
        }
        if bodyHeight > 0.90 {
            positioningState = .notReady(reason: "Step back")
            readyHoldStartTime = nil
            return
        }

        // All clear — user is in a READY position
        if readyHoldStartTime == nil {
            readyHoldStartTime = Date()
        }

        let held = Date().timeIntervalSince(readyHoldStartTime ?? Date())
        if held >= readyHoldDuration {
            if case .ready = positioningState { return } // already ready
            positioningState = .ready
            onReadyStateChanged?(.ready)
        } else {
            // Show a "stabilising" indicator but not blocking
            if case .notReady = positioningState {
                positioningState = .notReady(reason: "Hold position…")
            }
        }
    }

    // MARK: - Angle Math

    /// Compute the angle at joint B formed by A–B–C (in screen space, degrees)
    func angle(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Double {
        let v1 = CGPoint(x: a.x - b.x, y: a.y - b.y)
        let v2 = CGPoint(x: c.x - b.x, y: c.y - b.y)
        let dot   = v1.x * v2.x + v1.y * v2.y
        let cross = v1.x * v2.y - v1.y * v2.x
        return abs(atan2(cross, dot)) * 180.0 / .pi
    }

    /// Vertical angle deviation from straight (degrees from 180°)
    func deviationFrom180(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Double {
        return abs(180.0 - angle(a, b, c))
    }

    // MARK: - Pushup Detection

    private func runPushupDetection(
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        shoulder: CGPoint, hip: CGPoint, ankle: CGPoint
    ) {
        guard let elbow = bestPoint(for: [.leftElbow, .rightElbow], in: points).map(toScreen),
              let wrist = bestPoint(for: [.leftWrist, .rightWrist], in: points).map(toScreen) else {
            return
        }

        let elbowAngle = angle(shoulder, elbow, wrist)

        // Track wrist start X on first entry into DOWN phase
        if repPhase == .idle || repPhase == .completed {
            wristStartX = wrist.x
        }

        // Core alignment gate: shoulder–hip–ankle must be within ±12°
        let coreDeviation = deviationFrom180(shoulder, hip, ankle)
        let coreOk = coreDeviation <= 12.0

        // Arm path gate: wrist must not drift > 15% of frame width horizontally
        let wristDrift = abs(wrist.x - wristStartX)
        let armOk = wristDrift <= 0.15

        if !coreOk {
            formIssue = .coreNotStraight
        } else {
            formIssue = .good
        }

        // State machine
        switch repPhase {
        case .idle, .completed:
            repPhase = .goingDown

        case .goingDown:
            if elbowAngle <= 95.0 {
                repPhase = .atBottom
            }

        case .atBottom:
            if elbowAngle > 95.0 {
                repPhase = .goingUp
            }

        case .goingUp:
            if elbowAngle >= 155.0 {
                // Rep complete — check all gates
                let elapsed = Date().timeIntervalSince(lastRepTime)
                let speedOk = elapsed >= 0.5

                if coreOk && armOk && speedOk {
                    currentReps += 1
                    lastRepTime = Date()
                    onRepCounted?(currentReps)
                    repPhase = .completed
                } else {
                    // Failed a gate — still allow them to go down again
                    repPhase = .goingDown
                }
            }
        }
    }

    // MARK: - Squat Detection

    private func runSquatDetection(
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        shoulder: CGPoint, hip: CGPoint, ankle: CGPoint
    ) {
        guard let knee = bestPoint(for: [.leftKnee, .rightKnee], in: points).map(toScreen) else {
            return
        }

        let kneeAngle = angle(hip, knee, ankle)

        // Torso vertical deviation (should be close to straight up)
        // Shoulder should be roughly above hip — check lean angle
        let torsoLean = abs(atan2(shoulder.x - hip.x, shoulder.y - hip.y) * 180.0 / .pi)
        let torsoOk = torsoLean <= 35.0

        // Depth gate
        let deepEnough = kneeAngle <= 97.0

        if !torsoOk {
            formIssue = .coreNotStraight
        } else if repPhase == .atBottom && !deepEnough {
            formIssue = .notDeepEnough
        } else {
            formIssue = .good
        }

        switch repPhase {
        case .idle, .completed:
            repPhase = .goingDown

        case .goingDown:
            if kneeAngle <= 97.0 {
                repPhase = .atBottom
            }

        case .atBottom:
            if kneeAngle > 97.0 {
                repPhase = .goingUp
            }

        case .goingUp:
            if kneeAngle >= 158.0 {
                let elapsed = Date().timeIntervalSince(lastRepTime)
                let speedOk = elapsed >= 0.6

                if torsoOk && deepEnough && speedOk {
                    currentReps += 1
                    lastRepTime = Date()
                    onRepCounted?(currentReps)
                    repPhase = .completed
                } else {
                    repPhase = .goingDown
                }
            }
        }
    }

    // MARK: - Plank Detection

    private func runPlankDetection(shoulder: CGPoint, hip: CGPoint, ankle: CGPoint) {
        let deviation = deviationFrom180(shoulder, hip, ankle)
        let formGood = deviation <= 15.0

        if formGood {
            // Restore from break
            if !plankIsAligned {
                plankIsAligned = true
                plankBreakStartTime = nil
                onPlankAlignmentChanged?(true)
                formIssue = .good
            }
        } else {
            // Form breaking
            formIssue = .coreNotStraight

            if plankIsAligned {
                // Start break timer
                plankIsAligned = false
                plankBreakStartTime = Date()
                onPlankAlignmentChanged?(false)
            } else if let breakStart = plankBreakStartTime {
                let breakDuration = Date().timeIntervalSince(breakStart)
                if breakDuration >= plankBreakGrace {
                    // 10 seconds elapsed — auto-end session
                    plankBreakStartTime = nil
                    onSessionShouldEnd?()
                }
            }
        }
    }

    private func resetPlankBreakTimer() {
        if plankIsAligned {
            plankIsAligned = false
            plankBreakStartTime = nil
            onPlankAlignmentChanged?(false)
        }
    }

    // MARK: - Helpers

    private func bestPoint(
        for joints: [VNHumanBodyPoseObservation.JointName],
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> VNRecognizedPoint? {
        joints.compactMap { points[$0] }
              .filter { $0.confidence >= minimumConfidence }
              .max(by: { $0.confidence < $1.confidence })
    }

    private func toScreen(_ point: VNRecognizedPoint) -> CGPoint {
        // Vision Y is 0=bottom, screen Y is 0=top — flip Y
        CGPoint(x: Double(point.location.x), y: 1.0 - Double(point.location.y))
    }

    private func toScreen(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x, y: 1.0 - point.y)
    }

    // MARK: - Control

    func startExercise(_ type: ExerciseType) {
        activeExercise = type
        currentReps = 0
        repPhase = .idle
        formIssue = .good
        plankIsAligned = false
        plankBreakStartTime = nil
        lastRepTime = .distantPast
        positioningState = .notReady(reason: type == .pushups ? "Step back until your full side profile fits" : "Step into frame")
        readyHoldStartTime = nil
    }

    func stopExercise() {
        activeExercise = nil
        jointPositions = [:]
        positioningState = .notReady(reason: "")
        plankIsAligned = false
        plankBreakStartTime = nil
    }
}
