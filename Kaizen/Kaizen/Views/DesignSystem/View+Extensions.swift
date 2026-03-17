import SwiftUI

extension View {
    /// Adds a global swipe-to-dismiss gesture that works from anywhere on the screen (not just the edge).
    /// - Parameters:
    ///   - action: The dismissal action to perform.
    ///   - threshold: The minimum horizontal distance to trigger the back action.
    func onSwipeBack(action: @escaping () -> Void, threshold: CGFloat = 80) -> some View {
        self.gesture(
            DragGesture()
                .onEnded { value in
                    // Only trigger if horizontal swipe is positive (left to right)
                    // and vertical variance is low (not a vertical scroll)
                    if value.translation.width > threshold && abs(value.translation.height) < 50 {
                        action()
                    }
                }
        )
    }

    func kaizenGlassCard(cornerRadius: CGFloat = 28, tint: Color = .white.opacity(0.07)) -> some View {
        modifier(KaizenGlassCardModifier(cornerRadius: cornerRadius, tint: tint))
    }

    func kaizenFloatingCapsule(tint: Color = .white.opacity(0.08)) -> some View {
        modifier(KaizenFloatingCapsuleModifier(tint: tint))
    }
}

/// UIKit hack to restore swipe-to-go-back when navigationBarHidden is true.
/// This allows the native edge-swipe to work even if we've hidden the standard bar.
struct SwipeBackFix: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            vc.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            vc.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private struct KaizenGlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tint,
                                        tint.opacity(0.45),
                                        Color.black.opacity(0.16)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.22),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 16)
                    .shadow(color: tint.opacity(0.08), radius: 30, x: 0, y: 0)
            }
    }
}

private struct KaizenFloatingCapsuleModifier: ViewModifier {
    let tint: Color

    func body(content: Content) -> some View {
        content
            .background {
                Capsule(style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [tint, Color.black.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.16), radius: 16, x: 0, y: 10)
            }
    }
}
