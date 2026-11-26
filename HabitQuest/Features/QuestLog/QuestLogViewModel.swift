import Combine
import HabitQuestCore
import SwiftData
import SwiftUI

/// ViewModel for QuestLogView handling all habit management operations
@MainActor
public class QuestLogViewModel: ObservableObject {
    @Published var allHabits: [Habit] = []
    @Published var showingAddQuest = false
    @Published var editingHabit: Habit?

    private var modelContext: ModelContext?
    private let logger = HabitQuestLogger(category: .uiCategory)
    private(set) var lastReminderTask: Task<Void, Never>?

    /// Sets the model context and loads all habits.
    func setModelContext(_ context: ModelContext) {
        modelContext = context
        loadAllHabits()
    }

    /// Loads all habits from SwiftData.
    func loadAllHabits() {
        guard let modelContext else { return }

        do {
            let fetchDescriptor = FetchDescriptor<Habit>()
            let fetchedHabits = try modelContext.fetch(fetchDescriptor)
            // Sort manually to avoid concurrency issues
            allHabits = fetchedHabits.sorted { $0.creationDate > $1.creationDate }
            logger.info("Loaded \(allHabits.count) habits")
        } catch {
            logger.error("Failed to load habits: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Adds a new habit and schedules notifications for it.
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

            // F1: Wire reminders
            Task {
                await HabitNotificationService.shared.scheduleSmartReminders(for: habit)
            }

            loadAllHabits()
            logger.info("Added new habit: \(habit.name)")
        } catch {
            logger.error("Failed to add habit: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Updates an existing habit, saves changes, and reschedules or cancels its notifications.
    func updateHabit(_ habit: Habit) {
        guard let modelContext else { return }

        do {
            // Validate habit input
            if let validationError = ErrorHandler.validateHabit(name: habit.name, description: habit.habitDescription) {
                ErrorHandler.handle(validationError, showToUser: true)
                return
            }

            try modelContext.save()

            lastReminderTask = Task {
                await HabitNotificationService.shared.rescheduleReminders(for: habit)
            }

            loadAllHabits()
            logger.info("Updated habit: \(habit.name)")
        } catch {
            logger.error("Failed to update habit: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Deletes a habit and all its associated data.
    func deleteHabit(_ habit: Habit) {
        guard let modelContext else { return }

        do {
            let habitId = habit.id
            modelContext.delete(habit)
            try modelContext.save()
            HabitNotificationService.shared.cancelNotifications(for: habitId)

            loadAllHabits()
            logger.info("Deleted habit: \(habit.name)")
        } catch {
            logger.error("Failed to delete habit: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Sets a habit for editing.
    func editHabit(_ habit: Habit) {
        editingHabit = habit
    }
}
