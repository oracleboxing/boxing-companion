import Foundation

struct WorkoutSessionSupabaseClient {
    enum ClientError: Error {
        case missingConfiguration
        case invalidResponse
    }

    var workoutID: String?
    var workoutName = "Workout Alpha"

    func fetchWorkout() async throws -> WorkoutSession {
        guard
            let baseURL = AppConfig.supabaseURL,
            let anonKey = AppConfig.supabaseAnonKey
        else {
            throw ClientError.missingConfiguration
        }

        var components = URLComponents(string: "\(baseURL)/rest/v1/workout_templates")
        components?.queryItems = queryItems()

        guard let url = components?.url else {
            throw ClientError.missingConfiguration
        }

        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw ClientError.invalidResponse
        }

        let rows = try JSONDecoder().decode([WorkoutSessionRow].self, from: data)
        guard let row = rows.first else {
            return WorkoutSession.placeholder
        }

        return row.session(named: workoutName)
    }

    func fetchWorkoutAlpha() async throws -> WorkoutSession {
        try await fetchWorkout()
    }

    private func queryItems() -> [URLQueryItem] {
        var items = [
            URLQueryItem(name: "select", value: "id,title,summary,discipline,blocks_json"),
            URLQueryItem(name: "limit", value: "1")
        ]

        if let workoutID, !workoutID.hasPrefix("fallback-") {
            items.append(URLQueryItem(name: "id", value: "eq.\(workoutID)"))
        } else {
            items.append(URLQueryItem(name: "title", value: "ilike.*\(workoutName)*"))
        }

        return items
    }
}

private struct WorkoutSessionRow: Decodable {
    let title: String?
    let summary: String?
    let discipline: String?
    let blocksJSON: [WorkoutSessionBlockRow]?

    enum CodingKeys: String, CodingKey {
        case title
        case summary
        case discipline
        case blocksJSON = "blocks_json"
    }

    func session(named fallbackName: String) -> WorkoutSession {
        let displayTitle = title ?? fallbackName
        let blocks = blocksJSON?.map(\.block).filter { !$0.title.isEmpty } ?? []

        return WorkoutSession(
            title: displayTitle,
            discipline: .from(discipline),
            blocks: blocks.isEmpty ? [WorkoutSessionBlock(title: summary ?? displayTitle, type: .unknown, durationSeconds: 0, animationID: "guard_bounce")] : blocks
        )
    }
}

private struct WorkoutSessionBlockRow: Decodable {
    let title: String?
    let type: String?
    let durationSeconds: Int?
    let animationID: String?
    let intensity: String?
    let incline: String?
    let prescription: String?
    let notes: String?
    let cues: [String]?
    let repeatCount: Int?
    let workSeconds: Int?
    let restSeconds: Int?
    let equipment: [String]?

    enum CodingKeys: String, CodingKey {
        case title
        case type
        case durationSeconds = "duration_seconds"
        case animationID = "animation_id"
        case intensity
        case incline
        case prescription
        case notes
        case cues
        case repeatCount = "repeat_count"
        case workSeconds = "work_seconds"
        case restSeconds = "rest_seconds"
        case equipment
    }

    var block: WorkoutSessionBlock {
        WorkoutSessionBlock(
            title: title ?? "",
            type: WorkoutSessionBlockType(rawValue: type ?? "") ?? .unknown,
            durationSeconds: durationSeconds ?? 0,
            animationID: animationID,
            intensity: intensity,
            incline: incline,
            prescription: prescription,
            notes: notes,
            cues: cues ?? [],
            repeatCount: repeatCount,
            workSeconds: workSeconds,
            restSeconds: restSeconds,
            equipment: equipment ?? []
        )
    }
}
