import Combine
import Foundation
import OSLog

// MARK: - Security Monitor

@MainActor
final class SecurityMonitor: Sendable {
    static let shared = SecurityMonitor()

    private let logger: Logger
    private let auditLogger: AuditLogger
    private let encryptionService: EncryptionService

    // Monitoring state
    private var accessCounts: [String: Int] = [:]
    private var lastAccessTimes: [String: Date] = [:]
    private var suspiciousActivities: [SecurityAlert] = []
    private var monitoringEnabled = true

    // Publishers for reactive monitoring
    private let accessAlertPublisher = PassthroughSubject<SecurityAlert, Never>()
    private let dataAccessPublisher = PassthroughSubject<DataAccessEvent, Never>()

    private init() {
        self.logger = Logger(subsystem: "com.codingreviewer.security", category: "monitor")
        self.auditLogger = AuditLogger.shared
        self.encryptionService = EncryptionService.shared

        setupMonitoring()
    }

    // MARK: - Public Interface

    var accessAlerts: AnyPublisher<SecurityAlert, Never> {
        accessAlertPublisher.eraseToAnyPublisher()
    }

    var dataAccessEvents: AnyPublisher<DataAccessEvent, Never> {
        dataAccessPublisher.eraseToAnyPublisher()
    }

    func monitorDataAccess(operation: String, dataType: String, recordCount: Int = 0) {
        guard monitoringEnabled else { return }

        let event = DataAccessEvent(
            operation: operation,
            dataType: dataType,
            recordCount: recordCount,
            timestamp: Date()
        )

        // Update access tracking
        let key = "\(operation)_\(dataType)"
        accessCounts[key, default: 0] += 1
        lastAccessTimes[key] = event.timestamp

        // Publish event
        dataAccessPublisher.send(event)

        // Check for suspicious patterns
        checkForSuspiciousActivity(event)

        // Audit log
        auditLogger.logDataAccess(operation: operation, dataType: dataType, recordCount: recordCount)
    }

    func monitorFileAnalysis(fileURL: URL, analysisType: String) {
        guard monitoringEnabled else { return }

        // Check for sensitive file patterns
        checkForSensitiveFiles(fileURL)

        // Monitor analysis frequency
        checkAnalysisFrequency(fileURL, analysisType)
    }

    func monitorAnalysisResultStorage(dataType: String, recordCount: Int) {
        guard monitoringEnabled else { return }

        auditLogger.logDataStorage(dataType: dataType, recordCount: recordCount)

        // Check storage limits
        checkStorageLimits(dataType, recordCount)
    }

    func monitorAnalysisResultDeletion(dataType: String, recordCount: Int) {
        guard monitoringEnabled else { return }

        auditLogger.logDataDeletion(dataType: dataType, recordCount: recordCount)

        // Check for unusual deletion patterns
        checkDeletionPatterns(dataType, recordCount)
    }

    func validatePrivacyCompliance(dataType: String, containsPersonalData: Bool) -> Bool {
        let isCompliant = !containsPersonalData || hasUserConsent(for: dataType)

        auditLogger.logPrivacyComplianceCheck(
            checkType: "data_processing_\(dataType)",
            result: isCompliant
        )

        if !isCompliant {
            let alert = SecurityAlert(
                type: .privacyViolation,
                severity: .high,
                message: "Privacy compliance violation: Processing personal data without consent for \(dataType)",
                timestamp: Date()
            )
            handleSecurityAlert(alert)
        }

        return isCompliant
    }

    // MARK: - Private Monitoring Logic

