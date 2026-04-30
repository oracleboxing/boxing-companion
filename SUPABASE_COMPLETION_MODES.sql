-- Boxing Companion MVP completion modes
-- Run in Supabase SQL editor after SUPABASE_RUNNER_LAYOUTS.sql.
-- Safe/idempotent. This updates existing workout_templates.blocks_json so the native app can distinguish timer-based blocks from reps/manual blocks.

alter table public.workout_templates
  add column if not exists block_schema_version integer not null default 1;

-- Contract:
-- completion_mode = 'timer'
--   The app counts down duration_seconds and auto-advances when complete.
--
-- completion_mode = 'manual'
--   The app shows a Done / Next Exercise action. duration_seconds can be null or treated as an estimate only.
--
-- completion_mode = 'hybrid'
--   Future use. Ignore for MVP unless Jordan explicitly reopens hybrid workouts.

-- Add default timer completion mode to every existing block that lacks it.
update public.workout_templates wt
set
  blocks_json = coalesce((
    select jsonb_agg(
      case
        when block ? 'completion_mode' then block
        else jsonb_set(block, '{completion_mode}', '"timer"'::jsonb, true)
      end
      order by ordinality
    )
    from jsonb_array_elements(wt.blocks_json::jsonb) with ordinality as blocks(block, ordinality)
  ), wt.blocks_json::jsonb),
  block_schema_version = greatest(block_schema_version, 3),
  updated_at = now()
where wt.blocks_json is not null;

-- For S&C, reps/prescription blocks should generally be manual unless they clearly use timed holds or recovery/cooldown.
update public.workout_templates wt
set
  blocks_json = coalesce((
    select jsonb_agg(
      case
        when wt.discipline = 'strength_conditioning'
          and coalesce(block->>'type', '') in ('strength', 'conditioning')
          and coalesce(block->>'prescription', '') !~* '(sec|second|seconds|min|minute|minutes|hold)'
        then jsonb_set(block, '{completion_mode}', '"manual"'::jsonb, true)
        else block
      end
      order by ordinality
    )
    from jsonb_array_elements(wt.blocks_json::jsonb) with ordinality as blocks(block, ordinality)
  ), wt.blocks_json::jsonb),
  block_schema_version = greatest(block_schema_version, 3),
  updated_at = now()
where wt.discipline = 'strength_conditioning'
  and wt.blocks_json is not null;

-- Make the current S&C Alpha intent explicit.
update public.workout_templates wt
set
  blocks_json = coalesce((
    select jsonb_agg(
      case block->>'id'
        when 'sc-alpha-block-1' then jsonb_set(block, '{completion_mode}', '"manual"'::jsonb, true)
        when 'sc-alpha-block-2' then jsonb_set(block, '{completion_mode}', '"manual"'::jsonb, true)
        when 'sc-alpha-block-3' then jsonb_set(block, '{completion_mode}', '"timer"'::jsonb, true)
        when 'sc-alpha-block-4' then jsonb_set(block, '{completion_mode}', '"manual"'::jsonb, true)
        when 'sc-alpha-block-5' then jsonb_set(block, '{completion_mode}', '"timer"'::jsonb, true)
        else block
      end
      order by ordinality
    )
    from jsonb_array_elements(wt.blocks_json::jsonb) with ordinality as blocks(block, ordinality)
  ), wt.blocks_json::jsonb),
  block_schema_version = greatest(block_schema_version, 3),
  updated_at = now()
where wt.title = 'S&C Alpha: Shoulder Core Legs'
  and wt.blocks_json is not null;

-- Suggested shape for future manual S&C blocks:
-- {
--   "id": "sc-example-pushups",
--   "type": "strength",
--   "title": "Scap Push-Ups",
--   "completion_mode": "manual",
--   "prescription": "8-12 controlled reps",
--   "equipment": ["none"],
--   "animation_id": "scap_push_up",
--   "cues": ["Push the floor away", "Control the shoulder blades"]
-- }
--
-- Suggested shape for timed S&C blocks:
-- {
--   "id": "sc-example-side-plank",
--   "type": "strength",
--   "title": "Side Plank",
--   "completion_mode": "timer",
--   "duration_seconds": 30,
--   "prescription": "30 sec each side",
--   "animation_id": "guard_bounce"
-- }
