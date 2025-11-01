//
//  AuditLogger.swift
//  MomentumFinance
//
//  Created by Quantum Audit System
//  Copyright © 2025 Momentum Finance. All rights reserved.
//

import Foundation
import OSLog
import CryptoKit

// MARK: - Supporting Types

public enum AuditTransactionType: String, Codable, Sendable {
    case deposit
    case withdrawal
    case transfer
    case payment
    case refund
}

public enum AuthenticationMethod: String, Codable, Sendable {
    case password
    case biometric
    case twoFactor = "2fa"
    case hardwareKey = "hardware_key"
}

public enum DataAction: String, Codable, Sendable {
    case read
    case write
    case delete
    case update
}

public enum SecurityEventType: String, Codable, Sendable {
    case suspiciousActivity = "suspicious_activity"
    case dataBreach = "data_breach"
    case unauthorizedAccess = "unauthorized_access"
    case complianceViolation = "compliance_violation"
    case systemCompromise = "system_compromise"
    case system = "system"
    case dataAccess = "data_access"
}

public enum SecuritySeverity: String, Codable, Sendable {
    case low
    case medium
    case high
    case critical
}

public enum AuditEventType: String, Codable, Sendable {
    case transaction
    case authentication
    case dataAccess = "data_access"
    case security
    case system
    case budgetOperation = "budget_operation"
}

public struct AuditEntry: Encodable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let eventType: AuditEventType
    public let userId: String
    public let resourceId: String
    public let action: String
    public let details: Data
    public let ipAddress: String
    public let userAgent: String
    public let sessionId: String

    // Computed property to access details as dictionary
    public var detailsDictionary: [String: Any] {
        (try? JSONSerialization.jsonObject(with: details)) as? [String: Any] ?? [:]
    }

    private enum CodingKeys: String, CodingKey {
        case id, timestamp, eventType, userId, resourceId, action, details, ipAddress, userAgent, sessionId
    }

    public init(
        id: UUID,
        timestamp: Date,
        eventType: AuditEventType,
        userId: String,
        resourceId: String,
        action: String,
        details: [String: Any],
        ipAddress: String,
        userAgent: String,
        sessionId: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.eventType = eventType
        self.userId = userId
        self.resourceId = resourceId
        self.action = action
        // Convert details dictionary to JSON data
        self.details = try! JSONSerialization.data(withJSONObject: details)
        self.ipAddress = ipAddress
        self.userAgent = userAgent
        self.sessionId = sessionId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        eventType = try container.decode(AuditEventType.self, forKey: .eventType)
        userId = try container.decode(String.self, forKey: .userId)
        resourceId = try container.decode(String.self, forKey: .resourceId)
        action = try container.decode(String.self, forKey: .action)
        details = try container.decode(Data.self, forKey: .details)
        ipAddress = try container.decode(String.self, forKey: .ipAddress)
        userAgent = try container.decode(String.self, forKey: .userAgent)
        sessionId = try container.decode(String.self, forKey: .sessionId)
    }
}

public struct ComplianceReport {
    public let period: DateInterval
    public let totalTransactions: Int
    public let authenticationFailures: Int
    public let securityIncidents: Int
    public let auditEntries: [AuditEntry]

    public var complianceScore: Double {
        // Simple compliance scoring algorithm
        let baseScore = 100.0
        let failurePenalty = Double(authenticationFailures) * 2.0
        let incidentPenalty = Double(securityIncidents) * 5.0

        return max(0, baseScore - failurePenalty - incidentPenalty)
    }
}

/// Comprehensive audit logging system for financial data operations
/// Implements Phase 6 Security requirements with encrypted audit trails
@available(iOS 15.0, macOS 12.0, *)
public final class AuditLogger: @unchecked Sendable {

    // MARK: - Singleton

    @MainActor
    public static let shared = AuditLogger()

    // MARK: - Properties

    private let auditQueue: DispatchQueue
    private var auditBuffer: [AuditEntry] = []
    private let bufferFlushInterval: TimeInterval = 30.0 // Flush every 30 seconds
    private var flushTimer: Timer?

    private let encryptionKey: SymmetricKey
    private let auditFileURL: URL

    // MARK: - Initialization

