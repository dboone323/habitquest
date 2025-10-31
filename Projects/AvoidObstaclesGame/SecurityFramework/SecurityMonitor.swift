//
//  SecurityMonitor.swift
//  AvoidObstaclesGame
//
//  Security Framework: Real-time Security Monitoring
//  Monitors game activity for security threats and suspicious behavior
//

import Foundation

// MARK: - Security Monitor

@MainActor
class SecurityMonitor {
    static let shared = SecurityMonitor()

    private var monitoringActive = false
    private var threatPatterns: [ThreatPattern] = []
    private var securityMetrics = SecurityMetrics()

    // Monitoring intervals
    private let monitoringInterval: TimeInterval = 30.0 // 30 seconds
    private let metricsResetInterval: TimeInterval = 3600.0 // 1 hour

    private var monitoringTimer: Timer?
    private var metricsResetTimer: Timer?

    private init() {
        setupThreatPatterns()
        startMonitoring()
    }

    deinit {
        // Note: stopMonitoring() is actor-isolated and cannot be called from deinit
        // The monitoring will be stopped when the app terminates
    }

    // MARK: - Public Methods

    func monitorGameEvent(_ event: GameEvent) {
        guard monitoringActive else { return }

        // Update metrics
        securityMetrics.recordEvent(event)

        // Check for threats
        checkForThreats(event)

        // Log security-relevant events
        if event.isSecurityRelevant {
            AuditLogger.shared.logGameEvent(.securityAlert,
                                            severity: .info,
                                            userId: event.playerId,
                                            metadata: [
                                                "event_type": event.type.rawValue,
                                                "player": event.playerId,
                                                "severity": event.severity.rawValue,
                                            ])
        }
    }

    func monitorDataAccess(_ access: DataAccess) {
        guard monitoringActive else { return }

        // Update access metrics
        securityMetrics.recordDataAccess(access)

        // Check for suspicious access patterns
        checkForSuspiciousAccess(access)

        // Log data access
        AuditLogger.shared.logGameEvent(.dataAccess,
                                        severity: access.success ? .info : .warning,
                                        userId: access.userId,
                                        metadata: [
                                            "data_type": access.dataType.rawValue,
                                            "access_type": access.accessType.rawValue,
                                            "success": access.success,
                                        ])
    }

    func getSecurityStatus() -> SecurityStatus {
        let activeThreats = threatPatterns.filter(\.isActive)
        let recentAlerts = AuditLogger.shared.getAuditEvents(eventType: .securityAlert,
                                                             since: Date().addingTimeInterval(-3600)) // Last hour

        return SecurityStatus(
            monitoringActive: monitoringActive,
            activeThreats: activeThreats.count,
            recentAlerts: recentAlerts.count,
            threatLevel: calculateThreatLevel(),
            lastUpdate: Date()
        )
    }

    func getSecurityMetrics() -> SecurityMetrics {
        securityMetrics
    }

    func forceSecurityScan() {
        // Perform immediate security scan
        let scanResults = performSecurityScan()

        // Log scan results
        AuditLogger.shared.logGameEvent(.complianceCheck,
                                        severity: scanResults.threatLevel == .critical ? .critical : .info,
                                        metadata: [
                                            "threats_found": scanResults.threatsFound,
                                            "anomalies_detected": scanResults.anomaliesDetected,
                                            "scan_duration": scanResults.duration,
                                        ])

        // Handle any critical findings
        if scanResults.threatLevel == .critical {
            AuditLogger.shared.logSecurityAlert("Critical security threat detected",
                                                severity: .critical,
                                                metadata: scanResults.metadata)
        }
    }

    // MARK: - Private Methods

    private func setupThreatPatterns() {
        threatPatterns = [
            ThreatPattern(
                id: "rapid_score_increase",
                name: "Rapid Score Increase",
                description: "Unusually rapid score increases indicating potential cheating",
                severity: .warning,
                detector: { [weak self] event in
                    guard let self, let gameEvent = event as? GameEvent else { return false }

                    // Check for score increases > 1000 in < 5 seconds
                    return gameEvent.scoreIncrease > 1000 && gameEvent.timeInterval < 5.0
                }
            ),

            ThreatPattern(
                id: "frequent_failures",
                name: "Frequent Game Failures",
                description: "Unusually high failure rate indicating frustrated users or attacks",
                severity: .info,
                detector: { [weak self] _ in
                    guard let self else { return false }

                    // Check failure rate over last 10 games
                    let recentFailures = self.securityMetrics.recentFailures
                    return recentFailures > 7 // >70% failure rate
                }
            ),

            ThreatPattern(
                id: "data_tampering",
                name: "Data Tampering Detected",
                description: "Game data has been modified externally",
                severity: .error,
                detector: { [weak self] event in
                    guard let self, let access = event as? DataAccess else { return false }

                    // Check for failed decryption attempts
                    return !access.success && access.dataType == .encrypted
                }
            ),

            ThreatPattern(
                id: "unusual_timing",
                name: "Unusual Game Timing",
                description: "Game events occurring at impossible speeds",
                severity: .warning,
                detector: { [weak self] event in
                    guard let self, let gameEvent = event as? GameEvent else { return false }

                    // Check for events faster than human reaction time
                    return gameEvent.reactionTime < 0.1 // 100ms
                }
            ),
        ]
    }

