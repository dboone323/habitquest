//
//  CloudKitBatchExtensions.swift
//  PlannerApp
//
//  CloudKit batch processing extensions for efficient data operations
//

import CloudKit

// MARK: - CloudKit Batch Processing Extensions

extension CloudKitManager {
    /// Upload multiple tasks to CloudKit in efficient batches with progress tracking
    func uploadTasksInBatches(_ tasks: [PlannerTask]) async throws {
        try await uploadItemsInBatches(tasks, recordType: "Task", batchSize: 100) { task in
            task.toCKRecord()
        }
    }

    /// Upload multiple goals to CloudKit in efficient batches with progress tracking
    func uploadGoalsInBatches(_ goals: [Goal]) async throws {
        try await uploadItemsInBatches(goals, recordType: "Goal", batchSize: 100) { goal in
            goal.toCKRecord()
        }
    }

    /// Upload multiple calendar events to CloudKit in efficient batches
    func uploadEventsInBatches(_ events: [CalendarEvent]) async throws {
        try await uploadItemsInBatches(events, recordType: "CalendarEvent", batchSize: 100) { event in
            event.toCKRecord()
        }
    }

    /// Upload multiple journal entries to CloudKit in efficient batches
    func uploadJournalEntriesInBatches(_ entries: [JournalEntry]) async throws {
        try await uploadItemsInBatches(entries, recordType: "JournalEntry", batchSize: 100) { entry in
            entry.toCKRecord()
        }
    }

    /// Generic batch upload function with progress tracking and error handling
    private func uploadItemsInBatches<T>(
        _ items: [T],
        recordType: String,
        batchSize: Int,
        recordConverter: (T) -> CKRecord
    ) async throws {
        guard !items.isEmpty else { return }

        let totalBatches = (items.count + batchSize - 1) / batchSize
        var completedBatches = 0

        for batchIndex in 0..<totalBatches {
            let startIndex = batchIndex * batchSize
            let endIndex = min(startIndex + batchSize, items.count)
            let batchItems = Array(items[startIndex..<endIndex])
            let records = batchItems.map(recordConverter)

            // Use CKModifyRecordsOperation for better control and error handling
            let modifyOperation = CKModifyRecordsOperation(
                recordsToSave: records,
                recordIDsToDelete: []
            )

            modifyOperation.savePolicy = .changedKeys
            modifyOperation.qualityOfService = .userInitiated

            // Configure progress tracking
            modifyOperation.perRecordProgressBlock = { record, progress in
                print("Uploading \(recordType): \(progress * 100)% complete for record \(record.recordID.recordName)")
            }

            modifyOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success(let savedRecords, _):
                    print("Successfully uploaded batch of \(savedRecords.count) \(recordType) records")
                case .failure(let error):
                    print("Failed to upload \(recordType) batch: \(error.localizedDescription)")
                }
            }

            // Execute the operation
            try await withCheckedThrowingContinuation { continuation in
                modifyOperation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                self.database.add(modifyOperation)
            }

