import Foundation

struct WorkoutSessionSupabaseClient {
    enum ClientError: Error {
        case missingConfiguration
        case invalidResponse
    }

    var workoutName = "Workout Alpha"

    func fetchWorkoutAlpha() async throws -> WorkoutSession {
        guard
            let baseURL = AppConfig.supabaseURL,
            let anonKey = AppConfig.supabaseAnonKey
        else {
            throw ClientError.missingConfiguration
        }

        var components = URLComponents(string: "\(baseURL)/rest/v1/workout_templates")
        components?.queryItems = [
            URLQueryItem(name: "select", value: "title,summary,blocks_json"),
            URLQueryItem(name: "title", value: "ilike.*\(workoutName)*"),
            URLQueryItem(name: "limit", value: "1")
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

        let rows = try JSONDecoder().decode([WorkoutSessionRow].self, from: data)
        guard let row = rows.first else {
            return WorkoutSession.placeholder
        }

        return row.session(named: workoutName)
    }
}

private struct WorkoutSessionRow: Decodable {
    let title: String?
    let summary: String?
    let blocksJSON: [WorkoutSessionBlockRow]?

    enum CodingKeys: String, CodingKey {
        case title
        case summary
        case blocksJSON = "blocks_json"
    }

    func session(named fallbackName: String) -> WorkoutSession {
        let displayTitle = title ?? fallbackName
        let blocks = blocksJSON?.map(\.block).filter { !$0.title.isEmpty } ?? []

        return WorkoutSession(
            title: displayTitle,
            blocks: blocks.isEmpty ? [WorkoutSessionBlock(title: summary ?? displayTitle, type: .unknown, durationSeconds: 0)] : blocks
        )
    }
}

private struct WorkoutSessionBlockRow: Decodable {
    let title: String?
    let type: String?
    let durationSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case type
        case durationSeconds = "duration_seconds"
    }

    var block: WorkoutSessionBlock {
        WorkoutSessionBlock(
            title: title ?? "",
            type: WorkoutSessionBlockType(rawValue: type ?? "") ?? .unknown,
            durationSeconds: durationSeconds ?? 0
        )
    }
}

private enum AppConfig {
    static var supabaseURL: String? {
        value(named: "SUPABASE_URL")
    }

    static var supabaseAnonKey: String? {
        value(named: "SUPABASE_ANON_KEY")
    }

    private static func value(named key: String) -> String? {
        if let environmentValue = ProcessInfo.processInfo.environment[key], !environmentValue.isEmpty {
            return environmentValue
        }

        if let bundleValue = Bundle.main.object(forInfoDictionaryKey: key) as? String, !bundleValue.isEmpty {
            return bundleValue
        }

        if let localValue = localEnvironmentValue(named: key), !localValue.isEmpty {
            return localValue
        }

        return nil
    }

    private static func localEnvironmentValue(named key: String) -> String? {
        guard
            let url = Bundle.main.url(forResource: "Supabase", withExtension: "local.env"),
            let contents = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }

        return contents
            .split(separator: "\n")
            .compactMap { line -> (String, String)? in
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)

                guard
                    !trimmedLine.isEmpty,
                    !trimmedLine.hasPrefix("#"),
                    let separatorIndex = trimmedLine.firstIndex(of: "=")
                else {
                    return nil
                }

                let lineKey = String(trimmedLine[..<separatorIndex])
                let rawValue = trimmedLine[trimmedLine.index(after: separatorIndex)...]
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

                return (lineKey, rawValue)
            }
            .first { $0.0 == key }?
            .1
    }
}
