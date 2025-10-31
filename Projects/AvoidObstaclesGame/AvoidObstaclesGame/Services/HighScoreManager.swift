//
// HighScoreManager.swift
// AvoidObstaclesGame
//
// Manages high scores with persistent storage and security integration
//

import Foundation

/// Manages high scores with persistent storage and security features.
/// Provides methods to add, retrieve, and clear high scores for the AvoidObstaclesGame.
class HighScoreManager: @unchecked Sendable {
    /// Shared singleton instance for global access.
    static let shared = HighScoreManager()

    /// UserDefaults key for storing high scores.
    private let highScoresKey = "AvoidObstaclesHighScores"
    /// Maximum number of high scores to keep.
    private let maxScores = 10

    /// Security services
    private let auditLogger = AuditLogger.shared
    private let securityMonitor = SecurityMonitor.shared

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Retrieves all high scores sorted from highest to lowest with security monitoring.
    /// - Returns: An array of high scores in descending order.
    func getHighScores() -> [Int] {
        let scores = UserDefaults.standard.array(forKey: highScoresKey) as? [Int] ?? []

        // Monitor data access
        securityMonitor.monitorDataAccess(operation: .read, entityType: "highscores", dataCount: scores.count)

        return scores.sorted(by: >)
    }

    /// Retrieves all high scores sorted from highest to lowest (async version).
    /// - Returns: An array of high scores in descending order.
    func getHighScoresAsync() async -> [Int] {
        let scores = UserDefaults.standard.array(forKey: self.highScoresKey) as? [Int] ?? []
        return scores.sorted(by: >)
    }

    /// Adds a new score to the high scores list with security monitoring.
    /// - Parameter score: The score to add.
    /// - Returns: True if the score is in the top 10 after adding, false otherwise.
    func addScore(_ score: Int) -> Bool {
        var scores = getHighScores()
        scores.append(score)
        scores.sort(by: >)

        // Keep only top 10 scores
        if scores.count > maxScores {
            scores = Array(scores.prefix(maxScores))
        }

        // Monitor data modification
        securityMonitor.monitorDataAccess(operation: .update, entityType: "highscores", dataCount: scores.count)

        UserDefaults.standard.set(scores, forKey: highScoresKey)
        UserDefaults.standard.synchronize()

        // Log security event
        auditLogger.logDataAccess(operation: .update, entityType: "highscores", dataCount: scores.count)

        // Return true if this score is in the top 10
        return scores.contains(score)
    }

    /// Adds a new score to the high scores list (async version).
    /// - Parameter score: The score to add.
    /// - Returns: True if the score is in the top 10 after adding, false otherwise.
    func addScoreAsync(_ score: Int) async -> Bool {
        var scores = await self.getHighScoresAsync()
        scores.append(score)
        scores.sort(by: >)

        // Keep only top 10 scores
        if scores.count > self.maxScores {
            scores = Array(scores.prefix(self.maxScores))
        }

        UserDefaults.standard.set(scores, forKey: self.highScoresKey)
        UserDefaults.standard.synchronize()

        // Return true if this score is in the top 10
        return scores.contains(score)
    }

    /// Retrieves the highest score from the high scores list.
    /// - Returns: The highest score, or 0 if no scores exist.
    func getHighestScore() -> Int {
        self.getHighScores().first ?? 0
    }

    /// Retrieves the highest score from the high scores list (async version).
    /// - Returns: The highest score, or 0 if no scores exist.
    func getHighestScoreAsync() async -> Int {
        let scores = await getHighScoresAsync()
        return scores.first ?? 0
    }

    /// Checks if a given score would qualify as a high score without adding it.
    /// - Parameter score: The score to check.
    /// - Returns: True if the score would be in the top 10, false otherwise.
    func isHighScore(_ score: Int) -> Bool {
        let scores = self.getHighScores()
        return scores.count < self.maxScores || score > (scores.last ?? 0)
    }

    /// Checks if a given score would qualify as a high score without adding it (async version).
    /// - Parameter score: The score to check.
    /// - Returns: True if the score would be in the top 10, false otherwise.
    func isHighScoreAsync(_ score: Int) async -> Bool {
        let scores = await getHighScoresAsync()
        return scores.count < self.maxScores || score > (scores.last ?? 0)
    }

    /// Clears all high scores from persistent storage with security logging.
    func clearHighScores() {
        let scores = getHighScores()

        // Monitor data deletion
        securityMonitor.monitorDataAccess(operation: .delete, entityType: "highscores", dataCount: scores.count)

        UserDefaults.standard.removeObject(forKey: highScoresKey)
        UserDefaults.standard.synchronize()

        // Log security event
        auditLogger.logDataAccess(operation: .delete, entityType: "highscores", dataCount: scores.count)
    }

    /// Clears all high scores from persistent storage (async version). Useful for testing or resetting.
    func clearHighScoresAsync() async {
        UserDefaults.standard.removeObject(forKey: self.highScoresKey)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Object Pooling

/// Object pool for performance optimization
@MainActor
private var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
@MainActor
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
@MainActor
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
