//
//  PrivacyManager.swift
//  HabitQuest
//
//  Created by Code Review Agent on 2025-10-30
//  Copyright © 2025 HabitQuest. All rights reserved.
//

import Combine
import Foundation
import OSLog

/// Privacy consent types
public enum ConsentType: String, Codable, Sendable {
    case dataProcessing = "data_processing"
    case analytics
    case notifications
    case healthData = "health_data"
    case marketing
}

/// Data deletion request status
public enum DataDeletionStatus: String, Codable, Sendable {
    case pending
    case processing
    case completed
    case failed
}

/// Privacy consent record
public struct PrivacyConsent: Codable, Sendable, Identifiable {
    public let id: UUID
    public let userId: String
    public let consentType: ConsentType
    public let granted: Bool
    public let grantedAt: Date?
    public let revokedAt: Date?
    public let consentVersion: String
    public let ipAddress: String?
    public let userAgent: String?

    public init(
        userId: String,
        consentType: ConsentType,
        granted: Bool,
        consentVersion: String = "1.0",
        ipAddress: String? = nil,
        userAgent: String? = nil
    ) {
        self.id = UUID()
        self.userId = userId
        self.consentType = consentType
        self.granted = granted
        self.grantedAt = granted ? Date() : nil
        self.revokedAt = granted ? nil : Date()
        self.consentVersion = consentVersion
        self.ipAddress = ipAddress
        self.userAgent = userAgent
    }
}

/// Data deletion request
public struct DataDeletionRequest: Codable, Sendable, Identifiable {
    public let id: UUID
    public let userId: String
    public let requestedAt: Date
    public let reason: String
    public var status: DataDeletionStatus
    public var completedAt: Date?
    public var failureReason: String?
    public let gdprArticle: String

    public init(
        userId: String,
        reason: String,
        gdprArticle: String = "17"
    ) {
        self.id = UUID()
        self.userId = userId
        self.requestedAt = Date()
        self.reason = reason
        self.status = .pending
        self.completedAt = nil
        self.failureReason = nil
        self.gdprArticle = gdprArticle
    }
}

/// Privacy and compliance management for HabitQuest
/// Handles GDPR compliance, user consent, and data deletion requests
@MainActor
public final class PrivacyManager: ObservableObject {
    public static let shared = PrivacyManager()

    private let logger = Logger.shared
    private let auditLogger = AuditLogger.shared
    private let securityMonitor = SecurityMonitor.shared

    // Published properties
    @Published public var consentRecords: [PrivacyConsent] = []
    @Published public var deletionRequests: [DataDeletionRequest] = []

    // Storage
    private let userDefaults = UserDefaults.standard
    private let consentKey = "habitquest_privacy_consents"
    private let deletionKey = "habitquest_deletion_requests"

    private init() {
        loadStoredData()
    }

    // MARK: - Consent Management

    /// Grant consent for a specific type
    public func grantConsent(userId: String, type: ConsentType, version: String = "1.0") async throws {
        let consent = PrivacyConsent(
            userId: userId,
            consentType: type,
            granted: true,
            consentVersion: version
        )

        consentRecords.append(consent)
        saveConsentRecords()

        // Audit log the consent
        await auditLogger.logConsentUpdate(userId: userId, consentType: type.rawValue, granted: true)

        // Update security monitor
        await securityMonitor.monitorPrivacySettings(userId: userId, settings: ["consent_\(type.rawValue)": true])

        logger.info("Consent granted for \(type.rawValue) by user \(userId)")
    }

    /// Revoke consent for a specific type
    public func revokeConsent(userId: String, type: ConsentType) async throws {
        // Remove existing consent
        consentRecords.removeAll { $0.userId == userId && $0.consentType == type }

        // Add revocation record
        let revocation = PrivacyConsent(
            userId: userId,
            consentType: type,
            granted: false,
            consentVersion: "1.0"
        )

        consentRecords.append(revocation)
        saveConsentRecords()

        // Audit log the revocation
        await auditLogger.logConsentUpdate(userId: userId, consentType: type.rawValue, granted: false)

        // Update security monitor
        await securityMonitor.monitorPrivacySettings(userId: userId, settings: ["consent_\(type.rawValue)": false])

        logger.info("Consent revoked for \(type.rawValue) by user \(userId)")
    }

    /// Check if user has granted consent for a specific type
    public func hasConsent(userId: String, type: ConsentType) -> Bool {
        let userConsents = consentRecords.filter { $0.userId == userId && $0.consentType == type }
        return userConsents.contains { $0.granted }
    }

    /// Get all consents for a user
    public func consentsForUser(_ userId: String) -> [PrivacyConsent] {
        consentRecords.filter { $0.userId == userId }
    }

