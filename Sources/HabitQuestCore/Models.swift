import Foundation
import SwiftData

// MARK: - Habit Models

/// Represents a habit that the user wants to track and maintain.
@Model
public final class Habit {
    /// Unique identifier for the habit.
    public var id: UUID
    /// Display name of the habit.
    public var name: String
    /// Detailed description of the habit's purpose.
    public var habitDescription: String
    /// How frequently the habit should be performed.
    public var frequency: HabitFrequency
    /// When the habit was first created.
    public var creationDate: Date
    /// Current experience point value assigned to this habit.
    public var xpValue: Int
    /// Current consecutive days/weeks streak.
    public var streak: Int
    /// Whether the habit is currently active.
    public var isActive: Bool
    /// The category the habit belongs to.
    public var category: HabitCategory
    /// The difficulty level of the habit.
    public var difficulty: HabitDifficulty

    /// The logs associated with this habit.
    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    public var logs: [HabitLog] = []

    public init(
        name: String,
        habitDescription: String,
        frequency: HabitFrequency,
        xpValue: Int = 10,
        category: HabitCategory = .health,
        difficulty: HabitDifficulty = .easy
    ) {
        id = UUID()
        self.name = name
        self.habitDescription = habitDescription
        self.frequency = frequency
        creationDate = Date()
        self.xpValue = xpValue
        streak = 0
        isActive = true
        self.category = category
        self.difficulty = difficulty
    }

    /// Check if habit was completed today
    public var isCompletedToday: Bool {
        guard
            let todaysLog = logs.first(where: { Calendar.current.isDateInToday($0.completionDate) })
        else {
            return false
        }
        return todaysLog.isCompleted
    }

    /// Get completion rate for the last 30 days
    public var completionRate: Double {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentLogs = logs.filter { $0.completionDate >= thirtyDaysAgo }
        guard !recentLogs.isEmpty else { return 0.0 }
        let completedCount = recentLogs.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(recentLogs.count)
    }
}

/// Records a single instance of a habit completion or failure.
@Model
public final class HabitLog {
    /// Unique identifier for the log entry.
    public var id: UUID
    /// The date the habit was supposed to be completed.
    public var completionDate: Date
    /// Whether the habit was completed successfully.
    public var isCompleted: Bool
    /// Optional notes about this completion.
    public var notes: String?
    /// XP earned for this completion (0 if not completed).
    public var xpEarned: Int
    /// Optional mood rating for this completion.
    public var mood: MoodRating?
    /// The exact time the habit was completed (if completed).
    public var completionTime: Date?

    /// The associated habit for this log entry.
    public var habit: Habit?

    public init(
        habit: Habit,
        completionDate: Date = Date(),
        isCompleted: Bool = true,
        notes: String? = nil,
        mood: MoodRating? = nil
    ) {
        id = UUID()
        self.habit = habit
        self.completionDate = completionDate
        self.isCompleted = isCompleted
        self.notes = notes
        xpEarned = isCompleted ? habit.xpValue * habit.difficulty.xpMultiplier : 0
        self.mood = mood
        completionTime = isCompleted ? Date() : nil
    }
}

// MARK: - Player Models

/// Tracks the user's global progress and character stats.
@Model
public final class PlayerProfile {
    /// Current character level (starts at 1).
    public var level: Int
    /// Current experience points accumulated.
    public var currentXP: Int
    /// Experience points needed to reach the next level.
    public var xpForNextLevel: Int
    /// Highest consecutive streak achieved across all habits.
    public var longestStreak: Int
    /// When this profile was created.
    public var creationDate: Date

    public init() {
        level = 1
        currentXP = 0
        xpForNextLevel = 100
        longestStreak = 0
        creationDate = Date()
    }
}

/// Represents an achievement that users can unlock.
@Model
public final class Achievement {
    public var id: UUID
    public var name: String
    public var achievementDescription: String
    public var iconName: String
    public var category: AchievementCategory
    public var xpReward: Int
    public var isHidden: Bool
    public var unlockedDate: Date?
    public var progress: Float
    private var requirementData: Data

    public var requirement: AchievementRequirement {
        get {
            guard let decoded = try? JSONDecoder().decode(AchievementRequirement.self, from: requirementData) else {
                return .totalCompletions(1)
            }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            requirementData = encoded
        }
    }

    public init(
        name: String,
        description: String,
        iconName: String,
        category: AchievementCategory,
        xpReward: Int = 50,
        isHidden: Bool = false,
        requirement: AchievementRequirement
    ) {
        id = UUID()
        self.name = name
        achievementDescription = description
        self.iconName = iconName
        self.category = category
        self.xpReward = xpReward
        self.isHidden = isHidden
        unlockedDate = nil
        progress = 0.0
        guard let encoded = try? JSONEncoder().encode(requirement) else {
            requirementData = Data()
            return
        }
        requirementData = encoded
    }

    public var isUnlocked: Bool { unlockedDate != nil }
    public var progressPercentage: String { String(format: "%.0f%%", progress * 100) }
}

// MARK: - Supporting Types

public enum HabitFrequency: String, CaseIterable, Codable, Sendable {
    case daily, weekly, monthly, custom
    public var displayName: String { rawValue }
}

