import Combine
import Foundation
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
public class TodaysQuestsViewModel: ObservableObject, BaseViewModel {
    // MARK: - State

    public struct State {
        var todaysHabits: [Habit] = []
        var showingAddQuest = false
        var showingCompletionAlert = false
        var completionMessage = ""
        var isLoading = false
        var errorMessage: String?
    }

    // MARK: - Actions

    public enum Action {
        case setModelContext(ModelContext)
        case loadTodaysHabits
        case completeHabit(Habit)
        case addNewHabit(Habit)
        case setShowingAddQuest(Bool)
        case dismissCompletionAlert
    }

    // MARK: - Properties

    @Published public var state = State()

    public var isLoading: Bool {
        get { state.isLoading }
        set { state.isLoading = newValue }
    }

    public var errorMessage: String? {
        get { state.errorMessage }
        set { state.errorMessage = newValue }
    }

    private var modelContext: ModelContext?

    // MARK: - BaseViewModel Protocol

    public func handle(_ action: Action) {
        switch action {
        case let .setModelContext(context):
            self.modelContext = context
            self.handle(.loadTodaysHabits)

        case .loadTodaysHabits:
            self.loadTodaysHabits()

        case let .completeHabit(habit):
            self.completeHabit(habit)

        case let .addNewHabit(habit):
            self.addNewHabit(habit)

        case let .setShowingAddQuest(showing):
            self.state.showingAddQuest = showing

        case .dismissCompletionAlert:
            self.state.showingCompletionAlert = false
            self.state.completionMessage = ""
        }
    }

    // MARK: - Private Methods

    /// Load habits that are due today based on their frequency
    private func loadTodaysHabits() {
        guard let context = modelContext else { return }

        let request = FetchDescriptor<Habit>()

        do {
            let allHabits = try context.fetch(request)
            self.state.todaysHabits = allHabits.filter { habit in
                self.isDueToday(habit)
            }
        } catch {
            print("Error loading habits: \(error)")
        }
    }

    /// Check if a habit is due today based on its frequency and last completion
    private func isDueToday(_: Habit) -> Bool {
        // For now, show all habits as due today
        true
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
        let earnedExperiencePoints = self.calculateXP(for: habit)
        self.awardXP(earnedExperiencePoints)

        // Show completion message
        self.state.completionMessage = "Quest completed! +\(earnedExperiencePoints) XP"
        self.state.showingCompletionAlert = true

        // Refresh today's habits
        self.handle(.loadTodaysHabits)

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
        habit.xpValue * habit.difficulty.xpMultiplier
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
            self.handle(.loadTodaysHabits)
        } catch {
            print("Error adding habit: \(error)")
        }
    }
}
