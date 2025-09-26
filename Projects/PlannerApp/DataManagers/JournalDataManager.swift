import Foundation

/// Protocol defining the interface for journal entry data management
protocol JournalDataManaging {
    func load() -> [JournalEntry]
    func save(entries: [JournalEntry])
    func add(_ entry: JournalEntry)
    func update(_ entry: JournalEntry)
    func delete(_ entry: JournalEntry)
    func find(by id: UUID) -> JournalEntry?
}

/// Manages storage and retrieval of `JournalEntry` objects with UserDefaults persistence.
final class JournalDataManager: JournalDataManaging {
    /// Shared singleton instance.
    static let shared = JournalDataManager()

    /// UserDefaults key for storing journal entries.
    private let entriesKey = "SavedJournalEntries"

    /// UserDefaults instance for persistence.
    private let userDefaults: UserDefaults

    /// Private initializer to enforce singleton usage.
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Loads all journal entries from UserDefaults.
    /// - Returns: Array of `JournalEntry` objects.
    func load() -> [JournalEntry] {
        guard let data = userDefaults.data(forKey: entriesKey),
              let decodedEntries = try? JSONDecoder().decode([JournalEntry].self, from: data)
        else {
            return []
        }
        return decodedEntries
    }

    /// Saves the provided journal entries to UserDefaults.
    /// - Parameter entries: Array of `JournalEntry` objects to save.
    func save(entries: [JournalEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
    }

    /// Adds a new journal entry to the stored entries.
    /// - Parameter entry: The `JournalEntry` to add.
    func add(_ entry: JournalEntry) {
        var currentEntries = load()
        currentEntries.append(entry)
        save(entries: currentEntries)
    }

    /// Updates an existing journal entry.
    /// - Parameter entry: The `JournalEntry` to update.
    func update(_ entry: JournalEntry) {
        var currentEntries = load()
        if let index = currentEntries.firstIndex(where: { $0.id == entry.id }) {
            currentEntries[index] = entry
            save(entries: currentEntries)
        }
    }

    /// Deletes a journal entry from storage.
    /// - Parameter entry: The `JournalEntry` to delete.
    func delete(_ entry: JournalEntry) {
        var currentEntries = load()
        currentEntries.removeAll { $0.id == entry.id }
        save(entries: currentEntries)
    }

    /// Finds a journal entry by its ID.
    /// - Parameter id: The UUID of the entry to find.
    /// - Returns: The `JournalEntry` if found, otherwise nil.
    func find(by id: UUID) -> JournalEntry? {
        let entries = load()
        return entries.first { $0.id == id }
    }

    /// Gets journal entries for a specific date.
    /// - Parameter date: The date to get entries for.
    /// - Returns: Array of entries on the specified date.
    func entries(for date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: targetDate)!

        return load().filter { entry in
            let entryDate = calendar.startOfDay(for: entry.date)
            return entryDate >= targetDate && entryDate < nextDay
        }.sorted { $0.date > $1.date } // Most recent first
    }

    /// Gets journal entries within a date range.
    /// - Parameters:
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: Array of entries within the date range.
    func entries(between startDate: Date, and endDate: Date) -> [JournalEntry] {
        load().filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }.sorted { $0.date > $1.date }
    }

    /// Gets recent journal entries.
    /// - Parameter count: Number of recent entries to return.
    /// - Returns: Array of recent entries.
    func recentEntries(count: Int = 10) -> [JournalEntry] {
        load().sorted { $0.date > $1.date }.prefix(count).map(\.self)
    }

    /// Gets journal entries with a specific mood.
    /// - Parameter mood: The mood to filter by.
    /// - Returns: Array of entries with the specified mood.
    func entries(withMood mood: String) -> [JournalEntry] {
        load().filter { $0.mood == mood }.sorted { $0.date > $1.date }
    }

    /// Gets all unique moods from journal entries.
    /// - Returns: Array of unique mood strings.
    func uniqueMoods() -> [String] {
        let moods = load().map(\.mood)
        return Array(Set(moods)).sorted()
    }

    /// Gets journal entries sorted by date.
    /// - Returns: Array of entries sorted by date (most recent first).
    func entriesSortedByDate() -> [JournalEntry] {
        load().sorted { $0.date > $1.date }
    }

    /// Clears all journal entries from storage.
    func clearAllEntries() {
        userDefaults.removeObject(forKey: entriesKey)
    }

    /// Gets statistics about journal entries.
    /// - Returns: Dictionary with journal statistics.
    func getJournalStatistics() -> [String: Any] {
        let entries = load()
        let total = entries.count
        let thisWeek = self.entries(between: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), and: Date()).count
        let moods = uniqueMoods()

        return [
            "total": total,
            "thisWeek": thisWeek,
            "uniqueMoods": moods.count,
            "moods": moods,
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