    func startMonitoring() {
        monitoringActive = true

        // Start monitoring timer
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: monitoringInterval,
                                               repeats: true)
        { [weak self] _ in
            self?.performPeriodicMonitoring()
        }

        // Start metrics reset timer
        metricsResetTimer = Timer.scheduledTimer(withTimeInterval: metricsResetInterval,
                                                 repeats: true)
        { [weak self] _ in
            self?.resetSecurityMetrics()
        }

        AuditLogger.shared.logGameEvent(.securityAlert,
                                        severity: .info,
                                        metadata: ["monitoring_interval": monitoringInterval])
    }

    private func stopMonitoring() {
        monitoringActive = false
        monitoringTimer?.invalidate()
        metricsResetTimer?.invalidate()

        AuditLogger.shared.logGameEvent(.securityAlert,
                                        severity: .info,
                                        metadata: ["operation": "monitoring_stopped"])
    }

    private func performPeriodicMonitoring() {
        // Check system health
        checkSystemHealth()

        // Analyze patterns
        analyzeThreatPatterns()

        // Update threat levels
        updateThreatLevels()

        // Generate periodic report
        if securityMetrics.totalEvents % 100 == 0 { // Every 100 events
            generatePeriodicReport()
        }
    }

    private func checkForThreats(_ event: GameEvent) {
        for pattern in threatPatterns {
            if pattern.detector(event) {
                pattern.isActive = true
                pattern.lastDetected = Date()

                AuditLogger.shared.logSecurityAlert("Threat pattern detected: \(pattern.name)",
                                                    severity: pattern.severity,
                                                    metadata: [
                                                        "pattern_id": pattern.id,
                                                        "event_type": event.type.rawValue,
                                                        "player": event.playerId,
                                                    ])
            }
        }
    }

    private func checkForSuspiciousAccess(_ access: DataAccess) {
        // Check for rapid successive access attempts
        let recentAccesses = securityMetrics.recentDataAccesses.filter {
            $0.dataType == access.dataType && $0.timestamp.timeIntervalSinceNow > -60 // Last minute
        }

        if recentAccesses.count > 10 { // More than 10 accesses per minute
            AuditLogger.shared.logSecurityAlert("Suspicious data access pattern",
                                                severity: .warning,
                                                metadata: [
                                                    "data_type": access.dataType.rawValue,
                                                    "access_count": recentAccesses.count,
                                                    "time_window": "60_seconds",
                                                ])
        }

        // Check for access failures
        if !access.success {
            securityMetrics.failedAccessCount += 1

            if securityMetrics.failedAccessCount > 5 { // Multiple failures
                AuditLogger.shared.logSecurityAlert("Multiple data access failures",
                                                    severity: .error,
                                                    metadata: [
                                                        "failure_count": securityMetrics.failedAccessCount,
                                                        "data_type": access.dataType.rawValue,
                                                    ])
            }
        }
    }

    private func checkSystemHealth() {
        // Check memory usage (simplified)
        let memoryUsage = getMemoryUsage()
        if memoryUsage > 0.8 { // >80% memory usage
            AuditLogger.shared.logSecurityAlert("High memory usage detected",
                                                severity: .info,
                                                metadata: ["memory_usage": memoryUsage])
        }

        // Check for unusual CPU usage patterns
        // This would require additional system monitoring
    }

    private func analyzeThreatPatterns() {
        // Deactivate old threats
        let cutoffTime = Date().addingTimeInterval(-300) // 5 minutes ago

        for pattern in threatPatterns where pattern.isActive {
            if pattern.lastDetected < cutoffTime {
                pattern.isActive = false

                AuditLogger.shared.logGameEvent(.securityAlert,
                                                severity: .info,
                                                metadata: ["pattern_id": pattern.id, "operation": "deactivated"])
            }
        }
    }

    private func updateThreatLevels() {
        let activeThreats = threatPatterns.filter(\.isActive)
        let highSeverityThreats = activeThreats.filter { $0.severity == AuditSeverity.error || $0.severity == AuditSeverity.critical }

        if !highSeverityThreats.isEmpty {
            // Escalate monitoring
            // Could increase monitoring frequency or enable additional checks
        }
    }

    private func performSecurityScan() -> SecurityScanResult {
        let startTime = Date()

        // Scan for active threats
        let activeThreats = threatPatterns.filter(\.isActive)

        // Check for anomalies in metrics
        let anomalies = checkForAnomalies()

        // Calculate threat level
        let threatLevel = calculateThreatLevel()

        let duration = Date().timeIntervalSince(startTime)

        return SecurityScanResult(
            threatsFound: activeThreats.count,
            anomaliesDetected: anomalies.count,
            threatLevel: threatLevel,
            duration: duration,
            metadata: [
                "active_threats": activeThreats.map(\.id),
                "anomalies": anomalies,
            ]
        )
    }

    private func checkForAnomalies() -> [String] {
        var anomalies: [String] = []

        // Check for unusual event frequencies
        if securityMetrics.eventsPerMinute > 100 { // Very high event rate
            anomalies.append("high_event_frequency")
        }

        // Check for data access anomalies
        if securityMetrics.failedAccessCount > securityMetrics.successfulAccessCount {
            anomalies.append("high_failure_rate")
        }

        return anomalies
    }

    private func calculateThreatLevel() -> ThreatLevel {
        let activeThreats = threatPatterns.filter(\.isActive)
        let criticalThreats = activeThreats.filter { $0.severity == AuditSeverity.critical }
        let highThreats = activeThreats.filter { $0.severity == AuditSeverity.error }

        if !criticalThreats.isEmpty {
            return .critical
        } else if highThreats.count > 1 {
            return .high
        } else if activeThreats.count > 2 {
            return .medium
        } else if !activeThreats.isEmpty {
            return .low
        } else {
            return .none
        }
    }

    private func resetSecurityMetrics() {
        securityMetrics = SecurityMetrics()

        AuditLogger.shared.logGameEvent(.complianceCheck,
                                        severity: .info,
                                        metadata: ["operation": "metrics_reset"])
    }

    private func generatePeriodicReport() {
        let status = getSecurityStatus()
        let metrics = getSecurityMetrics()

        AuditLogger.shared.logGameEvent(.complianceCheck,
                                        severity: .info,
                                        metadata: [
                                            "threat_level": status.threatLevel.rawValue,
                                            "active_threats": status.activeThreats,
                                            "total_events": metrics.totalEvents,
                                            "failed_accesses": metrics.failedAccessCount,
                                        ])
    }

    private func getMemoryUsage() -> Double {
        // Simplified memory usage check
        // In production, use proper system monitoring APIs
        0.5 // Placeholder: 50% memory usage
    }
}

