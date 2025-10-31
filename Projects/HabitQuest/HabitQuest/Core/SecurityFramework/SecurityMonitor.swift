//
//  SecurityMonitor.swift
//  HabitQuest
//
//  Created by Code Review Agent on 2025-10-30
//  Copyright © 2025 HabitQuest. All rights reserved.
//

import Combine
import Foundation
import OSLog

/// Security alert severity levels
public enum SecurityAlertSeverity: String, Codable, Sendable {
    case low
    case medium
    case high
    case critical
}

/// Security alert types for habit tracking
public enum SecurityAlertType: String, Codable, Sendable {
    case unusualActivity = "unusual_activity"
    case dataAccessAnomaly = "data_access_anomaly"
    case habitManipulation = "habit_manipulation"
    case streakAnomaly = "streak_anomaly"
    case privacyViolation = "privacy_violation"
    case consentIssue = "consent_issue"
    case encryptionFailure = "encryption_failure"
    case auditFailure = "audit_failure"
}

/// Security alert structure
public struct SecurityAlert: Codable, Sendable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let type: SecurityAlertType
    public let severity: SecurityAlertSeverity
    public let title: String
    public let description: String
    public let userId: String?
    public let resourceId: String?
    public let metadata: [String: String]?
    public var resolved: Bool
    public var resolvedAt: Date?

    public init(
        type: SecurityAlertType,
        severity: SecurityAlertSeverity,
        title: String,
        description: String,
        userId: String? = nil,
        resourceId: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.type = type
        self.severity = severity
        self.title = title
        self.description = description
        self.userId = userId
        self.resourceId = resourceId
        self.metadata = metadata
        self.resolved = false
        self.resolvedAt = nil
    }
}

/// Real-time security monitoring and alerting system for HabitQuest
/// Monitors habit tracking operations for security anomalies and privacy compliance
@MainActor
public final class SecurityMonitor: ObservableObject {
    public static let shared = SecurityMonitor()

    private let logger = Logger.shared
    private let auditLogger = AuditLogger.shared

    // Published properties for UI updates
    @Published public var activeAlerts: [SecurityAlert] = []
    @Published public var alertCount: Int = 0

