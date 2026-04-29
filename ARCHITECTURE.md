# Architecture

## Core Rule

Build deep modules with narrow interfaces. Screens should call modules, not know everyone else's business.

The app should feel simple at the surface because complexity is owned by a few clear modules underneath it.

## Current Shape

The app has moved from a bare round timer into a first workout-session vertical slice.

Current entry path:

```text
Boxing_CompanionApp
  -> ContentView
    -> WorkoutLibraryView
      -> WorkoutLibrarySupabaseClient
      -> WorkoutSessionView(selected workout)
        -> WorkoutSessionEngine
        -> WorkoutSessionSupabaseClient
```

Current source layout:

```text
Boxing Companion/
  Boxing_CompanionApp.swift
  ContentView.swift
  App/
    AppConfig.swift
  Workouts/
    WorkoutLibraryView.swift
    WorkoutLibrarySupabaseClient.swift
    WorkoutTemplateSummary.swift
  RoundTimer/
    RoundTimerEngine.swift
    RoundTimerView.swift
  WorkoutSession/
    WorkoutSessionEngine.swift
    WorkoutSessionSupabaseClient.swift
    WorkoutSessionView.swift
```

Current behavior:

- `ContentView` launches `WorkoutLibraryView`.
- `WorkoutLibraryView` fetches active workouts from Supabase `workout_templates` and shows Boxing, Running, and S&C filters.
- Selecting a workout opens `WorkoutSessionView(workout:)`.
- `WorkoutSessionView` fetches the selected workout blocks by Supabase ID, then falls back to title lookup for bundled fallback cards.
- `WorkoutSessionSupabaseClient` reads `blocks_json` from Supabase `workout_templates`.
- `WorkoutSessionEngine` owns current workout, active block index, start/stop state, manual previous/next block movement, and countdown ticks.
- If Supabase config/fetching fails, the library falls back to bundled summary cards and the session falls back to a safe placeholder.
- The old `RoundTimer` module is no longer the main product path. It can stay temporarily as prototype/reference code.

This is a useful MVP slice, but it currently combines domain models, engine logic, Supabase DTO mapping, and feature UI under `WorkoutSession`. The next architecture step is to keep the slice working while extracting deeper modules around it.

## Stack

- **App:** native iOS using SwiftUI
- **Local storage:** SwiftData, later
- **Cloud storage:** Supabase
- **Auth/session secrets:** Keychain, later
- **Testing:** Swift Testing for logic, XCUITest for flows

Do not use CloudKit. Supabase is the cloud source of truth for canonical content and user progress.

## Dependency Direction

Target dependency flow:

```text
App Shell
  -> Features / Screens
    -> Session Engine
    -> Workouts
    -> Persistence
    -> Profiles / Auth

Workouts
  -> Supabase Read Path
```

Important boundaries:

- Screens can depend on modules.
- Modules should not depend on screens.
- Session Engine can depend on workout domain models, but not Supabase, SwiftData, auth, or navigation.
- Workouts can map from static/local/remote sources into domain models, but UI should not consume Supabase DTOs directly.
- Profiles/Auth should not leak into timer, workout, or runner logic.
- App Shell decides what screen appears; it should not own training rules.

## Main Modules

### App Shell

Owns app startup, navigation, dependency assembly, and deciding which high-level screen appears.

Current files:

```text
Boxing Companion/
  Boxing_CompanionApp.swift
  ContentView.swift
```

Responsibilities:

- root SwiftUI scene
- initial feature selection
- lightweight dependency creation
- future navigation flow

Non-responsibilities:

- timer rules
- workout block progression
- Supabase DTO mapping
- user session storage

Near-term guidance:

- Keep `ContentView` as a thin handoff into `WorkoutSessionView`.
- Move files into an `App/` folder later only when the project structure starts to benefit from it.

### Workout Library Feature

Owns browsing and selecting training sessions.

Current files:

```text
Boxing Companion/Workouts/
  WorkoutLibraryView.swift
  WorkoutLibrarySupabaseClient.swift
  WorkoutTemplateSummary.swift
```

Responsibilities:

