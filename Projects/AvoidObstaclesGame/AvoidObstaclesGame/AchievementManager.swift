//
// AchievementManager.swift
// AvoidObstaclesGame
//
// Manages achievements, unlocking system, and achievement notifications.
//

import Foundation

/// Manages achievements and their unlocking
class AchievementManager {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = AchievementManager()

    /// Delegate for achievement events
    weak var delegate: AchievementDelegate?

    /// All available achievements
    private var achievements: [String: Achievement] = [:]

    /// UserDefaults keys
    private let unlockedAchievementsKey = "unlockedAchievements"
    private let achievementProgressKey = "achievementProgress"

    /// Total points earned from achievements
    private(set) var totalPoints: Int = 0

    // MARK: - Initialization

    private init() {
        self.setupAchievements()
        self.loadProgress()
    }

    // MARK: - Achievement Setup

    /// Sets up all available achievements
    private func setupAchievements() {
        // Use the centralized achievement definitions
        self.achievements = AchievementDefinitions.createAchievementDictionary()
    }

    // MARK: - Progress Tracking

    /// Updates achievement progress based on game events
    /// - Parameter event: The game event that occurred
    /// - Parameter value: The value associated with the event
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
            self.delegate?.achievementProgressUpdated(achievement, progress: achievement.progress)
            self.saveProgress()
        }
    }

    /// Unlocks an achievement
    private func unlockAchievement(_ id: String) {
        guard var achievement = achievements[id], !achievement.isUnlocked else { return }

        achievement.isUnlocked = true
        achievement.unlockedDate = Date()
        self.achievements[id] = achievement

        self.totalPoints += achievement.points

        // Save progress
        self.saveProgress()

        // Notify delegate
        self.delegate?.achievementUnlocked(achievement)

        // Play achievement sound
        AudioManager.shared.playLevelUpSound()

        // Trigger haptic feedback
        AudioManager.shared.triggerHapticFeedback(style: .success)
    }

    // MARK: - Data Persistence

    /// Loads achievement progress from UserDefaults
    private func loadProgress() {
        let defaults = UserDefaults.standard

        // Load unlocked achievements
        if let unlockedIds = defaults.array(forKey: unlockedAchievementsKey) as? [String] {
            for id in unlockedIds {
                if var achievement = achievements[id] {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = defaults.object(forKey: "achievement_\(id)_date") as? Date
                    self.achievements[id] = achievement
                    self.totalPoints += achievement.points
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
    private func saveProgress() {
        let defaults = UserDefaults.standard

        // Save unlocked achievements
        let unlockedIds = self.achievements.values.filter(\.isUnlocked).map(\.id)
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

    // MARK: - Achievement Queries

    /// Gets all achievements
    /// - Returns: Array of all achievements
    func getAllAchievements() -> [Achievement] {
        Array(self.achievements.values).sorted { $0.points < $1.points }
    }

    /// Gets only unlocked achievements
    /// - Returns: Array of unlocked achievements
    func getUnlockedAchievements() -> [Achievement] {
        self.achievements.values.filter(\.isUnlocked).sorted { $0.unlockedDate ?? Date() > $1.unlockedDate ?? Date() }
    }

    /// Gets achievements that are in progress
    /// - Returns: Array of achievements with progress > 0 and < 100%
    func getInProgressAchievements() -> [Achievement] {
        self.achievements.values.filter { !$0.isUnlocked && $0.currentValue > 0 }
    }

    /// Gets locked achievements
    /// - Returns: Array of locked achievements
    func getLockedAchievements() -> [Achievement] {
        self.achievements.values.filter { !$0.isUnlocked && $0.currentValue == 0 }
    }

    /// Checks if an achievement is unlocked
    /// - Parameter id: The achievement ID
    /// - Returns: True if unlocked
    func isAchievementUnlocked(_ id: String) -> Bool {
        self.achievements[id]?.isUnlocked ?? false
    }

    /// Gets achievement statistics
    /// - Returns: Dictionary of statistics
    func getAchievementStatistics() -> [String: Any] {
        let totalAchievements = self.achievements.count
        let unlockedCount = self.achievements.values.count(where: { $0.isUnlocked })
        let completionRate = totalAchievements > 0 ? Double(unlockedCount) / Double(totalAchievements) : 0

        return [
            "totalAchievements": totalAchievements,
            "unlockedAchievements": unlockedCount,
            "completionRate": completionRate,
            "totalPoints": self.totalPoints,
            "recentUnlocks": self.getRecentUnlocks(count: 5),
        ]
    }

    /// Gets recently unlocked achievements
    /// - Parameter count: Number of recent achievements to return
    /// - Returns: Array of recently unlocked achievements
    func getRecentUnlocks(count: Int = 5) -> [Achievement] {
        self.getUnlockedAchievements().prefix(count).map(\.self)
    }

    // MARK: - Reset

    /// Resets all achievements (for testing or user request)
    func resetAllAchievements() {
        for key in self.achievements.keys {
            if var achievement = achievements[key] {
                achievement.isUnlocked = false
                achievement.currentValue = 0
                achievement.unlockedDate = nil
                self.achievements[key] = achievement
            }
        }

        self.totalPoints = 0
        self.saveProgress()
    }

    // MARK: - Async Achievement Queries

    /// Gets all achievements asynchronously
    /// - Returns: Array of all achievements
    func getAllAchievementsAsync() async -> [Achievement] {
        await Task.detached {
            self.getAllAchievements()
        }.value
    }

    /// Gets only unlocked achievements asynchronously
    /// - Returns: Array of unlocked achievements
    func getUnlockedAchievementsAsync() async -> [Achievement] {
        await Task.detached {
            self.getUnlockedAchievements()
        }.value
    }

    /// Gets achievements that are in progress asynchronously
    /// - Returns: Array of achievements with progress > 0 and < 100%
    func getInProgressAchievementsAsync() async -> [Achievement] {
        await Task.detached {
            self.getInProgressAchievements()
        }.value
    }

    /// Gets locked achievements asynchronously
    /// - Returns: Array of locked achievements
    func getLockedAchievementsAsync() async -> [Achievement] {
        await Task.detached {
            self.getLockedAchievements()
        }.value
    }

    /// Checks if an achievement is unlocked asynchronously
    /// - Parameter id: The achievement ID
    /// - Returns: True if unlocked
    func isAchievementUnlockedAsync(_ id: String) async -> Bool {
        await Task.detached {
            self.isAchievementUnlocked(id)
        }.value
    }

    /// Gets achievement statistics asynchronously
    /// - Returns: Dictionary of statistics
    func getAchievementStatisticsAsync() async -> [String: Any] {
        await Task.detached {
            self.getAchievementStatistics()
        }.value
    }

    /// Gets recently unlocked achievements asynchronously
    /// - Parameter count: Number of recent achievements to return
    /// - Returns: Array of recently unlocked achievements
    func getRecentUnlocksAsync(count: Int = 5) async -> [Achievement] {
        await Task.detached {
            self.getRecentUnlocks(count: count)
        }.value
    }

    /// Updates achievement progress based on game events asynchronously
    /// - Parameter event: The game event that occurred
    /// - Parameter value: The value associated with the event
    func updateProgressAsync(for event: AchievementEvent, value: Int = 1) async {
        await Task.detached {
            self.updateProgress(for: event, value: value)
        }.value
    }

    /// Resets all achievements asynchronously (for testing or user request)
    func resetAllAchievementsAsync() async {
        await Task.detached {
            self.resetAllAchievements()
        }.value
    }
}

/// Events that can trigger achievement progress
enum AchievementEvent {
    case gameCompleted
    case scoreReached(score: Int)
    case difficultyReached(level: Int)
    case powerUpCollected
    case shieldUsed
    case perfectScore(score: Int)
    case comebackScore(score: Int)
}

// MARK: - Object Pooling

/// Object pool for performance optimization
private var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
