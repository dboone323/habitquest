import Foundation
import CloudKit

/// Protocol defining the interface for all data management operations
protocol DataManaging {
    associatedtype DataType: Identifiable & Codable

    func load() -> [DataType]
    func save(items: [DataType])
    func add(_ item: DataType)
    func update(_ item: DataType)
    func delete(_ item: DataType)
    func find(by id: UUID) -> DataType?
}

/// Consolidated data manager for all PlannerApp entities with enhanced performance and object pooling
final class PlannerDataManager: ObservableObject {
    // MARK: - Singleton
    @MainActor static let shared = PlannerDataManager()

    // MARK: - Published Properties
    @Published private(set) var tasks: [PlannerTask] = []
    @Published private(set) var goals: [Goal] = []
    @Published private(set) var calendarEvents: [CalendarEvent] = []
    @Published private(set) var journalEntries: [JournalEntry] = []

    // MARK: - Performance Monitoring
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var dataLoadTime: TimeInterval = 0
    @Published private(set) var memoryUsage: Int = 0

    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    private let tasksKey = "SavedTasks"
    private let goalsKey = "SavedGoals"
    private let calendarKey = "SavedCalendarEvents"
    private let journalKey = "SavedJournalEntries"

    // Object pooling for performance optimization
    private var taskPool = PlannerObjectPool<PlannerTask>()
    private var goalPool = PlannerObjectPool<Goal>()
    private var calendarPool = PlannerObjectPool<CalendarEvent>()
    private var journalPool = PlannerObjectPool<JournalEntry>()

