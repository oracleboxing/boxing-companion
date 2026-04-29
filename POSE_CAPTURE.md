# Pose Capture Animation Pipeline

## Decision

The strongest long-term Action Man direction is to derive animation data from real Oracle Boxing movement, especially Ollie demonstrating punches, stance, warm-ups, and combinations.

Use video capture plus 33-point human pose tracking to turn real boxing movement into lightweight Action Man keyframes.

This keeps the character programmable while making the movement feel Oracle-authored instead of guessed.

## Why this matters

The USP is not just “animated boxer on screen”.

The USP is:

> Boxing Companion shows a stylised visual coach moving with the rhythm and intent of the exact workout block, based on real Oracle Boxing movement.

That means a jab should not be random arm extension. It should carry the timing, shoulder path, guard recovery, and stance rhythm of an actual Oracle Boxing demonstration.

## Source technology

Use a 33-landmark human pose model such as Google MediaPipe Pose / BlazePose.

The model detects body landmarks per video frame, including:

- shoulders
- elbows
- wrists
- hips
- knees
- ankles
- feet
- head/face reference points

The raw landmarks become a motion source. They are not used directly in the app UI without cleanup.

## Pipeline

```text
Ollie demo video
  -> extract 33 body landmarks per frame
  -> smooth jitter
  -> normalize body scale and position
  -> map landmarks to Action Man joints
  -> simplify/keyframe important poses
  -> export Action Man animation JSON/Swift data
  -> app plays animation by animation_id
```

## Recording standard

Bad footage creates bad animation. Use a simple capture standard.

Recommended setup:

- full body visible at all times
- camera locked off, no handheld movement
- 45-degree front angle for boxing punches and combos
- side angle only when specifically needed
- camera around chest height
- good lighting
- plain background where possible
- enough space around hands and feet
- record orthodox first, mirror later for southpaw

Each clip should contain one clean movement or combo:

- guard stance
- jab
- cross
- jab-cross
- jab-cross-slip-cross
- jab-cross-pullback-cross
- knee raises
- squat and open
- forward lunge

## Normalization

Raw landmark coordinates should be normalized before being stored as animation data.

Normalize by:

- centering around pelvis or midpoint between hips
- scaling by shoulder width, hip width, or torso length
- converting from pixel coordinates to relative coordinates
- smoothing jitter with a light moving average or low-pass filter
- trimming dead frames before and after the movement
- resampling to a consistent frame rate or keyframe interval

The goal is not to reproduce every camera pixel. The goal is to capture clean rhythm and believable technique.

## Mapping MediaPipe landmarks to Action Man

Action Man currently uses a smaller app-specific joint model.

Suggested mapping:

```text
MediaPipe nose/ear midpoint      -> ActionMan head
shoulder midpoint                -> neck/chest reference
left shoulder                    -> leftShoulder
right shoulder                   -> rightShoulder
left elbow                       -> leftElbow
right elbow                      -> rightElbow
left wrist                       -> leftGlove
right wrist                      -> rightGlove
hip midpoint                     -> pelvis
left hip                         -> leftHip
right hip                        -> rightHip
left knee                        -> leftKnee
right knee                       -> rightKnee
left ankle/foot blend            -> leftFoot
right ankle/foot blend           -> rightFoot
```

Gloves can be visually exaggerated from wrist points so punches read clearly at phone size.

## Data output

The output should match the app’s animation model.

Example shape:

```json
{
  "id": "jab",
  "duration": 0.62,
  "loops": true,
  "source": "ollie_jab_45deg_v1",
  "keyframes": [
    {
      "time": 0.0,
      "pose": {
        "head": [0.50, 0.13],
        "neck": [0.50, 0.25],
        "leftShoulder": [0.42, 0.30]
      }
    }
  ]
}
```

The app can store these as:

- Swift constants first, easiest for MVP
- bundled JSON later
- Supabase-backed animation scripts later if we want remote tuning

## What belongs where

### Supabase

Supabase should store which animation plays:

```text
workout_templates.blocks_json[].animation_id
moves.animation_key
exercises.structure_json.animation_id
future: combinations.animation_script_id
future: workout_items.override_animation_id
```

### App bundle

The iOS app should store how the animation moves:

```text
ActionManAnimationLibrary.swift
or bundled ActionManAnimations.json
```

### Capture workspace

Raw videos, extracted landmarks, smoothing experiments, and generated keyframes should live outside the iOS app target until curated.

Possible future folder:

```text
tools/pose-capture/
  input-videos/
  extracted-landmarks/
  generated-animations/
  scripts/
```

Do not bundle raw capture videos into the app.

## Formula vs data

A punch can be described mathematically, but the better product path is captured motion plus cleanup.

Useful formula concepts:

- elbow extension curve
- wrist path over time
- shoulder protraction
- chest/hip rotation
- guard recovery path
- stance/weight shift
- timing beats

But the final animation should be driven by keyframes derived from real movement, not a single hardcoded equation for “jab”.

## MVP implementation path

1. Keep current hand-authored SwiftUI Action Man animations as the placeholder.
2. Build a small offline pose-capture script to process one video.
3. Start with one movement: Ollie jab from a 45-degree angle.
4. Export normalized Action Man keyframes.
5. Replace the hand-authored `jab` animation with captured data.
6. Repeat for cross, jab-cross, knee raises, and one combo.

## Quality bar

A captured Action Man animation is good when:

- the movement reads clearly at phone size
- the rhythm matches a real boxing demo
- the guard recovery is visible
- the feet and hips do not jitter distractingly
- it looks like a training guide, not motion-capture spaghetti

## Risks

- Poor camera angle can make punches look wrong.
- Landmarks can jitter during fast punches.
- Wrist tracking can fail when gloves/hands overlap the body.
- Overfitting to one camera angle may make the character look odd in a stylised 2D renderer.

Mitigation:

- standardise filming
- smooth aggressively but not enough to kill snap
- manually edit keyframes after extraction
- treat captured data as source material, not untouchable truth

## Recommendation

Use this as the future Action Man animation authoring pipeline.

Do not block the current app on it. The current SwiftUI animation library should stay as the working MVP layer while pose capture becomes the path to high-quality Oracle-authored movement.
