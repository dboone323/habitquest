// MARK: - Data Manager

import CloudKit
import Foundation

/// Manages storage and retrieval of `JournalEntry` objects in memory.
class JournalDataManager {
    /// Shared singleton instance.
    static let shared = JournalDataManager()

    /// In-memory storage for journal entries.
    var entries: [JournalEntry] = []

    /// Removes all journal entries from memory.
    func clearAllEntries() {
        self.entries.removeAll()
    }

    /// Loads all journal entries from memory.
    /// - Returns: Array of `JournalEntry` objects.
    func load() -> [JournalEntry] {
        self.entries
    }

    /// Saves the provided journal entries to memory.
    /// - Parameter entries: Array of `JournalEntry` objects to save.
    func save(entries: [JournalEntry]) {
        self.entries = entries
    }

    /// Private initializer to enforce singleton usage.
    private init() {}
}

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var title: String
    var body: String
    var date: Date
    var mood: String
    var modifiedAt: Date? // Added for CloudKit sync/merge

    init(
        id: UUID = UUID(), title: String, body: String, date: Date, mood: String,
        modifiedAt: Date? = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.mood = mood
        self.modifiedAt = modifiedAt
    }

    // MARK: - CloudKit Conversion

    /// Convert to CloudKit record for syncing
    func toCKRecord() -> CKRecord {
        let record = CKRecord(
            recordType: "JournalEntry", recordID: CKRecord.ID(recordName: self.id.uuidString)
        )
        record["title"] = self.title
        record["body"] = self.body
        record["date"] = self.date
        record["mood"] = self.mood
        record["modifiedAt"] = self.modifiedAt
        return record
    }

    /// Create a JournalEntry from CloudKit record
    static func from(ckRecord: CKRecord) throws -> JournalEntry {
        guard let title = ckRecord["title"] as? String,
              let body = ckRecord["body"] as? String,
              let date = ckRecord["date"] as? Date,
              let mood = ckRecord["mood"] as? String,
              let id = UUID(uuidString: ckRecord.recordID.recordName)
        else {
            throw NSError(
                domain: "JournalEntryConversionError", code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to convert CloudKit record to JournalEntry"
                ]
            )
        }

        return JournalEntry(
            id: id,
            title: title,
            body: body,
            date: date,
            mood: mood,
            modifiedAt: ckRecord["modifiedAt"] as? Date
        )
    }
}
