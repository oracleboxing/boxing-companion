# Data Model Context

The native app should align with the Oracle Boxing canonical training model.

## Canonical content tables

### `moves`

Canonical boxing movements. Examples: punches, footwork, defence, feints.

This is the source of truth for reusable boxing actions.

### `combinations`

Reusable named boxing sequences.

### `combination_items`

Ordered move links inside a combination.

### `exercises`

Non-boxing or supporting training items. For the first MVP this includes dynamic warm-ups.

Examples:
- Light Bounce
- Alternating Knee Raises
- Step Over The Gate
- Standing Torso Twists
- Squat And Open
- Alternating Forward Lunges

## Workout composition tables

Target clean schema:

### `workouts`

Top-level workout/session template.

### `workout_items`

Ordered blocks within a workout.

A block can represent warm-up, skill work, conditioning, rest/recovery, cooldown, etc.

### `workout_item_exercises`

Links exercises to a workout block.

### `workout_item_moves`

Links moves to a workout block.

### `workout_item_combinations`

Links combinations to a workout block.

## Raw/internal tables

### `raw_drill_candidates`

Internal review/intake table only. Do not use this as app-facing content.

It exists for extracted content, AI triage, duplicate detection, and manual curation.

## Language note

Internal schema uses `moves`, `exercises`, and `combinations`.

The product can still say “drills” where that is clearer for boxers. Do not rename database concepts just because product copy uses friendlier language.

## App model recommendation

Use separate models for local and remote data:

- Remote DTOs match Supabase shape.
- Domain models match app usage.
- SwiftData models handle local persistence/cache.

Do not let Supabase table shape leak everywhere into the UI.
