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

## First build slice

Build local-only first:

1. Home screen with app name, today’s training card, and Start Workout CTA.
2. Workout runner screen with timer blocks.
3. Static prototype workout using dynamic warm-up blocks.
4. Completion screen/state.
5. Swift Testing tests for timer state transitions.
6. One XCUITest smoke flow.

Only after that should Supabase reads be added.

## Suggested feature structure

```text
Boxing Companion/
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

## Ask before

Ask before:
- changing storage/backend direction
- adding CloudKit
- adding subscription/payment flows
- introducing major third-party SDKs
- restructuring the whole app architecture

## Tone of product

Calm, premium, useful. No generic AI mush. No “fitness bro SaaS dashboard” nonsense.
