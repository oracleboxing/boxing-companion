import SwiftUI
import Combine

struct WorkoutSessionView: View {
    @State private var engine = WorkoutSessionEngine()
    @State private var loadState = LoadState.loading

    private let client = WorkoutSessionSupabaseClient()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                timerZone
                    .frame(height: topHeight(for: proxy.size.height))

                athleteAndTextZone
                    .frame(height: middleHeight(for: proxy.size.height))

                controlsZone
                    .frame(height: bottomHeight(for: proxy.size.height))
            }
        }
        .padding(24)
        .background(screenBackground.ignoresSafeArea())
        .task {
            await loadWorkout()
        }
        .onReceive(timer) { _ in
            engine.tick()
        }
    }

    private var timerZone: some View {
        ZStack {
            liveText
                .offset(y: -18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var athleteAndTextZone: some View {
        VStack(spacing: 0) {
            ZStack {
                StandingBoxerPlaceholder()
                    .stroke(primaryTextColor, lineWidth: 9)
                    .frame(width: 168, height: 248)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ZStack {
                Color.clear

                // Keep this zone reserved so the timer does not move when workout names wrap.
                timerText
                    .offset(y: 18)
            }
            .frame(height: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var liveText: some View {
        Text(engine.liveText)
            .font(.system(size: 44, weight: .semibold))
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.55)
            .lineLimit(3)
            .foregroundStyle(primaryTextColor)
            .frame(maxWidth: .infinity)
    }

    private var timerText: some View {
        Text(engine.formattedTimeRemaining)
            .font(.system(size: 100, weight: .heavy, design: .default))
            .fontWidth(.condensed)
            .monospacedDigit()
            .scaleEffect(x: 0.94, y: 1.2, anchor: .center)
            .foregroundStyle(primaryTextColor)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    private var controlsZone: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)

            HStack(spacing: 16) {
                Button {
                    engine.previousBlock()
                } label: {
                    Text("PREV")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .disabled(!engine.canMovePrevious)

                Button {
                    engine.nextBlock()
                } label: {
                    Text("NEXT")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .disabled(!engine.canMoveNext)
            }
            .buttonStyle(.plain)
            .foregroundStyle(primaryTextColor)
            .opacity(engine.isResting ? 0.82 : 1)

            Button {
                engine.startStop()
            } label: {
                Text(engine.primaryActionTitle)
                    .font(.system(size: 44, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 104)
            }
            .buttonStyle(.plain)
            .background(startStopBackground)
            .foregroundStyle(startStopForegroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: startStopShadowColor, radius: 14, y: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func topHeight(for height: CGFloat) -> CGFloat {
        height * 0.25
    }

    private func middleHeight(for height: CGFloat) -> CGFloat {
        height * 0.42
    }

    private func bottomHeight(for height: CGFloat) -> CGFloat {
        height * 0.33
    }

    private var screenBackground: Color {
        engine.isResting
            ? Color(red: 0.05, green: 0.06, blue: 0.07)
            : Color.systemBackground
    }

    private var primaryTextColor: Color {
        engine.isResting ? .white : .primary
    }

    private func loadWorkout() async {
        do {
            let workout = try await client.fetchWorkoutAlpha()
            engine.setWorkout(workout)
            loadState = .loaded
        } catch {
            engine.setWorkout(.placeholder)
            loadState = .offline
        }
    }

    private var startStopBackground: some ShapeStyle {
        LinearGradient(
            colors: engine.isRunning
                ? [Color(red: 1.00, green: 0.78, blue: 0.76), Color(red: 0.96, green: 0.62, blue: 0.59)]
                : [Color(red: 0.74, green: 0.93, blue: 0.76), Color(red: 0.55, green: 0.84, blue: 0.58)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var startStopShadowColor: Color {
        engine.isRunning
            ? Color(red: 0.68, green: 0.12, blue: 0.10).opacity(0.24)
            : Color(red: 0.12, green: 0.45, blue: 0.16).opacity(0.24)
    }

    private var startStopForegroundColor: Color {
        engine.isRunning
            ? Color(red: 0.55, green: 0.04, blue: 0.03)
            : Color(red: 0.02, green: 0.32, blue: 0.09)
    }
}

private enum LoadState {
    case loading
    case loaded
    case offline
}

private struct StandingBoxerPlaceholder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let centerX = rect.midX
        let headRadius = rect.width * 0.15
        let headCenter = CGPoint(x: centerX, y: rect.minY + rect.height * 0.16)
        path.addEllipse(in: CGRect(
            x: headCenter.x - headRadius,
            y: headCenter.y - headRadius,
            width: headRadius * 2,
            height: headRadius * 2
        ))

        path.move(to: CGPoint(x: centerX, y: rect.minY + rect.height * 0.30))
        path.addLine(to: CGPoint(x: centerX, y: rect.minY + rect.height * 0.62))

        path.move(to: CGPoint(x: centerX, y: rect.minY + rect.height * 0.38))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.minY + rect.height * 0.50))

        path.move(to: CGPoint(x: centerX, y: rect.minY + rect.height * 0.38))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.28, y: rect.minY + rect.height * 0.50))

        path.move(to: CGPoint(x: centerX, y: rect.minY + rect.height * 0.62))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.34, y: rect.maxY - rect.height * 0.10))

        path.move(to: CGPoint(x: centerX, y: rect.minY + rect.height * 0.62))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.34, y: rect.maxY - rect.height * 0.10))

        return path
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

#Preview {
    WorkoutSessionView()
}
