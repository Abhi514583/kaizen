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
    var progressManager: ProgressManager?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func setProgressManager(_ manager: ProgressManager) {
        self.progressManager = manager
    }
    
    // MARK: - Streak Logic
    
    /// Checks for missed days and updates streak/freezes accordingly.
    /// Replaces ProgressionManager.processDailyCheck
    func validateDailyStreak(profile: UserProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if profile.currentStreak == 0 && !hasAnyCompletedDays() {
            profile.lastActivityDate = nil
            try? modelContext?.save()
            return
        }
        
        guard let lastTrackedDate = profile.lastActivityDate else {
            return
        }
        
        let lastActivity = calendar.startOfDay(for: lastTrackedDate)

        guard let daysBetween = calendar.dateComponents([.day], from: lastActivity, to: today).day, daysBetween > 0 else {
            return
        }

        var latestSatisfiedDate = lastActivity

        // We check every day from (lastActivity + 1) up to yesterday (which is today - 1)
        for i in 1...daysBetween {
            guard let dateToCheck = calendar.date(byAdding: .day, value: i, to: lastActivity) else { continue }
            
            // If dateToCheck is today, we don't penalize yet.
            if dateToCheck >= today { break }
            
            // Check DailySummary for dateToCheck
            var isSatisfied = false
            if let context = modelContext {
                let descriptor = FetchDescriptor<DailySummary>(
                    predicate: #Predicate<DailySummary> { $0.date == dateToCheck }
                )
                if let summary = try? context.fetch(descriptor).first {
                    if summary.sessionsCompleted > 0 || summary.freezeUsed {
                        isSatisfied = true
                    }
                }
            }
            
            if !isSatisfied {
                if profile.freezesRemaining > 0 {
                    consumeFreeze(profile: profile, on: dateToCheck)
                    latestSatisfiedDate = dateToCheck
                } else {
                    breakStreak(profile: profile)
                    progressManager?.handleDemotion(profile: profile)
                    profile.lastActivityDate = nil
                    break
                }
            } else {
                latestSatisfiedDate = dateToCheck
            }
        }

        if profile.currentStreak > 0 {
            profile.lastActivityDate = latestSatisfiedDate
        }

        try? modelContext?.save()
    }
    
    /// Increments streak if the day's first session is completed.
    func onActivityCompleted(profile: UserProfile) {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        validateDailyStreak(profile: profile)
        
        var todaySummary: DailySummary?
        if let context = modelContext {
            let descriptor = FetchDescriptor<DailySummary>(
                predicate: #Predicate<DailySummary> { $0.date == todayStart }
            )
            todaySummary = try? context.fetch(descriptor).first
        }

        guard let todaySummary else { return }
        let ritualCompleted = progressManager?.isDailyRitualComplete(summary: todaySummary, profile: profile, on: todayStart)
            ?? (todaySummary.sessionsCompleted > 0)

        guard ritualCompleted else { return }

        if let lastActivityDate = profile.lastActivityDate,
           calendar.isDate(lastActivityDate, inSameDayAs: todayStart) {
            return
        }

        profile.currentStreak += 1
        profile.lastActivityDate = todayStart
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

    private func hasAnyCompletedDays() -> Bool {
        guard let context = modelContext else { return false }
        let descriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate<DailySummary> { $0.sessionsCompleted > 0 }
        )
        let count = (try? context.fetchCount(descriptor)) ?? 0
        return count > 0
    }
}
