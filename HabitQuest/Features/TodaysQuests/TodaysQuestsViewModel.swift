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

    /// Complete a habit and award XP
    public func completeHabit(_ habit: Habit) {
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
