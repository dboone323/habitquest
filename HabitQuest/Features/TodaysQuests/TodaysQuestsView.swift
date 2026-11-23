import HabitQuestCore
import SwiftData
import SwiftUI
#if os(iOS)
import AudioToolbox
import UIKit
#endif

/// View displaying all habits that are due today
/// Users can see their daily/weekly quests and mark them as complete
public struct TodaysQuestsView: View {
    @StateObject private var viewModel = TodaysQuestsViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var habitAnalytics: [UUID: StreakAnalytics] = [:]
    @State private var streakService: StreakService?
    @State private var celebrationTrigger = false
    @State private var celebrationXP = 0
    @State private var celebrationTitle = ""
    @State private var celebrationExtraMessage: String? = nil

    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.todaysHabits.isEmpty {
                    EmptyStateView()
                } else {
                    QuestListView(
                        habits: viewModel.todaysHabits,
                        habitAnalytics: habitAnalytics,
                        isHabitCompleted: viewModel.isHabitCompletedToday,
                        onComplete: { habit in
                            let wasCompleted = viewModel.isHabitCompletedToday(habit)
                            viewModel.toggleHabitCompletion(habit)
                            if !wasCompleted {
                                triggerCelebration(for: habit)
                            }
                            Task {
                                await loadHabitAnalytics()
                            }
                        }
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
                        .accessibilityLabel("Add Quest")
                    }
                #else
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add Quest") {
                            viewModel.showingAddQuest = true
                        }
                        .accessibilityLabel("Add Quest")
                    }
                #endif
            }
            .sheet(isPresented: $viewModel.showingAddQuest) {
                AddQuestView(suggestions: viewModel.suggestions) { habit in
                    viewModel.addNewHabit(habit)
                }
            }
            .overlay {
                if celebrationTrigger {
                    ZStack(alignment: .top) {
                        ParticleEffectView(effectType: .confetti, trigger: celebrationTrigger)
                            .allowsHitTesting(false)
                            .zIndex(1)

                        VStack(spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                    .font(.title3)
                                Text("+\(celebrationXP) XP")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                            }
                            Text("\(celebrationTitle) Completed!")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.95))

                            if let extra = celebrationExtraMessage, !extra.isEmpty {
                                Text(extra)
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.yellow)
                                    .multilineTextAlignment(.center)
                                    .accessibilityIdentifier("CelebrationExtraMessage")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.purple.opacity(0.4), radius: 10, y: 5)
                        )
                        .padding(.top, 16)
                        .zIndex(2)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity).combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                        .accessibilityIdentifier("CelebrationPopover")
                    }
                    .allowsHitTesting(false)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: celebrationTrigger)
            .onAppear {
                viewModel.setModelContext(modelContext)
                setupStreakService()
            }
            .task {
                await loadHabitAnalytics()
            }
        }
    }

    private func triggerCelebration(for habit: Habit) {
        celebrationXP = habit.xpValue * habit.difficulty.xpMultiplier
        celebrationTitle = habit.name

        // Issue #83: Surface level-up and achievement message in the popover if present
        let msg = viewModel.completionMessage
        if msg.contains("LEVEL UP!") || msg.contains("🏆") {
            var extraParts: [String] = []
            if let levelUpRange = msg.range(of: "LEVEL UP![^!]+!", options: .regularExpression) {
                extraParts.append(String(msg[levelUpRange]))
            } else if msg.contains("LEVEL UP!") {
                extraParts.append("LEVEL UP!")
            }
            if let trophyRange = msg.range(of: "🏆[^\n]+", options: .regularExpression) {
                extraParts.append(String(msg[trophyRange]).trimmingCharacters(in: .whitespaces))
            }
            celebrationExtraMessage = extraParts.isEmpty ? msg : extraParts.joined(separator: " • ")
        } else {
            celebrationExtraMessage = nil
        }

        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            AudioServicesPlaySystemSound(1057)
        #endif

        celebrationTrigger = true

        Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            await MainActor.run {
                celebrationTrigger = false
            }
        }
    }

    private func setupStreakService() {
        streakService = StreakService(modelContext: modelContext)
    }

    private func loadHabitAnalytics() async {
        guard let streakService else { return }

        let profileDescriptor = FetchDescriptor<PlayerProfile>()
        let profile = try? modelContext.fetch(profileDescriptor).first

        var analytics: [UUID: StreakAnalytics] = [:]

        for habit in viewModel.todaysHabits {
            let habitAnalytics = await streakService.getStreakAnalytics(for: habit, profile: profile)
            analytics[habit.id] = habitAnalytics
        }

        await MainActor.run {
            habitAnalytics = analytics
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
    let isHabitCompleted: (Habit) -> Bool
    let onComplete: (Habit) -> Void

    var body: some View {
        List(habits, id: \.id) { habit in
            QuestRowView(
                habit: habit,
                analytics: habitAnalytics[habit.id],
                isCompleted: isHabitCompleted(habit),
                onComplete: onComplete
            )
        }
    }
}

/// Individual quest row with completion action
private struct QuestRowView: View {
    let habit: Habit
    let analytics: StreakAnalytics?
    let isCompleted: Bool
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
                    if let analytics {
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
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : .secondary)
            }
            .accessibilityLabel(isCompleted ? "Mark incomplete" : "Mark complete")
        }
        .padding(.vertical, 4)
    }
}

/// Simple add quest view (placeholder implementation)
private struct AddQuestView: View {
    let suggestions: [HabitSuggestion]
    let onAdd: (Habit) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var frequency = HabitFrequency.daily
    @State private var xpValue = 10

    var body: some View {
        NavigationView {
            Form {
                if !suggestions.isEmpty {
                    Section("Suggestions") {
                        ForEach(suggestions, id: \.id) { suggestion in
                            Button {
                                name = suggestion.name
                                description = suggestion.description
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.name)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    Text(suggestion.reasoning)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                Section("Quest Details") {
                    TextField("Quest Name", text: $name).accessibilityLabel("Text Field")
                    TextField("Description", text: $description, axis: .vertical)
                        .accessibilityLabel("Text Field")
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
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .accessibilityLabel("Cancel")
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let habit = Habit(
                                name: name,
                                habitDescription: description,
                                frequency: frequency,
                                xpValue: xpValue
                            )
                            onAdd(habit)
                            dismiss()
                        }
                        .accessibilityLabel("Add")
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
    case 0: .gray
    case 1...6: .orange
    case 7...29: .red
    case 30...99: .purple
    case 100...364: .blue
    default: .yellow
    }
}

#Preview {
    TodaysQuestsView()
}
