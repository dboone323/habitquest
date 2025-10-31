//
//  AuditLogger.swift
//  PlannerApp
//
//  Enterprise-grade audit logging system for CloudKit sync operations
//  with encrypted compliance trails for planner data privacy
//

import CryptoKit
import Foundation
import OSLog

public final class AuditLogger: @unchecked Sendable {
    // MARK: - Singleton

    public static let shared = AuditLogger()

    // MARK: - Properties

    private let logger: OSLog
    private let encryptionService: EncryptionService
    private var auditTrail: [AuditEvent] = []
    private let maxTrailSize = 1000
    private let auditTrailLock = NSLock()

    // MARK: - Initialization

    private init() {
        self.logger = OSLog(subsystem: "com.plannerapp", category: "AuditLogger")
        self.encryptionService = EncryptionService.shared
        loadAuditTrail()
    }

    // MARK: - Audit Event Types

    public enum AuditEventType: String, Codable, Sendable {
        case cloudKitSync = "cloudkit_sync"
        case dataExport = "data_export"
        case dataImport = "data_import"
        case permissionChange = "permission_change"
        case zoneOperation = "zone_operation"
        case subscriptionUpdate = "subscription_update"
        case conflictResolution = "conflict_resolution"
        case dataDeletion = "data_deletion"
        case privacyRequest = "privacy_request"
    }

    public enum AuditSeverity: String, Codable, Sendable {
        case info
        case warning
        case error
        case critical

        var osLogLevel: OSLogType {
            switch self {
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }

        var logLevel: OSLogType {
            switch self {
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }
    }

    // MARK: - Audit Event Structure

    public struct AuditEvent: Codable, Sendable {
        public let id: UUID
        public let timestamp: Date
        public let type: AuditEventType
        public let severity: AuditSeverity
        public let userId: String?
        public let operation: String
        public let details: [String: String]
        public let ipAddress: String?
        public let userAgent: String?
        public let encryptedData: Data?

        public init(
            type: AuditEventType,
            severity: AuditSeverity,
            operation: String,
            details: [String: String] = [:],
            userId: String? = nil,
            ipAddress: String? = nil,
            userAgent: String? = nil,
            encryptedData: Data? = nil
        ) {
            self.id = UUID()
            self.timestamp = Date()
            self.type = type
            self.severity = severity
            self.userId = userId
            self.operation = operation
            self.details = details
            self.ipAddress = ipAddress
            self.userAgent = userAgent
            self.encryptedData = encryptedData
        }
    }

    // MARK: - Public Methods

    /// Log CloudKit sync operation
    public func logCloudKitSync(
        operation: String,
        recordCount: Int,
        zoneID: String? = nil,
        error: Error? = nil
    ) {
        var details: [String: String] = [
            "record_count": String(recordCount),
            "sync_operation": operation,
        ]

        if let zoneID {
            details["zone_id"] = zoneID
        }

        if let error {
            details["error_type"] = String(describing: type(of: error))
            details["error_message"] = error.localizedDescription
        }

        let severity: AuditSeverity = error != nil ? .error : .info
        let event = AuditEvent(
            type: .cloudKitSync,
            severity: severity,
            operation: operation,
            details: details
        )

        logEvent(event)
    }

    /// Log data export operation
    public func logDataExport(
        recordType: String,
        recordCount: Int,
        destination: String,
        encrypted: Bool = true
    ) {
        let details: [String: String] = [
            "record_type": recordType,
            "record_count": String(recordCount),
            "destination": destination,
            "encrypted": String(encrypted),
        ]

        let event = AuditEvent(
            type: .dataExport,
            severity: .info,
            operation: "data_export",
            details: details
        )

        logEvent(event)
    }

    /// Log data import operation
    public func logDataImport(
        source: String,
        recordCount: Int,
        recordType: String,
        validationPassed: Bool
    ) {
        let details: [String: String] = [
            "source": source,
            "record_count": String(recordCount),
            "record_type": recordType,
            "validation_passed": String(validationPassed),
        ]

        let severity: AuditSeverity = validationPassed ? .info : .warning
        let event = AuditEvent(
            type: .dataImport,
            severity: severity,
            operation: "data_import",
            details: details
        )

        logEvent(event)
    }

    /// Log permission change
    public func logPermissionChange(
        recordType: String,
        recordId: String,
        oldPermission: String,
        newPermission: String
    ) {
        let details: [String: String] = [
            "record_type": recordType,
            "record_id": recordId,
            "old_permission": oldPermission,
            "new_permission": newPermission,
        ]

        let event = AuditEvent(
            type: .permissionChange,
            severity: .warning,
            operation: "permission_change",
            details: details
        )

        logEvent(event)
    }

    /// Log zone operation
    public func logZoneOperation(
        zoneID: String,
        operation: String,
        success: Bool,
        error: Error? = nil
    ) {
        var details: [String: String] = [
            "zone_id": zoneID,
            "zone_operation": operation,
            "success": String(success),
        ]

        if let error {
            details["error_type"] = String(describing: type(of: error))
            details["error_message"] = error.localizedDescription
        }

        let severity: AuditSeverity = success ? .info : .error
        let event = AuditEvent(
            type: .zoneOperation,
            severity: severity,
            operation: operation,
            details: details
        )

        logEvent(event)
    }

    /// Log conflict resolution
    public func logConflictResolution(
        recordType: String,
        recordId: String,
        resolutionStrategy: String,
        ancestorCount: Int
    ) {
        let details: [String: String] = [
            "record_type": recordType,
            "record_id": recordId,
            "resolution_strategy": resolutionStrategy,
            "ancestor_count": String(ancestorCount),
        ]

        let event = AuditEvent(
            type: .conflictResolution,
            severity: .warning,
            operation: "conflict_resolution",
            details: details
        )

        logEvent(event)
    }

    /// Log general data access operation
    public func logDataAccess(
        operation: String,
        entityType: String,
        entityId: String? = nil,
        userId: String? = nil,
        details: [String: String] = [:]
    ) {
        var eventDetails = details
        eventDetails["entity_type"] = entityType
        eventDetails["operation"] = operation
        if let entityId {
            eventDetails["entity_id"] = entityId
        }

        let event = AuditEvent(
            type: .dataImport, // Using dataImport as general data access
            severity: .info,
            operation: operation,
            details: eventDetails,
            userId: userId
        )

        logEvent(event)
    }

    /// Log privacy request operation
    public func logPrivacyRequest(
        requestType: String,
        userId: String,
        dataScope: String,
        completed: Bool
    ) {
        let details: [String: String] = [
            "request_type": requestType,
            "data_scope": dataScope,
            "completed": String(completed),
        ]

        let severity: AuditSeverity = completed ? .info : .warning
        let event = AuditEvent(
            type: .privacyRequest,
            severity: severity,
            operation: requestType,
            details: details,
            userId: userId
        )

        logEvent(event)
    }

    /// Log security event
    public func logSecurityEvent(
        event: String,
        details: [String: String] = [:],
        severity: AuditSeverity = .info
    ) {
        let eventDetails = details
        let auditEvent = AuditEvent(
            type: .privacyRequest, // Using privacyRequest as general security event type
            severity: severity,
            operation: event,
            details: eventDetails
        )

        logEvent(auditEvent)
    }

    /// Get audit trail for compliance reporting
    public func getAuditTrail(
        from startDate: Date? = nil,
        to endDate: Date? = nil,
        type: AuditEventType? = nil,
        severity: AuditSeverity? = nil
    ) -> [AuditEvent] {
        auditTrailLock.lock()
        let currentTrail = auditTrail
        auditTrailLock.unlock()

        var filtered = currentTrail

        if let startDate {
            filtered = filtered.filter { $0.timestamp >= startDate }
        }

        if let endDate {
            filtered = filtered.filter { $0.timestamp <= endDate }
        }

        if let type {
            filtered = filtered.filter { $0.type == type }
        }

        if let severity {
            filtered = filtered.filter { $0.severity == severity }
        }

        return filtered.sorted { $0.timestamp > $1.timestamp }
    }

    /// Generate compliance report
    public func generateComplianceReport(
        from startDate: Date,
        to endDate: Date
    ) -> Data? {
        let events = getAuditTrail(from: startDate, to: endDate)
        let report: [String: Any] = [
            "report_period": [
                "start_date": startDate.ISO8601Format(),
                "end_date": endDate.ISO8601Format(),
            ],
            "total_events": events.count,
            "events_by_type": Dictionary(grouping: events) { $0.type.rawValue }.mapValues { $0.count },
            "events_by_severity": Dictionary(grouping: events) { $0.severity.rawValue }.mapValues { $0.count },
            "critical_events": events.filter { $0.severity == .critical }.count,
            "events": events.map { event in
                [
                    "id": event.id.uuidString,
                    "timestamp": event.timestamp.ISO8601Format(),
                    "type": event.type.rawValue,
                    "severity": event.severity.rawValue,
                    "operation": event.operation,
                    "details": event.details,
                ]
            },
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: report, options: .prettyPrinted)
            return try encryptionService.encrypt(data: jsonData)
        } catch {
            os_log("Failed to generate compliance report: %{public}@", log: logger, type: .error, error.localizedDescription)
            return nil
        }
    }

