import Combine
import Foundation
import HabitQuestCore
import SwiftData

/// ViewModel managing today's quest display and completion logic
/// Handles filtering habits due today and managing completion flow
@MainActor
public class TodaysQuestsViewModel: ObservableObject {
    @Published var todaysHabits: [Habit] = []
    @Published var suggestions: [HabitSuggestion] = []
    @Published var showingAddQuest = false
    @Published var showingCompletionAlert = false
    @Published var completionMessage = ""

    private var modelContext: ModelContext?
    private let gamificationService = GamificationService()
    private var suggestionService: HabitSuggestionService?

    /// Set the model context for data operations
    public func setModelContext(_ context: ModelContext) {
        modelContext = context
        suggestionService = HabitSuggestionService(modelContext: context)
        loadTodaysHabits()
        loadSuggestions()
    }

    /// Load suggestions from the recommendation engine
    public func loadSuggestions() {
        guard let suggestionService else { return }
        Task { [weak self] in
            let items = await suggestionService.generateHabitSuggestions()
            await MainActor.run {
                self?.suggestions = items
            }
        }
    }

    /// Load habits that are due today based on their scheduled frequency
    private func loadTodaysHabits() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isActive }
        )

        do {
            let allHabits = try context.fetch(descriptor)

            // Auto-fill health habits if authorized
            HealthKitService.shared.autoFillHabits(allHabits, in: context)

            todaysHabits = allHabits.filter { habit in
                gamificationService.isHabitDueToday(habit)
            }
        } catch {
            print("Error loading habits: \(error)")
        }
    }

    /// Check if a habit has been completed today
    public func isHabitCompletedToday(_ habit: Habit) -> Bool {
        habit.logs.contains { Calendar.current.isDateInToday($0.completionDate) && $0.isCompleted }
    }

    /// Complete a habit and award XP (does nothing if already completed today)
    public func completeHabit(_ habit: Habit) {
        guard !isHabitCompletedToday(habit) else { return }
        guard let context = modelContext else { return }

        // Create a new log entry for this completion
        let newLog = HabitLog(habit: habit, completionDate: Date())
        context.insert(newLog)

        // Fetch player profile to update stats
        let profileDescriptor = FetchDescriptor<PlayerProfile>()
        let earnedXP: Int

        if let profile = (try? context.fetch(profileDescriptor))?.first {
            let result = gamificationService.processHabitCompletion(habit: habit, profile: profile)
            earnedXP = habit.xpValue * habit.difficulty.xpMultiplier

            // F2: Wire achievements
            let achievements = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
            let allHabits = (try? context.fetch(FetchDescriptor<Habit>())) ?? []
            let recentLogs = (try? context.fetch(FetchDescriptor<HabitLog>())) ?? []
            let newlyUnlocked = AchievementService.updateAchievementProgress(
                achievements: achievements,
                player: profile,
                habits: allHabits,
                recentLogs: recentLogs
            )

            if result.leveledUp {
                completionMessage = "LEVEL UP! Reached Level \(result.newLevel)! +\(earnedXP) XP"
            } else {
                completionMessage = "Quest completed! +\(earnedXP) XP"
            }

            if !newlyUnlocked.isEmpty {
                completionMessage += " 🏆 Unlocked \(newlyUnlocked.count) achievement(s)!"
            }
        } else {
            // Fallback if no profile exists
            earnedXP = habit.xpValue * habit.difficulty.xpMultiplier
            completionMessage = "Quest completed! +\(earnedXP) XP"
        }

        // F1: Wire reminders
        Task {
            await HabitNotificationService.shared.scheduleSmartReminders(for: habit)
        }

        showingCompletionAlert = true

        // Refresh today's habits
        loadTodaysHabits()

        // Save context
        do {
            try context.save()
        } catch {
            print("Error saving completion: \(error)")
        }
    }

    /// Uncomplete a habit for today and revert streak and XP awarded
    public func uncompleteHabit(_ habit: Habit) {
        guard let context = modelContext else { return }

        let todaysLogs = habit.logs.filter {
            Calendar.current.isDateInToday($0.completionDate) && $0.isCompleted
        }
        guard !todaysLogs.isEmpty else { return }

        var xpToRevert = 0
        for log in todaysLogs {
            xpToRevert += log.xpEarned > 0 ? log.xpEarned : (habit.xpValue * habit.difficulty.xpMultiplier)
            context.delete(log)
        }
        habit.logs.removeAll {
            Calendar.current.isDateInToday($0.completionDate) && $0.isCompleted
        }

        // Fetch player profile to revert XP and level
        let profileDescriptor = FetchDescriptor<PlayerProfile>()
        if let profile = (try? context.fetch(profileDescriptor))?.first {
            profile.currentXP = max(0, profile.currentXP - xpToRevert)

            // Recalculate level based on reverted XP
            var level = 1
            while profile.currentXP >= gamificationService.calculateXPForLevel(level + 1) {
                level += 1
            }
            profile.level = level
            profile.xpForNextLevel = gamificationService.calculateXPForNextLevel(forLevel: level)
        }

        // Revert habit streak
        let remainingCompletedLogs = habit.logs.filter(\.isCompleted)
        if remainingCompletedLogs.isEmpty {
            habit.streak = 0
        } else {
            gamificationService.updateHabitStreak(habit: habit)
        }

        showingCompletionAlert = false

        // Refresh today's habits
        loadTodaysHabits()

        // Save context
        do {
            try context.save()
        } catch {
            print("Error saving uncompletion: \(error)")
        }
    }

    /// Toggle habit completion status for today
    public func toggleHabitCompletion(_ habit: Habit) {
        if isHabitCompletedToday(habit) {
            uncompleteHabit(habit)
        } else {
            completeHabit(habit)
        }
    }

    /// Add a new habit
    public func addNewHabit(_ habit: Habit) {
        guard let context = modelContext else { return }

        context.insert(habit)

        // F1: Wire reminders
        Task {
            await HabitNotificationService.shared.scheduleSmartReminders(for: habit)
        }

        do {
            try context.save()
            loadTodaysHabits()
            loadSuggestions()
        } catch {
            print("Error adding habit: \(error)")
        }
    }
}
