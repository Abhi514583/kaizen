import Foundation
import SwiftData

enum ExerciseType: String, Codable, CaseIterable {
    case pushups = "Pushups"
    case squats = "Squats"
    case plank = "Plank"
}

@Model
final class ExerciseSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var exerciseTypeRaw: String = "Pushups"
    
    var exerciseType: ExerciseType {
        get { return ExerciseType(rawValue: exerciseTypeRaw) ?? .pushups }
        set { exerciseTypeRaw = newValue.rawValue }
    }
    var repsOrDuration: Int
    var targetForThatDay: Int
    var completed: Bool
    var videoPath: String?
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         exerciseType: ExerciseType,
         repsOrDuration: Int = 0,
         targetForThatDay: Int,
         completed: Bool = false,
         videoPath: String? = nil) {
        
        self.id = id
        self.date = date
        self.exerciseTypeRaw = exerciseType.rawValue
        self.repsOrDuration = repsOrDuration
        self.targetForThatDay = targetForThatDay
        self.completed = completed
        self.videoPath = videoPath
    }
}
