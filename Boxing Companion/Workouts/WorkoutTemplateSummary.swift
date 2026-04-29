import Foundation

struct WorkoutTemplateSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String?
    let discipline: WorkoutDiscipline
    let durationMinutes: Int?
    let difficulty: Int?
    let categories: [String]
    let equipment: [String]

    var disciplineTitle: String {
        discipline.title
    }

    var durationLabel: String {
        guard let durationMinutes else { return "Open duration" }
        return "\(durationMinutes) min"
    }

    var difficultyLabel: String {
        guard let difficulty else { return "Beginner" }

        switch difficulty {
        case 0...1: return "Beginner"
        case 2: return "Intermediate"
        default: return "Advanced"
        }
    }

    var primaryCategoryLabel: String? {
        categories.first?.replacingOccurrences(of: "_", with: " ").capitalized
    }

    static let fallbackWorkouts: [WorkoutTemplateSummary] = [
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
}

enum WorkoutDiscipline: String, CaseIterable, Hashable {
    case all
    case boxing
    case running
    case strengthConditioning = "strength_conditioning"
    case hybrid
    case unknown

    var title: String {
        switch self {
        case .all: return "All"
        case .boxing: return "Boxing"
        case .running: return "Running"
        case .strengthConditioning: return "S&C"
        case .hybrid: return "Hybrid"
        case .unknown: return "Other"
        }
    }

    var accentEmoji: String {
        switch self {
        case .all: return "🥊"
        case .boxing: return "🥊"
        case .running: return "🏃"
        case .strengthConditioning: return "💪"
        case .hybrid: return "⚡️"
        case .unknown: return "•"
        }
    }

    static func from(_ rawValue: String?) -> WorkoutDiscipline {
        guard let rawValue else { return .unknown }
        return WorkoutDiscipline(rawValue: rawValue) ?? .unknown
    }
}
