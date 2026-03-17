import Foundation
import Observation
import SwiftData

/// Manages the lifecycle of a workout session.
/// Responsibilities:
/// - Start/Pause/Complete/Cancel workout sessions
/// - Track active reps and duration
/// - Save finished sessions to SwiftData
/// - Trigger DailySummary aggregation
/// - Bridge VisionManager callbacks into session state
@Observable
@MainActor
final class WorkoutManager {
    // MARK: - Active Session State
    var activeSession: ExerciseSession?
    var currentReps: Int = 0
    var currentDuration: TimeInterval = 0
    var isPaused: Bool = false
    var inactivitySecondsRemaining: Int = 0
    var isInactivityCountingDown: Bool = false

    // MARK: - Internal Timers
    private var timer: Timer?
    private var inactivityTimer: Timer?
    private let inactivityTimeout: TimeInterval = 10.0

    // MARK: - Services
    var modelContext: ModelContext?
    var streakManager: StreakManager?
    var progressManager: ProgressManager?
    var visionManager: VisionManager?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func setStreakManager(_ manager: StreakManager) {
        self.streakManager = manager
    }

    func setProgressManager(_ manager: ProgressManager) {
        self.progressManager = manager
    }

    func setVisionManager(_ manager: VisionManager) {
        self.visionManager = manager
        manager.onRepCounted = { [weak self] _ in
            Task { @MainActor [weak self] in self?.onRepDetected() }
        }
        manager.onPlankAlignmentChanged = { [weak self] isAligned in
            Task { @MainActor [weak self] in self?.onPlankAlignmentChanged(isAligned) }
        }
        manager.onSessionShouldEnd = { [weak self] in
            Task { @MainActor [weak self] in self?.completeWorkout() }
        }
    }

    // MARK: - Session Lifecycle

    /// Initiates a new workout session for a given exercise type
    func startWorkout(type: ExerciseType, goal: Int) {
        stopTimer()
        stopInactivityTimer()
        let newSession = ExerciseSession(
            exerciseType: type,
            targetForThatDay: goal
        )
        activeSession = newSession
        currentReps = 0
        currentDuration = 0
        isPaused = false
        inactivitySecondsRemaining = 0
        isInactivityCountingDown = false

        // Start Vision tracking
        visionManager?.startExercise(type)

        if type == .plank {
            // Plank timer driven by alignment, not a simple repeating timer
            // It starts when alignment is confirmed via onPlankAlignmentChanged
        } else {
            // For rep-based exercises, start inactivity guard
            resetInactivityTimer()
        }
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimer()
            stopInactivityTimer()
        } else {
            if activeSession?.exerciseType == .plank && plankShouldTime {
                startTimer()
            } else {
                resetInactivityTimer()
            }
        }
    }

    private var plankShouldTime: Bool { visionManager?.plankIsAligned ?? false }

    func updateReps(count: Int) {
        guard !isPaused else { return }
        currentReps = count
    }

    /// Manual increment for testing habit loop logic without pose detection.
    func addManualReps(_ count: Int) {
        guard !isPaused else { return }
        currentReps += count
        resetInactivityTimer() // tapping manual keeps session alive
    }

    /// Manual increment for duration testing.
    func addManualDuration(_ seconds: TimeInterval) {
        guard !isPaused else { return }
        currentDuration += seconds
        // Plank duration is alignment-driven, no inactivity timer needed
    }

    // MARK: - Vision Callbacks

    func onRepDetected() {
        guard !isPaused, activeSession != nil else { return }
        currentReps += 1
        resetInactivityTimer()
    }

    func onPlankAlignmentChanged(_ isAligned: Bool) {
        guard activeSession?.exerciseType == .plank, !isPaused else { return }
        if isAligned {
            startTimer()
        } else {
            stopTimer()
        }
    }

    // MARK: - Inactivity Timer

    private func resetInactivityTimer() {
        stopInactivityTimer()
        inactivitySecondsRemaining = Int(inactivityTimeout)
        isInactivityCountingDown = false

        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.inactivitySecondsRemaining -= 1
                if self.inactivitySecondsRemaining <= 3 {
                    self.isInactivityCountingDown = true
                }
                if self.inactivitySecondsRemaining <= 0 {
                    self.stopInactivityTimer()
                    self.completeWorkout()
                }
            }
        }
    }

    private func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
        isInactivityCountingDown = false
    }

    func completeWorkout() {
        stopTimer()
        stopInactivityTimer()
        visionManager?.stopExercise()
        guard let session = activeSession else { return }

        let sessionDate = Date()
        session.date = sessionDate
        session.repsOrDuration = session.exerciseType == .plank ? Int(currentDuration) : currentReps
        session.completed = true

        if let context = modelContext {
            context.insert(session)
            try? context.save()

            // Trigger DailySummary aggregation
            updateDailySummary(for: sessionDate)

            if let profile = fetchProfile() {
                progressManager?.updateBaselines(profile: profile)
                streakManager?.onActivityCompleted(profile: profile)
                progressManager?.checkCycleCompletion(profile: profile)
            }
        }

        activeSession = nil
        currentReps = 0
        currentDuration = 0
        isPaused = false
    }

    private func fetchProfile() -> UserProfile? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<UserProfile>()
        return (try? context.fetch(descriptor))?.first
    }

    /// Aggregates all sessions for a given day into a DailySummary record.
    func updateDailySummary(for date: Date) {
        guard let context = modelContext else { return }

        let sessions = fetchSessions(for: date)
        let summary = fetchSummary(for: date) ?? DailySummary(date: date)

        // Reset totals before re-aggregating
        summary.pushupsTotal = 0
        summary.squatsTotal = 0
        summary.plankTotal = 0
        summary.sessionsCompleted = 0

        for session in sessions where session.completed {
            summary.sessionsCompleted += 1

            switch session.exerciseType {
            case .pushups:
                summary.pushupsTotal += session.repsOrDuration
            case .squats:
                summary.squatsTotal += session.repsOrDuration
            case .plank:
                summary.plankTotal += session.repsOrDuration
            }
        }

        if summary.modelContext == nil {
            context.insert(summary)
        }

        try? context.save()
    }

    func cancelWorkout() {
        stopTimer()
        stopInactivityTimer()
        visionManager?.stopExercise()
        activeSession = nil
        currentReps = 0
        currentDuration = 0
        isPaused = false
        isInactivityCountingDown = false
    }

    // MARK: - Timer Helpers
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, !self.isPaused else { return }
                self.currentDuration += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
