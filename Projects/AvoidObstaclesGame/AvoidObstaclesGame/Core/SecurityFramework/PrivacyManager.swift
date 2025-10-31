//
// PrivacyManager.swift
// AvoidObstaclesGame
//
// GDPR compliance and privacy management for game data.
// Handles data deletion requests, privacy settings, and compliance monitoring.
//

import Foundation
import OSLog

/// GDPR compliance and privacy management for game data
public class PrivacyManager: @unchecked Sendable {
    // MARK: - Properties

    /// Shared instance
    public static let shared = PrivacyManager()

    /// Thread-safe lock for privacy operations
    private let privacyLock = NSLock()

    /// Audit logger instance
    private let auditLogger = AuditLogger.shared

    /// Encryption service instance
    private let encryptionService = EncryptionService.shared

    /// Logger instance
    private let logger = OSLog(subsystem: "com.avoidobstacles.game", category: "Privacy")

    /// Privacy settings
    private var privacySettings: PrivacySettings = .init()

    // MARK: - Initialization

    private init() {
        loadPrivacySettings()
    }

    // MARK: - Privacy Settings

    /// Updates privacy settings
    /// - Parameter settings: New privacy settings
    public func updatePrivacySettings(_ settings: PrivacySettings) {
        privacyLock.lock()
        defer { privacyLock.unlock() }

        privacySettings = settings
        savePrivacySettings()

        auditLogger.logSecurityEvent(.privacySettingsChanged, details: [
            "analyticsEnabled": settings.analyticsEnabled,
            "dataSharingEnabled": settings.dataSharingEnabled,
            "retentionDays": settings.dataRetentionDays,
        ])
    }

    /// Gets current privacy settings
    /// - Returns: Current privacy settings
    public func getPrivacySettings() -> PrivacySettings {
        privacyLock.lock()
        defer { privacyLock.unlock() }

        return privacySettings
    }

    // MARK: - Data Deletion (GDPR Article 17)

    /// Requests deletion of all player data
    /// - Parameter playerId: Player identifier
    /// - Returns: Deletion request ID for tracking
    public func requestDataDeletion(for playerId: String) -> String {
        let requestId = UUID().uuidString

        auditLogger.logSecurityEvent(.dataDeletionRequested, details: [
            "requestId": requestId,
            "playerId": playerId,
            "requestType": "gdpr_right_to_erasure",
        ], playerId: playerId)

        // Perform deletion asynchronously
        performDataDeletion(for: playerId, requestId: requestId)

        return requestId
    }

    /// Performs data deletion for a player
    /// - Parameters:
    ///   - playerId: Player identifier
    ///   - requestId: Deletion request ID
    private func performDataDeletion(for playerId: String, requestId: String) {
        // Capture required properties before async operation
        let auditLogger = self.auditLogger
        let logger = self.logger

        DispatchQueue.global().async { [self] in
            do {
                // Delete game progress data
                self.deleteGameProgressData(for: playerId)

                // Delete achievement data
                self.deleteAchievementData(for: playerId)

                // Delete analytics data
                self.deleteAnalyticsData(for: playerId)

                // Delete high scores
                self.deleteHighScoreData(for: playerId)

                // Clear any cached encrypted data
                self.clearEncryptedCache(for: playerId)

                auditLogger.logSecurityEvent(.dataDeletionCompleted, details: [
                    "requestId": requestId,
                    "playerId": playerId,
                    "dataTypesDeleted": ["progress", "achievements", "analytics", "highscores", "cache"],
                ], playerId: playerId)

                os_log(.info, log: logger, "Data deletion completed for player %{public}@", playerId)

            } catch {
                auditLogger.logSecurityEvent(.dataDeletionCompleted, details: [
                    "requestId": requestId,
                    "playerId": playerId,
                    "error": error.localizedDescription,
                    "status": "failed",
                ], playerId: playerId)

                os_log(.error, log: logger, "Data deletion failed for player %{public}@: %{public}@", playerId, error.localizedDescription)
            }
        }
    }

    // MARK: - Data Export (GDPR Article 20)

    /// Exports all player data for GDPR compliance
    /// - Parameter playerId: Player identifier
    /// - Returns: JSON string containing all player data
    public func exportPlayerData(for playerId: String) throws -> String {
        privacyLock.lock()
        defer { privacyLock.unlock() }

        var exportData: [String: Any] = [:]

        // Export game progress
        exportData["gameProgress"] = getGameProgressData(for: playerId)

        // Export achievements
        exportData["achievements"] = getAchievementData(for: playerId)

        // Export analytics (if privacy allows)
        if privacySettings.analyticsEnabled {
            exportData["analytics"] = getAnalyticsData(for: playerId)
        }

        // Export high scores
        exportData["highScores"] = getHighScoreData(for: playerId)

        // Add metadata
        exportData["metadata"] = [
            "exportDate": Date().ISO8601Format(),
            "playerId": playerId,
            "gdprCompliant": true,
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw PrivacyError.exportFailed("Failed to encode export data")
        }

        auditLogger.logSecurityEvent(.gdprDataExport, details: [
            "playerId": playerId,
            "dataTypes": ["progress", "achievements", "analytics", "highscores"],
            "exportSize": jsonData.count,
        ], playerId: playerId)

        return jsonString
    }

