# Architecture

## Stack

- **App:** native iOS using SwiftUI
- **Local storage:** SwiftData
- **Cloud storage:** Supabase
- **Auth/session secrets:** Keychain
- **Testing:** Swift Testing for logic, XCUITest for flows

## Source of truth

Supabase is the cloud source of truth for canonical content and user progress.

SwiftData should be used for:
- cached workouts
- cached movements/exercises/combinations
- local workout completion drafts
- offline-friendly runner state
- lightweight app preferences

Do not use CloudKit. It creates a second sync system and muddies the data model.

## App modules

Suggested structure as the app grows:

```text
Boxing Companion/
  App/
  Features/
    Home/
    WorkoutRunner/
    WorkoutLibrary/
    Progress/
    Auth/
  Models/
    Local/
    Remote/
  Services/
    Supabase/
    Keychain/
    Sync/
  DesignSystem/
  Utilities/
```

Keep feature files small. Prefer clear models and simple services over clever abstractions.

## First technical milestones

1. Replace default Xcode sample `Item` model with app-specific local models.
2. Build static Home and Start Workout screens.
3. Build local-only Workout Runner timer from bundled prototype data.
4. Add Supabase read client for public/canonical content.
5. Cache fetched workouts into SwiftData.
6. Add completion tracking.
7. Add auth only when the unauthenticated runner path is useful.

## Testing strategy

Start pragmatic:

- Swift Testing for timer state machine and data mapping.
- XCUITest smoke flow: open app, tap Start Workout, advance/complete a block.
- Snapshot testing later, once UI direction stabilises.

Do not build a giant test harness before the product shape exists.