- show active workouts from Supabase
- group/filter by discipline: Boxing, Running, S&C, Hybrid
- keep cards lightweight and product-facing
- pass selected workout identity into the session runner
- provide fallback workout summaries when Supabase is unavailable

Non-responsibilities:

- running session timers
- parsing workout blocks for playback
- saving completions
- owning auth or progress sync

Deep-module rule: the library consumes workout summaries, not raw Supabase rows. Supabase DTO mapping stays inside `WorkoutLibrarySupabaseClient`.

### Workout Session Feature

Owns the current user-facing guided training surface.

Current files:

```text
Boxing Companion/WorkoutSession/
  WorkoutSessionView.swift
  WorkoutSessionEngine.swift
  WorkoutSessionSupabaseClient.swift
```

Responsibilities:

- active workout-session screen
- large current block text
- large countdown timer
- start/stop control
- previous/next block controls
- loading the selected workout for the current MVP
- support boxing, running, and S&C block types through the same narrow session model
- fallback placeholder when remote loading fails

Non-responsibilities, target state:

- canonical workout model ownership
- Supabase configuration ownership
- Supabase DTO mapping ownership
- persistence implementation
- authentication

Near-term guidance:

- Keep this module working as the vertical slice.
- Extract from it gradually: first domain workout models, then the read-only Supabase repository, then the general session engine.
- The next product-facing addition is the Action Man animation module. The workout session should only pass the active block's animation ID/playback state into Action Man, not own pose drawing logic.

### Action Man

Owns the animated visual training partner.

Current product direction: use the in-app SwiftUI pose/keyframe character. The Rive experiment has been parked so the repo stays focused on the programmable SwiftUI boxer that is already wired into Workout Alpha.

Current files:

```text
Boxing Companion/ActionMan/
  ActionManView.swift
  ActionManRenderer.swift
  ActionManPose.swift
  ActionManAnimation.swift
  ActionManAnimationLibrary.swift
  ActionManAnimationMapper.swift
```

Responsibilities:

- receive active workout block animation ID
- switch the visual character animation safely
- render the stylised SwiftUI boxer
- provide safe fallbacks for unknown animation IDs

Non-responsibilities:

- fetching workouts
- timer/session ownership
- Supabase DTO mapping
- progress persistence
- auth

Public interface should stay narrow:

```swift
struct ActionManView: View {
    let animationID: String?
    let isPlaying: Bool
}
```

Primary implementation guidance lives in `ACTION_MAN.md`.

Future animation authoring direction: use 33-point pose capture from real Oracle Boxing demo videos to generate higher-quality Action Man keyframes. Keep this as an offline/content pipeline, not workout-session UI logic. See `POSE_CAPTURE.md`.

### Session Engine

Owns runtime session state.

Current implementation:

```text
Boxing Companion/WorkoutSession/WorkoutSessionEngine.swift
```

Current responsibilities:

- selected workout session
- running/stopped state
- active block index
- seconds remaining
- formatted time
- previous/next block movement
- block auto-advance

Target responsibilities:

- idle/running/paused/complete status
- current block index
- current block remaining time
- elapsed/completed duration
- start, pause, resume, reset
- deterministic tick handling
- auto-advance through blocks
- completion reporting

Target non-responsibilities:

- fetching workouts
- saving completions
- authentication
- screen routing
- visual formatting

Target path:

```text
Boxing Companion/SessionEngine/
  SessionEngine.swift
  SessionStatus.swift
  SessionSnapshot.swift
```

Key design choice: make the engine deterministic. The engine should expose commands like `start()`, `pause()`, `reset()`, `previousBlock()`, `nextBlock()`, and `tick()`. The SwiftUI view or a thin runner model can own the actual `Timer`.

The UI should render a snapshot rather than reaching into many engine details:

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

### Workouts

Owns workout definitions and their app-domain shape.

Current implementation:

- `WorkoutSession`
- `WorkoutSessionBlock`
- `WorkoutSessionBlockType`

These currently live in `WorkoutSessionEngine.swift`.

Target responsibilities:

- `Workout`
- `WorkoutBlock`
- block types
- exercise/move/combination references
- prototype workout definitions
- mapping from Supabase DTOs to domain models

