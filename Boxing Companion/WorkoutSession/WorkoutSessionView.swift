import SwiftUI
import Combine

struct WorkoutSessionView: View {
    @State private var engine = WorkoutSessionEngine()
    @State private var loadState = AppLoadState.loading

    private let workout: WorkoutTemplateSummary?
    private let preloadedSession: WorkoutSession?
    private let startsAutomatically: Bool
    private let client: WorkoutSessionSupabaseClient
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(
        workout: WorkoutTemplateSummary? = nil,
        preloadedSession: WorkoutSession? = nil,
        startsAutomatically: Bool = false
    ) {
        self.workout = workout
        self.preloadedSession = preloadedSession
        self.startsAutomatically = startsAutomatically
        self.client = WorkoutSessionSupabaseClient(
            workoutID: workout?.id,
            workoutName: workout?.title ?? "Workout Alpha"
        )

        var initialEngine = WorkoutSessionEngine()
        if let preloadedSession {
            initialEngine.setWorkout(preloadedSession)
            if startsAutomatically {
                initialEngine.startStop()
            }
            _loadState = State(initialValue: .loaded)
        }
        _engine = State(initialValue: initialEngine)
    }

    var body: some View {
        VStack(spacing: 0) {
            AppScreenHeader(
                title: headerTitle,
                titleColor: primaryTextColor
            )

            GeometryReader { proxy in
                VStack(spacing: 0) {
                    timerZone
                        .frame(height: topHeight(for: proxy.size.height))

                    runnerZone
                        .frame(height: middleHeight(for: proxy.size.height))

                    controlsZone
                        .frame(height: bottomHeight(for: proxy.size.height))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .task {
            await loadWorkout()
        }
        .onReceive(timer) { _ in
            engine.tick()
        }
    }

    private var headerTitle: String {
        workout?.title ?? engine.workout.title
    }

    private var timerZone: some View {
        ZStack {
            liveText
                .offset(y: -18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var runnerZone: some View {
        WorkoutRunnerRouterView(
            engine: engine,
            primaryTextColor: primaryTextColor
        )
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
            .appPrimaryActionStyle(engine.isRunning ? .stop : .start)
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
            : AppTheme.ColorToken.screenBackground
    }

    private var primaryTextColor: Color {
        engine.isResting ? .white : .primary
    }

    private func loadWorkout() async {
        guard preloadedSession == nil else { return }

        do {
            let workout = try await client.fetchWorkout()
            engine.setWorkout(workout)
            if startsAutomatically {
                engine.startStop()
            }
            loadState = .loaded
        } catch {
            engine.setWorkout(WorkoutFallbackCatalog.session(for: workout))
            if startsAutomatically {
                engine.startStop()
            }
            loadState = .offline
        }
    }

}

#Preview {
    WorkoutSessionView(workout: WorkoutFallbackCatalog.workouts[0])
}
