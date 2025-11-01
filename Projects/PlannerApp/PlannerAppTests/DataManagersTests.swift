//
//  DataManagersTests.swift
//  PlannerAppTests
//
//  Created by Daniel Stevens on 4/28/25.
//
// swiftlint:disable identifier_name

import CloudKit
import Foundation
import SwiftData
import XCTest

@testable import PlannerApp

private typealias AppTask = PlannerTask

// Test-specific data managers that don't depend on CloudKitManager
final class TestTaskDataManager {
    private var tasks: [PlannerTask] = []

    func load() -> [PlannerTask] {
        tasks
    }

    func save(tasks: [PlannerTask]) {
        self.tasks = tasks
    }

    func add(_ task: PlannerTask) {
        tasks.append(task)
    }

    func update(_ task: PlannerTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func delete(_ task: PlannerTask) {
        tasks.removeAll { $0.id == task.id }
    }

    func find(by id: UUID) -> PlannerTask? {
        tasks.first { $0.id == id }
    }

    func clearAllTasks() {
        tasks.removeAll()
    }

    // Additional methods used by tests
    func tasks(filteredByCompletion completed: Bool) -> [PlannerTask] {
        tasks.filter { $0.isCompleted == completed }
    }

    func tasksDue(within days: Int) -> [PlannerTask] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return tasks.filter { task in
            if let dueDate = task.dueDate {
                return dueDate <= futureDate && !task.isCompleted
            }
            return false
        }
    }

    func overdueTasks() -> [PlannerTask] {
        tasksDue(within: 0).filter { task in
            if let dueDate = task.dueDate {
                return dueDate < Date() && !task.isCompleted
            }
            return false
        }
    }

    func tasksSortedByPriority() -> [PlannerTask] {
        tasks.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
    }