Target non-responsibilities:

- active timer state
- navigation
- auth
- SwiftUI layout

Target path:

```text
Boxing Companion/Workouts/
  Workout.swift
  WorkoutBlock.swift
  WorkoutBlockType.swift
  LocalWorkoutRepository.swift
```

Current block types are:

```swift
enum WorkoutSessionBlockType: String {
    case prep
    case warmup
    case skill
    case recovery
    case cooldown
    case unknown
}
```

Keep those names for now because they match the current Supabase `blocks_json` shape. Rename only when the content model is clearer.

Eventually keep three model layers:

- Remote DTOs match Supabase shape.
- Domain models match app usage.
- SwiftData models handle local persistence/cache.

Do not let Supabase table shape leak into the runner UI.

### Supabase Read Path

Owns read-only access to published content from the Oracle Boxing Supabase project.

Current implementation:

```text
Boxing Companion/WorkoutSession/WorkoutSessionSupabaseClient.swift
```

Current behavior:

- reads config from environment variables, Info.plist values, or bundled `Supabase.local.env`
- calls Supabase REST endpoint `/rest/v1/workout_templates`
- selects `title,summary,blocks_json`
- filters by `Workout Alpha`
- decodes rows into `WorkoutSession`

Target responsibilities:

- Supabase configuration
- read-only client setup
- fetch published workouts
- fetch related movements, exercises, and combinations later
- map DTOs to domain models
- cache fetched workouts later

Target non-responsibilities:

- direct UI state
- timer state
- auth-only progress writes

Target path:

```text
Boxing Companion/Supabase/
  SupabaseConfig.swift
  SupabaseReadClient.swift
  WorkoutTemplateDTO.swift
  SupabaseWorkoutRepository.swift
```

Rules:

- Use the anon/public key only.
- Never ship a service role key.
- Do not bypass Row Level Security from the client.
- Read curated/published content only.
- Do not expose internal intake tables such as `raw_drill_candidates`.
- Keep configuration tidy. The anon key is public-ish by design, but it should not be scattered through random source files.

### Persistence

Owns local records that are created by the app.

Not implemented yet.

For the MVP, persistence should be intentionally small.

Responsibilities:

- SwiftData completion records
- completed workout timestamp
- duration completed
- blocks completed
- local completion drafts if offline support becomes useful
- cached workouts later, only after the runner feels right

Non-responsibilities:

- canonical workout authoring
- Supabase schema ownership
- active session timing

Target path:

```text
Boxing Companion/Persistence/
```

Do not put canonical workout definitions in SwiftData at first unless caching is needed.

### Profiles / Auth

Owns identity and authenticated session state.

Not implemented yet. Add this only after the unauthenticated runner path is worth identifying.

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

Target path:

```text
Boxing Companion/ProfileAuth/
```

Auth should wrap the app, not invade it. The unauthenticated local/remote runner should still be understandable and testable.

## Target Source Layout

Do not rush the folder shuffle. Let extraction follow working behavior.

```text
Boxing Companion/
  App/
    Boxing_CompanionApp.swift
    ContentView.swift
  Features/
    WorkoutSession/
      WorkoutSessionView.swift
    RoundTimer/
      RoundTimerView.swift
  SessionEngine/
    SessionEngine.swift
    SessionStatus.swift
    SessionSnapshot.swift
  Workouts/
    Workout.swift
    WorkoutBlock.swift
    WorkoutBlockType.swift
    LocalWorkoutRepository.swift
  Supabase/
    SupabaseConfig.swift
    SupabaseReadClient.swift
    WorkoutTemplateDTO.swift
    SupabaseWorkoutRepository.swift
  Persistence/
  ProfileAuth/
  DesignSystem/
  Utilities/
```

Recommended extraction order:

1. Move `WorkoutSession`, `WorkoutSessionBlock`, and `WorkoutSessionBlockType` into `Workouts`.
2. Rename them to `Workout`, `WorkoutBlock`, and `WorkoutBlockType` once call sites are stable.
3. Move Supabase config and DTOs out of `WorkoutSessionSupabaseClient`.
4. Rename `WorkoutSessionEngine` to `SessionEngine` once it no longer owns app-specific workout loading.
5. Keep `WorkoutSessionView` as the first feature screen.
6. Delete or archive `RoundTimer` once the workout session runner fully replaces it.

