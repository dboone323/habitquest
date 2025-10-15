//
// ProgressionManager.swift
// AvoidObstaclesGame
//
// Consolidated manager for all progression systems including achievements, high scores,
// and player advancement tracking. Merged from AchievementManager and HighScoreManager.
//

import Foundation

/// Protocol for progression-related events
protocol ProgressionDelegate: AnyObject {
    func achievementUnlocked(_ achievement: Achievement)
    func achievementProgressUpdated(_ achievement: Achievement, progress: Double)
    func highScoreAchieved(_ score: Int, rank: Int)
}

/// Manages all progression systems including achievements and high scores
class ProgressionManager {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = ProgressionManager()

    /// Delegate for progression events
    weak var delegate: ProgressionDelegate?

    /// Achievement system properties
    private var achievements: [String: Achievement] = [:]
    private let unlockedAchievementsKey = "unlockedAchievements"
    private let achievementProgressKey = "achievementProgress"
    private(set) var totalAchievementPoints: Int = 0

    /// High score system properties
    private let highScoresKey = "AvoidObstaclesHighScores"
    private let maxHighScores = 10

    // MARK: - Initialization

    private init() {
        self.setupAchievements()
        self.loadAchievementProgress()
    }

    // MARK: - Achievement System

    /// Sets up all available achievements
    private func setupAchievements() {
        self.achievements = AchievementDefinitions.createAchievementDictionary()
    }

    /// Updates achievement progress based on game events
    func updateProgress(for event: AchievementEvent, value: Int = 1) {
        switch event {
        case .gameCompleted:
            self.updateAchievement("first_game", increment: 1)
            self.checkTimeBasedAchievements(survivalTime: Double(value))

        case let .scoreReached(score):
            self.updateScoreBasedAchievements(score: score)

        case let .difficultyReached(level):
            self.updateDifficultyAchievements(level: level)

        case .powerUpCollected:
            self.updateAchievement("power_up_collector", increment: 1)

        case .shieldUsed:
            self.updateAchievement("shield_master", increment: 1)

        case let .perfectScore(score):
            self.updateStreakAchievements(score: score)

        case let .comebackScore(score):
            if score >= 200 {
                self.unlockAchievement("comeback_kid")
            }
        }
    }

    /// Updates score-based achievements
    private func updateScoreBasedAchievements(score: Int) {
        let scoreAchievements = ["score_100", "score_500", "score_1000", "score_2500"]
        for achievementId in scoreAchievements {
            if let target = achievements[achievementId]?.targetValue, score >= target {
                self.unlockAchievement(achievementId)
            }
        }
    }

    /// Updates time-based achievements
    private func checkTimeBasedAchievements(survivalTime: TimeInterval) {
        let timeAchievements = [
            ("survivor_30s", 30.0),
            ("survivor_60s", 60.0),
            ("survivor_120s", 120.0),
            ("speedrunner", 30.0),
        ]

        for (achievementId, targetTime) in timeAchievements where survivalTime >= targetTime {
            self.unlockAchievement(achievementId)
        }
    }

    /// Updates difficulty-based achievements
    private func updateDifficultyAchievements(level: Int) {
        let difficultyAchievements = [
            ("level_3", 3),
            ("level_5", 5),
            ("level_6", 6),
        ]

        for (achievementId, targetLevel) in difficultyAchievements where level >= targetLevel {
            self.unlockAchievement(achievementId)
        }
    }

    /// Updates streak-based achievements
    private func updateStreakAchievements(score: Int) {
        let streakAchievements = [
            ("perfect_start", 50),
            ("no_hit_100", 100),
        ]

        for (achievementId, targetScore) in streakAchievements where score >= targetScore {
            self.unlockAchievement(achievementId)
        }
    }

