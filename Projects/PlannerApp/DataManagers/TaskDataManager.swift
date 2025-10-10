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

/// Legacy TaskDataManager - now delegates to PlannerDataManager for backward compatibility
/// This class is maintained for existing code that imports TaskDataManager directly
final class TaskDataManager: TaskDataManaging {
    /// Shared singleton instance - now delegates to PlannerDataManager
    static let shared = TaskDataManager()

    /// Delegate to the consolidated PlannerDataManager
    private let plannerDataManager = PlannerDataManager.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Loads all tasks from PlannerDataManager.
    /// - Returns: Array of `PlannerTask` objects.
    func load() -> [PlannerTask] {
        return plannerDataManager.loadTasks()
    }

    /// Saves the provided tasks using PlannerDataManager.
    /// - Parameter tasks: Array of `PlannerTask` objects to save.
    func save(tasks: [PlannerTask]) {
        plannerDataManager.saveTasks(tasks)
    }

    /// Adds a new task using PlannerDataManager.
    /// - Parameter task: The `PlannerTask` to add.
    func add(_ task: PlannerTask) {
        plannerDataManager.addTask(task)
    }

    /// Updates an existing task using PlannerDataManager.
    /// - Parameter task: The `PlannerTask` to update.
    func update(_ task: PlannerTask) {
        plannerDataManager.updateTask(task)
    }

    /// Deletes a task using PlannerDataManager.
    /// - Parameter task: The `PlannerTask` to delete.
    func delete(_ task: PlannerTask) {
        plannerDataManager.deleteTask(task)
    }

    /// Finds a task by its ID using PlannerDataManager.
    /// - Parameter id: The UUID of the task to find.
    /// - Returns: The `PlannerTask` if found, otherwise nil.
    func find(by id: UUID) -> PlannerTask? {
        return plannerDataManager.findTask(by: id)
    }

    /// Gets tasks filtered by completion status.
    /// - Parameter completed: Whether to get completed or incomplete tasks.
    /// - Returns: Array of filtered tasks.
    func tasks(filteredByCompletion completed: Bool) -> [PlannerTask] {
        return plannerDataManager.tasksFiltered(by: completed)
    }

    /// Gets tasks due within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of tasks due within the specified period.
    func tasksDue(within days: Int) -> [PlannerTask] {
        return plannerDataManager.tasksDue(within: days)
    }

    /// Gets overdue tasks.
    /// - Returns: Array of overdue tasks.
    func overdueTasks() -> [PlannerTask] {
        return plannerDataManager.tasksDue(within: 0).filter { task in
            if let dueDate = task.dueDate {
                return dueDate < Date() && !task.isCompleted
            }
            return false
        }
    }

    /// Gets tasks sorted by priority.
    /// - Returns: Array of tasks sorted by priority (high to low).
    func tasksSortedByPriority() -> [PlannerTask] {
        return plannerDataManager.tasksSortedByPriority()
    }

    /// Gets tasks sorted by due date.
    /// - Returns: Array of tasks sorted by due date (soonest first).
    func tasksSortedByDate() -> [PlannerTask] {
        return plannerDataManager.tasksSortedByDate()
    }

    /// Clears all tasks from storage.
    func clearAllTasks() {
        // Note: This only clears tasks, not other data types
        plannerDataManager.saveTasks([])
    }

    /// Gets statistics about tasks.
    /// - Returns: Dictionary with task statistics.
    func getTaskStatistics() -> [String: Int] {
        return plannerDataManager.getTaskStatistics()
    }
}
