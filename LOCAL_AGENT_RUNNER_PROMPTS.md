# Local Agent Runner UX Prompts

Use these as separate chats with the local coding agent. Keep each chat focused. Do not let it rewrite the whole app.

## Shared rules for all runner chats

- Repo: `~/boxing-companion`
- Preserve deep modules.
- Do not put Action Man or animation mapping back into `WorkoutSessionEngine`.
- `WorkoutSessionEngine` owns session state only: current block, next block, timer, status, navigation.
- Runner views own presentation.
- Supabase DTOs stay inside Supabase client/repository files.
- Do not add CloudKit, Rive, Lottie, SpriteKit, or a new animation stack.
- Do not redesign the whole app shell.
- Run Xcode build/simulator smoke test after changes.

---

## Prompt 1: Boxing runner UX

```text
You are working in ~/boxing-companion on the native SwiftUI Boxing Companion app.

Task: optimise the Boxing workout runner UI/UX only.

Context:
- The app has a shared WorkoutSessionEngine.
- Do not put Action Man or animation mapping into the engine.
- Boxing runner should be demo-first.
- Relevant files are likely:
  - Boxing Companion/WorkoutSession/WorkoutRunnerViews.swift
  - Boxing Companion/WorkoutSession/WorkoutSessionView.swift
  - Boxing Companion/ActionMan/*
  - Boxing Companion/DesignSystem/*

Goal:
Make the boxing runner feel like a clean Oracle Boxing coaching screen.

UX requirements:
- Action Man is the hero.
- Current drill/combo title is obvious.
- Timer is large but does not fight the demo.
- Show 1-3 coaching cues from the current block if present.
- Show up-next clearly.
- Rest blocks should feel visually distinct but not ugly.
- Start/pause/next/previous controls stay thumb-friendly.
- Keep typography, spacing, and colours consistent with AppTheme.

Architecture rules:
- Do not duplicate timer logic.
- Do not fetch Supabase data in the runner view.
- Do not change RunningRunnerView or StrengthRunnerView except for shared reusable helpers if genuinely needed.
- Keep changes small and reviewable.

Acceptance test:
- Workout Alpha opens and runs.
- Action Man animation changes by block.
- Cues/up-next display correctly when block data exists.
- Rest state remains readable.
- Xcode build passes.
```

---

## Prompt 2: Running runner UX

```text
You are working in ~/boxing-companion on the native SwiftUI Boxing Companion app.

Task: optimise the Running workout runner UI/UX only.

Context:
- Running workouts do not need Action Man as the hero.
- They need operating procedures: what settings to use, what interval state is active, and what happens next.
- The shared WorkoutSessionEngine owns timer/block progression. Do not duplicate that logic.
- Relevant files are likely:
  - Boxing Companion/WorkoutSession/WorkoutRunnerViews.swift
  - Boxing Companion/DesignSystem/*

Goal:
Make the running runner feel like a treadmill fight-conditioning control panel.

UX requirements:
- No large Action Man hero.
- Timer is very prominent.
- Show current mode: warm-up, work, recovery, interval work, cooldown.
- Show speed/intensity clearly, e.g. 13-16 km/h.
- Show incline clearly, e.g. 1.5%.
- For intervals, show repeat count and work/rest split, e.g. x5, 30s / 10s.
- Show up-next clearly.
- Recovery blocks should feel distinct.
- It should be glanceable while running, so fewer words, bigger numbers.

Architecture rules:
- Do not change BoxingRunnerView or StrengthRunnerView except for shared helper components if genuinely needed.
- Do not add new data fetching.
- Do not move running logic into the engine beyond generic session state.
- Keep the runner driven by current block metadata: intensity, incline, repeat_count, work_seconds, rest_seconds, cues, notes.

Acceptance test:
- Money May W1 S2 HIIT Run opens.
- Warm-up shows speed and incline.
- Interval blocks show split/repeats.
- Recovery blocks show recovery state and up-next.
- Xcode build passes.
```

---

## Prompt 3: S&C runner UX

```text
You are working in ~/boxing-companion on the native SwiftUI Boxing Companion app.

Task: optimise the Strength & Conditioning runner UI/UX only.

Context:
- S&C should keep Action Man big in the middle.
- S&C is not always timer-based. Some exercises are reps/manual completion.
- The shared WorkoutSessionEngine currently supports timer-based progression, and upcoming Supabase metadata will add completion_mode: timer/manual.
- Do not put Action Man or animation mapping into the engine.
- Relevant files are likely:
  - Boxing Companion/WorkoutSession/WorkoutRunnerViews.swift
  - Boxing Companion/WorkoutSession/WorkoutSessionEngine.swift only if needed for generic manual next support
  - Boxing Companion/DesignSystem/*

Goal:
Make the S&C runner feel like a simple coach-led exercise card, not a generic timer app.

UX requirements:
- Action Man is large and central.
- Exercise title is obvious.
- Show prescription clearly, e.g. 8-12 controlled reps or 30 sec each side.
- Show equipment if present.
- Show 1-3 cues if present.
- Show up-next clearly.
- If block completion_mode is manual/reps, prioritise a large Done / Next Exercise button instead of forcing a timer.
- If block completion_mode is timer, show the timer prominently.
- Rest blocks still use timer/recovery presentation.

Architecture rules:
- Do not duplicate timer logic.
- If manual progression is needed, add it generically to the session engine as a block completion mode, not as S&C-only state.
- Do not change BoxingRunnerView or RunningRunnerView except for shared helper components if genuinely needed.
- Keep changes small and reviewable.

Acceptance test:
- S&C Alpha opens.
- Reps-based blocks can be completed manually.
- Timed blocks still count down.
- Action Man remains the visual hero.
- Xcode build passes.
```
