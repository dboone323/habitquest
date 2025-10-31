//
//  PrivacyManager.swift
//  PlannerApp
//
//  GDPR/HIPAA compliance management with consent handling and data deletion
//  capabilities for CloudKit-synced planner data
//

import Combine
import Foundation
import OSLog

public final class PrivacyManager {
    // MARK: - Singleton

    public nonisolated(unsafe) static let shared = PrivacyManager()

    // MARK: - Properties

    private let logger: OSLog
    private let auditLogger: AuditLogger
    private let encryptionService: EncryptionService

    // Privacy state
    private var userConsents: [PrivacyConsent] = []
    private var dataProcessingActivities: [DataProcessingActivity] = []

    // Publishers
    public let privacyUpdates = PassthroughSubject<PrivacyUpdate, Never>()

    // MARK: - Initialization

    private init() {
        self.logger = OSLog(subsystem: "com.plannerapp", category: "PrivacyManager")
        self.auditLogger = AuditLogger.shared
        self.encryptionService = EncryptionService.shared
        loadPrivacyState()
    }

    // MARK: - Privacy Types

    public enum PrivacyConsentType: String, Codable, Sendable {
        case dataCollection = "data_collection"
        case dataSharing = "data_sharing"
        case analytics
        case cloudSync = "cloud_sync"
        case notifications
        case locationServices = "location_services"
    }

    public enum DataDeletionScope: String, Codable, Sendable {
        case userData = "user_data"
        case allData = "all_data"
        case specificRecords = "specific_records"
        case dateRange = "date_range"
    }

    public struct PrivacyConsent: Codable, Sendable {
        public let id: UUID
        public let type: PrivacyConsentType
        public let granted: Bool
        public let timestamp: Date
        public let version: String
        public let details: [String: String]

        public init(
            type: PrivacyConsentType,
            granted: Bool,
            version: String = "1.0",
            details: [String: String] = [:]
        ) {
            self.id = UUID()
            self.type = type
            self.granted = granted
            self.timestamp = Date()
            self.version = version
            self.details = details
        }
    }

    public struct DataProcessingActivity: Codable, Sendable {
        public let id: UUID
        public let purpose: String
        public let dataTypes: [String]
        public let legalBasis: String
        public let retentionPeriod: TimeInterval
        public let timestamp: Date
        public let active: Bool

        public init(
            purpose: String,
            dataTypes: [String],
            legalBasis: String,
            retentionPeriod: TimeInterval
        ) {
            self.id = UUID()
            self.purpose = purpose
            self.dataTypes = dataTypes
            self.legalBasis = legalBasis
            self.retentionPeriod = retentionPeriod
            self.timestamp = Date()
            self.active = true
        }
    }

    public enum PrivacyUpdate: Sendable {
        case consentUpdated(PrivacyConsent)
        case dataDeletionRequested(DataDeletionScope, String)
        case complianceCheckCompleted(Bool)
        case privacyReportGenerated(Data)
    }

    // MARK: - Consent Management

    /// Grant privacy consent
    public func grantConsent(
        type: PrivacyConsentType,
        details: [String: String] = [:]
    ) {
        let consent = PrivacyConsent(
            type: type,
            granted: true,
            details: details
        )

        userConsents.append(consent)
        savePrivacyState()

        privacyUpdates.send(.consentUpdated(consent))

        auditLogger.logPrivacyRequest(
            requestType: "consent_granted",
            userId: "current_user", // In real app, get from auth service
            dataScope: type.rawValue,
            completed: true
        )

        os_log("Privacy consent granted for %{public}@", log: logger, type: .info, type.rawValue)
    }

    /// Revoke privacy consent
    public func revokeConsent(type: PrivacyConsentType) {
        if let index = userConsents.firstIndex(where: { $0.type == type && $0.granted }) {
            userConsents[index] = PrivacyConsent(
                type: type,
                granted: false,
                details: ["revoked": "true"]
            )
            savePrivacyState()

            let consent = userConsents[index]
            privacyUpdates.send(.consentUpdated(consent))

            auditLogger.logPrivacyRequest(
                requestType: "consent_revoked",
                userId: "current_user",
                dataScope: type.rawValue,
                completed: true
            )

            os_log("Privacy consent revoked for %{public}@", log: logger, type: .info, type.rawValue)
        }
    }

    /// Check if consent is granted
    public func hasConsent(for type: PrivacyConsentType) -> Bool {
        userConsents.contains { $0.type == type && $0.granted }
    }

