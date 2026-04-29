# Action Man Animation System

## Status

This document describes the current SwiftUI pose/keyframe Action Man character. It has been upgraded from a line stickman into a simple filled boxer with gloves, limbs, torso, head, shoes, and shadows. This is the active renderer direction for now.

## Goal

Make the simple animated boxer perform the combos and exercises that appear in the active workout.

This should stay lightweight for the MVP. The figure is there to guide rhythm and intent, not to become a full biomechanics simulator.

The action man should answer:

> What should I be doing right now?

It does not need to answer every detail of:

> How do I perfect this technique?

## Current starting point

The app currently has a fixed placeholder stick figure inside the workout session UI.

Current rough shape:

```text
WorkoutSessionView
  -> StandingBoxerPlaceholder
```

That placeholder hardcodes the body as:

- head circle
- torso line
- left/right arm lines
- left/right leg lines

This is fine as a placeholder, but it cannot perform movements because there is no model for joints, poses, or animation timing.

## Recommended MVP approach

Build a small pose-based stick-figure animation system in SwiftUI.

Core idea:

```text
Workout block
  -> movement id or combo id
  -> animation script
  -> timed poses
  -> rendered stick figure
```

Example:

```text
jab_cross
  -> guard pose
  -> jab extension
  -> guard pose
  -> cross extension
  -> guard pose
```

This keeps the interface narrow. The workout runner does not need to know how to draw a jab. It only asks the animation module to play the animation for the current block.

## Module boundary

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
    let elapsedSecondsInBlock: TimeInterval
    let isPlaying: Bool
}
```

## Pose model

Use joint points rather than fixed lines.

Start with elbows and knees from day one. Without elbows and knees, punches look like stiff spaghetti and warm-ups/lunges become awkward.

Recommended MVP pose:

```swift
struct ActionManPose: Equatable {
    var head: CGPoint
    var neck: CGPoint
    var pelvis: CGPoint

    var leftShoulder: CGPoint
    var rightShoulder: CGPoint
    var leftElbow: CGPoint
    var rightElbow: CGPoint
    var leftHand: CGPoint
    var rightHand: CGPoint

    var leftKnee: CGPoint
    var rightKnee: CGPoint
    var leftFoot: CGPoint
    var rightFoot: CGPoint
}
```

The renderer draws:

- head
- neck to pelvis
- neck/shoulders to elbows to hands
- pelvis to knees to feet

Keep the figure one-colour and readable. Silhouette matters more than anatomical accuracy.

## Animation model

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

## Example animation scripts

### Guard Bounce

Use for prep, generic skill blocks, and fallback blocks.

```text
0.00s guard high
0.25s guard low by a few points
0.50s guard high
loop
```

### Rest Bounce

Use for recovery/rest blocks.

```text
0.00s relaxed stance
0.35s small bounce / shoulders lower
0.70s relaxed stance
loop
```

### Jab

```text
0.00s guard
0.12s lead hand halfway out
0.22s lead hand fully extended
0.35s guard
```

### Cross

```text
0.00s guard
0.12s rear shoulder rotates forward
0.24s rear hand fully extended
0.40s guard
```

### Jab Cross

Composition:

```text
jab
small guard beat
cross
guard beat
loop
```

### Alternating Knee Raises

```text
0.00s standing
0.35s left knee up
0.70s standing
1.05s right knee up
1.40s standing
loop
```

This is why knees should exist in the first pose model.

## Connecting workouts to animations

Short term, map by block title/type:

```swift
func animationID(for block: WorkoutBlock) -> String {
    switch block.title.lowercased() {
    case "alternating knee raises":
        return "alternating_knee_raises"
    case "jab cross", "round 2: jab cross basics":
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

Best long-term model:

```text
moves.animation_id
exercises.animation_id
combinations.animation_script_id
workout_items.override_animation_id
```

That lets one canonical jab animation power many workouts.

## Composition model for combinations

Eventually, combinations should be represented as a sequence of movement animation IDs:

```text
jab_cross_hook
  -> jab
  -> cross
  -> lead_hook
```

This makes combinations reusable scripts rather than bespoke animations.

## Options considered

### Option 1: SwiftUI Pose Renderer

Best fit for the MVP.

Pros:

- native Swift
- no external asset pipeline
- easy to keep the current simple stick-figure style
- animation behaviour can be tested as data
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

### Option 3: Lottie/Rive-style external animation tools

Good if a designer creates polished vector animations.

Pros:

- polished animation tooling
- easier for designer-authored movement
- less custom interpolation code

Cons:

- introduces asset pipeline and dependency decisions
- harder to generate combinations programmatically
- each combo/exercise may need separate authored assets

Recommendation: parked for now. Do not add an external animation runtime unless Jordan explicitly reopens it.

### Option 4: Video/GIF clips

Good for human demonstrations, not for the little action man.

Pros:

- realistic
- easy for users to understand

Cons:

- heavy assets
- not composable
- does not match the current minimal stick figure

Recommendation: use later for demo/instruction content, not for the animated stick figure.

## Recommended build path

### Step 1: Replace fixed shape with pose renderer

Create `ActionManPose` and draw the standing/guard pose using joint points.

Result: visually similar to today, but movable.

### Step 2: Add a tiny animation library

Add:

- `standing`
- `guard_bounce`
- `rest_bounce`
- `alternating_knee_raises`
- `jab`
- `cross`
- `jab_cross`

Result: the runner can play real movement loops.

### Step 3: Connect current block to animation

Expose the active block from `WorkoutSessionEngine`, then map it to an animation ID.

Result: when the block changes, the action man changes movement.

### Step 4: Add Supabase animation IDs

Add `animation_id` to canonical moves/exercises/combinations once local mapping proves useful.

Result: workout content controls the animation without hardcoded title matching.

### Step 5: Add combination composition

Represent combinations as reusable movement animation sequences.

Result: combos become composable rather than one-off animations.

## Product guidance

Keep the visual language simple:

- stylised filled character, not bare skeleton lines
- gloves, shoes, torso, head, and readable limb shapes
- smooth but minimal movement
- readable silhouettes
- no detailed anatomy yet
- no attempt to replace real coaching demos

The action man is a rhythm and intent guide. It gives the workout runner personality and makes it feel like a real app, without pretending to be a full technique coach.

## Testing guidance

Useful early tests:

- pose interpolation returns first pose at start time
- pose interpolation returns last pose at end time
- looping animation wraps elapsed time correctly
- unknown animation ID falls back to `guard_bounce`
- recovery block maps to `rest_bounce`
- Jab Cross block maps to `jab_cross`

Do not snapshot-test the exact visual shape yet. It will change while the figure gets tuned.
