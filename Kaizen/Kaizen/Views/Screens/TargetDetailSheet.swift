import SwiftUI
import SwiftData

struct TargetDetailSheet: View {
    let target: ExerciseTarget
    let type: ExerciseType
    let workoutManager: WorkoutManager
    @Binding var path: [KaizenRoute]
    @Environment(\.dismiss) var dismiss
    
    // Using @Query to fetch all sessions to calculate PB
    @Query private var sessions: [ExerciseSession]
    
    init(target: ExerciseTarget, type: ExerciseType, workoutManager: WorkoutManager, path: Binding<[KaizenRoute]>) {
        self.target = target
        self.type = type
        self.workoutManager = workoutManager
        self._path = path
        
        let rawValue = type.rawValue
        self._sessions = Query(
            filter: #Predicate<ExerciseSession> { session in
                session.exerciseTypeRaw == rawValue && session.completed == true
            },
            sort: \ExerciseSession.repsOrDuration,
            order: .reverse
        )
    }
    
    private var allTimeBest: Int {
        sessions.first?.repsOrDuration ?? 0
    }
    
    var body: some View {
        ZStack {
            Color.kaizenShadow.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 32) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(target.name.uppercased())
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                        Text("DAILY RITUAL INITIATIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(target.color)
                            .tracking(2)
                    }
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(target.color.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: iconName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(target.color)
                    }
                }
                
                // Stats
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TODAY'S GOAL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.kaizenGray)
                        Text("\(target.goal)\(type == .plank ? "s" : "")")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ALL-TIME BEST")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.kaizenGray)
                        Text("\(allTimeBest)\(type == .plank ? "s" : "")")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(target.color)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // Start Button
                Button(action: {
                    HapticManager.shared.playWorkoutStart()
                    dismiss()
                    
                    // Allow UI to dismiss, then jump to workout
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        workoutManager.startWorkout(type: type, goal: target.goal)
                        path.append(.activeWorkout(type))
                    }
                }) {
                    HStack {
                        Text("START SESSION")
                            .font(.system(size: 14, weight: .black))
                            .tracking(2)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.kaizenShadow)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(target.color)
                    .cornerRadius(16)
                    .shadow(color: target.color.opacity(0.3), radius: 15, x: 0, y: 10)
                }
                .padding(.bottom, 10)
            }
            .padding(30)
        }
    }
    
    private var iconName: String {
        switch type {
        case .pushups: return "figure.pushups"
        case .squats: return "figure.cross.training"
        case .plank: return "figure.strengthtraining.functional"
        }
    }
}
