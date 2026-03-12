# Sprint 2: Logic, Persistence & Habit Loop

## Goal
Transform the Kaizen UI prototype into a functional habit-tracking application by implementing core services, session persistence, and domain logic.

## Completed Tasks

### [Issue 13] Service Layer Refactor
**Goal**: Decouple business logic from the UI and retire the legacy `ProgressionManager`.
- **Implementation**:
    - Created `Kaizen/Services` directory structure.
    - Initialized `WorkoutManager`, `StreakManager`, and `ProgressManager` as `@MainActor` services.
    - Simplified `ProgressionManager` by preparing its logic for relocation.
    - Injected services into the `KaizenApp` environment and connected them to the `sharedModelContainer.mainContext`.

### [Issue 1] Workout Session Lifecycle
**Goal**: Build a robust engine to manage training sessions from start to finish.
- **Implementation**:
    - **`WorkoutManager`**: Built a stateful service using the `@Observable` macro to track `activeSession`, `currentReps`, and `currentDuration`.
    - **Live Counters**: Implemented a `Timer` for duration-based exercises (Plank) and a rep counter for others.
    - **Persistence**: Connected `completeWorkout()` to SwiftData, automatically saving `ExerciseSession` records upon completion.
    - **UI Integration**:
        - `WorkoutSetupView`: Initializes the manager with the selected exercise and goal.
        - `WorkoutView`: Displays live data from the manager; replaced mock `@State` with environment-driven variables.
        - `SessionCompleteView`: Formats and displays real session results, including MM:SS formatting for duration.
    - **Navigation**: Ensured accurate value passing (reps vs. seconds) via `KaizenRoute`.

### [Issue 2] Workout Session Persistence
**Goal**: Solidify SwiftData persistence and enable date-based retrieval.
- **Implementation**:
    - **Query Helpers**: Created `WorkoutManager+Queries.swift` providing `fetchSessions(for:)` and `fetchLatestSession(for:)` to allow other services to aggregate progress.
    - **Multi-Session Support**: Verified that UUID-based session identity allows multiple workouts on the same day without conflicts.
    - **Storage Atomicity**: Ensured `WorkoutManager` only saves when explicitly completed, and correctly discards cancelled sessions.
    - **Architecture**: Opened up `WorkoutManager.modelContext` to internal access for modular query extensions.

## Architecture Decisions
- **Services vs. Managers**: Services now handle domain/business rules, while Managers (Camera, Vision, Haptics) handle infrastructure.
- **Environment Injection**: Preferred environment-based service instances over raw singletons to improve testability and follow modern SwiftUI patterns.
- **Observability**: Used the `Observation` framework for clean, reactive UI updates from background services.

## Next Steps (Sprint 2)
- [ ] **Streak Validation**: Implement daily check logic in `StreakManager` to handle missed days and freezes.
- [ ] **Performance Analytics**: Implement cycle-based progression in `ProgressManager`.
- [ ] **Dynamic Home State**: Connect the Home screen's streak and ritual dots to real SwiftData summaries instead of mocks.
