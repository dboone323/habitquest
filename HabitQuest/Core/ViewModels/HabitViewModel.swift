import Combine
import OSLog
import SwiftData
import SwiftUI

// Main ViewModel for managing habits using the MVVM pattern in HabitQuest.
// Provides separation of concerns, testable business logic, and enhanced state management.

// MVVM ViewModel for managing habit data, user actions, and state in HabitQuest.
@MainActor
public class HabitViewModel: ObservableObject {
    public struct State: Sendable {
        public var habits: [Habit] = []
        public var searchText: String = ""
        public var selectedCategory: HabitCategory?
        public var errorMessage: String?
        public var isLoading: Bool = false

        public init() {}
    }
    /// State struct representing the current UI state for habits.
    @Published public var state = State()
    /// Actions that can be performed on the HabitViewModel.
    public enum Action {
        /// Load all habits from the data store with pagination.
        case loadHabits(page: Int, limit: Int)
        /// Create a new habit with the given parameters.
        case createHabit(
            name: String, description: String, frequency: HabitFrequency, category: HabitCategory,
            difficulty: HabitDifficulty
        )
        /// Mark a habit as completed for today.
        case completeHabit(Habit)
        /// Delete a habit (soft delete).
        case deleteHabit(Habit)
        /// Set the search text for filtering habits.
        case setSearchText(String)
        /// Set the selected category for filtering habits.
        case setCategory(HabitCategory?)
        /// Undo the last action.
        case undo
        /// Redo the last undone action.
        case redo
    }

    private var modelContext: ModelContext?
    private var currentPage = 1
    private let pageSize = 20
    private var cancellables = Set<AnyCancellable>()
    private var history: [Action] = []
    private var index: Int = -1

    @Published public var isLoading: Bool = false

    private func undo() {
        // Implement undo logic or remove case
    }

    private func redo() {
        // Implement redo logic or remove case
    }

    private func calculateXPValue(for difficulty: HabitDifficulty, frequency: HabitFrequency) -> Int {
        // Simple XP calculation
        let multiplier: Int
        switch difficulty {
        case .easy: multiplier = 10
        case .medium: multiplier = 25
        case .hard: multiplier = 50
        }
        return multiplier
    }

    private func isCompletedThisWeek(_ habit: Habit) -> Bool {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return habit.logs.contains { $0.completionDate >= weekStart }
    }

    // MARK: - Initialization

    /// Initializes the HabitViewModel and loads all habits.
    public init() {
        handle(.loadHabits(page: currentPage, limit: pageSize))
    }

    /// Sets the model context for data access and reloads habits.
    /// - Parameter context: The SwiftData model context to use.
    func setModelContext(_ context: ModelContext) {
        modelContext = context
        handle(.loadHabits(page: currentPage, limit: pageSize))
    }

    // MARK: - Public Methods

    /// Handles actions dispatched to the ViewModel, updating state as needed.
    /// - Parameter action: The action to handle.
    public func handle(_ action: Action) {
        switch action {
        case let .loadHabits(page, limit):
            loadHabits(page: page, limit: limit)
        case let .createHabit(name, description, frequency, category, difficulty):
            createHabit(
                name: name, description: description, frequency: frequency, category: category,
                difficulty: difficulty
            )
        case let .completeHabit(habit):
            completeHabit(habit)
        case let .deleteHabit(habit):
            deleteHabit(habit)
        case let .setSearchText(text):
            state.searchText = text
        case let .setCategory(category):
            state.selectedCategory = category
        case .undo:
            undo()
        case .redo:
            redo()
        }
    }