    private init() {
        self.auditQueue = DispatchQueue(label: "com.momentumfinance.audit.queue", qos: .utility)

        // Generate or retrieve encryption key
        self.encryptionKey = Self.generateOrRetrieveEncryptionKey()

        // Set up audit file URL
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.auditFileURL = documentsURL.appendingPathComponent("audit_trail.enc")

        setupPeriodicFlush()
        Logger.logInfo("AuditLogger initialized with encrypted audit trail")
    }

    // MARK: - Public API

    /// Log a financial transaction with full audit trail
    /// - Parameters:
    ///   - transactionId: Unique transaction identifier
    ///   - amount: Transaction amount
    ///   - type: Transaction type (deposit, withdrawal, transfer, etc.)
    ///   - accountId: Account identifier
    ///   - userId: User identifier
    ///   - metadata: Additional context data
    public func logTransaction(
        transactionId: String,
        amount: Decimal,
        type: AuditTransactionType,
        accountId: String,
        userId: String,
        metadata: [String: Any]? = nil
    ) {
        let entry = AuditEntry(
            id: UUID(),
            timestamp: Date(),
            eventType: .transaction,
            userId: userId,
            resourceId: transactionId,
            action: type.rawValue,
            details: [
                "amount": amount,
                "accountId": accountId,
                "transactionType": type.rawValue
            ].merging(metadata ?? [:]) { $1 },
            ipAddress: getCurrentIPAddress(),
            userAgent: getCurrentUserAgent(),
            sessionId: getCurrentSessionId()
        )

        logEntry(entry)
    }

    /// Log user authentication event
    /// - Parameters:
    ///   - userId: User identifier
    ///   - success: Whether authentication was successful
    ///   - method: Authentication method used
    ///   - metadata: Additional context
    public func logAuthentication(
        userId: String,
        success: Bool,
        method: AuthenticationMethod,
        metadata: [String: Any]? = nil
    ) {
        let entry = AuditEntry(
            id: UUID(),
            timestamp: Date(),
            eventType: .authentication,
            userId: userId,
            resourceId: userId,
            action: success ? "login_success" : "login_failure",
            details: [
                "method": method.rawValue,
                "success": success
            ].merging(metadata ?? [:]) { $1 },
            ipAddress: getCurrentIPAddress(),
            userAgent: getCurrentUserAgent(),
            sessionId: getCurrentSessionId()
        )

        logEntry(entry)
    }

    /// Log data access event
    /// - Parameters:
    ///   - userId: User identifier
    ///   - resourceType: Type of resource accessed
    ///   - resourceId: Resource identifier
    ///   - action: Action performed (read, write, delete)
    ///   - metadata: Additional context
    public func logDataAccess(
        userId: String,
        resourceType: String,
        resourceId: String,
        action: DataAction,
        metadata: [String: Any]? = nil
    ) {
        let entry = AuditEntry(
            id: UUID(),
            timestamp: Date(),
            eventType: .dataAccess,
            userId: userId,
            resourceId: resourceId,
            action: action.rawValue,
            details: [
                "resourceType": resourceType
            ].merging(metadata ?? [:]) { $1 },
            ipAddress: getCurrentIPAddress(),
            userAgent: getCurrentUserAgent(),
            sessionId: getCurrentSessionId()
        )

        logEntry(entry)
    }

    /// Log security event
    /// - Parameters:
    ///   - eventType: Type of security event
    ///   - userId: User identifier (if applicable)
    ///   - details: Event details
    ///   - severity: Event severity level
    public func logSecurityEvent(
        eventType: SecurityEventType,
        userId: String? = nil,
        details: [String: Any],
        severity: SecuritySeverity = .medium
    ) {
        let entry = AuditEntry(
            id: UUID(),
            timestamp: Date(),
            eventType: .security,
            userId: userId ?? "system",
            resourceId: "security_event",
            action: eventType.rawValue,
            details: details.merging(["severity": severity.rawValue]) { $1 },
            ipAddress: getCurrentIPAddress(),
            userAgent: getCurrentUserAgent(),
            sessionId: getCurrentSessionId()
        )

        logEntry(entry)

        // Log to system logger with appropriate level
        switch severity {
        case .low:
            os_log(.info, log: .default, "Security event: %{public}@", eventType.rawValue)
        case .medium:
            os_log(.default, log: .default, "Security event: %{public}@", eventType.rawValue)
        case .high, .critical:
            os_log(.error, log: .default, "Security event: %{public}@", eventType.rawValue)
        }
    }

