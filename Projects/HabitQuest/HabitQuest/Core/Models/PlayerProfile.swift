import Foundation
import SwiftData

/// Tracks the user's global progress and character stats
/// This represents the player's overall game state and progression
@Model
final class PlayerProfile {
    /// Current character level (starts at 1)
    var level: Int {
        didSet {
            level = max(1, level)
        }
    }

    /// Current experience points accumulated
    var currentXP: Int {
        didSet {
            currentXP = max(0, currentXP)
        }
    }

    /// Experience points needed to reach the next level
    var xpForNextLevel: Int

    /// Highest consecutive streak achieved across all habits
    var longestStreak: Int

    /// When this profile was created
    var creationDate: Date

    /// Initialize a new player profile with default starting values
    init() {
        self.level = 1
        self.currentXP = 0
        self.xpForNextLevel = 100
        self.longestStreak = 0
        self.creationDate = Date()
    }

    /// Calculate progress toward next level as a percentage (0.0 to 1.0)
    var xpProgress: Float {
        let xpForCurrentLevel = GameRules.calculateXPForLevel(level)
        let xpForNextLevel = GameRules.calculateXPForLevel(level + 1)
        let xpInLevel = currentXP - xpForCurrentLevel
        let xpNeeded = xpForNextLevel - xpForCurrentLevel

        guard xpNeeded > 0 && xpInLevel >= 0 else { return 0.0 }
        return min(Float(xpInLevel) / Float(xpNeeded), 1.0)
    }
}
