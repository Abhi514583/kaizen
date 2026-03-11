import SwiftUI

struct WorkoutView: View {
    @Binding var path: [KaizenRoute]
    let exerciseName: String
    let pr: String
    let goal: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentReps = 0
    @State private var isPaused = false
    
    var body: some View {
        ZStack {
            // MARK: - Camera Placeholder Backdrop
            Color.black
                .ignoresSafeArea()
            
            // Subtle Grid/Vision Placeholder for "Anime" vibe
            Canvas { context, size in
                let spacing: CGFloat = 40
                for x in stride(from: 0, to: size.width, by: spacing) {
                    for y in stride(from: 0, to: size.height, by: spacing) {
                        context.fill(Path(CGRect(x: x, y: y, width: 1, height: 1)), with: .color(Color.kaizenSage.opacity(0.1)))
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack {
                // MARK: - Top Stats Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exerciseName.uppercased())
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.kaizenWhite)
                            .tracking(2)
                        
                        HStack(spacing: 12) {
                            statLabel(title: "BEST", value: pr)
                            statLabel(title: "GOAL", value: "\(goal)")
                        }
                    }
                    Spacer()
                    
                    // Live Timer Placeholder
                    timerView
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // MARK: - Central Rep Counter
                VStack(spacing: -10) {
                    Text("\(currentReps)")
                        .font(.system(size: 160, weight: .black, design: .rounded))
                        .foregroundColor(.kaizenWhite)
                        .shadow(color: Color.kaizenSage.opacity(0.4), radius: 20)
                        .shadow(color: Color.kaizenSage.opacity(0.2), radius: 40)
                    
                    Text("REPS")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.kaizenSage)
                        .tracking(10)
                        .offset(x: 5)
                }
                .scaleEffect(isPaused ? 0.9 : 1.0)
                .opacity(isPaused ? 0.5 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentReps)
                
                Spacer()
                
                // MARK: - Controls
                HStack(spacing: 30) {
                    controlButton(icon: isPaused ? "play.fill" : "pause.fill") {
                        withAnimation { isPaused.toggle() }
                        HapticManager.shared.playWorkoutStart()
                    }
                    
                    controlButton(icon: "xmark", isDestructive: true) {
                        if let exerciseType = ExerciseType(rawValue: exerciseName) {
                            path.append(.sessionComplete(exerciseType, currentReps))
                        } else {
                            dismiss()
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func statLabel(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kaizenGray)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.kaizenSage)
        }
    }
    
    private var timerView: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("SESSION TIME")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.kaizenGray)
            Text("04:20")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.kaizenWhite)
        }
    }
    
    private func controlButton(icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isDestructive ? .red : .kaizenWhite)
            }
        }
    }
}

#Preview {
    WorkoutView(path: .constant([]), exerciseName: "Pushups", pr: "45 PR", goal: 50)
}
