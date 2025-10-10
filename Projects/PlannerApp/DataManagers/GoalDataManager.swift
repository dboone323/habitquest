import Foundation

/// Protocol defining the interface for goal data management
protocol GoalDataManaging {
    func load() -> [Goal]
    func save(goals: [Goal])
    func add(_ goal: Goal)
    func update(_ goal: Goal)
    func delete(_ goal: Goal)
    func find(by id: UUID) -> Goal?
}

/// Legacy GoalDataManager - now delegates to PlannerDataManager for backward compatibility
/// This class is maintained for existing code that imports GoalDataManager directly
final class GoalDataManager: GoalDataManaging {
    /// Shared singleton instance - now delegates to PlannerDataManager
    static let shared = GoalDataManager()

    /// Delegate to the consolidated PlannerDataManager
    private let plannerDataManager = PlannerDataManager.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Loads all goals from PlannerDataManager.
    /// - Returns: Array of `Goal` objects.
    func load() -> [Goal] {
        return plannerDataManager.loadGoals()
    }

    /// Saves the provided goals using PlannerDataManager.
    /// - Parameter goals: Array of `Goal` objects to save.
    func save(goals: [Goal]) {
        plannerDataManager.saveGoals(goals)
    }

    /// Adds a new goal using PlannerDataManager.
    /// - Parameter goal: The `Goal` to add.
    func add(_ goal: Goal) {
        plannerDataManager.addGoal(goal)
    }

    /// Updates an existing goal using PlannerDataManager.
    /// - Parameter goal: The `Goal` to update.
    func update(_ goal: Goal) {
        plannerDataManager.updateGoal(goal)
    }

    /// Deletes a goal using PlannerDataManager.
    /// - Parameter goal: The `Goal` to delete.
    func delete(_ goal: Goal) {
        plannerDataManager.deleteGoal(goal)
    }

    /// Finds a goal by its ID using PlannerDataManager.
    /// - Parameter id: The UUID of the goal to find.
    /// - Returns: The `Goal` if found, otherwise nil.
    func find(by id: UUID) -> Goal? {
        return plannerDataManager.findGoal(by: id)
    }

    /// Gets goals filtered by completion status.
    /// - Parameter completed: Whether to get completed or incomplete goals.
    /// - Returns: Array of filtered goals.
    func goals(filteredByCompletion completed: Bool) -> [Goal] {
        return plannerDataManager.goalsFiltered(by: completed)
    }

    /// Gets goals due within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of goals due within the specified period.
    func goalsDue(within days: Int) -> [Goal] {
        return plannerDataManager.goalsDue(within: days)
    }

    /// Gets goals sorted by priority.
    /// - Returns: Array of goals sorted by priority (high to low).
    func goalsSortedByPriority() -> [Goal] {
        return plannerDataManager.goalsSortedByPriority()
    }

    /// Gets goals sorted by target date.
    /// - Returns: Array of goals sorted by target date (soonest first).
    func goalsSortedByDate() -> [Goal] {
        return plannerDataManager.goalsSortedByDate()
    }

    /// Clears all goals from storage.
    func clearAllGoals() {
        // Note: This only clears goals, not other data types
        plannerDataManager.saveGoals([])
    }

    /// Gets statistics about goals.
    /// - Returns: Dictionary with goal statistics.
    func getGoalStatistics() -> [String: Int] {
        return plannerDataManager.getGoalStatistics()
    }
}
