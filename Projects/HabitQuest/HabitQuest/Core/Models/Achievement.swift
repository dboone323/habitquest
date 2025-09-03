import Foundation
import SwiftData

/// Represents an achievement that users can unlock through various actions
/// Achievements provide additional gamification and motivation
@Model
final class Achievement {
    /// Unique identifier for the achievement
    var id: UUID

    /// Display name of the achievement
    var name: String

    /// Detailed description of what the achievement requires
    var achievementDescription: String

    /// System icon name for the achievement badge
    var iconName: String

    /// Achievement category for organization
    var category: AchievementCategory

    /// XP bonus awarded when achievement is unlocked
    var xpReward: Int

    /// Whether this achievement is hidden until unlocked
    var isHidden: Bool

    /// When this achievement was unlocked (nil if not unlocked)
    var unlockedDate: Date?

    /// Current progress toward this achievement (0.0 to 1.0)
    var progress: Float

    /// Achievement requirement type and value (stored as encoded data)
    private var requirementData: Data

    /// Achievement requirement type and value
    var requirement: AchievementRequirement {
        get {
            guard let decoded = try? JSONDecoder().decode(AchievementRequirement.self, from: requirementData) else {
                return .totalCompletions(1) // Default fallback
            }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else {
                return
            }
            requirementData = encoded
        }
    }

    /// Initialize a new achievement
    /// - Parameters:
    ///   - name: Display name
    ///   - description: What the achievement requires
    ///   - iconName: SF Symbol name
    ///   - category: Achievement category
    ///   - xpReward: XP bonus when unlocked
    ///   - isHidden: Whether hidden until unlocked
    ///   - requirement: What needs to be accomplished
    init(name: String,
         description: String,
         iconName: String,
         category: AchievementCategory,
         xpReward: Int = 50,
         isHidden: Bool = false,
         requirement: AchievementRequirement) {
        self.id = UUID()
        self.name = name
        self.achievementDescription = description
        self.iconName = iconName
        self.category = category
        self.xpReward = xpReward
        self.isHidden = isHidden
        self.unlockedDate = nil
        self.progress = 0.0

        // Encode the requirement
        guard let encoded = try? JSONEncoder().encode(requirement) else {
            self.requirementData = Data()
            return
        }
        self.requirementData = encoded
    }

    /// Check if this achievement is unlocked
    var isUnlocked: Bool {
        return unlockedDate != nil
    }

    /// Get progress as a percentage string
    var progressPercentage: String {
        return String(format: "%.0f%%", progress * 100)
    }
}

/// Categories for organizing achievements
enum AchievementCategory: String, CaseIterable, Codable {
    case streak
    case completion
    case level
    case consistency
    case special

    var displayName: String {
        switch self {
        case .streak: return "Streak Master"
        case .completion: return "Quest Completion"
        case .level: return "Level Progression"
        case .consistency: return "Consistency"
        case .special: return "Special Events"
        }
    }

    var color: String {
        switch self {
        case .streak: return "orange"
        case .completion: return "green"
        case .level: return "blue"
        case .consistency: return "purple"
        case .special: return "yellow"
        }
    }
}

/// Types of achievement requirements
enum AchievementRequirement: @preconcurrency Codable, @unchecked Sendable {
    case streakDays(Int)           // Achieve X consecutive days
    case totalCompletions(Int)     // Complete habits X times total
    case reachLevel(Int)           // Reach level X
    case perfectWeek               // Complete all habits for 7 days
    case habitVariety(Int)         // Have X different active habits
    case earlyBird                 // Complete habits before 9 AM for 7 days
    case nightOwl                  // Complete habits after 9 PM for 7 days
    case weekendWarrior            // Complete habits on weekends for 4 weeks

    var description: String {
        switch self {
        case .streakDays(let days):
            return "Maintain a \(days)-day streak"
        case .totalCompletions(let count):
            return "Complete \(count) habits total"
        case .reachLevel(let level):
            return "Reach level \(level)"
        case .perfectWeek:
            return "Complete all habits for 7 consecutive days"
        case .habitVariety(let count):
            return "Have \(count) different active habits"
        case .earlyBird:
            return "Complete habits before 9 AM for 7 days"
        case .nightOwl:
            return "Complete habits after 9 PM for 7 days"
        case .weekendWarrior:
            return "Complete habits on weekends for 4 weeks"
        }
    }
}
