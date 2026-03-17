import SwiftUI

struct KaizenPlusButton: View {
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.playWorkoutStart()
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.kaizenMint, Color.kaizenSage],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: Color.kaizenMint.opacity(0.38), radius: 24, x: 0, y: 16)
                
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.kaizenShadow)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
            }
            .scaleEffect(isExpanded ? 1.06 : 1.0)
            .animation(.spring(response: 0.36, dampingFraction: 0.72), value: isExpanded)
        }
    }
}

#Preview {
    ZStack {
        Color.kaizenShadow.ignoresSafeArea()
        VStack(spacing: 40) {
            KaizenPlusButton(isExpanded: false) {}
            KaizenPlusButton(isExpanded: true) {}
        }
    }
}
