import Foundation

/// Protocol defining the interface for all planner entities
protocol PlannerEntity: Identifiable, Codable, Hashable {
    var id: UUID { get }
    var title: String { get set }
    var createdAt: Date { get }
    var modifiedAt: Date? { get set }
    var isCompleted: Bool { get set }
    var priority: any PlannerPriority { get set }
}

/// Protocol for entities that have due dates
protocol Schedulable {
    var dueDate: Date? { get set }
}

/// Protocol for entities that can be rendered
protocol PlannerRenderable {
    var color: String { get }
    var iconName: String { get }
}

/// Protocol for priority systems
protocol PlannerPriority: Codable, Hashable {
    var displayName: String { get }
    var sortOrder: Int { get }
    var color: String { get }
}

// MARK: - Enhanced Task Entity

extension PlannerTask: PlannerEntity, Schedulable, PlannerRenderable {
    var color: String {
        switch priority {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }

    var iconName: String {
        isCompleted ? "checkmark.circle.fill" : "circle"
    }

    // Hashable conformance for object pooling
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PlannerTask, rhs: PlannerTask) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Enhanced Goal Entity

extension Goal: PlannerEntity, Schedulable, PlannerRenderable {
    var dueDate: Date? {
        get { targetDate }
        set { if let newDate = newValue { targetDate = newDate } }
    }

    var color: String {
        switch priority {
        case .high: return "purple"
        case .medium: return "blue"
        case .low: return "teal"
        }
    }

    var iconName: String {
        let progressIcon: String
        switch progress {
        case 0 ..< 0.25: progressIcon = "circle"
        case 0.25 ..< 0.5: progressIcon = "circle.lefthalf.filled"
        case 0.5 ..< 0.75: progressIcon = "circle.righthalf.filled"
        case 0.75 ..< 1.0: progressIcon = "circle.fill"
        default: progressIcon = "checkmark.circle.fill"
        }
        return isCompleted ? "checkmark.circle.fill" : progressIcon
    }

    // Hashable conformance for object pooling
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Enhanced Calendar Event Entity

extension CalendarEvent: PlannerEntity, Schedulable, PlannerRenderable {
    var dueDate: Date? {
        get { date }
        set { if let newDate = newValue { date = newDate } }
    }

    var isCompleted: Bool {
        get { false } // Calendar events are not completable in the same way
        set {} // No-op
    }

    var priority: any PlannerPriority {
        get { EventPriority.medium }
        set {} // Calendar events have fixed priority
    }

    var color: String {
        "blue"
    }

    var iconName: String {
        "calendar"
    }

    // Hashable conformance for object pooling
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Enhanced Journal Entry Entity

extension JournalEntry: PlannerEntity, PlannerRenderable {
    var isCompleted: Bool {
        get { false } // Journal entries are not completable
        set {} // No-op
    }

    var priority: any PlannerPriority {
        get { JournalPriority.medium }
        set {} // Journal entries have fixed priority
    }

    var color: String {
        // Color based on mood
        switch mood.lowercased() {
        case "great", "excellent", "amazing": return "green"
        case "good", "happy", "content": return "blue"
        case "okay", "neutral", "fine": return "orange"
        case "bad", "sad", "disappointed": return "red"
        case "terrible", "awful", "horrible": return "purple"
        default: return "gray"
        }
    }

    var iconName: String {
        "book.closed"
    }

    // Hashable conformance for object pooling
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Priority Enums

enum EventPriority: String, CaseIterable, Codable {
    case low, medium, high

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: 3
        case .medium: 2
        case .low: 1
        }
    }

    var color: String {
        switch self {
        case .high: "red"
        case .medium: "orange"
        case .low: "green"
        }
    }
}

enum JournalPriority: String, CaseIterable, Codable {
    case low, medium, high

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: 3
        case .medium: 2
        case .low: 1
        }
    }

    var color: String {
        switch self {
        case .high: "purple"
        case .medium: "blue"
        case .low: "teal"
        }
    }
}

// MARK: - Entity Factory

enum PlannerEntityFactory {
    static func createTask(title: String, description: String = "", priority: TaskPriority = .medium, dueDate: Date? = nil) -> PlannerTask {
        PlannerTask(title: title, description: description, priority: priority, dueDate: dueDate)
    }

    static func createGoal(title: String, description: String, targetDate: Date, priority: GoalPriority = .medium) -> Goal {
        Goal(title: title, description: description, targetDate: targetDate, priority: priority)
    }

    static func createCalendarEvent(title: String, date: Date) -> CalendarEvent {
        CalendarEvent(title: title, date: date)
    }

    static func createJournalEntry(title: String, body: String, mood: String) -> JournalEntry {
        JournalEntry(title: title, body: body, date: Date(), mood: mood)
    }
}

// MARK: - Entity Extensions

extension PlannerEntity {
    /// Check if entity is overdue
    var isOverdue: Bool {
        if let dueDate = self as? Schedulable, let date = dueDate.dueDate {
            return date < Date() && !isCompleted
        }
        return false
    }

    /// Check if entity is due today
    var isDueToday: Bool {
        if let dueDate = self as? Schedulable, let date = dueDate.dueDate {
            let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: Date())
            let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
            return date >= todayStart && date < todayEnd && !isCompleted
        }
        return false
    }

    /// Check if entity is due this week
    var isDueThisWeek: Bool {
        if let dueDate = self as? Schedulable, let date = dueDate.dueDate {
            let calendar = Calendar.current
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return date >= weekStart && date < weekEnd && !isCompleted
        }
        return false
    }
}

// MARK: - Collection Extensions

extension Array where Element: PlannerEntity {
    /// Filter completed entities
    func completed() -> [Element] {
        filter(\.isCompleted)
    }

    /// Filter incomplete entities
    func incomplete() -> [Element] {
        filter { !$0.isCompleted }
    }

    /// Filter overdue entities
    func overdue() -> [Element] {
        filter(\.isOverdue)
    }

    /// Filter entities due today
    func dueToday() -> [Element] {
        filter(\.isDueToday)
    }

    /// Filter entities due this week
    func dueThisWeek() -> [Element] {
        filter(\.isDueThisWeek)
    }

    /// Sort by priority (high to low)
    func sortedByPriority() -> [Element] {
        sorted { $0.priority.sortOrder > $1.priority.sortOrder }
    }

    /// Sort by due date (soonest first)
    func sortedByDueDate() -> [Element] where Element: Schedulable {
        sorted { lhs, rhs in
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

    /// Get statistics for the collection
    func statistics() -> [String: Int] {
        let total = count
        let completed = completed().count
        let overdue = overdue().count
        let dueToday = dueToday().count
        let dueThisWeek = dueThisWeek().count

        return [
            "total": total,
            "completed": completed,
            "incomplete": total - completed,
            "overdue": overdue,
            "dueToday": dueToday,
            "dueThisWeek": dueThisWeek,
        ]
    }
} </ content>
<parameter name = "filePath" >/ Users / danielstevens / Desktop / Quantum - workspace / Projects / PlannerApp / Models / PlannerEntities.swift
