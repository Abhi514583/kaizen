import Foundation
import SwiftData

extension WorkoutManager {
    /// Fetches all exercise sessions for a specific calendar day.
    func fetchSessions(for date: Date) -> [ExerciseSession] {
        guard let context = modelContext else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<ExerciseSession> { session in
            session.date >= startOfDay && session.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<ExerciseSession>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// Fetches the most recent session for a specific exercise type.
    func fetchLatestSession(for type: ExerciseType) -> ExerciseSession? {
        guard let context = modelContext else { return nil }
        
        let predicate = #Predicate<ExerciseSession> { session in
            session.exerciseType == type && session.completed == true
        }
        
        var descriptor = FetchDescriptor<ExerciseSession>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        return (try? context.fetch(descriptor))?.first
    }
}
