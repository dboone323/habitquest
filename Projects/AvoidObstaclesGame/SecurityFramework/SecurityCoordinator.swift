//
//  SecurityCoordinator.swift
//  AvoidObstaclesGame
//
//  Security Framework: Central Coordinator
//  Coordinates all security components and provides unified security interface
//

import Foundation

// MARK: - Security Coordinator

@MainActor
class SecurityCoordinator {
    static let shared = SecurityCoordinator()

    // Security components
    let auditLogger = AuditLogger.shared
    let encryptionService = EncryptionService.shared
    let complianceManager = ComplianceManager.shared
    let securityMonitor = SecurityMonitor.shared

    private var securityInitialized = false
    private var lastHealthCheck = Date()

    private init() {
        initializeSecurity()
    }

    // MARK: - Initialization

    private func initializeSecurity() {
        do {
            // Validate encryption service
            guard encryptionService.validateEncryption() else {
                throw SecurityError.encryptionValidationFailed
            }

            // Start security monitoring
            securityMonitor.startMonitoring()

            // Perform initial compliance check
            complianceManager.checkDataRetentionCompliance()

            securityInitialized = true

            // Log successful initialization
            auditLogger.logGameEvent(.securityAlert,
                                     severity: .info,
                                     metadata: ["components": ["audit", "encryption", "compliance", "monitor"]])

        } catch {
            // Log initialization failure
            auditLogger.logSecurityAlert("Security framework initialization failed",
                                         severity: .critical,
                                         metadata: ["error": error.localizedDescription])

            // Attempt graceful degradation
            securityInitialized = false
        }
    }

    // MARK: - Public Interface

    func secureGameData(_ gameData: GameData) throws -> SecureGameData {
        guard securityInitialized else {
            throw SecurityError.securityNotInitialized
        }

        // Validate game data compliance
        try complianceManager.validateGameState(gameData.state)

        // Encrypt sensitive data
        let encryptedData = try encryptionService.encryptGameData(gameData.toDictionary())

        // Monitor the encryption operation
        securityMonitor.monitorDataAccess(DataAccess(
            dataType: .encrypted,
            accessType: .encrypt,
            success: true,
            timestamp: Date(),
            userId: gameData.state.playerName
        ))

        // Create secure container
        let secureData = SecureGameData(
            highScore: gameData.state.score,
            totalGamesPlayed: gameData.totalGamesPlayed,
            achievements: gameData.achievements,
            preferences: gameData.preferences
        )

        // Log secure data operation
        auditLogger.logGameEvent(.dataModification,
                                 severity: .info,
                                 userId: gameData.state.playerName,
                                 metadata: [
                                     "player": gameData.state.playerName,
                                     "data_size": encryptedData.count,
                                     "operation": "encrypt",
                                 ])

        return secureData
    }

    func retrieveSecureGameData(encryptedData: String, for player: String) throws -> GameData {
        guard securityInitialized else {
            throw SecurityError.securityNotInitialized
        }

        do {
            // Decrypt data
            let decryptedDict = try encryptionService.decryptGameData(encryptedData)

            // Monitor decryption operation
            securityMonitor.monitorDataAccess(DataAccess(
                dataType: .encrypted,
                accessType: .decrypt,
                success: true,
                timestamp: Date(),
                userId: player
            ))

            // Reconstruct game data
            let gameData = try GameData.fromDictionary(decryptedDict)

            // Validate retrieved data
            try complianceManager.validateGameState(gameData.state)

            // Log successful retrieval
            auditLogger.logGameEvent(.dataAccess,
                                     severity: .info,
                                     userId: player,
                                     metadata: [
                                         "player": player,
                                         "operation": "decrypt",
                                         "data_integrity": "valid",
                                     ])

            return gameData

        } catch {
            // Monitor failed decryption
            securityMonitor.monitorDataAccess(DataAccess(
                dataType: .encrypted,
                accessType: .decrypt,
                success: false,
                timestamp: Date(),
                userId: player
            ))

            // Log decryption failure
            auditLogger.logSecurityAlert("Secure data retrieval failed",
                                         severity: .warning,
                                         metadata: [
                                             "player": player,
                                             "error": error.localizedDescription,
                                         ])

            throw error
        }
    }

    func logGameEvent(_ event: GameEvent) {
        guard securityInitialized else { return }

        // Monitor the game event
        securityMonitor.monitorGameEvent(event)

        // Audit log the event if security-relevant
        if event.isSecurityRelevant {
            auditLogger.logGameEvent(.securityAlert,
                                     severity: .info,
                                     userId: event.playerId,
                                     metadata: [
                                         "event_type": event.type.rawValue,
                                         "player": event.playerId,
                                         "severity": "\(event.severity)",
                                     ])
        }
    }

