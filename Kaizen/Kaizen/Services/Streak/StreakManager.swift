import Foundation
import SwiftData
import Observation

/// Manages daily streak and freeze logic.
/// Responsibilities:
/// - Enforce once-a-day ritual rules
/// - Update UserProfile streak data
/// - Manage freeze heart consumption (8 per cycle)
/// - Process daily missed day checks
@Observable
@MainActor
final class StreakManager {
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Streak Logic
    
    /// Checks for missed days and updates streak/freezes accordingly.
    /// Replaces ProgressionManager.processDailyCheck
    func validateDailyStreak(profile: UserProfile) {
        checkCycleReset(profile: profile)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActivity = calendar.startOfDay(for: profile.lastActivityDate ?? Date())
        
        guard let daysBetween = calendar.dateComponents([.day], from: lastActivity, to: today).day, daysBetween > 0 else {
            if profile.lastActivityDate == nil {
                profile.lastActivityDate = today
                try? modelContext?.save()
            }
            return // Still on the same day or somehow in the past
        }
        
        // daysBetween = 1 means they last worked out yesterday (perfect)
        // daysBetween = 2 means they missed 1 day (yesterday)
        let missedDays = daysBetween - 1
        
        if missedDays > 0 {
            for i in 0..<missedDays {
                guard let missedDate = calendar.date(byAdding: .day, value: i + 1, to: lastActivity) else { continue }
                if profile.freezesRemaining > 0 {
                    consumeFreeze(profile: profile, on: missedDate)
                } else {
                    breakStreak(profile: profile)
                    break
                }
            }
        }
        
        // Move the tracker up to today so we don't double-penalize
        profile.lastActivityDate = today
        try? modelContext?.save()
    }
    
    /// Increments streak if the day's first session is completed.
    func onActivityCompleted(profile: UserProfile) {
        let calendar = Calendar.current
        
        // If the user already worked out today, don't increment again
        if let lastActivity = profile.lastActivityDate, calendar.isDateInToday(lastActivity) && profile.currentStreak > 0 {
            // Already incremented today
            return
        }
        
        profile.currentStreak += 1
        profile.lastActivityDate = Date()
        try? modelContext?.save()
    }
    
    private func consumeFreeze(profile: UserProfile, on date: Date) {
        profile.freezesRemaining -= 1
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Check if summary exists for this day, create if it doesn't, mark as frozen
        if let context = modelContext {
            let descriptor = FetchDescriptor<DailySummary>(
                predicate: #Predicate<DailySummary> { $0.date == startOfDay }
            )
            
            if let existing = try? context.fetch(descriptor).first {
                existing.freezeUsed = true
            } else {
                let newSummary = DailySummary(date: startOfDay, freezeUsed: true)
                context.insert(newSummary)
            }
        }
    }
    
    private func breakStreak(profile: UserProfile) {
        profile.currentStreak = 0
    }
    
    private func checkCycleReset(profile: UserProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cycleStart = calendar.startOfDay(for: profile.cycleStartDate ?? Date())
        
        guard let daysSinceReset = calendar.dateComponents([.day], from: cycleStart, to: today).day else {
            return
        }
        
        // Reset every 30 days
        if daysSinceReset >= 30 {
            profile.freezesRemaining = 8
            profile.cycleStartDate = today
            try? modelContext?.save()
        }
    }
}