    /// Retrieve audit entries for a specific user within a date range
    /// - Parameters:
    ///   - userId: User identifier
    ///   - startDate: Start date for the query
    ///   - endDate: End date for the query
    /// - Returns: Array of audit entries
    public func getAuditTrail(
        for userId: String,
        from startDate: Date,
        to endDate: Date
    ) -> [AuditEntry] {
        // In a real implementation, this would query the encrypted audit database
        // For now, return from buffer (not persisted yet)
        return auditBuffer.filter { entry in
            entry.userId == userId &&
            entry.timestamp >= startDate &&
            entry.timestamp <= endDate
        }
    }

    /// Generate compliance report for regulatory requirements
    /// - Parameters:
    ///   - startDate: Report start date
    ///   - endDate: Report end date
    /// - Returns: Compliance report data
    public func generateComplianceReport(
        from startDate: Date,
        to endDate: Date
    ) -> ComplianceReport {
        let relevantEntries = auditBuffer.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }

        let transactionCount = relevantEntries.filter { $0.eventType == .transaction }.count
        let authFailureCount = relevantEntries.filter {
            $0.eventType == .authentication && $0.action == "login_failure"
        }.count
        let securityEvents = relevantEntries.filter { $0.eventType == .security }

        return ComplianceReport(
            period: DateInterval(start: startDate, end: endDate),
            totalTransactions: transactionCount,
            authenticationFailures: authFailureCount,
            securityIncidents: securityEvents.count,
            auditEntries: relevantEntries
        )
    }

    // MARK: - Private Methods

    private func logEntry(_ entry: AuditEntry) {
        auditQueue.async { [weak self] in
            guard let self = self else { return }

            self.auditBuffer.append(entry)

            // Immediate logging to system logger
            os_log(.info, log: .default, "Audit: %{public}@ - %{public}@ by %{public}@", entry.eventType.rawValue, entry.action, entry.userId)

            // Flush if buffer is getting large
            if self.auditBuffer.count >= 100 {
                self.flushAuditBuffer()
            }
        }
    }

    private func setupPeriodicFlush() {
        auditQueue.async { [weak self] in
            self?.flushTimer = Timer.scheduledTimer(
                withTimeInterval: self?.bufferFlushInterval ?? 30.0,
                repeats: true
            ) { [weak self] _ in
                self?.flushAuditBuffer()
            }
        }
    }

    private func flushAuditBuffer() {
        guard !auditBuffer.isEmpty else { return }

        do {
            let entriesToFlush = auditBuffer
            auditBuffer.removeAll()

            // Encrypt and persist audit entries
            try persistAuditEntries(entriesToFlush)

            os_log(.info, log: .default, "Flushed %d audit entries to encrypted storage", entriesToFlush.count)
        } catch {
            os_log(.error, log: .default, "Failed to flush audit buffer: %{public}@", error.localizedDescription)
            // Re-add entries to buffer for retry
            auditBuffer.insert(contentsOf: auditBuffer, at: 0)
        }
    }

    private func persistAuditEntries(_ entries: [AuditEntry]) throws {
        let jsonData = try JSONEncoder().encode(entries)
        let encryptedData = try encryptData(jsonData)

        // Append to encrypted audit file
        if FileManager.default.fileExists(atPath: auditFileURL.path) {
            let existingData = try Data(contentsOf: auditFileURL)
            var combinedData = existingData
            combinedData.append(encryptedData)
            try combinedData.write(to: auditFileURL)
        } else {
            try encryptedData.write(to: auditFileURL)
        }
    }

    private func encryptData(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        return sealedBox.combined!
    }

    private static func generateOrRetrieveEncryptionKey() -> SymmetricKey {
        // In production, this should retrieve from secure keychain
        // For development, generate a consistent key
        let keyData = "MomentumFinanceAuditKey2025".data(using: .utf8)!
        return SymmetricKey(data: SHA256.hash(data: keyData))
    }

    private func getCurrentIPAddress() -> String {
        // In a real implementation, this would get the actual IP
        // For now, return a placeholder
        return "192.168.1.1"
    }

    private func getCurrentUserAgent() -> String {
        // In a real implementation, this would get the actual user agent
        // For now, return a placeholder
        return "MomentumFinance/1.0 (iOS)"
    }

    private func getCurrentSessionId() -> String {
        // In a real implementation, this would get the current session ID
        // For now, return a placeholder
        return UUID().uuidString
    }
}

// MARK: - Supporting Types (moved to top of file)
