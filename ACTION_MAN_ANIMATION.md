# Action Man Animation Investigation

## Goal

Make the simple stick-figure boxer perform the combos and exercises that appear in the active workout.

This should stay lightweight for the MVP. The figure is there to guide rhythm and intent, not to become a full biomechanics simulator.

## Current Starting Point

The app currently draws the boxer as a fixed SwiftUI `Shape` inside `WorkoutSessionView`:

```text
WorkoutSessionView
  -> StandingBoxerPlaceholder
```

That shape hardcodes the body as:

- head circle
- torso line
- left/right arm lines
- left/right leg lines

This is good for a placeholder, but it cannot perform movements because there is no model for joints, poses, or animation timing.

## Recommended MVP Approach

Build a small pose-based stick-figure animation system in SwiftUI.

The core idea:

```text
Workout block
  -> movement id or combo id
    -> animation script
      -> timed poses
        -> rendered stick figure
```

Example:

```text
"jab_cross"
  -> guard pose
  -> jab extension
  -> guard pose
  -> cross extension
  -> guard pose
```

This keeps the interface narrow. The runner does not need to know how to draw a jab. It only asks the animation module to play the animation for the current block.

## Module Boundary

Suggested module:

```text
Boxing Companion/ActionMan/
  ActionManView.swift
  ActionManPose.swift
  ActionManAnimation.swift
  ActionManAnimationLibrary.swift
  ActionManRenderer.swift
```

Responsibilities:

- define stick-figure joints
- define named poses
- interpolate between poses
- define movement/combo animation scripts
- render the current pose

Non-responsibilities:

- workout fetching
- timer state
- Supabase DTO decoding
- progress persistence
- auth

The public interface should stay small:

```swift
struct ActionManView: View {
    let animationID: String?
    let isPlaying: Bool
}
```

Later, the input can become richer:

```swift
struct ActionManPlayback {
    let animationID: String
    let elapsedSecondsInBlock: Int
    let isPlaying: Bool
}
```

## Pose Model

The stick figure should be driven by joint points rather than fixed lines.

Possible joints:

```swift
struct ActionManPose: Equatable {
    var head: CGPoint
    var neck: CGPoint
    var pelvis: CGPoint
    var leftHand: CGPoint
    var rightHand: CGPoint
    var leftFoot: CGPoint
    var rightFoot: CGPoint
}
```

For the current visual style, this is enough. If the figure needs elbows and knees later:

```swift
var leftElbow: CGPoint
var rightElbow: CGPoint
var leftKnee: CGPoint
var rightKnee: CGPoint
```

The renderer draws lines between joints:

```text
head
neck -> pelvis
neck -> leftHand
neck -> rightHand
pelvis -> leftFoot
pelvis -> rightFoot
```

With elbows/knees:

```text
neck -> shoulder -> elbow -> hand
pelvis -> knee -> foot
```

## Animation Model

An animation is a list of timed poses:

```swift
struct ActionManAnimation {
    let id: String
    let duration: TimeInterval
    let loops: Bool
    let keyframes: [ActionManKeyframe]
}

struct ActionManKeyframe {
    let time: TimeInterval
    let pose: ActionManPose
}
```

The playback system finds the two keyframes around the current time and interpolates each joint.

This gives smooth motion without needing frame-by-frame assets.

## Example Animation Scripts

### Guard Bounce

Use for prep, rest, and generic blocks.

```text
0.0s guard high
0.25s guard low by a few points
0.5s guard high
```

Loop while the block is running.

### Jab

```text
0.0s guard
0.12s lead hand halfway out
0.22s lead hand fully extended
0.35s guard
```

### Cross

```text
0.0s guard
0.12s rear shoulder rotates forward
0.24s rear hand fully extended
0.40s guard
```

### Jab Cross

Composition:

```text
jab
guard beat
cross
guard beat
```

### Alternating Knee Raises

```text
0.0s standing
0.35s left knee up
0.7s standing
1.05s right knee up
1.4s standing
```

This is one reason elbows/knees may become useful soon.

## Connecting Workouts To Animations

Short term, map by block title/type:

```swift
func animationID(for block: WorkoutBlock) -> String {
    switch block.title.lowercased() {
    case "alternating knee raises":
        return "alternating_knee_raises"
    case "jab cross":
        return "jab_cross"
    default:
        return block.type == .recovery ? "rest_bounce" : "guard_bounce"
    }
}
```

Better medium-term model:

```swift
struct WorkoutBlock {
    let animationID: String?
}
```

Supabase can eventually store `animation_id` on exercises, moves, combinations, or workout items.

Best long-term model:

```text
moves.animation_id
exercises.animation_id
combinations.animation_script_id
workout_items.override_animation_id
```

That lets one canonical jab animation power many workouts.

## Options Considered

### Option 1: SwiftUI Pose Renderer

Best fit for the MVP.

Pros:

- native Swift
- no external asset pipeline
- easy to keep the current simple stick-figure style
- animation behavior can be tested as data
- works well with workout/combo IDs

Cons:

- complex movements require more pose authoring
- not realistic enough for detailed technique coaching

Recommendation: use this first.

### Option 2: SpriteKit

Good if the action figure becomes game-like.

Pros:

- built for animation loops
- good frame timing
- can support simple physics later

Cons:

- more engine weight than needed
- less natural inside the current SwiftUI layout
- still needs pose/art authoring

Recommendation: skip for now.

### Option 3: Lottie or Rive

Good if a designer creates polished vector animations.

Pros:

- polished animation tooling
- easier for designer-authored movement
- less custom interpolation code

Cons:

- introduces asset pipeline and dependency decisions
- harder to generate combinations programmatically
- each combo/exercise may need separate authored assets

Recommendation: consider later if the brand wants a more polished mascot.

### Option 4: Video/GIF Clips

Good for human demonstrations, not for the little action man.

Pros:

- realistic
- easy for users to understand

Cons:

- heavy assets
- not composable
- does not match the current minimal stick figure

Recommendation: use later for demo/instruction content, not for the animated stick figure.

## Recommended Build Path

### Step 1: Replace Fixed Shape With Pose Renderer

Create `ActionManPose` and draw the standing pose using joint points.

Result: visually identical to today, but now movable.

### Step 2: Add A Tiny Animation Library

Add:

- `standing`
- `guardBounce`
- `restBounce`
- `alternatingKneeRaises`
- `jab`
- `cross`
- `jabCross`

Result: the runner can play real movement loops.

### Step 3: Connect Current Block To Animation

Expose the active block from the session engine or snapshot, then map it to an animation ID.

Result: when the block changes, the action man changes movement.

### Step 4: Add Supabase Animation IDs

Add `animation_id` to canonical moves/exercises/combinations once the local mapping proves useful.

Result: workout content controls the animation without hardcoded title matching.

### Step 5: Add Combination Composition

Represent combinations as a sequence of movement animation IDs:

```text
jab_cross_hook
  -> jab
  -> cross
  -> lead_hook
```

Result: combinations become reusable scripts rather than bespoke animations.

## Product Guidance

Keep the visual language simple:

- one-color figure
- smooth but minimal movement
- readable silhouettes
- no detailed anatomy yet
- no attempt to replace real coaching demos

The action man should answer: "What should I be doing right now?"

It does not need to answer every detail of "How do I perfect this technique?"
