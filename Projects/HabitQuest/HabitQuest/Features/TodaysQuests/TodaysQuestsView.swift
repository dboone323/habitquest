import SwiftData
import SwiftUI

/// View displaying all habits that are due today
/// Users can see their daily/weekly quests and mark them as complete
public struct TodaysQuestsView: View {
    @StateObject private var viewModel = TodaysQuestsViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var habitAnalytics: [UUID: StreakAnalytics] = [:]
    @State private var streakService: StreakService?

    public var body: some View {
        NavigationView {
            VStack {
                if self.viewModel.todaysHabits.isEmpty {
                    EmptyStateView()
                } else {
                    QuestListView(
                        habits: self.viewModel.todaysHabits,
                        habitAnalytics: self.habitAnalytics,
                        onComplete: self.viewModel.completeHabit
                    )
                }
            }
            .navigationTitle("Today's Quests")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Quest") {
                        self.viewModel.showingAddQuest = true
                    }
                    .accessibilityLabel("Add Quest")
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Quest") {
                        self.viewModel.showingAddQuest = true
                    }
                    .accessibilityLabel("Add Quest")
                }
                #endif
            }
            .sheet(isPresented: self.$viewModel.showingAddQuest) {
                AddQuestView { habit in
                    self.viewModel.addNewHabit(habit)
                }
            }
            .alert("Quest Completed!", isPresented: self.$viewModel.showingCompletionAlert) {
                Button("Awesome!") {}
                    .accessibilityLabel("Awesome")
            } message: {
                Text(self.viewModel.completionMessage)
            }
            .onAppear {
                self.viewModel.setModelContext(self.modelContext)
                self.setupStreakService()
            }
            .task {
                await self.loadHabitAnalytics()
            }
        }
    }

    private func setupStreakService() {
        self.streakService = StreakService(modelContext: self.modelContext)
    }

    private func loadHabitAnalytics() async {
        guard let streakService else { return }

        var analytics: [UUID: StreakAnalytics] = [:]

        for habit in self.viewModel.todaysHabits {
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
        List(self.habits, id: \.id) { habit in
            QuestRowView(
                habit: habit,
                analytics: self.habitAnalytics[habit.id],
                onComplete: self.onComplete
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
                Text(self.habit.name)
                    .font(.headline)

                Text(self.habit.habitDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text("\(self.habit.xpValue) XP")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)

                    // Enhanced streak with analytics
                    if let analytics {
                        StreakVisualizationView(
                            habit: self.habit,
                            analytics: analytics,
                            displayMode: .compact
                        )
                    } else {
                        // Fallback streak display
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundColor(streakColor(for: self.habit.streak))
                            Text("\(self.habit.streak)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(streakColor(for: self.habit.streak))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(streakColor(for: self.habit.streak).opacity(0.15))
                        .cornerRadius(4)
                    }
                }
            }

            Spacer()

            Button {
                self.onComplete(self.habit)
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
                    TextField("Quest Name", text: self.$name).accessibilityLabel("Text Field")
                    TextField("Description", text: self.$description, axis: .vertical)
                        .accessibilityLabel("Text Field")
                        .lineLimit(3 ... 6)
                }

                Section("Settings") {
                    Picker("Frequency", selection: self.$frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }

                    Stepper("XP Value: \(self.xpValue)", value: self.$xpValue, in: 5 ... 50, step: 5)
                }
            }
            .navigationTitle("New Quest")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        self.dismiss()
                    }
                    .accessibilityLabel("Cancel")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let habit = Habit(
                            name: name,
                            habitDescription: description,
                            frequency: frequency,
                            xpValue: xpValue
                        )
                        self.onAdd(habit)
                        self.dismiss()
                    }
                    .accessibilityLabel("Add")
                    .disabled(self.name.isEmpty)
                }
                #else
                ToolbarItem {
                    Button("Cancel") {
                        self.dismiss()
                    }
                    .accessibilityLabel("Cancel")
                }

                ToolbarItem {
                    Button("Add") {
                        let habit = Habit(
                            name: name,
                            habitDescription: description,
                            frequency: frequency,
                            xpValue: xpValue
                        )
                        self.onAdd(habit)
                        self.dismiss()
                    }
                    .accessibilityLabel("Add")
                    .disabled(self.name.isEmpty)
                }
                #endif
            }
        }
    }
}

// MARK: - Helper Functions

/// Get color for streak based on count
private func streakColor(for streak: Int) -> Color {
    switch streak {
    case 0: .gray
    case 1 ... 6: .orange
    case 7 ... 29: .red
    case 30 ... 99: .purple
    case 100 ... 364: .blue
    default: .yellow
    }
}

#Preview {
    TodaysQuestsView()
}
