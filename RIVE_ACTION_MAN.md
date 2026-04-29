# Rive Action Man

## Decision

Action Man should become a polished Rive-powered animated character, not a homemade SwiftUI stickman.

The current SwiftUI pose/keyframe system is useful as a prototype and fallback, but it is not the final USP-level visual direction.

## Product goal

Action Man should be one of the reasons people open Boxing Companion and think:

> This is what a boxing workout app should be.

He should feel like a lightweight visual training partner:

- shows the rhythm and intent of the current workout block
- demonstrates warm-ups clearly
- makes combos feel alive
- changes when the workout block changes
- stays premium and serious, not childish mascot energy

## Why Rive

Rive is the better fit for the real product version because it supports:

- proper vector character rigging
- smoother movement than hand-drawn SwiftUI joint lines
- state machines for workout-block-driven animation
- lightweight app-bundled assets
- programmatic animation switching from Swift
- future art direction upgrades without rewriting workout logic

## What stays from the current system

Keep:

- `animation_id` on workout blocks
- Supabase-driven mapping from workout content to animation IDs
- `ActionManView` as the public interface
- fallback animation behaviour
- the idea that the runner does not know how to animate a jab

Replace:

- final visual renderer
- hand-coded stickman as the main product UI

The architecture is still correct. The renderer was the weak bit.

## Target module shape

```text
Boxing Companion/ActionMan/
  ActionManView.swift                 # public wrapper used by WorkoutSessionView
  ActionManAnimationMapper.swift       # maps WorkoutSessionBlock -> animation id
  RiveActionManView.swift              # primary renderer once Rive runtime + asset are added
  SwiftUIActionManFallbackView.swift   # current math puppet fallback/reference
  ActionManAsset.md                    # notes for required Rive file/state machine
```

The public interface should remain:

```swift
struct ActionManView: View {
    let animationID: String?
    let isPlaying: Bool
    var lineColor: Color = .primary
}
```

Internally, `ActionManView` should prefer Rive when available and fall back to SwiftUI if the Rive asset/runtime is missing.

## Rive asset requirements

Create one bundled Rive file:

```text
ActionMan.riv
```

Recommended art direction:

- stylised 2D boxer
- premium, minimal, not cartoonish
- readable silhouette
- boxing gloves
- simple head/face, no uncanny detail
- clear shoulders, hips, knees, feet
- works on light and dark backgrounds
- classy colour palette: black/charcoal body, warm gold or red glove/wrap accent

Avoid:

- goofy mascot proportions
- aggressive comic-book style
- overly realistic human anatomy
- huge video-game character design
- cluttered details that disappear at phone size

## Rive state machine

Recommended state machine name:

```text
WorkoutState
```

Recommended input:

```text
animation_id: string-like/state selector
is_playing: boolean
```

Rive state machines do not always expose string inputs cleanly, so the implementation may use numbered animation codes instead.

If using numeric codes:

```text
animation_code: number
is_playing: boolean
```

App-side mapping:

```swift
guard_bounce = 0
rest_bounce = 1
jab = 2
cross = 3
jab_cross = 4
alternating_knee_raises = 5
step_over_the_gate = 6
standing_torso_twists = 7
squat_and_open = 8
alternating_forward_lunges = 9
jab_cross_slip_cross = 10
jab_cross_pullback_cross = 11
move_after_punching = 12
```

## Initial Rive animations needed

For Workout Alpha:

1. `guard_bounce`
2. `rest_bounce`
3. `alternating_knee_raises`
4. `step_over_the_gate`
5. `standing_torso_twists`
6. `squat_and_open`
7. `alternating_forward_lunges`
8. `jab`
9. `cross`
10. `jab_cross`
11. `jab_cross_slip_cross`
12. `jab_cross_pullback_cross`
13. `move_after_punching`

## Swift integration path

### 1. Add Rive runtime

Use Swift Package Manager in Xcode:

```text
https://github.com/rive-app/rive-ios
```

Add the Rive runtime product to the Boxing Companion app target.

Do this in Xcode first rather than hand-editing `project.pbxproj` from Linux.

### 2. Add `ActionMan.riv`

Place the bundled asset somewhere like:

```text
Boxing Companion/ActionMan/Assets/ActionMan.riv
```

Ensure it is included in the app target resources.

### 3. Replace public renderer internals

`WorkoutSessionView` should continue to use:

```swift
ActionManView(
    animationID: engine.currentAnimationID,
    isPlaying: engine.isRunning,
    lineColor: primaryTextColor
)
```

No workout-session code should import Rive directly.

### 4. Keep SwiftUI fallback

Until the Rive asset is complete, keep the SwiftUI pose renderer as fallback/reference. This lets the app still run while the proper character is being designed.

## Supabase model

Current working model:

```text
workout_templates.blocks_json[].animation_id
moves.animation_key
exercises.structure_json.animation_id
```

Future model:

```text
moves.animation_id
exercises.animation_id
combinations.animation_script_id
workout_items.override_animation_id
```

Supabase says what animation should play. Rive/Swift says how it looks.

## Implementation warning

Do not try to generate the `.riv` file in Swift code. Rive is an art/animation asset pipeline.

The right workflow is:

1. design character style
2. create/rig in Rive editor
3. export `.riv`
4. bundle in app
5. switch states from Swift using the current workout block animation ID

## Product note

This should be treated as a product pillar, not decoration.

The fallback stickman can prove state mapping. The Rive character is what makes the feature feel premium.