    /// Loads all active habits from the data store and updates state.
    private func loadHabits(page: Int, limit: Int) {
        guard let context = modelContext else { return }
        isLoading = true
        Logger().info("Loading habits page \(page) with limit \(limit)")
        do {
            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate { $0.isActive },
                sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
            )
            state.habits = try context.fetch(descriptor)
            state.errorMessage = nil
        } catch {
            setError(AppError.dataError("Failed to load habits: \(error.localizedDescription)"))
        }
        isLoading = false
    }

    /// Creates a new habit and saves it to the data store.
    /// - Parameters:
    ///   - name: The name of the habit.
    ///   - description: The description of the habit.
    ///   - frequency: The frequency of the habit.
    ///   - category: The category of the habit.
    ///   - difficulty: The difficulty level of the habit.
    private func createHabit(
        name: String, description: String, frequency: HabitFrequency, category: HabitCategory,
        difficulty: HabitDifficulty
    ) {
        guard let context = modelContext else { return }
        os_log("Creating new habit with name %s and description %s", log: .default, type: .info, name, description)
        let xpValue = calculateXPValue(for: difficulty, frequency: frequency)
        let newHabit = Habit(
            name: name,
            habitDescription: description,
            frequency: frequency,
            xpValue: xpValue,
            category: category,
            difficulty: difficulty
        )
        context.insert(newHabit)
        do {
            try context.save()
            loadHabits(page: currentPage, limit: pageSize)
        } catch {
            setError(AppError.dataError("Failed to create habit: \(error.localizedDescription)"))
        }
    }

    /// Marks a habit as completed for today and updates streaks.
    /// - Parameter habit: The habit to mark as completed.
    private func completeHabit(_ habit: Habit) {
        guard let context = modelContext else { return }
        if habit.isCompletedToday { return }
        os_log("Completing habit with name %s", log: .default, type: .info, habit.name)
        let log = HabitLog(habit: habit, isCompleted: true)
        context.insert(log)
        updateStreak(for: habit)
        do {
            try context.save()
            loadHabits(page: currentPage, limit: pageSize)
        } catch {
            setError(AppError.dataError("Failed to complete habit: \(error.localizedDescription)"))
        }
    }

    /// Soft deletes a habit (marks as inactive).
    /// - Parameter habit: The habit to delete.
    private func deleteHabit(_ habit: Habit) {
        guard let context = modelContext else { return }
        os_log("Deleting habit with name %s", log: .default, type: .info, habit.name)
        habit.isActive = false
        do {
            try context.save()
            loadHabits(page: currentPage, limit: pageSize)
        } catch {
            setError(AppError.dataError("Failed to delete habit: \(error.localizedDescription)"))
        }
    }

    /// Returns the list of habits filtered by search text and selected category.
    var filteredHabits: [Habit] {
        os_log(
            "Filtering habits with search text %s and selected category %@",
            log: .default,
            type: .info,
            state.searchText ?? "",
            state.selectedCategory?.rawValue ?? ""
        )
        var filtered = state.habits
        if let category = state.selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        if !state.searchText.isEmpty {
            filtered = filtered.filter { habit in
                habit.name.localizedCaseInsensitiveContains(self.state.searchText)
                    || habit.habitDescription.localizedCaseInsensitiveContains(self.state.searchText)
            }
        }
        return filtered
    }

    /// Returns the list of habits that need to be completed today.
    var todaysHabits: [Habit] {
        os_log("Calculating today's habits", log: .default, type: .info)
        return state.habits.filter { habit in
            switch habit.frequency {
            case .daily:
                return true
            case .weekly:
                return isCompletedThisWeek(habit)
            case .monthly:
                return isCompletedThisMonth(habit)
            case .custom:
                return false
            }
        }
    }

    /// Returns the list of habits that need to be completed this month.
    private func isCompletedThisMonth(_ habit: Habit) -> Bool {
        os_log("Checking if habit with name %s was completed this month", log: .default, type: .info, habit.name)
        let calendar = Calendar.current
        let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()

        return habit.logs.contains { log in
            calendar.isDate(log.completionDate, equalTo: monthStart, toGranularity: .month)
        }
    }

    /// Sets the error message to display in the UI.
    /// - Parameter errorMessage: The error message to set.
    private func setError(_ error: AppError) {
        state.errorMessage = error.localizedDescription
    }

    /// Updates streaks for a given habit.
    /// - Parameter habit: The habit to update streaks for.
    private func updateStreak(for habit: Habit) {
        // Logic to update streaks
    }
}
