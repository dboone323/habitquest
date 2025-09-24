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

enum TimePeriod {
    case week, month, quarter, year

    var startDate: Date {
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

    var dayCount: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .quarter: 90
        case .year: 365
        }
    }
}

struct HabitAnalytics {
    let overallStats: OverallStats
    let streakAnalytics: AnalyticsStreakData
    let categoryBreakdown: [CategoryStats]
    let moodCorrelation: MoodCorrelation
    let timePatterns: TimePatterns
    let weeklyProgress: WeeklyProgress
    let monthlyTrends: [MonthlyTrend]
    let habitPerformance: [HabitPerformance]

    static var empty: HabitAnalytics {
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

struct OverallStats {
    let totalHabits: Int
    let activeHabits: Int
    let totalCompletions: Int
    let completionRate: Double
    let totalXPEarned: Int
    let averageStreak: Int
}

struct AnalyticsStreakData {
    let currentStreaks: [Int]
    let longestStreak: Int
    let averageStreak: Int
    let activeStreaks: Int
}

struct CategoryStats {
    let category: HabitCategory
    let habitCount: Int
    let completionRate: Double
    let totalXP: Int
}

struct MoodCorrelation {
    let moodStats: [MoodStats]
    let strongestCorrelation: MoodRating
}

struct MoodStats {
    let mood: MoodRating
    let completionRate: Double
    let averageXP: Int
}

struct TimePatterns {
    let peakHours: Int
    let hourlyDistribution: [Int: Int]
    let weekdayPatterns: [Int: Int]
}

struct WeeklyProgress {
    let completedHabits: Int
    let totalOpportunities: Int
    let xpEarned: Int
    let dailyBreakdown: [String: Int]
}

struct MonthlyTrend {
    let month: Int
    let completions: Int
    let xpEarned: Int
    let averageDaily: Double
}

struct HabitPerformance {
    let habitId: UUID
    let habitName: String
    let completionRate: Double
    let currentStreak: Int
    let xpEarned: Int
    let trend: HabitTrend
}

struct HabitTrendData {
    let habitId: UUID
    let completionRates: [Double]
    let streaks: [Int]
    let xpEarned: [Int]
}

struct CategoryInsight {
    let category: HabitCategory
    let totalHabits: Int
    let completionRate: Double
    let averageStreak: Int
    let totalXPEarned: Int
}

struct ProductivityMetrics {
    let period: TimePeriod
    let completionRate: Double
    let streakCount: Int
    let xpEarned: Int
    let missedOpportunities: Int
}

public enum HabitTrend: String {
    case improving
    case stable
    case declining
}
