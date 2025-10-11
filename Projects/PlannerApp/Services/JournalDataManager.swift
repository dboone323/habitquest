import Foundation

/// Protocol defining the interface for journal entry data management
@MainActor
protocol JournalDataManaging {
    func load() -> [JournalEntry]
    func save(entries: [JournalEntry])
    func add(_ entry: JournalEntry)
    func update(_ entry: JournalEntry)
    func delete(_ entry: JournalEntry)
    func find(by id: UUID) -> JournalEntry?
}

/// Legacy JournalDataManager - now delegates to CloudKitManager for backward compatibility
/// This class is maintained for existing code that imports JournalDataManager directly
@MainActor
final class JournalDataManager: JournalDataManaging {
    /// Shared singleton instance - now delegates to CloudKitManager
    static let shared = JournalDataManager()

    /// Delegate to the consolidated CloudKitManager
    private let cloudKitManager = CloudKitManager.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Loads all journal entries from CloudKitManager.
    /// - Returns: Array of `JournalEntry` objects.
    func load() -> [JournalEntry] {
        return cloudKitManager.loadJournalEntries()
    }

    /// Saves the provided journal entries using CloudKitManager.
    /// - Parameter entries: Array of `JournalEntry` objects to save.
    func save(entries: [JournalEntry]) {
        cloudKitManager.saveJournalEntries(entries)
    }

    /// Adds a new journal entry using CloudKitManager.
    /// - Parameter entry: The `JournalEntry` to add.
    func add(_ entry: JournalEntry) {
        cloudKitManager.addJournalEntry(entry)
    }

    /// Updates an existing journal entry using CloudKitManager.
    /// - Parameter entry: The `JournalEntry` to update.
    func update(_ entry: JournalEntry) {
        cloudKitManager.updateJournalEntry(entry)
    }

    /// Deletes a journal entry using CloudKitManager.
    /// - Parameter entry: The `JournalEntry` to delete.
    func delete(_ entry: JournalEntry) {
        cloudKitManager.deleteJournalEntry(entry)
    }

    /// Finds a journal entry by its ID using CloudKitManager.
    /// - Parameter id: The UUID of the journal entry to find.
    /// - Returns: The `JournalEntry` if found, otherwise nil.
    func find(by id: UUID) -> JournalEntry? {
        return cloudKitManager.findJournalEntry(by: id)
    }

    /// Gets journal entries for a specific date.
    /// - Parameter date: The date to get entries for.
    /// - Returns: Array of entries on the specified date.
    func entries(for date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return cloudKitManager.journalEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }

    /// Gets journal entries within a date range.
    /// - Parameters:
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: Array of entries within the date range.
    func entries(between startDate: Date, and endDate: Date) -> [JournalEntry] {
        return cloudKitManager.journalEntries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }

    /// Gets recent journal entries.
    /// - Parameter count: Number of recent entries to return.
    /// - Returns: Array of recent entries.
    func recentEntries(count: Int = 10) -> [JournalEntry] {
        return cloudKitManager.journalEntries.sorted { $0.date > $1.date }.prefix(count).map { $0 }
    }

    /// Gets journal entries with a specific mood.
    /// - Parameter mood: The mood to filter by.
    /// - Returns: Array of entries with the specified mood.
    func entries(withMood mood: String) -> [JournalEntry] {
        return cloudKitManager.journalEntries.filter { $0.mood == mood }
    }

    /// Gets all unique moods from journal entries.
    /// - Returns: Array of unique mood strings.
    func uniqueMoods() -> [String] {
        let moods = cloudKitManager.journalEntries.compactMap { $0.mood }
        return Array(Set(moods)).sorted()
    }

    /// Gets journal entries sorted by date.
    /// - Returns: Array of entries sorted by date (most recent first).
    func entriesSortedByDate() -> [JournalEntry] {
        return cloudKitManager.journalEntries.sorted { $0.date > $1.date }
    }

    /// Clears all journal entries from storage.
    func clearAllEntries() {
        // Note: This only clears journal entries, not other data types
        cloudKitManager.saveJournalEntries([])
    }

    /// Gets statistics about journal entries.
    /// - Returns: Dictionary with journal statistics.
    func getJournalStatistics() -> [String: Any] {
        let total = cloudKitManager.journalEntries.count
        let moods = cloudKitManager.journalEntries.compactMap { $0.mood }
        let uniqueMoods = Set(moods).count

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        let entriesToday = cloudKitManager.journalEntries.filter { entry in
            entry.date >= todayStart && entry.date < todayEnd
        }.count

        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let entriesThisWeek = cloudKitManager.journalEntries.filter { $0.date >= thisWeekStart }.count

        return [
            "total": total,
            "uniqueMoods": uniqueMoods,
            "entriesToday": entriesToday,
            "entriesThisWeek": entriesThisWeek,
        ]
    }
}
