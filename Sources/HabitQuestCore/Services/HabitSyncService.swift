//
// HabitSyncService.swift
// HabitQuestCore
//

import CloudKit
import Combine
import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.habitquest.core", category: "HabitSyncService")

/// Comprehensive service for managing CloudKit synchronization and data availability.
/// Replaces the monolithic CloudKitSyncManager.
@MainActor
public final class HabitSyncService: ObservableObject, Sendable {
    public static let shared = HabitSyncService()

    /// Current synchronization status.
    @Published public private(set) var syncStatus: SyncStatus = .idle

    /// Last successful sync date.
    @Published public private(set) var lastSyncDate: Date?

    /// Descriptive error message if synchronization fails.
    @Published public private(set) var errorMessage: String?

    private let containerIdentifier = "iCloud.com.habitquest.app"

    private init() {}

    // MARK: - Sync Status

    public enum SyncStatus: String, Sendable {
        case idle = "Idle"
        case syncing = "Syncing..."
        case synced = "Synced"
        case error = "Sync Error"
        case offline = "Offline"

        public var symbolName: String {
            switch self {
            case .idle: "icloud"
            case .syncing: "arrow.triangle.2.circlepath.icloud"
            case .synced: "checkmark.icloud"
            case .error: "exclamationmark.icloud"
            case .offline: "icloud.slash"
            }
        }
    }

    // MARK: - Availability & Operations

    /// Checks if CloudKit is currently available for the user.
    public func checkCloudKitAvailability() async -> Bool {
        do {
            let status = try await CKContainer(identifier: containerIdentifier).accountStatus()
            switch status {
            case .available:
                return true
            case .noAccount:
                errorMessage = "No iCloud account found."
                return false
            default:
                errorMessage = "iCloud is restricted or unavailable."
                return false
            }
        } catch {
            errorMessage = "CloudKit error: \(error.localizedDescription)"
            return false
        }
    }

    /// Triggers a manual sync refresh with simulated UI feedback.
    public func refreshSync() async {
        syncStatus = .syncing
        guard await checkCloudKitAvailability() else {
            syncStatus = .error
            return
        }

        // SwiftData handles the actual mirroring; we provide the status lifecycle.
        try? await Task.sleep(nanoseconds: 300_000_000)

        lastSyncDate = Date()
        syncStatus = .synced
        errorMessage = nil
        logger.info("CloudKit sync refresh completed.")
    }

    // MARK: - SwiftData Integration

    /// Standard CloudKit configuration for SwiftData.
    public static func createCloudConfiguration() -> ModelConfiguration {
        ModelConfiguration(isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)
    }
}