    /// Clear old audit entries (GDPR compliance)
    public func clearAuditTrail(olderThan days: Int = 90) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        auditTrailLock.lock()
        auditTrail = auditTrail.filter { $0.timestamp >= cutoffDate }
        auditTrailLock.unlock()

        saveAuditTrail()

        os_log("Cleared audit trail entries older than %{public}d days", log: logger, type: .info, days)
    }

    // MARK: - Private Methods

    private func logEvent(_ event: AuditEvent) {
        // Add to in-memory trail
        auditTrailLock.lock()
        auditTrail.append(event)

        // Maintain max size
        if auditTrail.count > maxTrailSize {
            auditTrail.removeFirst(auditTrail.count - maxTrailSize)
        }
        auditTrailLock.unlock()

        // Save to persistent storage
        saveAuditTrail()

        // Log to system logger
        let message = "[\(event.type.rawValue.uppercased())] \(event.operation)"
        os_log("%{public}@", log: logger, type: event.severity.osLogLevel, message)

        // Log additional details
        if !event.details.isEmpty {
            let detailsString = event.details.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            os_log("Details: %{public}@", log: logger, type: event.severity.osLogLevel, detailsString)
        }
    }

    private func saveAuditTrail() {
        do {
            let data = try JSONEncoder().encode(auditTrail)
            let encryptedData = try encryptionService.encrypt(data: data)

            let fileURL = getAuditTrailFileURL()
            try encryptedData.write(to: fileURL, options: .atomic)
        } catch {
            os_log("Failed to save audit trail: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
    }

    private func loadAuditTrail() {
        do {
            let fileURL = getAuditTrailFileURL()
            let encryptedData = try Data(contentsOf: fileURL)
            let decryptedData = try encryptionService.decrypt(data: encryptedData)
            auditTrail = try JSONDecoder().decode([AuditEvent].self, from: decryptedData)
        } catch {
            // If loading fails, start with empty trail
            auditTrail = []
            os_log("Failed to load audit trail, starting fresh: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
    }

    private func getAuditTrailFileURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("audit_trail.enc")
    }
}
