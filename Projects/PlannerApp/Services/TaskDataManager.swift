import Foundation

/// Protocol defining the interface for task data management
@MainActor
protocol TaskDataManaging {
    func load() -> [PlannerTask]
    func save(tasks: [PlannerTask])
    func add(_ task: PlannerTask)
    func update(_ task: PlannerTask)
    func delete(_ task: PlannerTask)
    func find(by id: UUID) -> PlannerTask?
}

/// Legacy TaskDataManager - now delegates to CloudKitManager for backward compatibility
/// This class is maintained for existing code that imports TaskDataManager directly
@MainActor
final class TaskDataManager: TaskDataManaging {
    /// Shared singleton instance - now delegates to CloudKitManager
    static let shared = TaskDataManager()

    /// Delegate to the consolidated CloudKitManager
    private let cloudKitManager = CloudKitManager.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Loads all tasks from CloudKitManager.
    /// - Returns: Array of `PlannerTask` objects.
    func load() -> [PlannerTask] {
        return cloudKitManager.loadTasks()
    }

    /// Saves the provided tasks using CloudKitManager.
    /// - Parameter tasks: Array of `PlannerTask` objects to save.
    func save(tasks: [PlannerTask]) {
        cloudKitManager.saveTasks(tasks)
    }

    /// Adds a new task using CloudKitManager.
    /// - Parameter task: The `PlannerTask` to add.
    func add(_ task: PlannerTask) {
        cloudKitManager.addTask(task)
    }

    /// Updates an existing task using CloudKitManager.
    /// - Parameter task: The `PlannerTask` to update.
    func update(_ task: PlannerTask) {
        cloudKitManager.updateTask(task)
    }

    /// Deletes a task using CloudKitManager.
    /// - Parameter task: The `PlannerTask` to delete.
    func delete(_ task: PlannerTask) {
        cloudKitManager.deleteTask(task)
    }

    /// Finds a task by its ID using CloudKitManager.
    /// - Parameter id: The UUID of the task to find.
    /// - Returns: The `PlannerTask` if found, otherwise nil.
    func find(by id: UUID) -> PlannerTask? {
        return cloudKitManager.findTask(by: id)
    }

    /// Gets tasks filtered by completion status.
    /// - Parameter completed: Whether to get completed or incomplete tasks.
    /// - Returns: Array of filtered tasks.
    func tasks(filteredByCompletion completed: Bool) -> [PlannerTask] {
        return cloudKitManager.tasks.filter { $0.isCompleted == completed }
    }

    /// Gets tasks due within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of tasks due within the specified period.
    func tasksDue(within days: Int) -> [PlannerTask] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return cloudKitManager.tasks.filter { task in
            if let dueDate = task.dueDate {
                return dueDate <= futureDate && !task.isCompleted
            }
            return false
        }
    }

    /// Gets overdue tasks.
    /// - Returns: Array of overdue tasks.
    func overdueTasks() -> [PlannerTask] {
        return tasksDue(within: 0).filter { task in
            if let dueDate = task.dueDate {
                return dueDate < Date() && !task.isCompleted
            }
            return false
        }
    }

    /// Gets tasks sorted by priority.
    /// - Returns: Array of tasks sorted by priority (high to low).
    func tasksSortedByPriority() -> [PlannerTask] {
        return cloudKitManager.tasks.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
    }

    /// Gets tasks sorted by due date.
    /// - Returns: Array of tasks sorted by due date (soonest first).
    func tasksSortedByDate() -> [PlannerTask] {
        return cloudKitManager.tasks.sorted { lhs, rhs in
            switch (lhs.dueDate, rhs.dueDate) {
            case let (.some(lhsDate), .some(rhsDate)):
                return lhsDate < rhsDate
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return lhs.createdAt < rhs.createdAt
            }
        }
    }

    /// Clears all tasks from storage.
    func clearAllTasks() {
        // Note: This only clears tasks, not other data types
        cloudKitManager.saveTasks([])
    }

    /// Gets statistics about tasks.
    /// - Returns: Dictionary with task statistics.
    func getTaskStatistics() -> [String: Int] {
        let total = cloudKitManager.tasks.count
        let completed = cloudKitManager.tasks.count(where: { $0.isCompleted })
        let overdue = cloudKitManager.tasks.count(where: { task in
            if let dueDate = task.dueDate {
                return dueDate < Date() && !task.isCompleted
            }
            return false
        })

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        let dueToday = cloudKitManager.tasks.count { task in
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
