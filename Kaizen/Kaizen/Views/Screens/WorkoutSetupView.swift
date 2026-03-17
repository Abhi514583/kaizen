import SwiftUI

struct WorkoutSetupView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(WorkoutManager.self) private var workoutManager
    @Environment(ProgressManager.self) private var progressManager
    @Binding var path: [KaizenRoute]
    let exerciseType: ExerciseType
    
    private var dailyTarget: Int {
        progressManager.calculateDailyTarget(for: exerciseType)
    }

    private var bestLabel: String {
        let best = progressManager.currentBest(for: exerciseType)
        guard best > 0 else { return "No personal best yet" }
        return exerciseType == .plank ? "\(best)s best" : "\(best) rep best"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.kaizenShadow, Color(red: 0.12, green: 0.14, blue: 0.13)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        HapticManager.shared.playWorkoutStart()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.kaizenGray)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                Spacer()
                
                VStack(spacing: 22) {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(exerciseTint.opacity(0.16))
                        .frame(width: 104, height: 104)
                        .overlay(
                            Image(systemName: iconName)
                                .font(.system(size: 44, weight: .medium))
                                .foregroundColor(exerciseTint)
                        )

                    VStack(spacing: 8) {
                        Text("Begin Ritual")
                            .font(.kaizenLargeHeader)
                            .foregroundColor(.kaizenWhite)
                        Text(exerciseType.rawValue.uppercased())
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(exerciseTint)
                            .tracking(3)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        metricRow(title: "Today's target", value: "\(dailyTarget)\(exerciseType == .plank ? " seconds" : " reps")")
                        metricRow(title: "Personal best", value: bestLabel)
                    }
                    .padding(22)
                    .kaizenGlassCard(cornerRadius: 30, tint: exerciseTint.opacity(0.08))

                    Button(action: {
                        HapticManager.shared.playWorkoutStart()
                        workoutManager.startWorkout(type: exerciseType, goal: dailyTarget)
                        path.append(.activeWorkout(exerciseType))
                    }) {
                        Text("START SESSION")
                            .tracking(2)
                    }
                    .buttonStyle(.kaizenPrimary)
                    .padding(.horizontal, 32)
                }
                .padding(.horizontal, 28)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackFix())
        .onSwipeBack {
            HapticManager.shared.playWorkoutStart()
            dismiss()
        }
    }

    private func metricRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.kaizenFog.opacity(0.58))
                .tracking(2)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.kaizenWhite)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var exerciseTint: Color {
        switch exerciseType {
        case .pushups: return .kaizenMint
        case .squats: return .kaizenWood
        case .plank: return .kaizenFog
        }
    }

    private var iconName: String {
        switch exerciseType {
        case .pushups: return "figure.pushups"
        case .squats: return "figure.cross.training"
        case .plank: return "figure.strengthtraining.functional"
        }
    }
}