// MARK: - Supporting Types

class ThreatPattern {
    let id: String
    let name: String
    let description: String
    let severity: AuditSeverity
    let detector: (Any) -> Bool

    var isActive = false
    var lastDetected = Date()

    init(id: String, name: String, description: String, severity: AuditSeverity, detector: @escaping (Any) -> Bool) {
        self.id = id
        self.name = name
        self.description = description
        self.severity = severity
        self.detector = detector
    }
}

struct GameEvent {
    let type: GameEventType
    let playerId: String
    let timestamp: Date
    let scoreIncrease: Int
    let timeInterval: TimeInterval
    let reactionTime: TimeInterval
    let severity: EventSeverity

    var isSecurityRelevant: Bool {
        severity != .low
    }
}

enum GameEventType: String {
    case scoreUpdate
    case collision
    case levelComplete
    case gameOver
    case achievement
}

enum EventSeverity: String {
    case low
    case medium
    case high
}

struct DataAccess {
    let dataType: DataType
    let accessType: AccessType
    let success: Bool
    let timestamp: Date
    let userId: String?
}

enum DataType: String {
    case gameData
    case userPreferences
    case achievements
    case encrypted
    case logs
}

enum AccessType: String {
    case read
    case write
    case delete
    case encrypt
    case decrypt
}

struct SecurityStatus {
    let monitoringActive: Bool
    let activeThreats: Int
    let recentAlerts: Int
    let threatLevel: ThreatLevel
    let lastUpdate: Date
}

enum ThreatLevel: String {
    case none
    case low
    case medium
    case high
    case critical
}

struct SecurityMetrics {
    var totalEvents = 0
    var eventsPerMinute = 0.0
    var recentFailures = 0
    var failedAccessCount = 0
    var successfulAccessCount = 0
    var recentDataAccesses: [DataAccess] = []

    mutating func recordEvent(_ event: GameEvent) {
        totalEvents += 1

        if event.type == .collision || event.type == .gameOver {
            recentFailures += 1
        }
    }

    mutating func recordDataAccess(_ access: DataAccess) {
        recentDataAccesses.append(access)

        // Keep only recent accesses (last hour)
        let cutoff = Date().addingTimeInterval(-3600)
        recentDataAccesses = recentDataAccesses.filter { $0.timestamp > cutoff }

        if access.success {
            successfulAccessCount += 1
        } else {
            failedAccessCount += 1
        }
    }
}

struct SecurityScanResult {
    let threatsFound: Int
    let anomaliesDetected: Int
    let threatLevel: ThreatLevel
    let duration: TimeInterval
    let metadata: [String: Any]
}
