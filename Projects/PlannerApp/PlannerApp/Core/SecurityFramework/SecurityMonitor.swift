//
//  SecurityMonitor.swift
//  PlannerApp
//
//  Real-time security monitoring and anomaly detection for CloudKit operations
//  with automated alerting and compliance monitoring
//

import Combine
import Foundation
import OSLog

public final class SecurityMonitor {
    // MARK: - Singleton

    public nonisolated(unsafe) static let shared = SecurityMonitor()

    // MARK: - Properties

    private let logger: OSLog
    private let auditLogger: AuditLogger
    private var cancellables = Set<AnyCancellable>()

    // Monitoring state
    private var syncActivity: [String: Date] = [:]
    private var failedOperations: [String: Int] = [:]
    private var anomalyPatterns: [AnomalyPattern] = []

    // Thresholds
    private let maxFailedOperationsPerHour = 10
    private let maxSyncFrequencyPerMinute = 60
    private let anomalyDetectionWindow: TimeInterval = 3600 // 1 hour

    // Publishers
    public let securityAlerts = PassthroughSubject<SecurityAlert, Never>()

    // MARK: - Initialization

    private init() {
        self.logger = OSLog(subsystem: "com.plannerapp", category: "SecurityMonitor")
        self.auditLogger = AuditLogger.shared
        setupMonitoring()
        loadAnomalyPatterns()
    }

    // MARK: - Alert Types

    public enum SecurityAlertType: String, Sendable {
        case excessiveFailures = "excessive_failures"
        case unusualSyncFrequency = "unusual_sync_frequency"
        case dataAnomaly = "data_anomaly"
        case permissionViolation = "permission_violation"
        case encryptionFailure = "encryption_failure"
        case complianceViolation = "compliance_violation"
    }

    public struct SecurityAlert: Sendable {
        public let id: UUID
        public let timestamp: Date
        public let type: SecurityAlertType
        public let severity: AuditLogger.AuditSeverity
        public let message: String
        public let details: [String: String]
        public let recommendedAction: String

        public init(
            type: SecurityAlertType,
            severity: AuditLogger.AuditSeverity,
            message: String,
            details: [String: String] = [:],
            recommendedAction: String
        ) {
            self.id = UUID()
            self.timestamp = Date()
            self.type = type
            self.severity = severity
            self.message = message
            self.details = details
            self.recommendedAction = recommendedAction
        }
    }

    // MARK: - Anomaly Detection

    private struct AnomalyPattern: Codable, Sendable {
        let id: UUID
        let pattern: String
        let threshold: Int
        let timeWindow: TimeInterval
        let severity: AuditLogger.AuditSeverity
        var lastTriggered: Date?
    }

    // MARK: - Public Methods

    /// Monitor CloudKit sync operation
    public func monitorSyncOperation(
        operation: String,
        zoneID: String,
        recordCount: Int,
        success: Bool,
        error: Error? = nil
    ) {
        let operationKey = "\(zoneID)_\(operation)"

        // Track activity
        syncActivity[operationKey] = Date()

        if !success {
            failedOperations[operationKey, default: 0] += 1
        }

        // Check for excessive failures
        checkExcessiveFailures(operationKey: operationKey)

        // Check sync frequency
        checkSyncFrequency(operationKey: operationKey)

        // Log the operation
        auditLogger.logCloudKitSync(
            operation: operation,
            recordCount: recordCount,
            zoneID: zoneID,
            error: error
        )
    }

    /// Monitor data access patterns
    public func monitorDataAccess(
        recordType: String,
        operation: String,
        userId: String? = nil,
        recordCount: Int = 1
    ) {
        // Check for unusual access patterns
        checkDataAnomalies(recordType: recordType, operation: operation, recordCount: recordCount)

        // Log access for audit trail
        auditLogger.logDataAccess(
            operation: "data_access",
            entityType: recordType,
            userId: userId,
            details: [
                "access_operation": operation,
                "record_count": String(recordCount),
            ]
        )
    }

