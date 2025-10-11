import Foundation
import SwiftData

// MARK: - Model Types (simplified for analytics)

// Simplified Habit model for analytics
public struct AnalyticsHabit {
    public let id: UUID
    public let name: String
    public let category: AnalyticsHabitCategory
    public let difficulty: AnalyticsHabitDifficulty
    public let streak: Int
    public let logs: [AnalyticsHabitLog]
}

// Simplified HabitLog model for analytics
public struct AnalyticsHabitLog {
    public let id: UUID
    public let completionDate: Date
    public let isCompleted: Bool
    public let xpEarned: Int
}

// MARK: - Enums

public enum AnalyticsHabitCategory: String, CaseIterable, Codable {
    case health, fitness, learning, productivity, social, creativity, mindfulness, other
}

public enum AnalyticsHabitDifficulty: String, CaseIterable, Codable {
    case easy, medium, hard
}

// MARK: - Time Period

public enum TimePeriod {
    case week, month, quarter, year

    public var startDate: Date {
        let calendar = Calendar.current
        switch self {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .quarter:
            return calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        }
    }

    public var dayCount: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .quarter: 90
        case .year: 365
        }
    }
}

// MARK: - Productivity Metrics

public struct ProductivityMetrics {
    public let period: TimePeriod
    public let completionRate: Double
    public let streakCount: Int
    public let xpEarned: Int
    public let missedOpportunities: Int
}

// MARK: - Productivity Score

public struct ProductivityScore {
    public let overallScore: Double
    public let completionRate: Double
    public let streakHealth: Double
    public let diversityScore: Double
    public let momentumScore: Double
    public let recommendations: [String]
}

// MARK: - Productivity Insights

public struct ProductivityInsights {
    public let currentScore: ProductivityScore
    public let weeklyCompletionRate: Double
    public let activeStreaks: Int
    public let xpEarnedThisWeek: Int
    public let topPerformingCategories: [AnalyticsHabitCategory]
    public let improvementAreas: [ProductivityArea]
    public let nextMilestones: [ProductivityMilestone]
}

// MARK: - Productivity Trends

public struct ProductivityTrends {
    public let dailyScores: [Double]
    public let trend: ProductivityTrend
    public let averageScore: Double
    public let bestDay: Double
    public let consistencyScore: Double
}

// MARK: - Enums

public enum ProductivityTrend {
    case improving
    case stable
    case declining
}

public enum ProductivityArea {
    case consistency
    case streaks
    case diversity
    case momentum
}

// MARK: - Productivity Milestone

public struct ProductivityMilestone {
    public let type: MilestoneType
    public let currentValue: Int
    public let targetValue: Int
    public let description: String
}

public enum MilestoneType {
    case totalCompletions
    case longestStreak
}

// MARK: - Prediction Types

public struct SchedulingRecommendation {
    public let optimalTime: Int
    public let successRateAtTime: Double
    public let reasoning: String
    public let alternativeTimes: [Int]
}

// MARK: - Pattern Analysis Types

public struct HabitPatterns {
    public let consistency: Double
    public let momentum: Double
    public let volatility: Double
    public let weekdayPreference: Int
    public let timePreference: [String]

    public init(consistency: Double, momentum: Double, volatility: Double, weekdayPreference: Int, timePreference: [String]) {
        self.consistency = consistency
        self.momentum = momentum
        self.volatility = volatility
        self.weekdayPreference = weekdayPreference
        self.timePreference = timePreference
    }
}

public struct TimeFactors {
    public let currentHourSuccessRate: Double
    public let currentDaySuccessRate: Double
    public let timesSinceLastCompletion: TimeInterval
    public let optimalTimeWindow: ClosedRange<Int>

    public init(
        currentHourSuccessRate: Double,
        currentDaySuccessRate: Double,
        timesSinceLastCompletion: TimeInterval,
        optimalTimeWindow: ClosedRange<Int>
    ) {
        self.currentHourSuccessRate = currentHourSuccessRate
        self.currentDaySuccessRate = currentDaySuccessRate
        self.timesSinceLastCompletion = timesSinceLastCompletion
        self.optimalTimeWindow = optimalTimeWindow
    }
}

public struct StreakMomentum {
    public let weeklyMomentum: Double
    public let longestRecentStreak: Int
    public let acceleration: Double

    public init(weeklyMomentum: Double, longestRecentStreak: Int, acceleration: Double) {
        self.weeklyMomentum = weeklyMomentum
        self.longestRecentStreak = longestRecentStreak
        self.acceleration = acceleration
    }
}

// MARK: - Behavioral Insights Types

public struct BehavioralInsights {
    public let moodCorrelation: Double
    public let motivationTriggers: [String]
    public let commonBreakPoints: [String]
    public let personalityInsights: [String]
    public let recommendations: [String]
}

// MARK: - Habit Suggestion Types

public struct AnalyticsHabitSuggestion: Identifiable {
    public let id: UUID
    public let name: String
    public let description: String
    public let category: AnalyticsHabitCategory
    public let difficulty: AnalyticsHabitDifficulty
    public let reasoning: String
    public let expectedSuccess: Double

    public init(name: String, description: String, category: AnalyticsHabitCategory, difficulty: AnalyticsHabitDifficulty, reasoning: String, expectedSuccess: Double) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.reasoning = reasoning
        self.expectedSuccess = expectedSuccess
    }
}

public struct UserProfile {
    public let existingHabits: [AnalyticsHabit]
    public let averageConsistency: Double
    public let peakProductivityHour: Int
    public let preferredCategories: [AnalyticsHabitCategory]
}
