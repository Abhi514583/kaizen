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
    var exerciseType: ExerciseType
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
        self.exerciseType = exerciseType
        self.repsOrDuration = repsOrDuration
        self.targetForThatDay = targetForThatDay
        self.completed = completed
        self.videoPath = videoPath
    }
}
