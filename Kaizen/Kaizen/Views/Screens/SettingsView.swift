import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
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
                
                VStack(spacing: UIConstants.Spacing.md) {
                    Text("Settings")
                        .font(.kaizenLargeHeader)
                        .foregroundColor(.kaizenWhite)
                    Text("App Configuration")
                        .font(.kaizenBody)
                        .foregroundColor(.kaizenGray)
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
