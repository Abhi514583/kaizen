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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Icon + Name
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(target.color.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: iconName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(target.color)
                    }
                    
                    Text(target.name.uppercased())
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .tracking(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.kaizenGray.opacity(0.5))
                    .padding(.trailing, 8)
                
                // Progress Label
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(target.current)")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("/\(target.goal)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.kaizenGray)
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                    
                    Capsule()
                        .fill(target.color)
                        .frame(width: geo.size.width * min(1.0, CGFloat(target.current) / CGFloat(target.goal)))
                        .shadow(color: target.color.opacity(0.3), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 4)
        }
        .contentShape(Rectangle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .buttonStyle(.plain) // Prevents the whole stack from being tinted
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
