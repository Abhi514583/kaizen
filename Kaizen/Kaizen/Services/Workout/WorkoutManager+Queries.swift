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
    
    /// Fetches the DailySummary for a specific calendar day.
    func fetchSummary(for date: Date) -> DailySummary? {
        guard let context = modelContext else { return nil }
        
        let targetDate = Calendar.current.startOfDay(for: date)
        
        let predicate = #Predicate<DailySummary> { summary in
            summary.date == targetDate
        }
        
        var descriptor = FetchDescriptor<DailySummary>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        return (try? context.fetch(descriptor))?.first
    }
}
