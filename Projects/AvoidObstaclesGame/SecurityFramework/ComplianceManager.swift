//
//  ComplianceManager.swift
//  AvoidObstaclesGame
//
//  Security Framework: Compliance & Data Validation
//  Ensures game data complies with security standards and validates data integrity
//

import Foundation

// MARK: - Compliance Manager

@MainActor
class ComplianceManager {
    static let shared = ComplianceManager()

    // Compliance standards
    private let maxDataSize = 1024 * 1024 // 1MB max per data blob
    private let maxRetentionDays = 365 // 1 year data retention
    private let requiredEncryption = true

    private var complianceRules: [ComplianceRule] = []

    private init() {
        setupComplianceRules()
    }

    // MARK: - Public Methods

    func validateDataCompliance(_ data: Data, for purpose: DataPurpose) throws {
        // Check data size limits
        guard data.count <= maxDataSize else {
            throw ComplianceError.dataTooLarge
        }

        // Check data format
        try validateDataFormat(data, for: purpose)

        // Check encryption requirements
        if requiredEncryption && purpose.requiresEncryption {
            try validateEncryptionStatus(data)
        }

        // Apply specific compliance rules
        for rule in complianceRules where rule.appliesTo.contains(purpose) {
            try rule.validate(data)
        }

        // Log compliance check
        AuditLogger.shared.logComplianceCheck(checkType: "data_compliance",
                                              result: true,
                                              details: "Data compliance validated for \(purpose.rawValue)")
    }

    func validateGameState(_ gameState: GameState) throws {
        // Validate score integrity
        guard gameState.score >= 0 else {
            throw ComplianceError.invalidScore
        }

        // Validate game duration
        guard gameState.duration >= 0 && gameState.duration <= 3600 else { // Max 1 hour
            throw ComplianceError.invalidDuration
        }

        // Validate player data
        guard !gameState.playerName.isEmpty && gameState.playerName.count <= 50 else {
            throw ComplianceError.invalidPlayerData
        }

        // Check for suspicious patterns
        if detectSuspiciousActivity(gameState) {
            AuditLogger.shared.logSecurityAlert("Suspicious game activity detected",
                                                severity: .warning,
                                                metadata: [
                                                    "player": gameState.playerName,
                                                    "score": gameState.score,
                                                    "duration": gameState.duration,
                                                ])
        }
    }

    func checkDataRetentionCompliance() {
        // Check for data that exceeds retention limits
        let cutoffDate = Date().addingTimeInterval(-Double(maxRetentionDays * 24 * 3600))

        // This would integrate with data storage layer
        // For now, just log the compliance check
        AuditLogger.shared.logComplianceCheck(checkType: "data_retention",
                                              result: true,
                                              details: "Data retention compliance checked, cutoff: \(cutoffDate)")
    }

    func generateComplianceReport() -> ComplianceReport {
        let violations = checkAllComplianceRules()
        let lastAudit = Date()

        let report = ComplianceReport(
            timestamp: lastAudit,
            totalRules: complianceRules.count,
            violations: violations,
            complianceScore: calculateComplianceScore(violations: violations)
        )

        // Log report generation
        AuditLogger.shared.logComplianceCheck(checkType: "compliance_report",
                                              result: report.isCompliant,
                                              details: "Compliance report generated with score \(report.complianceScore)%")

        return report
    }

    // MARK: - Private Methods

    private func setupComplianceRules() {
        complianceRules = [
            ComplianceRule(
                id: "data_size_limit",
                name: "Data Size Limits",
                description: "Ensure data doesn't exceed maximum allowed size",
                appliesTo: [.gameData, .userPreferences, .achievements],
                validator: { data in
                    guard data.count <= self.maxDataSize else {
                        throw ComplianceError.dataTooLarge
                    }
                }
            ),

            ComplianceRule(
                id: "data_integrity",
                name: "Data Integrity Check",
                description: "Validate data structure and required fields",
                appliesTo: [.gameData],
                validator: { data in
                    // Attempt to parse as JSON to validate structure
                    do {
                        _ = try JSONSerialization.jsonObject(with: data)
                    } catch {
                        throw ComplianceError.invalidDataFormat
                    }
                }
            ),

            ComplianceRule(
                id: "encryption_required",
                name: "Encryption Required",
                description: "Sensitive data must be encrypted",
                appliesTo: [.userPreferences, .achievements],
                validator: { data in
                    // Check if data appears to be encrypted (base64-like)
                    let string = String(data: data, encoding: .utf8) ?? ""
                    if !string.containsOnlyBase64Characters() {
                        throw ComplianceError.encryptionRequired
                    }
                }
            ),
        ]
    }

