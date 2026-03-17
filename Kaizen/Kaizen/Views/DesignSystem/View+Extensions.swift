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
