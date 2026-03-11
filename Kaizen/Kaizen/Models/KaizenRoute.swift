import Foundation

enum KaizenRoute: Hashable {
    case home
    case calendar
    case improvement
    case settings
    case workoutSetup(ExerciseType)
    case activeWorkout(ExerciseType)
    case sessionComplete(ExerciseType, Int)
}
