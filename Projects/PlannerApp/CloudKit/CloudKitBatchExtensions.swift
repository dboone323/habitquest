//
//  CloudKitBatchExtensions.swift
//  PlannerApp
//
//  CloudKit batch processing extensions for efficient data operations
//

import CloudKit

// MARK: - CloudKit Batch Processing Extensions

extension EnhancedCloudKitManager {
    /// Upload multiple tasks to CloudKit in efficient batches
    func uploadTasksInBatches(_ tasks: [PlannerTask]) async throws {
        let batchSize = 100
        for batch in stride(from: 0, to: tasks.count, by: batchSize) {
            let endIndex = min(batch + batchSize, tasks.count)
            let batchTasks = Array(tasks[batch ..< endIndex])
            let records = batchTasks.map { $0.toCKRecord() }

            _ = try await self.database.modifyRecords(
                saving: records,
                deleting: []
            )

            // Process results if needed
            print("Batch uploaded: \(records.count) tasks")
        }
    }

    /// Upload multiple goals to CloudKit in efficient batches
    func uploadGoalsInBatches(_ goals: [Goal]) async throws {
        let batchSize = 100
        for batch in stride(from: 0, to: goals.count, by: batchSize) {
            let endIndex = min(batch + batchSize, goals.count)
            let batchGoals = Array(goals[batch ..< endIndex])
            let records = batchGoals.map { $0.toCKRecord() }

            _ = try await self.database.modifyRecords(
                saving: records,
                deleting: []
            )

            print("Batch uploaded: \(records.count) goals")
        }
    }
}
