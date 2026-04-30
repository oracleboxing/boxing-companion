import Foundation

enum WorkoutFallbackCatalog {
    static let workouts: [WorkoutTemplateSummary] = [
        WorkoutTemplateSummary(
            id: "fallback-workout-alpha",
            title: "Workout Alpha",
            summary: "Beginner boxing session with dynamic warm-ups, isolated jab/cross work, combinations, and move-after-punching rhythm.",
            discipline: .boxing,
            durationMinutes: 23,
            difficulty: 1,
            categories: ["boxing_basics"],
            equipment: ["none"]
        ),
        WorkoutTemplateSummary(
            id: "fallback-running-alpha",
            title: "Money May W1 S2 HIIT Run",
            summary: "24-minute treadmill HIIT session for boxing conditioning.",
            discipline: .running,
            durationMinutes: 24,
            difficulty: 2,
            categories: ["running", "hiit"],
            equipment: ["treadmill"]
        ),
        WorkoutTemplateSummary(
            id: "fallback-sc-alpha",
            title: "S&C Alpha: Shoulder Core Legs",
            summary: "Beginner strength and conditioning session for shoulder control, trunk stability, leg strength, and stance endurance.",
            discipline: .strengthConditioning,
            durationMinutes: 13,
            difficulty: 1,
            categories: ["strength_conditioning"],
            equipment: ["none"]
        )
    ]

    static let placeholderSession = WorkoutSession(
        title: "Workout Alpha",
        discipline: .boxing,
        blocks: [
            WorkoutSessionBlock(title: "Prep: Guard Bounce", type: .prep, durationSeconds: 60, animationID: "guard_bounce"),
            WorkoutSessionBlock(title: "Alternating Knee Raises", type: .warmup, durationSeconds: 60, animationID: "alternating_knee_raises"),
            WorkoutSessionBlock(title: "Jab Mechanics", type: .skill, durationSeconds: 120, animationID: "jab"),
            WorkoutSessionBlock(title: "Recover", type: .recovery, durationSeconds: 45, animationID: "rest_bounce"),
            WorkoutSessionBlock(title: "Jab Cross", type: .skill, durationSeconds: 120, animationID: "jab_cross"),
            WorkoutSessionBlock(title: "Move After Punching", type: .skill, durationSeconds: 120, animationID: "move_after_punching"),
            WorkoutSessionBlock(title: "Cooldown Bounce", type: .cooldown, durationSeconds: 60, animationID: "guard_bounce")
        ]
    )

    static func session(for workout: WorkoutTemplateSummary?) -> WorkoutSession {
        guard let workout else {
            return placeholderSession
        }

        switch workout.discipline {
        case .running:
            return WorkoutSession(
                title: workout.title,
                discipline: workout.discipline,
                blocks: [
                    WorkoutSessionBlock(title: "Warm Up Jog", type: .warmup, durationSeconds: 300, animationID: "guard_bounce"),
                    WorkoutSessionBlock(title: "HIIT Run: Push", type: .runningIntervals, durationSeconds: 60, animationID: "guard_bounce"),
                    WorkoutSessionBlock(title: "HIIT Run: Recover", type: .recovery, durationSeconds: 90, animationID: "rest_bounce"),
                    WorkoutSessionBlock(title: "HIIT Run: Push", type: .runningIntervals, durationSeconds: 60, animationID: "guard_bounce"),
                    WorkoutSessionBlock(title: "HIIT Run: Recover", type: .recovery, durationSeconds: 90, animationID: "rest_bounce"),
                    WorkoutSessionBlock(title: "Cool Down Walk", type: .cooldown, durationSeconds: 300, animationID: "rest_bounce")
                ]
            )
        case .strengthConditioning:
            return WorkoutSession(
                title: workout.title,
                discipline: workout.discipline,
                blocks: [
                    WorkoutSessionBlock(title: "Shoulder Prep", type: .warmup, durationSeconds: 90, animationID: "standing_torso_twists"),
                    WorkoutSessionBlock(title: "Squat and Open", type: .strength, durationSeconds: 120, animationID: "squat_and_open"),
                    WorkoutSessionBlock(title: "Alternating Forward Lunges", type: .strength, durationSeconds: 120, animationID: "alternating_forward_lunges"),
                    WorkoutSessionBlock(title: "Core Torso Twists", type: .conditioning, durationSeconds: 120, animationID: "standing_torso_twists"),
                    WorkoutSessionBlock(title: "Recover", type: .recovery, durationSeconds: 60, animationID: "rest_bounce"),
                    WorkoutSessionBlock(title: "Stance Hold Bounce", type: .cooldown, durationSeconds: 90, animationID: "guard_bounce")
                ]
            )
        default:
            return placeholderSession
        }
    }

    static func isFallbackWorkoutID(_ id: String) -> Bool {
        id.hasPrefix("fallback-")
    }
}
