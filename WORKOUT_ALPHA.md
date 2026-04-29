# Workout Alpha

`Workout Alpha` is the first live Supabase workout seed for Boxing Companion.

## Current live location

Until the clean `workouts` / `workout_items` tables are applied live, this workout lives in the legacy-but-current table:

- `workout_templates`
- title: `Workout Alpha`
- duration: `18` minutes
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

The seeded workout has 13 blocks:

1. Get Ready
2. Light Bounce
3. Alternating Knee Raises
4. Step Over The Gate
5. Standing Torso Twists
6. Squat And Open
7. Alternating Forward Lunges
8. Round 1: Stance And Guard
9. Rest
10. Round 2: Jab Cross Basics
11. Rest
12. Round 3: Move After Punching
13. Finish

## Important note

This is a pragmatic first seed so the native app has something real to query immediately.

The target schema is still:

- `workouts`
- `workout_items`
- `workout_item_exercises`
- `workout_item_moves`
- `workout_item_combinations`

When that schema is live, migrate Workout Alpha across rather than building long-term architecture around `workout_templates`.
