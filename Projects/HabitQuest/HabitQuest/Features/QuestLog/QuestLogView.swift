import SwiftData
import SwiftUI

/// View displaying all user habits with management capabilities
/// Users can view, add, edit, and delete their quests from this central location
public struct QuestLogView: View {
    @StateObject private var viewModel = QuestLogViewModel()
    @Environment(\.modelContext) private var modelContext

    public var body: some View {
        NavigationView {
            VStack {
                if self.viewModel.allHabits.isEmpty {
                    EmptyQuestLogView()
                } else {
                    QuestListView(
                        habits: self.viewModel.allHabits,
                        onDelete: self.viewModel.deleteHabit,
                        onEdit: self.viewModel.editHabit
                    )
                }
            }
            .navigationTitle("Quest Log")
            .toolbar(content: {
                                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Filter functionality would go here
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filter Button")
                }
                #else
                ToolbarItem {
                    Button("Filter") {
                        // Filter functionality would go here
                    }
                    .accessibilityLabel("Filter Button")
                }
                #endif
            })
            .sheet(isPresented: self.$viewModel.showingAddQuest) {
                AddEditQuestView(
                    habit: nil,
                    onSave: self.viewModel.addHabit
                )
            }
            .sheet(item: self.$viewModel.editingHabit) { habit in
                AddEditQuestView(
                    habit: habit,
                    onSave: self.viewModel.updateHabit
                )
            }
            .onAppear {
                self.viewModel.setModelContext(self.modelContext)
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
            ForEach(self.habits, id: \.id) { habit in
                QuestLogRowView(
                    habit: habit,
                    onEdit: self.onEdit
                )
            }
            .onDelete { indexSet in
                for index in indexSet {
                    self.onDelete(self.habits[index])
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
                Text(self.habit.name)
                    .font(.headline)

                Text(self.habit.habitDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    QuestStatChip(
                        icon: "star.fill",
                        text: "\(self.habit.xpValue) XP",
                        color: .blue
                    )

                    QuestStatChip(
                        icon: "flame.fill",
                        text: "\(self.habit.streak)",
                        color: .orange
                    )

                    QuestStatChip(
                        icon: "calendar",
                        text: self.habit.frequency.displayName,
                        color: .green
                    )

                    QuestStatChip(
                        icon: "checkmark.circle",
                        text: "\(self.habit.logs.count)",
                        color: .purple
                    )
                }
            }

            Spacer()

            Button {
                self.onEdit(self.habit)
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
            Image(systemName: self.icon)
                .font(.caption)
            Text(self.text)
                .font(.caption)
        }
        .foregroundColor(self.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(self.color.opacity(0.15))
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
        self.habit != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Quest Details") {
                    TextField("Quest Name", text: self.$name).accessibilityLabel("Text Field")
                    TextField("Description", text: self.$description, axis: .vertical)
                        .accessibilityLabel("Text Field")
                        .lineLimit(3 ... 6)
                }

                Section("Quest Settings") {
                    Picker("Frequency", selection: self.$frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }

                    Stepper("XP Reward: \(self.xpValue)", value: self.$xpValue, in: 5 ... 100, step: 5)
                }

                if self.isEditing, let habit {
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
            .navigationTitle(self.isEditing ? "Edit Quest" : "New Quest")
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
                    Button(self.isEditing ? "Save" : "Add") {
                        self.saveQuest()
                    }
                    .accessibilityLabel(self.isEditing ? "Save" : "Add")
                    .disabled(self.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #else
                ToolbarItem {
                    Button("Cancel") {
                        self.dismiss()
                    }
                    .accessibilityLabel("Cancel")
                }

                ToolbarItem {
                    Button(self.isEditing ? "Save" : "Add") {
                        self.saveQuest()
                    }
                    .accessibilityLabel(self.isEditing ? "Save" : "Add")
                    .disabled(self.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #endif
            }
        }
    }

    private func saveQuest() {
        if let existingHabit = habit {
            // Update existing habit
            existingHabit.name = self.name
            existingHabit.habitDescription = self.description
            existingHabit.frequency = self.frequency
            existingHabit.xpValue = self.xpValue
            self.onSave(existingHabit)
        } else {
            // Create new habit
            let newHabit = Habit(
                name: name,
                habitDescription: description,
                frequency: frequency,
                xpValue: xpValue
            )
            self.onSave(newHabit)
        }

        self.dismiss()
    }
}

#Preview {
    QuestLogView()
}
