//
//  AuditLogger.swift
//  AvoidObstaclesGame
//
//  Security Framework: Audit Logging
//  Logs security events, game data access, and compliance activities
//

import Foundation
import OSLog

// MARK: - Audit Event Types

enum AuditEventType: String, Codable {
    case gameStart = "game_start"
    case gameEnd = "game_end"
    case scoreUpdate = "score_update"
    case levelProgress = "level_progress"
    case dataAccess = "data_access"
    case dataModification = "data_modification"
    case securityAlert = "security_alert"
    case complianceCheck = "compliance_check"
    case authentication
    case authorization
}

// MARK: - Audit Severity Levels

enum AuditSeverity: String, Codable {
    case info
    case warning
    case error
    case critical
}

// MARK: - Audit Event Structure

struct AuditEvent: Codable {
    let id: String
    let timestamp: Date
    let eventType: AuditEventType
    let severity: AuditSeverity
    let userId: String?
    let sessionId: String
    let gameData: [String: AnyCodable]?
    let metadata: [String: AnyCodable]?
    let ipAddress: String?
    let userAgent: String?

    init(eventType: AuditEventType,
         severity: AuditSeverity = .info,
         userId: String? = nil,
         sessionId: String = UUID().uuidString,
         gameData: [String: Any]? = nil,
         metadata: [String: Any]? = nil)
    {

        self.id = UUID().uuidString
        self.timestamp = Date()
        self.eventType = eventType
        self.severity = severity
        self.userId = userId
        self.sessionId = sessionId
        self.gameData = gameData?.mapValues { AnyCodable($0) }
        self.metadata = metadata?.mapValues { AnyCodable($0) }
        self.ipAddress = nil // Web environment - would be populated by server
        self.userAgent = nil // Web environment - would be populated by browser
    }
}

// MARK: - AnyCodable Wrapper

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [AnyCodable]:
            try container.encode(arrayValue)
        case let dictValue as [String: AnyCodable]:
            try container.encode(dictValue)
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - Audit Logger

@MainActor
class AuditLogger {
    static let shared = AuditLogger()

    private let logger: Logger
    private let auditLogFile: URL
    private var auditEvents: [AuditEvent] = []
    private let maxStoredEvents = 1000

    private init() {
        self.logger = Logger(subsystem: "com.quantumworkspace.avoidobstacles", category: "security.audit")

        // Create audit log directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let auditDirectory = documentsDirectory.appendingPathComponent("AvoidObstaclesGame/AuditLogs")

        try? FileManager.default.createDirectory(at: auditDirectory, withIntermediateDirectories: true)

        // Create daily log file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        self.auditLogFile = auditDirectory.appendingPathComponent("audit_\(dateString).log")

        loadExistingAuditEvents()
    }

    // MARK: - Public Methods

    func logGameEvent(_ eventType: AuditEventType,
                      severity: AuditSeverity = .info,
                      userId: String? = nil,
                      gameData: [String: Any]? = nil,
                      metadata: [String: Any]? = nil)
    {

        let event = AuditEvent(eventType: eventType,
                               severity: severity,
                               userId: userId,
                               gameData: gameData,
                               metadata: metadata)

        auditEvents.append(event)

        // Keep only recent events in memory
        if auditEvents.count > maxStoredEvents {
            auditEvents.removeFirst(auditEvents.count - maxStoredEvents)
        }

        // Log to system logger
        logToSystemLogger(event)

        // Persist to file
        persistAuditEvent(event)

        // Check for security alerts
        checkForSecurityAlerts(event)
    }

    func logSecurityAlert(_ message: String,
                          severity: AuditSeverity = .warning,
                          metadata: [String: Any]? = nil)
    {

        var alertMetadata = metadata ?? [:]
        alertMetadata["alert_message"] = message
        alertMetadata["alert_type"] = "security_alert"

        logGameEvent(.securityAlert,
                     severity: severity,
                     metadata: alertMetadata)
    }

