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
    struct ProgressSnapshot: Identifiable {
        let id: String
        let title: String
        let baseline: Int
        let current: Int
        let trend: [Double]
        let icon: String
        let isTime: Bool
    }

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
            syncProgressState(for: profile, didAdvanceCycle: true)

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
        syncProgressState(for: profile)

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

    func currentBest(for type: ExerciseType) -> Int {
        fetchCompletedSessions(for: type).map(\.repsOrDuration).max() ?? 0
    }

    func progressSnapshot(for type: ExerciseType, profile: UserProfile? = nil) -> ProgressSnapshot {
        let sessions = fetchCompletedSessions(for: type).sorted { $0.date < $1.date }
        let resolvedProfile = profile ?? fetchProfile()
        let baseline = baselineValue(for: type, profile: resolvedProfile) > 0
            ? baselineValue(for: type, profile: resolvedProfile)
            : (sessions.first?.repsOrDuration ?? defaultStartingTarget(for: type))
        let current = max(currentBest(for: type), baseline)
        let scale = max(current, baseline, 1)

        var trendValues = sessions.map { Double($0.repsOrDuration) / Double(scale) }
        if trendValues.isEmpty {
            let baselinePoint = Double(baseline) / Double(scale)
            trendValues = [baselinePoint, baselinePoint]
        } else if trendValues.count == 1, let first = trendValues.first {
            trendValues = [first, first]
        }

        if trendValues.count > 7 {
            trendValues = Array(trendValues.suffix(7))
        }

        return ProgressSnapshot(
            id: type.rawValue,
            title: type.rawValue,
            baseline: baseline,
            current: current,
            trend: trendValues,
            icon: iconName(for: type),
            isTime: type == .plank
        )
    }

    func updateBaselines(profile: UserProfile) {
        let pushupBaseline = earliestCompletedValue(for: .pushups)
        let squatBaseline = earliestCompletedValue(for: .squats)
        let plankBaseline = earliestCompletedValue(for: .plank)

        var didChange = false

        if profile.baselinePushups == 0, let pushupBaseline {
            profile.baselinePushups = pushupBaseline
            didChange = true
        }

        if profile.baselineSquats == 0, let squatBaseline {
            profile.baselineSquats = squatBaseline
            didChange = true
        }

        if profile.baselinePlank == 0, let plankBaseline {
            profile.baselinePlank = plankBaseline
            didChange = true
        }

        syncProgressState(for: profile)

        if didChange {
            try? modelContext?.save()
        }
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

    private func fetchCompletedSessions(for type: ExerciseType) -> [ExerciseSession] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<ExerciseSession>(
            predicate: #Predicate<ExerciseSession> {
                $0.exerciseTypeRaw == type.rawValue && $0.completed == true
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    private func earliestCompletedValue(for type: ExerciseType) -> Int? {
        fetchCompletedSessions(for: type).first?.repsOrDuration
    }

    private func iconName(for type: ExerciseType) -> String {
        switch type {
        case .pushups:
            return "figure.pushups"
        case .squats:
            return "figure.cross.training"
        case .plank:
            return "figure.strengthtraining.functional"
        }
    }

    private func syncProgressState(for profile: UserProfile, didAdvanceCycle: Bool = false) {
        let progress: SwordProgress
        if let existing = profile.progress {
            progress = existing
        } else {
            let newProgress = SwordProgress()
            profile.progress = newProgress
            if newProgress.modelContext == nil {
                modelContext?.insert(newProgress)
            }
            progress = newProgress
        }

        progress.currentTier = profile.currentSwordTier
        progress.auraState = auraState(for: profile.currentSwordTier)

        if didAdvanceCycle {
            progress.completedCycles += 1
            progress.lastTierUpgradeDate = Date()
        }
    }

    private func auraState(for tier: SwordTier) -> AuraState {
        switch tier {
        case .wooden:
            return .none
        case .steel:
            return .faint
        case .gold:
            return .glowing
        case .shadow:
            return .radiant
        }
    }
}
