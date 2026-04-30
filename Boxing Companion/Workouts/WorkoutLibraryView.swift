import SwiftUI

struct WorkoutLibraryView: View {
    @State private var loadState = AppLoadState.loading
    @State private var workouts: [WorkoutTemplateSummary] = []

    private let client = WorkoutLibrarySupabaseClient()

    var body: some View {
        NavigationStack {
            WorkoutLibraryPage(
                navigationTitle: "Workouts",
                pageTitle: "Choose Type",
                showsBackButton: false
            ) {
                LazyVStack(spacing: 14) {
                    ForEach(WorkoutTypeOption.allCases) { option in
                        NavigationLink {
                            WorkoutTypeWorkoutListView(
                                option: option,
                                workouts: workouts.filter { $0.discipline == option.discipline },
                                isLoading: loadState == .loading
                            )
                        } label: {
                            WorkoutTypeRow(option: option)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if loadState == .loading && workouts.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                }
            }
            .task {
                await loadWorkouts()
            }
            .refreshable {
                await loadWorkouts()
            }
        }
    }

    private func loadWorkouts() async {
        loadState = .loading

        do {
            let fetchedWorkouts = try await client.fetchPublishedWorkouts()
            workouts = fetchedWorkouts.isEmpty ? WorkoutFallbackCatalog.workouts : fetchedWorkouts
            loadState = .loaded
        } catch {
            workouts = WorkoutFallbackCatalog.workouts
            loadState = .offline
        }
    }
}

private struct WorkoutTypeWorkoutListView: View {
    let option: WorkoutTypeOption
    let workouts: [WorkoutTemplateSummary]
    let isLoading: Bool

    var body: some View {
        WorkoutLibraryPage(
            navigationTitle: option.title,
            pageTitle: "Choose Workout"
        ) {
            LazyVStack(spacing: 14) {
                ForEach(workouts) { workout in
                    NavigationLink {
                        WorkoutPreviewView(workout: workout)
                    } label: {
                        WorkoutRow(workout: workout)
                    }
                    .buttonStyle(.plain)
                }
            }

            if isLoading && workouts.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
            }
        }
    }
}

private struct WorkoutLibraryPage<Content: View>: View {
    let navigationTitle: String
    let pageTitle: String
    var showsBackButton = true
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AppScreenHeader(
                    title: navigationTitle,
                    titleColor: AppTheme.ColorToken.primaryText,
                    showsBackButton: showsBackButton
                )
                    .padding(.bottom, 28)

                Text(pageTitle)
                    .font(AppTheme.FontToken.screenTitle)
                    .foregroundStyle(AppTheme.ColorToken.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 62)

