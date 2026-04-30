-- Boxing Companion MVP runner layout metadata
-- Run in Supabase SQL editor.
-- Safe/idempotent: adds metadata columns and backfills current workout_templates rows.

alter table public.workout_templates
  add column if not exists runner_layout text,
  add column if not exists block_schema_version integer not null default 1,
  add column if not exists runner_config jsonb not null default '{}'::jsonb;

alter table public.workout_templates
  drop constraint if exists workout_templates_runner_layout_check;

alter table public.workout_templates
  add constraint workout_templates_runner_layout_check
  check (
    runner_layout is null
    or runner_layout in ('boxing_demo', 'running_procedure', 'strength_demo_prescription')
  );

alter table public.workout_templates
  drop constraint if exists workout_templates_discipline_check;

alter table public.workout_templates
  add constraint workout_templates_discipline_check
  check (
    discipline is null
    or discipline in ('boxing', 'running', 'strength_conditioning')
  );

update public.workout_templates
set
  runner_layout = case discipline
    when 'running' then 'running_procedure'
    when 'strength_conditioning' then 'strength_demo_prescription'
    else 'boxing_demo'
  end,
  block_schema_version = greatest(block_schema_version, 2),
  runner_config = case discipline
    when 'running' then jsonb_build_object(
      'hero', 'procedure',
      'show_action_man', false,
      'required_block_fields', jsonb_build_array('duration_seconds', 'intensity', 'incline'),
      'optional_block_fields', jsonb_build_array('repeat_count', 'work_seconds', 'rest_seconds', 'notes', 'cues')
    )
    when 'strength_conditioning' then jsonb_build_object(
      'hero', 'action_man',
      'show_action_man', true,
      'required_block_fields', jsonb_build_array('duration_seconds'),
      'optional_block_fields', jsonb_build_array('prescription', 'equipment', 'notes', 'cues', 'animation_id')
    )
    else jsonb_build_object(
      'hero', 'action_man',
      'show_action_man', true,
      'required_block_fields', jsonb_build_array('duration_seconds', 'animation_id'),
      'optional_block_fields', jsonb_build_array('notes', 'cues')
    )
  end,
  updated_at = now()
where is_active = true;

-- Current block JSON contract used by the native app:
--
-- Boxing blocks:
--   title, type, duration_seconds, animation_id, notes, cues
--
-- Running blocks:
--   title, type, duration_seconds, intensity, incline, repeat_count,
--   work_seconds, rest_seconds, notes, cues
--
-- S&C blocks:
--   title, type, duration_seconds, prescription, equipment, animation_id,
--   notes, cues
--
-- App routing rule:
--   discipline = 'boxing'                -> boxing demo runner
--   discipline = 'running'               -> running procedure runner
--   discipline = 'strength_conditioning' -> S&C demo + prescription runner
