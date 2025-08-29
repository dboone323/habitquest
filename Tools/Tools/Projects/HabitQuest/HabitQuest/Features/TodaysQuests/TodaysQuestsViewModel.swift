import Foundation
import Combine
import SwiftData

//
//  TodaysQuestsViewModel.swift
//  HabitQuest
//
//  Created by Daniel Stevens on 6/27/25.
//

/// ViewModel managing today's quest display and completion logic
/// Handles filtering habits due today and managing completion flow
@MainActor
class TodaysQuestsViewModel: ObservableObject {
    @Published var todaysHabits: [Habit] = []
    @Published var showingAddQuest = false
    @Published var showingCompletionAlert = false
    @Published var completionMessage = ""

    private var modelContext: ModelContext?

    /// Set the model context for data operations
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTodaysHabits()
    }

    /// Load habits that are due today based on their frequency
    private func loadTodaysHabits() {
        guard let context = modelContext else { return }

        let request = FetchDescriptor<Habit>()

        do {
            let allHabits = try context.fetch(request)
            todaysHabits = allHabits.filter { habit in
                isDueToday(habit)
            }
        } catch {
            print("Error loading habits: \(error)")
        }
    }

    /// Check if a habit is due today based on its frequency and last completion
    private func isDueToday(_ habit: Habit) -> Bool {
        // For now, show all habits as due today
        return true
    }

    /// Complete a habit and award XP
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func completeHabit(_ habit: Habit) {
        guard let context = modelContext else { return }

        // Create a new log entry for this completion
        let newLog = HabitLog(habit: habit, completionDate: Date())
        context.insert(newLog)

    // Award XP to the player
    let earnedExperiencePoints = calculateXP(for: habit)
    awardXP(earnedExperiencePoints)

        // Show completion message
        completionMessage = "Quest completed! +\(earnedXP) XP"
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

    /// Calculate XP for completing a habit
    private func calculateXP(for habit: Habit) -> Int {
        // XP earned factoring in difficulty multiplier
        return habit.xpValue * habit.difficulty.xpMultiplier
    }

    /// Award XP to the player profile
    private func awardXP(_ experiencePoints: Int) {
        guard let context = modelContext else { return }

        let request = FetchDescriptor<PlayerProfile>()

        do {
            let profiles = try context.fetch(request)
            let profile = profiles.first ?? {
                let newProfile = PlayerProfile()
                context.insert(newProfile)
                return newProfile
            }()

            // Directly modify currentXP since addXP method might not exist yet
            profile.currentXP += experiencePoints
            try context.save()
        } catch {
            print("Error awarding XP: \(error)")
        }
    }

    /// Add a new habit
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func addNewHabit(_ habit: Habit) {
        guard let context = modelContext else { return }

        context.insert(habit)

        do {
            try context.save()
            loadTodaysHabits()
        } catch {
            print("Error adding habit: \(error)")
        }
    }
}