public enum HabitCategory: String, CaseIterable, Codable, Sendable {
    case health, fitness, learning, productivity, social, creativity, mindfulness, other

    public var emoji: String {
        switch self {
        case .health: "🏥"
        case .fitness: "🏋️‍♀️"
        case .learning: "📚"
        case .productivity: "💼"
        case .social: "👥"
        case .creativity: "🎨"
        case .mindfulness: "🧘‍♀️"
        case .other: "📋"
        }
    }

    public var color: String {
        switch self {
        case .health: "red"
        case .fitness: "orange"
        case .learning: "blue"
        case .productivity: "green"
        case .social: "purple"
        case .creativity: "yellow"
        case .mindfulness: "indigo"
        case .other: "gray"
        }
    }
}

public enum HabitDifficulty: String, CaseIterable, Codable, Sendable {
    case easy, medium, hard
    public var xpMultiplier: Int {
        switch self {
        case .easy: 1
        case .medium: 2
        case .hard: 3
        }
    }
}

public enum MoodRating: String, CaseIterable, Codable, Sendable {
    case terrible = "😞", bad = "😕", okay = "😐", neutral = "😑", good = "😊", excellent = "😄"
    public var value: Int {
        switch self {
        case .terrible: 1
        case .bad: 2
        case .okay, .neutral: 3
        case .good: 4
        case .excellent: 5
        }
    }
}

public enum AchievementCategory: String, CaseIterable, Codable, Sendable {
    case streak, completion, level, consistency, special
    public var displayName: String {
        switch self {
        case .streak: "Streak Master"
        case .completion: "Quest Completion"
        case .level: "Level Progression"
        case .consistency: "Consistency"
        case .special: "Special Events"
        }
    }
}

public enum AchievementRequirement: Codable, Sendable {
    case streakDays(Int), totalCompletions(Int), reachLevel(Int), perfectWeek, habitVariety(Int), earlyBird, nightOwl, weekendWarrior
}

public struct StreakMilestone: Identifiable, Sendable, Comparable {
    public let id: UUID
    public let streakCount: Int
    public let title: String
    public let description: String
    public let emoji: String
    public let celebrationLevel: CelebrationLevel

    public init(streakCount: Int, title: String, description: String, emoji: String, celebrationLevel: CelebrationLevel) {
        id = UUID()
        self.streakCount = streakCount
        self.title = title
        self.description = description
        self.emoji = emoji
        self.celebrationLevel = celebrationLevel
    }

    public enum CelebrationLevel: Int, CaseIterable, Codable, Sendable {
        case basic = 1, intermediate = 2, advanced = 3, epic = 4, legendary = 5
    }

    public static func < (lhs: StreakMilestone, rhs: StreakMilestone) -> Bool {
        lhs.streakCount < rhs.streakCount
    }
}

// MARK: - Analytical Support Types

/// Represents a personalized habit recommendation generated by AI or heuristics.
public struct HabitSuggestion: Codable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let description: String
    public let category: HabitCategory
    public let difficulty: HabitDifficulty
    public let reasoning: String
    public let expectedSuccess: Double

    public init(name: String, description: String, category: HabitCategory, difficulty: HabitDifficulty, reasoning: String, expectedSuccess: Double) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.reasoning = reasoning
        self.expectedSuccess = expectedSuccess
    }
}

/// Aggregated insight about a user's behavioral patterns.
public struct HabitInsight: Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let description: String
    public let impact: InsightImpact
    public let suggestion: String?

    public init(title: String, description: String, impact: InsightImpact, suggestion: String? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.impact = impact
        self.suggestion = suggestion
    }

    public enum InsightImpact: String, Sendable, Codable {
        case positive, negative, neutral
    }
}

// MARK: - Notification Support Types

/// Contextual states for habits that trigger specialized notifications.
public enum HabitContext: String, Sendable, Codable {
    case normal
    case optimalTime
    case streakAtRisk
    case milestoneApproaching
    case lowEngagement
}

/// Potential risk to habit consistency.
public enum RiskLevel: String, Sendable, Codable {
    case low, medium, high
}

/// Aggregated contextual analysis for a single habit.
public struct ContextualInsights: Sendable {
    public let currentContext: HabitContext
    public let riskLevel: RiskLevel
    
    public init(currentContext: HabitContext, riskLevel: RiskLevel) {
        self.currentContext = currentContext
        self.riskLevel = riskLevel
    }
}

// MARK: - Data Support Types

/// A preset habit configuration used for easy creation and discovery.
public struct HabitTemplate: Identifiable, Sendable, Codable {
    public let id: UUID
    public let name: String
    public let habitDescription: String
    public let category: HabitCategory
    public let frequency: HabitFrequency
    public let difficulty: HabitDifficulty
    public let xpValue: Int

    public init(name: String, description: String, category: HabitCategory, frequency: HabitFrequency, difficulty: HabitDifficulty, xpValue: Int) {
        self.id = UUID()
        self.name = name
        self.habitDescription = description
        self.category = category
        self.frequency = frequency
        self.difficulty = difficulty
        self.xpValue = xpValue
    }
}



