// MARK: - Calendar Event Model

import CloudKit
import Foundation

/// Represents a calendar event for PlannerApp, supporting CloudKit sync and Codable serialization.
public struct CalendarEvent: Identifiable, Codable {
    /// Unique identifier for the calendar event.
    public let id: UUID

    /// Title or description of the event.
    var title: String

    /// Date and time of the event.
    var date: Date

    /// Timestamp when the event was created.
    var createdAt: Date

    /// Timestamp when the event was last modified. Used for CloudKit sync/merge.
    var modifiedAt: Date?

    /// Initializes a new CalendarEvent.
    /// - Parameters:
    ///   - id: Unique identifier (default: new UUID).
    ///   - title: Title or description of the event.
    ///   - date: Date and time of the event.
    ///   - createdAt: Creation timestamp (default: now).
    ///   - modifiedAt: Last modified timestamp (default: now).
    init(
        id: UUID = UUID(), title: String, date: Date, createdAt: Date = Date(),
        modifiedAt: Date? = Date()
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    // MARK: - CloudKit Conversion

    /// Converts the CalendarEvent to a CloudKit record for syncing.
    /// - Returns: A `CKRecord` representing this event.
    func toCKRecord() -> CKRecord {
        let record = CKRecord(
            recordType: "CalendarEvent", recordID: CKRecord.ID(recordName: self.id.uuidString)
        )
        record["title"] = self.title
        record["date"] = self.date
        record["createdAt"] = self.createdAt
        record["modifiedAt"] = self.modifiedAt
        return record
    }

    /// Creates a CalendarEvent from a CloudKit record.
    /// - Parameter ckRecord: The CloudKit record to convert.
    /// - Throws: An error if conversion fails.
    /// - Returns: A `CalendarEvent` instance.
    static func from(ckRecord: CKRecord) throws -> CalendarEvent {
        guard let title = ckRecord["title"] as? String,
              let date = ckRecord["date"] as? Date,
              let id = UUID(uuidString: ckRecord.recordID.recordName)
        else {
            throw NSError(
                domain: "CalendarEventConversionError", code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to convert CloudKit record to CalendarEvent",
                ]
            )
        }

        return CalendarEvent(
            id: id,
            title: title,
            date: date,
            createdAt: ckRecord["createdAt"] as? Date ?? Date(),
            modifiedAt: ckRecord["modifiedAt"] as? Date
        )
    }
}
