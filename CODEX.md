# Codex Instructions

You are working on Boxing Companion, a native iOS app for Oracle Boxing.

## Product summary

Build a premium, native SwiftUI training companion. The main user action is **Start Workout**. The app should help a boxer know what to train today and follow a clean coach-led workout.

## Important constraints

- Use SwiftUI.
- Use SwiftData for local cache/offline state.
- Use Supabase as the cloud source of truth.
- Do not use CloudKit.
- Do not invent a new backend.
- Do not put service-role keys or private secrets in the app.
- Do not build social feeds, RPG levels, leaderboards, or generic gamification.
- Do not treat AI-generated raw content as canonical member-facing content.

## Current Xcode state

This repo was created from the Xcode SwiftData template, so default sample files may still exist:

- `Item.swift`
- sample `ContentView`
- sample add/delete list UI

Replace those with app-specific models and views as soon as useful.

## Current build slice

The app now has a first workout session vertical slice:

1. `ContentView` launches `WorkoutSessionView`.
2. `WorkoutSessionSupabaseClient` fetches `Workout Alpha` from Supabase `workout_templates`.
3. `WorkoutSessionEngine` owns active block, countdown, play/pause, previous/next, and completion.
4. If Supabase fails, the app falls back to a placeholder session.

Next useful product slice: build the lightweight Action Man animation system described in [`ACTION_MAN.md`](ACTION_MAN.md), then connect the active workout block to an animation ID.

## Suggested feature structure

```text
Boxing Companion/
  ActionMan/
  Features/
    Home/
    WorkoutRunner/
    Progress/
  Models/
  Services/
  DesignSystem/
```

Keep files small and obvious. Prefer boring, readable Swift over clever architecture.

## Testing

Use Swift Testing for unit tests. Use XCUITest for user flows.

Minimum useful tests:
- timer starts in prep/current block state
- timer advances to next block
- pause/resume works
- completion triggers after final block
- app launches and Start Workout opens runner
- Action Man pose interpolation works
- unknown animation ID falls back safely
- active block maps to the expected animation ID

## Ask before

Ask before:
- changing storage/backend direction
- adding CloudKit
- adding subscription/payment flows
- introducing major third-party SDKs
- restructuring the whole app architecture

## Tone of product

Calm, premium, useful. No generic AI mush. No “fitness bro SaaS dashboard” nonsense.