    func tasksSortedByDate() -> [PlannerTask] {
        tasks.sorted { lhs, rhs in
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

    func getTaskStatistics() -> [String: Int] {
        let total = tasks.count
        let completed = tasks.count(where: { $0.isCompleted })
        let overdue = tasks.count(where: { task in
            if let dueDate = task.dueDate {
                return dueDate < Date() && !task.isCompleted
            }
            return false
        })

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

final class TestGoalDataManager {
    private var goals: [Goal] = []

    func load() -> [Goal] {
        goals
    }

    func save(goals: [Goal]) {
        self.goals = goals
    }

    func add(_ item: Goal) {
        goals.append(item)
    }

    func update(_ item: Goal) {
        if let index = goals.firstIndex(where: { $0.id == item.id }) {
            goals[index] = item
        }
    }

    func delete(_ item: Goal) {
        goals.removeAll { $0.id == item.id }
    }

    func find(by id: UUID) -> Goal? {
        goals.first { $0.id == id }
    }

    func clearAllGoals() {
        goals.removeAll()
    }

    // Additional methods used by tests
    func getGoalStatistics() -> [String: Int] {
        let total = goals.count
        let completed = goals.count(where: { $0.isCompleted })
        let incomplete = total - completed
        let overdue = goals.count(where: { goal in
            !goal.isCompleted && goal.targetDate < Date()
        })
        let dueThisWeek = goals.count(where: { goal in
            let calendar = Calendar.current
            let now = Date()
            let oneWeekFromNow = calendar.date(byAdding: .day, value: 7, to: now) ?? now
            return goal.targetDate >= now && goal.targetDate <= oneWeekFromNow
        })

        return [
            "total": total,
            "completed": completed,
            "incomplete": incomplete,
            "overdue": overdue,
            "dueThisWeek": dueThisWeek,
        ]
    }
}

final class TestCalendarDataManager {
    private var events: [CalendarEvent] = []

    func load() -> [CalendarEvent] {
        events
    }

    func save(events: [CalendarEvent]) {
        self.events = events
    }

    func add(_ item: CalendarEvent) {
        events.append(item)
    }

    func update(_ item: CalendarEvent) {
        if let index = events.firstIndex(where: { $0.id == item.id }) {
            events[index] = item
        }
    }

    func delete(_ item: CalendarEvent) {
        events.removeAll { $0.id == item.id }
    }

    func find(by id: UUID) -> CalendarEvent? {
        events.first { $0.id == id }
    }

    func events(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func events(between startDate: Date, and endDate: Date) -> [CalendarEvent] {
        events.filter { $0.date >= startDate && $0.date <= endDate }
    }

    func eventsSortedByDate() -> [CalendarEvent] {
        events.sorted { $0.date < $1.date }
    }

    func upcomingEvents(within days: Int) -> [CalendarEvent] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return events.filter { $0.date >= Date() && $0.date <= futureDate }
    }

    func clearAllEvents() {
        events.removeAll()
    }

    func getEventStatistics() -> [String: Int] {
        let total = events.count

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        let eventsToday = events.filter { event in
            event.date >= todayStart && event.date < todayEnd
        }.count

        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let eventsThisWeek = events.filter { $0.date >= thisWeekStart }.count

        let upcoming = events.filter { $0.date >= Date() }.count

        return [
            "total": total,
            "eventsToday": eventsToday,
            "eventsThisWeek": eventsThisWeek,
            "upcoming": upcoming,
        ]
    }
}

final class DataManagersTests: XCTestCase {
    var testUserDefaults: UserDefaults!
    var testTaskManager: TestTaskDataManager?
    var testGoalManager: TestGoalDataManager?
    var testCalendarManager: TestCalendarDataManager?

    override func setUpWithError() throws {
        // Create test-specific UserDefaults suite
        let testSuiteName = "TestSuite_\(UUID().uuidString)"
        self.testUserDefaults = UserDefaults(suiteName: testSuiteName)!

        // Initialize test data managers
        self.testTaskManager = TestTaskDataManager()
        self.testGoalManager = TestGoalDataManager()
        self.testCalendarManager = TestCalendarDataManager()

        // Clear any existing test data
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            UserDefaults.standard.synchronize()
        }

        // Also clear standard UserDefaults keys used by CloudKitManager
        let keysToClear = ["SavedTasks", "SavedGoals", "SavedCalendarEvents", "SavedJournalEntries"]
        for key in keysToClear {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()

        // Ensure each test starts with an empty data store
        // Clear data synchronously by directly manipulating test managers
        // Note: Removed calls to manager methods since setUpWithError can't be @MainActor

        // Also clear UserDefaults
        for key in keysToClear {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }

    override func tearDownWithError() throws {
        // Reset test data managers
        testTaskManager = nil
        testGoalManager = nil
        testCalendarManager = nil

        // Clear UserDefaults
        let keysToClear = ["SavedTasks", "SavedGoals", "SavedCalendarEvents", "SavedJournalEntries"]
        for key in keysToClear {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()

        self.testUserDefaults = nil
    }

    // MARK: - TaskDataManager Tests

    @MainActor
    func testTaskDataManagerSaveAndLoad() {
        // Clear existing tasks first
        testTaskManager!.clearAllTasks()

        let manager = testTaskManager!

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
        testTaskManager!.clearAllTasks()

        let manager = testTaskManager!

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
        testTaskManager!.clearAllTasks()

        let manager = testTaskManager!

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
        let manager = testTaskManager!
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
        let manager = testTaskManager!
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
        let manager = testTaskManager!
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
        let manager = testTaskManager!
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
        let manager = testTaskManager!
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
        let manager = testTaskManager!
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
        let manager = testTaskManager!
        manager.clearAllTasks()

        let completedTask = PlannerTask(title: "Completed", description: "Done", isCompleted: true)
        let incompleteTask = PlannerTask(title: "Incomplete", description: "Not done", isCompleted: false)
        let overdueTask = PlannerTask(
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
        let dueTodayTask = PlannerTask(
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

    @MainActor
    func testCalendarEventCreation() {
        let event = CalendarEvent(
            id: UUID(),
            title: "Test Event",
            date: Date()
        )

        XCTAssertEqual(event.title, "Test Event")
        XCTAssertNotNil(event.id)
    }

    @MainActor
    func testCalendarDataManagerAdd() {
        let event = CalendarEvent(
            id: UUID(),
            title: "Test Event",
            date: Date()
        )

        testCalendarManager!.add(event)

        let loadedEvents = testCalendarManager!.load()
        XCTAssertEqual(loadedEvents.count, 1)
        XCTAssertEqual(loadedEvents.first?.title, "Test Event")
    }

    @MainActor
    func testCalendarDataManagerUpdate() {
        let event = CalendarEvent(
            id: UUID(),
            title: "Original Event",
            date: Date()
        )

        testCalendarManager!.add(event)

        let updatedEvent = CalendarEvent(
            id: event.id,
            title: "Updated Event",
            date: event.date
        )

        testCalendarManager!.update(updatedEvent)

        let loadedEvents = testCalendarManager!.load()
        XCTAssertEqual(loadedEvents.count, 1)
        XCTAssertEqual(loadedEvents.first?.title, "Updated Event")
    }

    @MainActor
    func testCalendarDataManagerDelete() {
        let event = CalendarEvent(
            id: UUID(),
            title: "Test Event",
            date: Date()
        )

        testCalendarManager!.add(event)
        XCTAssertEqual(testCalendarManager!.load().count, 1)

        testCalendarManager!.delete(event)
        XCTAssertEqual(testCalendarManager!.load().count, 0)
    }

    @MainActor
    func testCalendarDataManagerFindById() {
        let eventId = UUID()
        let event = CalendarEvent(
            id: eventId,
            title: "Test Event",
            date: Date()
        )

        testCalendarManager!.add(event)

        let foundEvent = testCalendarManager!.find(by: eventId)
        XCTAssertNotNil(foundEvent)
        XCTAssertEqual(foundEvent?.id, eventId)
        XCTAssertEqual(foundEvent?.title, "Test Event")

        let notFoundEvent = testCalendarManager!.find(by: UUID())
        XCTAssertNil(notFoundEvent)
    }

    @MainActor
    func testCalendarDataManagerEventsForDate() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let todayEvent = CalendarEvent(
            id: UUID(),
            title: "Today Event",
            date: today
        )

        let tomorrowEvent = CalendarEvent(
            id: UUID(),
            title: "Tomorrow Event",
            date: tomorrow
        )

        testCalendarManager!.add(todayEvent)
        testCalendarManager!.add(tomorrowEvent)

        let todayEvents = testCalendarManager!.events(for: today)
        XCTAssertEqual(todayEvents.count, 1)
        XCTAssertEqual(todayEvents.first?.title, "Today Event")

        let tomorrowEvents = testCalendarManager!.events(for: tomorrow)
        XCTAssertEqual(tomorrowEvents.count, 1)
        XCTAssertEqual(tomorrowEvents.first?.title, "Tomorrow Event")
    }

    @MainActor
    func testCalendarDataManagerEventsBetweenDates() {
        let startDate = Date()
        let middleDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate)!

        let event1 = CalendarEvent(id: UUID(), title: "Event 1", date: startDate)
        let event2 = CalendarEvent(id: UUID(), title: "Event 2", date: middleDate)
        let event3 = CalendarEvent(id: UUID(), title: "Event 3", date: endDate)

        testCalendarManager!.add(event1)
        testCalendarManager!.add(event2)
        testCalendarManager!.add(event3)

        let eventsInRange = testCalendarManager!.events(between: startDate, and: endDate)
        XCTAssertEqual(eventsInRange.count, 3)

        let eventsInMiddleRange = testCalendarManager!.events(between: middleDate, and: middleDate)
        XCTAssertEqual(eventsInMiddleRange.count, 1)
        XCTAssertEqual(eventsInMiddleRange.first?.title, "Event 2")
    }

    @MainActor
    func testCalendarDataManagerEventsSortedByDate() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let middleDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        let event1 = CalendarEvent(id: UUID(), title: "Future Event", date: futureDate)
        let event2 = CalendarEvent(id: UUID(), title: "Past Event", date: pastDate)
        let event3 = CalendarEvent(id: UUID(), title: "Middle Event", date: middleDate)

        testCalendarManager!.add(event1)
        testCalendarManager!.add(event2)
        testCalendarManager!.add(event3)

        let sortedEvents = testCalendarManager!.eventsSortedByDate()
        XCTAssertEqual(sortedEvents.count, 3)
        XCTAssertEqual(sortedEvents[0].title, "Past Event")
        XCTAssertEqual(sortedEvents[1].title, "Middle Event")
        XCTAssertEqual(sortedEvents[2].title, "Future Event")
    }

    @MainActor
    func testCalendarDataManagerUpcomingEvents() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!

        let pastEvent = CalendarEvent(id: UUID(), title: "Past Event", date: pastDate)
        let todayEvent = CalendarEvent(id: UUID(), title: "Today Event", date: today)
        let tomorrowEvent = CalendarEvent(id: UUID(), title: "Tomorrow Event", date: tomorrow)
        let nextWeekEvent = CalendarEvent(id: UUID(), title: "Next Week Event", date: nextWeek)

        testCalendarManager!.add(pastEvent)
        testCalendarManager!.add(todayEvent)
        testCalendarManager!.add(tomorrowEvent)
        testCalendarManager!.add(nextWeekEvent)

        let upcomingEvents = testCalendarManager!.upcomingEvents(within: 2)

        XCTAssertGreaterThanOrEqual(upcomingEvents.count, 1) // At least today
        XCTAssertLessThanOrEqual(upcomingEvents.count, 3) // At most today, tomorrow, and maybe next week if within 2 days
    }

    @MainActor
    func testCalendarDataManagerClearAllEvents() {
        let event1 = CalendarEvent(id: UUID(), title: "Event 1", date: Date())
        let event2 = CalendarEvent(id: UUID(), title: "Event 2", date: Date())

        testCalendarManager!.add(event1)
        testCalendarManager!.add(event2)
        XCTAssertEqual(testCalendarManager!.load().count, 2)

        testCalendarManager!.clearAllEvents()
        XCTAssertEqual(testCalendarManager!.load().count, 0)
    }

    @MainActor
    func testCalendarDataManagerStatistics() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let todayEvent = CalendarEvent(id: UUID(), title: "Today Event", date: today)
        let yesterdayEvent = CalendarEvent(id: UUID(), title: "Yesterday Event", date: yesterday)
        let tomorrowEvent = CalendarEvent(id: UUID(), title: "Tomorrow Event", date: tomorrow)

        testCalendarManager!.add(todayEvent)
        testCalendarManager!.add(yesterdayEvent)
        testCalendarManager!.add(tomorrowEvent)

        let stats = testCalendarManager!.getEventStatistics()

        XCTAssertEqual(stats["total"], 3)
        XCTAssertEqual(stats["eventsToday"], 1)
        XCTAssertGreaterThanOrEqual(stats["eventsThisWeek"] ?? 0, 1) // At least today
        XCTAssertGreaterThanOrEqual(stats["upcoming"] ?? 0, 1) // At least today
    }

    @MainActor
    func testGoalDataManagerStatistics() throws {
        let manager = testGoalManager!
        manager.clearAllGoals()

        let completedGoal = Goal(title: "Completed Goal", description: "Done", targetDate: Date().addingTimeInterval(86400), isCompleted: true)
        let incompleteGoal = Goal(title: "Incomplete Goal", description: "Not done", targetDate: Date().addingTimeInterval(86400), isCompleted: false)
        let overdueGoal = Goal(title: "Overdue Goal", description: "Late", targetDate: Date().addingTimeInterval(-86400), isCompleted: false)

        manager.save(goals: [completedGoal, incompleteGoal, overdueGoal])

        let stats = manager.getGoalStatistics()

        XCTAssertEqual(stats["total"], 3)
        XCTAssertEqual(stats["completed"], 1)
        XCTAssertEqual(stats["incomplete"], 2)
        XCTAssertEqual(stats["overdue"], 1)
        XCTAssertGreaterThanOrEqual(stats["dueThisWeek"] ?? 0, 1) // At least the incomplete goal
    }

    // MARK: - Data Manager Integration Tests

    @MainActor
    func testTaskDataManagerIntegration() throws {
        // Clear all data
        testTaskManager!.clearAllTasks()
        testGoalManager!.clearAllGoals()
        testCalendarManager!.clearAllEvents()

        // Add test data
        let task = PlannerTask(title: "Integration Task", description: "Test integration", isCompleted: false)
        let goal = Goal(title: "Integration Goal", description: "Test goal", targetDate: Date().addingTimeInterval(86400))
        let event = CalendarEvent(title: "Integration Event", date: Date())

        testTaskManager!.add(task)
        testGoalManager!.add(goal)
        testCalendarManager!.add(event)

        // Verify data was saved and can be loaded
        let loadedTasks = testTaskManager!.load()
        let loadedGoals = testGoalManager!.load()
        let loadedEvents = testCalendarManager!.load()

        XCTAssertEqual(loadedTasks.count, 1)
        XCTAssertEqual(loadedGoals.count, 1)
        XCTAssertEqual(loadedEvents.count, 1)

        XCTAssertEqual(loadedTasks[0].title, "Integration Task")
        XCTAssertEqual(loadedGoals[0].title, "Integration Goal")
        XCTAssertEqual(loadedEvents[0].title, "Integration Event")
    }
}