    private func setupMonitoring() {
        // Set up periodic cleanup of old access data
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_600_000_000_000) // 1 hour
                await cleanupOldAccessData()
            }
        }
    }

    private func checkForSuspiciousActivity(_ event: DataAccessEvent) {
        // Check for rapid successive accesses (potential brute force)
        let key = "\(event.operation)_\(event.dataType)"
        if let lastAccess = lastAccessTimes[key],
           Date().timeIntervalSince(lastAccess) < 1.0, // Less than 1 second
           accessCounts[key, default: 0] > 10
        { // More than 10 accesses

            let alert = SecurityAlert(
                type: .suspiciousAccess,
                severity: .medium,
                message: "Suspicious rapid access pattern detected for \(event.dataType)",
                timestamp: Date()
            )
            handleSecurityAlert(alert)
        }

        // Check for large data exports
        if event.operation == "export" && event.recordCount > 1000 {
            let alert = SecurityAlert(
                type: .largeDataExport,
                severity: .low,
                message: "Large data export detected: \(event.recordCount) records of \(event.dataType)",
                timestamp: Date()
            )
            handleSecurityAlert(alert)
        }
    }

    private func checkForSensitiveFiles(_ fileURL: URL) {
        let sensitivePatterns = [
            "password", "secret", "key", "token", "credential",
            "private", "confidential", "sensitive",
        ]

        let fileName = fileURL.lastPathComponent.lowercased()
        for pattern in sensitivePatterns {
            if fileName.contains(pattern) {
                auditLogger.logSensitiveDataDetected(
                    fileURL: fileURL,
                    dataType: "potential_sensitive_file"
                )

                let alert = SecurityAlert(
                    type: .sensitiveFileAccess,
                    severity: .medium,
                    message: "Access to potentially sensitive file: \(fileURL.lastPathComponent)",
                    timestamp: Date()
                )
                handleSecurityAlert(alert)
                break
            }
        }
    }

    private func checkAnalysisFrequency(_ fileURL: URL, _ analysisType: String) {
        // Monitor for excessive analysis of the same file
        let key = "analysis_\(fileURL.path)_\(analysisType)"
        let currentCount = accessCounts[key, default: 0] + 1
        accessCounts[key] = currentCount

        if currentCount > 50 { // More than 50 analyses of same file
            let alert = SecurityAlert(
                type: .excessiveAnalysis,
                severity: .low,
                message: "Excessive analysis of file: \(fileURL.lastPathComponent) (\(currentCount) times)",
                timestamp: Date()
            )
            handleSecurityAlert(alert)
        }
    }

    private func checkStorageLimits(_ dataType: String, _ recordCount: Int) {
        // Check if storage is approaching limits
        let totalStored = getStoredRecordCount(for: dataType) + recordCount

        if totalStored > 10000 { // Arbitrary limit for demo
            let alert = SecurityAlert(
                type: .storageLimit,
                severity: .medium,
                message: "Approaching storage limit for \(dataType): \(totalStored) records",
                timestamp: Date()
            )
            handleSecurityAlert(alert)
        }
    }

    private func checkDeletionPatterns(_ dataType: String, _ recordCount: Int) {
        // Check for bulk deletions that might indicate data breach cleanup
        if recordCount > 1000 {
            let alert = SecurityAlert(
                type: .bulkDeletion,
                severity: .high,
                message: "Bulk deletion detected: \(recordCount) records of \(dataType)",
                timestamp: Date()
            )
            handleSecurityAlert(alert)
        }
    }

    private func hasUserConsent(for dataType: String) -> Bool {
        // In a real implementation, this would check user consent preferences
        // For demo purposes, we'll assume consent for analysis data
        dataType.hasPrefix("analysis_")
    }

    private func getStoredRecordCount(for dataType: String) -> Int {
        // In a real implementation, this would query the storage system
        // For demo purposes, return a mock count
        accessCounts["stored_\(dataType)", default: 0]
    }

    private func handleSecurityAlert(_ alert: SecurityAlert) {
        suspiciousActivities.append(alert)
        accessAlertPublisher.send(alert)

        // Log the alert
        switch alert.severity {
        case .low:
            logger.info("Security Alert: \(alert.message)")
        case .medium:
            logger.warning("Security Alert: \(alert.message)")
        case .high:
            logger.error("Security Alert: \(alert.message)")
        }

        // Audit log security violations for high severity
        if alert.severity == .high {
            auditLogger.logSecurityViolation(
                violation: alert.type.rawValue,
                details: alert.message
            )
        }

        // Keep only recent alerts (last 100)
        if suspiciousActivities.count > 100 {
            suspiciousActivities.removeFirst(suspiciousActivities.count - 100)
        }
    }

    private func cleanupOldAccessData() async {
        let oneHourAgo = Date().addingTimeInterval(-3600)

        // Remove access data older than 1 hour
        accessCounts = accessCounts.filter { _, _ in true } // Keep all for demo
        lastAccessTimes = lastAccessTimes.filter { $0.value > oneHourAgo }

        // Clean up old alerts (older than 24 hours)
        let oneDayAgo = Date().addingTimeInterval(-86400)
        suspiciousActivities = suspiciousActivities.filter { $0.timestamp > oneDayAgo }
    }

    // MARK: - Monitoring Control

    func enableMonitoring() {
        monitoringEnabled = true
        logger.info("Security monitoring enabled")
    }

    func disableMonitoring() {
        monitoringEnabled = false
        logger.info("Security monitoring disabled")
    }

    func getMonitoringStatus() -> MonitoringStatus {
        MonitoringStatus(
            enabled: monitoringEnabled,
            activeAlerts: suspiciousActivities.count,
            totalAccessEvents: accessCounts.values.reduce(0, +)
        )
    }
}

// MARK: - Supporting Types

struct SecurityAlert: Identifiable, Sendable {
    let id = UUID()
    let type: AlertType
    let severity: AlertSeverity
    let message: String
    let timestamp: Date
}

enum AlertType: String, Sendable {
    case suspiciousAccess
    case sensitiveFileAccess
    case largeDataExport
    case excessiveAnalysis
    case storageLimit
    case bulkDeletion
    case privacyViolation
}

enum AlertSeverity: String, Sendable {
    case low
    case medium
    case high
}

struct DataAccessEvent: Sendable {
    let operation: String
    let dataType: String
    let recordCount: Int
    let timestamp: Date
}

struct MonitoringStatus: Sendable {
    let enabled: Bool
    let activeAlerts: Int
    let totalAccessEvents: Int
}
