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
    
    /// Calculates a stable target for a given date using the last completed session
    /// before that day. This prevents the target from increasing mid-day after a save.
    func calculateDailyTarget(for type: ExerciseType, on date: Date = Date(), profile: UserProfile? = nil) -> Int {
        guard let context = modelContext else { return type == .plank ? 10 : 1 }
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        let descriptor = FetchDescriptor<ExerciseSession>(
            predicate: #Predicate<ExerciseSession> {
                $0.exerciseTypeRaw == type.rawValue && $0.completed == true && $0.date < startOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        guard let latestSession = try? context.fetch(descriptor).first else {
            let resolvedProfile = profile ?? fetchProfile()
            let baseline = baselineValue(for: type, profile: resolvedProfile)
            return baseline > 0 ? baseline : defaultStartingTarget(for: type)
        }
        
        let oldTarget = latestSession.targetForThatDay
        
        // 1% rule: Either jump by 1% or a minimum of 1 rep to ensure constant progress
        let increment = max(1, Int(Double(oldTarget) * 0.01))
        
        return oldTarget + increment
    }
    
    func dailyTargets(for date: Date = Date(), profile: UserProfile? = nil) -> [ExerciseType: Int] {
        let resolvedProfile = profile ?? fetchProfile()
        return [
            .pushups: calculateDailyTarget(for: .pushups, on: date, profile: resolvedProfile),
            .squats: calculateDailyTarget(for: .squats, on: date, profile: resolvedProfile),
            .plank: calculateDailyTarget(for: .plank, on: date, profile: resolvedProfile)
        ]
    }

    func isDailyRitualComplete(summary: DailySummary, profile: UserProfile? = nil, on date: Date = Date()) -> Bool {
        let targets = dailyTargets(for: date, profile: profile)
        return summary.pushupsTotal >= (targets[.pushups] ?? 0)
            && summary.squatsTotal >= (targets[.squats] ?? 0)
            && summary.plankTotal >= (targets[.plank] ?? 0)
    }

    func updateBaselines(profile: UserProfile) {
        // TODO: Update UserProfile with latest baseline averages for long-term charts
    }

    private func fetchProfile() -> UserProfile? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<UserProfile>()
        return (try? context.fetch(descriptor))?.first
    }

    private func baselineValue(for type: ExerciseType, profile: UserProfile?) -> Int {
        guard let profile else { return 0 }
        switch type {
        case .pushups:
            return profile.baselinePushups
        case .squats:
            return profile.baselineSquats
        case .plank:
            return profile.baselinePlank
        }
    }

    private func defaultStartingTarget(for type: ExerciseType) -> Int {
        type == .plank ? 10 : 1
    }
}
