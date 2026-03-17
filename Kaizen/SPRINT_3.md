# Sprint 3: Real-Time Pose Detection & Camera Intelligence

> **Theme:** Replace manual input with Apple Vision-powered biomechanical tracking. Every rep must be earned.

---

## Sprint Goals

| Goal | Status |
|------|--------|
| Real-time body pose detection via `VNDetectHumanBodyPoseRequest` | 🔲 |
| Side-view camera with ultra-wide / back camera lock | 🔲 |
| Guided positioning screen (green ✅ when aligned) | 🔲 |
| Pushup rep counting with strict form gates | 🔲 |
| Squat rep counting with depth and alignment gates | 🔲 |
| Plank hold timer with alignment monitor & break-stop logic | 🔲 |
| 10-second pause buffer before session auto-end | 🔲 |
| Manual fallback mode remains available | 🔲 |
| Skeleton overlay on camera feed (real-time joint dots) | 🔲 |

---

## Issue 1: Camera & Pose Detection Integration

**Title:** [Sprint 3] Implement Real-Time Pose Detection for Exercises

### Description
Replace manual input with real-time body tracking using Apple Vision. System detects and counts pushups, squats, and plank duration using joint positions from the **side view** (phone placed landscape on floor or propped at hip height).

### Camera Setup
- Switch `CameraManager` from front camera → **back ultra-wide camera** (`builtInUltraWideCamera` or fallback to `builtInWideAngleCamera`, position `.back`)
- Target resolution: `AVCaptureSession.Preset.hd1920x1080`
- Frame orientation: `.right` (landscape)
- Vision `VNDetectHumanBodyPoseRequest` runs on every frame at confidence threshold `≥ 0.5`

### Guided Positioning Screen
Before each exercise starts, a full-screen camera preview shows the user. The system evaluates:

**READY state (green ✅):**
- At least 8 of the key body joints are visible with confidence ≥ 0.6
- Body is oriented laterally (side-view): the horizontal distance between `leftShoulder` and `rightShoulder` is **less than 15% of frame width** (they overlap in side view)
- Body fills between 30%–85% of frame height (correct distance check)

**NOT READY (red ❌) states:**
- `outOfFrame` – fewer than 5 joints detected
- `lowConfidence` – joints detected but confidence < 0.6
- `badAngle` – shoulder spread > 20% of frame width (facing camera, not side-on)
- `tooClose` / `tooFar` – body < 30% or > 90% frame height

User sees a real-time instruction card: e.g., **"TURN SIDEWAYS"**, **"STEP BACK"**, **"RAISE PHONE"**, etc.

Once the READY state holds for **2 consecutive seconds**, a countdown (3-2-1-GO) begins, then tracking starts automatically.

---

## Issue 2: Pushup Detection Algorithm

**Title:** [Sprint 3] Strict Form Pushup Rep Counter

### Algorithm

**Key joints sourced (side view):**
- `leftShoulder` / `rightShoulder` → pick the visible one
- `leftElbow` / `rightElbow`
- `leftWrist` / `rightWrist`
- `leftHip` / `rightHip`
- `leftAnkle` / `rightAnkle`

**Elbow Angle Calculation:**
```
elbowAngle = angle(shoulder → elbow → wrist)
```
- **UP position:** elbow angle ≥ 155° (arms nearly straight)
- **DOWN position:** elbow angle ≤ 90° (chest near floor)
- A valid rep = DOWN → UP transition

**Form Gates (all must pass, 5-10% tolerance):**
1. **Core Gate:** Hip–shoulder–ankle must be within `±12°` of a straight line. If the user sags their hips or pikes their butt, no rep is counted.
2. **Arm Path Gate:** Wrist must stay within `±15% frame height` of its start horizontal position. Users cannot fake reps by flopping their arms.
3. **Full Range Gate:** Must reach both extremes (< 90° AND > 155°) within a single rep cycle.
4. **Speed Gate:** Each rep must take ≥ 0.5 seconds total (prevents spammy micro-movements).

**Rep State Machine:**
```
.idle → .goingDown (angle crosses 100°) → .atBottom (angle ≤ 90°) → .goingUp → .atTop (angle ≥ 155°, form passed) → count += 1 → .goingDown
```

---

## Issue 3: Squat Detection Algorithm

**Title:** [Sprint 3] Strict Form Squat Rep Counter

### Algorithm

**Key joints (side view):**
- `leftHip` / `rightHip`
- `leftKnee` / `rightKnee`
- `leftAnkle` / `rightAnkle`
- `leftShoulder` / `rightShoulder`

**Hip-Knee Angle Calculation:**
```
kneeAngle = angle(hip → knee → ankle)
```
- **UP / Standing:** knee angle ≥ 160°
- **DOWN / Parallel:** knee angle ≤ 95° (thighs parallel to floor = proper depth)
- A valid rep = DOWN → UP transition

**Form Gates:**
1. **Depth Gate:** Must reach knee angle ≤ 95° (no shallow squats).
2. **Torso Upright Gate:** Shoulder–hip–knee vertical alignment: torso angle from vertical must be ≤ 35° (prevents excessive forward lean).
3. **Knee Track Gate:** Knee horizontal position must not drift backward past ankle by more than 20% of leg length (prevents leaning back).
4. **Speed Gate:** Rep must take ≥ 0.6 seconds.

