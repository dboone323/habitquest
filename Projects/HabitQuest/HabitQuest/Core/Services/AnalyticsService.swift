import SwiftData
import SwiftUI

/// Comprehensive analytics service for tracking habit performance and user insights
/// Now acts as an orchestrator for specialized analytics services
@Observable
final class AnalyticsService {
    private let modelContext: ModelContext
    private let aggregatorService: AnalyticsAggregatorService
    private let trendAnalysisService: TrendAnalysisService
    private let categoryInsightsService: CategoryInsightsService
    private let productivityMetricsService: ProductivityMetricsService

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.trendAnalysisService = TrendAnalysisService(modelContext: modelContext)
        self.categoryInsightsService = CategoryInsightsService(modelContext: modelContext)
        self.productivityMetricsService = ProductivityMetricsService(modelContext: modelContext)
        self.aggregatorService = AnalyticsAggregatorService(
            modelContext: modelContext,
            trendAnalysisService: self.trendAnalysisService,
            categoryInsightsService: self.categoryInsightsService,
            productivityMetricsService: self.productivityMetricsService
        )
    }

    // MARK: - Core Analytics Data

    /// Get comprehensive analytics data
    func getAnalytics() async -> HabitAnalytics {
        await self.aggregatorService.getAnalytics()
    }

    // MARK: - Specific Analytics Queries

    /// Get habit trends for specific habit
    func getHabitTrends(for habitId: UUID, days: Int = 30) async -> HabitTrendData {
        await self.trendAnalysisService.getHabitTrends(for: habitId, days: days)
    }

    /// Get insights for all habit categories
    func getCategoryInsights() async -> [CategoryInsight] {
        await self.categoryInsightsService.getCategoryInsights()
    }

    /// Get productivity metrics for a time period
    func getProductivityMetrics(for period: TimePeriod) async -> ProductivityMetrics {
        await self.productivityMetricsService.getProductivityMetrics(for: period)
    }

    /// Get detailed category performance
    func getCategoryPerformance(category: HabitCategory) async -> CategoryPerformance {
        await self.categoryInsightsService.getCategoryPerformance(category: category)
    }

    /// Get category distribution
    func getCategoryDistribution() async -> [HabitCategory: Int] {
        await self.categoryInsightsService.getCategoryDistribution()
    }

    /// Calculate productivity score
    func calculateProductivityScore() async -> ProductivityScore {
        await self.productivityMetricsService.calculateProductivityScore()
    }

    /// Get productivity insights
    func getProductivityInsights() async -> ProductivityInsights {
        await self.productivityMetricsService.getProductivityInsights()
    }

    /// Calculate productivity trends
    func calculateProductivityTrends(days: Int = 30) async -> ProductivityTrends {
        await self.productivityMetricsService.calculateProductivityTrends(days: days)
    }
}

// MARK: - Supporting Types

public struct HabitAnalytics {
    public let overallStats: OverallStats
    public let streakAnalytics: AnalyticsStreakData
    public let categoryBreakdown: [CategoryStats]
    public let moodCorrelation: MoodCorrelation
    public let timePatterns: TimePatterns
    public let weeklyProgress: WeeklyProgress
    public let monthlyTrends: [MonthlyTrend]
    public let habitPerformance: [HabitPerformance]

    public static var empty: HabitAnalytics {
        HabitAnalytics(
            overallStats: OverallStats(
                totalHabits: 0,
                activeHabits: 0,
                totalCompletions: 0,
                completionRate: 0.0,
                totalXPEarned: 0,
                averageStreak: 0
            ),
            streakAnalytics: AnalyticsStreakData(
                currentStreaks: [],
                longestStreak: 0,
                averageStreak: 0,
                activeStreaks: 0
            ),
            categoryBreakdown: [],
            moodCorrelation: MoodCorrelation(
                moodStats: [],
                strongestCorrelation: .neutral
            ),
            timePatterns: TimePatterns(
                peakHours: 0,
                hourlyDistribution: [:],
                weekdayPatterns: [:]
            ),
            weeklyProgress: WeeklyProgress(
                completedHabits: 0,
                totalOpportunities: 0,
                xpEarned: 0,
                dailyBreakdown: [:]
            ),
            monthlyTrends: [],
            habitPerformance: []
        )
    }
}

public struct OverallStats {
    public let totalHabits: Int
    public let activeHabits: Int
    public let totalCompletions: Int
    public let completionRate: Double
    public let totalXPEarned: Int
    public let averageStreak: Int
}

public struct AnalyticsStreakData {
    public let currentStreaks: [Int]
    public let longestStreak: Int
    public let averageStreak: Int
    public let activeStreaks: Int
}

public struct CategoryStats {
    public let category: HabitCategory
    public let habitCount: Int
    public let completionRate: Double
    public let totalXP: Int
}

public struct MoodCorrelation {
    public let moodStats: [MoodStats]
    public let strongestCorrelation: MoodRating
}

public struct MoodStats {
    public let mood: MoodRating
    public let completionRate: Double
    public let averageXP: Int
}

public struct TimePatterns {
    public let peakHours: Int
    public let hourlyDistribution: [Int: Int]
    public let weekdayPatterns: [Int: Int]
}

public struct WeeklyProgress {
    public let completedHabits: Int
    public let totalOpportunities: Int
    public let xpEarned: Int
    public let dailyBreakdown: [String: Int]
}

public struct MonthlyTrend {
    public let month: Int
    public let completions: Int
    public let xpEarned: Int
    public let averageDaily: Double
}

public struct HabitPerformance {
    public let habitId: UUID
    public let habitName: String
    public let completionRate: Double
    public let currentStreak: Int
    public let xpEarned: Int
    public let trend: HabitTrend
}

public struct HabitTrendData {
    public let habitId: UUID
    public let completionRates: [Double]
    public let streaks: [Int]
    public let xpEarned: [Int]
}

public struct CategoryInsight {
    public let category: HabitCategory
    public let totalHabits: Int
    public let completionRate: Double
    public let averageStreak: Int
    public let totalXPEarned: Int
}

public enum HabitTrend: String, Codable {
    case improving
    case stable
    case declining
}