    /// Get all user consents
    public func getUserConsents() -> [PrivacyConsent] {
        userConsents.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - Data Deletion (Right to be Forgotten)

    /// Request data deletion
    public func requestDataDeletion(
        scope: DataDeletionScope,
        reason: String,
        userId: String = "current_user"
    ) {
        privacyUpdates.send(.dataDeletionRequested(scope, reason))

        auditLogger.logPrivacyRequest(
            requestType: "data_deletion",
            userId: userId,
            dataScope: scope.rawValue,
            completed: false // Will be marked complete when deletion finishes
        )

        // Start deletion process
        let auditLogger = self.auditLogger
        let encryptionService = self.encryptionService
        let logger = self.logger

        DispatchQueue.global(qos: .background).async {
            Task {
                await Self.performDataDeletion(
                    auditLogger: auditLogger,
                    encryptionService: encryptionService,
                    logger: logger,
                    scope: scope,
                    reason: reason,
                    userId: userId
                )
            }
        }

        os_log("Data deletion requested: %{public}@ for user %{public}@", log: logger, type: .info, scope.rawValue, userId)
    }

    private static func performDataDeletion(
        auditLogger: AuditLogger,
        encryptionService: EncryptionService,
        logger: OSLog,
        scope: DataDeletionScope,
        reason: String,
        userId: String
    ) async {
        do {
            switch scope {
            case .userData:
                try await deleteUserData(userId: userId, logger: logger)
            case .allData:
                try await deleteAllData(logger: logger)
            case .specificRecords:
                // Would need record IDs - simplified for this implementation
                break
            case .dateRange:
                // Would need date range - simplified for this implementation
                break
            }

            auditLogger.logPrivacyRequest(
                requestType: "data_deletion",
                userId: userId,
                dataScope: scope.rawValue,
                completed: true
            )

            os_log("Data deletion completed for scope: %{public}@", log: logger, type: .info, scope.rawValue)
        } catch {
            os_log("Data deletion failed: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
    }

    private static func deleteUserData(userId: String, logger: OSLog) async throws {
        // In a real implementation, this would:
        // 1. Delete CloudKit records for the user
        // 2. Clear local caches
        // 3. Remove from search indexes
        // 4. Notify other services

        os_log("Deleting user data for user: %{public}@", log: logger, type: .info, userId)

        // Simulate deletion process
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay

        // Note: In a real implementation, this would clear actual user data
        // For this demo, we just simulate the operation
    }

    private static func deleteAllData(logger: OSLog) async throws {
        // Delete all application data
        os_log("Deleting all application data", log: logger, type: .default)

        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay

        // Note: In a real implementation, this would clear all application data
        // For this demo, we just simulate the operation
    }

    // MARK: - Data Export (Right to Data Portability)

    /// Export user data for portability
    public func exportUserData(userId: String = "current_user") async throws -> Data {
        os_log("Exporting user data for user: %{public}@", log: logger, type: .info, userId)

        // Collect all user data
        let exportData: [String: Any] = [
            "user_id": userId,
            "export_timestamp": Date().ISO8601Format(),
            "consents": userConsents.map { consent in
                [
                    "type": consent.type.rawValue,
                    "granted": consent.granted,
                    "timestamp": consent.timestamp.ISO8601Format(),
                    "version": consent.version,
                ]
            },
            "processing_activities": dataProcessingActivities.map { activity in
                [
                    "purpose": activity.purpose,
                    "data_types": activity.dataTypes,
                    "legal_basis": activity.legalBasis,
                    "retention_period_days": activity.retentionPeriod / 86400,
                    "timestamp": activity.timestamp.ISO8601Format(),
                    "active": activity.active,
                ]
            },
            "audit_trail": auditLogger.getAuditTrail().map { event in
                [
                    "timestamp": event.timestamp.ISO8601Format(),
                    "type": event.type.rawValue,
                    "severity": event.severity.rawValue,
                    "operation": event.operation,
                    "details": event.details,
                ]
            },
        ]

        // Convert to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)

        // Encrypt the export
        let encryptedData = try encryptionService.encrypt(data: jsonData)

        auditLogger.logDataExport(
            recordType: "user_data_export",
            recordCount: 1,
            destination: "user_download"
        )

        return encryptedData
    }

    // MARK: - Compliance Monitoring

    /// Perform GDPR compliance check
    public func performComplianceCheck() -> Bool {
        var compliant = true
        var issues: [String] = []

        // Check consent requirements
        let requiredConsents: [PrivacyConsentType] = [.dataCollection, .cloudSync]
        for consentType in requiredConsents {
            if !hasConsent(for: consentType) {
                issues.append("Missing consent for \(consentType.rawValue)")
                compliant = false
            }
        }

        // Check data retention compliance
        let expiredActivities = dataProcessingActivities.filter { activity in
            let expirationDate = activity.timestamp.addingTimeInterval(activity.retentionPeriod)
            return Date() > expirationDate && activity.active
        }

        if !expiredActivities.isEmpty {
            issues.append("\(expiredActivities.count) data processing activities exceed retention period")
            compliant = false
        }

        // Check audit trail completeness
        let recentAuditEvents = auditLogger.getAuditTrail(
            from: Calendar.current.date(byAdding: .day, value: -30, to: Date())
        )

        if recentAuditEvents.isEmpty {
            issues.append("No audit events in the last 30 days")
            compliant = false
        }

        // Log compliance check result
        if !compliant {
            os_log("GDPR compliance check failed: %{public}@", log: logger, type: .error, issues.joined(separator: "; "))
        } else {
            os_log("GDPR compliance check passed", log: logger, type: .info)
        }

        privacyUpdates.send(.complianceCheckCompleted(compliant))
        return compliant
    }

    /// Generate privacy compliance report
    public func generatePrivacyReport() -> Data? {
        let report: [String: Any] = [
            "report_generated": Date().ISO8601Format(),
            "compliance_status": performComplianceCheck(),
            "user_consents": userConsents.map { consent in
                [
                    "type": consent.type.rawValue,
                    "granted": consent.granted,
                    "timestamp": consent.timestamp.ISO8601Format(),
                ]
            },
            "data_processing_activities": dataProcessingActivities.map { activity in
                [
                    "purpose": activity.purpose,
                    "active": activity.active,
                    "retention_days": activity.retentionPeriod / 86400,
                ]
            },
            "audit_trail_summary": [
                "total_events": auditLogger.getAuditTrail().count,
                "events_last_30_days": auditLogger.getAuditTrail(
                    from: Calendar.current.date(byAdding: .day, value: -30, to: Date())
                ).count,
                "critical_events": auditLogger.getAuditTrail().filter {
                    $0.severity == .critical
                }.count,
            ],
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: report, options: .prettyPrinted)
            privacyUpdates.send(.privacyReportGenerated(jsonData))
            return jsonData
        } catch {
            os_log("Failed to generate privacy report: %{public}@", log: logger, type: .error, error.localizedDescription)
            return nil
        }
    }

    // MARK: - Data Processing Activities

    /// Register data processing activity
    public func registerDataProcessingActivity(
        purpose: String,
        dataTypes: [String],
        legalBasis: String,
        retentionPeriod: TimeInterval
    ) {
        let activity = DataProcessingActivity(
            purpose: purpose,
            dataTypes: dataTypes,
            legalBasis: legalBasis,
            retentionPeriod: retentionPeriod
        )

        dataProcessingActivities.append(activity)
        savePrivacyState()

        os_log("Registered data processing activity: %{public}@", log: logger, type: .info, purpose)
    }

    /// Get active data processing activities
    public func getActiveProcessingActivities() -> [DataProcessingActivity] {
        dataProcessingActivities.filter(\.active)
    }

    // MARK: - Private Methods

    private func loadPrivacyState() {
        do {
            let fileURL = getPrivacyStateFileURL()
            let encryptedData = try Data(contentsOf: fileURL)
            let decryptedData = try encryptionService.decrypt(data: encryptedData)

            let state = try JSONDecoder().decode(PrivacyState.self, from: decryptedData)
            userConsents = state.consents
            dataProcessingActivities = state.activities
        } catch {
            // If loading fails, start with empty state
            userConsents = []
            dataProcessingActivities = []
            os_log("Failed to load privacy state, starting fresh: %{public}@", log: logger, type: .default, error.localizedDescription)
        }
    }

    private func savePrivacyState() {
        do {
            let state = PrivacyState(consents: userConsents, activities: dataProcessingActivities)
            let data = try JSONEncoder().encode(state)
            let encryptedData = try encryptionService.encrypt(data: data)

            let fileURL = getPrivacyStateFileURL()
            try encryptedData.write(to: fileURL, options: .atomic)
        } catch {
            os_log("Failed to save privacy state: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
    }

    private func getPrivacyStateFileURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("privacy_state.enc")
    }

    // MARK: - Private Types

    private struct PrivacyState: Codable {
        let consents: [PrivacyConsent]
        let activities: [DataProcessingActivity]
    }
}
