//
// AchievementDataManager.swift
// AvoidObstaclesGame
//
// Handles data persistence for achievements with security integration.
// Component extracted from AchievementManager.swift
//

import Foundation

/// Manages persistence of achievement data with security features
public class AchievementDataManager: @unchecked Sendable {
    // MARK: - Properties

    /// UserDefaults keys
    private let unlockedAchievementsKey = "unlockedAchievements"
    private let achievementProgressKey = "achievementProgress"

    /// Shared instance
    public static let shared = AchievementDataManager()

    /// Security services
    private let auditLogger = AuditLogger.shared
    private let encryptionService = EncryptionService.shared
    private let securityMonitor = SecurityMonitor.shared

    // MARK: - Initialization

    private init() {}

    // MARK: - Data Loading

    /// Loads achievement progress from UserDefaults with security monitoring
    /// - Parameter achievements: The achievements dictionary to update
    /// - Returns: Updated achievements dictionary and total points
    public func loadProgress(for achievements: [String: Achievement]) -> ([String: Achievement], Int) {
        var updatedAchievements = achievements
        var totalPoints = 0
        let defaults = UserDefaults.standard

        // Monitor data access
        securityMonitor.monitorDataAccess(operation: .read, entityType: "achievements", dataCount: 2)

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

    /// Saves achievement progress to UserDefaults with security monitoring
    /// - Parameter achievements: The achievements to save
    public func saveProgress(for achievements: [String: Achievement]) {
        let defaults = UserDefaults.standard

        // Prepare data for saving
        let unlockedIds = achievements.values.filter(\.isUnlocked).map(\.id)
        var progressData: [String: Int] = [:]

        for achievement in achievements.values where !achievement.isUnlocked && achievement.currentValue > 0 {
            progressData[achievement.id] = achievement.currentValue
        }

        // Monitor data access
        securityMonitor.monitorDataAccess(operation: .update, entityType: "achievements", dataCount: unlockedIds.count + progressData.count)

        // Save unlocked achievements
        defaults.set(unlockedIds, forKey: unlockedAchievementsKey)

        // Save unlock dates
        for achievement in achievements.values where achievement.isUnlocked {
            if let date = achievement.unlockedDate {
                defaults.set(date, forKey: "achievement_\(achievement.id)_date")
            }
        }

        // Save progress for incomplete achievements
        defaults.set(progressData, forKey: achievementProgressKey)

        defaults.synchronize()

        // Log security event
        auditLogger.logDataAccess(operation: .update, entityType: "achievements", dataCount: unlockedIds.count + progressData.count)
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

    /// Clears all achievement data from UserDefaults with security logging
    public func clearAllData() {
        let defaults = UserDefaults.standard

        // Count data before deletion for logging
        let unlockedCount = (defaults.array(forKey: unlockedAchievementsKey) as? [String])?.count ?? 0
        let progressCount = (defaults.dictionary(forKey: achievementProgressKey) as? [String: Int])?.count ?? 0
        let totalDataCount = unlockedCount + progressCount

        // Monitor data deletion
        securityMonitor.monitorDataAccess(operation: .delete, entityType: "achievements", dataCount: totalDataCount)

        // Remove unlocked achievements
        defaults.removeObject(forKey: unlockedAchievementsKey)

        // Remove progress data
        defaults.removeObject(forKey: achievementProgressKey)

        // Remove all unlock dates
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("achievement_") && key.hasSuffix("_date") {
            defaults.removeObject(forKey: key)
        }

        defaults.synchronize()

        // Log security event
        auditLogger.logDataAccess(operation: .delete, entityType: "achievements", dataCount: totalDataCount)
    }
}
