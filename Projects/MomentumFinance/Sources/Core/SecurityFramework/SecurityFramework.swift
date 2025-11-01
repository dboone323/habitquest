//
//  SecurityFramework.swift
//  MomentumFinance
//
//  Created by Quantum Security Framework
//  Copyright © 2025 Momentum Finance. All rights reserved.
//

import Foundation
import Combine

/// Quantum Security Framework for Momentum Finance
/// Provides comprehensive security, encryption, and compliance capabilities
///
/// This framework implements Phase 6 Security requirements including:
/// - Encrypted audit trails with AES-256-GCM
/// - Real-time security monitoring and alerting
/// - Compliance validation and reporting
/// - Secure key management and rotation
/// - Financial data protection standards
///
/// Usage:
/// ```swift
/// import SecurityFramework
///
/// // Log a financial transaction
/// AuditLogger.shared.logTransaction(
///     transactionId: "txn_123",
///     amount: 100.0,
///     type: .transfer,
///     accountId: "acc_456",
///     userId: "user_789"
/// )
///
/// // Encrypt sensitive data
/// let encrypted = try EncryptionService.shared.encryptString("sensitive data")
///
/// // Monitor security events
/// SecurityMonitor.shared.reportSecurityEvent(SecurityEvent(
///     type: .suspiciousActivity,
///     userId: "user_789",
///     severity: .medium,
///     details: ["activity": "unusual_login"]
/// ))
/// ```
public struct SecurityFramework {

    /// Version of the Security Framework
    public static let version = "1.0.0"

    /// Initialize the security framework
    /// This should be called early in the application lifecycle
    @MainActor
    public static func initialize() {
        // Initialize all security services
        _ = AuditLogger.shared
        _ = EncryptionService.shared
        _ = SecurityMonitor.shared

        print("🔒 Quantum Security Framework v\(version) initialized")
    }

    /// Perform a complete security health check
    /// - Returns: Security assessment report
    @MainActor
    public static func performSecurityHealthCheck() -> SecurityAssessment {
        return SecurityMonitor.shared.performSecurityAssessment()
    }

    /// Validate compliance with regulatory requirements
    /// - Returns: Compliance validation result
    @MainActor
    public static func validateCompliance() -> ComplianceValidation {
        return SecurityMonitor.shared.validateCompliance()
    }

    /// Get security monitoring alerts publisher
    /// - Returns: Publisher for security alerts
    @MainActor
    public static func securityAlertsPublisher() -> AnyPublisher<SecurityAlert, Never> {
        return SecurityMonitor.shared.securityAlertsPublisher.eraseToAnyPublisher()
    }

    /// Get compliance status publisher
    /// - Returns: Publisher for compliance status updates
    @MainActor
    public static func complianceStatusPublisher() -> AnyPublisher<ComplianceStatus, Never> {
        return SecurityMonitor.shared.complianceStatusPublisher.eraseToAnyPublisher()
    }
}

// MARK: - Convenience Extensions

extension AuditLogger {
    /// Convenience method to log user login
    /// - Parameters:
    ///   - userId: User identifier
    ///   - success: Whether login was successful
    ///   - method: Authentication method used
    @MainActor
    public static func logLogin(userId: String, success: Bool, method: AuthenticationMethod = .password) {
        shared.logAuthentication(userId: userId, success: success, method: method)
    }

    /// Convenience method to log user logout
    /// - Parameter userId: User identifier
    @MainActor
    public static func logLogout(userId: String) {
        shared.logSecurityEvent(
            eventType: .unauthorizedAccess,
            userId: userId,
            details: ["action": "logout"],
            severity: .low
        )
    }
}

extension EncryptionService {
    /// Convenience method to encrypt user financial data
    /// - Parameter data: Financial data to encrypt
    /// - Returns: Encrypted data
    public static func encryptFinancialData(_ data: Data) throws -> EncryptedData {
        return try shared.encryptData(data)
    }

    /// Convenience method to decrypt user financial data
    /// - Parameter encryptedData: Encrypted financial data
    /// - Returns: Decrypted data
    public static func decryptFinancialData(_ encryptedData: EncryptedData) throws -> Data {
        return try shared.decryptData(encryptedData)
    }
}

extension SecurityMonitor {
    /// Convenience method to report failed login attempt
    /// - Parameter userId: User identifier
    @MainActor
    public static func reportFailedLogin(userId: String) {
        let event = SecurityEvent(
            type: .unauthorizedAccess,
            userId: userId,
            severity: .low,
            details: ["attempt": "failed"]
        )
        shared.reportSecurityEvent(event)
    }

    /// Convenience method to report suspicious activity
    /// - Parameters:
    ///   - userId: User identifier
    ///   - activity: Description of suspicious activity
    @MainActor
    public static func reportSuspiciousActivity(userId: String, activity: String) {
        let event = SecurityEvent(
            type: .suspiciousActivity,
            userId: userId,
            severity: .medium,
            details: ["activity": activity]
        )
        shared.reportSecurityEvent(event)
    }
}

// Note: All types (AuditEntry, EncryptedData, SecurityEvent, SecurityAlert,
// SecurityAssessment, ComplianceValidation) are already available at module level

// Note: TransactionType, AuthenticationMethod, DataAction, SecurityEventType,
// SecuritySeverity, AuditEventType, SecurityAlertType, and ComplianceLevel
// are already available at module level from their respective files
