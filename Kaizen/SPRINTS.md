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