    /// Updates a specific achievement's progress
    private func updateAchievement(_ id: String, increment: Int = 1) {
        guard var achievement = achievements[id], !achievement.isUnlocked else { return }

        achievement.currentValue += increment

        if achievement.currentValue >= achievement.targetValue {
            self.unlockAchievement(id)
        } else {
            self.achievements[id] = achievement
            self.delegate?.achievementProgressUpdated(achievement, progress: Double(achievement.progress))
            self.saveAchievementProgress()
        }
    }

    /// Unlocks an achievement
    private func unlockAchievement(_ id: String) {
        guard var achievement = achievements[id], !achievement.isUnlocked else { return }

        achievement.isUnlocked = true
        achievement.unlockedDate = Date()
        self.achievements[id] = achievement

        self.totalAchievementPoints += achievement.points

        self.saveAchievementProgress()
        self.delegate?.achievementUnlocked(achievement)

        // Play achievement sound and haptic feedback
        AudioManager.shared.playLevelUpSound()
        AudioManager.shared.triggerHapticFeedback(style: .success)
    }

    // MARK: - High Score System

    /// Retrieves all high scores sorted from highest to lowest
    func getHighScores() -> [Int] {
        let scores = UserDefaults.standard.array(forKey: self.highScoresKey) as? [Int] ?? []
        return scores.sorted(by: >)
    }

    /// Adds a new score to the high scores list
    func addScore(_ score: Int) -> Bool {
        var scores = self.getHighScores()
        let wasHighScore = self.isHighScore(score)

        scores.append(score)
        scores.sort(by: >)

        // Keep only top scores
        if scores.count > self.maxHighScores {
            scores = Array(scores.prefix(self.maxHighScores))
        }

        UserDefaults.standard.set(scores, forKey: self.highScoresKey)
        UserDefaults.standard.synchronize()

        // Notify if this became a high score
        if wasHighScore, let rank = scores.firstIndex(of: score) {
            self.delegate?.highScoreAchieved(score, rank: rank + 1)
        }

        return wasHighScore
    }

    /// Retrieves the highest score
    func getHighestScore() -> Int {
        self.getHighScores().first ?? 0
    }

    /// Checks if a score would qualify as a high score
    func isHighScore(_ score: Int) -> Bool {
        let scores = self.getHighScores()
        return scores.count < self.maxHighScores || score > (scores.last ?? 0)
    }

    /// Clears all high scores
    func clearHighScores() {
        UserDefaults.standard.removeObject(forKey: self.highScoresKey)
        UserDefaults.standard.synchronize()
    }

    // MARK: - Achievement Queries

    /// Gets all achievements
    func getAllAchievements() -> [Achievement] {
        Array(self.achievements.values).sorted { $0.points < $1.points }
    }

    /// Gets only unlocked achievements
    func getUnlockedAchievements() -> [Achievement] {
        self.achievements.values.filter { $0.isUnlocked }.sorted { $0.unlockedDate ?? Date() > $1.unlockedDate ?? Date() }
    }

    /// Gets achievements that are in progress
    func getInProgressAchievements() -> [Achievement] {
        self.achievements.values.filter { !$0.isUnlocked && $0.currentValue > 0 }
    }

    /// Gets locked achievements
    func getLockedAchievements() -> [Achievement] {
        self.achievements.values.filter { !$0.isUnlocked && $0.currentValue == 0 }
    }

    /// Checks if an achievement is unlocked
    func isAchievementUnlocked(_ id: String) -> Bool {
        self.achievements[id]?.isUnlocked ?? false
    }

    /// Gets achievement statistics
    func getAchievementStatistics() -> [String: Any] {
        let totalAchievements = self.achievements.count
        let unlockedCount = self.achievements.values.filter { $0.isUnlocked }.count
        let completionRate = totalAchievements > 0 ? Double(unlockedCount) / Double(totalAchievements) : 0

        return [
            "totalAchievements": totalAchievements,
            "unlockedAchievements": unlockedCount,
            "completionRate": completionRate,
            "totalPoints": self.totalAchievementPoints,
            "recentUnlocks": self.getRecentUnlocks(count: 5),
        ]
    }

