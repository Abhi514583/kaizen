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
    
    /// Real-time improvement calculation for UI.
    func calculateImprovement(for type: ExerciseType) -> Double {
        // TODO: Logic to compare latest session with baseline
        return 0.0
    }
    
    func updateBaselines(profile: UserProfile) {
        // TODO: Update UserProfile with latest baseline averages
    }
}