            completedBatches += 1
            let progress = Double(completedBatches) / Double(totalBatches)
            self.syncProgress = progress
            print("Batch upload progress for \(recordType): \(Int(progress * 100))%")
        }

        print("Completed batch upload of \(items.count) \(recordType) items")
    }

    /// Batch delete operation for efficient record deletion
    func deleteRecordsInBatches(_ recordIDs: [CKRecord.ID], batchSize: Int = 100) async throws {
        guard !recordIDs.isEmpty else { return }

        let totalBatches = (recordIDs.count + batchSize - 1) / batchSize

        for batchIndex in 0..<totalBatches {
            let startIndex = batchIndex * batchSize
            let endIndex = min(startIndex + batchSize, recordIDs.count)
            let batchRecordIDs = Array(recordIDs[startIndex..<endIndex])

            let modifyOperation = CKModifyRecordsOperation(
                recordsToSave: [],
                recordIDsToDelete: batchRecordIDs
            )

            modifyOperation.qualityOfService = .userInitiated

            try await withCheckedThrowingContinuation { continuation in
                modifyOperation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success(_, let deletedRecordIDs):
                        print("Successfully deleted batch of \(deletedRecordIDs?.count ?? 0) records")
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                self.database.add(modifyOperation)
            }
        }

        print("Completed batch deletion of \(recordIDs.count) records")
    }

    /// Batch fetch operation for efficient record retrieval
    func fetchRecordsInBatches(recordIDs: [CKRecord.ID], batchSize: Int = 100) async throws -> [CKRecord] {
        guard !recordIDs.isEmpty else { return [] }

        var allRecords: [CKRecord] = []
        let totalBatches = (recordIDs.count + batchSize - 1) / batchSize

        for batchIndex in 0..<totalBatches {
            let startIndex = batchIndex * batchSize
            let endIndex = min(startIndex + batchSize, recordIDs.count)
            let batchRecordIDs = Array(recordIDs[startIndex..<endIndex])

            let fetchOperation = CKFetchRecordsOperation(recordIDs: batchRecordIDs)
            fetchOperation.qualityOfService = .userInitiated

            let batchRecords = try await withCheckedThrowingContinuation { continuation in
                var fetchedRecords: [CKRecord] = []

                fetchOperation.perRecordResultBlock = { recordID, result in
                    switch result {
                    case .success(let record):
                        fetchedRecords.append(record)
                    case .failure(let error):
                        print("Failed to fetch record \(recordID.recordName): \(error.localizedDescription)")
                    }
                }

                fetchOperation.fetchRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        continuation.resume(returning: fetchedRecords)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }

                self.database.add(fetchOperation)
            }

            allRecords.append(contentsOf: batchRecords)
        }

        print("Fetched \(allRecords.count) records in \(totalBatches) batches")
        return allRecords
    }

    /// Comprehensive batch sync operation that handles both upload and download
    func performBatchSync() async throws {
        self.syncStatus = .syncing
        self.syncProgress = 0.0

        do {
            // Phase 1: Upload local changes in batches
            try await uploadAllLocalChangesInBatches()
            self.syncProgress = 0.5

            // Phase 2: Download remote changes in batches
            try await downloadAllRemoteChangesInBatches()
            self.syncProgress = 1.0

            self.lastSyncDate = Date()
            self.syncStatus = .success
            print("Batch sync completed successfully")

        } catch {
            self.syncStatus = .error(.unknownError(error))
            throw error
        }
    }

    /// Upload all local changes using batch operations
    private func uploadAllLocalChangesInBatches() async throws {
        async let taskUpload = uploadTasksInBatches(self.tasks)
        async let goalUpload = uploadGoalsInBatches(self.goals)
        async let eventUpload = uploadEventsInBatches(self.calendarEvents)
        async let journalUpload = uploadJournalEntriesInBatches(self.journalEntries)

        try await taskUpload
        try await goalUpload
        try await eventUpload
        try await journalUpload
    }

    /// Download all remote changes using batch operations
    private func downloadAllRemoteChangesInBatches() async throws {
        async let taskDownload = downloadTasksInBatches()
        async let goalDownload = downloadGoalsInBatches()
        async let eventDownload = downloadEventsInBatches()
        async let journalDownload = downloadJournalEntriesInBatches()

        try await taskDownload
        try await goalDownload
        try await eventDownload
        try await journalDownload
    }

    /// Download tasks in batches from CloudKit
    private func downloadTasksInBatches() async throws {
        let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
        let records = try await fetchRecordsWithQueryInBatches(query, batchSize: 100)
        // Process records and update local storage
        print("Downloaded \(records.count) tasks in batches")
    }

    /// Download goals in batches from CloudKit
    private func downloadGoalsInBatches() async throws {
        let query = CKQuery(recordType: "Goal", predicate: NSPredicate(value: true))
        let records = try await fetchRecordsWithQueryInBatches(query, batchSize: 100)
        // Process records and update local storage
        print("Downloaded \(records.count) goals in batches")
    }

    /// Download events in batches from CloudKit
    private func downloadEventsInBatches() async throws {
        let query = CKQuery(recordType: "CalendarEvent", predicate: NSPredicate(value: true))
        let records = try await fetchRecordsWithQueryInBatches(query, batchSize: 100)
        // Process records and update local storage
        print("Downloaded \(records.count) events in batches")
    }

    /// Download journal entries in batches from CloudKit
    private func downloadJournalEntriesInBatches() async throws {
        let query = CKQuery(recordType: "JournalEntry", predicate: NSPredicate(value: true))
        let records = try await fetchRecordsWithQueryInBatches(query, batchSize: 100)
        // Process records and update local storage
        print("Downloaded \(records.count) journal entries in batches")
    }

    /// Fetch records with query using batch operations
    private func fetchRecordsWithQueryInBatches(_ query: CKQuery, batchSize: Int) async throws -> [CKRecord] {
        var allRecords: [CKRecord] = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            let queryOperation: CKQueryOperation
            if let cursor = cursor {
                queryOperation = CKQueryOperation(cursor: cursor)
            } else {
                queryOperation = CKQueryOperation(query: query)
            }

            queryOperation.resultsLimit = batchSize
            queryOperation.qualityOfService = .userInitiated

            let (batchRecords, batchCursor) = try await withCheckedThrowingContinuation { continuation in
                var fetchedRecords: [CKRecord] = []

                queryOperation.recordFetchedBlock = { record in
                    fetchedRecords.append(record)
                }

                queryOperation.queryResultBlock = { result in
                    switch result {
                    case .success(let cursor):
                        continuation.resume(returning: (fetchedRecords, cursor))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }

                self.database.add(queryOperation)
            }

            allRecords.append(contentsOf: batchRecords)
            cursor = batchCursor

        } while cursor != nil

        return allRecords
    }
}