    /// Gets recently unlocked achievements
    func getRecentUnlocks(count: Int = 5) -> [Achievement] {
        self.getUnlockedAchievements().prefix(count).map { $0 }
    }

    // MARK: - Data Persistence

    /// Loads achievement progress from UserDefaults
    private func loadAchievementProgress() {
        let defaults = UserDefaults.standard

        // Load unlocked achievements
        if let unlockedIds = defaults.array(forKey: unlockedAchievementsKey) as? [String] {
            for id in unlockedIds {
                if var achievement = achievements[id] {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = defaults.object(forKey: "achievement_\(id)_date") as? Date
                    self.achievements[id] = achievement
                    self.totalAchievementPoints += achievement.points
                }
            }
        }

        // Load progress for incomplete achievements
        if let progressData = defaults.dictionary(forKey: achievementProgressKey) as? [String: Int] {
            for (id, value) in progressData {
                if var achievement = achievements[id], !achievement.isUnlocked {
                    achievement.currentValue = value
                    self.achievements[id] = achievement
                }
            }
        }
    }

    /// Saves achievement progress to UserDefaults
    private func saveAchievementProgress() {
        let defaults = UserDefaults.standard

        // Save unlocked achievements
        let unlockedIds = self.achievements.values.filter { $0.isUnlocked }.map { $0.id }
        defaults.set(unlockedIds, forKey: self.unlockedAchievementsKey)

        // Save unlock dates
        for achievement in self.achievements.values where achievement.isUnlocked {
            if let date = achievement.unlockedDate {
                defaults.set(date, forKey: "achievement_\(achievement.id)_date")
            }
        }

        // Save progress for incomplete achievements
        var progressData: [String: Int] = [:]
        for achievement in self.achievements.values where !achievement.isUnlocked && achievement.currentValue > 0 {
            progressData[achievement.id] = achievement.currentValue
        }
        defaults.set(progressData, forKey: self.achievementProgressKey)

        defaults.synchronize()
    }

    // MARK: - Reset Functions

    /// Resets all achievements
    func resetAllAchievements() {
        for key in self.achievements.keys {
            if var achievement = achievements[key] {
                achievement.isUnlocked = false
                achievement.currentValue = 0
                achievement.unlockedDate = nil
                self.achievements[key] = achievement
            }
        }

        self.totalAchievementPoints = 0
        self.saveAchievementProgress()
    }

    // MARK: - Async Versions

    /// Gets all achievements asynchronously
    func getAllAchievementsAsync() async -> [Achievement] {
        return await Task.detached(priority: .background) {
            return self.getAllAchievements()
        }.value
    }

    /// Gets high scores asynchronously
    func getHighScoresAsync() async -> [Int] {
        return await Task.detached(priority: .background) {
            return self.getHighScores()
        }.value
    }

    /// Adds a score asynchronously
    func addScoreAsync(_ score: Int) async -> Bool {
        return await Task.detached(priority: .background) {
            return self.addScore(score)
        }.value
    }

    /// Gets highest score asynchronously
    func getHighestScoreAsync() async -> Int {
        return await Task.detached(priority: .background) {
            return self.getHighestScore()
        }.value
    }

    /// Checks if score is high score asynchronously
    func isHighScoreAsync(_ score: Int) async -> Bool {
        return await Task.detached(priority: .background) {
            return self.isHighScore(score)
        }.value
    }

    /// Updates achievement progress asynchronously
    func updateProgressAsync(for event: AchievementEvent, value: Int = 1) async {
        await Task.detached(priority: .background) {
            self.updateProgress(for: event, value: value)
        }.value
    }

    /// Resets achievements asynchronously
    func resetAllAchievementsAsync() async {
        await Task.detached(priority: .background) {
            self.resetAllAchievements()
        }.value
    }

    /// Clears high scores asynchronously
    func clearHighScoresAsync() async {
        await Task.detached(priority: .background) {
            self.clearHighScores()
        }.value
    }
}

/// Events that can trigger achievement progress

