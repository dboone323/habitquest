import Foundation
import Combine
import SwiftData
import SwiftUI

/// Main ViewModel for managing habits using the MVVM pattern in HabitQuest.
/// Provides separation of concerns, testable business logic, and enhanced state management.

/// MVVM ViewModel for managing habits with enhanced features and AI-Enhanced Architecture Implementation.

/// ViewModel for managing habit data, user actions, and state in HabitQuest.
@MainActor
@Observable
public class HabitViewModel: BaseViewModel {
    /// State struct representing the current UI state for habits.
    public struct State {
        /// The list of all loaded habits.
        var habits: [Habit] = []
        /// The currently selected category for filtering.
        var selectedCategory: HabitCategory?
        /// The current search text for filtering habits.
        var searchText: String = ""
    }

    /// Actions that can be performed on the HabitViewModel.
    public enum Action {
        /// Load all habits from the data store.
        case loadHabits
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
    }

    public var state = State()
    public var isLoading = false
    public var errorMessage: String?

    // MARK: - Private Properties

    private var modelContext: ModelContext?

    // MARK: - Initialization

    /// Initializes the HabitViewModel and loads all habits.
    public init() {
        self.handle(.loadHabits)
    }

    /// Sets the model context for data access and reloads habits.
    /// - Parameter context: The SwiftData model context to use.
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        self.handle(.loadHabits)
    }

    // MARK: - Public Methods

    /// Handles actions dispatched to the ViewModel, updating state as needed.
    /// - Parameter action: The action to handle.
    public func handle(_ action: Action) {
        Task {
            await self.handleAsync(action)
        }
    }

    private func handleAsync(_ action: Action) async {
        switch action {
        case .loadHabits:
            await self.loadHabits()
        case let .createHabit(name, description, frequency, category, difficulty):
            await self.createHabit(
                name: name, description: description, frequency: frequency, category: category,
                difficulty: difficulty
            )
        case let .completeHabit(habit):
            await self.completeHabit(habit)
        case let .deleteHabit(habit):
            await self.deleteHabit(habit)
        case let .setSearchText(text):
            self.state.searchText = text
        case let .setCategory(category):
            self.state.selectedCategory = category
        }
    }

    /// Loads all active habits from the data store and updates state.
    private func loadHabits() async {
        guard let context = modelContext else { return }
        self.isLoading = true
        self.errorMessage = nil
        do {
            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate { $0.isActive },
                sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
            )
            self.state.habits = try context.fetch(descriptor)
        } catch {
            setError(AppError.dataError("Failed to load habits: \(error.localizedDescription)"))
        }
        self.isLoading = false
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
    ) async {
        guard let context = modelContext else { return }
        let xpValue = self.calculateXPValue(for: difficulty, frequency: frequency)
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
            await self.loadHabits()
        } catch {
            setError(AppError.dataError("Failed to create habit: \(error.localizedDescription)"))
        }
    }

    /// Marks a habit as completed for today and updates streaks.
    /// - Parameter habit: The habit to mark as completed.
    private func completeHabit(_ habit: Habit) async {
        guard let context = modelContext else { return }
        if habit.isCompletedToday { return }
        let log = HabitLog(habit: habit, isCompleted: true)
        context.insert(log)
        self.updateStreak(for: habit)
        do {
            try context.save()
            await self.loadHabits()
        } catch {
            setError(AppError.dataError("Failed to complete habit: \(error.localizedDescription)"))
        }
    }

    /// Soft deletes a habit (marks as inactive).
    /// - Parameter habit: The habit to delete.
    private func deleteHabit(_ habit: Habit) async {
        guard let context = modelContext else { return }
        habit.isActive = false
        do {
            try context.save()
            await self.loadHabits()
        } catch {
            setError(AppError.dataError("Failed to delete habit: \(error.localizedDescription)"))
        }
    }

    /// Returns the list of habits filtered by search text and selected category.
    var filteredHabits: [Habit] {
        var filtered = self.state.habits
        if let category = state.selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        if !self.state.searchText.isEmpty {
            filtered = filtered.filter { habit in
                habit.name.localizedCaseInsensitiveContains(self.state.searchText)
                    || habit.habitDescription.localizedCaseInsensitiveContains(self.state.searchText)
            }
        }
        return filtered
    }

    /// Returns the list of habits that need to be completed today.
    var todaysHabits: [Habit] {
        self.state.habits.filter { habit in
            switch habit.frequency {
            case .daily:
                !habit.isCompletedToday
            case .weekly:
                !self.isCompletedThisWeek(habit)
            case .custom:
                !habit.isCompletedToday
            }
        }
    }

    /// Calculates the total XP earned today from completed habits.
    var todaysXP: Int {
        let today = Date()
        let calendar = Calendar.current
        return self.state.habits.compactMap { habit in
            habit.logs.filter { log in
                calendar.isDate(log.completionDate, inSameDayAs: today) && log.isCompleted
            }.first?.habit?.xpValue
        }.reduce(0, +)
    }

    // MARK: - Private Methods

    /// Calculates the XP value for a habit based on its difficulty and frequency.
    /// - Parameters:
    ///   - difficulty: The difficulty of the habit.
    ///   - frequency: The frequency of the habit.
    /// - Returns: The calculated XP value.
    private func calculateXPValue(for difficulty: HabitDifficulty, frequency: HabitFrequency) -> Int {
        let baseXP = switch frequency {
        case .daily: 10
        case .weekly: 50
        case .custom: 25
        }

        return baseXP * difficulty.xpMultiplier
    }

    /// Updates the streak count for a habit based on completion history.
    /// - Parameter habit: The habit to update the streak for.
    private func updateStreak(for habit: Habit) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let wasCompletedYesterday = habit.logs.contains { log in
            Calendar.current.isDate(log.completionDate, inSameDayAs: yesterday) && log.isCompleted
        }

        if wasCompletedYesterday || habit.streak == 0 {
            habit.streak += 1
        } else {
            habit.streak = 1 // Reset streak if there was a gap
        }
    }

    /// Checks if a habit has been completed this week.
    /// - Parameter habit: The habit to check.
    /// - Returns: True if completed this week, false otherwise.
    private func isCompletedThisWeek(_ habit: Habit) -> Bool {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()

        return habit.logs.contains { log in
            log.completionDate >= weekStart && log.isCompleted
        }
    }
}
