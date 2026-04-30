import Foundation

struct SupabaseRestClient {
    enum ClientError: Error {
        case missingConfiguration
        case invalidResponse
    }

    private let baseURL: String
    private let anonKey: String
    private let session: URLSession
    private let decoder: JSONDecoder

    init?(
        baseURL: String? = AppConfig.supabaseURL,
        anonKey: String? = AppConfig.supabaseAnonKey,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        guard let baseURL, let anonKey else {
            return nil
        }

        self.baseURL = baseURL
        self.anonKey = anonKey
        self.session = session
        self.decoder = decoder
    }

    func fetchRows<Row: Decodable>(
        from table: String,
        queryItems: [URLQueryItem]
    ) async throws -> [Row] {
        let request = try request(table: table, queryItems: queryItems)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw ClientError.invalidResponse
        }

        return try decoder.decode([Row].self, from: data)
    }

    private func request(table: String, queryItems: [URLQueryItem]) throws -> URLRequest {
        var components = URLComponents(string: "\(baseURL)/rest/v1/\(table)")
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw ClientError.missingConfiguration
        }

        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