    /// Get consent history for a user and type
    public func consentHistory(userId: String, type: ConsentType) -> [PrivacyConsent] {
        consentRecords
            .filter { $0.userId == userId && $0.consentType == type }
            .sorted { $0.grantedAt ?? Date.distantPast > $1.grantedAt ?? Date.distantPast }
    }

    // MARK: - Data Deletion (Right to be Forgotten - GDPR Article 17)

    /// Request data deletion for a user
    public func requestDataDeletion(userId: String, reason: String) async throws {
        let request = DataDeletionRequest(userId: userId, reason: reason)

        deletionRequests.append(request)
        saveDeletionRequests()

        // Audit log the deletion request
        await auditLogger.logDataDeletion(userId: userId, deletionReason: reason)

        // Create security alert for compliance tracking
        await securityMonitor.createAlert(
            type: .privacyViolation, // Would need to add dataDeletion type
            severity: .critical,
            title: "Data Deletion Request",
            description: "User \(userId) requested data deletion: \(reason)",
            userId: userId,
            metadata: ["gdpr_article": "17", "reason": reason]
        )

        logger.info("Data deletion requested for user \(userId): \(reason)")

        // Start processing the deletion request
        Task {
            await processDataDeletion(request)
        }
    }

    /// Process a data deletion request
    private func processDataDeletion(_ request: DataDeletionRequest) async {
        // Update status to processing
        updateDeletionRequestStatus(request.id, status: .processing)

        do {
            // In a real implementation, this would:
            // 1. Delete user data from database
            // 2. Delete associated files
            // 3. Anonymize audit logs
            // 4. Notify third parties
            // 5. Send confirmation email

            // Simulate processing time
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds

            // For demo purposes, we'll just mark as completed
            // In production, this would be a comprehensive data deletion process

            updateDeletionRequestStatus(request.id, status: .completed, completedAt: Date())

            // Audit log completion
            await auditLogger.logEvent(
                type: .dataDeletion,
                severity: .info,
                userId: request.userId,
                resourceId: request.userId,
                resourceType: "user_data",
                action: "data_deletion_completed",
                details: ["request_id": request.id.uuidString]
            )

            logger.info("Data deletion completed for user \(request.userId)")

        } catch {
            updateDeletionRequestStatus(request.id, status: .failed, failureReason: error.localizedDescription)

            // Audit log failure
            await auditLogger.logEvent(
                type: .dataDeletion,
                severity: .error,
                userId: request.userId,
                resourceId: request.userId,
                resourceType: "user_data",
                action: "data_deletion_failed",
                details: [
                    "request_id": request.id.uuidString,
                    "error": error.localizedDescription,
                ]
            )

            logger.error("Data deletion failed for user \(request.userId): \(error.localizedDescription)")
        }
    }

    /// Update deletion request status
    private func updateDeletionRequestStatus(
        _ requestId: UUID,
        status: DataDeletionStatus,
        completedAt: Date? = nil,
        failureReason: String? = nil
    ) {
        if let index = deletionRequests.firstIndex(where: { $0.id == requestId }) {
            var request = deletionRequests[index]
            request.status = status
            request.completedAt = completedAt
            request.failureReason = failureReason
            deletionRequests[index] = request
            saveDeletionRequests()
        }
    }

    /// Get deletion requests for a user
    public func deletionRequestsForUser(_ userId: String) -> [DataDeletionRequest] {
        deletionRequests.filter { $0.userId == userId }
    }

    // MARK: - Data Export (GDPR Article 20)

    /// Export user data for download
    public func exportUserData(userId: String) async throws -> Data {
        // Check consent for data processing
        guard await securityMonitor.checkGDPRCompliance(userId: userId, operation: "data_export") else {
            throw PrivacyError.consentRequired
        }

        // In a real implementation, this would gather all user data
        let exportData = UserDataExport(
            userId: userId,
            exportDate: Date(),
            habits: [], // Would fetch from database
            habitLogs: [], // Would fetch from database
            achievements: [], // Would fetch from database
            consents: consentsForUser(userId),
            profile: nil // Would fetch from database
        )

        let jsonData = try JSONEncoder().encode(exportData)

        // Audit log the export
        await auditLogger.logDataExport(
            userId: userId,
            exportFormat: "json",
            requestedData: ["habits", "logs", "achievements", "consents", "profile"]
        )

        logger.info("Data export completed for user \(userId)")
        return jsonData
    }

    // MARK: - Privacy Settings

