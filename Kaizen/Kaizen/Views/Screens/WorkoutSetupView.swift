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
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Top Navigation
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
                
                VStack(spacing: UIConstants.Spacing.lg) {
                    Text("Begin Ritual")
                        .font(.kaizenLargeHeader)
                        .foregroundColor(.kaizenWhite)
                    Text("Focus: \(exerciseType.rawValue)")
                        .font(.kaizenBody)
                        .foregroundColor(.kaizenSage)
                    
                    Text("Target: \(dailyTarget) \(exerciseType == .plank ? "seconds" : "reps")")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.kaizenGray)
                    
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
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(SwipeBackFix())
        .onSwipeBack {
            HapticManager.shared.playWorkoutStart()
            dismiss()
        }
    }
}
