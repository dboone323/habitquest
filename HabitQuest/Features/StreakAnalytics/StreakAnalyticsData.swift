import Foundation
import SwiftData
import SwiftUI

/// Data structures for streak analytics
struct StreakAnalyticsData {
    let totalActiveStreaks: Int
    let longestOverallStreak: Int
    let averageConsistency: Double
    let milestonesAchieved: Int
    let streakDistribution: [StreakDistributionData]
    let topPerformingHabits: [TopPerformer]
    let consistencyInsights: [ConsistencyInsight]
    let weeklyPatterns: [WeeklyPattern]
}

struct TopPerformer {
    let habit: Habit
    let currentStreak: Int
    let longestStreak: Int
    let consistency: Double
}

struct StreakDistributionData {
    let range: String
    let count: Int
}

struct ConsistencyInsight {
    let title: String
    let description: String
    let type: InsightType

    enum InsightType {
        case positive, improvement, neutral

        var color: Color {
            switch self {
            case .positive: .green
            case .improvement: .orange
            case .neutral: .blue
            }
        }

        var icon: String {
            switch self {
            case .positive: "checkmark.circle.fill"
            case .improvement: "exclamationmark.triangle.fill"
            case .neutral: "info.circle.fill"
            }
        }
    }
}

struct WeeklyPattern {
    let day: String
    let completionRate: Double
}
