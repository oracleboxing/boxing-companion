# Architecture

## Core Rule

Build deep modules with narrow interfaces. Screens should call modules, not know everyone else's business.

The app should feel simple at the surface because complexity is owned by a few clear modules underneath it.

## Stack

- **App:** native iOS using SwiftUI
- **Local storage:** SwiftData
- **Cloud storage:** Supabase
- **Auth/session secrets:** Keychain
- **Testing:** Swift Testing for logic, XCUITest for flows

Do not use CloudKit. Supabase is the cloud source of truth for canonical content and user progress.

## Dependency Direction

High-level dependency flow:

```text
App Shell
  -> Screens / Features
    -> Session Engine
    -> Workouts
    -> Profiles / Auth
    -> Persistence
    -> Supabase Read Path
```

Important boundaries:

- Screens can depend on modules.
- Modules should not depend on screens.
- Session Engine can depend on workout domain models, but not Supabase, SwiftData, auth, or navigation.
- Workouts can map from local/static/remote sources into domain models, but UI should not consume Supabase DTOs directly.
- Profiles/Auth should not leak into timer, workout, or runner logic.
- App Shell decides what screen appears; it should not own training rules.

## Main Modules

### App Shell

Owns app startup, navigation, dependency assembly, and deciding which high-level screen appears.

Responsibilities:

- root SwiftUI scene
- navigation flow
- lightweight dependency creation
- feature entry points

Non-responsibilities:

- timer rules
- workout block progression
- Supabase DTO mapping
- user session storage

Suggested path:

```text
Boxing Companion/App/
```

### Session Engine

Owns runtime session state.

The app should be able to say "run this session" and the engine handles time, pause/resume, completion, and block progression.

Responsibilities:

- idle/running/paused/complete state
- current block index
- current block remaining time
- elapsed/completed duration
- start, pause, resume, stop/reset
- deterministic tick handling
- auto-advance through blocks

Non-responsibilities:

- fetching workouts
- saving completions
- authentication
- screen routing
- visual formatting

Suggested path:

```text
Boxing Companion/SessionEngine/
  SessionEngine.swift
  SessionState.swift
  SessionSnapshot.swift
```

The key design choice: make the engine deterministic. The engine should expose commands like `start()`, `pause()`, `reset()`, and `tick()`. The SwiftUI view or a thin runner model can own the actual `Timer`.

### Workouts

Owns workout definitions and their app-domain shape.

This starts as local Swift structs or bundled JSON, then later gets backed by Supabase read models.

Responsibilities:

- `Workout`
- `WorkoutBlock`
- block types such as warmup, work, rest, cooldown
- exercise/move/combination references
- prototype workout definitions
- mapping from Supabase DTOs to domain models

Non-responsibilities:

- active timer state
- navigation
- auth
- SwiftUI layout

Suggested path:

```text
Boxing Companion/Workouts/
  Domain/
  Local/
  Remote/
```

Keep three model layers when Supabase arrives:

- Remote DTOs match Supabase shape.
- Domain models match app usage.
- SwiftData models handle local persistence/cache.

Do not let Supabase table shape leak into the runner UI.

### Workout Runner

Owns the user-facing guided training screen.

This is a feature module, not the domain engine. It displays engine state and sends commands.

Responsibilities:

- current block timer display
- current block name
- up-next preview later
- start/stop/pause controls
- complete state
- simple coach cues

Non-responsibilities:

- canonical workout definition ownership
- Supabase access
- auth/session storage
- persistence implementation

Suggested path:

```text
Boxing Companion/Features/WorkoutRunner/
```

### Persistence

Owns local records that are created by the app.

For the MVP, persistence should be intentionally small.

Responsibilities:

- SwiftData completion records
- completed workout timestamp
- duration completed
- local completion drafts if offline support becomes useful
- cached workouts later, only after the runner feels right

Non-responsibilities:

- canonical workout authoring
- Supabase schema ownership
- active session timing

Suggested path:

```text
Boxing Companion/Persistence/
```

Do not put canonical workout definitions in SwiftData at first unless caching is needed.

### Supabase Read Path

Owns read-only access to published content from the Oracle Boxing Supabase project.

Responsibilities:

- Supabase configuration
- read-only client setup
- fetch published workouts
- fetch related movements, exercises, and combinations
- map DTOs to domain models
- cache fetched workouts later

Non-responsibilities:

- direct UI state
- timer state
- auth-only progress writes

Suggested path:

```text
Boxing Companion/Supabase/
  SupabaseConfig.swift
  SupabaseClientFactory.swift
  WorkoutDTOs.swift
  WorkoutRemoteRepository.swift
```

Rules:

- Use the anon/public key only.
- Never ship a service role key.
- Do not bypass Row Level Security from the client.
- Read curated/published content only.
- Do not expose internal intake tables such as `raw_drill_candidates`.

### Profiles / Auth

Owns identity and authenticated session state.

Add this only after the unauthenticated runner path is worth identifying.

Responsibilities:

- auth module boundary
- Supabase auth
- Keychain session storage
- current user profile
- RLS-safe progress write path

Non-responsibilities:

- timer state
- workout block progression
- runner display
- workout content mapping

