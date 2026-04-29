# Roadmap

## Current priority

Build the Boxing Companion workout runner into something that feels like a native Oracle Boxing training product, not just a timer.

## Phase 1: Workout Alpha runner

Status: in progress.

Goals:

- load Workout Alpha from Supabase
- show current block and timer
- support start/stop, previous, next
- show Action Man animation for each block
- keep a safe offline/fallback workout path

## Phase 2: Action Man MVP

Status: in progress.

Goals:

- keep the SwiftUI Action Man renderer working
- make the character visually readable and premium enough for early testing
- support animation IDs for all Workout Alpha blocks
- keep `ActionManView` as the narrow public interface

Current animation IDs include:

- `guard_bounce`
- `rest_bounce`
- `jab`
- `cross`
- `jab_cross`
- `jab_cross_slip_cross`
- `jab_cross_pullback_cross`
- `move_after_punching`
- warm-up animations

## Phase 3: Pose-captured Oracle movement

Status: planned.

This is the likely USP path.

Use Ollie/Jordan demo footage plus 33-point pose tracking to create cleaner Action Man animations based on real Oracle Boxing movement.

Goals:

- create a filming standard for demo clips
- process one clean jab video first
- extract 33 body landmarks per frame
- normalize and smooth the motion
- map landmarks into Action Man joints
- export keyframes into the app animation library
- replace hand-authored jab with captured jab
- repeat for cross, jab-cross, and first warm-up movements

Reference: [`POSE_CAPTURE.md`](POSE_CAPTURE.md)

## Phase 4: Content model cleanup

Status: planned.

Goals:

- migrate away from temporary `workout_templates.blocks_json`
- apply clean `workouts` / `workout_items` schema when ready
- move animation IDs into canonical content metadata:
  - `moves.animation_key`
  - `exercises.structure_json.animation_id`, or future `exercises.animation_id`
  - `combinations.animation_script_id`
  - `workout_items.override_animation_id`

## Phase 5: User progress

Status: later.

Goals:

- track workout completion locally first
- sync progress to Supabase behind RLS
- show simple completion history
- avoid gamification bloat

## Parked

These are not current priorities:

- Rive renderer
- Lottie animation pipeline
- SpriteKit game-style renderer
- video-analysis coaching
- social feed
- XP/levels/leaderboards

Do not reopen these unless Jordan explicitly asks.
