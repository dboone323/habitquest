//
//  CloudKitTypes.swift
//  PlannerApp
//
//  Data types and enums for CloudKit integration
//

import CloudKit
import Foundation

// MARK: - Sync Status

public enum SyncStatus: Equatable {
    case idle
    case syncing
    case success
    case error(CloudKitError)
    case conflictResolutionNeeded
    case temporarilyUnavailable

    public static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.syncing, .syncing), (.success, .success),
             (.conflictResolutionNeeded, .conflictResolutionNeeded),
             (.temporarilyUnavailable, .temporarilyUnavailable):
            true
        case let (.error(lhsError), .error(rhsError)):
            lhsError.id == rhsError.id
        default:
            false
        }
    }

    public var isActive: Bool {
        switch self {
        case .syncing, .conflictResolutionNeeded:
            true
        default:
            false
        }
    }

    public var description: String {
        switch self {
        case .idle: "Ready to sync"
        case .syncing: "Syncing..."
        case .success: "Sync completed"
        case let .error(error): "Sync error: \(error.localizedDescription)"
        case .conflictResolutionNeeded: "Conflicts need resolution"
        case .temporarilyUnavailable: "Sync temporarily unavailable"
        }
    }
}

// MARK: - Sync Conflict

public struct SyncConflict: Identifiable {
    public let id = UUID()
    public let recordID: CKRecord.ID
    public let localRecord: CKRecord
    public let serverRecord: CKRecord
    public let type: ConflictType

    public enum ConflictType {
        case modified
        case deleted
        case created
    }
}

// MARK: - CloudKit Error Types

/// Enhanced CloudKit error types for better user feedback
public enum CloudKitError: Error, Identifiable {
    case notSignedIn
    case networkIssue
    case permissionDenied
    case quotaExceeded
    case deviceBusy
    case serverError
    case accountChanged
    case containerUnavailable
    case conflictDetected
    case unknownError(Error)

    public var id: String { self.localizedDescription }

    // Provide a user-friendly message
    public var localizedDescription: String {
        switch self {
        case .notSignedIn:
            "You're not signed in to iCloud"
        case .networkIssue:
            "Network connection issue"
        case .permissionDenied:
            "iCloud access was denied"
        case .quotaExceeded:
            "Your iCloud storage is full"
        case .deviceBusy:
            "Your device is busy"
        case .serverError:
            "iCloud server issue"
        case .accountChanged:
            "Your iCloud account has changed"
        case .containerUnavailable:
            "iCloud container unavailable"
        case .conflictDetected:
            "Data conflict detected"
        case let .unknownError(error):
            "Unexpected error: \(error.localizedDescription)"
        }
    }

    // Provide a detailed explanation
    public var explanation: String {
        switch self {
        case .notSignedIn:
            "You need to be signed in to iCloud to enable syncing across your devices."
        case .networkIssue:
            "There seems to be an issue with your internet connection."
        case .permissionDenied:
            "This app doesn't have permission to access your iCloud data."
        case .quotaExceeded:
            "You've reached your iCloud storage limit, which prevents syncing new data."
        case .deviceBusy:
            "Your device is currently busy processing other tasks."
        case .serverError:
            "Apple's iCloud servers are experiencing technical difficulties."
        case .accountChanged:
            "Your iCloud account has changed since the last sync."
        case .containerUnavailable:
            "The app's iCloud container couldn't be accessed."
        case .conflictDetected:
            "Changes were made to the same data on multiple devices."
        case .unknownError:
            "An unexpected error occurred while syncing your data."
        }
    }

    // Provide a recovery suggestion
    public var recoverySuggestion: String {
        switch self {
        case .notSignedIn:
            #if os(iOS)
            return "Go to Settings → Apple ID → iCloud and sign in with your Apple ID."
            #else
            return "Go to System Settings → Apple ID → iCloud and sign in with your Apple ID."
            #endif
        case .networkIssue:
            return "Check your Wi-Fi connection or cellular data. Try syncing again when your connection improves."
        case .permissionDenied:
            #if os(iOS)
            return "Go to Settings → Apple ID → iCloud → Apps Using iCloud and enable this app."
            #else
            return "Go to System Settings → Apple ID → iCloud and ensure this app is enabled."
            #endif
        case .quotaExceeded:
            #if os(iOS)
            return "Go to Settings → Apple ID → iCloud → Manage Storage to free up space or upgrade your storage plan."
            #else
            return "Go to System Settings → Apple ID → iCloud → Manage Storage to free up space."
            #endif
        case .deviceBusy:
            return "Close some other apps and try again. If the issue persists, restart your device."
        case .serverError:
            return "This is a temporary issue with Apple's servers. Please try again after a while."
        case .accountChanged:
            return "Sign in to your current iCloud account in Settings, then restart the app."
        case .containerUnavailable:
            return "Check that iCloud is enabled for this app in Settings. If the issue persists, restart your device."
        case .conflictDetected:
            return "Review the conflicted items and choose which version to keep."
        case .unknownError:
            return "Try restarting the app. If the issue continues, please contact support."
        }
    }

    // Suggest an action the user can take
    public var actionLabel: String {
        switch self {
        case .notSignedIn:
            "Open Settings"
        case .networkIssue:
            "Check Connection"
        case .permissionDenied:
            "Open iCloud Settings"
        case .quotaExceeded:
            "Manage Storage"
        case .deviceBusy, .serverError, .containerUnavailable:
            "Try Again"
        case .accountChanged:
            "Open Settings"
        case .conflictDetected:
            "Review Conflicts"
        case .unknownError:
            "Restart App"
        }
    }

    // Convert from CKError to CloudKitError
    public static func fromCKError(_ error: Error) -> CloudKitError {
        guard let ckError = error as? CKError else {
            return .unknownError(error)
        }

        switch ckError.code {
        case .notAuthenticated, .badContainer:
            return .notSignedIn
        case .networkFailure, .networkUnavailable, .serverRejectedRequest, .serviceUnavailable:
            return .networkIssue
        case .permissionFailure:
            return .permissionDenied
        case .quotaExceeded:
            return .quotaExceeded
        case .zoneBusy, .resultsTruncated:
            return .deviceBusy
        case .serverRecordChanged, .batchRequestFailed, .assetFileNotFound:
            return .serverError
        case .changeTokenExpired, .accountTemporarilyUnavailable:
            return .accountChanged
        default:
            return .unknownError(error)
        }
    }
}