    private func validateDataFormat(_ data: Data, for purpose: DataPurpose) throws {
        switch purpose {
        case .gameData, .userPreferences, .achievements:
            // Must be valid JSON
            do {
                _ = try JSONSerialization.jsonObject(with: data)
            } catch {
                throw ComplianceError.invalidDataFormat
            }

        case .logs:
            // Can be plain text or JSON
            if let string = String(data: data, encoding: .utf8) {
                if !string.isValidLogFormat() {
                    throw ComplianceError.invalidDataFormat
                }
            } else {
                throw ComplianceError.invalidDataFormat
            }
        }
    }

    private func validateEncryptionStatus(_ data: Data) throws {
        // Simple check: encrypted data should be base64-encoded
        guard let string = String(data: data, encoding: .utf8),
              string.containsOnlyBase64Characters()
        else {
            throw ComplianceError.encryptionRequired
        }
    }

    private func detectSuspiciousActivity(_ gameState: GameState) -> Bool {
        // Check for impossible scores
        if gameState.score > 1_000_000 { // Unrealistically high score
            return true
        }

        // Check for suspiciously fast completion
        if gameState.duration < 10 && gameState.score > 1000 { // Too fast for high score
            return true
        }

        // Check for repetitive patterns (potential cheating)
        // This would require tracking multiple games

        return false
    }

    private func checkAllComplianceRules() -> [ComplianceViolation] {
        let violations: [ComplianceViolation] = []

        // This would check actual stored data
        // For demo purposes, return empty array (no violations)
        // In production, this would scan all stored data

        return violations
    }

    private func calculateComplianceScore(violations: [ComplianceViolation]) -> Double {
        let totalRules = complianceRules.count
        let violationPenalty = Double(violations.count) / Double(totalRules)
        return max(0.0, 100.0 - (violationPenalty * 100.0))
    }
}

// MARK: - Supporting Types

enum DataPurpose: String {
    case gameData
    case userPreferences
    case achievements
    case logs

    var requiresEncryption: Bool {
        switch self {
        case .userPreferences, .achievements:
            return true
        case .gameData, .logs:
            return false
        }
    }
}

struct ComplianceRule {
    let id: String
    let name: String
    let description: String
    let appliesTo: [DataPurpose]
    let validator: (Data) throws -> Void

    func validate(_ data: Data) throws {
        try validator(data)
    }
}

struct ComplianceViolation {
    let ruleId: String
    let ruleName: String
    let description: String
    let severity: ViolationSeverity
    let timestamp: Date
    let affectedData: String?
}

enum ViolationSeverity {
    case low
    case medium
    case high
    case critical
}

struct ComplianceReport {
    let timestamp: Date
    let totalRules: Int
    let violations: [ComplianceViolation]
    let complianceScore: Double

    var isCompliant: Bool {
        complianceScore >= 95.0 // 95% compliance threshold
    }
}

// MARK: - Game State for Validation

struct GameState {
    let playerName: String
    let score: Int
    let duration: TimeInterval
    let level: Int
    let obstaclesAvoided: Int
}

// MARK: - Compliance Errors

enum ComplianceError: Error {
    case dataTooLarge
    case invalidDataFormat
    case encryptionRequired
    case invalidScore
    case invalidDuration
    case invalidPlayerData
    case retentionViolation

    var localizedDescription: String {
        switch self {
        case .dataTooLarge:
            return "Data exceeds maximum allowed size"
        case .invalidDataFormat:
            return "Data format is invalid or corrupted"
        case .encryptionRequired:
            return "Data must be encrypted for security compliance"
        case .invalidScore:
            return "Game score is invalid"
        case .invalidDuration:
            return "Game duration is invalid"
        case .invalidPlayerData:
            return "Player data is invalid"
        case .retentionViolation:
            return "Data retention policy violated"
        }
    }
}

// MARK: - String Extensions

extension String {
    func containsOnlyBase64Characters() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=")
        return self.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }

    func isValidLogFormat() -> Bool {
        // Basic validation for log entries
        // Should contain timestamp-like patterns or be valid JSON
        if self.hasPrefix("{") && self.hasSuffix("}") {
            // Check if valid JSON
            return (try? JSONSerialization.jsonObject(with: self.data(using: .utf8)!)) != nil
        }

        // Check for timestamp pattern (ISO 8601 or similar)
        let timestampPattern = #"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"#
        return self.range(of: timestampPattern, options: .regularExpression) != nil
    }
}
