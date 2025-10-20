//
// SocialManager.swift
// AvoidObstaclesGame
//
// Social features implementation including leaderboards, sharing, and challenges
// Provides comprehensive social gaming experience with global leaderboards,
// achievement sharing, and community challenges.
//

import Foundation
import SpriteKit

/// Social features manager for leaderboards, sharing, and challenges
@MainActor
final class SocialManager {
    // MARK: - Properties

    private weak var scene: SKScene?
    private var gameStateContainer: GameStateManager?
    private var leaderboardData: [LeaderboardEntry] = []
    private var activeChallenges: [Challenge] = []
    private var playerStats: PlayerSocialStats

    // MARK: - Initialization

    init(scene: SKScene, gameStateContainer: GameStateManager) {
        self.scene = scene
        self.gameStateContainer = gameStateContainer
        self.playerStats = PlayerSocialStats()

        setupSocialFeatures()
        loadLeaderboardData()
        loadActiveChallenges()
    }

    // MARK: - Public Methods

    /// Submit score to leaderboard
    func submitScore(_ score: Int, playerName: String = "Player") {
        let entry = LeaderboardEntry(
            playerName: playerName,
            score: score,
            timestamp: Date(),
            rank: 0 // Will be calculated when sorting
        )

        leaderboardData.append(entry)
        updateLeaderboardRanks()
        saveLeaderboardData()

        // Check for new personal best
        if score > playerStats.personalBest {
            playerStats.personalBest = score
            showNewPersonalBestNotification(score)
        }

        // Check for leaderboard achievements
        checkLeaderboardAchievements()
    }

    /// Get top scores for display
    func getTopScores(limit: Int = 10) -> [LeaderboardEntry] {
        Array(leaderboardData.sorted { $0.score > $1.score }.prefix(limit))
    }

    /// Get player's current rank
    func getPlayerRank(for score: Int) -> Int? {
        let sortedScores = leaderboardData.sorted { $0.score > $1.score }
        return sortedScores.firstIndex { $0.score <= score }?.advanced(by: 1)
    }

    /// Share achievement or score
    func shareAchievement(_ achievement: String, score: Int? = nil) {
        let shareText = createShareText(for: achievement, score: score)
        showShareDialog(text: shareText)
    }

    /// Create and start a challenge
    func createChallenge(type: ChallengeType, targetScore: Int, duration: TimeInterval) -> Challenge {
        let challenge = Challenge(
            id: UUID().uuidString,
            type: type,
            targetScore: targetScore,
            duration: duration,
            startDate: Date(),
            participants: [playerStats.playerName],
            isActive: true
        )

        activeChallenges.append(challenge)
        saveActiveChallenges()

        return challenge
    }

