import SwiftUI

struct UserWorkoutFlowView: View {
    @Binding var path: [KaizenRoute]
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            VStack(spacing: UIConstants.Spacing.lg) {
                Text("Active Workout")
                    .font(.kaizenLargeHeader)
                    .foregroundColor(.kaizenWhite)
                Text("Vision ML Tracking Placeholder")
                    .font(.kaizenBody)
                    .foregroundColor(.kaizenSage)
                
                Button(action: {
                    HapticManager.shared.playSessionComplete()
                    path = [] // Pop to root
                }) {
                    Text("Finish")
                        .font(.kaizenSectionHeader)
                        .foregroundColor(.kaizenShadow)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 16)
                        .background(Color.kaizenWhite)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
