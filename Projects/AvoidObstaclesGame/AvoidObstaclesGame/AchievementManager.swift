//
// AchievementManager.swift
// AvoidObstaclesGame
//
// Manages achievements, unlocking system, and achievement notifications.
//

import Foundation

/// Protocol for achievement-related events
protocol AchievementDelegate: AnyObject {
    func achievementUnlocked(_ achievement: Achievement)
    func achievementProgressUpdated(_ achievement: Achievement, progress: Float)
}

/// Represents an achievement in the game
public struct Achievement: Codable, Identifiable {
    public let id: String
    let title: String
    let description: String
    let iconName: String
    let points: Int
    let isHidden: Bool

    /// Achievement types for different categories
    enum AchievementType: String, Codable {
        case scoreBased
        case timeBased
        case streakBased
        case collectionBased
        case special
    }

    let type: AchievementType
    let targetValue: Int
    var currentValue: Int = 0
    var isUnlocked: Bool = false
    var unlockedDate: Date?

    /// Progress towards completion (0.0 to 1.0)
    var progress: Float {
        min(Float(currentValue) / Float(targetValue), 1.0)
    }

    /// Creates an achievement with default values
    init(
        id: String,
        title: String,
        description: String,
        iconName: String = "trophy",
        points: Int,
        type: AchievementType,
        targetValue: Int,
        isHidden: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.points = points
        self.type = type
        self.targetValue = targetValue
        self.isHidden = isHidden
    }
}

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
        setupAchievements()
        loadProgress()
    }

    // MARK: - Achievement Setup

    /// Sets up all available achievements
    private func setupAchievements() {
        let allAchievements = [
            // Score-based achievements
            Achievement(
                id: "first_game",
                title: "First Steps",
                description: "Complete your first game",
                points: 10,
                type: .special,
                targetValue: 1
            ),
            Achievement(
                id: "score_100",
                title: "Century",
                description: "Reach a score of 100",
                points: 25,
                type: .scoreBased,
                targetValue: 100
            ),
            Achievement(
                id: "score_500",
                title: "High Flyer",
                description: "Reach a score of 500",
                points: 50,
                type: .scoreBased,
                targetValue: 500
            ),
            Achievement(
                id: "score_1000",
                title: "Legend",
                description: "Reach a score of 1000",
                points: 100,
                type: .scoreBased,
                targetValue: 1000
            ),
            Achievement(
                id: "score_2500",
                title: "Master",
                description: "Reach a score of 2500",
                points: 200,
                type: .scoreBased,
                targetValue: 2500
            ),

            // Time-based achievements
            Achievement(
                id: "survivor_30s",
                title: "Survivor",
                description: "Survive for 30 seconds",
                points: 30,
                type: .timeBased,
                targetValue: 30
            ),
            Achievement(
                id: "survivor_60s",
                title: "Time Lord",
                description: "Survive for 60 seconds",
                points: 60,
                type: .timeBased,
                targetValue: 60
            ),
            Achievement(
                id: "survivor_120s",
                title: "Eternal",
                description: "Survive for 2 minutes",
                points: 120,
                type: .timeBased,
                targetValue: 120
            ),

            // Difficulty-based achievements
            Achievement(
                id: "level_3",
                title: "Getting Tough",
                description: "Reach difficulty level 3",
                points: 40,
                type: .special,
                targetValue: 3
            ),
            Achievement(
                id: "level_5",
                title: "Speed Demon",
                description: "Reach difficulty level 5",
                points: 80,
                type: .special,
                targetValue: 5
            ),
            Achievement(
                id: "level_6",
                title: "Ultimate",
                description: "Reach the maximum difficulty",
                points: 150,
                type: .special,
                targetValue: 6
            ),

            // Streak-based achievements
            Achievement(
                id: "perfect_start",
                title: "Perfect Start",
                description: "Score 50 without getting hit",
                points: 35,
                type: .streakBased,
                targetValue: 50
            ),
            Achievement(
                id: "no_hit_100",
                title: "Untouchable",
                description: "Score 100 without getting hit",
                points: 70,
                type: .streakBased,
                targetValue: 100
            ),

            // Collection-based achievements
            Achievement(
                id: "power_up_collector",
                title: "Collector",
                description: "Collect 10 power-ups",
                points: 45,
                type: .collectionBased,
                targetValue: 10
            ),
            Achievement(
                id: "shield_master",
                title: "Shield Master",
                description: "Use shield 5 times",
                points: 55,
                type: .collectionBased,
                targetValue: 5
            ),

            // Special achievements
            Achievement(
                id: "comeback_kid",
                title: "Comeback Kid",
                description: "Score 200 after game over",
                points: 90,
                type: .special,
                targetValue: 200,
                isHidden: true
            ),
            Achievement(
                id: "speedrunner",
                title: "Speedrunner",
                description: "Complete a game in under 30 seconds",
                points: 75,
                type: .timeBased,
                targetValue: 30,
                isHidden: true
            ),
        ]

        for achievement in allAchievements {
            achievements[achievement.id] = achievement
        }
    }

    // MARK: - Progress Tracking

    /// Updates achievement progress based on game events
    /// - Parameter event: The game event that occurred
    /// - Parameter value: The value associated with the event
    func updateProgress(for event: AchievementEvent, value: Int = 1) {
        switch event {
        case .gameCompleted:
            updateAchievement("first_game", increment: 1)
            checkTimeBasedAchievements(survivalTime: Double(value))

        case let .scoreReached(score):
            updateScoreBasedAchievements(score: score)

        case let .difficultyReached(level):
            updateDifficultyAchievements(level: level)

        case .powerUpCollected:
            updateAchievement("power_up_collector", increment: 1)

        case .shieldUsed:
            updateAchievement("shield_master", increment: 1)

        case let .perfectScore(score):
            updateStreakAchievements(score: score)

        case let .comebackScore(score):
            if score >= 200 {
                unlockAchievement("comeback_kid")
            }
        }
    }

    /// Updates score-based achievements
    private func updateScoreBasedAchievements(score: Int) {
        let scoreAchievements = ["score_100", "score_500", "score_1000", "score_2500"]
        for achievementId in scoreAchievements {
            if let target = achievements[achievementId]?.targetValue, score >= target {
                unlockAchievement(achievementId)
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

        for (achievementId, targetTime) in timeAchievements {
            if survivalTime >= targetTime {
                unlockAchievement(achievementId)
            }
        }
    }

    /// Updates difficulty-based achievements
    private func updateDifficultyAchievements(level: Int) {
        let difficultyAchievements = [
            ("level_3", 3),
            ("level_5", 5),
            ("level_6", 6),
        ]

        for (achievementId, targetLevel) in difficultyAchievements {
            if level >= targetLevel {
                unlockAchievement(achievementId)
            }
        }
    }

    /// Updates streak-based achievements
    private func updateStreakAchievements(score: Int) {
        let streakAchievements = [
            ("perfect_start", 50),
            ("no_hit_100", 100),
        ]

        for (achievementId, targetScore) in streakAchievements {
            if score >= targetScore {
                unlockAchievement(achievementId)
            }
        }
    }

    /// Updates a specific achievement's progress
    private func updateAchievement(_ id: String, increment: Int = 1) {
        guard var achievement = achievements[id], !achievement.isUnlocked else { return }

        achievement.currentValue += increment

        if achievement.currentValue >= achievement.targetValue {
            unlockAchievement(id)
        } else {
            achievements[id] = achievement
            delegate?.achievementProgressUpdated(achievement, progress: achievement.progress)
            saveProgress()
        }
    }

    /// Unlocks an achievement
    private func unlockAchievement(_ id: String) {
        guard var achievement = achievements[id], !achievement.isUnlocked else { return }

        achievement.isUnlocked = true
        achievement.unlockedDate = Date()
        achievements[id] = achievement

        totalPoints += achievement.points

        // Save progress
        saveProgress()

        // Notify delegate
        delegate?.achievementUnlocked(achievement)

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
                    achievements[id] = achievement
                    totalPoints += achievement.points
                }
            }
        }

        // Load progress for incomplete achievements
        if let progressData = defaults.dictionary(forKey: achievementProgressKey) as? [String: Int] {
            for (id, value) in progressData {
                if var achievement = achievements[id], !achievement.isUnlocked {
                    achievement.currentValue = value
                    achievements[id] = achievement
                }
            }
        }
    }

    /// Saves achievement progress to UserDefaults
    private func saveProgress() {
        let defaults = UserDefaults.standard

        // Save unlocked achievements
        let unlockedIds = achievements.values.filter(\.isUnlocked).map(\.id)
        defaults.set(unlockedIds, forKey: unlockedAchievementsKey)

        // Save unlock dates
        for achievement in achievements.values where achievement.isUnlocked {
            if let date = achievement.unlockedDate {
                defaults.set(date, forKey: "achievement_\(achievement.id)_date")
            }
        }

        // Save progress for incomplete achievements
        var progressData: [String: Int] = [:]
        for achievement in achievements.values where !achievement.isUnlocked && achievement.currentValue > 0 {
            progressData[achievement.id] = achievement.currentValue
        }
        defaults.set(progressData, forKey: achievementProgressKey)

        defaults.synchronize()
    }

    // MARK: - Achievement Queries

    /// Gets all achievements
    /// - Returns: Array of all achievements
    func getAllAchievements() -> [Achievement] {
        Array(achievements.values).sorted { $0.points < $1.points }
    }

    /// Gets only unlocked achievements
    /// - Returns: Array of unlocked achievements
    func getUnlockedAchievements() -> [Achievement] {
        achievements.values.filter(\.isUnlocked).sorted { $0.unlockedDate ?? Date() > $1.unlockedDate ?? Date() }
    }

    /// Gets achievements that are in progress
    /// - Returns: Array of achievements with progress > 0 and < 100%
    func getInProgressAchievements() -> [Achievement] {
        achievements.values.filter { !$0.isUnlocked && $0.currentValue > 0 }
    }

    /// Gets locked achievements
    /// - Returns: Array of locked achievements
    func getLockedAchievements() -> [Achievement] {
        achievements.values.filter { !$0.isUnlocked && $0.currentValue == 0 }
    }

    /// Checks if an achievement is unlocked
    /// - Parameter id: The achievement ID
    /// - Returns: True if unlocked
    func isAchievementUnlocked(_ id: String) -> Bool {
        achievements[id]?.isUnlocked ?? false
    }

    /// Gets achievement statistics
    /// - Returns: Dictionary of statistics
    func getAchievementStatistics() -> [String: Any] {
        let totalAchievements = achievements.count
        let unlockedCount = achievements.values.count(where: { $0.isUnlocked })
        let completionRate = totalAchievements > 0 ? Double(unlockedCount) / Double(totalAchievements) : 0

        return [
            "totalAchievements": totalAchievements,
            "unlockedAchievements": unlockedCount,
            "completionRate": completionRate,
            "totalPoints": totalPoints,
            "recentUnlocks": getRecentUnlocks(count: 5),
        ]
    }

    /// Gets recently unlocked achievements
    /// - Parameter count: Number of recent achievements to return
    /// - Returns: Array of recently unlocked achievements
    func getRecentUnlocks(count: Int = 5) -> [Achievement] {
        getUnlockedAchievements().prefix(count).map(\.self)
    }

    // MARK: - Reset

    /// Resets all achievements (for testing or user request)
    func resetAllAchievements() {
        for key in achievements.keys {
            if var achievement = achievements[key] {
                achievement.isUnlocked = false
                achievement.currentValue = 0
                achievement.unlockedDate = nil
                achievements[key] = achievement
            }
        }

        totalPoints = 0
        saveProgress()
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
