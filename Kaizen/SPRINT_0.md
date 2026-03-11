# Sprint 0: Foundation & Core

## Issue 1: Project Setup & Architecture
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

## Issue 2: Core Data Schema (SwiftData)
**Status:** ✅ Completed
**Description:** Set up the local, offline-first database using SwiftData. Define the exact data structures for UI, streak logic, and workout system persistence.

**Work Accomplished:**
- Formally created `UserProfile`, `SwordProgress`, `DailySummary`, and `ExerciseSession` SwiftData models.
- Hooked `ProgressionManager` to map the gamification loop directly to the new `UserProfile` schema.
- Added dummy `ExerciseSession` entries to `ContentView` to verify SwiftData `List` binding logic cleanly maps backwards through time based on `date`.
- Re-verified complete project compilation.

---

## Issue 3: Camera & Vision Strategy
**Status:** ✅ Completed
**Description:** Finalize the Camera & ML Tracking Architecture using AVFoundation and Vision frameworks.

**Work Accomplished:**
- Built `CameraManager.swift` to handle AVFoundation front-facing video streams.
- Built `VisionManager.swift` to digest video buffers via `VNDetectHumanBodyPoseRequest` for body joint extraction.
- Established `TrackingState.swift` to handle UI feedback strings across error scenarios (low lighting, out of frame).
- Injected `NSCameraUsageDescription` into the `project.pbxproj` file to satisfy iOS privacy requirements.
