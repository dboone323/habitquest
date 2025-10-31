//
// SecurityMonitor.swift
// AvoidObstaclesGame
//
// Real-time security monitoring for game operations and anomaly detection.
// Monitors data access patterns, game state changes, and security events.
//

import Combine
import Foundation

/// Real-time security monitoring for game operations
public class SecurityMonitor: @unchecked Sendable {
    // MARK: - Properties

    /// Shared instance
    public static let shared = SecurityMonitor()

    /// Thread-safe lock for monitoring data
    private let monitorLock = NSLock()

    /// Audit logger instance
    private let auditLogger = AuditLogger.shared

    /// Security event publisher
    public let securityEventPublisher = PassthroughSubject<GameSecurityEvent, Never>()

    /// Monitoring statistics
    private var monitoringStats: MonitoringStats = .init()

    /// Anomaly detection thresholds
    private let anomalyThresholds = AnomalyThresholds()

    /// Recent events buffer for pattern analysis
    private var recentEvents: [GameSecurityEvent] = []

    /// Maximum events to keep for analysis
    private let maxRecentEvents = 100

    // MARK: - Initialization

    private init() {}

    // MARK: - Data Access Monitoring

    /// Monitors game data access operations
    /// - Parameters:
    ///   - operation: The data operation type
    ///   - entityType: Type of game entity
    ///   - dataCount: Number of data items accessed
    ///   - playerId: Optional player identifier
    public func monitorDataAccess(operation: DataOperation, entityType: String, dataCount: Int, playerId: String? = nil) {
        monitorLock.lock()
        defer { monitorLock.unlock() }

        // Update statistics
        monitoringStats.totalDataAccesses += 1
        monitoringStats.dataAccessByType[entityType, default: 0] += 1

        // Log the access
        auditLogger.logDataAccess(operation: operation, entityType: entityType, dataCount: dataCount, playerId: playerId)

        // Check for anomalies
        checkForAnomalies(operation: operation, entityType: entityType, dataCount: dataCount, playerId: playerId)

        // Publish security event
        securityEventPublisher.send(.gameDataAccessed)
    }

    /// Monitors player analytics access
    /// - Parameters:
    ///   - analyticsType: Type of analytics accessed
    ///   - playerId: Player identifier
    public func monitorAnalyticsAccess(analyticsType: String, playerId: String) {
        monitorLock.lock()
        defer { monitorLock.unlock() }

        monitoringStats.analyticsAccesses += 1
        monitoringStats.analyticsAccessByType[analyticsType, default: 0] += 1

        auditLogger.logAnalyticsAccess(analyticsType: analyticsType, playerId: playerId)

        // Check privacy compliance
        checkPrivacyCompliance(analyticsType: analyticsType, playerId: playerId)

        securityEventPublisher.send(.playerAnalyticsAccessed)
    }

    /// Monitors game state changes
    /// - Parameters:
    ///   - gameMode: Current game mode
    ///   - difficulty: Game difficulty level
    ///   - playerId: Optional player identifier
    public func monitorGameStateChange(gameMode: String, difficulty: String, playerId: String? = nil) {
        monitorLock.lock()
        defer { monitorLock.unlock() }

        monitoringStats.gameStateChanges += 1
        monitoringStats.gameStateByMode[gameMode, default: 0] += 1

        auditLogger.logGameStateChange(gameMode: gameMode, difficulty: difficulty, playerId: playerId)

        securityEventPublisher.send(.gameStateChanged)
    }

    /// Monitors sync operations for game data
    /// - Parameters:
    ///   - operation: The sync operation type
    ///   - recordCount: Number of records synced
    ///   - playerId: Optional player identifier
    public func monitorSyncOperation(operation: String, recordCount: Int, playerId: String? = nil) {
        monitorLock.lock()
        defer { monitorLock.unlock() }

        monitoringStats.syncOperations += 1

        let details: [String: Any] = [
            "operation": operation,
            "recordCount": recordCount,
            "syncType": "game_data",
        ]

        auditLogger.logSecurityEvent(.gameDataModified, details: details, playerId: playerId)

        // Check for bulk operations
        if recordCount > anomalyThresholds.maxRecordsPerSync {
            auditLogger.logSecurityEvent(.gameDataModified, details: [
                "anomaly": "bulk_sync_operation",
                "recordCount": recordCount,
                "threshold": anomalyThresholds.maxRecordsPerSync,
            ], playerId: playerId)
        }

        securityEventPublisher.send(.gameDataModified)
    }

