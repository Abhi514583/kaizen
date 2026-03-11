import SwiftUI

struct WorkoutSetupView: View {
    @Binding var path: [KaizenRoute]
    let exerciseType: ExerciseType
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
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
        }
    }
}
