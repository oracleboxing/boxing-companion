import Foundation

struct WorkoutLibrarySupabaseClient {
    func fetchPublishedWorkouts() async throws -> [WorkoutTemplateSummary] {
        guard let client = SupabaseRestClient() else {
            throw SupabaseRestClient.ClientError.missingConfiguration
        }

        let rows: [WorkoutTemplateSummaryRow] = try await client.fetchRows(
            from: "workout_templates",
            queryItems: [
            URLQueryItem(name: "select", value: "id,title,summary,discipline,duration_minutes,difficulty,categories,equipment,is_active,created_at"),
            URLQueryItem(name: "is_active", value: "eq.true"),
            URLQueryItem(name: "order", value: "created_at.asc")
            ]
        )

        return rows.map(\.summary)
    }
}

private struct WorkoutTemplateSummaryRow: Decodable {
    let id: String
    let title: String?
    let summaryText: String?
    let discipline: String?
    let durationMinutes: Int?
    let difficulty: Int?
    let categories: [String]?
    let equipment: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case summaryText = "summary"
        case discipline
        case durationMinutes = "duration_minutes"
        case difficulty
        case categories
        case equipment
    }

    var summary: WorkoutTemplateSummary {
        WorkoutTemplateSummary(
            id: id,
            title: title ?? "Untitled Workout",
            summary: summaryText,
            discipline: .from(discipline),
            durationMinutes: durationMinutes,
            difficulty: difficulty,
            categories: categories ?? [],
            equipment: equipment ?? []
        )
    }
}
