import SwiftUI

struct KaizenPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.kaizenShadow)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Capsule()
                    .fill(Color.kaizenWhite)
                    .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.3)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct KaizenSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.kaizenWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.kaizenShadow)
                    .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.kaizenWhite.opacity(isEnabled ? 0.1 : 0.05), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == KaizenPrimaryButtonStyle {
    static var kaizenPrimary: KaizenPrimaryButtonStyle { KaizenPrimaryButtonStyle() }
}

extension ButtonStyle where Self == KaizenSecondaryButtonStyle {
    static var kaizenSecondary: KaizenSecondaryButtonStyle { KaizenSecondaryButtonStyle() }
}
