//
// AchievementDataManager.swift
// AvoidObstaclesGame
//
// Handles data persistence for achievements.
// Component extracted from AchievementManager.swift
//

import Foundation

/// Manages persistence of achievement data
public class AchievementDataManager: @unchecked Sendable {
    // MARK: - Properties

    /// UserDefaults keys
    private let unlockedAchievementsKey = "unlockedAchievements"
    private let achievementProgressKey = "achievementProgress"

    /// Shared instance
    public static let shared = AchievementDataManager()

    // MARK: - Initialization

    private init() {}

    // MARK: - Data Loading

    /// Loads achievement progress from UserDefaults
    /// - Parameter achievements: The achievements dictionary to update
    /// - Returns: Updated achievements dictionary and total points
    public func loadProgress(for achievements: [String: Achievement]) -> ([String: Achievement], Int) {
        var updatedAchievements = achievements
        var totalPoints = 0
        let defaults = UserDefaults.standard

        // Load unlocked achievements
        if let unlockedIds = defaults.array(forKey: unlockedAchievementsKey) as? [String] {
            for id in unlockedIds {
                if var achievement = updatedAchievements[id] {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = defaults.object(forKey: "achievement_\(id)_date") as? Date
                    updatedAchievements[id] = achievement
                    totalPoints += achievement.points
                }
            }
        }

        // Load progress for incomplete achievements
        if let progressData = defaults.dictionary(forKey: achievementProgressKey) as? [String: Int] {
            for (id, value) in progressData {
                if var achievement = updatedAchievements[id], !achievement.isUnlocked {
                    achievement.currentValue = value
                    updatedAchievements[id] = achievement
                }
            }
        }

        return (updatedAchievements, totalPoints)
    }

    // MARK: - Data Saving

    /// Saves achievement progress to UserDefaults
    /// - Parameter achievements: The achievements to save
    public func saveProgress(for achievements: [String: Achievement]) {
        let defaults = UserDefaults.standard

        // Save unlocked achievements
        let unlockedIds = achievements.values.filter(\.isUnlocked).map(\.id)
        defaults.set(unlockedIds, forKey: self.unlockedAchievementsKey)

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
        defaults.set(progressData, forKey: self.achievementProgressKey)

        defaults.synchronize()
    }

    // MARK: - Achievement Updates

    /// Updates an achievement in the dictionary and saves progress
    /// - Parameters:
    ///   - id: Achievement ID
    ///   - achievements: The achievements dictionary
    ///   - increment: Value to increment current progress by
    /// - Returns: Updated achievements dictionary
    public func updateAchievement(_ id: String, in achievements: [String: Achievement], increment: Int = 1) -> [String: Achievement] {
        var updatedAchievements = achievements

        guard var achievement = updatedAchievements[id], !achievement.isUnlocked else {
            return updatedAchievements
        }

        achievement.currentValue += increment
        updatedAchievements[id] = achievement

        // Save progress
        self.saveProgress(for: updatedAchievements)

        return updatedAchievements
    }

    /// Unlocks an achievement and saves progress
    /// - Parameters:
    ///   - id: Achievement ID
    ///   - achievements: The achievements dictionary
    /// - Returns: Updated achievements dictionary
    public func unlockAchievement(_ id: String, in achievements: [String: Achievement]) -> [String: Achievement] {
        var updatedAchievements = achievements

        guard var achievement = updatedAchievements[id], !achievement.isUnlocked else {
            return updatedAchievements
        }

        achievement.isUnlocked = true
        achievement.unlockedDate = Date()
        updatedAchievements[id] = achievement

        // Save progress
        self.saveProgress(for: updatedAchievements)

        return updatedAchievements
    }

    // MARK: - Reset

    /// Resets all achievements
    /// - Parameter achievements: The achievements dictionary to reset
    /// - Returns: Reset achievements dictionary
    public func resetAllAchievements(_ achievements: [String: Achievement]) -> [String: Achievement] {
        var resetAchievements = achievements

        for key in resetAchievements.keys {
            if var achievement = resetAchievements[key] {
                achievement.isUnlocked = false
                achievement.currentValue = 0
                achievement.unlockedDate = nil
                resetAchievements[key] = achievement
            }
        }

        // Save reset progress
        self.saveProgress(for: resetAchievements)

        return resetAchievements
    }

    // MARK: - Utility

    /// Clears all achievement data from UserDefaults
    public func clearAllData() {
        let defaults = UserDefaults.standard

        // Remove unlocked achievements
        defaults.removeObject(forKey: self.unlockedAchievementsKey)

        // Remove progress data
        defaults.removeObject(forKey: self.achievementProgressKey)

        // Remove all unlock dates
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("achievement_") && key.hasSuffix("_date") {
            defaults.removeObject(forKey: key)
        }

        defaults.synchronize()
    }
}
