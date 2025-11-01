//
//  ModelsTests.swift
//  PlannerAppTests
//
//  Created by Daniel Stevens on 4/28/25.
//
// swiftlint:disable identifier_name

import CloudKit
import Foundation
import SwiftData
import XCTest

@testable import PlannerApp

private typealias AppTask = PlannerTask

final class ModelsTests: XCTestCase {
    // MARK: - Task Model Tests

    @MainActor
    func testTaskCreation() {
        // Test basic task creation
        let task = AppTask(title: "Test Task", description: "A test task", priority: .medium, dueDate: Date())
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertEqual(task.description, "A test task")
        XCTAssertEqual(task.priority, TaskPriority.medium)
        XCTAssertFalse(task.isCompleted)
        XCTAssertNotNil(task.dueDate)
    }

    @MainActor
    func testTaskPriority() throws {
        let highPriorityTask = AppTask(title: "High Priority", description: "Urgent task", priority: .high, dueDate: Date())
        let lowPriorityTask = AppTask(title: "Low Priority", description: "Optional task", priority: .low, dueDate: Date())

        XCTAssertEqual(highPriorityTask.priority, TaskPriority.high)
        XCTAssertEqual(lowPriorityTask.priority, TaskPriority.low)
        XCTAssertNotEqual(highPriorityTask.priority, lowPriorityTask.priority)
        XCTAssertEqual(highPriorityTask.priority.sortOrder, 3)
        XCTAssertEqual(lowPriorityTask.priority.sortOrder, 1)
    }

    func testTaskDueDate() throws {
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday

        XCTAssertGreaterThan(futureDate, Date(), "Future date should be after current date")
        XCTAssertLessThan(pastDate, Date(), "Past date should be before current date")
    }

    func testTaskCompletionToggle() throws {
        var task = AppTask(title: "Toggle Test", description: "Test completion toggle")

        XCTAssertFalse(task.isCompleted)

        task.isCompleted = true
        XCTAssertTrue(task.isCompleted)

        task.isCompleted = false
        XCTAssertFalse(task.isCompleted)
    }

    func testTaskEquality() throws {
        let id = UUID()
        let task1 = AppTask(id: id, title: "Test", description: "Description")
        let task2 = AppTask(id: id, title: "Test", description: "Description")

        XCTAssertEqual(task1.id, task2.id)
        XCTAssertEqual(task1.title, task2.title)
    }

    // MARK: - Goal Model Tests