## Phase Plan

### Phase 1: Bare Timer

Status: mostly superseded.

Completed/started:

- single timer surface exists in `RoundTimer`
- start/stop behavior exists
- default Xcode sample model has been removed

Architecture note:

- Keep `RoundTimer` only while it is useful as reference/prototype code.

### Phase 2: Workout Session Vertical Slice

Status: current active implementation.

Completed/started:

- `WorkoutSessionView` is the app's first screen
- `WorkoutSessionEngine` can start/stop, tick, move previous/next, and auto-advance blocks
- Supabase fetch path exists for `Workout Alpha`
- placeholder fallback exists for missing config/offline failure

Next issues:

- add Swift Testing coverage for engine start/stop/tick/advance behavior
- model explicit session states: idle, running, paused/stopped, complete
- add completion state instead of representing completion only as `secondsRemaining == 0`
- decide whether the primary action means stop, pause, or reset

### Phase 3: Extract Workout Domain

Goal: define what a workout is outside the feature screen.

Issues:

- move `WorkoutSession` models into `Workouts`
- rename domain types away from `WorkoutSession*` if appropriate
- keep block types aligned with Supabase `blocks_json`
- add one local fallback/prototype workout with real block durations
- add tests for DTO-to-domain fallback behavior

### Phase 4: Extract Supabase Read Path

Goal: keep remote reading separate from the runner feature.

Issues:

- extract `AppConfig` into `SupabaseConfig`
- extract `WorkoutSessionRow` and `WorkoutSessionBlockRow` into DTO files
- create a repository that returns domain `Workout` values
- keep the client read-only
- keep `WorkoutSessionView` unaware of REST details

### Phase 5: Session Engine

Goal: make the engine a reusable training state machine.

Issues:

- rename/extract `WorkoutSessionEngine` to `SessionEngine`
- expose `SessionSnapshot`
- add explicit `SessionStatus`
- support reset behavior
- support complete state
- add tests for block progression
- remove display formatting from the engine or make it a small formatter helper

### Phase 6: Runner Polish

Goal: turn the current vertical slice into the real MVP runner.

Issues:

- show current block timer
- show current block name
- show complete state at the end
- preserve simple previous/next controls if they help testing and coaching flow
- add up-next preview later
- do not add settings, stats, badges, or library UI

### Phase 7: Persistence

Goal: save only what is needed.

Issues:

- add SwiftData completion record
- save completed workout timestamp
- save duration completed
- save blocks completed
- keep canonical workout definitions out of SwiftData for now unless caching is needed

Architecture note:

- Completion saving should happen at the edge of the runner flow.
- The engine can report completion, but should not save it.

### Phase 8: Profiles / Auth

Goal: add identity only when the app has something worth identifying.

Issues:

- add auth module boundary
- store session securely in Keychain
- connect Supabase auth
- associate completions with user profile
- add RLS-safe progress write path

Architecture note:

- Auth should wrap the app, not invade it.
- The unauthenticated runner should still be understandable and testable.

## Testing Strategy

Start pragmatic:

- Swift Testing for `WorkoutSessionEngine` immediately.
- Swift Testing for Supabase DTO-to-domain mapping.
- Swift Testing for `SessionEngine` after extraction.
- Swift Testing for completion record creation when persistence is added.
- XCUITest smoke flow: open app, load/fallback workout, start workout, advance blocks, reach complete state.

Do not build a giant test harness before the product shape exists.

## Next Build Recommendation

The highest-leverage next move is tests plus extraction:

1. Add tests around the current `WorkoutSessionEngine`.
2. Add an explicit complete/session state so completion is not inferred from zero seconds.
3. Extract workout domain models from `WorkoutSessionEngine.swift`.
4. Extract Supabase config/DTO mapping from the feature module.

That keeps the working Supabase-powered runner alive while turning the current vertical slice into the deep-module architecture.
