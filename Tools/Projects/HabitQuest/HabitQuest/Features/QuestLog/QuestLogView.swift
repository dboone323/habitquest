import SwiftData
import SwiftUI

/// View displaying all user habits with management capabilities
/// Users can view, add, edit, and delete their quests from this central location
struct QuestLogView: View {
    @StateObject private var viewModel = QuestLogViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.allHabits.isEmpty {
                    EmptyQuestLogView()
                } else {
                    QuestListView(
                        habits: viewModel.allHabits,
                        onDelete: viewModel.deleteHabit,
                        onEdit: viewModel.editHabit
                    )
                }
            }
            .navigationTitle("Quest Log")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Filter") {
                        viewModel.showingAddQuest = true
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Filter") {
                        viewModel.showingFilterOptions = true
                    }
                }
                #endif
            }
            .sheet(isPresented: $viewModel.showingAddQuest) {
                AddEditQuestView(
                    habit: nil,
                    onSave: viewModel.addHabit
                )
            }
            .sheet(item: $viewModel.editingHabit) { habit in
                AddEditQuestView(
                    habit: habit,
                    onSave: viewModel.updateHabit
                )
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }
}

/// Empty state when no quests exist
private struct EmptyQuestLogView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Quests in Your Log")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start your journey by adding your first habit quest")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

/// List of all quests with management options
private struct QuestListView: View {
    let habits: [Habit]
    let onDelete: (Habit) -> Void
    let onEdit: (Habit) -> Void

    var body: some View {
        List {
            ForEach(habits, id: \.id) { habit in
                QuestLogRowView(
                    habit: habit,
                    onEdit: onEdit
                )
            }
            .onDelete { indexSet in
                for index in indexSet {
                    onDelete(habits[index])
                }
            }
        }
    }
}

/// Individual quest row in the log
private struct QuestLogRowView: View {
    let habit: Habit
    let onEdit: (Habit) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.name)
                    .font(.headline)

                Text(habit.habitDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    QuestStatChip(
                        icon: "star.fill",
                        text: "\(habit.xpValue) XP",
                        color: .blue
                    )

                    QuestStatChip(
                        icon: "flame.fill",
                        text: "\(habit.streak)",
                        color: .orange
                    )

                    QuestStatChip(
                        icon: "calendar",
                        text: habit.frequency.displayName,
                        color: .green
                    )

                    QuestStatChip(
                        icon: "checkmark.circle",
                        text: "\(habit.logs.count)",
                        color: .purple
                    )
                }
            }

            Spacer()

            Button {
                onEdit(habit)
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Small stat chip component
private struct QuestStatChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.15))
        .cornerRadius(4)
    }
}

/// Add/Edit quest form view
private struct AddEditQuestView: View {
    let habit: Habit?
    let onSave: (Habit) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var description: String
    @State private var frequency: HabitFrequency
    @State private var xpValue: Int

    init(habit: Habit?, onSave: @escaping (Habit) -> Void) {
        self.habit = habit
        self.onSave = onSave

        _name = State(initialValue: habit?.name ?? "")
        _description = State(initialValue: habit?.habitDescription ?? "")
        _frequency = State(initialValue: habit?.frequency ?? .daily)
        _xpValue = State(initialValue: habit?.xpValue ?? 10)
    }

    var isEditing: Bool {
        habit != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Quest Details") {
                    TextField("Quest Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Quest Settings") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }

                    Stepper("XP Reward: \(xpValue)", value: $xpValue, in: 5...100, step: 5)
                }

                if isEditing, let habit = habit {
                    Section("Quest Stats") {
                        HStack {
                            Text("Current Streak")
                            Spacer()
                            Text("\(habit.streak)")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Total Completions")
                            Spacer()
                            Text("\(habit.logs.count)")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Created")
                            Spacer()
                            Text(habit.creationDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Quest" : "New Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        saveQuest()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveQuest() {
        if let existingHabit = habit {
            // Update existing habit
            existingHabit.name = name
            existingHabit.habitDescription = description
            existingHabit.frequency = frequency
            existingHabit.xpValue = xpValue
            onSave(existingHabit)
        } else {
            // Create new habit
            let newHabit = Habit(
                name: name,
                habitDescription: description,
                frequency: frequency,
                xpValue: xpValue
            )
            onSave(newHabit)
        }

        dismiss()
    }
}

#Preview {
    QuestLogView()
}
