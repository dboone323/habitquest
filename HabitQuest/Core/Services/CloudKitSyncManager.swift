//
// CloudKitSyncManager.swift
// HabitQuest
//
// Manages CloudKit synchronization for habit data backup and multi-device sync.
// Works with SwiftData's automatic CloudKit mirroring.
//

import Foundation
import SwiftData
import CloudKit
import Combine

/// Manager for CloudKit synchronization of habit data.
@MainActor
public final class CloudKitSyncManager: ObservableObject {
    
    public static let shared = CloudKitSyncManager()
    
    /// Current sync status.
    @Published public private(set) var syncStatus: SyncStatus = .idle
    
    /// Last successful sync date.
    @Published public private(set) var lastSyncDate: Date?
    
    /// Error message if sync failed.
    @Published public private(set) var errorMessage: String?
    
    /// Container identifier for CloudKit.
    private let containerIdentifier = "iCloud.com.habitquest.app"
    
    private init() {}
    
    // MARK: - Sync Status
    
    public enum SyncStatus: String {
        case idle = "Idle"
        case syncing = "Syncing..."
        case synced = "Synced"
        case error = "Sync Error"
        case offline = "Offline"
    }
    
    // MARK: - CloudKit Availability
    
    /// Checks if CloudKit is available for the current user.
    public func checkCloudKitAvailability() async -> Bool {
        do {
            let status = try await CKContainer(identifier: containerIdentifier)
                .accountStatus()
            
            switch status {
            case .available:
                return true
            case .noAccount:
                errorMessage = "No iCloud account signed in"
                return false
            case .restricted:
                errorMessage = "iCloud access is restricted"
                return false
            case .couldNotDetermine:
                errorMessage = "Could not determine iCloud status"
                return false
            case .temporarilyUnavailable:
                errorMessage = "iCloud is temporarily unavailable"
                return false
            @unknown default:
                errorMessage = "Unknown iCloud status"
                return false
            }
        } catch {
            errorMessage = "Failed to check iCloud status: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Sync Operations
    
    /// Triggers a manual sync refresh.
    public func refreshSync() async {
        syncStatus = .syncing
        
        // Check availability first
        guard await checkCloudKitAvailability() else {
            syncStatus = .error
            return
        }
        
        // SwiftData handles automatic syncing when configured with CloudKit
        // This method is for UI feedback and manual refresh triggers
        
        // Simulate a brief sync operation
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        lastSyncDate = Date()
        syncStatus = .synced
        errorMessage = nil
        
        print("[CloudKitSync] Sync completed at \(lastSyncDate!)")
    }
    
    // MARK: - SwiftData Configuration
    
    /// Creates a ModelConfiguration with CloudKit sync enabled.
    /// - Returns: ModelConfiguration for SwiftData container.
    public static func createCloudKitModelConfiguration() -> ModelConfiguration {
        ModelConfiguration(
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
    }
    
    /// Creates a ModelContainer with CloudKit sync for Habit models.
    /// - Parameter schema: The schema containing habit-related models.
    /// - Returns: A ModelContainer configured for CloudKit sync.
    public static func createCloudKitContainer(for schema: Schema) throws -> ModelContainer {
        let config = createCloudKitModelConfiguration()
        return try ModelContainer(for: schema, configurations: [config])
    }
    
    // MARK: - Conflict Resolution
    
    /// Describes how to handle sync conflicts.
    public enum ConflictResolution {
        case serverWins
        case clientWins
        case merge
    }
    
    /// Current conflict resolution strategy.
    public var conflictResolution: ConflictResolution = .serverWins
}

// MARK: - Sync Status View Helper

extension CloudKitSyncManager.SyncStatus {
    
    /// SF Symbol name for the sync status.
    public var symbolName: String {
        switch self {
        case .idle:
            return "icloud"
        case .syncing:
            return "arrow.triangle.2.circlepath.icloud"
        case .synced:
            return "checkmark.icloud"
        case .error:
            return "exclamationmark.icloud"
        case .offline:
            return "icloud.slash"
        }
    }
    
    /// Color for the sync status indicator.
    public var colorName: String {
        switch self {
        case .idle:
            return "gray"
        case .syncing:
            return "blue"
        case .synced:
            return "green"
        case .error:
            return "red"
        case .offline:
            return "orange"
        }
    }
}