    // Monitoring state
    private var habitCompletionPatterns: [String: [Date]] = [:]
    private var lastActivityTimestamps: [String: Date] = [:]
    private var consentStates: [String: Bool] = [:]

    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupMonitoring()
    }

    // MARK: - Setup

    private func setupMonitoring() {
        // Setup periodic health checks
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.performHealthCheck() }
            }
            .store(in: &cancellables)

        // Setup daily pattern analysis
        Timer.publish(every: 86400, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.analyzeDailyPatterns() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Activity Monitoring

    /// Monitor habit completion activity
    public func monitorHabitCompletion(habitId: String, userId: String?) async {
        let now = Date()
        let key = habitId

        // Track completion patterns
        if habitCompletionPatterns[key] == nil {
            habitCompletionPatterns[key] = []
        }
        habitCompletionPatterns[key]?.append(now)

        // Keep only last 24 hours of data
        habitCompletionPatterns[key] = habitCompletionPatterns[key]?
            .filter { now.timeIntervalSince($0) < 86400 }

        // Check for unusual activity
        await checkForUnusualActivity(habitId: habitId, userId: userId)

        // Update last activity
        lastActivityTimestamps[key] = now
    }

    /// Monitor habit data access
    public func monitorDataAccess(resourceType: String, resourceId: String, userId: String?, operation: String) async {
        let metadata = [
            "resource_type": resourceType,
            "operation": operation,
            "access_time": ISO8601DateFormatter().string(from: Date()),
        ]

        // Check for data access anomalies
        await checkForDataAccessAnomaly(resourceId: resourceId, userId: userId, metadata: metadata)
    }

    /// Monitor streak updates
    public func monitorStreakUpdate(habitId: String, newStreak: Int, userId: String?) async {
        // Check for streak manipulation
        if newStreak > 1000 { // Unrealistic streak
            await createAlert(
                type: .streakAnomaly,
                severity: .high,
                title: "Unrealistic Streak Detected",
                description: "Habit streak of \(newStreak) days detected for habit \(habitId)",
                userId: userId,
                resourceId: habitId,
                metadata: ["streak_count": String(newStreak)]
            )
        }

        // Check for sudden streak changes
        await checkForStreakManipulation(habitId: habitId, newStreak: newStreak, userId: userId)
    }

    /// Monitor privacy settings
    public func monitorPrivacySettings(userId: String, settings: [String: Any]) async {
        // Check consent status
        if let dataSharing = settings["dataSharing"] as? Bool {
            consentStates[userId] = dataSharing

            if !dataSharing {
                await checkForPrivacyViolation(userId: userId)
            }
        }
    }

    // MARK: - Anomaly Detection

    private func checkForUnusualActivity(habitId: String, userId: String?) async {
        guard let completions = habitCompletionPatterns[habitId] else { return }

        let now = Date()
        let recentCompletions = completions.filter { now.timeIntervalSince($0) < 3600 } // Last hour

        // Alert if more than 50 completions in an hour (potential automation)
        if recentCompletions.count > 50 {
            await createAlert(
                type: .unusualActivity,
                severity: .medium,
                title: "Unusual Habit Completion Activity",
                description: "\(recentCompletions.count) habit completions in the last hour for habit \(habitId)",
                userId: userId,
                resourceId: habitId,
                metadata: ["completion_count": String(recentCompletions.count)]
            )
        }
    }

    private func checkForDataAccessAnomaly(resourceId: String, userId: String?, metadata: [String: String]) async {
        // Check for rapid successive access (potential brute force)
        let accessKey = "\(resourceId)_\(userId ?? "anonymous")"
        let now = Date()

        if let lastAccess = lastActivityTimestamps[accessKey],
           now.timeIntervalSince(lastAccess) < 1.0
        { // Less than 1 second
            await createAlert(
                type: .dataAccessAnomaly,
                severity: .medium,
                title: "Rapid Data Access Detected",
                description: "Unusual rapid access pattern detected for resource \(resourceId)",
                userId: userId,
                resourceId: resourceId,
                metadata: metadata
            )
        }

        lastActivityTimestamps[accessKey] = now
    }

    private func checkForStreakManipulation(habitId: String, newStreak: Int, userId: String?) async {
        // This would typically compare against historical data
        // For now, we'll flag extreme changes
        if newStreak > 365 { // More than a year
            await createAlert(
                type: .habitManipulation,
                severity: .low,
                title: "Extended Streak Achievement",
                description: "Impressive \(newStreak)-day streak achieved for habit \(habitId)",
                userId: userId,
                resourceId: habitId,
                metadata: ["streak_count": String(newStreak)]
            )
        }
    }

    private func checkForPrivacyViolation(userId: String) async {
        // Check if data operations occurred without consent
        let recentAlerts = activeAlerts.filter {
            $0.userId == userId &&
                $0.type == .dataAccessAnomaly &&
                !$0.resolved
        }

        if !recentAlerts.isEmpty {
            await createAlert(
                type: .privacyViolation,
                severity: .high,
                title: "Potential Privacy Violation",
                description: "Data access detected without user consent for user \(userId)",
                userId: userId,
                metadata: ["consent_status": "revoked"]
            )
        }
    }

    // MARK: - Alert Management

    /// Create a security alert
    public func createAlert(
        type: SecurityAlertType,
        severity: SecurityAlertSeverity,
        title: String,
        description: String,
        userId: String? = nil,
        resourceId: String? = nil,
        metadata: [String: String]? = nil
    ) async {
        let alert = SecurityAlert(
            type: type,
            severity: severity,
            title: title,
            description: description,
            userId: userId,
            resourceId: resourceId,
            metadata: metadata
        )

        // Add to active alerts
        activeAlerts.append(alert)
        alertCount = activeAlerts.count

        // Log security event
        logger.warning("\(type.rawValue): \(title)")

        // Audit log the alert
        await auditLogger.logEvent(
            type: .habitCreation, // Using existing type, would need to add security alert type
            severity: severity == .critical ? .critical : .warning,
            userId: userId,
            resourceId: resourceId,
            resourceType: "security_alert",
            action: "security_alert_generated",
            details: [
                "alert_type": type.rawValue,
                "alert_title": title,
                "alert_description": description,
            ]
        )

        // Auto-resolve low severity alerts after 24 hours
        if severity == .low {
            Task {
                try? await Task.sleep(nanoseconds: 86_400_000_000_000) // 24 hours
                await resolveAlert(alert.id)
            }
        }
    }

    /// Resolve a security alert
    public func resolveAlert(_ alertId: UUID) async {
        if let index = activeAlerts.firstIndex(where: { $0.id == alertId }) {
            var alert = activeAlerts[index]
            alert.resolved = true
            alert.resolvedAt = Date()
            activeAlerts[index] = alert
            alertCount = activeAlerts.count
        }
    }

    /// Get alerts for a specific user
    public func alertsForUser(_ userId: String) -> [SecurityAlert] {
        activeAlerts.filter { $0.userId == userId }
    }

    /// Get alerts by severity
    public func alertsBySeverity(_ severity: SecurityAlertSeverity) -> [SecurityAlert] {
        activeAlerts.filter { $0.severity == severity }
    }

    // MARK: - Health Monitoring

    private func performHealthCheck() async {
        // Check encryption service
        do {
            let encryptionValid = try await EncryptionService.shared.validateEncryption()
            if !encryptionValid {
                await createAlert(
                    type: .encryptionFailure,
                    severity: .critical,
                    title: "Encryption Service Failure",
                    description: "Encryption service validation failed",
                    metadata: ["service": "encryption"]
                )
            }
        } catch {
            await createAlert(
                type: .encryptionFailure,
                severity: .critical,
                title: "Encryption Service Error",
                description: "Failed to validate encryption service: \(error.localizedDescription)",
                metadata: ["error": error.localizedDescription]
            )
        }

        // Check for unresolved high-severity alerts
        let highSeverityAlerts = activeAlerts.filter {
            ($0.severity == .high || $0.severity == .critical) && !$0.resolved
        }

        if highSeverityAlerts.count > 10 {
            await createAlert(
                type: .unusualActivity,
                severity: .critical,
                title: "Excessive Security Alerts",
                description: "\(highSeverityAlerts.count) high-severity alerts remain unresolved",
                metadata: ["alert_count": String(highSeverityAlerts.count)]
            )
        }
    }

    private func analyzeDailyPatterns() async {
        // Analyze daily activity patterns for anomalies
        let now = Date()
        let dayAgo = now.addingTimeInterval(-86400)

        for (habitId, completions) in habitCompletionPatterns {
            let dailyCompletions = completions.filter { $0 > dayAgo }
            let averageCompletions = Double(dailyCompletions.count) / 24.0 // Per hour

            if averageCompletions > 10 { // More than 10 completions per hour sustained
                await createAlert(
                    type: .unusualActivity,
                    severity: .low,
                    title: "High Activity Pattern",
                    description: "Habit \(habitId) shows sustained high completion rate: \(String(format: "%.1f", averageCompletions))/hour",
                    resourceId: habitId,
                    metadata: ["hourly_rate": String(format: "%.1f", averageCompletions)]
                )
            }
        }

        // Clean up old data
        habitCompletionPatterns = habitCompletionPatterns.mapValues { completions in
            completions.filter { now.timeIntervalSince($0) < 86400 }
        }
        habitCompletionPatterns = habitCompletionPatterns.filter { !$0.value.isEmpty }
    }

    // MARK: - Compliance Monitoring

    /// Check GDPR compliance for data operations
    public func checkGDPRCompliance(userId: String, operation: String) async -> Bool {
        // Check if user has consented to data processing
        guard let hasConsent = consentStates[userId], hasConsent else {
            await createAlert(
                type: .consentIssue,
                severity: .high,
                title: "GDPR Consent Violation",
                description: "Data operation '\(operation)' performed without user consent",
                userId: userId,
                metadata: ["operation": operation, "gdpr_article": "7"]
            )
            return false
        }

        return true
    }

    /// Check HIPAA compliance for health data (if applicable)
    public func checkHIPAACompliance(userId: String, dataType: String) async -> Bool {
        // For habit tracking, HIPAA may not apply, but we monitor for health-related data
        let healthDataTypes = ["medical_history", "medication", "health_metrics"]

        if healthDataTypes.contains(dataType.lowercased()) {
            await createAlert(
                type: .privacyViolation,
                severity: .critical,
                title: "Potential HIPAA Concern",
                description: "Health-related data operation detected: \(dataType)",
                userId: userId,
                metadata: ["data_type": dataType, "regulation": "HIPAA"]
            )
            return false
        }

        return true
    }
}
