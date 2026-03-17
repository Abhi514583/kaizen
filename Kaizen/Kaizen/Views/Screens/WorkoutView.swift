import SwiftUI

struct WorkoutView: View {
    @Binding var path: [KaizenRoute]
    let exerciseName: String
    let pr: String
    let goal: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutManager.self) private var workoutManager
    @Environment(ProgressManager.self) private var progressManager

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

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.10, blue: 0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Canvas { context, size in
                let spacing: CGFloat = 40
                for x in stride(from: 0, to: size.width, by: spacing) {
                    for y in stride(from: 0, to: size.height, by: spacing) {
                        context.fill(Path(CGRect(x: x, y: y, width: 1, height: 1)), with: .color(Color.kaizenMint.opacity(0.08)))
                    }
                }
            }
            .ignoresSafeArea()

            Circle()
                .fill(Color.kaizenMint.opacity(0.16))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(y: 120)

            VStack(spacing: 24) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(exerciseName.uppercased())
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(.kaizenWhite)
                            .tracking(2)

                        HStack(spacing: 12) {
                            statLabel(title: "BEST", value: displayPR)
                            statLabel(title: "GOAL", value: displayGoalLabel)
                        }
                    }
                    Spacer()
                    liveChip
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Text(workoutManager.activeSession?.exerciseType == .plank ?
                             String(format: "%02d:%02d", Int(workoutManager.currentDuration) / 60, Int(workoutManager.currentDuration) % 60) :
                             "\(workoutManager.currentReps)")
                            .font(.system(size: workoutManager.activeSession?.exerciseType == .plank ? 108 : 146, weight: .black, design: .rounded))
                            .foregroundColor(.kaizenWhite)
                            .contentTransition(.numericText())
                            .shadow(color: Color.kaizenMint.opacity(0.22), radius: 24)
                            .onTapGesture {
                                if workoutManager.activeSession?.exerciseType != .plank {
                                    workoutManager.updateReps(count: workoutManager.currentReps + 1)
                                    HapticManager.shared.playWorkoutStart()
                                }
                            }

                        Text(workoutManager.activeSession?.exerciseType == .plank ? "HOLD" : "TAP TO ADD")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.kaizenMint)
                            .tracking(4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 34)
                    .padding(.horizontal, 18)
                    .kaizenGlassCard(cornerRadius: 38, tint: Color.kaizenMint.opacity(0.10))

                    HStack(spacing: 16) {
                        metricPill(title: workoutManager.activeSession?.exerciseType == .plank ? "Elapsed" : "Reps", value: workoutManager.activeSession?.exerciseType == .plank ? String(format: "%02d:%02d", Int(workoutManager.currentDuration) / 60, Int(workoutManager.currentDuration) % 60) : "\(workoutManager.currentReps)")
                        metricPill(title: "Target", value: displayGoalLabel)
                    }
                }
                .scaleEffect(workoutManager.isPaused ? 0.9 : 1.0)
                .opacity(workoutManager.isPaused ? 0.5 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: workoutManager.currentReps)
                .padding(.horizontal, 24)

                Spacer()

                HStack(spacing: 16) {
                    if workoutManager.activeSession?.exerciseType == .plank {
                        manualButton(label: "+10s") {
                            workoutManager.addManualDuration(10)
                        }
                    } else {
                        manualButton(label: "+1") {
                            workoutManager.addManualReps(1)
                        }
                        manualButton(label: "+5") {
                            workoutManager.addManualReps(5)
                        }
                    }
                }
                .opacity(workoutManager.isPaused ? 0.3 : 1.0)
                .disabled(workoutManager.isPaused)
                .padding(.bottom, 20)

                HStack(spacing: 30) {
                    controlButton(icon: workoutManager.isPaused ? "play.fill" : "pause.fill") {
                        workoutManager.togglePause()
                        HapticManager.shared.playWorkoutStart()
                    }

                    controlButton(icon: "checkmark", isDestructive: false) {
                        let finalValue = workoutManager.activeSession?.exerciseType == .plank ?
                            Int(workoutManager.currentDuration) : workoutManager.currentReps

                        workoutManager.completeWorkout()

                        if let exerciseType = ExerciseType(rawValue: exerciseName) {
                            path.append(.sessionComplete(exerciseType, finalValue))
                        }
                    }

                    controlButton(icon: "xmark", isDestructive: true) {
                        workoutManager.cancelWorkout()
                        dismiss()
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func statLabel(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kaizenFog.opacity(0.56))
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.kaizenMint)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .kaizenFloatingCapsule(tint: Color.kaizenMint.opacity(0.08))
    }

    private var liveChip: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(workoutManager.isPaused ? "PAUSED" : "LIVE")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(workoutManager.isPaused ? .kaizenEmber : .kaizenMint)
                .tracking(2)
            Text(workoutManager.activeSession?.exerciseType == .plank ? "TIMER MODE" : "REP MODE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.kaizenFog.opacity(0.72))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .kaizenFloatingCapsule(tint: Color.white.opacity(0.08))
    }

    private func metricPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.kaizenFog.opacity(0.56))
                .tracking(2)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.kaizenWhite)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .kaizenGlassCard(cornerRadius: 24, tint: Color.white.opacity(0.04))
    }

    private func manualButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            HapticManager.shared.playWorkoutStart()
        }) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.kaizenMint)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
        }
        .kaizenFloatingCapsule(tint: Color.kaizenMint.opacity(0.08))
    }

    private func controlButton(icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.regularMaterial)
                    .frame(width: 78, height: 78)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isDestructive ? .kaizenEmber : .kaizenWhite)
            }
        }
    }
}

#Preview {
    WorkoutView(path: .constant([]), exerciseName: "Pushups", pr: "45 PR", goal: 50)
}
