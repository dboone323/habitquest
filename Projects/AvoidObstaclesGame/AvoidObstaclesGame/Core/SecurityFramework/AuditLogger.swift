//
// AuditLogger.swift
// AvoidObstaclesGame
//
// Enterprise-grade audit logging for game security events and compliance monitoring.
// Logs player actions, game state changes, and security-relevant events.
//

import Foundation
import OSLog

/// Enterprise audit logger for game security events
public class AuditLogger: @unchecked Sendable {
    // MARK: - Properties

    /// Shared instance
    public static let shared = AuditLogger()

    /// OSLog logger for audit events
    private let logger = OSLog(subsystem: "com.avoidobstacles.game", category: "Audit")

    /// Thread-safe lock for audit trail
    private let auditLock = NSLock()

    /// In-memory audit trail for recent events
    private var auditTrail: [AuditEvent] = []

    /// Maximum audit trail size
    private let maxAuditTrailSize = 1000

    // MARK: - Initialization

    private init() {}

    // MARK: - Audit Logging

    /// Logs a game security event
    /// - Parameters:
    ///   - event: The security event type
    ///   - details: Additional event details
    ///   - playerId: Optional player identifier
    public func logSecurityEvent(_ event: GameSecurityEvent, details: [String: Any]? = nil, playerId: String? = nil) {
        let auditEvent = AuditEvent(
            timestamp: Date(),
            event: event,
            details: details,
            playerId: playerId
        )

        auditLock.lock()
        defer { auditLock.unlock() }

        // Add to in-memory trail
        auditTrail.append(auditEvent)

        // Maintain trail size
        if auditTrail.count > maxAuditTrailSize {
            auditTrail.removeFirst(auditTrail.count - maxAuditTrailSize)
        }

        // Log to OSLog
        let message = formatLogMessage(for: auditEvent)
        os_log(.info, log: logger, "%{public}@", message)

        // Log critical events at higher level
        if event.isCritical {
            os_log(.error, log: logger, "CRITICAL: %{public}@", message)
        }
    }

    /// Logs game data access for compliance monitoring
    /// - Parameters:
    ///   - operation: The data operation type
    ///   - entityType: Type of game entity being accessed
    ///   - dataCount: Number of data items
    ///   - playerId: Optional player identifier
    public func logDataAccess(operation: DataOperation, entityType: String, dataCount: Int, playerId: String? = nil) {
        let details: [String: Any] = [
            "operation": operation.rawValue,
            "entityType": entityType,
            "dataCount": dataCount,
        ]

        let event: GameSecurityEvent = switch operation {
        case .create: .gameDataCreated
        case .read: .gameDataAccessed
        case .update: .gameDataModified
        case .delete: .gameDataDeleted
        }

        logSecurityEvent(event, details: details, playerId: playerId)
    }

    /// Logs player analytics access for privacy compliance
    /// - Parameters:
    ///   - analyticsType: Type of analytics being accessed
    ///   - playerId: Player identifier
    public func logAnalyticsAccess(analyticsType: String, playerId: String) {
        let details: [String: Any] = [
            "analyticsType": analyticsType,
            "accessType": "read",
        ]

        logSecurityEvent(.playerAnalyticsAccessed, details: details, playerId: playerId)
    }

    /// Logs game state changes for security monitoring
    /// - Parameters:
    ///   - gameMode: Current game mode
    ///   - difficulty: Game difficulty level
    ///   - playerId: Optional player identifier
    public func logGameStateChange(gameMode: String, difficulty: String, playerId: String? = nil) {
        let details: [String: Any] = [
            "gameMode": gameMode,
            "difficulty": difficulty,
            "changeType": "state_transition",
        ]

        logSecurityEvent(.gameStateChanged, details: details, playerId: playerId)
    }

    // MARK: - Audit Trail Management

    /// Retrieves recent audit events
    /// - Parameter limit: Maximum number of events to return
    /// - Returns: Array of recent audit events
    public func getRecentEvents(limit: Int = 100) -> [AuditEvent] {
        auditLock.lock()
        defer { auditLock.unlock() }

        let count = min(limit, auditTrail.count)
        return Array(auditTrail.suffix(count))
    }

    /// Clears the audit trail
    public func clearAuditTrail() {
        auditLock.lock()
        defer { auditLock.unlock() }

        auditTrail.removeAll()
        logSecurityEvent(.auditTrailCleared, details: ["reason": "manual_clear"])
    }

    // MARK: - Private Methods

    private func formatLogMessage(for event: AuditEvent) -> String {
        var components = [
            "AUDIT",
            event.event.rawValue,
            event.timestamp.ISO8601Format(),
        ]

        if let playerId = event.playerId {
            components.append("Player:\(playerId)")
        }

        if let details = event.details {
            let detailString = details.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
            components.append("Details:{\(detailString)}")
        }

        return components.joined(separator: " | ")
    }
}

// MARK: - Supporting Types

/// Represents an audit event
public struct AuditEvent {
    public let timestamp: Date
    public let event: GameSecurityEvent
    public let details: [String: Any]?
    public let playerId: String?
}

/// Security event types for game operations
public enum GameSecurityEvent: String {
    // Game Data Events
    case gameDataCreated = "GAME_DATA_CREATED"
    case gameDataAccessed = "GAME_DATA_ACCESSED"
    case gameDataModified = "GAME_DATA_MODIFIED"
    case gameDataDeleted = "GAME_DATA_DELETED"

    // Player Analytics Events
    case playerAnalyticsAccessed = "PLAYER_ANALYTICS_ACCESSED"
    case playerAnalyticsModified = "PLAYER_ANALYTICS_MODIFIED"

    // Game State Events
    case gameStateChanged = "GAME_STATE_CHANGED"
    case gameSessionStarted = "GAME_SESSION_STARTED"
    case gameSessionEnded = "GAME_SESSION_ENDED"

    // Security Events
    case encryptionKeyRotated = "ENCRYPTION_KEY_ROTATED"
    case dataDeletionRequested = "DATA_DELETION_REQUESTED"
    case dataDeletionCompleted = "DATA_DELETION_COMPLETED"
    case auditTrailCleared = "AUDIT_TRAIL_CLEARED"

    // Compliance Events
    case gdprDataExport = "GDPR_DATA_EXPORT"
    case privacySettingsChanged = "PRIVACY_SETTINGS_CHANGED"

    /// Whether this event is considered critical
    public var isCritical: Bool {
        switch self {
        case .dataDeletionRequested, .dataDeletionCompleted, .auditTrailCleared:
            return true
        default:
            return false
        }
    }
}

/// Data operation types
public enum DataOperation: String {
    case create = "CREATE"
    case read = "READ"
    case update = "UPDATE"
    case delete = "DELETE"
}
