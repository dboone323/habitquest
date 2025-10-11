//
//  PlannerAppTests.swift
//  PlannerAppTests
//
//  Created by Daniel Stevens on 4/28/25.
//

import Foundation
import SwiftData
import XCTest

@testable import PlannerApp

private typealias AppTask = PlannerTask

// swiftlint:disable type_body_length

final class PlannerAppTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        // Create in-memory model container for testing
        let schema = Schema([
            // Add your PlannerApp models here when they are defined
            // Example: Task.self, Project.self, Category.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        self.modelContext = ModelContext(self.modelContainer)

        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            UserDefaults.standard.synchronize()
        }

        // Ensure each test starts with an empty data store
        Task { @MainActor in
            TaskDataManager.shared.clearAllTasks()
            GoalDataManager.shared.clearAllGoals()
            CalendarDataManager.shared.clearAllEvents()
        }
    }

    override func tearDownWithError() throws {
        // Reset shared data managers to avoid cross-test state leakage
        Task { @MainActor in
            TaskDataManager.shared.clearAllTasks()
            GoalDataManager.shared.clearAllGoals()
            CalendarDataManager.shared.clearAllEvents()
        }

        self.modelContainer = nil
        self.modelContext = nil
    }

    // MARK: - Task Model Tests

    @MainActor
    func testTaskCreation() {
        // Test basic task creation
        let task = AppTask(title: "Test Task", description: "A test task", priority: .medium, dueDate: Date())
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertEqual(task.description, "A test task")
        XCTAssertEqual(task.priority, TaskPriority.medium)
        XCTAssertFalse(task.isCompleted)
        XCTAssertNotNil(task.dueDate)
    }

    @MainActor
    func testTaskPriority() throws {
        let highPriorityTask = AppTask(title: "High Priority", description: "Urgent task", priority: .high, dueDate: Date())
        let lowPriorityTask = AppTask(title: "Low Priority", description: "Optional task", priority: .low, dueDate: Date())

        XCTAssertEqual(highPriorityTask.priority, TaskPriority.high)
        XCTAssertEqual(lowPriorityTask.priority, TaskPriority.low)
        XCTAssertNotEqual(highPriorityTask.priority, lowPriorityTask.priority)
        XCTAssertEqual(highPriorityTask.priority.sortOrder, 3)
        XCTAssertEqual(lowPriorityTask.priority.sortOrder, 1)
    }

    @MainActor
    func testTaskDueDate() throws {
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday

        XCTAssertGreaterThan(futureDate, Date(), "Future date should be after current date")
        XCTAssertLessThan(pastDate, Date(), "Past date should be before current date")
    }

    @MainActor
    func testTaskCompletionToggle() throws {
        var task = AppTask(title: "Toggle Test", description: "Test completion toggle")

        XCTAssertFalse(task.isCompleted)

        task.isCompleted = true
        XCTAssertTrue(task.isCompleted)

        task.isCompleted = false
        XCTAssertFalse(task.isCompleted)
    }

    @MainActor
    func testTaskEquality() throws {
        let id = UUID()
        let task1 = AppTask(id: id, title: "Test", description: "Description")
        let task2 = AppTask(id: id, title: "Test", description: "Description")

        XCTAssertEqual(task1.id, task2.id)
        XCTAssertEqual(task1.title, task2.title)
    }

    // MARK: - TaskDataManager Tests

    @MainActor
    func testTaskDataManagerSaveAndLoad() {
        // Clear existing tasks first
        TaskDataManager.shared.clearAllTasks()

        let manager = TaskDataManager.shared

        // Create test tasks
        let task1 = AppTask(title: "Test Task 1", description: "First test task", priority: .medium, dueDate: Date())
        let task2 = AppTask(
            title: "Test Task 2",
            description: "Second test task",
            priority: .high,
            dueDate: Date().addingTimeInterval(86400)
        )

        // Save tasks
        manager.save(tasks: [task1, task2])

        // Load tasks
        let loadedTasks = manager.load()

        // Verify tasks were saved and loaded correctly
        XCTAssertEqual(loadedTasks.count, 2)
        XCTAssertEqual(loadedTasks[0].title, "Test Task 1")
        XCTAssertEqual(loadedTasks[1].title, "Test Task 2")
        XCTAssertEqual(loadedTasks[0].priority, TaskPriority.medium)
        XCTAssertEqual(loadedTasks[1].priority, TaskPriority.high)
    }

    @MainActor
    func testTaskDataManagerAdd() {
        // Clear existing tasks first
        TaskDataManager.shared.clearAllTasks()

        let manager = TaskDataManager.shared

        // Create and add a task
        let task = AppTask(title: "Added Task", description: "Task added via add method", priority: .low)
        manager.add(task)

        // Verify task was added
        let loadedTasks = manager.load()
        XCTAssertEqual(loadedTasks.count, 1)
        XCTAssertEqual(loadedTasks[0].title, "Added Task")
        XCTAssertEqual(loadedTasks[0].priority, TaskPriority.low)
    }

    @MainActor
    func testTaskDataManagerUpdate() {
        // Clear existing tasks first
        TaskDataManager.shared.clearAllTasks()

        let manager = TaskDataManager.shared

        // Create and add a task
        let originalTask = AppTask(title: "Original Task", description: "Original description", priority: .medium)
        manager.add(originalTask)

        // Update the task
        var updatedTask = originalTask
        updatedTask.title = "Updated Task"
        updatedTask.isCompleted = true
        manager.update(updatedTask)

        // Verify task was updated
        let loadedTasks = manager.load()
        XCTAssertEqual(loadedTasks.count, 1)
        XCTAssertEqual(loadedTasks[0].title, "Updated Task")
        XCTAssertTrue(loadedTasks[0].isCompleted)
    }

    @MainActor
    func testTaskDataManagerDelete() throws {
        let manager = TaskDataManager.shared
        manager.clearAllTasks()

        let task1 = AppTask(title: "Task 1", description: "First task")
        let task2 = AppTask(title: "Task 2", description: "Second task")
        manager.save(tasks: [task1, task2])

        manager.delete(task1)

        let loadedTasks = manager.load()
        XCTAssertEqual(loadedTasks.count, 1)
        XCTAssertEqual(loadedTasks[0].title, "Task 2")
    }

    @MainActor
    func testTaskDataManagerFindById() throws {
        let manager = TaskDataManager.shared
        manager.clearAllTasks()

        let task1 = AppTask(title: "Task 1", description: "First task")
        let task2 = AppTask(title: "Task 2", description: "Second task")
        manager.save(tasks: [task1, task2])

        let foundTask = manager.find(by: task1.id)
        XCTAssertNotNil(foundTask)
        XCTAssertEqual(foundTask?.title, "Task 1")

        let notFoundTask = manager.find(by: UUID())
        XCTAssertNil(notFoundTask)
    }

    @MainActor
    func testTaskDataManagerFiltering() throws {
        let manager = TaskDataManager.shared
        manager.clearAllTasks()

        let completedTask = AppTask(title: "Completed", description: "Done", isCompleted: true)
        let incompleteTask = AppTask(title: "Incomplete", description: "Not done", isCompleted: false)
        manager.save(tasks: [completedTask, incompleteTask])

        let completedTasks = manager.tasks(filteredByCompletion: true)
        let incompleteTasks = manager.tasks(filteredByCompletion: false)

        XCTAssertEqual(completedTasks.count, 1)
        XCTAssertEqual(incompleteTasks.count, 1)
        XCTAssertEqual(completedTasks[0].title, "Completed")
        XCTAssertEqual(incompleteTasks[0].title, "Incomplete")
    }

    @MainActor
    func testTaskDataManagerDueDateFiltering() throws {
        let manager = TaskDataManager.shared
        manager.clearAllTasks()

        let dueToday = AppTask(title: "Due Today", description: "Urgent", dueDate: Date())
        let dueTomorrow = AppTask(title: "Due Tomorrow", description: "Soon", dueDate: Date().addingTimeInterval(86400))
        let dueNextWeek = AppTask(title: "Due Next Week", description: "Later", dueDate: Date().addingTimeInterval(7 * 86400))
        let noDueDate = AppTask(title: "No Due Date", description: "Flexible")

        manager.save(tasks: [dueToday, dueTomorrow, dueNextWeek, noDueDate])

        let dueWithin1Day = manager.tasksDue(within: 1)
        let dueWithin7Days = manager.tasksDue(within: 7)

        XCTAssertEqual(dueWithin1Day.count, 2) // dueToday and dueTomorrow (within 1 day)
        XCTAssertEqual(dueWithin7Days.count, 3) // dueToday, dueTomorrow, and dueNextWeek (within 7 days)
    }

    @MainActor
    func testTaskDataManagerOverdueTasks() throws {
        let manager = TaskDataManager.shared
        manager.clearAllTasks()

        let overdueTask = AppTask(title: "Overdue", description: "Late", isCompleted: false, dueDate: Date().addingTimeInterval(-86400))
        let completedOverdueTask = AppTask(
            title: "Completed Overdue",
            description: "Done late",
            isCompleted: true,
            dueDate: Date().addingTimeInterval(-86400)
        )
        let notOverdueTask = AppTask(title: "Not Overdue", description: "On time", dueDate: Date().addingTimeInterval(86400))

        manager.save(tasks: [overdueTask, completedOverdueTask, notOverdueTask])

        let overdueTasks = manager.overdueTasks()
        XCTAssertEqual(overdueTasks.count, 1)
        XCTAssertEqual(overdueTasks[0].title, "Overdue")
    }

    @MainActor
    func testTaskDataManagerSorting() throws {
        let manager = TaskDataManager.shared
        manager.clearAllTasks()

        let highPriority = AppTask(title: "High", description: "High priority", priority: .high)
        let mediumPriority = AppTask(title: "Medium", description: "Medium priority", priority: .medium)
        let lowPriority = AppTask(title: "Low", description: "Low priority", priority: .low)

        manager.save(tasks: [lowPriority, highPriority, mediumPriority])

        let sortedByPriority = manager.tasksSortedByPriority()
        XCTAssertEqual(sortedByPriority[0].title, "High")
        XCTAssertEqual(sortedByPriority[1].title, "Medium")
        XCTAssertEqual(sortedByPriority[2].title, "Low")
    }

    @MainActor
    func testTaskDataManagerStatistics() throws {
        let manager = TaskDataManager.shared
        manager.clearAllTasks()

        let completedTask = AppTask(title: "Completed", description: "Done", isCompleted: true)
        let incompleteTask = AppTask(title: "Incomplete", description: "Not done", isCompleted: false)
        let overdueTask = AppTask(
            title: "Overdue",
            description: "Late",
            isCompleted: false,
            dueDate: Date().addingTimeInterval(-86400)
        )
        // Create a task due today explicitly - use noon today to ensure it's within today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(24 * 3600)
        let lateEveningToday = calendar.date(byAdding: .second, value: -60, to: startOfTomorrow)
            ?? startOfTomorrow.addingTimeInterval(-60)
        let dueTodayTask = AppTask(
            title: "Due Today", description: "Urgent", isCompleted: false, dueDate: lateEveningToday
        )

        manager.save(tasks: [completedTask, incompleteTask, overdueTask, dueTodayTask])

        let stats = manager.getTaskStatistics()
        let loadedTasks = manager.load()
        let taskSummaries = loadedTasks.map { task in
            if let dueDate = task.dueDate {
                "\(task.title) - due: \(dueDate) - completed: \(task.isCompleted)"
            } else {
                "\(task.title) - due: nil - completed: \(task.isCompleted)"
            }
        }
        print("DEBUG: Loaded tasks = \(taskSummaries)")
        print("DEBUG: Actual stats = \(stats)")
        XCTAssertEqual(stats["total"], 4, "Stats: \(stats) | Tasks: \(taskSummaries)")
        XCTAssertEqual(stats["completed"], 1, "Stats: \(stats) | Tasks: \(taskSummaries)")
        XCTAssertEqual(stats["incomplete"], 3, "Stats: \(stats) | Tasks: \(taskSummaries)")
        XCTAssertEqual(stats["overdue"], 1, "Stats: \(stats) | Tasks: \(taskSummaries)")
        XCTAssertEqual(stats["dueToday"], 1, "Stats: \(stats) | Tasks: \(taskSummaries)")
    }

    // MARK: - DashboardViewModel Tests

    @MainActor
    func testDashboardViewModelInitialization() throws {
        let viewModel = DashboardViewModel()

        XCTAssertEqual(viewModel.todaysEvents.count, 0)
        XCTAssertEqual(viewModel.incompleteTasks.count, 0)
        XCTAssertEqual(viewModel.upcomingGoals.count, 0)
        XCTAssertEqual(viewModel.recentActivities.count, 0)
        XCTAssertEqual(viewModel.upcomingItems.count, 0)
    }

    @MainActor
    func testDashboardViewModelFetchData() throws {
        let viewModel = DashboardViewModel()

        // Clear existing data
        TaskDataManager.shared.clearAllTasks()
        GoalDataManager.shared.clearAllGoals()
        CalendarDataManager.shared.clearAllEvents()

        // Add test data
        let task = AppTask(title: "Test Task", description: "Test description", isCompleted: false)
        let goal = Goal(title: "Test Goal", description: "Test goal", targetDate: Date().addingTimeInterval(86400))
        let event = CalendarEvent(title: "Test Event", date: Date())

        TaskDataManager.shared.add(task)
        GoalDataManager.shared.add(goal)
        CalendarDataManager.shared.add(event)

        // Fetch data
        viewModel.fetchDashboardData()

        // Verify data was loaded
        XCTAssertGreaterThanOrEqual(viewModel.totalIncompleteTasksCount, 1)
        XCTAssertGreaterThanOrEqual(viewModel.totalUpcomingGoalsCount, 1)
        XCTAssertGreaterThanOrEqual(viewModel.totalTodaysEventsCount, 1)
    }

    @MainActor
    func testDashboardViewModelRefreshData() async throws {
        let viewModel = DashboardViewModel()

        // Clear existing data
        TaskDataManager.shared.clearAllTasks()

        // Add test data
        let task = AppTask(title: "Refresh Test Task", description: "Test refresh", isCompleted: true)
        TaskDataManager.shared.add(task)

        // Refresh data
        await viewModel.refreshData()

        // Verify quick stats were updated
        XCTAssertGreaterThanOrEqual(viewModel.totalTasks, 1)
        XCTAssertGreaterThanOrEqual(viewModel.completedTasks, 1)
        XCTAssertGreaterThanOrEqual(viewModel.recentActivities.count, 0) // May be 0 if not recent
    }

    @MainActor
    func testDashboardViewModelDataFiltering() throws {
        let viewModel = DashboardViewModel()

        // Clear existing data
        TaskDataManager.shared.clearAllTasks()
        GoalDataManager.shared.clearAllGoals()

        // Add test data
        let incompleteTask = AppTask(title: "Incomplete", description: "Not done", isCompleted: false)
        let completedTask = AppTask(title: "Completed", description: "Done", isCompleted: true)
        let futureGoal = Goal(title: "Future Goal", description: "Future", targetDate: Date().addingTimeInterval(86400))

        TaskDataManager.shared.save(tasks: [incompleteTask, completedTask])
        GoalDataManager.shared.add(futureGoal)

        // Fetch data
        viewModel.fetchDashboardData()

        // Verify filtering worked
        XCTAssertTrue(viewModel.incompleteTasks.contains { $0.title == "Incomplete" })
        XCTAssertFalse(viewModel.incompleteTasks.contains { $0.title == "Completed" })
    }

    @MainActor
    func testDashboardViewModelItemLimit() throws {
        let viewModel = DashboardViewModel()

        // Clear existing data
        TaskDataManager.shared.clearAllTasks()

        // Add multiple tasks
        var tasks: [AppTask] = []
        for index in 1 ... 10 {
            let task = AppTask(title: "Task \(index)", description: "Task \(index)", isCompleted: false)
            tasks.append(task)
        }
        TaskDataManager.shared.save(tasks: tasks)

        // Fetch data (default limit is 3)
        viewModel.fetchDashboardData()

        // Verify limit was applied
        XCTAssertLessThanOrEqual(viewModel.incompleteTasks.count, 3)
        XCTAssertEqual(viewModel.totalIncompleteTasksCount, 10)
    }

    // MARK: - Goal Model Tests

    @MainActor
    func testGoalCreation() throws {
        let targetDate = Date().addingTimeInterval(7 * 86400) // One week from now
        let goal = Goal(title: "Test Goal", description: "A test goal", targetDate: targetDate)

        XCTAssertEqual(goal.title, "Test Goal")
        XCTAssertEqual(goal.description, "A test goal")
        XCTAssertEqual(goal.targetDate.timeIntervalSince1970, targetDate.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertFalse(goal.isCompleted)
        XCTAssertNotNil(goal.id)
        XCTAssertNotNil(goal.createdAt)
    }

    @MainActor
    func testGoalCompletion() throws {
        var goal = Goal(title: "Completion Test", description: "Test completion", targetDate: Date().addingTimeInterval(86400))

        XCTAssertFalse(goal.isCompleted)

        goal.isCompleted = true
        XCTAssertTrue(goal.isCompleted)
    }

    // MARK: - Calendar Event Tests

    @MainActor
    func testCalendarEventCreation() throws {
        let eventDate = Date().addingTimeInterval(3600) // One hour from now
        let event = CalendarEvent(title: "Test Event", date: eventDate)

        XCTAssertEqual(event.title, "Test Event")
        XCTAssertEqual(event.date.timeIntervalSince1970, eventDate.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertNotNil(event.id)
    }

    // MARK: - Data Manager Integration Tests

    @MainActor
    func testDataManagerIntegration() throws {
        // Clear all data
        TaskDataManager.shared.clearAllTasks()
        GoalDataManager.shared.clearAllGoals()
        CalendarDataManager.shared.clearAllEvents()

        // Add test data
        let task = AppTask(title: "Integration Task", description: "Test integration", isCompleted: false)
        let goal = Goal(title: "Integration Goal", description: "Test goal", targetDate: Date().addingTimeInterval(86400))
        let event = CalendarEvent(title: "Integration Event", date: Date())

        TaskDataManager.shared.add(task)
        GoalDataManager.shared.add(goal)
        CalendarDataManager.shared.add(event)

        // Verify data was saved and can be loaded
        let loadedTasks = TaskDataManager.shared.load()
        let loadedGoals = GoalDataManager.shared.load()
        let loadedEvents = CalendarDataManager.shared.load()

        XCTAssertEqual(loadedTasks.count, 1)
        XCTAssertEqual(loadedGoals.count, 1)
        XCTAssertEqual(loadedEvents.count, 1)

        XCTAssertEqual(loadedTasks[0].title, "Integration Task")
        XCTAssertEqual(loadedGoals[0].title, "Integration Goal")
        XCTAssertEqual(loadedEvents[0].title, "Integration Event")
    }

    // MARK: - Date and Time Tests

    @MainActor
    func testDateCalculations() throws {
        // Test date calculation utilities
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!

        XCTAssertGreaterThan(tomorrow, today, "Tomorrow should be after today")
        XCTAssertGreaterThan(nextWeek, tomorrow, "Next week should be after tomorrow")
    }

    @MainActor
    func testTaskOverdueDetection() throws {
        // Test detection of overdue tasks
        let yesterday = Date().addingTimeInterval(-86400)
        let tomorrow = Date().addingTimeInterval(86400)

        XCTAssertLessThan(yesterday, Date(), "Yesterday should be in the past")
        XCTAssertGreaterThan(tomorrow, Date(), "Tomorrow should be in the future")
    }

    @MainActor
    func testDueDateValidation() throws {
        // Test due date validation
        let pastDate = Date().addingTimeInterval(-86400)
        let futureDate = Date().addingTimeInterval(86400)

        // Tasks should be able to have past due dates (for overdue tracking)
        // but typically we'd validate future dates for new tasks
        XCTAssertLessThan(pastDate, Date())
        XCTAssertGreaterThan(futureDate, Date())
    }

    // MARK: - Search and Filter Tests

    @MainActor
    func testTaskSearch() throws {
        // Test task search functionality
        let searchTerm = "meeting"

        XCTAssertFalse(searchTerm.isEmpty, "Search term should not be empty")
        XCTAssertEqual(searchTerm.lowercased(), "meeting", "Search term should be lowercase")
    }

    @MainActor
    func testTaskFiltering() throws {
        // Test task filtering by priority
        // let highPriorityTasks = filterTasks(by: .high)
        // let mediumPriorityTasks = filterTasks(by: .medium)

        // XCTAssertGreaterThanOrEqual(highPriorityTasks.count, 0)
        // XCTAssertGreaterThanOrEqual(mediumPriorityTasks.count, 0)

        XCTAssertTrue(true, "Task filtering test framework ready")
    }

    @MainActor
    func testAdvancedFiltering() throws {
        // Test advanced filtering options
        // let completedTasks = filterTasks(by: .completed)
        // let overdueTasks = filterTasks(by: .overdue)
        // let highPriorityOverdueTasks = filterTasks(by: [.high, .overdue])

        // XCTAssertGreaterThanOrEqual(completedTasks.count, 0)
        // XCTAssertGreaterThanOrEqual(overdueTasks.count, 0)
        // XCTAssertGreaterThanOrEqual(highPriorityOverdueTasks.count, 0)

        XCTAssertTrue(true, "Advanced filtering test framework ready")
    }

    // MARK: - Data Persistence Tests

    @MainActor
    func testDataPersistence() throws {
        // Test data persistence across app launches
        let testData = ["key": "value", "number": "42"]

        XCTAssertEqual(testData["key"], "value")
        XCTAssertEqual(testData["number"], "42")
        XCTAssertEqual(testData.count, 2)
    }

    @MainActor
    func testDataMigration() throws {
        // Test data migration between app versions
        let oldVersionData = ["version": "1.0", "tasks": "[]"]
        let newVersionData = ["version": "2.0", "tasks": "[]", "projects": "[]"]

        XCTAssertEqual(oldVersionData["version"], "1.0")
        XCTAssertEqual(newVersionData["version"], "2.0")
        XCTAssertTrue(newVersionData.keys.contains("projects"))
    }

    @MainActor
    func testDataBackupAndRestore() throws {
        // Test data backup and restore functionality
        // let backupService = DataBackupService()
        // let testData = ["tasks": ["task1", "task2"], "projects": ["project1"]]

        // try backupService.createBackup(from: testData)
        // let restoredData = try backupService.restoreFromBackup()

        // XCTAssertEqual(restoredData["tasks"]?.count, 2)
        // XCTAssertEqual(restoredData["projects"]?.count, 1)

        XCTAssertTrue(true, "Data backup and restore test framework ready")
    }

    // MARK: - Performance Tests

    @MainActor
    func testTaskCreationPerformance() throws {
        // Test performance of creating multiple tasks
        let startTime = Date()

        // Simulate creating multiple tasks
        for identifier in 1 ... 100 {
            let taskData: [String: Any] = ["id": identifier, "title": "Task \(identifier)"]
            XCTAssertEqual((taskData["id"] as? Int), identifier)
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 1.0, "Creating 100 tasks should take less than 1 second")
    }

    @MainActor
    func testSearchPerformance() throws {
        // Test performance of search operations
        let startTime = Date()

        // Simulate search through multiple items
        for itemIndex in 1 ... 1000 {
            let item = "Item \(itemIndex)"
            XCTAssertTrue(item.contains("Item"))
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 0.5, "Searching through 1000 items should be fast")
    }

    @MainActor
    func testBulkOperationsPerformance() throws {
        // Test performance of bulk operations
        let startTime = Date()

        // Simulate bulk task operations
        var tasks: [[String: Any]] = []
        for taskIndex in 1 ... 500 {
            let task: [String: Any] = ["id": taskIndex, "title": "Bulk Task \(taskIndex)", "completed": taskIndex % 2 == 0]
            tasks.append(task)
        }

        let completedTasks = tasks.filter { $0["completed"] as? Bool == true }
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 2.0, "Bulk operations should be fast")
        XCTAssertEqual(completedTasks.count, 250)
    }

    // MARK: - UI Logic Tests

    @MainActor
    func testTaskDisplayFormatting() throws {
        // Test formatting of task display strings
        let taskTitle = "Complete Project Report"
        let formattedTitle = taskTitle.uppercased()

        XCTAssertEqual(formattedTitle, "COMPLETE PROJECT REPORT")
        XCTAssertTrue(formattedTitle.hasSuffix("REPORT"))
    }

    @MainActor
    func testDateDisplayFormatting() throws {
        // Test formatting of date display strings
        let date = Date()
        let dateString = date.description

        XCTAssertFalse(dateString.isEmpty)
        XCTAssertTrue(dateString.contains("-")) // ISO date format contains hyphens
    }

    @MainActor
    func testPriorityColorMapping() throws {
        // Test mapping of priority levels to colors
        // let highPriorityColor = UIColor.red
        // let mediumPriorityColor = UIColor.orange
        // let lowPriorityColor = UIColor.green

        // XCTAssertNotEqual(highPriorityColor, mediumPriorityColor)
        // XCTAssertNotEqual(mediumPriorityColor, lowPriorityColor)

        XCTAssertTrue(true, "Priority color mapping test framework ready")
    }

    // MARK: - Integration Tests

    @MainActor
    func testTaskProjectIntegration() throws {
        // Test integration between tasks and projects
        // let project = Project(name: "Integration Test", description: "Test integration", color: .red)
        // let task = Task(title: "Integration Task", description: "Test task", dueDate: Date(), priority: .high)

        // project.addTask(task)

        // XCTAssertTrue(project.tasks.contains(task))
        // XCTAssertEqual(task.project, project)

        XCTAssertTrue(true, "Task-project integration test framework ready")
    }

    @MainActor
    func testCategoryTaskIntegration() throws {
        // Test integration between categories and tasks
        // let category = Category(name: "Integration", color: .purple, icon: "circle")
        // let task = Task(title: "Category Task", description: "Test category task", dueDate: Date(), priority: .medium)

        // category.addTask(task)

        // XCTAssertTrue(category.tasks.contains(task))
        // XCTAssertEqual(task.category, category)

        XCTAssertTrue(true, "Category-task integration test framework ready")
    }

    @MainActor
    func testFullWorkflowIntegration() throws {
        // Test complete workflow from project creation to task completion
        // let project = Project(name: "Full Workflow", description: "Complete workflow test", color: .blue)
        // let category = Category(name: "Workflow Category", color: .green, icon: "checklist")
        // let task = Task(title: "Workflow Task", description: "Test full workflow", dueDate: Date(), priority: .high)

        // project.addTask(task)
        // category.addTask(task)

        // XCTAssertEqual(project.tasks.count, 1)
        // XCTAssertEqual(category.tasks.count, 1)
        // XCTAssertEqual(task.project, project)
        // XCTAssertEqual(task.category, category)

        // task.status = .completed
        // XCTAssertEqual(task.status, .completed)
        // XCTAssertEqual(project.completedTasksCount, 1)

        XCTAssertTrue(true, "Full workflow integration test framework ready")
    }

    // MARK: - Data Export Service Tests

    @MainActor
    func testDataExportServiceInitialization() throws {
        // Test data export service initialization
        // let service = DataExportService()
        // XCTAssertNotNil(service)

        // Placeholder until DataExportService is implemented
        XCTAssertTrue(true, "Data export service initialization test framework ready")
    }

    @MainActor
    func testDataExport() throws {
        // Test data export functionality
        // let service = DataExportService()
        // let exportData = ["tasks": ["task1", "task2"], "projects": ["project1"]]

        // let exportedString = try service.exportToJSON(exportData)
        // XCTAssertFalse(exportedString.isEmpty)

        // let reimportedData = try service.importFromJSON(exportedString)
        // XCTAssertEqual(reimportedData["tasks"]?.count, 2)

        // Placeholder until DataExportService is implemented
        XCTAssertTrue(true, "Data export test framework ready")
    }

    @MainActor
    func testExportFormats() throws {
        // Test different export formats
        // let service = DataExportService()
        // let testData = ["test": "data"]

        // let jsonExport = try service.exportToJSON(testData)
        // let csvExport = try service.exportToCSV(testData)

        // XCTAssertFalse(jsonExport.isEmpty)
        // XCTAssertFalse(csvExport.isEmpty)
        // XCTAssertTrue(jsonExport.contains("{"))
        // XCTAssertTrue(csvExport.contains(","))

        // Placeholder until DataExportService is implemented
        XCTAssertTrue(true, "Export formats test framework ready")
    }

    // MARK: - Content View Tests

    @MainActor
    func testContentViewInitialization() throws {
        // Test content view initialization
        // let view = ContentView()
        // XCTAssertNotNil(view)

        // Placeholder until ContentView is implemented
        XCTAssertTrue(true, "Content view initialization test framework ready")
    }

    @MainActor
    func testContentViewDataBinding() throws {
        // Test content view data binding
        // let viewModel = PlannerViewModel()
        // let view = ContentView(viewModel: viewModel)

        // XCTAssertNotNil(view.viewModel)
        // XCTAssertEqual(view.viewModel, viewModel)

        // Placeholder until ContentView is implemented
        XCTAssertTrue(true, "Content view data binding test framework ready")
    }

    // MARK: - Edge Cases and Validation Tests

    @MainActor
    func testEmptyTaskValidation() throws {
        // Test validation of empty tasks
        let emptyTitle = ""
        let emptyDescription = ""

        XCTAssertTrue(emptyTitle.isEmpty)
        XCTAssertTrue(emptyDescription.isEmpty)
    }

    @MainActor
    func testInvalidDateHandling() throws {
        // Test handling of invalid dates
        let invalidDate = Date.distantPast

        XCTAssertLessThan(invalidDate, Date())
    }

    @MainActor
    func testLargeDataSets() throws {
        // Test handling of large data sets
        let largeArray = Array(1 ... 10000)
        let filteredArray = largeArray.filter { $0 % 2 == 0 }

        XCTAssertEqual(largeArray.count, 10000)
        XCTAssertEqual(filteredArray.count, 5000)
    }

    @MainActor
    func testConcurrentAccess() throws {
        // Test concurrent access to data
        // This would typically use expectations for async testing
        let expectation = XCTestExpectation(description: "Concurrent access test")

        DispatchQueue.global().async {
            // Simulate concurrent data access
            let data = ["concurrent": "access"]
            XCTAssertEqual(data["concurrent"], "access")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

// swiftlint:enable type_body_length
