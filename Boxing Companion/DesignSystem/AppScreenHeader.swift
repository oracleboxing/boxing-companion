import SwiftUI

struct AppScreenHeader: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    var titleColor: Color = .primary
    var showsBackButton = true
    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            HStack {
                if showsBackButton {
                    Button {
                        if let onBack {
                            onBack()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.ColorToken.primaryText)
                            .frame(width: 42, height: 42)
                            .background(AppTheme.ColorToken.controlSurface, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")
                }

                Spacer(minLength: 0)
            }

            Text(title)
                .font(AppTheme.FontToken.navTitle)
                .foregroundStyle(titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 58)
        }
        .frame(height: 42)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AppScreenHeader(title: "Money May W1 S2 HIIT Run")
        .padding(24)
}