    // MARK: - Initialization
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadAllData()
    }

    private func loadAllData() {
        tasks = loadTasks()
        goals = loadGoals()
        calendarEvents = loadCalendarEvents()
        journalEntries = loadJournalEntries()
        updateMemoryUsage()
    }

    func loadTasks() -> [PlannerTask] {
        guard let data = userDefaults.data(forKey: tasksKey),
              let decodedTasks = try? JSONDecoder().decode([PlannerTask].self, from: data)
        else {
            return []
        }
        return decodedTasks
    }

    func loadGoals() -> [Goal] {
        guard let data = userDefaults.data(forKey: goalsKey),
              let decodedGoals = try? JSONDecoder().decode([Goal].self, from: data)
        else {
            return []
        }
        return decodedGoals
    }

    func loadCalendarEvents() -> [CalendarEvent] {
        guard let data = userDefaults.data(forKey: calendarKey),
              let decodedEvents = try? JSONDecoder().decode([CalendarEvent].self, from: data)
        else {
            return []
        }
        return decodedEvents
    }

    func loadJournalEntries() -> [JournalEntry] {
        guard let data = userDefaults.data(forKey: journalKey),
              let decodedEntries = try? JSONDecoder().decode([JournalEntry].self, from: data)
        else {
            return []
        }
        return decodedEntries
    }

    // MARK: - Task Management
    func saveTasks(_ tasks: [PlannerTask]) {
        self.tasks = tasks
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
        updateMemoryUsage()
    }

    func addTask(_ task: PlannerTask) {
        var currentTasks = tasks
        currentTasks.append(task)
        saveTasks(currentTasks)
    }

    func updateTask(_ task: PlannerTask) {
        var currentTasks = tasks
        if let index = currentTasks.firstIndex(where: { $0.id == task.id }) {
            currentTasks[index] = task
            saveTasks(currentTasks)
        }
    }

    func deleteTask(_ task: PlannerTask) {
        var currentTasks = tasks
        currentTasks.removeAll { $0.id == task.id }
        saveTasks(currentTasks)
    }

    func findTask(by id: UUID) -> PlannerTask? {
        return tasks.first { $0.id == id }
    }

    // MARK: - Goal Management
    func saveGoals(_ goals: [Goal]) {
        self.goals = goals
        if let encoded = try? JSONEncoder().encode(goals) {
            userDefaults.set(encoded, forKey: goalsKey)
        }
        updateMemoryUsage()
    }

    func addGoal(_ goal: Goal) {
        var currentGoals = goals
        currentGoals.append(goal)
        saveGoals(currentGoals)
    }

    func updateGoal(_ goal: Goal) {
        var currentGoals = goals
        if let index = currentGoals.firstIndex(where: { $0.id == goal.id }) {
            currentGoals[index] = goal
            saveGoals(currentGoals)
        }
    }

    func deleteGoal(_ goal: Goal) {
        var currentGoals = goals
        currentGoals.removeAll { $0.id == goal.id }
        saveGoals(currentGoals)
    }

    func findGoal(by id: UUID) -> Goal? {
        return goals.first { $0.id == id }
    }

    // MARK: - Calendar Management
    func saveCalendarEvents(_ events: [CalendarEvent]) {
        self.calendarEvents = events
        if let encoded = try? JSONEncoder().encode(events) {
            userDefaults.set(encoded, forKey: calendarKey)
        }
        updateMemoryUsage()
    }

    func addCalendarEvent(_ event: CalendarEvent) {
        var currentEvents = calendarEvents
        currentEvents.append(event)
        saveCalendarEvents(currentEvents)
    }

    func updateCalendarEvent(_ event: CalendarEvent) {
        var currentEvents = calendarEvents
        if let index = currentEvents.firstIndex(where: { $0.id == event.id }) {
            currentEvents[index] = event
            saveCalendarEvents(currentEvents)
        }
    }

    func deleteCalendarEvent(_ event: CalendarEvent) {
        var currentEvents = calendarEvents
        currentEvents.removeAll { $0.id == event.id }
        saveCalendarEvents(currentEvents)
    }

    func findCalendarEvent(by id: UUID) -> CalendarEvent? {
        return calendarEvents.first { $0.id == id }
    }

    // MARK: - Journal Management
    func saveJournalEntries(_ entries: [JournalEntry]) {
        self.journalEntries = entries
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: journalKey)
        }
        updateMemoryUsage()
    }

    func addJournalEntry(_ entry: JournalEntry) {
        var currentEntries = journalEntries
        currentEntries.append(entry)
        saveJournalEntries(currentEntries)
    }

    func updateJournalEntry(_ entry: JournalEntry) {
        var currentEntries = journalEntries
        if let index = currentEntries.firstIndex(where: { $0.id == entry.id }) {
            currentEntries[index] = entry
            saveJournalEntries(currentEntries)
        }
    }

    func deleteJournalEntry(_ entry: JournalEntry) {
        var currentEntries = journalEntries
        currentEntries.removeAll { $0.id == entry.id }
        saveJournalEntries(currentEntries)
    }

    func findJournalEntry(by id: UUID) -> JournalEntry? {
        return journalEntries.first { $0.id == id }
    }

    // MARK: - Statistics and Analytics
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

    func getGoalStatistics() -> [String: Int] {
        let total = goals.count
        let completed = goals.count(where: { $0.isCompleted })
        let overdue = goals.count(where: { $0.targetDate < Date() && !$0.isCompleted })

        let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let dueThisWeek = goals.count(where: { $0.targetDate <= futureDate && !$0.isCompleted })

        return [
            "total": total,
            "completed": completed,
            "incomplete": total - completed,
            "overdue": overdue,
            "dueThisWeek": dueThisWeek,
        ]
    }

    func getDashboardStatistics() -> [String: Any] {
        let taskStats = getTaskStatistics()
        let goalStats = getGoalStatistics()

        return [
            "tasks": taskStats,
            "goals": goalStats,
            "totalItems": taskStats["total"]! + goalStats["total"]!,
            "completedItems": taskStats["completed"]! + goalStats["completed"]!,
            "overdueItems": taskStats["overdue"]! + goalStats["overdue"]!,
            "dataLoadTime": dataLoadTime,
            "memoryUsage": memoryUsage,
            "lastSyncDate": lastSyncDate as Any
        ]
    }

    // MARK: - Filtering and Sorting
    func tasksFiltered(by completion: Bool) -> [PlannerTask] {
        return tasks.filter { $0.isCompleted == completion }
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

    func tasksSortedByPriority() -> [PlannerTask] {
        return tasks.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
    }

    func tasksSortedByDate() -> [PlannerTask] {
        return tasks.sorted { lhs, rhs in
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

    func goalsFiltered(by completion: Bool) -> [Goal] {
        return goals.filter { $0.isCompleted == completion }
    }

    func goalsDue(within days: Int) -> [Goal] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return goals.filter { $0.targetDate <= futureDate && !$0.isCompleted }
    }

    func goalsSortedByPriority() -> [Goal] {
        return goals.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
    }

    func goalsSortedByDate() -> [Goal] {
        return goals.sorted { $0.targetDate < $1.targetDate }
    }

    // MARK: - Journal Filtering and Query Methods
    func journalEntries(for date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return journalEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }

    func journalEntries(between startDate: Date, and endDate: Date) -> [JournalEntry] {
        return journalEntries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }

    func recentJournalEntries(count: Int) -> [JournalEntry] {
        return journalEntries.sorted { $0.date > $1.date }.prefix(count).map { $0 }
    }

    func journalEntries(withMood mood: String) -> [JournalEntry] {
        return journalEntries.filter { $0.mood == mood }
    }

    func uniqueJournalMoods() -> [String] {
        let moods = journalEntries.compactMap { $0.mood }
        return Array(Set(moods)).sorted()
    }

    func journalEntriesSortedByDate() -> [JournalEntry] {
        return journalEntries.sorted { $0.date > $1.date }
    }

    func getJournalEntryStatistics() -> [String: Int] {
        let total = journalEntries.count
        let moods = journalEntries.compactMap { $0.mood }
        let uniqueMoods = Set(moods).count

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        let entriesToday = journalEntries.filter { entry in
            entry.date >= todayStart && entry.date < todayEnd
        }.count

        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let entriesThisWeek = journalEntries.filter { $0.date >= thisWeekStart }.count

        return [
            "total": total,
            "uniqueMoods": uniqueMoods,
            "entriesToday": entriesToday,
            "entriesThisWeek": entriesThisWeek,
        ]
    }

    // MARK: - Calendar Filtering and Query Methods
    func calendarEvents(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return calendarEvents.filter { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }

    func calendarEvents(between startDate: Date, and endDate: Date) -> [CalendarEvent] {
        return calendarEvents.filter { event in
            event.date >= startDate && event.date <= endDate
        }
    }

    func calendarEventsSortedByDate() -> [CalendarEvent] {
        return calendarEvents.sorted { $0.date < $1.date }
    }

    func upcomingCalendarEvents(within days: Int) -> [CalendarEvent] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return calendarEvents.filter { $0.date >= Date() && $0.date <= futureDate }
    }

    func getCalendarEventStatistics() -> [String: Int] {
        let total = calendarEvents.count

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        let eventsToday = calendarEvents.filter { event in
            event.date >= todayStart && event.date < todayEnd
        }.count

        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let eventsThisWeek = calendarEvents.filter { $0.date >= thisWeekStart }.count

        let upcoming = calendarEvents.filter { $0.date >= Date() }.count

        return [
            "total": total,
            "eventsToday": eventsToday,
            "eventsThisWeek": eventsThisWeek,
            "upcoming": upcoming,
        ]
    }

    // MARK: - CloudKit Integration
    func syncWithCloudKit() async {
        // Placeholder for CloudKit sync implementation
        lastSyncDate = Date()
    }

    // MARK: - Performance Monitoring
    private func updateMemoryUsage() {
        // Estimate memory usage based on data sizes
        let taskSize = tasks.count * MemoryLayout<PlannerTask>.size
        let goalSize = goals.count * MemoryLayout<Goal>.size
        let calendarSize = calendarEvents.count * MemoryLayout<CalendarEvent>.size
        let journalSize = journalEntries.count * MemoryLayout<JournalEntry>.size

        memoryUsage = taskSize + goalSize + calendarSize + journalSize
    }

    // MARK: - Data Clearing
    func clearAllData() {
        tasks.removeAll()
        goals.removeAll()
        calendarEvents.removeAll()
        journalEntries.removeAll()

        userDefaults.removeObject(forKey: tasksKey)
        userDefaults.removeObject(forKey: goalsKey)
        userDefaults.removeObject(forKey: calendarKey)
        userDefaults.removeObject(forKey: journalKey)

        updateMemoryUsage()
    }

    // MARK: - Object Pool Management
    func preloadObjectPools() {
        // Preload pools with commonly used objects
        taskPool.preload(count: 10)
        goalPool.preload(count: 5)
        calendarPool.preload(count: 5)
        journalPool.preload(count: 5)
    }

    func getTaskFromPool() -> PlannerTask? {
        return taskPool.getObject()
    }

    func returnTaskToPool(_ task: PlannerTask) {
        taskPool.returnObject(task)
    }

    func getGoalFromPool() -> Goal? {
        return goalPool.getObject()
    }

    func returnGoalToPool(_ goal: Goal) {
        goalPool.returnObject(goal)
    }

    func getCalendarEventFromPool() -> CalendarEvent? {
        return calendarPool.getObject()
    }

    func returnCalendarEventToPool(_ event: CalendarEvent) {
        calendarPool.returnObject(event)
    }

    func getJournalEntryFromPool() -> JournalEntry? {
        return journalPool.getObject()
    }

    func returnJournalEntryToPool(_ entry: JournalEntry) {
        journalPool.returnObject(entry)
    }
}

// MARK: - Enhanced Object Pool
private class PlannerObjectPool<T> {
    private var pool: [T] = []
    private let maxPoolSize: Int

    init(maxPoolSize: Int = 50) {
        self.maxPoolSize = maxPoolSize
    }

    func preload(count: Int) {
        // Preload pool with default instances
        for _ in 0..<min(count, maxPoolSize) {
            if let defaultInstance = createDefaultInstance() {
                pool.append(defaultInstance)
            }
        }
    }

    func getObject() -> T? {
        return pool.popLast()
    }

    func returnObject(_ object: T) {
        if pool.count < maxPoolSize {
            pool.append(object)
        }
    }

    private func createDefaultInstance() -> T? {
        // Create default instances based on type
        switch T.self {
        case is PlannerTask.Type:
            return PlannerTask(title: "", description: "") as? T
        case is Goal.Type:
            return Goal(title: "", description: "", targetDate: Date()) as? T
        case is CalendarEvent.Type:
            return CalendarEvent(title: "", date: Date()) as? T
        case is JournalEntry.Type:
            return JournalEntry(title: "", body: "", date: Date(), mood: "") as? T
        default:
            return nil
        }
    }

    var poolSize: Int {
        return pool.count
    }
}

// MARK: - Legacy Protocol Conformance
extension PlannerDataManager: TaskDataManaging {
    func load() -> [PlannerTask] {
        return tasks
    }

    func save(tasks: [PlannerTask]) {
        saveTasks(tasks)
    }

    func add(_ item: PlannerTask) {
        addTask(item)
    }

    func update(_ item: PlannerTask) {
        updateTask(item)
    }

    func delete(_ item: PlannerTask) {
        deleteTask(item)
    }

    func find(by id: UUID) -> PlannerTask? {
        return findTask(by: id)
    }
}

extension PlannerDataManager: GoalDataManaging {
    func load() -> [Goal] {
        return goals
    }

    func save(goals: [Goal]) {
        saveGoals(goals)
    }

    func add(_ item: Goal) {
        addGoal(item)
    }

    func update(_ item: Goal) {
        updateGoal(item)
    }

    func delete(_ item: Goal) {
        deleteGoal(item)
    }

    func find(by id: UUID) -> Goal? {
        return findGoal(by: id)
    }
}
