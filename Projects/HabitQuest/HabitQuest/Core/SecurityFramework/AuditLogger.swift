//
//  AuditLogger.swift
//  HabitQuest
//
//  Created by Code Review Agent on 2025-10-30
//  Copyright © 2025 HabitQuest. All rights reserved.
//

import CryptoKit
import Foundation
import OSLog

/// Audit event types specific to habit tracking operations
public enum AuditEventType: String, Codable, Sendable {
    case habitCreation = "habit_creation"
    case habitUpdate = "habit_update"
    case habitDeletion = "habit_deletion"
    case habitCompletion = "habit_completion"
    case habitLogCreation = "habit_log_creation"
    case habitLogUpdate = "habit_log_update"
    case habitLogDeletion = "habit_log_deletion"
    case achievementUnlocked = "achievement_unlocked"
    case streakMilestone = "streak_milestone"
    case playerProfileUpdate = "player_profile_update"
    case notificationPreferenceUpdate = "notification_preference_update"
    case dataExport = "data_export"
    case dataDeletion = "data_deletion"
    case consentUpdate = "consent_update"
    case privacySettingsUpdate = "privacy_settings_update"
}

/// Audit severity levels
public enum AuditSeverity: String, Codable, Sendable {
    case info
    case warning
    case error
    case critical
}

/// Audit log entry structure
public struct AuditLogEntry: Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let eventType: AuditEventType
    public let severity: AuditSeverity
    public let userId: String?
    public let resourceId: String?
    public let resourceType: String?
    public let action: String
    public let details: [String: String]?
    public let ipAddress: String?
    public let userAgent: String?
    public let success: Bool
    public let errorMessage: String?

    public init(
        eventType: AuditEventType,
        severity: AuditSeverity = .info,
        userId: String? = nil,
        resourceId: String? = nil,
        resourceType: String? = nil,
        action: String,
        details: [String: String]? = nil,
        ipAddress: String? = nil,
        userAgent: String? = nil,
        success: Bool = true,
        errorMessage: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.eventType = eventType
        self.severity = severity
        self.userId = userId
        self.resourceId = resourceId
        self.resourceType = resourceType
        self.action = action
        self.details = details
        self.ipAddress = ipAddress
        self.userAgent = userAgent
        self.success = success
        self.errorMessage = errorMessage
    }
}

/// Enterprise-grade audit logging system for HabitQuest
/// Provides comprehensive logging of all habit tracking operations with encryption and compliance monitoring
@MainActor
public final class AuditLogger: Sendable {
    public static let shared = AuditLogger()

    private let logger = Logger.shared
    private let encryptionService = EncryptionService.shared
    private let logQueue = DispatchQueue(label: "com.habitquest.audit.queue", qos: .utility)

    private init() {}

    // MARK: - Habit Operations

    /// Log habit creation with encrypted audit trail
    public func logHabitCreation(habitId: String, habitName: String, userId: String? = nil) async {
        let details = ["habit_name": habitName]
        await logEvent(
            type: .habitCreation,
            userId: userId,
            resourceId: habitId,
            resourceType: "habit",
            action: "create_habit",
            details: details
        )
    }

    /// Log habit update with change tracking
    public func logHabitUpdate(habitId: String, changes: [String: String], userId: String? = nil) async {
        await logEvent(
            type: .habitUpdate,
            userId: userId,
            resourceId: habitId,
            resourceType: "habit",
            action: "update_habit",
            details: changes
        )
    }

    /// Log habit deletion with compliance tracking
    public func logHabitDeletion(habitId: String, habitName: String, userId: String? = nil) async {
        let details = ["habit_name": habitName, "compliance_reason": "user_initiated_deletion"]
        await logEvent(
            type: .habitDeletion,
            severity: .warning,
            userId: userId,
            resourceId: habitId,
            resourceType: "habit",
            action: "delete_habit",
            details: details
        )
    }

    /// Log habit completion with streak tracking
    public func logHabitCompletion(habitId: String, habitName: String, streakCount: Int, userId: String? = nil) async {
        let details = [
            "habit_name": habitName,
            "streak_count": String(streakCount),
            "completion_date": ISO8601DateFormatter().string(from: Date()),
        ]
        await logEvent(
            type: .habitCompletion,
            userId: userId,
            resourceId: habitId,
            resourceType: "habit",
            action: "complete_habit",
            details: details
        )
    }

    // MARK: - Habit Log Operations

    /// Log habit log creation
    public func logHabitLogCreation(logId: String, habitId: String, completionDate: Date, userId: String? = nil) async {
        let details = [
            "habit_id": habitId,
            "completion_date": ISO8601DateFormatter().string(from: completionDate),
        ]
        await logEvent(
            type: .habitLogCreation,
            userId: userId,
            resourceId: logId,
            resourceType: "habit_log",
            action: "create_habit_log",
            details: details
        )
    }

    /// Log habit log update
    public func logHabitLogUpdate(logId: String, habitId: String, changes: [String: String], userId: String? = nil) async {
        var details = changes
        details["habit_id"] = habitId
        await logEvent(
            type: .habitLogUpdate,
            userId: userId,
            resourceId: logId,
            resourceType: "habit_log",
            action: "update_habit_log",
            details: details
        )
    }

    /// Log habit log deletion
    public func logHabitLogDeletion(logId: String, habitId: String, userId: String? = nil) async {
        let details = ["habit_id": habitId, "compliance_reason": "user_initiated_deletion"]
        await logEvent(
            type: .habitLogDeletion,
            severity: .warning,
            userId: userId,
            resourceId: logId,
            resourceType: "habit_log",
            action: "delete_habit_log",
            details: details
        )
    }

