import SwiftUI

struct ActionManView: View {
    let animationID: String?
    let isPlaying: Bool
    var lineColor: Color = .primary

    var body: some View {
        TimelineView(.animation) { context in
            let animation = ActionManAnimationLibrary.animation(for: animationID)
            let elapsedTime = isPlaying
                ? context.date.timeIntervalSinceReferenceDate
                : 0
            let pose = animation.pose(at: elapsedTime)

            ActionManRenderer(
                pose: pose,
                lineColor: lineColor
            )
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        guard let animationID else {
            return "Action Man showing guard bounce"
        }

        return "Action Man showing \(animationID.replacingOccurrences(of: "_", with: " "))"
    }
}

#Preview {
    VStack {
        ActionManView(animationID: "jab_cross", isPlaying: true)
            .frame(width: 220, height: 320)
    }
    .padding()
}