    /// Monitor permission changes
    public func monitorPermissionChange(
        recordType: String,
        recordId: String,
        oldPermission: String,
        newPermission: String
    ) {
        // Alert on suspicious permission changes
        if isSuspiciousPermissionChange(oldPermission: oldPermission, newPermission: newPermission) {
            let alert = SecurityAlert(
                type: .permissionViolation,
                severity: .critical,
                message: "Suspicious permission change detected",
                details: [
                    "record_type": recordType,
                    "record_id": recordId,
                    "old_permission": oldPermission,
                    "new_permission": newPermission,
                ],
                recommendedAction: "Review permission change and verify user authorization"
            )
            securityAlerts.send(alert)
        }

        // Log permission change
        auditLogger.logPermissionChange(
            recordType: recordType,
            recordId: recordId,
            oldPermission: oldPermission,
            newPermission: newPermission
        )
    }

    /// Monitor encryption operations
    public func monitorEncryptionOperation(success: Bool, operation: String) {
        if !success {
            let alert = SecurityAlert(
                type: .encryptionFailure,
                severity: .error,
                message: "Encryption operation failed",
                details: ["operation": operation],
                recommendedAction: "Check encryption service health and key availability"
            )
            securityAlerts.send(alert)
        }
    }

    /// Check compliance status
    public func checkCompliance() -> Bool {
        // Validate encryption service
        let encryptionValid = EncryptionService.shared.validateEncryption()

        // Check audit trail integrity
        let auditTrailValid = validateAuditTrail()

        // Check for compliance violations
        let complianceViolations = checkComplianceViolations()

        if !encryptionValid {
            let alert = SecurityAlert(
                type: .complianceViolation,
                severity: .critical,
                message: "Encryption service validation failed",
                recommendedAction: "Rotate encryption keys and validate service health"
            )
            securityAlerts.send(alert)
        }

        if !auditTrailValid {
            let alert = SecurityAlert(
                type: .complianceViolation,
                severity: .error,
                message: "Audit trail integrity compromised",
                recommendedAction: "Review audit trail and restore from backup if necessary"
            )
            securityAlerts.send(alert)
        }

        return encryptionValid && auditTrailValid && complianceViolations.isEmpty
    }

    /// Get security status report
    public func getSecurityStatus() -> [String: Any] {
        [
            "encryption_healthy": EncryptionService.shared.validateEncryption(),
            "audit_trail_integrity": validateAuditTrail(),
            "active_alerts": getActiveAlerts().count,
            "failed_operations_last_hour": failedOperations.values.reduce(0, +),
            "sync_operations_last_hour": syncActivity.values.filter {
                Date().timeIntervalSince($0) < 3600
            }.count,
            "compliance_status": checkCompliance(),
        ]
    }

    /// Get active security alerts
    public func getActiveAlerts() -> [SecurityAlert] {
        // In a real implementation, this would maintain a list of active alerts
        // For now, return empty array as alerts are sent via publisher
        []
    }

    // MARK: - Private Methods

    private func setupMonitoring() {
        // Setup periodic health checks
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.performHealthCheck()
            }
            .store(in: &cancellables)

