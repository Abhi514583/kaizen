import SwiftUI

struct WorkoutView: View {
    @Binding var path: [KaizenRoute]
    let exerciseName: String
    let pr: String
    let goal: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutManager.self) private var workoutManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(CameraManager.self) private var cameraManager
    @Environment(VisionManager.self) private var visionManager

    private var usesPoseCamera: Bool {
        currentExerciseType == .pushups
    }

    private var currentExerciseType: ExerciseType? {
        workoutManager.activeSession?.exerciseType ?? ExerciseType(rawValue: exerciseName)
    }

    private var displayGoal: Int {
        workoutManager.activeSession?.targetForThatDay ?? goal
    }

    private var displayGoalLabel: String {
        guard let currentExerciseType else { return "\(displayGoal)" }
        return currentExerciseType == .plank ? "\(displayGoal)s" : "\(displayGoal)"
    }

    private var displayPR: String {
        guard let currentExerciseType else { return pr }
        let best = progressManager.currentBest(for: currentExerciseType)
        guard best > 0 else { return "NO PR" }
        if currentExerciseType == .plank {
            return String(format: "%02d:%02d PR", best / 60, best % 60)
        }
        return "\(best) PR"
    }

    private var skeletonFormState: SkeletonOverlayView.FormState {
        switch visionManager.formIssue {
        case .good: return .good
        case .coreNotStraight: return .broken
        default: return .warning
        }
    }

    private var plankAlignmentIcon: (String, Color) {
        visionManager.plankIsAligned
            ? ("checkmark.circle.fill", .kaizenSage)
            : ("xmark.circle.fill", .red)
    }

    var body: some View {
        ZStack {
            if usesPoseCamera {
                CameraPreviewView(
                    session: cameraManager.captureSession,
                    videoGravity: .resizeAspect,
                    isMirrored: cameraManager.isFrontCamera
                )
                .ignoresSafeArea()

                SkeletonOverlayView(
                    joints: visionManager.jointPositions,
                    formState: skeletonFormState
                )
                .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            // Gradient scrim for readability
            VStack {
                LinearGradient(colors: [.black.opacity(0.75), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 180)
                Spacer()
                LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 260)
            }
            .ignoresSafeArea()

            // MARK: - Inactivity Countdown
            if workoutManager.isInactivityCountingDown {
                inactivityCountdownOverlay
            }

            // MARK: - Main UI
            VStack {
                topStatsHeader
                Spacer()
                repCounter
                Spacer()
                formFeedbackBanner
                Spacer()
                manualControls
                controlButtons
                    .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if usesPoseCamera {
                cameraManager.switchToExerciseMode()
                cameraManager.startSession()
            }
        }
        .onDisappear {
            if usesPoseCamera {
                cameraManager.stopSession()
            }
        }
    }

    // MARK: - Top Stats

    private var topStatsHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exerciseName.uppercased())
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.kaizenWhite)
                    .tracking(2)

                HStack(spacing: 12) {
                    statLabel(title: "BEST", value: displayPR)
                    statLabel(title: "GOAL", value: displayGoalLabel)

                    // Plank alignment indicator
                    if currentExerciseType == .plank {
                        let (icon, color) = plankAlignmentIcon
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(color)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                timerView
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
                .opacity(usesPoseCamera ? 1 : 0)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    // MARK: - Rep / Duration Counter

    private var repCounter: some View {
        VStack(spacing: -10) {
            if currentExerciseType == .plank {
                Text(String(format: "%02d:%02d", Int(workoutManager.currentDuration) / 60, Int(workoutManager.currentDuration) % 60))
                    .font(.system(size: 110, weight: .black, design: .rounded))
                    .foregroundColor(visionManager.plankIsAligned ? .kaizenSage : .orange)
                    .shadow(color: Color.kaizenSage.opacity(visionManager.plankIsAligned ? 0.4 : 0), radius: 20)
            } else {
                Text("\(workoutManager.currentReps)")
                    .font(.system(size: 160, weight: .black, design: .rounded))
                    .foregroundColor(.kaizenWhite)
                    .shadow(color: Color.kaizenSage.opacity(0.4), radius: 20)
                    .shadow(color: Color.kaizenSage.opacity(0.2), radius: 40)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: workoutManager.currentReps)
            }

            Text(currentExerciseType == .plank ? "HOLD" : "REPS")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.kaizenSage)
                .tracking(10)
                .offset(x: 5)
        }
        .scaleEffect(workoutManager.isPaused ? 0.9 : 1.0)
        .opacity(workoutManager.isPaused ? 0.5 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: workoutManager.isPaused)
    }

    // MARK: - Form Feedback Banner

    private var formFeedbackBanner: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(formBannerColor)
                .frame(width: 8, height: 8)
            Text(usesPoseCamera ? visionManager.formIssue.rawValue.uppercased() : "MANUAL MODE")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(formBannerColor)
                .tracking(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(formBannerColor.opacity(0.12)))
        .animation(.easeInOut(duration: 0.3), value: visionManager.formIssue.rawValue)
    }

    private var formBannerColor: Color {
        guard usesPoseCamera else { return .kaizenSage }
        switch skeletonFormState {
        case .good:    return .kaizenSage
        case .warning: return .orange
        case .broken:  return .red
        }
    }

    // MARK: - Inactivity Countdown

    private var inactivityCountdownOverlay: some View {
        VStack(spacing: 6) {
            Text("ENDING IN \(workoutManager.inactivitySecondsRemaining)s")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.red)
                .tracking(2)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.red.opacity(0.15)))
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.3), value: workoutManager.isInactivityCountingDown)
    }

    // MARK: - Manual Controls (fallback for testing)

    private var manualControls: some View {
        HStack(spacing: 16) {
            if currentExerciseType == .plank {
                manualButton(label: "+10s") { workoutManager.addManualDuration(10) }
            } else {
                manualButton(label: "+1")  { workoutManager.addManualReps(1) }
                manualButton(label: "+5")  { workoutManager.addManualReps(5) }
            }
        }
        .opacity(workoutManager.isPaused ? 0.3 : 1.0)
        .disabled(workoutManager.isPaused)
        .padding(.bottom, 12)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: 30) {
            controlButton(icon: workoutManager.isPaused ? "play.fill" : "pause.fill") {
                workoutManager.togglePause()
                HapticManager.shared.playWorkoutStart()
            }

            controlButton(icon: "checkmark", isDestructive: false) {
                let finalValue = currentExerciseType == .plank
                    ? Int(workoutManager.currentDuration)
                    : workoutManager.currentReps
                workoutManager.completeWorkout()
                if let exerciseType = currentExerciseType {
                    path.append(.sessionComplete(exerciseType, finalValue))
                }
            }

            controlButton(icon: "xmark", isDestructive: true) {
                workoutManager.cancelWorkout()
                dismiss()
            }
        }
    }

    // MARK: - Subviews

    private func statLabel(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kaizenGray)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.kaizenSage)
        }
    }

    private var timerView: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("SESSION")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kaizenGray)
            Text(String(format: "%02d:%02d", Int(workoutManager.currentDuration) / 60, Int(workoutManager.currentDuration) % 60))
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.kaizenWhite)
        }
    }

    private func manualButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            HapticManager.shared.playWorkoutStart()
        }) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.kaizenSage)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .stroke(Color.kaizenSage.opacity(0.3), lineWidth: 1)
                        .background(Color.kaizenSage.opacity(0.05))
                )
        }
    }

    private func controlButton(icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 70, height: 70)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isDestructive ? .red : .kaizenWhite)
            }
        }
    }
}
