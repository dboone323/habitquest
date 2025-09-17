import Combine
import SwiftData
import SwiftUI

/// ViewModel for QuestLogView handling all habit management operations
@MainActor
class QuestLogViewModel: ObservableObject {
    @Published var allHabits: [Habit] = []
    @Published var showingAddQuest = false
    @Published var editingHabit: Habit?

    private var modelContext: ModelContext?
    private let logger = Logger(category: .uiCategory)

    /// Set the model context and load all habits
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        self.loadAllHabits()
    }

    /// Load all habits from SwiftData
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func loadAllHabits() {
        guard let modelContext else { return }

        do {
            let fetchDescriptor = FetchDescriptor<Habit>()
            let fetchedHabits = try modelContext.fetch(fetchDescriptor)
            // Sort manually to avoid concurrency issues
            self.allHabits = fetchedHabits.sorted { $0.creationDate > $1.creationDate }
            self.logger.info("Loaded \(self.allHabits.count) habits")

        } catch {
            self.logger.error("Failed to load habits: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Add a new habit to the system
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func addHabit(_ habit: Habit) {
        guard let modelContext else { return }

        do {
            // Validate habit input
            if let validationError = ErrorHandler.validateHabit(name: habit.name, description: habit.habitDescription) {
                ErrorHandler.handle(validationError, showToUser: true)
                return
            }

            modelContext.insert(habit)
            try modelContext.save()

            self.loadAllHabits()
            self.logger.info("Added new habit: \(habit.name)")

        } catch {
            self.logger.error("Failed to add habit: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Update an existing habit
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func updateHabit(_ habit: Habit) {
        guard let modelContext else { return }

        do {
            // Validate habit input
            if let validationError = ErrorHandler.validateHabit(name: habit.name, description: habit.habitDescription) {
                ErrorHandler.handle(validationError, showToUser: true)
                return
            }

            try modelContext.save()

            self.loadAllHabits()
            self.logger.info("Updated habit: \(habit.name)")

        } catch {
            self.logger.error("Failed to update habit: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Delete a habit and all its associated logs
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func deleteHabit(_ habit: Habit) {
        guard let modelContext else { return }

        do {
            modelContext.delete(habit)
            try modelContext.save()

            self.loadAllHabits()
            self.logger.info("Deleted habit: \(habit.name)")

        } catch {
            self.logger.error("Failed to delete habit: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Set a habit for editing
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func editHabit(_ habit: Habit) {
        self.editingHabit = habit
    }
}
