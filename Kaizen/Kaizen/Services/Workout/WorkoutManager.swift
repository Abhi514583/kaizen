import Foundation
import Observation
import SwiftData

/// Manages the lifecycle of a workout session.
/// Responsibilities:
/// - Start/Pause/Complete/Cancel workout sessions
/// - Track active reps and duration
/// - Save finished sessions to SwiftData
/// - Trigger DailySummary aggregation
@Observable
@MainActor
final class WorkoutManager {
    // MARK: - Active Session State
    var activeSession: ExerciseSession?
    var currentReps: Int = 0
    var currentDuration: TimeInterval = 0
    var isPaused: Bool = false
    
    // MARK: - Internal Timer
    private var timer: Timer?
    
    // MARK: - Initialization
    // We will use an environment-injected ModelContext
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Session Lifecycle
    
    func startWorkout(type: ExerciseType, goal: Int) {
        activeSession = ExerciseSession(
            exerciseType: type,
            targetForThatDay: goal
        )
        currentReps = 0
        currentDuration = 0
        isPaused = false
        
        if type == .plank {
            startTimer()
        }
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimer()
        } else if activeSession?.exerciseType == .plank {
            startTimer()
        }
    }
    
    func updateReps(count: Int) {
        guard !isPaused else { return }
        currentReps = count
    }
    
    func completeWorkout() {
        stopTimer()
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
        }
        
        // Note: Streak/Progress updates will be triggered here in later issues
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
        activeSession = nil
        currentReps = 0
        currentDuration = 0
        isPaused = false
    }
    
    // MARK: - Timer Helpers
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.currentDuration += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
