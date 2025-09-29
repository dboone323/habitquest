import Foundation

/// Protocol defining the interface for task data management
protocol TaskDataManaging {
    func load() -> [PlannerTask]
    func save(tasks: [PlannerTask])
    func add(_ task: PlannerTask)
    func update(_ task: PlannerTask)
    func delete(_ task: PlannerTask)
    func find(by id: UUID) -> PlannerTask?
}

/// Manages storage and retrieval of `PlannerTask` objects with UserDefaults persistence.
final class TaskDataManager: TaskDataManaging {
    /// Shared singleton instance.
    static let shared = TaskDataManager()

    /// UserDefaults key for storing tasks.
    private let tasksKey = "SavedTasks"

    /// UserDefaults instance for persistence.
    private let userDefaults: UserDefaults

    /// Private initializer to enforce singleton usage.
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Loads all tasks from UserDefaults.
    /// - Returns: Array of `PlannerTask` objects.
    func load() -> [PlannerTask] {
        guard let data = userDefaults.data(forKey: tasksKey),
              let decodedTasks = try? JSONDecoder().decode([PlannerTask].self, from: data)
        else {
            return []
        }
        return decodedTasks
    }

    /// Saves the provided tasks to UserDefaults.
    /// - Parameter tasks: Array of `PlannerTask` objects to save.
    func save(tasks: [PlannerTask]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            self.userDefaults.set(encoded, forKey: self.tasksKey)
        }
    }

    /// Adds a new task to the stored tasks.
    /// - Parameter task: The `PlannerTask` to add.
    func add(_ task: PlannerTask) {
        var currentTasks = self.load()
        currentTasks.append(task)
        self.save(tasks: currentTasks)
    }

    /// Updates an existing task.
    /// - Parameter task: The `PlannerTask` to update.
    func update(_ task: PlannerTask) {
        var currentTasks = self.load()
        if let index = currentTasks.firstIndex(where: { $0.id == task.id }) {
            currentTasks[index] = task
            self.save(tasks: currentTasks)
        }
    }

    /// Deletes a task from storage.
    /// - Parameter task: The `PlannerTask` to delete.
    func delete(_ task: PlannerTask) {
        var currentTasks = self.load()
        currentTasks.removeAll { $0.id == task.id }
        self.save(tasks: currentTasks)
    }

    /// Finds a task by its ID.
    /// - Parameter id: The UUID of the task to find.
    /// - Returns: The `PlannerTask` if found, otherwise nil.
    func find(by id: UUID) -> PlannerTask? {
        let tasks = self.load()
        return tasks.first { $0.id == id }
    }

    /// Gets tasks filtered by completion status.
    /// - Parameter completed: Whether to get completed or incomplete tasks.
    /// - Returns: Array of filtered tasks.
    func tasks(filteredByCompletion completed: Bool) -> [PlannerTask] {
        self.load().filter { $0.isCompleted == completed }
    }

    /// Gets tasks due within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of tasks due within the specified period.
    func tasksDue(within days: Int) -> [PlannerTask] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return self.load().filter { task in
            if let dueDate = task.dueDate {
                return dueDate <= futureDate && !task.isCompleted
            }
            return false
        }
    }

    /// Gets overdue tasks.
    /// - Returns: Array of overdue tasks.
    func overdueTasks() -> [PlannerTask] {
        self.load().filter { task in
            if let dueDate = task.dueDate {
                return dueDate < Date() && !task.isCompleted
            }
            return false
        }
    }

    /// Gets tasks sorted by priority.
    /// - Returns: Array of tasks sorted by priority (high to low).
    func tasksSortedByPriority() -> [PlannerTask] {
        self.load().sorted { $0.priority.sortOrder > $1.priority.sortOrder }
    }

    /// Gets tasks sorted by due date.
    /// - Returns: Array of tasks sorted by due date (soonest first).
    func tasksSortedByDate() -> [PlannerTask] {
        self.load().sorted { lhs, rhs in
            switch (lhs.dueDate, rhs.dueDate) {
            case let (.some(lhsDate), .some(rhsDate)):
                lhsDate < rhsDate
            case (.some, .none):
                true
            case (.none, .some):
                false
            case (.none, .none):
                lhs.createdAt < rhs.createdAt
            }
        }
    }

    /// Clears all tasks from storage.
    func clearAllTasks() {
        self.userDefaults.removeObject(forKey: self.tasksKey)
    }

    /// Gets statistics about tasks.
    /// - Returns: Dictionary with task statistics.
    func getTaskStatistics() -> [String: Int] {
        let tasks = self.load()
        let total = tasks.count
        let completed = tasks.count(where: { $0.isCompleted })
        let overdue = self.overdueTasks().count

        // Count tasks due today (between start of today and end of today)
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        let dueToday = tasks.count { task in
            if let dueDate = task.dueDate, !task.isCompleted {
                return dueDate >= todayStart && dueDate < todayEnd
            }
            return false
        }

        return [
            "total": total,
            "completed": completed,
            "incomplete": total - completed,
            "overdue": overdue,
            "dueToday": dueToday,
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
