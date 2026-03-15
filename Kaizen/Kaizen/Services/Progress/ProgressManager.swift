import Foundation
import SwiftData
import Observation

/// Manages performance analytics and 30-day "Sword Path" progression.
/// Responsibilities:
/// - Calculate "1% Better" improvement percentages
/// - Handled Sword Tier upgrades/downgrades
/// - Manage baseline values
/// - Orchestrate cycle resets
@Observable
@MainActor
final class ProgressManager {
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Progression Logic
    
    /// Checks if a 30-day cycle has concluded and handles tiering.
    /// Replaces ProgressionManager.advanceCycle / handleDemotion
    func checkCycleCompletion(profile: UserProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cycleStart = calendar.startOfDay(for: profile.cycleStartDate ?? Date())
        
        guard let daysSinceReset = calendar.dateComponents([.day], from: cycleStart, to: today).day else {
            return
        }
        
        if daysSinceReset >= 30 {
            // Upgrade Tier
            if let nextTier = profile.currentSwordTier.next {
                profile.currentSwordTier = nextTier
                HapticManager.shared.playSwordTierUnlock()
            }
            
            // Reset Cycle
            profile.cycleStartDate = today
            profile.freezesRemaining = 8
            
            try? modelContext?.save()
        }
    }
    
    /// Called when the user runs out of freezes and breaks their streak
    func handleDemotion(profile: UserProfile) {
        if let previousTier = profile.currentSwordTier.previous {
            profile.currentSwordTier = previousTier
        }
        
        // Reset Cycle either way
        profile.cycleStartDate = Date()
        profile.freezesRemaining = 8
        
        try? modelContext?.save()
    }
    
    /// Calculates the next daily target by finding the last completed session target and adding min(+1) or 1%.
    func calculateDailyTarget(for type: ExerciseType) -> Int {
        guard let context = modelContext else { return type == .plank ? 10 : 1 }
        
        let descriptor = FetchDescriptor<ExerciseSession>(
            predicate: #Predicate<ExerciseSession> { $0.exerciseTypeRaw == type.rawValue && $0.completed == true },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        guard let latestSession = try? context.fetch(descriptor).first else {
            // Starter baselines if they have never successfully tracked this exercise
            return type == .plank ? 10 : 1
        }
        
        let oldTarget = latestSession.targetForThatDay
        
        // 1% rule: Either jump by 1% or a minimum of 1 rep to ensure constant progress
        let increment = max(1, Int(Double(oldTarget) * 0.01))
        
        return oldTarget + increment
    }
    
    func updateBaselines(profile: UserProfile) {
        // TODO: Update UserProfile with latest baseline averages for long-term charts
    }
}
