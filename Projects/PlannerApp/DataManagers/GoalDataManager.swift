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

/// Manages storage and retrieval of `Goal` objects with UserDefaults persistence.
final class GoalDataManager: GoalDataManaging {
    /// Shared singleton instance.
    static let shared = GoalDataManager()

    /// UserDefaults key for storing goals.
    private let goalsKey = "SavedGoals"

    /// UserDefaults instance for persistence.
    private let userDefaults: UserDefaults

    /// Private initializer to enforce singleton usage.
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Loads all goals from UserDefaults.
    /// - Returns: Array of `Goal` objects.
    func load() -> [Goal] {
        guard let data = userDefaults.data(forKey: goalsKey),
              let decodedGoals = try? JSONDecoder().decode([Goal].self, from: data)
        else {
            return []
        }
        return decodedGoals
    }

    /// Saves the provided goals to UserDefaults.
    /// - Parameter goals: Array of `Goal` objects to save.
    func save(goals: [Goal]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            userDefaults.set(encoded, forKey: goalsKey)
        }
    }

    /// Adds a new goal to the stored goals.
    /// - Parameter goal: The `Goal` to add.
    func add(_ goal: Goal) {
        var currentGoals = load()
        currentGoals.append(goal)
        save(goals: currentGoals)
    }

    /// Updates an existing goal.
    /// - Parameter goal: The `Goal` to update.
    func update(_ goal: Goal) {
        var currentGoals = load()
        if let index = currentGoals.firstIndex(where: { $0.id == goal.id }) {
            currentGoals[index] = goal
            save(goals: currentGoals)
        }
    }

    /// Deletes a goal from storage.
    /// - Parameter goal: The `Goal` to delete.
    func delete(_ goal: Goal) {
        var currentGoals = load()
        currentGoals.removeAll { $0.id == goal.id }
        save(goals: currentGoals)
    }

    /// Finds a goal by its ID.
    /// - Parameter id: The UUID of the goal to find.
    /// - Returns: The `Goal` if found, otherwise nil.
    func find(by id: UUID) -> Goal? {
        let goals = load()
        return goals.first { $0.id == id }
    }

    /// Gets goals filtered by completion status.
    /// - Parameter completed: Whether to get completed or incomplete goals.
    /// - Returns: Array of filtered goals.
    func goals(filteredByCompletion completed: Bool) -> [Goal] {
        load().filter { $0.isCompleted == completed }
    }

    /// Gets goals due within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of goals due within the specified period.
    func goalsDue(within days: Int) -> [Goal] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return load().filter { $0.targetDate <= futureDate && !$0.isCompleted }
    }

    /// Gets goals sorted by priority.
    /// - Returns: Array of goals sorted by priority (high to low).
    func goalsSortedByPriority() -> [Goal] {
        load().sorted { (goal1: Goal, goal2: Goal) -> Bool in
            goal1.priority.sortOrder > goal2.priority.sortOrder
        }
    }

    /// Gets goals sorted by target date.
    /// - Returns: Array of goals sorted by target date (soonest first).
    func goalsSortedByDate() -> [Goal] {
        load().sorted { (goal1: Goal, goal2: Goal) -> Bool in
            goal1.targetDate < goal2.targetDate
        }
    }

    /// Clears all goals from storage.
    func clearAllGoals() {
        userDefaults.removeObject(forKey: goalsKey)
    }

    /// Gets statistics about goals.
    /// - Returns: Dictionary with goal statistics.
    func getGoalStatistics() -> [String: Int] {
        let goals = load()
        let total = goals.count
        let completed = goals.count(where: { $0.isCompleted })
        let overdue = goals.count(where: { $0.targetDate < Date() && !$0.isCompleted })
        let dueThisWeek = goalsDue(within: 7).count

        return [
            "total": total,
            "completed": completed,
            "incomplete": total - completed,
            "overdue": overdue,
            "dueThisWeek": dueThisWeek,
        ]
    }
}

// MARK: - Object Pooling

/// Object pool for performance optimization
private var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
