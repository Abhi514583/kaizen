import SwiftUI

struct WorkoutSetupView: View {
    @Binding var path: [KaizenRoute]
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            VStack(spacing: UIConstants.Spacing.lg) {
                Text("Begin Ritual")
                    .font(.kaizenLargeHeader)
                    .foregroundColor(.kaizenWhite)
                Text("Select your focus for today.")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenGray)
                
                Button(action: {
                    HapticManager.shared.playWorkoutStart()
                    path.append(.activeWorkout)
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
