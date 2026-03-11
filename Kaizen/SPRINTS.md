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

*(Add future issues here as they are assigned)*

## Sprint 1: Front-End Foundation (UI Mocks & Navigation)
*Objective: Build out the entire UI shell of Kaizen with fluid navigation between major screens fed by mock data.*

### Issue 1: Root Navigation Shell (Refined Interactivity)
**Status:** ✅ Completed
**Description:** Refine the dashboard with a central KAIZEN brand, a red-accented streak indicator, and 8 individually interactive/draggable red hearts. The weekday label on the right will trigger the calendar panel.

**Work Accomplished:**
- Centered the "KAIZEN" brand at the top of the HomeView.
- Implemented the streak counter on the left with a Red Dot indicator.
- Created 8 individually interactive/draggable red hearts for the freeze row.
- Made the weekday label on the right clickable to open the Calendar history panel.
- Verified build and navigation functionality.
### Issue 3: Monthly Sword Progression & Freeze Logic
**Status:** ✅ Completed
**Description:** Define monthly sword tiers, freeze mechanics, and demotion penalties to enforce consistency.

**Work Accomplished:**
- Defined `SwordTier` enum (Wooden, Steel, Gold, Shadow).
- Implemented `UserProgression` SwiftData model for persistence of tier and freeze state.
- Built `ProgressionManager` to handle daily checks, freeze consumption, and tier advancement/demotion.
- Integrated progression stats into the `ContentView` UI.
- Hooked up `HapticManager` for feedback on freeze consumption and tier unlocks.

### Issue 2: Design System (Minimalist Aesthetic)
**Status:** ✅ Completed
**Description:** Define the visual language of the Kaizen app with muted tones, typography, spacing grids, and haptic feedback.

**Work Accomplished:**
- Created `.colorset` configurations with programmatic variants for dark/light mode contrast mapping.
- Added `Color+Theme` and `Font+Theme` to standardize the UI style layer (SF Pro Rounded).
- Wrote `UIConstants.swift` for 8pt layout rhythm constants.
- Added `HapticManager` for Core Haptics mappings.
- Re-wrote `ContentView` and added `KaizenHeader` to demo the new aesthetic.