        // Setup anomaly pattern monitoring
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAnomalyPatterns()
            }
            .store(in: &cancellables)
    }

    private func performHealthCheck() {
        let isHealthy = checkCompliance()

        if !isHealthy {
            os_log("Security health check failed", log: logger, type: .default)
        }
    }

    private func checkExcessiveFailures(operationKey: String) {
        let recentFailures = failedOperations[operationKey] ?? 0

        if recentFailures >= maxFailedOperationsPerHour {
            let alert = SecurityAlert(
                type: .excessiveFailures,
                severity: .error,
                message: "Excessive operation failures detected",
                details: [
                    "operation": operationKey,
                    "failure_count": String(recentFailures),
                ],
                recommendedAction: "Investigate operation failures and implement rate limiting"
            )
            securityAlerts.send(alert)

            // Reset counter after alerting
            failedOperations[operationKey] = 0
        }
    }

    private func checkSyncFrequency(operationKey: String) {
        let recentOperations = syncActivity.values.filter {
            Date().timeIntervalSince($0) < 60 // Last minute
        }.count

        if recentOperations >= maxSyncFrequencyPerMinute {
            let alert = SecurityAlert(
                type: .unusualSyncFrequency,
                severity: .warning,
                message: "Unusual sync frequency detected",
                details: [
                    "operation": operationKey,
                    "operations_per_minute": String(recentOperations),
                ],
                recommendedAction: "Monitor sync operations and implement throttling if necessary"
            )
            securityAlerts.send(alert)
        }
    }

    private func checkDataAnomalies(recordType: String, operation: String, recordCount: Int) {
        // Simple anomaly detection based on record count thresholds
        let threshold = getAnomalyThreshold(for: recordType, operation: operation)

        if recordCount > threshold {
            let alert = SecurityAlert(
                type: .dataAnomaly,
                severity: .warning,
                message: "Data access anomaly detected",
                details: [
                    "record_type": recordType,
                    "operation": operation,
                    "record_count": String(recordCount),
                    "threshold": String(threshold),
                ],
                recommendedAction: "Review data access patterns and verify legitimacy"
            )
            securityAlerts.send(alert)
        }
    }

    private func getAnomalyThreshold(for recordType: String, operation: String) -> Int {
        // Define thresholds based on record type and operation
        switch (recordType, operation) {
        case ("Task", "fetch"):
            return 1000
        case ("Goal", "fetch"):
            return 500
        case ("JournalEntry", "fetch"):
            return 200
        case ("CalendarEvent", "fetch"):
            return 300
        default:
            return 100
        }
    }

    private func isSuspiciousPermissionChange(oldPermission: String, newPermission: String) -> Bool {
        // Define suspicious permission changes
        let dangerousChanges = [
            ("private", "public"),
            ("restricted", "public"),
            ("owner", "public"),
        ]

        return dangerousChanges.contains { oldPermission.lowercased().contains($0.0) &&
            newPermission.lowercased().contains($0.1)
        }
    }

    private func validateAuditTrail() -> Bool {
        // Basic integrity check - ensure audit trail is not empty and recent
        let auditTrail = auditLogger.getAuditTrail(from: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        return !auditTrail.isEmpty
    }

    private func checkComplianceViolations() -> [String] {
        var violations: [String] = []

        // Check for unencrypted sensitive data patterns
        // This would be more sophisticated in a real implementation

        return violations
    }

    private func checkAnomalyPatterns() {
        for pattern in anomalyPatterns {
            // Check if pattern should trigger an alert
            if shouldTriggerPattern(pattern) {
                let alert = SecurityAlert(
                    type: .dataAnomaly,
                    severity: pattern.severity,
                    message: "Anomaly pattern detected: \(pattern.pattern)",
                    details: ["pattern_id": pattern.id.uuidString],
                    recommendedAction: "Review anomaly pattern and adjust thresholds if necessary"
                )
                securityAlerts.send(alert)

                // Update last triggered
                updatePatternLastTriggered(pattern.id)
            }
        }
    }

    private func shouldTriggerPattern(_ pattern: AnomalyPattern) -> Bool {
        // Simple time-based check
        if let lastTriggered = pattern.lastTriggered {
            let timeSinceLastTrigger = Date().timeIntervalSince(lastTriggered)
            return timeSinceLastTrigger >= pattern.timeWindow
        }
        return true // Never triggered before
    }

    private func loadAnomalyPatterns() {
        // Load predefined anomaly patterns
        anomalyPatterns = [
            AnomalyPattern(
                id: UUID(),
                pattern: "excessive_task_creations",
                threshold: 50,
                timeWindow: 3600,
                severity: .warning,
                lastTriggered: nil
            ),
            AnomalyPattern(
                id: UUID(),
                pattern: "bulk_data_deletion",
                threshold: 100,
                timeWindow: 3600,
                severity: .error,
                lastTriggered: nil
            ),
        ]
    }

    private func updatePatternLastTriggered(_ patternId: UUID) {
        if let index = anomalyPatterns.firstIndex(where: { $0.id == patternId }) {
            anomalyPatterns[index].lastTriggered = Date()
        }
    }
}
