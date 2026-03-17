import SwiftUI
import Vision

/// Draws a real-time skeleton overlay over the camera feed.
/// Reads normalized joint positions from VisionManager.
struct SkeletonOverlayView: View {
    let joints: [VNHumanBodyPoseObservation.JointName: CGPoint]
    let formState: FormState
    var frameSize: CGSize = .zero

    enum FormState {
        case good, warning, broken
    }

    private var lineColor: Color {
        switch formState {
        case .good:    return .kaizenSage
        case .warning: return .orange
        case .broken:  return .red
        }
    }

    var body: some View {
        Canvas { context, size in
            let effective = frameSize == .zero ? size : frameSize

            let hasRightChain = joints[.rightShoulder] != nil && joints[.rightElbow] != nil && joints[.rightHip] != nil
            let sidePrefix = hasRightChain ? "right" : "left"

            let bones: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = sidePrefix == "right"
                ? [
                    (.rightShoulder, .rightElbow),
                    (.rightElbow, .rightWrist),
                    (.rightShoulder, .rightHip),
                    (.rightHip, .rightKnee),
                    (.rightKnee, .rightAnkle)
                ]
                : [
                    (.leftShoulder, .leftElbow),
                    (.leftElbow, .leftWrist),
                    (.leftShoulder, .leftHip),
                    (.leftHip, .leftKnee),
                    (.leftKnee, .leftAnkle)
                ]

            for (jointA, jointB) in bones {
                guard let ptA = joints[jointA], let ptB = joints[jointB] else { continue }
                let screenA = toScreen(ptA, in: effective)
                let screenB = toScreen(ptB, in: effective)

                var path = Path()
                path.move(to: screenA)
                path.addLine(to: screenB)
                context.stroke(path, with: .color(lineColor.opacity(0.85)), lineWidth: 4)
            }

            for joint in bones.flatMap({ [$0.0, $0.1] }) {
                guard let pt = joints[joint] else { continue }
                let screenPt = toScreen(pt, in: effective)
                let dotRect = CGRect(x: screenPt.x - 5, y: screenPt.y - 5, width: 10, height: 10)
                context.fill(Path(ellipseIn: dotRect), with: .color(lineColor))
            }
        }
        .allowsHitTesting(false)
    }

    private func toScreen(_ pt: CGPoint, in size: CGSize) -> CGPoint {
        // Vision normalized: x=0 is left, y=0 is BOTTOM — already flipped by VisionManager
        CGPoint(x: pt.x * size.width, y: pt.y * size.height)
    }
}
