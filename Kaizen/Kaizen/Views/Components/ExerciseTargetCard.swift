import SwiftUI

struct ExerciseTarget: Identifiable, Equatable {
    let id: String // Use a stable string (type.rawValue)
    let type: ExerciseType
    let name: String
    let current: Int
    let goal: Int
    let color: Color
}

struct ExerciseTargetCard: View {
    let target: ExerciseTarget
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(target.color.opacity(0.14))
                            .frame(width: 48, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(target.color.opacity(0.16), lineWidth: 1)
                            )

                        Image(systemName: iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(target.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(target.name.uppercased())
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.kaizenWhite)
                            .tracking(1.4)

                        Text(statusCopy)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.kaizenFog.opacity(0.72))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text(valueLabel)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(.kaizenWhite)
                                .contentTransition(.numericText())

                            Text(goalLabel)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.kaizenFog.opacity(0.7))
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.kaizenFog.opacity(0.52))
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.06))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [target.color.opacity(0.9), target.color.opacity(0.55)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(18, geo.size.width * progress))
                            .shadow(color: target.color.opacity(0.24), radius: 10, x: 0, y: 0)
                    }
                }
                .frame(height: 8)
            }
            .padding(18)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var progress: CGFloat {
        guard target.goal > 0 else { return 0 }
        return min(1.0, CGFloat(target.current) / CGFloat(target.goal))
    }

    private var valueLabel: String {
        "\(target.current)\(target.type == .plank ? "s" : "")"
    }

    private var goalLabel: String {
        "/\(target.goal)\(target.type == .plank ? "s" : "")"
    }

    private var statusCopy: String {
        if progress >= 1.0 {
            return "Target complete"
        }
        if target.current > 0 {
            return "\(Int(progress * 100))% of today"
        }
        return "Ready for first set"
    }
    
    private var iconName: String {
        switch target.name.lowercased() {
        case "pushups": return "figure.pushups"
        case "squats": return "figure.cross.training"
        case "plank": return "figure.strengthtraining.functional"
        default: return "figure.walk"
        }
    }
}

#Preview {
    ZStack {
        Color.kaizenShadow.ignoresSafeArea()
        VStack(spacing: 16) {
            ExerciseTargetCard(target: ExerciseTarget(id: "pushups", type: .pushups, name: "Pushups", current: 30, goal: 50, color: .kaizenSage))
            ExerciseTargetCard(target: ExerciseTarget(id: "squats", type: .squats, name: "Squats", current: 80, goal: 80, color: .kaizenWood))
        }
        .padding()
    }
}
