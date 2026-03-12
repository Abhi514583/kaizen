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
                Circle()
                    .fill(Color.kaizenSage)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.kaizenSage.opacity(0.4), radius: 15, x: 0, y: 0) // Core Glow
                    .shadow(color: Color.kaizenSage.opacity(0.2), radius: 30, x: 0, y: 0) // Outer Glow
                
                Image(systemName: "plus")
                    .font(.title.weight(.bold))
                    .foregroundColor(.kaizenShadow)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
            }
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
