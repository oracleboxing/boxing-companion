import SwiftUI

enum AppTheme {
    enum ColorToken {
        static let screenBackground = Color.systemBackground
        static let cardBackground = Color(red: 0.965, green: 0.955, blue: 0.945)
        static let cardStroke = Color.black.opacity(0.06)
        static let primaryText = Color.black
        static let secondaryText = Color.black.opacity(0.56)
        static let accent = Color.black
        static let controlSurface = Color(red: 0.965, green: 0.955, blue: 0.945)
        static let restSurface = Color.black
    }

    enum FontToken {
        static let screenEyebrow = Font.system(size: 20, weight: .bold)
        static let screenTitle = Font.system(size: 27, weight: .bold)
        static let cardTitle = Font.system(size: 14, weight: .semibold)
        static let cardSubtitle = Font.system(size: 11, weight: .regular)
        static let navTitle = Font.system(size: 16, weight: .semibold)
        static let sectionLabel = Font.caption.weight(.semibold)
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 22
        static let screenTop: CGFloat = 64
        static let cardHorizontal: CGFloat = 22
        static let cardVertical: CGFloat = 18
        static let rowGap: CGFloat = 18
    }

    enum Radius {
        static let card: CGFloat = 12
        static let button: CGFloat = 10
    }
}

struct AppPageTitle: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow)
                .font(AppTheme.FontToken.screenEyebrow)
                .foregroundStyle(AppTheme.ColorToken.primaryText)

            Text(title)
                .font(AppTheme.FontToken.screenTitle)
                .foregroundStyle(AppTheme.ColorToken.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Color {
    static var systemBackground: Color {
#if os(iOS)
        Color(uiColor: .systemBackground)
#elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
#else
        Color.white
#endif
    }
}
