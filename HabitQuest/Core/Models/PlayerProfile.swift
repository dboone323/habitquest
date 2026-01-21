import Foundation
import SwiftData

/// Tracks the user's global progress and character stats
/// This represents the player's overall game state and progression
@Model
final class PlayerProfile {
    /// Current character level (starts at 1)
    var level: Int

    /// Current experience points accumulated
    var currentXP: Int

    /// Experience points needed to reach the next level
    var xpForNextLevel: Int

    /// Highest consecutive streak achieved across all habits
    var longestStreak: Int

    /// When this profile was created
    var creationDate: Date

    /// Initialize a new player profile with default starting values
    init() {
        level = 1
        currentXP = 0
        xpForNextLevel = 100
        longestStreak = 0
        creationDate = Date()
    }

    /// Calculate progress toward next level as a percentage (0.0 to 1.0)
    var xpProgress: Float {
        let gamificationService = GamificationService()
        let previousLevelXP = level > 1 ? gamificationService.calculateXPForLevel(level - 1) : 0
        let currentLevelXP = gamificationService.calculateXPForLevel(level)
        let progressInCurrentLevel = currentXP - previousLevelXP
        let xpNeededForCurrentLevel = currentLevelXP - previousLevelXP

        return xpNeededForCurrentLevel > 0 ? Float(progressInCurrentLevel) / Float(xpNeededForCurrentLevel) : 0.0
    }
}
