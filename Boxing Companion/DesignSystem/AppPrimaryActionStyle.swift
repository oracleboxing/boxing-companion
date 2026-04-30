import SwiftUI

enum AppPrimaryActionState {
    case start
    case stop
}

private struct AppPrimaryActionVisuals {
    let colors: [Color]
    let foregroundColor: Color
    let shadowColor: Color

    static func visuals(for state: AppPrimaryActionState) -> AppPrimaryActionVisuals {
        switch state {
        case .start:
            AppPrimaryActionVisuals(
                colors: [
                    Color(red: 0.74, green: 0.93, blue: 0.76),
                    Color(red: 0.55, green: 0.84, blue: 0.58)
                ],
                foregroundColor: Color(red: 0.02, green: 0.32, blue: 0.09),
                shadowColor: Color(red: 0.12, green: 0.45, blue: 0.16).opacity(0.24)
            )
        case .stop:
            AppPrimaryActionVisuals(
                colors: [
                    Color(red: 1.00, green: 0.78, blue: 0.76),
                    Color(red: 0.96, green: 0.62, blue: 0.59)
                ],
                foregroundColor: Color(red: 0.55, green: 0.04, blue: 0.03),
                shadowColor: Color(red: 0.68, green: 0.12, blue: 0.10).opacity(0.24)
            )
        }
    }
}

private struct AppPrimaryActionStyleModifier: ViewModifier {
    let state: AppPrimaryActionState

    func body(content: Content) -> some View {
        let visuals = AppPrimaryActionVisuals.visuals(for: state)

        content
            .buttonStyle(.plain)
            .background(
                LinearGradient(
                    colors: visuals.colors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundStyle(visuals.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous))
            .shadow(color: visuals.shadowColor, radius: 14, y: 8)
    }
}

extension View {
    func appPrimaryActionStyle(_ state: AppPrimaryActionState) -> some View {
        modifier(AppPrimaryActionStyleModifier(state: state))
    }
}