    /// Join an existing challenge
    func joinChallenge(_ challenge: Challenge) {
        if !challenge.participants.contains(playerStats.playerName) {
            var updatedChallenge = challenge
            updatedChallenge.participants.append(playerStats.playerName)
            // Update in activeChallenges array
            if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
                activeChallenges[index] = updatedChallenge
                saveActiveChallenges()
            }
        }
    }

    /// Submit score for active challenges
    func submitChallengeScore(_ score: Int) {
        for (index, challenge) in activeChallenges.enumerated() {
            if challenge.isActive && challenge.participants.contains(playerStats.playerName) {
                var updatedChallenge = challenge
                updatedChallenge.scores[playerStats.playerName] = score

                // Check if challenge is completed
                if Date().timeIntervalSince(challenge.startDate) >= challenge.duration {
                    updatedChallenge.isActive = false
                    showChallengeResults(updatedChallenge)
                }

                activeChallenges[index] = updatedChallenge
            }
        }
        saveActiveChallenges()
    }

    /// Get social stats for display
    func getSocialStats() -> PlayerSocialStats {
        playerStats
    }

    /// Update social stats
    func updateSocialStats(gamesPlayed: Int, totalScore: Int) {
        playerStats.gamesPlayed = gamesPlayed
        playerStats.totalScore = totalScore
        playerStats.averageScore = gamesPlayed > 0 ? Double(totalScore) / Double(gamesPlayed) : 0
        savePlayerStats()
    }

    // MARK: - Private Methods

    private func setupSocialFeatures() {
        // Initialize social features
        loadPlayerStats()
    }

    private func updateLeaderboardRanks() {
        let sortedEntries = leaderboardData.sorted { $0.score > $1.score }
        for (index, _) in sortedEntries.enumerated() {
            leaderboardData[index].rank = index + 1
        }
    }

    private func showNewPersonalBestNotification(_ score: Int) {
        guard let scene else { return }

        let notification = SKLabelNode(fontNamed: "SF-Pro-Display-Bold")
        notification.text = "🏆 New Personal Best: \(score)!"
        notification.fontSize = 24
        notification.fontColor = .systemYellow
        notification.position = CGPoint(x: 0, y: scene.size.height / 2 - 100)
        notification.zPosition = 200

        scene.addChild(notification)

        // Animate and remove
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        notification.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }

    private func checkLeaderboardAchievements() {
        _ = getTopScores(limit: 100)
        let playerRank = getPlayerRank(for: playerStats.personalBest) ?? 999

        // Check for rank-based achievements
        if playerRank == 1 && !playerStats.achievements.contains("Top Player") {
            playerStats.achievements.append("Top Player")
            showAchievementNotification("Top Player")
        } else if playerRank <= 10 && !playerStats.achievements.contains("Top 10") {
            playerStats.achievements.append("Top 10")
            showAchievementNotification("Top 10")
        } else if playerRank <= 50 && !playerStats.achievements.contains("Top 50") {
            playerStats.achievements.append("Top 50")
            showAchievementNotification("Top 50")
        }
    }

    private func showAchievementNotification(_ achievement: String) {
        guard let scene else { return }

        let notification = SKLabelNode(fontNamed: "SF-Pro-Display-Bold")
        notification.text = "🎉 Achievement Unlocked: \(achievement)!"
        notification.fontSize = 20
        notification.fontColor = .systemGreen
        notification.position = CGPoint(x: 0, y: scene.size.height / 2 - 150)
        notification.zPosition = 200

        scene.addChild(notification)

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 3.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        notification.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }

    private func createShareText(for achievement: String, score: Int?) -> String {
        var text = "🎮 Just achieved '\(achievement)' in Avoid Obstacles!"

        if let score {
            text += " Scored \(score) points!"
        }

        text += " Can you beat my score? #AvoidObstacles #Gaming"

        return text
    }

    private func showShareDialog(text: String) {
        // In a real implementation, this would open the system's share dialog
        // For now, we'll just show a notification
        guard let scene else { return }

        let shareNotification = SKLabelNode(fontNamed: "SF-Pro-Display-Regular")
        shareNotification.text = "Shared: \(text.prefix(50))..."
        shareNotification.fontSize = 16
        shareNotification.fontColor = .systemBlue
        shareNotification.position = CGPoint(x: 0, y: scene.size.height / 2 - 200)
        shareNotification.zPosition = 200

        scene.addChild(shareNotification)

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        shareNotification.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }

    private func showChallengeResults(_ challenge: Challenge) {
        guard let scene else { return }

        let results = challenge.getResults()
        var resultText = "Challenge Complete!\n"

        for (player, score) in results.sorted(by: { $0.value > $1.value }) {
            resultText += "\(player): \(score)\n"
        }

        let resultsLabel = SKLabelNode(fontNamed: "SF-Pro-Display-Bold")
        resultsLabel.text = resultText
        resultsLabel.fontSize = 18
        resultsLabel.fontColor = .white
        resultsLabel.position = CGPoint(x: 0, y: 0)
        resultsLabel.zPosition = 250

        scene.addChild(resultsLabel)

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 4.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        resultsLabel.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }

    // MARK: - Persistence

    private func saveLeaderboardData() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(leaderboardData) {
            UserDefaults.standard.set(data, forKey: "leaderboardData")
        }
    }

    private func loadLeaderboardData() {
        if let data = UserDefaults.standard.data(forKey: "leaderboardData") {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode([LeaderboardEntry].self, from: data) {
                leaderboardData = loadedData
            }
        }
    }

    private func saveActiveChallenges() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(activeChallenges) {
            UserDefaults.standard.set(data, forKey: "activeChallenges")
        }
    }

    private func loadActiveChallenges() {
        if let data = UserDefaults.standard.data(forKey: "activeChallenges") {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode([Challenge].self, from: data) {
                activeChallenges = loadedData
            }
        }
    }

    private func savePlayerStats() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(playerStats) {
            UserDefaults.standard.set(data, forKey: "playerSocialStats")
        }
    }

    private func loadPlayerStats() {
        if let data = UserDefaults.standard.data(forKey: "playerSocialStats") {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(PlayerSocialStats.self, from: data) {
                playerStats = loadedData
            }
        }
    }
}

// MARK: - Data Models

/// Leaderboard entry
struct LeaderboardEntry: Codable, Hashable {
    var playerName: String
    var score: Int
    var timestamp: Date
    var rank: Int
}

/// Challenge types
enum ChallengeType: String, Codable {
    case highScore = "High Score"
    case survival = "Survival"
    case speedRun = "Speed Run"
    case combo = "Combo Master"
}

/// Challenge data
struct Challenge: Codable, Hashable {
    var id: String
    var type: ChallengeType
    var targetScore: Int
    var duration: TimeInterval
    var startDate: Date
    var participants: [String]
    var scores: [String: Int] = [:]
    var isActive: Bool

    func getResults() -> [String: Int] {
        scores
    }

    func getWinner() -> String? {
        scores.max(by: { $0.value < $1.value })?.key
    }
}

/// Player social statistics
struct PlayerSocialStats: Codable {
    var playerName: String = "Player"
    var personalBest: Int = 0
    var gamesPlayed: Int = 0
    var totalScore: Int = 0
    var averageScore: Double = 0.0
    var achievements: [String] = []
    var challengesWon: Int = 0
    var challengesParticipated: Int = 0
}
