import CryptoKit
import Foundation
import OSLog

// MARK: - Code Analysis Security Events

enum CodeAnalysisSecurityEvent: String, Codable, Sendable {
    case fileAnalysisStarted = "file_analysis_started"
    case fileAnalysisCompleted = "file_analysis_completed"
    case fileAnalysisFailed = "file_analysis_failed"
    case documentationAnalysisStarted = "documentation_analysis_started"
    case documentationAnalysisCompleted = "documentation_analysis_completed"
    case documentationAnalysisFailed = "documentation_analysis_failed"
    case sensitiveDataDetected = "sensitive_data_detected"
    case analysisResultAccessed = "analysis_result_accessed"
    case analysisResultStored = "analysis_result_stored"
    case analysisResultDeleted = "analysis_result_deleted"
    case securityViolation = "security_violation"
    case privacyComplianceCheck = "privacy_compliance_check"
}

// MARK: - Audit Logger

@MainActor
final class AuditLogger: Sendable {
    static let shared = AuditLogger()

    private let logger: Logger
    private let auditLog: OSLog
    private let encryptionService: EncryptionService

    private init() {
        self.logger = Logger(subsystem: "com.codingreviewer.security", category: "audit")
        self.auditLog = OSLog(subsystem: "com.codingreviewer.security", category: "audit")
        self.encryptionService = EncryptionService.shared
    }

    // MARK: - File Analysis Audit

    func logFileAnalysisStarted(fileURL: URL, analysisType: String) {
        let event = AuditEvent(
            eventType: .info,
            event: .fileAnalysisStarted,
            message: "Started code analysis for file: \(fileURL.lastPathComponent)",
            metadata: [
                "file_path": fileURL.path,
                "analysis_type": analysisType,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    func logFileAnalysisCompleted(fileURL: URL, analysisType: String, issueCount: Int) {
        let event = AuditEvent(
            eventType: .info,
            event: .fileAnalysisCompleted,
            message: "Completed code analysis for file: \(fileURL.lastPathComponent) with \(issueCount) issues",
            metadata: [
                "file_path": fileURL.path,
                "analysis_type": analysisType,
                "issue_count": String(issueCount),
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    func logFileAnalysisFailed(fileURL: URL, analysisType: String, error: Error) {
        let event = AuditEvent(
            eventType: .error,
            event: .fileAnalysisFailed,
            message: "Failed code analysis for file: \(fileURL.lastPathComponent) - \(error.localizedDescription)",
            metadata: [
                "file_path": fileURL.path,
                "analysis_type": analysisType,
                "error": error.localizedDescription,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    // MARK: - Documentation Analysis Audit

    func logDocumentationAnalysisStarted(fileURL: URL) {
        let event = AuditEvent(
            eventType: .info,
            event: .documentationAnalysisStarted,
            message: "Started documentation analysis for file: \(fileURL.lastPathComponent)",
            metadata: [
                "file_path": fileURL.path,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    func logDocumentationAnalysisCompleted(fileURL: URL, coverage: Double) {
        let event = AuditEvent(
            eventType: .info,
            event: .documentationAnalysisCompleted,
            message: "Completed documentation analysis for file: \(fileURL.lastPathComponent) with \(String(format: "%.1f", coverage * 100))% coverage",
            metadata: [
                "file_path": fileURL.path,
                "coverage": String(coverage),
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    func logDocumentationAnalysisFailed(fileURL: URL, error: Error) {
        let event = AuditEvent(
            eventType: .error,
            event: .documentationAnalysisFailed,
            message: "Failed documentation analysis for file: \(fileURL.lastPathComponent) - \(error.localizedDescription)",
            metadata: [
                "file_path": fileURL.path,
                "error": error.localizedDescription,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    // MARK: - Data Access Audit

    func logDataAccess(operation: String, dataType: String, recordCount: Int = 0) {
        let event = AuditEvent(
            eventType: .info,
            event: .analysisResultAccessed,
            message: "Data access: \(operation) on \(dataType) (\(recordCount) records)",
            metadata: [
                "operation": operation,
                "data_type": dataType,
                "record_count": String(recordCount),
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    func logDataStorage(dataType: String, recordCount: Int) {
        let event = AuditEvent(
            eventType: .info,
            event: .analysisResultStored,
            message: "Stored \(recordCount) \(dataType) records",
            metadata: [
                "data_type": dataType,
                "record_count": String(recordCount),
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    func logDataDeletion(dataType: String, recordCount: Int) {
        let event = AuditEvent(
            eventType: .warning,
            event: .analysisResultDeleted,
            message: "Deleted \(recordCount) \(dataType) records",
            metadata: [
                "data_type": dataType,
                "record_count": String(recordCount),
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    // MARK: - Security Events

    func logSensitiveDataDetected(fileURL: URL, dataType: String) {
        let event = AuditEvent(
            eventType: .warning,
            event: .sensitiveDataDetected,
            message: "Sensitive data detected in file: \(fileURL.lastPathComponent) (\(dataType))",
            metadata: [
                "file_path": fileURL.path,
                "data_type": dataType,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    func logSecurityViolation(violation: String, details: String) {
        let event = AuditEvent(
            eventType: .error,
            event: .securityViolation,
            message: "Security violation: \(violation) - \(details)",
            metadata: [
                "violation": violation,
                "details": details,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    func logPrivacyComplianceCheck(checkType: String, result: Bool) {
        let event = AuditEvent(
            eventType: result ? .info : .warning,
            event: .privacyComplianceCheck,
            message: "Privacy compliance check: \(checkType) - \(result ? "PASSED" : "FAILED")",
            metadata: [
                "check_type": checkType,
                "result": String(result),
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]
        )
        logEvent(event)
    }

    // MARK: - Private Methods

    private func logEvent(_ event: AuditEvent) {
        // Log to OSLog
        switch event.eventType {
        case .info:
            logger.info("\(event.message, privacy: .public)")
        case .warning:
            logger.warning("\(event.message, privacy: .public)")
        case .error:
            logger.error("\(event.message, privacy: .public)")
        }

        // Store encrypted audit trail
        Task {
            await storeEncryptedAuditEvent(event)
        }
    }

    private func storeEncryptedAuditEvent(_ event: AuditEvent) async {
        do {
            let eventData = try JSONEncoder().encode(event)
            _ = try await encryptionService.encrypt(data: eventData)
            // In a real implementation, this would be stored in a secure database
            // For now, we'll just log that it would be stored
            logger.debug("Audit event encrypted and would be stored: \(event.event.rawValue)")
        } catch {
            logger.error("Failed to encrypt audit event: \(error.localizedDescription)")
        }
    }
}

// MARK: - Audit Event Types

private enum AuditEventType: String, Codable {
    case info
    case warning
    case error
}

private struct AuditEvent: Codable {
    let eventType: AuditEventType
    let event: CodeAnalysisSecurityEvent
    let message: String
    let metadata: [String: String]
    let timestamp: Date

    init(eventType: AuditEventType, event: CodeAnalysisSecurityEvent, message: String, metadata: [String: String]) {
        self.eventType = eventType
        self.event = event
        self.message = message
        self.metadata = metadata
        self.timestamp = Date()
    }
}
