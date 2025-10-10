import Foundation

/// Protocol defining the interface for calendar event data management
protocol CalendarDataManaging {
    func load() -> [CalendarEvent]
    func save(events: [CalendarEvent])
    func add(_ event: CalendarEvent)
    func update(_ event: CalendarEvent)
    func delete(_ event: CalendarEvent)
    func find(by id: UUID) -> CalendarEvent?
}

/// Legacy CalendarDataManager - now delegates to PlannerDataManager for backward compatibility
/// This class is maintained for existing code that imports CalendarDataManager directly
final class CalendarDataManager: CalendarDataManaging {
    /// Shared singleton instance - now delegates to PlannerDataManager
    static let shared = CalendarDataManager()

    /// Delegate to the consolidated PlannerDataManager
    private let plannerDataManager = PlannerDataManager.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Loads all calendar events from PlannerDataManager.
    /// - Returns: Array of `CalendarEvent` objects.
    func load() -> [CalendarEvent] {
        return plannerDataManager.loadCalendarEvents()
    }

    /// Saves the provided calendar events using PlannerDataManager.
    /// - Parameter events: Array of `CalendarEvent` objects to save.
    func save(events: [CalendarEvent]) {
        plannerDataManager.saveCalendarEvents(events)
    }

    /// Adds a new calendar event using PlannerDataManager.
    /// - Parameter event: The `CalendarEvent` to add.
    func add(_ event: CalendarEvent) {
        plannerDataManager.addCalendarEvent(event)
    }

    /// Updates an existing calendar event using PlannerDataManager.
    /// - Parameter event: The `CalendarEvent` to update.
    func update(_ event: CalendarEvent) {
        plannerDataManager.updateCalendarEvent(event)
    }

    /// Deletes a calendar event using PlannerDataManager.
    /// - Parameter event: The `CalendarEvent` to delete.
    func delete(_ event: CalendarEvent) {
        plannerDataManager.deleteCalendarEvent(event)
    }

    /// Finds a calendar event by its ID using PlannerDataManager.
    /// - Parameter id: The UUID of the calendar event to find.
    /// - Returns: The `CalendarEvent` if found, otherwise nil.
    func find(by id: UUID) -> CalendarEvent? {
        return plannerDataManager.findCalendarEvent(by: id)
    }

    /// Gets calendar events for a specific date.
    /// - Parameter date: The date to filter events for.
    /// - Returns: Array of events on the specified date.
    func events(for date: Date) -> [CalendarEvent] {
        return plannerDataManager.calendarEvents(for: date)
    }

    /// Gets calendar events within a date range.
    /// - Parameters:
    ///   - startDate: The start date of the range.
    ///   - endDate: The end date of the range.
    /// - Returns: Array of events within the date range.
    func events(between startDate: Date, and endDate: Date) -> [CalendarEvent] {
        return plannerDataManager.calendarEvents(between: startDate, and: endDate)
    }

    /// Gets calendar events sorted by date.
    /// - Returns: Array of events sorted by date (soonest first).
    func eventsSortedByDate() -> [CalendarEvent] {
        return plannerDataManager.calendarEventsSortedByDate()
    }

    /// Gets upcoming calendar events within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of upcoming events.
    func upcomingEvents(within days: Int) -> [CalendarEvent] {
        return plannerDataManager.upcomingCalendarEvents(within: days)
    }

    /// Clears all calendar events from storage.
    func clearAllEvents() {
        // Note: This only clears calendar events, not other data types
        plannerDataManager.saveCalendarEvents([])
    }

    /// Gets statistics about calendar events.
    /// - Returns: Dictionary with calendar event statistics.
    func getEventStatistics() -> [String: Int] {
        return plannerDataManager.getCalendarEventStatistics()
    }
}
