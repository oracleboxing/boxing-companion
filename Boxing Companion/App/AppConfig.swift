import Foundation

enum AppConfig {
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
