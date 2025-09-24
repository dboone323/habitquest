// MARK: - Data Manager

import CloudKit
import Foundation

/// Represents the priority of a goal (low, medium, high).
public enum GoalPriority: String, CaseIterable, Codable {
    /// Low priority goal.
    case low
    /// Medium priority goal.
    case medium
    /// High priority goal.
    case high

    /// Human-readable display name for the priority.
    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    /// Sort order for priority (higher values = higher priority).
    var sortOrder: Int {
        switch self {
        case .low: 1
        case .medium: 2
        case .high: 3
        }
    }
}

/// Represents a user goal in the PlannerApp (e.g., "Run a marathon").
public struct Goal: Identifiable, Codable {
    /// Unique identifier for the goal.
    public let id: UUID
    /// The title or summary of the goal.
    var title: String
    /// Detailed description of the goal.
    var description: String
    /// The target date to achieve the goal.
    var targetDate: Date
    /// The date the goal was created.
    var createdAt: Date
    /// The date the goal was last modified (optional).
    var modifiedAt: Date? // Added for CloudKit sync/merge
    /// Whether the goal is completed.
    var isCompleted: Bool // Adding completion status for goals
    /// The priority of the goal.
    var priority: GoalPriority // Goal priority
    /// The progress toward the goal (0.0 to 1.0).
    var progress: Double // Goal progress (0.0 to 1.0)

    /// Creates a new goal.
    /// - Parameters:
    ///   - id: The unique identifier (default: new UUID).
    ///   - title: The goal title.
    ///   - description: The goal description.
    ///   - targetDate: The target date to achieve the goal.
    ///   - createdAt: The creation date (default: now).
    ///   - modifiedAt: The last modified date (default: now).
    ///   - isCompleted: Whether the goal is completed (default: false).
    ///   - priority: The goal priority (default: .medium).
    ///   - progress: The progress toward the goal (default: 0.0).
    init(
        id: UUID = UUID(), title: String, description: String, targetDate: Date,
        createdAt: Date = Date(), modifiedAt: Date? = Date(), isCompleted: Bool = false,
        priority: GoalPriority = .medium, progress: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.isCompleted = isCompleted
        self.priority = priority
        self.progress = progress
    }

    // MARK: - CloudKit Conversion

    /// Converts this goal to a CloudKit record for syncing.
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Goal", recordID: CKRecord.ID(recordName: self.id.uuidString))
        record["title"] = self.title
        record["description"] = self.description
        record["targetDate"] = self.targetDate
        record["createdAt"] = self.createdAt
        record["modifiedAt"] = self.modifiedAt
        record["isCompleted"] = self.isCompleted
        record["priority"] = self.priority.rawValue
        record["progress"] = self.progress
        return record
    }

    /// Creates a Goal from a CloudKit record.
    /// - Parameter ckRecord: The CloudKit record to convert.
    /// - Throws: An error if conversion fails.
    /// - Returns: A Goal instance.
    static func from(ckRecord: CKRecord) throws -> Goal {
        guard let title = ckRecord["title"] as? String,
              let targetDate = ckRecord["targetDate"] as? Date,
              let id = UUID(uuidString: ckRecord.recordID.recordName)
        else {
            throw NSError(
                domain: "GoalConversionError", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert CloudKit record to Goal"]
            )
        }

        let priorityString = ckRecord["priority"] as? String ?? "medium"
        let priority = GoalPriority(rawValue: priorityString) ?? .medium

        return Goal(
            id: id,
            title: title,
            description: ckRecord["description"] as? String ?? "",
            targetDate: targetDate,
            createdAt: ckRecord["createdAt"] as? Date ?? Date(),
            modifiedAt: ckRecord["modifiedAt"] as? Date,
            isCompleted: ckRecord["isCompleted"] as? Bool ?? false,
            priority: priority,
            progress: ckRecord["progress"] as? Double ?? 0.0
        )
    }
}
