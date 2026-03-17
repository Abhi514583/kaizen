import SwiftUI
import SwiftData

/// Guided positioning screen shown before each workout.
/// Shows live camera + skeleton overlay and waits for the user to enter correct position.
struct WorkoutSetupView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(WorkoutManager.self) private var workoutManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(CameraManager.self) private var cameraManager
    @Environment(VisionManager.self) private var visionManager
    @Binding var path: [KaizenRoute]
    let exerciseType: ExerciseType

    @State private var countdownValue: Int = 3
    @State private var countdownActive: Bool = false
    @State private var countdownTimer: Timer? = nil
    @State private var isManualMode: Bool = false

    private var supportsPoseTracking: Bool {
        exerciseType == .pushups
    }

    private var dailyTarget: Int {
        progressManager.calculateDailyTarget(for: exerciseType)
    }

    private var skeletonFormState: SkeletonOverlayView.FormState {
        switch visionManager.formIssue {
        case .good: return .good
        case .coreNotStraight: return .broken
        default: return .warning
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isManualMode {
                manualSetupView
            } else {
                cameraSetupView
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isManualMode = !supportsPoseTracking
            guard supportsPoseTracking else { return }
            cameraManager.switchToExerciseMode()
            visionManager.startExercise(exerciseType)
            cameraManager.startSession()
        }
        .onDisappear {
            cancelCountdown()
        }
        .onChange(of: visionManager.positioningState) { _, newState in
            handlePositioningChange(newState)
        }
    }

    // MARK: - Camera Mode

    private var cameraSetupView: some View {
        ZStack {
            // Live camera feed
            CameraPreviewView(
                session: cameraManager.captureSession,
                videoGravity: .resizeAspect,
                isMirrored: cameraManager.isFrontCamera
            )
                .ignoresSafeArea()

            // Skeleton overlay
            SkeletonOverlayView(
                joints: visionManager.jointPositions,
                formState: skeletonFormState
            )
            .ignoresSafeArea()

            // Darkened top + bottom for readability
            VStack {
                LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 160)
                Spacer()
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 220)
            }
            .ignoresSafeArea()

            // Countdown overlay
            if countdownActive {
                countdownOverlay
            }

            // UI Controls
            VStack {
                // Top bar
                HStack {
                    Button(action: { HapticManager.shared.playWorkoutStart(); dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    Text(exerciseType.rawValue.uppercased())
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .tracking(3)
                    Spacer()
                    Button(action: {
                        HapticManager.shared.playWorkoutStart()
                        cameraManager.toggleCamera()
                    }) {
                        Image(systemName: "camera.rotate.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.kaizenGray)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Button(action: { isManualMode = true }) {
                        Text("MANUAL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.kaizenGray)
                            .tracking(1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().stroke(Color.kaizenGray.opacity(0.4), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                // Target info
                HStack(spacing: 24) {
                    targetBadge(label: "TARGET",
                                value: exerciseType == .plank ? "\(dailyTarget)s" : "\(dailyTarget)")
                    targetBadge(label: "ALL-TIME BEST",
                                value: bestLabel())
                }
                .padding(.bottom, 16)

                // Alignment guide card
                AlignmentGuideCard(
                    positioningState: visionManager.positioningState,
                    exerciseType: exerciseType
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }

    // MARK: - Countdown Overlay

    private var countdownOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 12) {
                Text("\(countdownValue)")
                    .font(.system(size: 130, weight: .black, design: .rounded))
                    .foregroundColor(.kaizenSage)
                    .shadow(color: .kaizenSage.opacity(0.5), radius: 30)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: countdownValue)

                Text("GET READY")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white)
                    .tracking(4)
            }
        }
    }

    // MARK: - Manual Mode Fallback

    private var manualSetupView: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { isManualMode = false }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.kaizenGray)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    Button(action: { HapticManager.shared.playWorkoutStart(); dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.kaizenGray)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Spacer()

                VStack(spacing: UIConstants.Spacing.lg) {
                    Image(systemName: exerciseIcon)
                        .font(.system(size: 48))
                        .foregroundColor(.kaizenSage)

                    Text("Manual Mode")
                        .font(.kaizenLargeHeader)
                        .foregroundColor(.kaizenWhite)

                    Text("Focus: \(exerciseType.rawValue)")
                        .font(.kaizenBody)
                        .foregroundColor(.kaizenSage)

                    Text("Target: \(dailyTarget) \(exerciseType == .plank ? "seconds" : "reps")")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.kaizenGray)

                    Text(supportsPoseTracking ? "Pushups use live pose tracking. Other exercises stay manual for now." : "Vision tracking is enabled for pushups first. This exercise stays in manual mode.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.kaizenGray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button(action: {
                        HapticManager.shared.playWorkoutStart()
                        workoutManager.startWorkout(type: exerciseType, goal: dailyTarget)
                        path.append(.activeWorkout(exerciseType))
                    }) {
                        Text("Start")
                    }
                    .buttonStyle(.kaizenPrimary)
                    .padding(.horizontal, 48)
                }

                Spacer()
            }
        }
    }

    // MARK: - Helpers

    private func handlePositioningChange(_ state: PositioningState) {
        if case .ready = state {
            if !countdownActive {
                startCountdown()
            }
        } else {
            cancelCountdown()
        }
    }

    private func startCountdown() {
        countdownValue = 3
        countdownActive = true
        HapticManager.shared.playWorkoutStart()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if self.countdownValue > 1 {
                    self.countdownValue -= 1
                    HapticManager.shared.playWorkoutStart()
                } else {
                    self.cancelCountdown()
                    self.launchWorkout()
                }
            }
        }
    }

    private func cancelCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdownActive = false
    }

    private func launchWorkout() {
        HapticManager.shared.playSessionComplete()
        workoutManager.startWorkout(type: exerciseType, goal: dailyTarget)
        path.append(.activeWorkout(exerciseType))
    }

    private func targetBadge(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kaizenGray)
                .tracking(1)
        }
        .frame(minWidth: 70)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.07).cornerRadius(12))
    }

    private func bestLabel() -> String {
        // WorkoutManager doesn't have direct access to progressManager here
        // We read from progressManager directly
        let best = progressManager.currentBest(for: exerciseType)
        guard best > 0 else { return "—" }
        if exerciseType == .plank { return String(format: "%d:%02d", best / 60, best % 60) }
        return "\(best)"
    }

    private var exerciseIcon: String {
        switch exerciseType {
        case .pushups: return "figure.pushups"
        case .squats:  return "figure.cross.training"
        case .plank:   return "figure.strengthtraining.functional"
        }
    }
}
