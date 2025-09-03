import Foundation

// Supporting types for analytics extracted to reduce AdvancedAnalyticsEngine file size
struct HabitPatterns {
    let consistency: Double
    let momentum: Double
    let volatility: Double
    let weekdayPreference: Int
    let timePreference: Int
}

struct TimeFactors {
    let currentHourSuccessRate: Double
    let currentDaySuccessRate: Double
    let timesSinceLastCompletion: TimeInterval
    let optimalTimeWindow: ClosedRange<Int>
}

struct StreakMomentum {
    let weeklyMomentum: Double
    let longestRecentStreak: Int
    let acceleration: Double
}

struct SchedulingRecommendation {
    let optimalTime: Int
    let successRateAtTime: Double
    let reasoning: String
    let alternativeTimes: [Int]
}

struct BehavioralInsights {
    let moodCorrelation: Double
    let strongestDays: [String]
    let weakestDays: [String]
    let streakBreakFactors: [String]
    let motivationTriggers: [String]
    let personalityInsights: [String]
}

struct HabitSuggestion {
    let name: String
    let description: String
    let category: HabitCategory
    let difficulty: HabitDifficulty
    let reasoning: String
    let expectedSuccess: Double
}
