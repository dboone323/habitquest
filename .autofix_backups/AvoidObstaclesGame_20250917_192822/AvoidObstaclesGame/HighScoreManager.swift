//
// HighScoreManager.swift
// AvoidObstaclesGame
//
// Manages high scores with persistent storage using UserDefaults
//

import Foundation

/// Manages high scores with persistent storage using UserDefaults.
/// Provides methods to add, retrieve, and clear high scores for the AvoidObstaclesGame.
class HighScoreManager {
    /// Shared singleton instance for global access.
    static let shared = HighScoreManager()

    /// UserDefaults key for storing high scores.
    private let highScoresKey = "AvoidObstaclesHighScores"
    /// Maximum number of high scores to keep.
    private let maxScores = 10

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Retrieves all high scores sorted from highest to lowest.
    /// - Returns: An array of high scores in descending order.
    func getHighScores() -> [Int] {
        let scores = UserDefaults.standard.array(forKey: self.highScoresKey) as? [Int] ?? []
        return scores.sorted(by: >)
    }

    /// Adds a new score to the high scores list.
    /// - Parameter score: The score to add.
    /// - Returns: True if the score is in the top 10 after adding, false otherwise.
    func addScore(_ score: Int) -> Bool {
        var scores = self.getHighScores()
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

    /// Checks if a given score would qualify as a high score without adding it.
    /// - Parameter score: The score to check.
    /// - Returns: True if the score would be in the top 10, false otherwise.
    func isHighScore(_ score: Int) -> Bool {
        let scores = self.getHighScores()
        return scores.count < self.maxScores || score > (scores.last ?? 0)
    }

    /// Clears all high scores from persistent storage. Useful for testing or resetting.
    func clearHighScores() {
        UserDefaults.standard.removeObject(forKey: self.highScoresKey)
        UserDefaults.standard.synchronize()
    }
}