    // MARK: - Achievement Operations

    /// Log achievement unlock
    public func logAchievementUnlock(achievementId: String, achievementName: String, userId: String? = nil) async {
        let details = [
            "achievement_name": achievementName,
            "unlock_date": ISO8601DateFormatter().string(from: Date()),
        ]
        await logEvent(
            type: .achievementUnlocked,
            userId: userId,
            resourceId: achievementId,
            resourceType: "achievement",
            action: "unlock_achievement",
            details: details
        )
    }

    // MARK: - Streak Operations

    /// Log streak milestone achievement
    public func logStreakMilestone(habitId: String, habitName: String, milestone: Int, userId: String? = nil) async {
        let details = [
            "habit_name": habitName,
            "milestone": String(milestone),
            "achievement_date": ISO8601DateFormatter().string(from: Date()),
        ]
        await logEvent(
            type: .streakMilestone,
            userId: userId,
            resourceId: habitId,
            resourceType: "habit",
            action: "achieve_streak_milestone",
            details: details
        )
    }

    // MARK: - Profile Operations

    /// Log player profile update
    public func logPlayerProfileUpdate(profileId: String, changes: [String: String], userId: String? = nil) async {
        await logEvent(
            type: .playerProfileUpdate,
            userId: userId,
            resourceId: profileId,
            resourceType: "player_profile",
            action: "update_player_profile",
            details: changes
        )
    }

    /// Log notification preference update
    public func logNotificationPreferenceUpdate(preferenceId: String, changes: [String: String], userId: String? = nil) async {
        await logEvent(
            type: .notificationPreferenceUpdate,
            userId: userId,
            resourceId: preferenceId,
            resourceType: "notification_preference",
            action: "update_notification_preference",
            details: changes
        )
    }

    // MARK: - Privacy & Compliance Operations

    /// Log data export request (GDPR Article 20)
    public func logDataExport(userId: String, exportFormat: String, requestedData: [String]) async {
        let details = [
            "export_format": exportFormat,
            "requested_data": requestedData.joined(separator: ","),
            "gdpr_article": "20",
            "request_date": ISO8601DateFormatter().string(from: Date()),
        ]
        await logEvent(
            type: .dataExport,
            severity: .info,
            userId: userId,
            resourceId: userId,
            resourceType: "user_data",
            action: "export_user_data",
            details: details
        )
    }

    /// Log data deletion request (right to be forgotten - GDPR Article 17)
    public func logDataDeletion(userId: String, deletionReason: String) async {
        let details = [
            "deletion_reason": deletionReason,
            "gdpr_article": "17",
            "request_date": ISO8601DateFormatter().string(from: Date()),
            "compliance_status": "pending_verification",
        ]
        await logEvent(
            type: .dataDeletion,
            severity: .critical,
            userId: userId,
            resourceId: userId,
            resourceType: "user_data",
            action: "delete_user_data",
            details: details
        )
    }

    /// Log consent update
    public func logConsentUpdate(userId: String, consentType: String, granted: Bool) async {
        let details = [
            "consent_type": consentType,
            "consent_granted": String(granted),
            "gdpr_article": "7",
            "update_date": ISO8601DateFormatter().string(from: Date()),
        ]
        await logEvent(
            type: .consentUpdate,
            userId: userId,
            resourceId: userId,
            resourceType: "user_consent",
            action: granted ? "grant_consent" : "revoke_consent",
            details: details
        )
    }

    /// Log privacy settings update
    public func logPrivacySettingsUpdate(userId: String, settings: [String: String]) async {
        await logEvent(
            type: .privacySettingsUpdate,
            userId: userId,
            resourceId: userId,
            resourceType: "privacy_settings",
            action: "update_privacy_settings",
            details: settings
        )
    }

    // MARK: - Core Logging Method

    /// Core audit logging method with encryption and structured logging
    public func logEvent(
        type: AuditEventType,
        severity: AuditSeverity = .info,
        userId: String? = nil,
        resourceId: String? = nil,
        resourceType: String? = nil,
        action: String,
        details: [String: String]? = nil,
        success: Bool = true,
        errorMessage: String? = nil
    ) async {
        let entry = AuditLogEntry(
            eventType: type,
            severity: severity,
            userId: userId,
            resourceId: resourceId,
            resourceType: resourceType,
            action: action,
            details: details,
            success: success,
            errorMessage: errorMessage
        )

        // Log to OSLog for immediate visibility
        logger.log("\(type.rawValue): \(action)", level: severity.logLevel)

        // Encrypt and persist audit entry
        await persistAuditEntry(entry)
    }

    /// Persist audit entry with encryption
    private func persistAuditEntry(_ entry: AuditLogEntry) async {
        do {
            let jsonData = try JSONEncoder().encode(entry)
            let encryptedData = try await encryptionService.encrypt(data: jsonData)

            // In a production app, this would be sent to a secure audit log service
            // For now, we'll log the encrypted entry for demonstration
            let encryptedString = encryptedData.base64EncodedString()
            logger.info("Encrypted audit entry: \(encryptedString.prefix(50))...")

        } catch {
            logger.error("Failed to persist audit entry: \(error.localizedDescription)")
        }
    }
}

// MARK: - Extensions

extension AuditSeverity {
    var osLogLevel: OSLogType {
        switch self {
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical: return .fault
        }
    }

    var logLevel: LogLevel {
        switch self {
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        case .critical: return .error // Map critical to error since LogLevel doesn't have critical
        }
    }
}
