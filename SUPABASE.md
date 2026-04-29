# Supabase Context

Boxing Companion should use the existing Oracle Boxing Supabase project.

## Rules

- Use the anon/public key in the iOS app only.
- Never put the service role key in the iOS app.
- Do not bypass Row Level Security from the client.
- Treat Supabase as source of truth for canonical content.
- Treat SwiftData as local cache/offline state.

## First integration path

1. Build local-only runner.
2. Add read-only Supabase fetches for published workouts/content.
3. Cache fetched content in SwiftData.
4. Add auth.
5. Add progress writes behind RLS policies.

## Content safety

The app should only read curated/published content.

Do not expose internal review/intake tables such as `raw_drill_candidates` to members.

## Environment/config

The final app should load Supabase URL and anon key through a safe app configuration approach suitable for iOS builds.

Do not hardcode secrets into random source files. The anon key is public-ish by design, but still keep configuration tidy.
