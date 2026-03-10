import Foundation
import SwiftData

@MainActor
final class ProgressionManager {
    static let shared = ProgressionManager()
    
    private init() {}
    
    /// Processes daily progression, checks for missed days, consumes freezes, or handles demotion.
    func processDailyCheck(progression: UserProgression, modelContext: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // If they already worked out today, nothing to check for penalty
        if let last = progression.lastWorkoutDate, calendar.isDate(last, inSameDayAs: today) {
            return
        }
        
        guard let lastWorkout = progression.lastWorkoutDate else {
            // First time using the app. We don't penalize until they start.
            return
        }
        
        // Calculate days missed since the last workout
        let lastWorkoutDay = calendar.startOfDay(for: lastWorkout)
        let components = calendar.dateComponents([.day], from: lastWorkoutDay, to: today)
        let missedDays = (components.day ?? 0) - 1
        
        var demoted = false
        
        // Consume freezes sequentially
        if missedDays > 0 {
            for _ in 0..<missedDays {
                if progression.freezesRemaining > 0 {
                    progression.freezesUsed += 1
                    HapticManager.shared.playFreezeConsumed()
                } else {
                    handleDemotion(progression: progression)
                    demoted = true
                    break // Stop processing days once demoted and cycle reset
                }
            }
        }
        
        // Only check for cycle completion if they weren't just demoted (which resets cycle)
        if !demoted && progression.isCycleComplete {
            advanceCycle(progression: progression)
        }
        
        try? modelContext.save()
    }
    
    /// Called when a workout is completed
    func completeWorkout(progression: UserProgression, modelContext: ModelContext) {
        progression.lastWorkoutDate = Date()
        HapticManager.shared.playSessionComplete()
        
        if progression.isCycleComplete {
            advanceCycle(progression: progression)
        }
        
        try? modelContext.save()
    }
    
    private func advanceCycle(progression: UserProgression) {
        // If they completed the cycle without breaking, they level up
        if let nextTier = progression.currentTier.next {
            progression.currentTier = nextTier
            HapticManager.shared.playSwordTierUnlock()
        }
        
        resetCycle(progression: progression)
    }
    
    private func handleDemotion(progression: UserProgression) {
        if let previousTier = progression.currentTier.previous {
            progression.currentTier = previousTier
        }
        
        // Reset cycle either way if they fail
        resetCycle(progression: progression)
    }
    
    private func resetCycle(progression: UserProgression) {
        // We set the cycle start to today, and lastWorkout is preserved so that
        // the user has a fresh start tomorrow without immediate penalty if they don't workout again today.
        progression.cycleStartDate = Date()
        progression.freezesUsed = 0
    }
}
