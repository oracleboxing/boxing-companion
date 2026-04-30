import Foundation

struct WorkoutSessionSupabaseClient {
    var workoutID: String?
    var workoutName = "Workout Alpha"

    func fetchWorkout() async throws -> WorkoutSession {
        guard let client = SupabaseRestClient() else {
            throw SupabaseRestClient.ClientError.missingConfiguration
        }

        let rows: [WorkoutSessionRow] = try await client.fetchRows(
            from: "workout_templates",
            queryItems: queryItems()
        )

        guard let row = rows.first else {
            throw SupabaseRestClient.ClientError.invalidResponse
        }

        return row.session(named: workoutName)
    }

    private func queryItems() -> [URLQueryItem] {
        var items = [
            URLQueryItem(name: "select", value: "id,title,summary,discipline,blocks_json"),
            URLQueryItem(name: "limit", value: "1")
        ]

        if let workoutID, !WorkoutFallbackCatalog.isFallbackWorkoutID(workoutID) {
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
            blocks: blocks.isEmpty ? [WorkoutSessionBlock(title: summary ?? displayTitle, type: .unknown, durationSeconds: 60, animationID: "guard_bounce")] : blocks
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
        case name
        case type
        case blockType = "block_type"
        case durationSeconds = "duration_seconds"
        case duration
        case seconds
        case animationID = "animation_id"
        case animation
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? container.decodeIfPresent(String.self, forKey: .name)
        type = try container.decodeIfPresent(String.self, forKey: .type)
            ?? container.decodeIfPresent(String.self, forKey: .blockType)
        durationSeconds = Self.decodeInt(from: container, keys: [.durationSeconds, .duration, .seconds])
        animationID = try container.decodeIfPresent(String.self, forKey: .animationID)
            ?? container.decodeIfPresent(String.self, forKey: .animation)
        intensity = try container.decodeIfPresent(String.self, forKey: .intensity)
        incline = try container.decodeIfPresent(String.self, forKey: .incline)
        prescription = try container.decodeIfPresent(String.self, forKey: .prescription)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        cues = try container.decodeIfPresent([String].self, forKey: .cues)
        repeatCount = Self.decodeInt(from: container, keys: [.repeatCount])
        workSeconds = Self.decodeInt(from: container, keys: [.workSeconds])
        restSeconds = Self.decodeInt(from: container, keys: [.restSeconds])
        equipment = try container.decodeIfPresent([String].self, forKey: .equipment)
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

    private static func decodeInt(
        from container: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) -> Int? {
        for key in keys {
            if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                return value
            }

            if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
                return Int(value)
            }

            if
                let value = try? container.decodeIfPresent(String.self, forKey: key),
                let intValue = Int(value)
            {
                return intValue
            }
        }

        return nil
    }
}
