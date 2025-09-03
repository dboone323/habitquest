import SwiftData
import SwiftUI

/// View displaying all habits that are due today
/// Users can see their daily/weekly quests and mark them as complete
struct TodaysQuestsView: View {
    @StateObject private var viewModel = TodaysQuestsViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var habitAnalytics: [UUID: StreakAnalytics] = [:]
    @State private var streakService: StreakService?

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.todaysHabits.isEmpty {
                    EmptyStateView()
                } else {
                    QuestListView(
                        habits: viewModel.todaysHabits,
                        habitAnalytics: habitAnalytics,
                        onComplete: viewModel.completeHabit
                    )
                }
            }
            .navigationTitle("Today's Quests")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Quest") {
                        viewModel.showingAddQuest = true
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Quest") {
                        viewModel.showingAddQuest = true
                    }
                }
                #endif
            }
            .sheet(isPresented: $viewModel.showingAddQuest) {
                AddQuestView { habit in
                    viewModel.addNewHabit(habit)
                }
            }
            .alert("Quest Completed!", isPresented: $viewModel.showingCompletionAlert) {
                Button("Awesome!") { }
            } message: {
                Text(viewModel.completionMessage)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                setupStreakService()
            }
            .task {
                await loadHabitAnalytics()
            }
        }
    }

    private func setupStreakService() {
        streakService = StreakService(modelContext: modelContext)
    }

    private func loadHabitAnalytics() async {
        guard let streakService = streakService else { return }

        var analytics: [UUID: StreakAnalytics] = [:]

        for habit in viewModel.todaysHabits {
            let habitAnalytics = await streakService.getStreakAnalytics(for: habit)
            analytics[habit.id] = habitAnalytics
        }

        await MainActor.run {
            self.habitAnalytics = analytics
        }
    }
}

/// Empty state when no quests are available
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Quests Today!")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add your first habit to start your adventure")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

/// List of today's available quests
private struct QuestListView: View {
    let habits: [Habit]
    let habitAnalytics: [UUID: StreakAnalytics]
    let onComplete: (Habit) -> Void

    var body: some View {
        List(habits, id: \.id) { habit in
            QuestRowView(
                habit: habit,
                analytics: habitAnalytics[habit.id],
                onComplete: onComplete
            )
        }
    }
}

/// Individual quest row with completion action
private struct QuestRowView: View {
    let habit: Habit
    let analytics: StreakAnalytics?
    let onComplete: (Habit) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)

                Text(habit.habitDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text("\(habit.xpValue) XP")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)

                    // Enhanced streak with analytics
                    if let analytics = analytics {
                        StreakVisualizationView(
                            habit: habit,
                            analytics: analytics,
                            displayMode: .compact
                        )
                    } else {
                        // Fallback streak display
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundColor(streakColor(for: habit.streak))
                            Text("\(habit.streak)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(streakColor(for: habit.streak))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(streakColor(for: habit.streak).opacity(0.15))
                        .cornerRadius(4)
                    }
                }
            }

            Spacer()

            Button {
                onComplete(habit)
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Simple add quest view (placeholder implementation)
private struct AddQuestView: View {
    let onAdd: (Habit) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var frequency = HabitFrequency.daily
    @State private var xpValue = 10

    var body: some View {
        NavigationView {
            Form {
                Section("Quest Details") {
                    TextField("Quest Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Settings") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }

                    Stepper("XP Value: \(xpValue)", value: $xpValue, in: 5...50, step: 5)
                }
            }
            .navigationTitle("New Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let habit = Habit(name: name, habitDescription: description, frequency: frequency, xpValue: xpValue)
                        onAdd(habit)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Helper Functions

/// Get color for streak based on count
private func streakColor(for streak: Int) -> Color {
    switch streak {
    case 0: return .gray
    case 1...6: return .orange
    case 7...29: return .red
    case 30...99: return .purple
    case 100...364: return .blue
    default: return .yellow
    }
}

#Preview {
    TodaysQuestsView()
}
