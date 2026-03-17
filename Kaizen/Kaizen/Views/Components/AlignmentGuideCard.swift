import SwiftUI

/// Floating card that tells the user how to position themselves.
struct AlignmentGuideCard: View {
    let positioningState: PositioningState
    let exerciseType: ExerciseType

    @State private var pulse = false

    private var isReady: Bool {
        if case .ready = positioningState { return true }
        if case .countdown = positioningState { return true }
        return false
    }

    private var instructionText: String {
        switch positioningState {
        case .ready:
            return "✓ Position locked in"
        case .countdown(let n):
            return "Starting in \(n)…"
        case .notReady(let reason):
            return reason
        }
    }

    private var ringColor: Color {
        isReady ? .kaizenSage : .orange
    }

    var body: some View {
        VStack(spacing: 14) {
            // Exercise icon + tip
            HStack(spacing: 12) {
                Image(systemName: exerciseIcon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.kaizenGray)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(exerciseTip)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.kaizenGray)
                        .tracking(1)

                    Text(instructionText)
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(isReady ? .kaizenSage : .white)
                        .animation(.easeInOut(duration: 0.3), value: instructionText)
                }

                Spacer()

                // Status ring
                ZStack {
                    Circle()
                        .stroke(ringColor.opacity(0.25), lineWidth: 3)
                        .frame(width: 36, height: 36)

                    Circle()
                        .trim(from: 0, to: isReady ? 1.0 : 0.3)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isReady)

                    if isReady {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.kaizenSage)
                    }
                }
                .scaleEffect(pulse && !isReady ? 1.08 : 1.0)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ringColor.opacity(isReady ? 0.5 : 0.2), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var exerciseIcon: String {
        switch exerciseType {
        case .pushups: return "figure.pushups"
        case .squats:  return "figure.cross.training"
        case .plank:   return "figure.strengthtraining.functional"
        }
    }

    private var exerciseTip: String {
        switch exerciseType {
        case .pushups: return "BACK ULTRA-WIDE · HIP HEIGHT · FULL SIDE VIEW"
        case .squats:  return "PHONE AT HIP HEIGHT · SIDE VIEW"
        case .plank:   return "PHONE AT FLOOR LEVEL · SIDE VIEW"
        }
    }
}
