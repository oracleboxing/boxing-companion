# Boxing Companion

**Boxing Companion** is the native iOS training companion for Oracle Boxing.

The job of the app is simple: help a boxer know exactly what to train today, press **Start Workout**, and follow a clean coach-led session without drowning in menus, badges, or generic fitness-app noise.

## Product direction

Boxing Companion is:
- a native SwiftUI iOS app
- a companion to the Oracle Boxing Skool community
- built around workouts, warm-ups, progress, and grading support
- powered by Oracle-authored boxing content
- backed by the existing Oracle Boxing Supabase project

Boxing Companion is not:
- a social network
- a Duolingo-style boxing RPG
- an AI-generated drill library
- a generic fitness app with boxing paint thrown on it
- a replacement for Oracle Boxing coaching

## MVP focus

The first useful version should do four things well:

1. Show the boxer today's training.
2. Let them start a workout quickly.
3. Run a simple timer/block-based workout experience.
4. Track completion locally and sync useful progress to Supabase later.

The first content slice is dynamic warm-ups plus simple beginner boxing workouts.

## Technical direction

- UI: SwiftUI
- Local persistence: SwiftData
- Cloud backend: Supabase
- Secrets/session storage: Keychain
- Tests: Swift Testing and XCUITest
- CloudKit: intentionally not used

Supabase is the source of truth. SwiftData is for local cache/offline state only.

## Repo context

Read these before building:

- [`PRODUCT.md`](PRODUCT.md)
- [`ARCHITECTURE.md`](ARCHITECTURE.md)
- [`MVP.md`](MVP.md)
- [`DATA_MODEL.md`](DATA_MODEL.md)
- [`SUPABASE.md`](SUPABASE.md)
- [`DESIGN.md`](DESIGN.md)
- [`ACTION_MAN.md`](ACTION_MAN.md)
- [`CODEX.md`](CODEX.md)
