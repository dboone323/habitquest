import Foundation
import SwiftUI
import SwiftData

// MARK: - Health Models

/// User baseline data and health goals
@Model
public final class HealthProfile {
    public var id: UUID
    public var name: String
    public var dateOfBirth: Date
    public var gender: String
    public var heightInMeters: Double
    public var targetWeightInKg: Double
    public var dailyStepGoal: Int
    public var dailyCalorieGoal: Int
    
    public init(
        id: UUID = UUID(),
        name: String = "User",
        dateOfBirth: Date = Date(),
        gender: String = "Prefer not to say",
        heightInMeters: Double = 1.75,
        targetWeightInKg: Double = 80.0,
        dailyStepGoal: Int = 10000,
        dailyCalorieGoal: Int = 2500
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.heightInMeters = heightInMeters
        self.targetWeightInKg = targetWeightInKg
        self.dailyStepGoal = dailyStepGoal
        self.dailyCalorieGoal = dailyCalorieGoal
    }
}

/// Snapshot entries for physiological metrics
@Model
public final class HealthVitals {
    public var id: UUID
    public var timestamp: Date
    public var type: VitalType
    public var value: Double
    public var unit: String
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: VitalType = .heartRate,
        value: Double = 0.0,
        unit: String = "bpm"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.value = value
        self.unit = unit
    }
}

public enum VitalType: String, Codable, Sendable {
    case heartRate = "heart_rate"
    case bloodPressureSystolic = "bp_systolic"
    case bloodPressureDiastolic = "bp_diastolic"
    case bloodSugar = "blood_sugar"
    case bodyTemperature = "temperature"
    case oxygenSaturation = "sp_o2"
}

/// Logged physical activities and daily movement
@Model
public final class HealthActivity {
    public var id: UUID
    public var timestamp: Date
    public var activityType: String
    public var durationInMinutes: Double
    public var caloriesBurned: Int
    public var stepsTaken: Int
    public var distanceInMeters: Double
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        activityType: String = "General",
        durationInMinutes: Double = 0.0,
        caloriesBurned: Int = 0,
        stepsTaken: Int = 0,
        distanceInMeters: Double = 0.0
    ) {
        self.id = id
        self.timestamp = timestamp
        self.activityType = activityType
        self.durationInMinutes = durationInMinutes
        self.caloriesBurned = caloriesBurned
        self.stepsTaken = stepsTaken
        self.distanceInMeters = distanceInMeters
    }
}

/// Nutrition tracking and caloric intake
@Model
public final class HealthNutrition {
    public var id: UUID
    public var timestamp: Date
    public var mealType: String
    public var calories: Int
    public var proteinInGrams: Double
    public var carbsInGrams: Double
    public var fatInGrams: Double
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        mealType: String = "Snack",
        calories: Int = 0,
        proteinInGrams: Double = 0.0,
        carbsInGrams: Double = 0.0,
        fatInGrams: Double = 0.0
    ) {
        self.id = id
        self.timestamp = timestamp
        self.mealType = mealType
        self.calories = calories
        self.proteinInGrams = proteinInGrams
        self.carbsInGrams = carbsInGrams
        self.fatInGrams = fatInGrams
    }
}

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
    /// Number of streak freezes consumed to bridge the gap leading into this completion.
    public var freezesConsumed: Int

    /// The associated habit for this log entry.
    public var habit: Habit?

    public init(
        habit: Habit,
        completionDate: Date = Date(),
        isCompleted: Bool = true,
        notes: String? = nil,
        mood: MoodRating? = nil,
        freezesConsumed: Int = 0
    ) {
        id = UUID()
        self.habit = habit
        self.completionDate = completionDate
        self.isCompleted = isCompleted
        self.notes = notes
        xpEarned = isCompleted ? habit.xpValue * habit.difficulty.xpMultiplier : 0
        self.mood = mood
        completionTime = isCompleted ? Date() : nil
        self.freezesConsumed = freezesConsumed
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
    /// Streak freezes currently in player inventory.
    public var streakFreezes: Int
    /// When this profile was created.
    public var creationDate: Date

    /// Normalized progress towards the next level (0.0 - 1.0).
    public var xpProgress: Float {
        let currentThreshold = Double(Int(100 * pow(1.5, Double(level - 1))))
        let nextThreshold = Double(xpForNextLevel)
        let progressRange = nextThreshold - currentThreshold
        guard progressRange > 0 else { return 0.0 }
        return Float((Double(currentXP) - currentThreshold) / progressRange)
    }

    public init() {
        level = 1
        currentXP = 0
        xpForNextLevel = 100
        longestStreak = 0
        streakFreezes = 0
        creationDate = Date()
    }
}

/// Configuration for streak forgiveness and grace period
public enum StreakForgivenessConfig {
    public static let defaultThreshold: Int = 5
    public static let thresholdKey = "streakForgivenessThreshold"