    // MARK: - Anomaly Detection

    private func checkForAnomalies(operation: DataOperation, entityType: String, dataCount: Int, playerId: String?) {
        // Check for excessive data access
        if dataCount > anomalyThresholds.maxDataAccessPerOperation {
            auditLogger.logSecurityEvent(.gameDataAccessed, details: [
                "anomaly": "excessive_data_access",
                "dataCount": dataCount,
                "threshold": anomalyThresholds.maxDataAccessPerOperation,
                "entityType": entityType,
            ], playerId: playerId)
        }

        // Check for rapid successive operations (potential automation)
        let recentAccesses = recentEvents.filter { $0 == .gameDataAccessed }.count
        if recentAccesses > anomalyThresholds.maxRapidAccesses {
            auditLogger.logSecurityEvent(.gameDataAccessed, details: [
                "anomaly": "rapid_successive_accesses",
                "recentCount": recentAccesses,
                "threshold": anomalyThresholds.maxRapidAccesses,
            ], playerId: playerId)
        }
    }

    private func checkPrivacyCompliance(analyticsType: String, playerId: String) {
        // Check if analytics access is within privacy limits
        let accessCount = monitoringStats.analyticsAccessByType[analyticsType, default: 0]
        if accessCount > anomalyThresholds.maxAnalyticsAccessPerSession {
            auditLogger.logSecurityEvent(.playerAnalyticsAccessed, details: [
                "privacy_check": "excessive_analytics_access",
                "analyticsType": analyticsType,
                "accessCount": accessCount,
                "threshold": anomalyThresholds.maxAnalyticsAccessPerSession,
            ], playerId: playerId)
        }
    }

    // MARK: - Statistics and Reporting

    /// Gets current monitoring statistics
    /// - Returns: Copy of monitoring statistics
    public func getMonitoringStats() -> MonitoringStats {
        monitorLock.lock()
        defer { monitorLock.unlock() }

        return monitoringStats
    }

    /// Resets monitoring statistics
    public func resetStats() {
        monitorLock.lock()
        defer { monitorLock.unlock() }

        monitoringStats = MonitoringStats()
        auditLogger.logSecurityEvent(.auditTrailCleared, details: ["reason": "stats_reset"])
    }

    /// Gets security health status
    /// - Returns: Security health assessment
    public func getSecurityHealth() -> SecurityHealth {
        monitorLock.lock()
        defer { monitorLock.unlock() }

        var issues: [SecurityIssue] = []

        // Check for anomalies
        if monitoringStats.totalDataAccesses > anomalyThresholds.maxTotalAccessesPerHour {
            issues.append(.highDataAccessRate)
        }

        if monitoringStats.analyticsAccesses > anomalyThresholds.maxAnalyticsAccessesPerHour {
            issues.append(.highAnalyticsAccessRate)
        }

        let health: SecurityHealthStatus = issues.isEmpty ? .healthy : .warning

        return SecurityHealth(status: health, issues: issues, lastChecked: Date())
    }
}

// MARK: - Supporting Types

/// Monitoring statistics
public struct MonitoringStats {
    public var totalDataAccesses: Int = 0
    public var analyticsAccesses: Int = 0
    public var gameStateChanges: Int = 0
    public var syncOperations: Int = 0

    public var dataAccessByType: [String: Int] = [:]
    public var analyticsAccessByType: [String: Int] = [:]
    public var gameStateByMode: [String: Int] = [:]
}

/// Anomaly detection thresholds
private struct AnomalyThresholds {
    let maxDataAccessPerOperation = 1000
    let maxRapidAccesses = 50
    let maxRecordsPerSync = 500
    let maxAnalyticsAccessPerSession = 20
    let maxTotalAccessesPerHour = 10000
    let maxAnalyticsAccessesPerHour = 500
}

/// Security health assessment
public struct SecurityHealth {
    public let status: SecurityHealthStatus
    public let issues: [SecurityIssue]
    public let lastChecked: Date
}

/// Security health status levels
public enum SecurityHealthStatus {
    case healthy
    case warning
    case critical
}

/// Security issues that can be detected
public enum SecurityIssue {
    case highDataAccessRate
    case highAnalyticsAccessRate
    case suspiciousPatterns
    case privacyViolation
}
