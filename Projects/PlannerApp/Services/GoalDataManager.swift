import Foundation

/// Protocol defining the interface for goal data management
@MainActor
protocol GoalDataManaging {
    func load() -> [Goal]
    func save(goals: [Goal])
    func add(_ goal: Goal)
    func update(_ goal: Goal)
    func delete(_ goal: Goal)
    func find(by id: UUID) -> Goal?
}

/// Legacy GoalDataManager - now delegates to CloudKitManager for backward compatibility
/// This class is maintained for existing code that imports GoalDataManager directly
@MainActor
final class GoalDataManager: GoalDataManaging {
    /// Shared singleton instance - now delegates to CloudKitManager
    static let shared = GoalDataManager()

    /// Delegate to the consolidated CloudKitManager
    private let cloudKitManager = CloudKitManager.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Loads all goals from CloudKitManager.
    /// - Returns: Array of `Goal` objects.
    func load() -> [Goal] {
        return cloudKitManager.loadGoals()
    }

    /// Saves the provided goals using CloudKitManager.
    /// - Parameter goals: Array of `Goal` objects to save.
    func save(goals: [Goal]) {
        cloudKitManager.saveGoals(goals)
    }

    /// Adds a new goal using CloudKitManager.
    /// - Parameter goal: The `Goal` to add.
    func add(_ goal: Goal) {
        cloudKitManager.addGoal(goal)
    }

    /// Updates an existing goal using CloudKitManager.
    /// - Parameter goal: The `Goal` to update.
    func update(_ goal: Goal) {
        cloudKitManager.updateGoal(goal)
    }

    /// Deletes a goal using CloudKitManager.
    /// - Parameter goal: The `Goal` to delete.
    func delete(_ goal: Goal) {
        cloudKitManager.deleteGoal(goal)
    }

    /// Finds a goal by its ID using CloudKitManager.
    /// - Parameter id: The UUID of the goal to find.
    /// - Returns: The `Goal` if found, otherwise nil.
    func find(by id: UUID) -> Goal? {
        return cloudKitManager.findGoal(by: id)
    }

    /// Gets goals filtered by completion status.
    /// - Parameter completed: Whether to get completed or incomplete goals.
    /// - Returns: Array of filtered goals.
    func goals(filteredByCompletion completed: Bool) -> [Goal] {
        return cloudKitManager.goals.filter { $0.isCompleted == completed }
    }

    /// Gets goals due within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of goals due within the specified period.
    func goalsDue(within days: Int) -> [Goal] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return cloudKitManager.goals.filter { $0.targetDate <= futureDate && !$0.isCompleted }
    }

    /// Gets goals sorted by priority.
    /// - Returns: Array of goals sorted by priority (high to low).
    func goalsSortedByPriority() -> [Goal] {
        return cloudKitManager.goals.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
    }

    /// Gets goals sorted by target date.
    /// - Returns: Array of goals sorted by target date (soonest first).
    func goalsSortedByDate() -> [Goal] {
        return cloudKitManager.goals.sorted { $0.targetDate < $1.targetDate }
    }

    /// Clears all goals from storage.
    func clearAllGoals() {
        // Note: This only clears goals, not other data types
        cloudKitManager.saveGoals([])
    }

    /// Gets statistics about goals.
    /// - Returns: Dictionary with goal statistics.
    func getGoalStatistics() -> [String: Int] {
        let total = cloudKitManager.goals.count
        let completed = cloudKitManager.goals.count(where: { $0.isCompleted })
        let overdue = cloudKitManager.goals.count(where: { $0.targetDate < Date() && !$0.isCompleted })

        let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let dueThisWeek = cloudKitManager.goals.count(where: { $0.targetDate <= futureDate && !$0.isCompleted })

        return [
            "total": total,
            "completed": completed,
            "incomplete": total - completed,
            "overdue": overdue,
            "dueThisWeek": dueThisWeek,
        ]
    }
}
