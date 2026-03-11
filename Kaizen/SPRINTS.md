# Kaizen Sprints

## Sprint 0: Foundation & Core

### Issue 1: Project Setup & Architecture
**Status:** ✅ Completed
**Description:** Initialize the iOS project and establish the core application architecture (SwiftUI + MVVM + SwiftData).

**Work Accomplished:**
- Created base Xcode Project with SwiftUI and SwiftData.
- Established strict MVVM folder structure (`Views/`, `ViewModels/`, `Models/`, `Managers/`, `Services/`, `Assets/`).
- Migrated default `ContentView` and `Item` into the correct architectural folders.
- Implemented `NavigationStack` for phone-friendly root routing.
- Configured files for File System Synchronized Groups.
- Verified cleanly compiling build using `xcodebuild`.

---
### Issue 4: Core Data Schema (SwiftData)
**Status:** ✅ Completed
**Description:** Set up the local, offline-first database using SwiftData. Define the exact data structures for UI, streak logic, and workout system persistence.

**Work Accomplished:**
- Formally created `UserProfile`, `SwordProgress`, `DailySummary`, and `ExerciseSession` SwiftData models.
- Hooked `ProgressionManager` to map the gamification loop directly to the new `UserProfile` schema.
- Added dummy `ExerciseSession` entries to `ContentView` to verify SwiftData `List` binding logic cleanly maps backwards through time based on `date`.
- Re-verified complete project compilation.

---
### Issue 5: Camera & Vision Strategy
**Status:** ✅ Completed
**Description:** Finalize the Camera & ML Tracking Architecture using AVFoundation and Vision frameworks.

**Work Accomplished:**
- Built `CameraManager.swift` to handle AVFoundation front-facing video streams.
- Built `VisionManager.swift` to digest video buffers via `VNDetectHumanBodyPoseRequest` for body joint extraction.
- Established `TrackingState.swift` to handle UI feedback strings across error scenarios (low lighting, out of frame).
- Injected `NSCameraUsageDescription` into the `project.pbxproj` file to satisfy iOS privacy requirements.

### Issue 4: Sword Hero Card
**Status:** ✅ Completed
**Description:** Build the main sword display card and integrate it into the home screen layout.

**Work Accomplished:**
- Created the reusable `SwordHeroCard` component with tier and aura labels.
- Repositioned the hero element to the top area (below branding) to clean up the middle layout.
- Removed deprecated central aura elements.
- Verified build and aesthetic alignment.

## Sprint 1: Front-End Foundation (UI Mocks & Navigation)
*Objective: Build out the entire UI shell of Kaizen with fluid navigation between major screens fed by mock data.*

### Issue 1: Root Navigation Shell (Final Design Iteration)
**Status:** ✅ Completed
**Description:** Refine the dashboard with a central KAIZEN brand, a red-accented streak indicator, and 8 individually interactive/draggable red hearts. The weekday label on the right will trigger the calendar panel.

**Work Accomplished:**
- Centered the "KAIZEN" brand at the top of the HomeView.
- Implemented the streak counter on the left with a Red Dot indicator.
- Created 8 individually interactive/draggable red hearts for the freeze row.
- Made the weekday label on the right clickable to open the Calendar history panel.
- Verified build and navigation functionality.

### Issue 2: Home Screen Ritual Layout
**Status:** ✅ Completed
**Description:** Build out the "Ritual Layout" including Today's Target cards for each exercise and a refined Sword Hero section.

**Work Accomplished:**
- Implemented Today's Target cards for Pushups, Squats, and Plank.
- Enhanced the hero section with the Aura element and "Sword Energy" branding.
- Finalized header layout with Settings access and clickable calendar link.
- Verified build and aesthetic alignment.

### Issue 3: Mechanical Flip Clock Hero Component
**Status:** ✅ Completed
**Description:** Build the mechanical flip-clock inspired component for the home screen to reinforce the ritualistic daily feel.

**Work Accomplished:**
- Created the reusable `FlipClockHero` component with a mechanical aesthetic.
- Integrated the flip clock into the Home screen streak indicator.
- Added a subtle "DAY" contextual label above the clock for better UX.
- Implemented "DONE" visual states for exercise target cards.
- Verified build and visual consistency.
