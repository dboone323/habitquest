import Foundation

/// Protocol defining the interface for calendar event data management
@MainActor
protocol CalendarDataManaging {
    func load() -> [CalendarEvent]
    func save(events: [CalendarEvent])
    func add(_ event: CalendarEvent)
    func update(_ event: CalendarEvent)
    func delete(_ event: CalendarEvent)
    func find(by id: UUID) -> CalendarEvent?
}

/// Legacy CalendarDataManager - now delegates to CloudKitManager for backward compatibility
/// This class is maintained for existing code that imports CalendarDataManager directly
@MainActor
final class CalendarDataManager: CalendarDataManaging {
    /// Shared singleton instance - now delegates to CloudKitManager
    static let shared = CalendarDataManager()

    /// Delegate to the consolidated CloudKitManager
    private let cloudKitManager = CloudKitManager.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Loads all calendar events from CloudKitManager.
    /// - Returns: Array of `CalendarEvent` objects.
    func load() -> [CalendarEvent] {
        return cloudKitManager.loadCalendarEvents()
    }

    /// Saves the provided calendar events using CloudKitManager.
    /// - Parameter events: Array of `CalendarEvent` objects to save.
    func save(events: [CalendarEvent]) {
        cloudKitManager.saveCalendarEvents(events)
    }

    /// Adds a new calendar event using CloudKitManager.
    /// - Parameter event: The `CalendarEvent` to add.
    func add(_ event: CalendarEvent) {
        cloudKitManager.addCalendarEvent(event)
    }

    /// Updates an existing calendar event using CloudKitManager.
    /// - Parameter event: The `CalendarEvent` to update.
    func update(_ event: CalendarEvent) {
        cloudKitManager.updateCalendarEvent(event)
    }

    /// Deletes a calendar event using CloudKitManager.
    /// - Parameter event: The `CalendarEvent` to delete.
    func delete(_ event: CalendarEvent) {
        cloudKitManager.deleteCalendarEvent(event)
    }

    /// Finds a calendar event by its ID using CloudKitManager.
    /// - Parameter id: The UUID of the calendar event to find.
    /// - Returns: The `CalendarEvent` if found, otherwise nil.
    func find(by id: UUID) -> CalendarEvent? {
        return cloudKitManager.findCalendarEvent(by: id)
    }

    /// Gets calendar events for a specific date.
    /// - Parameter date: The date to filter events for.
    /// - Returns: Array of events on the specified date.
    func events(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return cloudKitManager.calendarEvents.filter { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }

    /// Gets calendar events within a date range.
    /// - Parameters:
    ///   - startDate: The start date of the range.
    ///   - endDate: The end date of the range.
    /// - Returns: Array of events within the date range.
    func events(between startDate: Date, and endDate: Date) -> [CalendarEvent] {
        return cloudKitManager.calendarEvents.filter { event in
            event.date >= startDate && event.date <= endDate
        }
    }

    /// Gets calendar events sorted by date.
    /// - Returns: Array of events sorted by date (soonest first).
    func eventsSortedByDate() -> [CalendarEvent] {
        return cloudKitManager.calendarEvents.sorted { $0.date < $1.date }
    }

    /// Gets upcoming calendar events within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of upcoming events.
    func upcomingEvents(within days: Int) -> [CalendarEvent] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return cloudKitManager.calendarEvents.filter { $0.date >= Date() && $0.date <= futureDate }
    }

    /// Clears all calendar events from storage.
    func clearAllEvents() {
        // Note: This only clears calendar events, not other data types
        cloudKitManager.saveCalendarEvents([])
    }

    /// Gets statistics about calendar events.
    /// - Returns: Dictionary with calendar event statistics.
    func getEventStatistics() -> [String: Int] {
        let total = cloudKitManager.calendarEvents.count

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        let eventsToday = cloudKitManager.calendarEvents.filter { event in
            event.date >= todayStart && event.date < todayEnd
        }.count

        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let eventsThisWeek = cloudKitManager.calendarEvents.filter { $0.date >= thisWeekStart }.count

        let upcoming = cloudKitManager.calendarEvents.filter { $0.date >= Date() }.count

        return [
            "total": total,
            "eventsToday": eventsToday,
            "eventsThisWeek": eventsThisWeek,
            "upcoming": upcoming,
        ]
    }
}