    func performSecurityHealthCheck() -> SecurityHealthStatus {
        let currentTime = Date()
        let timeSinceLastCheck = currentTime.timeIntervalSince(lastHealthCheck)

        // Perform comprehensive health check
        let auditStatus = checkAuditLoggerHealth()
        let encryptionStatus = checkEncryptionHealth()
        let complianceStatus = checkComplianceHealth()
        let monitorStatus = checkMonitorHealth()

        let overallHealth = determineOverallHealth([
            auditStatus,
            encryptionStatus,
            complianceStatus,
            monitorStatus,
        ])

        let healthStatus = SecurityHealthStatus(
            timestamp: currentTime,
            overallHealth: overallHealth,
            componentStatus: [
                "audit_logger": auditStatus,
                "encryption_service": encryptionStatus,
                "compliance_manager": complianceStatus,
                "security_monitor": monitorStatus,
            ],
            lastCheckInterval: timeSinceLastCheck,
            recommendations: generateHealthRecommendations(overallHealth, componentStatus: [
                "audit": auditStatus,
                "encryption": encryptionStatus,
                "compliance": complianceStatus,
                "monitor": monitorStatus,
            ])
        )

        lastHealthCheck = currentTime

        // Log health check results
        auditLogger.logGameEvent(.complianceCheck,
                                 severity: .info,
                                 metadata: [
                                     "overall_health": overallHealth.rawValue,
                                     "components_checked": 4,
                                     "recommendations_count": healthStatus.recommendations.count,
                                 ])

        return healthStatus
    }

    func getSecurityReport() -> SecurityReport {
        guard securityInitialized else {
            return SecurityReport(
                timestamp: Date(),
                status: .notInitialized,
                components: [:],
                alerts: [],
                recommendations: ["Initialize security framework"]
            )
        }

        let healthStatus = performSecurityHealthCheck()
        let complianceReport = complianceManager.generateComplianceReport()
        let securityStatus = securityMonitor.getSecurityStatus()
        let recentAlerts = auditLogger.getAuditEvents(eventType: .securityAlert,
                                                      since: Date().addingTimeInterval(-24 * 3600))

        let report = SecurityReport(
            timestamp: Date(),
            status: healthStatus.overallHealth == .healthy ? .operational : .degraded,
            components: [
                "audit_logger": ComponentStatus(status: healthStatus.componentStatus["audit_logger"] ?? .unknown, lastCheck: Date()),
                "encryption_service": ComponentStatus(status: healthStatus.componentStatus["encryption_service"] ?? .unknown, lastCheck: Date()),
                "compliance_manager": ComponentStatus(status: healthStatus.componentStatus["compliance_manager"] ?? .unknown, lastCheck: Date()),
                "security_monitor": ComponentStatus(status: healthStatus.componentStatus["security_monitor"] ?? .unknown, lastCheck: Date()),
            ],
            alerts: recentAlerts,
            recommendations: healthStatus.recommendations
        )

        return report
    }

    func handleSecurityIncident(_ incident: SecurityIncident) {
        // Log the incident
        auditLogger.logSecurityAlert("Security incident reported",
                                     severity: incident.severity,
                                     metadata: [
                                         "incident_type": incident.type.rawValue,
                                         "description": incident.description,
                                         "affected_user": incident.affectedUser ?? "unknown",
                                     ])

        // Take appropriate action based on incident type
        switch incident.type {
        case .dataTampering:
            // Rotate encryption keys
            encryptionService.rotateEncryptionKey()

        case .unauthorizedAccess:
            // Increase monitoring
            securityMonitor.forceSecurityScan()

        case .suspiciousActivity:
            // Generate compliance report
            _ = complianceManager.generateComplianceReport()

        case .systemCompromise:
            // Critical incident - log and alert
            auditLogger.logSecurityAlert("Critical security incident: System compromise detected",
                                         severity: .critical,
                                         metadata: incident.metadata)
        }

        // Monitor the incident response
        securityMonitor.monitorGameEvent(GameEvent(
            type: .gameOver, // Using gameOver as generic security event
            playerId: incident.affectedUser ?? "system",
            timestamp: Date(),
            scoreIncrease: 0,
            timeInterval: 0,
            reactionTime: 0,
            severity: .high
        ))
    }

    // MARK: - Health Check Methods

    private func checkAuditLoggerHealth() -> ComponentHealth {
        // Check if audit logger can write events
        do {
            try auditLogger.logGameEvent(.complianceCheck,
                                         severity: .info,
                                         metadata: ["test": true])
            return .healthy
        } catch {
            return .degraded
        }
    }

    private func checkEncryptionHealth() -> ComponentHealth {
        encryptionService.validateEncryption() ? .healthy : .failed
    }