**Rep State Machine:**
```
.idle → .goingDown (angle < 130°) → .atBottom (angle ≤ 95°) → .goingUp → .atTop (angle ≥ 160°, form passed) → count += 1 → .goingDown
```

---

## Issue 4: Plank Hold Detection Algorithm

**Title:** [Sprint 3] Plank Alignment Monitor with Auto-Stop

### Algorithm

**Key joints (side view):**
- `leftShoulder` / `rightShoulder`
- `leftHip` / `rightHip`
- `leftAnkle` / `rightAnkle`

**Alignment Score:**
The shoulder–hip–ankle angle must remain within `165°–180°` (straight line, ±10% / ~15° tolerance).

```
plankLineDeviation = |180° - angle(shoulder → hip → ankle)|
```
- **GOOD alignment:** deviation ≤ 15° → timer runs
- **BREAK alignment:** deviation > 15° → timer pauses immediately

**Break Logic:**
- When alignment breaks, a `10-second grace timer` starts.
- If user restores alignment within 10 seconds → timer resumes, no penalty.
- If break persists > 10 seconds → **session ends automatically**, result saved as max duration held.

**Progressive Feedback:**
- 0–5 sec break: Yellow warning overlay "HOLD THE LINE"
- 5–10 sec break: Red overlay "⚠️ BREAKING FORM – 5s TO END"
- > 10 sec: Auto-complete saves the held duration.

---

## Issue 5: Skeleton Overlay UI

**Title:** [Sprint 3] Real-time Joint Skeleton Overlay on Camera Feed

### Description
Render a live skeleton overlay on top of the camera preview. Use SwiftUI `Canvas` drawing over a `VideoPreviewLayerView`.

**Joints to draw:**
- Dots at each detected joint (confidence ≥ 0.5)
- Lines connecting: shoulder→elbow→wrist, hip→knee→ankle, shoulder→hip

**Color coding:**
- Form GOOD → `.kaizenSage` (green)
- Form WARNING → `.orange`
- Form BREAK → `.red`
- Tracking lost → `.clear` (hide overlay)

**Performance:** Maximum 30 fps Vision processing. Drop frames if Vision queue is busy.

---

## Issue 6: 10-Second Pause Buffer (Reps)

**Title:** [Sprint 3] Session Auto-End on Inactivity

### Description
For pushups and squats, if the user stops performing reps for more than **10 seconds** (no angle state change), a visible countdown appears.

**Logic:**
- `lastRepTimestamp` updated on each confirmed rep
- If `Date.now - lastRepTimestamp > 10.0s` → show "SESSION ENDING IN Xs" overlay
- At 10s: `workoutManager.completeWorkout()` fires automatically, saving the final rep count

**Grace period restart:**
- If the user resumes (any joint angle changes back toward DOWN state), countdown cancels.

---

## Issue 7: Pose-Aware `WorkoutSetupView`

**Title:** [Sprint 3] Guided Positioning Screen Before Each Workout

### Description
Replace the static `WorkoutSetupView` with a full-screen camera preview. The system:
1. Shows the live camera with skeleton overlay
2. Shows a positioning guide card (e.g., "Place phone 6 feet away, at hip height, pointed sideways")
3. Validates the READY state
4. Starts countdown automatically once READY

---

## Acceptance Criteria Summary

| Criterion | Covered By |
|-----------|-----------|
| `VisionManager` uses `VNDetectHumanBodyPoseRequest` | Issue 1 |
| `CameraManager` streams frames from back/wide camera | Issue 1 |
| Guided positioning → green ✅ READY state | Issue 7 |
| Rep counting via elbow angle (pushups) | Issue 2 |
| Rep counting via knee angle (squats) | Issue 3 |
| Plank timer runs only with good alignment | Issue 4 |
| 5–10% form error tolerance for each exercise | Issues 2, 3, 4 |
| 10-second pause before session auto-end | Issue 6 |
| Skeleton overlay on camera | Issue 5 |
| Manual fallback remains available | Issue 1 |

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Body Pose | `Vision.VNDetectHumanBodyPoseRequest` |
| Camera | `AVFoundation.AVCaptureSession` (back ultra-wide) |
| Overlay | SwiftUI `Canvas` + `VideoPreviewLayerView` (UIViewRepresentable) |
| Angle Math | Pure geometry: `atan2` for 2D joint angles |
| Concurrency | Vision runs on `DispatchQueue(label: "com.kaizen.videoQueue")`, publishes to `@MainActor` |

---

## File Change Map

| File | Action |
|------|--------|
| `Managers/CameraManager.swift` | Modify — switch to back ultra-wide, add session preset |
| `Managers/VisionManager.swift` | Rewrite — add full exercise detection state machines |
| `Services/Workout/WorkoutManager.swift` | Modify — add `onRepDetected()`, `onPlankAlignmentChange()` hooks |
| `Views/Screens/WorkoutSetupView.swift` | Rewrite — guided positioning screen with live camera |
| `Views/Screens/WorkoutView.swift` | Modify — add skeleton overlay, 10s countdown, live feedback |
| `Views/Components/CameraPreviewView.swift` | New — `UIViewRepresentable` for `AVCaptureVideoPreviewLayer` |
| `Views/Components/SkeletonOverlayView.swift` | New — Canvas-based joint drawing |
| `Views/Components/AlignmentGuideCard.swift` | New — positioning instruction popup |
