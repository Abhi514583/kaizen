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
        // TODO: Logic to handle missed days and cycle resets
    }
    
    /// Increments streak if the day's first session is completed.
    func onActivityCompleted(profile: UserProfile) {
        // TODO: Streak increment logic
    }
    
    private func consumeFreeze(profile: UserProfile) {
        // TODO: Decrement freezesRemaining and mark DailySummary
    }
}
