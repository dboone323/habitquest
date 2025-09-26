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

/// Manages storage and retrieval of `CalendarEvent` objects with UserDefaults persistence.
final class CalendarDataManager: CalendarDataManaging {
    /// Shared singleton instance.
    static let shared = CalendarDataManager()

    /// UserDefaults key for storing calendar events.
    private let eventsKey = "SavedCalendarEvents"

    /// UserDefaults instance for persistence.
    private let userDefaults: UserDefaults

    /// Private initializer to enforce singleton usage.
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Loads all calendar events from UserDefaults.
    /// - Returns: Array of `CalendarEvent` objects.
    func load() -> [CalendarEvent] {
        guard let data = userDefaults.data(forKey: eventsKey),
              let decodedEvents = try? JSONDecoder().decode([CalendarEvent].self, from: data)
        else {
            return []
        }
        return decodedEvents
    }

    /// Saves the provided events to UserDefaults.
    /// - Parameter events: Array of `CalendarEvent` objects to save.
    func save(events: [CalendarEvent]) {
        if let encoded = try? JSONEncoder().encode(events) {
            userDefaults.set(encoded, forKey: eventsKey)
        }
    }

    /// Adds a new calendar event to the stored events.
    /// - Parameter event: The `CalendarEvent` to add.
    func add(_ event: CalendarEvent) {
        var currentEvents = load()
        currentEvents.append(event)
        save(events: currentEvents)
    }

    /// Updates an existing calendar event.
    /// - Parameter event: The `CalendarEvent` to update.
    func update(_ event: CalendarEvent) {
        var currentEvents = load()
        if let index = currentEvents.firstIndex(where: { $0.id == event.id }) {
            currentEvents[index] = event
            save(events: currentEvents)
        }
    }

    /// Deletes a calendar event from storage.
    /// - Parameter event: The `CalendarEvent` to delete.
    func delete(_ event: CalendarEvent) {
        var currentEvents = load()
        currentEvents.removeAll { $0.id == event.id }
        save(events: currentEvents)
    }

    /// Finds a calendar event by its ID.
    /// - Parameter id: The UUID of the event to find.
    /// - Returns: The `CalendarEvent` if found, otherwise nil.
    func find(by id: UUID) -> CalendarEvent? {
        let events = load()
        return events.first { $0.id == id }
    }

    /// Gets events for a specific date.
    /// - Parameter date: The date to get events for.
    /// - Returns: Array of events on the specified date.
    func events(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: targetDate)!

        return load().filter { event in
            let eventDate = calendar.startOfDay(for: event.date)
            return eventDate >= targetDate && eventDate < nextDay
        }.sorted { $0.date < $1.date }
    }

    /// Gets events within a date range.
    /// - Parameters:
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: Array of events within the date range.
    func events(between startDate: Date, and endDate: Date) -> [CalendarEvent] {
        load().filter { event in
            event.date >= startDate && event.date <= endDate
        }.sorted { $0.date < $1.date }
    }

    /// Gets upcoming events within a specified number of days.
    /// - Parameter days: Number of days from now.
    /// - Returns: Array of upcoming events.
    func upcomingEvents(within days: Int) -> [CalendarEvent] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return load().filter { $0.date > Date() && $0.date <= futureDate }
            .sorted { $0.date < $1.date }
    }

    /// Gets events sorted by date.
    /// - Returns: Array of events sorted by date (soonest first).
    func eventsSortedByDate() -> [CalendarEvent] {
        load().sorted { $0.date < $1.date }
    }

    /// Clears all events from storage.
    func clearAllEvents() {
        userDefaults.removeObject(forKey: eventsKey)
    }

    /// Gets statistics about calendar events.
    /// - Returns: Dictionary with event statistics.
    func getEventStatistics() -> [String: Int] {
        let events = load()
        let total = events.count
        let today = self.events(for: Date()).count
        let thisWeek = upcomingEvents(within: 7).count

        return [
            "total": total,
            "today": today,
            "thisWeek": thisWeek,
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
