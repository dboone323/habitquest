import CloudKit
import Foundation

// Test the Task toCKRecord conversion
struct Task {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: String
    var dueDate: Date?
    var createdAt: Date
    var modifiedAt: Date?

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Task", recordID: CKRecord.ID(recordName: self.id.uuidString))
        record["title"] = self.title
        record["description"] = self.description
        record["isCompleted"] = self.isCompleted
        record["priority"] = self.priority
        record["dueDate"] = self.dueDate
        record["createdAt"] = self.createdAt
        record["modifiedAt"] = self.modifiedAt
        return record
    }
}

let task = Task(
    id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!,
    title: "Test Task",
    description: "Test description",
    isCompleted: false,
    priority: "high",
    dueDate: Date(),
    createdAt: Date(),
    modifiedAt: Date()
)

let record = task.toCKRecord()

print("Record ID: \(record.recordID.recordName)")
print("Record Type: \(record.recordType)")
print("Title: \(record["title"] as? String ?? "nil")")
print("Description: \(record["description"] as? String ?? "nil")")
print("Priority: \(record["priority"] as? String ?? "nil")")
print("Is Completed: \(record["isCompleted"] as? Bool ?? false)")

// Test the assertions
let recordIdMatches = record.recordID.recordName == "12345678-1234-1234-1234-123456789012"
let recordTypeMatches = record.recordType == "Task"
let titleMatches = (record["title"] as? String) == "Test Task"
let descriptionMatches = (record["description"] as? String) == "Test description"
let priorityMatches = (record["priority"] as? String) == "high"
let isCompletedMatches = (record["isCompleted"] as? Bool) == false

print("\nAssertions:")
print("Record ID matches: \(recordIdMatches)")
print("Record type matches: \(recordTypeMatches)")
print("Title matches: \(titleMatches)")
print("Description matches: \(descriptionMatches)")
print("Priority matches: \(priorityMatches)")
print("Is completed matches: \(isCompletedMatches)")

let allPass = recordIdMatches && recordTypeMatches && titleMatches && descriptionMatches && priorityMatches && isCompletedMatches
print("\nAll assertions pass: \(allPass)")
