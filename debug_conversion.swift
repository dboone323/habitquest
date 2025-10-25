#!/usr/bin/env swift

import CloudKit
import Foundation

// Define the TaskPriority enum
enum TaskPriority: String, CaseIterable, Codable {
    case low, medium, high

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }
}

// Define the Task struct
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date?
    var createdAt: Date
    var modifiedAt: Date?

    init(
        id: UUID = UUID(), title: String, description: String = "", isCompleted: Bool = false,
        priority: TaskPriority = .medium, dueDate: Date? = nil, createdAt: Date = Date(),
        modifiedAt: Date? = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Task", recordID: CKRecord.ID(recordName: self.id.uuidString))
        record["title"] = self.title
        record["description"] = self.description
        record["isCompleted"] = self.isCompleted
        record["priority"] = self.priority.rawValue
        record["dueDate"] = self.dueDate
        record["createdAt"] = self.createdAt
        record["modifiedAt"] = self.modifiedAt
        return record
    }
}

// Test the conversion
let task = Task(
    id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!,
    title: "Test Task",
    description: "Test description",
    isCompleted: false,
    priority: .high,
    dueDate: Date(),
    createdAt: Date(),
    modifiedAt: Date()
)

print("Task created successfully")
print("Task ID: \(task.id)")
print("Task title: \(task.title)")

let record = task.toCKRecord()

print("Record created successfully")
print("Record type: \(record.recordType)")
print("Record ID: \(record.recordID.recordName)")
print("Title from record: \(record["title"] as? String ?? "nil")")
print("Description from record: \(record["description"] as? String ?? "nil")")
print("Priority from record: \(record["priority"] as? String ?? "nil")")
print("IsCompleted from record: \(record["isCompleted"] as? Bool ?? false)")
