import SwiftUI

struct WorkoutLibraryView: View {
    @State private var selectedDiscipline: WorkoutDiscipline = .all
    @State private var loadState = WorkoutLibraryLoadState.loading
    @State private var workouts: [WorkoutTemplateSummary] = []

    private let client = WorkoutLibrarySupabaseClient()

    private var filteredWorkouts: [WorkoutTemplateSummary] {
        guard selectedDiscipline != .all else { return workouts }
        return workouts.filter { $0.discipline == selectedDiscipline }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    disciplinePicker

                    if loadState == .offline {
                        offlineNotice
                    }

                    LazyVStack(spacing: 14) {
                        ForEach(filteredWorkouts) { workout in
                            NavigationLink {
                                WorkoutSessionView(workout: workout)
                            } label: {
                                WorkoutCard(workout: workout)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(24)
            }
            .background(Color.systemBackground.ignoresSafeArea())
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadWorkouts()
            }
            .refreshable {
                await loadWorkouts()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Boxing Companion")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.4)

            Text("Choose today’s training")
                .font(.system(size: 36, weight: .bold, design: .default))
                .fontWidth(.condensed)
                .foregroundStyle(.primary)

            Text("Boxing, roadwork, and S&C sessions built to support better boxing. No random fitness-app soup.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var disciplinePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach([WorkoutDiscipline.all, .boxing, .running, .strengthConditioning, .hybrid], id: \.self) { discipline in
                    Button {
                        selectedDiscipline = discipline
                    } label: {
                        HStack(spacing: 6) {
                            Text(discipline.accentEmoji)
                            Text(discipline.title)
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(selectedDiscipline == discipline ? Color.primary : Color.secondary.opacity(0.12))
                        )
                        .foregroundStyle(selectedDiscipline == discipline ? Color.systemBackground : Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var offlineNotice: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Showing fallback workouts")
                .font(.headline)
            Text("Supabase did not load, so the app is using bundled starter sessions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func loadWorkouts() async {
        loadState = .loading

        do {
            let fetchedWorkouts = try await client.fetchPublishedWorkouts()
            workouts = fetchedWorkouts.isEmpty ? WorkoutTemplateSummary.fallbackWorkouts : fetchedWorkouts
            loadState = .loaded
        } catch {
            workouts = WorkoutTemplateSummary.fallbackWorkouts
            loadState = .offline
        }
    }
}

private struct WorkoutCard: View {
    let workout: WorkoutTemplateSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(workout.discipline.accentEmoji)
                    .font(.system(size: 30))
                    .frame(width: 48, height: 48)
                    .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text("\(workout.disciplineTitle) • \(workout.durationLabel) • \(workout.difficultyLabel)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)
            }

            if let summary = workout.summary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }

            HStack(spacing: 8) {
                if let primaryCategoryLabel = workout.primaryCategoryLabel {
                    WorkoutPill(title: primaryCategoryLabel)
                }

                if let firstEquipment = workout.equipment.first {
                    WorkoutPill(title: firstEquipment.replacingOccurrences(of: "_", with: " ").capitalized)
                }

                Spacer()

                Text("START")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.primary)
            }
        }
        .padding(18)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct WorkoutPill: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.12), in: Capsule(style: .continuous))
            .foregroundStyle(.secondary)
    }
}

private enum WorkoutLibraryLoadState {
    case loading
    case loaded
    case offline
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
    WorkoutLibraryView()
}
