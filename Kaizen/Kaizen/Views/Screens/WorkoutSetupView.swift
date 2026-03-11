import SwiftUI

struct WorkoutSetupView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var path: [KaizenRoute]
    let exerciseType: ExerciseType
    
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
                    
                    Button(action: {
                        HapticManager.shared.playWorkoutStart()
                        path.append(.activeWorkout(exerciseType))
                    }) {
                        Text("Start")
                            .font(.kaizenSectionHeader)
                            .foregroundColor(.kaizenShadow)
                            .padding(.horizontal, 48)
                            .padding(.vertical, 16)
                            .background(Color.kaizenSage)
                            .clipShape(Capsule())
                    }
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
