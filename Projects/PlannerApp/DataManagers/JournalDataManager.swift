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

/// Legacy JournalDataManager - now delegates to PlannerDataManager for backward compatibility
/// This class is maintained for existing code that imports JournalDataManager directly
final class JournalDataManager: JournalDataManaging {
    /// Shared singleton instance - now delegates to PlannerDataManager
    static let shared = JournalDataManager()

    /// Delegate to the consolidated PlannerDataManager
    private let plannerDataManager = PlannerDataManager.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Loads all journal entries from PlannerDataManager.
    /// - Returns: Array of `JournalEntry` objects.
    func load() -> [JournalEntry] {
        return plannerDataManager.loadJournalEntries()
    }

    /// Saves the provided journal entries using PlannerDataManager.
    /// - Parameter entries: Array of `JournalEntry` objects to save.
    func save(entries: [JournalEntry]) {
        plannerDataManager.saveJournalEntries(entries)
    }

    /// Adds a new journal entry using PlannerDataManager.
    /// - Parameter entry: The `JournalEntry` to add.
    func add(_ entry: JournalEntry) {
        plannerDataManager.addJournalEntry(entry)
    }

    /// Updates an existing journal entry using PlannerDataManager.
    /// - Parameter entry: The `JournalEntry` to update.
    func update(_ entry: JournalEntry) {
        plannerDataManager.updateJournalEntry(entry)
    }

    /// Deletes a journal entry using PlannerDataManager.
    /// - Parameter entry: The `JournalEntry` to delete.
    func delete(_ entry: JournalEntry) {
        plannerDataManager.deleteJournalEntry(entry)
    }

    /// Finds a journal entry by its ID using PlannerDataManager.
    /// - Parameter id: The UUID of the journal entry to find.
    /// - Returns: The `JournalEntry` if found, otherwise nil.
    func find(by id: UUID) -> JournalEntry? {
        return plannerDataManager.findJournalEntry(by: id)
    }

    /// Gets journal entries for a specific date.
    /// - Parameter date: The date to get entries for.
    /// - Returns: Array of entries on the specified date.
    func entries(for date: Date) -> [JournalEntry] {
        return plannerDataManager.journalEntries(for: date)
    }

    /// Gets journal entries within a date range.
    /// - Parameters:
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: Array of entries within the date range.
    func entries(between startDate: Date, and endDate: Date) -> [JournalEntry] {
        return plannerDataManager.journalEntries(between: startDate, and: endDate)
    }

    /// Gets recent journal entries.
    /// - Parameter count: Number of recent entries to return.
    /// - Returns: Array of recent entries.
    func recentEntries(count: Int = 10) -> [JournalEntry] {
        return plannerDataManager.recentJournalEntries(count: count)
    }

    /// Gets journal entries with a specific mood.
    /// - Parameter mood: The mood to filter by.
    /// - Returns: Array of entries with the specified mood.
    func entries(withMood mood: String) -> [JournalEntry] {
        return plannerDataManager.journalEntries(withMood: mood)
    }

    /// Gets all unique moods from journal entries.
    /// - Returns: Array of unique mood strings.
    func uniqueMoods() -> [String] {
        return plannerDataManager.uniqueJournalMoods()
    }

    /// Gets journal entries sorted by date.
    /// - Returns: Array of entries sorted by date (most recent first).
    func entriesSortedByDate() -> [JournalEntry] {
        return plannerDataManager.journalEntriesSortedByDate()
    }

    /// Clears all journal entries from storage.
    func clearAllEntries() {
        // Note: This only clears journal entries, not other data types
        plannerDataManager.saveJournalEntries([])
    }

    /// Gets statistics about journal entries.
    /// - Returns: Dictionary with journal statistics.
    func getJournalStatistics() -> [String: Any] {
        return plannerDataManager.getJournalEntryStatistics()
    }
}
