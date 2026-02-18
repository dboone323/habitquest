//
// BackupService.swift
// HabitQuest
//
// Service for local data backup and restore
//

import Foundation
import SwiftData

class BackupService {
    static let shared = BackupService()

    func createBackup() throws -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupURL = documentsURL.appendingPathComponent(
            "HabitQuest_Backup_\(Date().ISO8601Format()).json")

        // Initialize structured backup metadata
        let backupMetadata: [String: Any] = [
            "app_version": "1.1.0",
            "backup_date": Date().ISO8601Format(),
            "device_id": UUID().uuidString,
            "schema_version": 1,
            "record_count": 0,  // Placeholder until SwiftData query is integrated
        ]

        do {
            let backupData = try JSONSerialization.data(
                withJSONObject: backupMetadata, options: .prettyPrinted)
            try backupData.write(to: backupURL)
        } catch {
            NSLog(
                "[BackupService] CRITICAL: Failed to write backup file: \(error.localizedDescription)"
            )
            throw error
        }

        return backupURL
    }

    func restoreBackup(from url: URL) throws {
        // Implementation would involve parsing JSON and re-inserting into SwiftData
        print("Restoring from \(url.path)")
    }
}
