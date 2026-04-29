# MVP Scope

## Goal

Ship the simplest native iOS app that makes Oracle Boxing training easier to follow.

## Must-have screens

### 1. Home / Today

Purpose: make the next action obvious.

Should show:
- today's suggested workout
- primary **Start Workout** CTA
- brief training focus
- small progress/completion cue

### 2. Workout Runner

Purpose: guide the boxer through a session.

Should support:
- prep/warm-up blocks
- work blocks
- rest blocks
- countdown timer
- current block title
- simple coach cues
- up-next preview
- play/pause/skip
- completion state

### 3. Workout Summary

Purpose: close the loop.

Should show:
- workout completed
- total duration
- blocks completed
- simple encouragement
- next suggested action later

## First content slice

Dynamic warm-ups:
- Light Bounce
- Alternating Knee Raises
- Step Over The Gate
- Standing Torso Twists
- Squat And Open
- Alternating Forward Lunges

Names are provisional. Jordan will refine exact Oracle Boxing vocabulary and demo instructions later.

## Not in MVP

- social/community feed
- leaderboards
- XP/levels/badges
- video analysis
- complex grading automation
- full admin editing inside iOS
- purchases/subscription management

## First build recommendation

Build a local-only prototype first:
- static workout JSON or Swift structs
- SwiftData completion state
- no auth
- no Supabase writes

Then wire Supabase reads once the runner feels right.

## Action Man animation roadmap

Current MVP uses hand-authored SwiftUI keyframes.

Best future path: capture Ollie/Jordan demo videos with a 33-point pose model, normalize the landmark data, and convert it into Action Man keyframes. This gives the app Oracle-authored movement instead of guessed animation.

See [`POSE_CAPTURE.md`](POSE_CAPTURE.md).
