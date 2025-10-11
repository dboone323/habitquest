//
// AchievementDefinitions.swift
// AvoidObstaclesGame
//
// Contains all achievement definitions and setup logic.
// Component extracted from AchievementManager.swift
//

import Foundation

/// Protocol for achievement-related events
public protocol AchievementDelegate: AnyObject {
    func achievementUnlocked(_ achievement: Achievement)
    func achievementProgressUpdated(_ achievement: Achievement, progress: Float)
}

/// Represents an achievement in the game
public struct Achievement: Codable, Identifiable, Sendable {
    public let id: String
    let title: String
    let description: String
    let iconName: String
    let points: Int
    let isHidden: Bool

    /// Achievement types for different categories
    public enum AchievementType: String, Codable, Sendable {
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
        min(Float(self.currentValue) / Float(self.targetValue), 1.0)
    }

    /// Creates an achievement with default values
    public init(
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

/// Static definitions for all game achievements
public enum AchievementDefinitions {
    /// All available achievements in the game
    public static let allAchievements: [Achievement] = [
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

    /// Creates a dictionary of achievements keyed by ID
    public static func createAchievementDictionary() -> [String: Achievement] {
        var achievements: [String: Achievement] = [:]
        for achievement in self.allAchievements {
            achievements[achievement.id] = achievement
        }
        return achievements
    }

    /// Gets achievements by type
    public static func getAchievementsByType(_ type: Achievement.AchievementType) -> [Achievement] {
        self.allAchievements.filter { $0.type == type }
    }

    /// Gets score-based achievements sorted by target value
    public static func getScoreAchievements() -> [Achievement] {
        self.getAchievementsByType(.scoreBased).sorted { $0.targetValue < $1.targetValue }
    }

    /// Gets time-based achievements sorted by target value
    public static func getTimeAchievements() -> [Achievement] {
        self.getAchievementsByType(.timeBased).sorted { $0.targetValue < $1.targetValue }
    }

    /// Gets difficulty-based achievements sorted by target value
    public static func getDifficultyAchievements() -> [Achievement] {
        self.allAchievements.filter { $0.id.hasPrefix("level_") }.sorted { $0.targetValue < $1.targetValue }
    }

    /// Gets streak-based achievements sorted by target value
    public static func getStreakAchievements() -> [Achievement] {
        self.getAchievementsByType(.streakBased).sorted { $0.targetValue < $1.targetValue }
    }

    /// Gets collection-based achievements sorted by target value
    public static func getCollectionAchievements() -> [Achievement] {
        self.getAchievementsByType(.collectionBased).sorted { $0.targetValue < $1.targetValue }
    }

    /// Gets special achievements
    public static func getSpecialAchievements() -> [Achievement] {
        self.getAchievementsByType(.special)
    }

    /// Gets hidden achievements
    public static func getHiddenAchievements() -> [Achievement] {
        self.allAchievements.filter(\.isHidden)
    }
}