    func logDataAccess(resource: String,
                       operation: String,
                       userId: String? = nil,
                       success: Bool = true)
    {

        let metadata: [String: Any] = [
            "resource": resource,
            "operation": operation,
            "success": success,
            "access_time": Date().timeIntervalSince1970,
        ]

        logGameEvent(.dataAccess,
                     severity: success ? .info : .warning,
                     userId: userId,
                     metadata: metadata)
    }

    func logComplianceCheck(checkType: String,
                            result: Bool,
                            details: String? = nil)
    {

        let metadata: [String: Any] = [
            "check_type": checkType,
            "result": result,
            "details": details ?? "",
            "compliance_standard": "GDPR",
        ]

        logGameEvent(.complianceCheck,
                     severity: result ? .info : .error,
                     metadata: metadata)
    }

    func getAuditEvents(for userId: String? = nil,
                        eventType: AuditEventType? = nil,
                        since date: Date? = nil,
                        limit: Int = 100) -> [AuditEvent]
    {

        var filteredEvents = auditEvents

        if let userId {
            filteredEvents = filteredEvents.filter { $0.userId == userId }
        }

        if let eventType {
            filteredEvents = filteredEvents.filter { $0.eventType == eventType }
        }

        if let date {
            filteredEvents = filteredEvents.filter { $0.timestamp >= date }
        }

        return Array(filteredEvents.suffix(limit))
    }

    func exportAuditLog(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(auditEvents)
        try data.write(to: url)
    }

    // MARK: - Private Methods

    private func logToSystemLogger(_ event: AuditEvent) {
        let message = """
        [AUDIT] \(event.eventType.rawValue.uppercased()) - \
        \(event.severity.rawValue.uppercased()) - \
        Session: \(event.sessionId)
        """

        switch event.severity {
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        case .critical:
            logger.critical("\(message)")
        }
    }

    private func persistAuditEvent(_ event: AuditEvent) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            let eventData = try encoder.encode(event)
            let eventString = String(data: eventData, encoding: .utf8)!

            // Append to log file
            if let fileHandle = try? FileHandle(forWritingTo: auditLogFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write("\(eventString)\n".data(using: .utf8)!)
                fileHandle.closeFile()
            } else {
                // Create new file
                try eventString.write(to: auditLogFile, atomically: true, encoding: .utf8)
            }
        } catch {
            logger.error("Failed to persist audit event: \(error.localizedDescription)")
        }
    }

    private func loadExistingAuditEvents() {
        do {
            let logData = try Data(contentsOf: auditLogFile)
            let logContent = String(data: logData, encoding: .utf8) ?? ""

            let lines = logContent.components(separatedBy: .newlines).filter { !$0.isEmpty }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            auditEvents = lines.compactMap { line in
                try? decoder.decode(AuditEvent.self, from: line.data(using: .utf8)!)
            }

            // Keep only recent events
            if auditEvents.count > maxStoredEvents {
                auditEvents = Array(auditEvents.suffix(maxStoredEvents))
            }

            logger.info("Loaded \(self.auditEvents.count) existing audit events")
        } catch {
            logger.info("No existing audit log found, starting fresh")
        }
    }

    private func checkForSecurityAlerts(_ event: AuditEvent) {
        // Check for suspicious patterns
        switch event.eventType {
        case .dataAccess:
            if let success = event.metadata?["success"]?.value as? Bool, !success {
                logSecurityAlert("Failed data access attempt detected",
                                 severity: .warning,
                                 metadata: ["event_id": event.id])
            }

        case .gameEnd:
            if let score = event.gameData?["final_score"]?.value as? Int, score < 0 {
                logSecurityAlert("Invalid negative score detected",
                                 severity: .error,
                                 metadata: ["event_id": event.id, "score": score])
            }

        default:
            break
        }

        // Check for rapid successive events (potential abuse)
        let recentEvents = auditEvents.filter {
            $0.timestamp > Date().addingTimeInterval(-300) // Last 5 minutes
        }

        if recentEvents.count > 50 { // More than 50 events in 5 minutes
            logSecurityAlert("High frequency activity detected",
                             severity: .warning,
                             metadata: ["event_count": recentEvents.count])
        }
    }
}