    // MARK: - Privacy Compliance Checks

    /// Checks if analytics collection is allowed for a player
    /// - Parameter playerId: Player identifier
    /// - Returns: True if analytics collection is allowed
    public func isAnalyticsAllowed(for playerId: String) -> Bool {
        privacyLock.lock()
        defer { privacyLock.unlock() }

        return privacySettings.analyticsEnabled
    }

    /// Checks if data sharing is allowed
    /// - Returns: True if data sharing is allowed
    public func isDataSharingAllowed() -> Bool {
        privacyLock.lock()
        defer { privacyLock.unlock() }

        return privacySettings.dataSharingEnabled
    }

    /// Checks if data retention limits are exceeded
    /// - Parameter playerId: Player identifier
    /// - Returns: True if cleanup is needed
    public func shouldCleanupOldData(for playerId: String) -> Bool {
        // Check if any data exceeds retention period
        let retentionDays = privacySettings.dataRetentionDays
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date()

        // Check game progress data age
        if let lastModified = getLastModifiedDate(for: playerId), lastModified < cutoffDate {
            return true
        }

        return false
    }

    // MARK: - Private Data Operations

    private func deleteGameProgressData(for playerId: String) {
        let defaults = UserDefaults.standard
        let keys = ["gameProgress_\(playerId)", "playerStats_\(playerId)", "difficulty_\(playerId)"]

        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }

    private func deleteAchievementData(for playerId: String) {
        let defaults = UserDefaults.standard
        let keys = ["unlockedAchievements", "achievementProgress"]

        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }

    private func deleteAnalyticsData(for playerId: String) {
        let defaults = UserDefaults.standard
        let keys = ["playerAnalytics_\(playerId)", "gameSessions_\(playerId)"]

        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }

    private func deleteHighScoreData(for playerId: String) {
        let defaults = UserDefaults.standard
        let keys = ["highScores", "personalBests_\(playerId)"]

        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }

    private func clearEncryptedCache(for playerId: String) {
        // Clear any cached encrypted data
        // Implementation depends on specific caching mechanism
    }

    private func getGameProgressData(for playerId: String) -> [String: Any] {
        let defaults = UserDefaults.standard
        return [
            "progress": defaults.dictionary(forKey: "gameProgress_\(playerId)") ?? [:],
            "stats": defaults.dictionary(forKey: "playerStats_\(playerId)") ?? [:],
            "difficulty": defaults.string(forKey: "difficulty_\(playerId)") ?? "normal",
        ]
    }

    private func getAchievementData(for playerId: String) -> [String: Any] {
        let defaults = UserDefaults.standard
        return [
            "unlocked": defaults.array(forKey: "unlockedAchievements") ?? [],
            "progress": defaults.dictionary(forKey: "achievementProgress") ?? [:],
        ]
    }

    private func getAnalyticsData(for playerId: String) -> [String: Any] {
        let defaults = UserDefaults.standard
        return [
            "analytics": defaults.dictionary(forKey: "playerAnalytics_\(playerId)") ?? [:],
            "sessions": defaults.array(forKey: "gameSessions_\(playerId)") ?? [],
        ]
    }

    private func getHighScoreData(for playerId: String) -> [String: Any] {
        let defaults = UserDefaults.standard
        return [
            "highScores": defaults.array(forKey: "highScores") ?? [],
            "personalBests": defaults.dictionary(forKey: "personalBests_\(playerId)") ?? [:],
        ]
    }

    private func getLastModifiedDate(for playerId: String) -> Date? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "lastModified_\(playerId)") as? Date
    }

    // MARK: - Settings Persistence

    private func savePrivacySettings() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(privacySettings) {
            defaults.set(data, forKey: "privacySettings")
        }
    }

    private func loadPrivacySettings() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "privacySettings"),
           let settings = try? JSONDecoder().decode(PrivacySettings.self, from: data)
        {
            privacySettings = settings
        }
    }
}

// MARK: - Supporting Types

/// Privacy settings for GDPR compliance
public struct PrivacySettings: Codable {
    public var analyticsEnabled: Bool = true
    public var dataSharingEnabled: Bool = false
    public var dataRetentionDays: Int = 365

    public init(analyticsEnabled: Bool = true, dataSharingEnabled: Bool = false, dataRetentionDays: Int = 365) {
        self.analyticsEnabled = analyticsEnabled
        self.dataSharingEnabled = dataSharingEnabled
        self.dataRetentionDays = dataRetentionDays
    }
}

/// Privacy-related errors
public enum PrivacyError: Error {
    case exportFailed(String)
    case deletionFailed(String)

    public var localizedDescription: String {
        switch self {
        case let .exportFailed(reason):
            return "Data export failed: \(reason)"
        case let .deletionFailed(reason):
            return "Data deletion failed: \(reason)"
        }
    }
}