Suggested path:

```text
Boxing Companion/ProfileAuth/
```

## Suggested Source Layout

Near-term layout:

```text
Boxing Companion/
  App/
    Boxing_CompanionApp.swift
    ContentView.swift
  Features/
    RoundTimer/
    WorkoutRunner/
  SessionEngine/
  Workouts/
    Domain/
    Local/
  Persistence/
  Supabase/
  ProfileAuth/
  DesignSystem/
  Utilities/
```

The current `RoundTimer` can stay while proving the UI. Once block-based workouts exist, promote the timer logic into `SessionEngine` and let `RoundTimer` either disappear or become a small debug/prototype feature.

## Core Domain Sketch

The exact Swift names can evolve, but the boundaries should look like this:

```swift
struct Workout: Identifiable, Equatable {
    let id: String
    let title: String
    let blocks: [WorkoutBlock]
}

struct WorkoutBlock: Identifiable, Equatable {
    let id: String
    let type: WorkoutBlockType
    let title: String
    let durationSeconds: Int
    let cues: [String]
}

enum WorkoutBlockType: String, Codable, Equatable {
    case warmup
    case work
    case rest
    case cooldown
}

enum SessionStatus: Equatable {
    case idle
    case running
    case paused
    case complete
}
```

The runner should mostly render a snapshot:

```swift
struct SessionSnapshot: Equatable {
    let status: SessionStatus
    let workoutTitle: String
    let currentBlockTitle: String?
    let currentBlockType: WorkoutBlockType?
    let currentBlockIndex: Int
    let totalBlocks: Int
    let secondsRemaining: Int
    let elapsedSeconds: Int
}
```

That snapshot is the narrow interface between the engine and the UI.

## Phase Plan

### Phase 1: Bare Timer

Goal: prove the simplest training surface.

Issues:

- Build single round timer screen
- Add start/stop timer behavior
- Keep timer state local and disposable
- Remove default Xcode sample app code
- Verify app launches cleanly

Current status:

- A `RoundTimerView` and `RoundTimerEngine` already exist.
- The default sample `Item` model has been removed from the working tree.

### Phase 2: Session Engine

Goal: move timer logic out of the view before it grows claws.

Issues:

- Create `SessionEngine`
- Model session states: idle, running, paused, complete
- Add round duration support
- Add reset behavior
- Add unit tests for start, stop, tick, complete
- Wire timer page to `SessionEngine`

Architecture note:

- Avoid building this as a bigger `RoundTimerEngine`.
- Build it as a block runner, even if the first session has only one block.

### Phase 3: Workout Model

Goal: define what a workout is without touching Supabase yet.

Issues:

- Create local `Workout`
- Create local `WorkoutBlock`
- Support block types: warmup, work, rest
- Add one hardcoded prototype boxing workout
- Make session engine run a workout block sequence
- Add tests for block progression

Architecture note:

- This is where the app graduates from timer to guided training.
- Supabase should still stay out of the app at this phase.

### Phase 4: Workout Runner

Goal: turn the timer into a real guided session, still simple.

Issues:

- Show current block timer
- Show current block name
- Add Start / Stop only
- Auto-advance through blocks
- Show complete state at the end
- Do not add settings, stats, badges, or library UI

Architecture note:

- The runner screen should bind to engine snapshots and send engine commands.
- It should not know how block progression works.

### Phase 5: Persistence

Goal: save only what is needed.

Issues:

- Add SwiftData completion record
- Save completed workout timestamp
- Save duration completed
- Keep canonical workout definitions out of SwiftData for now unless caching is needed

Architecture note:

- Completion saving should happen at the edge of the runner flow.
- The engine can report completion, but should not save it.

### Phase 6: Supabase Read Path

Goal: pull published workouts from the real content source.

Issues:

- Add Supabase config structure
- Add read-only Supabase client
- Fetch published workouts
- Map Supabase DTOs to app domain models
- Cache fetched workouts locally only after the runner feels right

Architecture note:

- Start with a repository that returns domain `Workout` values.
- Keep DTOs private to the Supabase module where possible.

### Phase 7: Profiles / Auth

Goal: add identity only when the app has something worth identifying.

Issues:

- Add auth module boundary
- Store session securely in Keychain
- Connect Supabase auth
- Associate completions with user profile
- Add RLS-safe progress write path

Architecture note:

- Auth should wrap the app, not invade it.
- The unauthenticated local runner should still be understandable and testable.

## Testing Strategy

Start pragmatic:

- Swift Testing for `SessionEngine`.
- Swift Testing for workout DTO-to-domain mapping once Supabase DTOs exist.
- Swift Testing for completion record creation when persistence is added.
- XCUITest smoke flow: open app, start workout, reach complete state.

Do not build a giant test harness before the product shape exists.

## First Build Recommendation

Next technical move:

1. Rename or replace `RoundTimerEngine` with a general `SessionEngine`.
2. Introduce `Workout` and `WorkoutBlock` domain models.
3. Make the current timer screen run a one-block local workout through the engine.
4. Add engine tests before adding Supabase, auth, settings, stats, or a library.

That gives the app its real spine early while keeping the surface tiny.