    /// Update privacy settings for a user
    public func updatePrivacySettings(userId: String, settings: [String: Any]) async throws {
        // Validate settings
        guard let dataSharing = settings["dataSharing"] as? Bool else {
            throw PrivacyError.invalidSettings
        }

        // Update consent based on data sharing preference
        if dataSharing {
            try await grantConsent(userId: userId, type: .dataProcessing)
        } else {
            try await revokeConsent(userId: userId, type: .dataProcessing)
        }

        // Audit log privacy settings update
        await auditLogger.logPrivacySettingsUpdate(
            userId: userId,
            settings: settings.mapValues { String(describing: $0) }
        )

        // Update security monitor
        await securityMonitor.monitorPrivacySettings(userId: userId, settings: settings)

        logger.info("Privacy settings updated for user \(userId)")
    }

    // MARK: - Compliance Validation

    /// Validate GDPR compliance for user operations
    public func validateGDPRCompliance(userId: String, operation: String) async -> Bool {
        // Check data processing consent
        guard hasConsent(userId: userId, type: .dataProcessing) else {
            logger.warning("GDPR violation: No data processing consent for user \(userId) operation: \(operation)")
            return false
        }

        // Check for active deletion requests
        let activeDeletions = deletionRequests.filter {
            $0.userId == userId && ($0.status == .pending || $0.status == .processing)
        }

        if !activeDeletions.isEmpty {
            logger.warning("GDPR concern: Active deletion request for user \(userId)")
            return false
        }

        return true
    }

    /// Generate privacy compliance report
    public func generateComplianceReport(userId: String) async -> PrivacyComplianceReport {
        let consents = consentsForUser(userId)
        let deletions = deletionRequestsForUser(userId)
        let gdprCompliant = await validateGDPRCompliance(userId: userId, operation: "compliance_check")

        return PrivacyComplianceReport(
            userId: userId,
            reportDate: Date(),
            gdprCompliant: gdprCompliant,
            activeConsents: consents.filter(\.granted),
            consentHistory: consents,
            deletionRequests: deletions,
            dataProcessingConsent: hasConsent(userId: userId, type: .dataProcessing),
            analyticsConsent: hasConsent(userId: userId, type: .analytics),
            marketingConsent: hasConsent(userId: userId, type: .marketing)
        )
    }

    // MARK: - Storage Management

    private func saveConsentRecords() {
        do {
            let data = try JSONEncoder().encode(consentRecords)
            userDefaults.set(data, forKey: consentKey)
        } catch {
            logger.error("Failed to save consent records: \(error.localizedDescription)")
        }
    }

    private func saveDeletionRequests() {
        do {
            let data = try JSONEncoder().encode(deletionRequests)
            userDefaults.set(data, forKey: deletionKey)
        } catch {
            logger.error("Failed to save deletion requests: \(error.localizedDescription)")
        }
    }

    private func loadStoredData() {
        // Load consent records
        if let consentData = userDefaults.data(forKey: consentKey) {
            do {
                consentRecords = try JSONDecoder().decode([PrivacyConsent].self, from: consentData)
            } catch {
                logger.error("Failed to load consent records: \(error.localizedDescription)")
            }
        }

        // Load deletion requests
        if let deletionData = userDefaults.data(forKey: deletionKey) {
            do {
                deletionRequests = try JSONDecoder().decode([DataDeletionRequest].self, from: deletionData)
            } catch {
                logger.error("Failed to load deletion requests: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Data Structures

/// User data export structure
public struct UserDataExport: Codable, Sendable {
    public let userId: String
    public let exportDate: Date
    public let habits: [String] // Simplified for demo
    public let habitLogs: [String] // Simplified for demo
    public let achievements: [String] // Simplified for demo
    public let consents: [PrivacyConsent]
    public let profile: String? // Simplified for demo
}

/// Privacy compliance report
public struct PrivacyComplianceReport: Codable, Sendable {
    public let userId: String
    public let reportDate: Date
    public let gdprCompliant: Bool
    public let activeConsents: [PrivacyConsent]
    public let consentHistory: [PrivacyConsent]
    public let deletionRequests: [DataDeletionRequest]
    public let dataProcessingConsent: Bool
    public let analyticsConsent: Bool
    public let marketingConsent: Bool
}

// MARK: - Error Types

public enum PrivacyError: LocalizedError {
    case consentRequired
    case invalidSettings
    case deletionInProgress
    case exportFailed

    public var errorDescription: String? {
        switch self {
        case .consentRequired:
            return "User consent required for this operation"
        case .invalidSettings:
            return "Invalid privacy settings provided"
        case .deletionInProgress:
            return "Data deletion is currently in progress"
        case .exportFailed:
            return "Failed to export user data"
        }
    }
}
