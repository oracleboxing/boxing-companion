# Workout Alpha

`Workout Alpha` is the first live Supabase workout seed for Boxing Companion.

It is now Action Man-ready: every block in `blocks_json` has an `animation_id` that the native app can map to the SwiftUI pose/keyframe animation library.

## Current live location

Until the clean `workouts` / `workout_items` tables are applied live, this workout lives in the legacy-but-current table:

- `workout_templates`
- title: `Workout Alpha`
- duration: `23` minutes
- active: `true`
- blocks: `blocks_json`

The iOS app can read it with the anon key.

## Query shape

```sql
select
  id,
  title,
  summary,
  grade,
  difficulty,
  duration_minutes,
  categories,
  equipment,
  discipline,
  blocks_json,
  is_active
from workout_templates
where title = 'Workout Alpha'
  and is_active = true;
```

## Blocks

The seeded workout has 17 blocks:

1. Get Ready, `guard_bounce`, 30s
2. Light Bounce, `guard_bounce`, 30s
3. Alternating Knee Raises, `alternating_knee_raises`, 45s
4. Step Over The Gate, `step_over_the_gate`, 45s
5. Standing Torso Twists, `standing_torso_twists`, 30s
6. Squat And Open, `squat_and_open`, 45s
7. Alternating Forward Lunges, `alternating_forward_lunges`, 45s
8. Isolated Move: Jab, `jab`, 90s
9. Isolated Move: Cross, `cross`, 90s
10. Combo 1: Jab Cross, `jab_cross`, 180s
11. Rest, `rest_bounce`, 60s
12. Combo 2: Jab Cross Slip Rear Side Cross, `jab_cross_slip_cross`, 180s
13. Rest, `rest_bounce`, 60s
14. Combo 3: Jab Cross Pullback Cross, `jab_cross_pullback_cross`, 180s
15. Rest, `rest_bounce`, 60s
16. Round 4: Move After Punching, `move_after_punching`, 180s
17. Finish, `rest_bounce`, 30s

## Supabase animation metadata

Current pragmatic setup:

- `workout_templates.blocks_json[].animation_id` tells the native app what to play for each block.
- `moves.animation_key` has been set for core isolated moves where the column exists, e.g. `jab` and `cross`.
- `exercises.structure_json.animation_id` has been set for the first dynamic warm-ups.

Future target:

- `workouts`
- `workout_items`
- `workout_item_exercises`
- `workout_item_moves`
- `workout_item_combinations`
- canonical `animation_id` / `animation_key` fields across moves, exercises, combinations, and workout-item overrides

When that schema is live, migrate Workout Alpha across rather than building long-term architecture around `workout_templates`.