    private func checkComplianceHealth() -> ComponentHealth {
        let report = complianceManager.generateComplianceReport()
        return report.isCompliant ? .healthy : .degraded
    }

    private func checkMonitorHealth() -> ComponentHealth {
        let status = securityMonitor.getSecurityStatus()
        return status.monitoringActive ? .healthy : .failed
    }

    private func determineOverallHealth(_ componentHealth: [ComponentHealth]) -> ComponentHealth {
        if componentHealth.contains(.failed) {
            return .failed
        } else if componentHealth.contains(.degraded) {
            return .degraded
        } else if componentHealth.allSatisfy({ $0 == .healthy }) {
            return .healthy
        } else {
            return .unknown
        }
    }

    private func generateHealthRecommendations(_ overallHealth: ComponentHealth, componentStatus: [String: ComponentHealth]) -> [String] {
        var recommendations: [String] = []

        if overallHealth == .failed {
            recommendations.append("Critical: Security framework has failed components - immediate attention required")
        }

        for (component, status) in componentStatus {
            switch status {
            case .failed:
                recommendations.append("Fix \(component) - component is not functioning")
            case .degraded:
                recommendations.append("Review \(component) - component performance is degraded")
            case .unknown:
                recommendations.append("Investigate \(component) - health status unknown")
            case .healthy:
                break // No recommendation needed
            }
        }

        if recommendations.isEmpty {
            recommendations.append("All security components are healthy")
        }

        return recommendations
    }
}

// MARK: - Supporting Types

struct GameData {
    let state: GameState
    let totalGamesPlayed: Int
    let achievements: [String]
    let preferences: [String: Any]
    let lastPlayed: Date

    func toDictionary() -> [String: Any] {
        [
            "player_name": state.playerName,
            "score": state.score,
            "duration": state.duration,
            "level": state.level,
            "obstacles_avoided": state.obstaclesAvoided,
            "total_games_played": totalGamesPlayed,
            "achievements": achievements,
            "preferences": preferences,
            "last_played": lastPlayed.timeIntervalSince1970,
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) throws -> GameData {
        guard let playerName = dict["player_name"] as? String,
              let score = dict["score"] as? Int,
              let duration = dict["duration"] as? TimeInterval,
              let level = dict["level"] as? Int,
              let obstaclesAvoided = dict["obstacles_avoided"] as? Int,
              let totalGamesPlayed = dict["total_games_played"] as? Int,
              let achievements = dict["achievements"] as? [String],
              let preferences = dict["preferences"] as? [String: Any],
              let lastPlayedTimestamp = dict["last_played"] as? TimeInterval
        else {
            throw SecurityError.invalidDataFormat
        }

        let state = GameState(
            playerName: playerName,
            score: score,
            duration: duration,
            level: level,
            obstaclesAvoided: obstaclesAvoided
        )

        let lastPlayed = Date(timeIntervalSince1970: lastPlayedTimestamp)

        return GameData(
            state: state,
            totalGamesPlayed: totalGamesPlayed,
            achievements: achievements,
            preferences: preferences,
            lastPlayed: lastPlayed
        )
    }
}

struct SecurityHealthStatus {
    let timestamp: Date
    let overallHealth: ComponentHealth
    let componentStatus: [String: ComponentHealth]
    let lastCheckInterval: TimeInterval
    let recommendations: [String]
}

enum ComponentHealth: String {
    case healthy
    case degraded
    case failed
    case unknown
}

struct SecurityReport {
    let timestamp: Date
    let status: SystemStatus
    let components: [String: ComponentStatus]
    let alerts: [AuditEvent]
    let recommendations: [String]
}

enum SystemStatus {
    case operational
    case degraded
    case notInitialized
}

struct ComponentStatus {
    let status: ComponentHealth
    let lastCheck: Date
}

struct SecurityIncident {
    let type: IncidentType
    let severity: AuditSeverity
    let description: String
    let affectedUser: String?
    let timestamp: Date
    let metadata: [String: Any]
}

enum IncidentType: String {
    case dataTampering
    case unauthorizedAccess
    case suspiciousActivity
    case systemCompromise
}

// MARK: - Security Errors

enum SecurityError: Error {
    case securityNotInitialized
    case encryptionValidationFailed
    case invalidDataFormat
    case dataIntegrityViolation

    var localizedDescription: String {
        switch self {
        case .securityNotInitialized:
            return "Security framework has not been initialized"
        case .encryptionValidationFailed:
            return "Encryption service validation failed"
        case .invalidDataFormat:
            return "Data format is invalid"
        case .dataIntegrityViolation:
            return "Data integrity check failed"
        }
    }
}
