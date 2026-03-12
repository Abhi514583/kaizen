# Sprint 1 Bugs Reported and Fixes

Date: 2026-03-11
Scope: Verification done from current code in this repo.

## Sprint 1: Verified Fixed

1. Duplicate profile creation risk
- Status: Fixed
- Verification:
  - [HomeView.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Views/Screens/HomeView.swift:291) now uses `FetchDescriptor<UserProfile>()` + `fetchCount` before insert.
  - Insert only proceeds when `existingCount == 0 && profiles.isEmpty`.
- Fix implemented:
  - Defensive singleton-style check before creating `UserProfile` and `SwordProgress`.

2. Progress card crash when baseline is 0
- Status: Fixed
- Verification:
  - [ProgressCard.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Views/Components/ProgressCard.swift:37) now guards baseline:
    - `baseline > 0 ? ... : 0`
- Fix implemented:
  - Safe zero-baseline fallback to `0%` improvement.

3. Calendar marks today as future/inactive
- Status: Fixed
- Verification:
  - [CalendarView.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Views/Screens/CalendarView.swift:39) now sets today (`i == 0`) to `.inProgress`.
- Fix implemented:
  - Today is now active/selectable in mock history flow.

4. Workout flow always reports 0 reps
- Status: Fixed (for mock/manual flow)
- Verification:
  - [WorkoutView.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Views/Screens/WorkoutView.swift:61) adds tap-to-increment on the rep count text.
  - Session completion still passes `currentReps` to route.
- Fix implemented:
  - Manual tap increments reps, enabling end-to-end session-complete test flow.

## Sprint 2: Bugs Reported and Pending Fixes

1. Progression rules incomplete (freeze/missed-day/demotion not active)
- Status: Not fixed
- Evidence:
  - [ProgressionManager.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Managers/ProgressionManager.swift:16) notes simplified logic.
  - [ProgressionManager.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Managers/ProgressionManager.swift:56) `handleDemotion` exists but is not used.
- Sprint 2 fix target:
  - Implement real last-workout/day-state tracking and call freeze/demotion logic.

2. Vision orientation hardcoded to `.up`
- Status: Not fixed
- Evidence:
  - [VisionManager.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Managers/VisionManager.swift:21) uses fixed orientation.
- Sprint 2 fix target:
  - Map `AVCaptureConnection`/device orientation to Vision orientation for reliable pose detection.

3. Camera setup can be re-run without explicit idempotent guard
- Status: Not fixed
- Evidence:
  - [CameraManager.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Managers/CameraManager.swift:26) can call `setupCamera()` repeatedly.
  - [CameraManager.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Managers/CameraManager.swift:52) no explicit `isConfigured` guard.
- Sprint 2 fix target:
  - Add one-time configuration guard and/or clear/rebuild inputs/outputs safely.

4. Gesture conflict risk from global swipe-back drag
- Status: Not fixed
- Evidence:
  - [View+Extensions.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/Kaizen/Views/DesignSystem/View+Extensions.swift:9) applies broad `DragGesture`.
- Sprint 2 fix target:
  - Restrict to edge-swipe region or resolve with high-priority gesture strategy per screen.

5. Test coverage is still minimal
- Status: Not fixed
- Evidence:
  - [KaizenTests.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/KaizenTests/KaizenTests.swift:13) placeholder test only.
  - [KaizenUITests.swift](/Users/abhishekthakur/Dev_2/Kaizen/Kaizen/KaizenUITests/KaizenUITests.swift:26) launch-only template.
- Sprint 2 fix target:
  - Add model and flow tests for profile creation, progression, and workout completion.

## Note on Build Verification

I could not independently confirm your "build verified" statement in this environment because command-line build is blocked by local signing/provisioning configuration (`com.abhishekios.Kaizen` profile mismatch). The code-level checks above are verified from source.