    public static var threshold: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: thresholdKey)
            return val > 0 ? val : defaultThreshold
        }
        set {
            UserDefaults.standard.set(newValue, forKey: thresholdKey)
        }
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

    public var color: Color {
        switch self {
        case .health: .red
        case .fitness: .orange
        case .learning: .blue
        case .productivity: .green
        case .social: .purple
        case .creativity: .yellow
        case .mindfulness: .indigo
        case .other: .gray
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
    case general, streak, completion, level, consistency, special, hidden
    
    public var color: Color {
        switch self {
        case .general: return .blue
        case .streak: return .orange
        case .completion: return .green
        case .level: return .indigo
        case .consistency: return .teal
        case .special: return .purple
        case .hidden: return .gray
        }
    }
    public var displayName: String {
        switch self {
        case .streak: return "Streak Master"
        case .completion: return "Quest Completion"
        case .level: return "Level Progression"
        case .consistency: return "Consistency"
        case .general: return "General"
        case .special: return "Special Events"
        case .hidden: return "Hidden"
        }
    }
}

public enum AchievementRequirement: Codable, Sendable {
    case streakDays(Int), totalCompletions(Int), reachLevel(Int), perfectWeek, habitVariety(Int), earlyBird, nightOwl, weekendWarrior
    
    public var description: String {
        switch self {
        case .streakDays(let count): return "Maintain a \(count) day streak"
        case .totalCompletions(let count): return "Complete habits \(count) times"
        case .reachLevel(let level): return "Reach level \(level)"
        case .perfectWeek: return "Complete all habits for 7 consecutive days"
        case .habitVariety(let count): return "Complete \(count) different types of habits"
        case .earlyBird: return "Complete a habit before 8 AM"
        case .nightOwl: return "Complete a habit after 10 PM"
        case .weekendWarrior: return "Complete habits on both Saturday and Sunday"
        }
    }
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
        
        public var particleCount: Int {
            switch self {
            case .basic: 10
            case .intermediate: 25
            case .advanced: 50
            case .epic: 75
            case .legendary: 100
            }
        }
        
        public var animationIntensity: Double {
            switch self {
            case .basic: 0.5
            case .intermediate: 0.75
            case .advanced: 1.0
            case .epic: 1.25
            case .legendary: 1.5
            }
        }
    }

    public static func milestone(for count: Int) -> StreakMilestone {
        let all = allMilestones.sorted(by: { $0.streakCount > $1.streakCount })
        return all.first(where: { count >= $0.streakCount }) ?? allMilestones[0]
    }

    public static var predefinedMilestones: [StreakMilestone] { allMilestones }

    public static func isNewMilestone(streakCount: Int, previousCount: Int) -> Bool {
        let all = allMilestones.sorted(by: { $0.streakCount > $1.streakCount })
        let currentStreakCount = all.first(where: { streakCount >= $0.streakCount })?.streakCount ?? 0
        let prevStreakCount = all.first(where: { previousCount >= $0.streakCount })?.streakCount ?? 0
        return currentStreakCount > prevStreakCount
    }

    public static func nextMilestone(for count: Int) -> StreakMilestone? {
        let all = allMilestones.sorted(by: { $0.streakCount < $1.streakCount })
        return all.first(where: { $0.streakCount > count })
    }

    public static var allMilestones: [StreakMilestone] {
        [
            StreakMilestone(streakCount: 3, title: "Getting Started", description: "3 day streak", emoji: "🔥", celebrationLevel: .basic),
            StreakMilestone(streakCount: 7, title: "One Week Warrior", description: "7 day streak", emoji: "📈", celebrationLevel: .intermediate),
            StreakMilestone(streakCount: 14, title: "Consistent", description: "14 day streak", emoji: "🚀", celebrationLevel: .intermediate),
            StreakMilestone(streakCount: 30, title: "Monthly Master", description: "30 day streak", emoji: "🏆", celebrationLevel: .advanced),
            StreakMilestone(streakCount: 50, title: "Half Century", description: "50 day streak", emoji: "⚡️", celebrationLevel: .advanced),
            StreakMilestone(streakCount: 100, title: "Century Club", description: "100 day streak", emoji: "👑", celebrationLevel: .epic),
            StreakMilestone(streakCount: 365, title: "Year of Dedication", description: "365 day streak", emoji: "🌟", celebrationLevel: .legendary)
        ]
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

/// Structured behavioral profile of a user based on their habit history.
public struct UserProfile {
    public let existingHabits: [Habit]
    public let averageConsistency: Double
    public let peakProductivityHour: Int
    public let preferredCategories: [HabitCategory]

    public init(existingHabits: [Habit], averageConsistency: Double, peakProductivityHour: Int, preferredCategories: [HabitCategory]) {
        self.existingHabits = existingHabits
        self.averageConsistency = averageConsistency
        self.peakProductivityHour = peakProductivityHour
        self.preferredCategories = preferredCategories
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



