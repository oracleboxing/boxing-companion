import Foundation

struct WorkoutLibrarySupabaseClient {
    enum ClientError: Error {
        case missingConfiguration
        case invalidResponse
    }

    func fetchPublishedWorkouts() async throws -> [WorkoutTemplateSummary] {
        guard
            let baseURL = AppConfig.supabaseURL,
            let anonKey = AppConfig.supabaseAnonKey
        else {
            throw ClientError.missingConfiguration
        }

        var components = URLComponents(string: "\(baseURL)/rest/v1/workout_templates")
        components?.queryItems = [
            URLQueryItem(name: "select", value: "id,title,summary,discipline,duration_minutes,difficulty,categories,equipment,is_active,created_at"),
            URLQueryItem(name: "is_active", value: "eq.true"),
            URLQueryItem(name: "order", value: "created_at.asc")
        ]

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

        let rows = try JSONDecoder().decode([WorkoutTemplateSummaryRow].self, from: data)
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