                content
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(AppTheme.ColorToken.screenBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct WorkoutPreviewView: View {
    let workout: WorkoutTemplateSummary

    @State private var loadState = AppLoadState.loading
    @State private var session: WorkoutSession?

    private let client: WorkoutSessionSupabaseClient

    init(workout: WorkoutTemplateSummary) {
        self.workout = workout
        self.client = WorkoutSessionSupabaseClient(
            workoutID: workout.id,
            workoutName: workout.title
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            AppScreenHeader(title: workout.title, titleColor: AppTheme.ColorToken.primaryText)
                .padding(.bottom, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Plan")
                            .font(AppTheme.FontToken.screenTitle)
                            .foregroundStyle(AppTheme.ColorToken.primaryText)

                        Text("\(session?.totalDurationLabel ?? workout.durationLabel) | \(workout.difficultyLabel)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.ColorToken.secondaryText)
                            .lineLimit(1)
                    }

                    blockList
                }
                .padding(.bottom, 18)
            }

            startWorkoutLink
                .padding(.top, 14)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(AppTheme.ColorToken.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .task(id: workout.id) {
            await loadPreview()
        }
    }

    @ViewBuilder
    private var blockList: some View {
        switch loadState {
        case .loading:
            HStack(spacing: 12) {
                ProgressView()
                Text("Loading workout plan")
                    .font(AppTheme.FontToken.cardTitle)
                    .foregroundStyle(AppTheme.ColorToken.primaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .loaded, .offline:
            LazyVStack(alignment: .leading, spacing: 18) {
                ForEach(planSections) { section in
                    WorkoutPreviewSectionView(section: section)
                }
            }
        }
    }

    private var startWorkoutLink: some View {
        NavigationLink {
            WorkoutSessionView(
                workout: workout,
                preloadedSession: displaySession,
                startsAutomatically: true
            )
        } label: {
            Text("Start Workout")
                .font(.system(size: 44, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 104)
        }
        .appPrimaryActionStyle(.start)
        .disabled(loadState == .loading)
        .opacity(loadState == .loading ? 0.55 : 1)
    }

    private var displaySession: WorkoutSession {
        session ?? WorkoutFallbackCatalog.session(for: workout)
    }

    private var planSections: [WorkoutPreviewSection] {
        var sections: [WorkoutPreviewSection] = []

        for block in displaySession.blocks where block.type != .recovery {
            if let index = sections.firstIndex(where: { $0.title == block.typeLabel }) {
                sections[index].blocks.append(block)
            } else {
                sections.append(WorkoutPreviewSection(title: block.typeLabel, blocks: [block]))
            }
        }

        return sections
    }

    private func loadPreview() async {
        loadState = .loading

        if WorkoutFallbackCatalog.isFallbackWorkoutID(workout.id) {
            session = WorkoutFallbackCatalog.session(for: workout)
            loadState = .offline
            return
        }

        do {
            session = try await client.fetchWorkout()
            loadState = .loaded
        } catch {
            session = WorkoutFallbackCatalog.session(for: workout)
            loadState = .offline
        }
    }
}

private struct WorkoutPreviewSection: Identifiable {
    let id = UUID()
    let title: String
    var blocks: [WorkoutSessionBlock]
}

private struct WorkoutPreviewSectionView: View {
    let section: WorkoutPreviewSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.ColorToken.secondaryText)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(section.blocks) { block in
                    Text(block.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.ColorToken.primaryText)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct WorkoutTypeRow: View {
    let option: WorkoutTypeOption

    var body: some View {
        AppCardRow {
            HStack(spacing: 16) {
                option.icon
                    .frame(width: 26, height: 26)

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(AppTheme.FontToken.cardTitle)
                        .foregroundStyle(AppTheme.ColorToken.primaryText)

                    Text(option.subtitle)
                        .font(AppTheme.FontToken.cardSubtitle)
                        .foregroundStyle(AppTheme.ColorToken.secondaryText)
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct WorkoutRow: View {
    let workout: WorkoutTemplateSummary

    var body: some View {
        AppCardRow {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(workout.title)
                        .font(AppTheme.FontToken.cardTitle)
                        .foregroundStyle(AppTheme.ColorToken.primaryText)
                        .lineLimit(2)

                    Text(workout.summary ?? "Guided workout with structured rounds and clear pacing.")
                        .font(AppTheme.FontToken.cardSubtitle)
                        .foregroundStyle(AppTheme.ColorToken.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(workout.durationLabel)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.ColorToken.primaryText)
                            .lineLimit(1)

                        Text(workout.difficultyLabel)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppTheme.ColorToken.accent)
                            .lineLimit(1)
                    }
                    .fixedSize(horizontal: true, vertical: false)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.ColorToken.secondaryText)
                }
            }
        }
    }
}

private struct AppCardRow<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .frame(minHeight: 78)
            .frame(maxWidth: .infinity)
            .background(AppTheme.ColorToken.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                    .stroke(AppTheme.ColorToken.cardStroke, lineWidth: 1)
            )
    }
}

private enum WorkoutTypeOption: CaseIterable, Identifiable {
    case boxing
    case run
    case strengthConditioning

    var id: Self { self }

    var discipline: WorkoutDiscipline {
        switch self {
        case .boxing: return .boxing
        case .run: return .running
        case .strengthConditioning: return .strengthConditioning
        }
    }

    var title: String {
        switch self {
        case .boxing: return "Boxing"
        case .run: return "Running"
        case .strengthConditioning: return "Strength & Conditioning"
        }
    }

    var subtitle: String {
        switch self {
        case .boxing: return "Bag work, skills, rounds, etc."
        case .run: return "Running, jogging, sprinting, etc."
        case .strengthConditioning: return "Machines, free weights, etc."
        }
    }

    @ViewBuilder
    var icon: some View {
        switch self {
        case .boxing:
            Image(systemName: "figure.boxing")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(AppTheme.ColorToken.accent)
        case .run:
            Image(systemName: "shoeprints.fill")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(AppTheme.ColorToken.accent)
        case .strengthConditioning:
            Image(systemName: "dumbbell")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.ColorToken.accent)
        }
    }
}

#Preview {
    WorkoutLibraryView()
}
