import Foundation

enum AppTimeFormatter {
    static func clockTime(for seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    static func durationLabel(for seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60

        if minutes == 0 {
            return "\(remainingSeconds) sec"
        }

        if remainingSeconds == 0 {
            return "\(minutes) min"
        }

        return "\(minutes)m \(remainingSeconds)s"
    }
}