    func testGoalCreation() throws {
        let targetDate = Date().addingTimeInterval(7 * 86400) // One week from now
        let goal = Goal(title: "Test Goal", description: "A test goal", targetDate: targetDate)

        XCTAssertEqual(goal.title, "Test Goal")
        XCTAssertEqual(goal.description, "A test goal")
        XCTAssertEqual(goal.targetDate.timeIntervalSince1970, targetDate.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertFalse(goal.isCompleted)
        XCTAssertNotNil(goal.id)
        XCTAssertNotNil(goal.createdAt)
    }

    func testGoalCompletion() throws {
        var goal = Goal(title: "Completion Test", description: "Test completion", targetDate: Date().addingTimeInterval(86400))

        XCTAssertFalse(goal.isCompleted)

        goal.isCompleted = true
        XCTAssertTrue(goal.isCompleted)
    }

    @MainActor
    func testGoalPriorityDisplayNames() {
        XCTAssertEqual(GoalPriority.low.displayName, "Low")
        XCTAssertEqual(GoalPriority.medium.displayName, "Medium")
        XCTAssertEqual(GoalPriority.high.displayName, "High")
    }

    @MainActor
    func testGoalPrioritySortOrder() {
        XCTAssertEqual(GoalPriority.low.sortOrder, 1)
        XCTAssertEqual(GoalPriority.medium.sortOrder, 2)
        XCTAssertEqual(GoalPriority.high.sortOrder, 3)
        XCTAssertLessThan(GoalPriority.low.sortOrder, GoalPriority.medium.sortOrder)
        XCTAssertLessThan(GoalPriority.medium.sortOrder, GoalPriority.high.sortOrder)
    }

    @MainActor
    func testGoalPriorityAllCases() {
        let allCases = GoalPriority.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.low))
        XCTAssertTrue(allCases.contains(.medium))
        XCTAssertTrue(allCases.contains(.high))
    }

    @MainActor
    func testGoalInitialization() {
        let targetDate = Date().addingTimeInterval(86400 * 30)
        let goal = Goal(
            title: "Test Goal",
            description: "Test Description",
            targetDate: targetDate
        )

        XCTAssertNotNil(goal.id)
        XCTAssertEqual(goal.title, "Test Goal")
        XCTAssertEqual(goal.description, "Test Description")
        XCTAssertEqual(goal.targetDate, targetDate)
        XCTAssertFalse(goal.isCompleted)
        XCTAssertEqual(goal.priority, .medium)
        XCTAssertEqual(goal.progress, 0.0)
    }

    @MainActor
    func testGoalInitializationWithAllParameters() {
        let id = UUID()
        let targetDate = Date().addingTimeInterval(86400 * 30)
        let createdAt = Date()
        let modifiedAt = Date()

        let goal = Goal(
            id: id,
            title: "Test Goal",
            description: "Test Description",
            targetDate: targetDate,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            isCompleted: true,
            priority: .high,
            progress: 0.75
        )

        XCTAssertEqual(goal.id, id)
        XCTAssertEqual(goal.title, "Test Goal")
        XCTAssertEqual(goal.description, "Test Description")
        XCTAssertEqual(goal.targetDate, targetDate)
        XCTAssertEqual(goal.createdAt, createdAt)
        XCTAssertEqual(goal.modifiedAt, modifiedAt)
        XCTAssertTrue(goal.isCompleted)
        XCTAssertEqual(goal.priority, .high)
        XCTAssertEqual(goal.progress, 0.75)
    }

    @MainActor
    func testGoalProgressRange() {
        let goal1 = Goal(title: "Goal 1", description: "Desc", targetDate: Date(), progress: 0.0)
        let goal2 = Goal(title: "Goal 2", description: "Desc", targetDate: Date(), progress: 0.5)
        let goal3 = Goal(title: "Goal 3", description: "Desc", targetDate: Date(), progress: 1.0)

        XCTAssertEqual(goal1.progress, 0.0)
        XCTAssertEqual(goal2.progress, 0.5)
        XCTAssertEqual(goal3.progress, 1.0)
        XCTAssertGreaterThanOrEqual(goal1.progress, 0.0)
        XCTAssertLessThanOrEqual(goal3.progress, 1.0)
    }

    @MainActor
    func testGoalCodable() {
        let targetDate = Date().addingTimeInterval(86400 * 30)
        let originalGoal = Goal(
            title: "Test Goal",
            description: "Test Description",
            targetDate: targetDate,
            priority: .high,
            progress: 0.5
        )

        // Encode to JSON
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(originalGoal) else {
            XCTFail("Failed to encode goal")
            return
        }

        // Decode from JSON
        let decoder = JSONDecoder()
        guard let decodedGoal = try? decoder.decode(Goal.self, from: jsonData) else {
            XCTFail("Failed to decode goal")
            return
        }

        // Verify all properties
        XCTAssertEqual(decodedGoal.id, originalGoal.id)
        XCTAssertEqual(decodedGoal.title, originalGoal.title)
        XCTAssertEqual(decodedGoal.description, originalGoal.description)
        XCTAssertEqual(decodedGoal.targetDate.timeIntervalSince1970, originalGoal.targetDate.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(decodedGoal.isCompleted, originalGoal.isCompleted)
        XCTAssertEqual(decodedGoal.priority, originalGoal.priority)
        XCTAssertEqual(decodedGoal.progress, originalGoal.progress)
    }

    @MainActor
    func testGoalToCKRecord() {
        let id = UUID()
        let targetDate = Date().addingTimeInterval(86400 * 30)
        let createdAt = Date()
        let goal = Goal(
            id: id,
            title: "Test Goal",
            description: "Test Description",
            targetDate: targetDate,
            createdAt: createdAt,
            isCompleted: false,
            priority: .high,
            progress: 0.75
        )

        let ckRecord = goal.toCKRecord()

        XCTAssertEqual(ckRecord.recordType, "Goal")
        XCTAssertEqual(ckRecord.recordID.recordName, id.uuidString)
        XCTAssertEqual(ckRecord["title"] as? String, "Test Goal")
        XCTAssertEqual(ckRecord["description"] as? String, "Test Description")
        XCTAssertEqual(ckRecord["targetDate"] as? Date, targetDate)
        XCTAssertEqual(ckRecord["createdAt"] as? Date, createdAt)
        XCTAssertEqual(ckRecord["isCompleted"] as? Bool, false)
        XCTAssertEqual(ckRecord["priority"] as? String, "high")
        XCTAssertEqual(ckRecord["progress"] as? Double, 0.75)
    }

    @MainActor
    func testGoalFromCKRecord() {
        let id = UUID()
        let targetDate = Date().addingTimeInterval(86400 * 30)
        let createdAt = Date()
        let modifiedAt = Date()

        let ckRecord = CKRecord(recordType: "Goal", recordID: CKRecord.ID(recordName: id.uuidString))
        ckRecord["title"] = "Test Goal"
        ckRecord["description"] = "Test Description"
        ckRecord["targetDate"] = targetDate
        ckRecord["createdAt"] = createdAt
        ckRecord["modifiedAt"] = modifiedAt
        ckRecord["isCompleted"] = true
        ckRecord["priority"] = "high"
        ckRecord["progress"] = 0.75

        guard let goal = try? Goal.from(ckRecord: ckRecord) else {
            XCTFail("Failed to create Goal from CKRecord")
            return
        }

        XCTAssertEqual(goal.id, id)
        XCTAssertEqual(goal.title, "Test Goal")
        XCTAssertEqual(goal.description, "Test Description")
        XCTAssertEqual(goal.targetDate, targetDate)
        XCTAssertEqual(goal.createdAt, createdAt)
        XCTAssertEqual(goal.modifiedAt, modifiedAt)
        XCTAssertTrue(goal.isCompleted)
        XCTAssertEqual(goal.priority, .high)
        XCTAssertEqual(goal.progress, 0.75)
    }

    @MainActor
    func testGoalFromCKRecordWithDefaults() {
        let id = UUID()
        let targetDate = Date().addingTimeInterval(86400 * 30)

        // Minimal CKRecord with only required fields
        let ckRecord = CKRecord(recordType: "Goal", recordID: CKRecord.ID(recordName: id.uuidString))
        ckRecord["title"] = "Test Goal"
        ckRecord["targetDate"] = targetDate

        guard let goal = try? Goal.from(ckRecord: ckRecord) else {
            XCTFail("Failed to create Goal from minimal CKRecord")
            return
        }

        XCTAssertEqual(goal.id, id)
        XCTAssertEqual(goal.title, "Test Goal")
        XCTAssertEqual(goal.description, "")
        XCTAssertEqual(goal.targetDate, targetDate)
        XCTAssertFalse(goal.isCompleted)
        XCTAssertEqual(goal.priority, .medium)
        XCTAssertEqual(goal.progress, 0.0)
    }

    @MainActor
    func testGoalFromCKRecordFailure() {
        // CKRecord missing required fields
        let ckRecord = CKRecord(recordType: "Goal", recordID: CKRecord.ID(recordName: UUID().uuidString))

        XCTAssertThrowsError(try Goal.from(ckRecord: ckRecord)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "GoalConversionError")
            XCTAssertEqual(nsError.code, 1)
        }
    }

    @MainActor
    func testGoalPriorityComparison() {
        let lowGoal = Goal(title: "Low", description: "Desc", targetDate: Date(), priority: .low)
        let mediumGoal = Goal(title: "Medium", description: "Desc", targetDate: Date(), priority: .medium)
        let highGoal = Goal(title: "High", description: "Desc", targetDate: Date(), priority: .high)

        XCTAssertLessThan(lowGoal.priority.sortOrder, mediumGoal.priority.sortOrder)
        XCTAssertLessThan(mediumGoal.priority.sortOrder, highGoal.priority.sortOrder)
    }

    // MARK: - Calendar Event Tests

    @MainActor
    func testCalendarEventCreation() {
        let event = CalendarEvent(
            id: UUID(),
            title: "Test Event",
            date: Date()
        )

        XCTAssertEqual(event.title, "Test Event")
        XCTAssertNotNil(event.id)
    }

    @MainActor
    func testCalendarEventInitializationDefaults() {
        let date = Date().addingTimeInterval(3600)
        let event = CalendarEvent(title: "Meeting", date: date)

        XCTAssertEqual(event.title, "Meeting")
        XCTAssertEqual(event.date, date)
        XCTAssertNotNil(event.id)
        XCTAssertLessThanOrEqual(event.createdAt.timeIntervalSinceNow, 1.0)
        XCTAssertNotNil(event.modifiedAt)
    }

    @MainActor
    func testCalendarEventToCKRecord() {
        let id = UUID()
        let date = Date().addingTimeInterval(7200)
        let createdAt = Date()
        let modifiedAt = Date()
        let event = CalendarEvent(id: id, title: "Workshop", date: date, createdAt: createdAt, modifiedAt: modifiedAt)

        let record = event.toCKRecord()
        XCTAssertEqual(record.recordType, "CalendarEvent")
        XCTAssertEqual(record.recordID.recordName, id.uuidString)
        XCTAssertEqual(record["title"] as? String, "Workshop")
        XCTAssertEqual(record["date"] as? Date, date)
        XCTAssertEqual(record["createdAt"] as? Date, createdAt)
        XCTAssertEqual(record["modifiedAt"] as? Date, modifiedAt)
    }

    @MainActor
    func testCalendarEventFromCKRecord() {
        let id = UUID()
        let date = Date().addingTimeInterval(10800)
        let createdAt = Date()
        let modifiedAt = Date()
        let record = CKRecord(recordType: "CalendarEvent", recordID: CKRecord.ID(recordName: id.uuidString))
        record["title"] = "Conference"
        record["date"] = date
        record["createdAt"] = createdAt
        record["modifiedAt"] = modifiedAt

        guard let event = try? CalendarEvent.from(ckRecord: record) else {
            XCTFail("Failed to parse CalendarEvent from CKRecord")
            return
        }

        XCTAssertEqual(event.id, id)
        XCTAssertEqual(event.title, "Conference")
        XCTAssertEqual(event.date, date)
        XCTAssertEqual(event.createdAt, createdAt)
        XCTAssertEqual(event.modifiedAt, modifiedAt)
    }

    @MainActor
    func testCalendarEventFromCKRecordWithDefaults() {
        let id = UUID()
        let date = Date().addingTimeInterval(14400)
        let record = CKRecord(recordType: "CalendarEvent", recordID: CKRecord.ID(recordName: id.uuidString))
        record["title"] = "Sync"
        record["date"] = date
        // Note: No createdAt / modifiedAt provided

        guard let event = try? CalendarEvent.from(ckRecord: record) else {
            XCTFail("Failed to parse CalendarEvent from minimal CKRecord")
            return
        }

        XCTAssertEqual(event.id, id)
        XCTAssertEqual(event.title, "Sync")
        XCTAssertEqual(event.date, date)
        XCTAssertNotNil(event.createdAt)
        // modifiedAt may be nil
    }

    @MainActor
    func testCalendarEventFromCKRecordFailure() {
        // Missing required fields (title/date) should throw
        let badRecord = CKRecord(recordType: "CalendarEvent", recordID: CKRecord.ID(recordName: UUID().uuidString))
        XCTAssertThrowsError(try CalendarEvent.from(ckRecord: badRecord)) { error in
            let nserr = error as NSError
            XCTAssertEqual(nserr.domain, "CalendarEventConversionError")
            XCTAssertEqual(nserr.code, 1)
        }
    }

    @MainActor
    func testCalendarEventCodableRoundTrip() {
        let event = CalendarEvent(title: "Demo", date: Date().addingTimeInterval(1800))
        let enc = JSONEncoder()
        guard let data = try? enc.encode(event) else {
            XCTFail("Encode failed")
            return
        }
        let dec = JSONDecoder()
        guard let out = try? dec.decode(CalendarEvent.self, from: data) else {
            XCTFail("Decode failed")
            return
        }
        XCTAssertEqual(out.id, event.id)
        XCTAssertEqual(out.title, event.title)
        XCTAssertEqual(out.date.timeIntervalSince1970, event.date.timeIntervalSince1970, accuracy: 1.0)
    }

    // MARK: - PlannerTask Model Tests

    @MainActor
    func testTaskPriorityDisplayAndOrder() {
        XCTAssertEqual(TaskPriority.low.displayName, "Low")
        XCTAssertEqual(TaskPriority.medium.displayName, "Medium")
        XCTAssertEqual(TaskPriority.high.displayName, "High")
        XCTAssertLessThan(TaskPriority.low.sortOrder, TaskPriority.medium.sortOrder)
        XCTAssertLessThan(TaskPriority.medium.sortOrder, TaskPriority.high.sortOrder)
    }

    @MainActor
    func testPlannerTaskInitializationDefaults() {
        let t = PlannerTask(title: "Write tests")
        XCTAssertEqual(t.title, "Write tests")
        XCTAssertEqual(t.description, "")
        XCTAssertFalse(t.isCompleted)
        XCTAssertEqual(t.priority, .medium)
        XCTAssertNil(t.dueDate)
        XCTAssertNotNil(t.modifiedAt)
    }

    @MainActor
    func testPlannerTaskInitializationAllParams() {
        let id = UUID()
        let due = Date().addingTimeInterval(24 * 3600)
        let created = Date()
        let modified = Date()
        let t = PlannerTask(id: id, title: "Ship", description: "Release v1", isCompleted: true, priority: .high, dueDate: due, createdAt: created, modifiedAt: modified)
        XCTAssertEqual(t.id, id)
        XCTAssertEqual(t.title, "Ship")
        XCTAssertEqual(t.description, "Release v1")
        XCTAssertTrue(t.isCompleted)
        XCTAssertEqual(t.priority, .high)
        XCTAssertEqual(t.dueDate, due)
        XCTAssertEqual(t.createdAt, created)
        XCTAssertEqual(t.modifiedAt, modified)
    }

    @MainActor
    func testPlannerTaskToCKRecord() {
        let id = UUID()
        let due = Date().addingTimeInterval(3600)
        let created = Date()
        let modified = Date()
        let t = PlannerTask(id: id, title: "Plan", description: "Plan sprint", isCompleted: false, priority: .low, dueDate: due, createdAt: created, modifiedAt: modified)
        let r = t.toCKRecord()
        XCTAssertEqual(r.recordType, "Task")
        XCTAssertEqual(r.recordID.recordName, id.uuidString)
        XCTAssertEqual(r["title"] as? String, "Plan")
        XCTAssertEqual(r["description"] as? String, "Plan sprint")
        XCTAssertEqual(r["isCompleted"] as? Bool, false)
        XCTAssertEqual(r["priority"] as? String, "low")
        XCTAssertEqual(r["dueDate"] as? Date, due)
        XCTAssertEqual(r["createdAt"] as? Date, created)
        XCTAssertEqual(r["modifiedAt"] as? Date, modified)
    }

    @MainActor
    func testPlannerTaskFromCKRecordSimpleID() {
        let id = UUID()
        let created = Date()
        let r = CKRecord(recordType: "Task", recordID: CKRecord.ID(recordName: id.uuidString))
        r["title"] = "Do"
        r["description"] = "Do work"
        r["isCompleted"] = true
        r["priority"] = "high"
        r["createdAt"] = created
        let task = try? PlannerTask.from(ckRecord: r)
        XCTAssertNotNil(task)
        XCTAssertEqual(task?.id, id)
        XCTAssertEqual(task?.title, "Do")
        XCTAssertEqual(task?.description, "Do work")
        XCTAssertTrue(task?.isCompleted ?? false)
        XCTAssertEqual(task?.priority, .high)
        XCTAssertEqual(task?.createdAt, created)
    }

    @MainActor
    func testPlannerTaskFromCKRecordWithPathID() {
        let id = UUID()
        let created = Date()
        let r = CKRecord(recordType: "Task", recordID: CKRecord.ID(recordName: "Tasks/\(id.uuidString)"))
        r["title"] = "Path"
        r["createdAt"] = created
        let task = try? PlannerTask.from(ckRecord: r)
        XCTAssertNotNil(task)
        XCTAssertEqual(task?.id, id)
        XCTAssertEqual(task?.title, "Path")
        XCTAssertEqual(task?.createdAt, created)
    }

    @MainActor
    func testPlannerTaskFromCKRecordFailure() {
        let r = CKRecord(recordType: "Task", recordID: CKRecord.ID(recordName: UUID().uuidString))
        // Missing required "title" and "createdAt"
        XCTAssertThrowsError(try PlannerTask.from(ckRecord: r)) { error in
            let nserr = error as NSError
            XCTAssertEqual(nserr.domain, "TaskConversionError")
            XCTAssertEqual(nserr.code, 1)
        }
    }

    @MainActor
    func testPlannerTaskCodableRoundTrip() {
        let task = PlannerTask(title: "Round", description: "trip", priority: .medium)
        let data = try? JSONEncoder().encode(task)
        XCTAssertNotNil(data)
        let decoded = try? JSONDecoder().decode(PlannerTask.self, from: data!)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.id, task.id)
        XCTAssertEqual(decoded?.title, task.title)
        XCTAssertEqual(decoded?.description, task.description)
        XCTAssertEqual(decoded?.priority, task.priority)
    }
}
