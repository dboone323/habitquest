import SwiftData
import SwiftUI

/// Service responsible for aggregating comprehensive analytics data
final class AnalyticsAggregatorService {
    private let modelContext: ModelContext
    private let trendAnalysisService: TrendAnalysisService
    private let categoryInsightsService: CategoryInsightsService
    private let productivityMetricsService: ProductivityMetricsService

    init(
        modelContext: ModelContext,
        trendAnalysisService: TrendAnalysisService,
        categoryInsightsService: CategoryInsightsService,
        productivityMetricsService: ProductivityMetricsService
    ) {
        self.modelContext = modelContext
        self.trendAnalysisService = trendAnalysisService
        self.categoryInsightsService = categoryInsightsService
        self.productivityMetricsService = productivityMetricsService
    }

    /// Get comprehensive analytics data
    func getAnalytics() async -> HabitAnalytics {
        let habits = await fetchAllHabits()
        let logs = await fetchAllLogs()

        return await HabitAnalytics(
            overallStats: self.calculateOverallStats(habits: habits, logs: logs),
            streakAnalytics: self.calculateStreakAnalytics(habits: habits),
            categoryBreakdown: self.categoryInsightsService.calculateCategoryBreakdown(habits: habits),
            moodCorrelation: self.calculateMoodCorrelation(logs: logs),
            timePatterns: self.calculateTimePatterns(logs: logs),
            weeklyProgress: self.trendAnalysisService.calculateWeeklyProgress(logs: logs),
            monthlyTrends: self.trendAnalysisService.calculateMonthlyTrends(logs: logs),
            habitPerformance: self.calculateHabitPerformance(habits: habits)
        )
    }

    // MARK: - Private Methods

    private func fetchAllHabits() async -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        return (try? self.modelContext.fetch(descriptor)) ?? []
    }

    private func fetchAllLogs() async -> [HabitLog] {
        let descriptor = FetchDescriptor<HabitLog>()
        return (try? self.modelContext.fetch(descriptor)) ?? []
    }

    private func calculateOverallStats(habits: [Habit], logs: [HabitLog]) -> OverallStats {
        let completedLogs = logs.filter(\.isCompleted)
        let totalCompletions = completedLogs.count
        let completionRate = Double(totalCompletions) / Double(max(logs.count, 1))

        return OverallStats(
            totalHabits: habits.count,
            activeHabits: habits.filter(\.isActive).count,
            totalCompletions: totalCompletions,
            completionRate: completionRate,
            totalXPEarned: completedLogs.reduce(0) { $0 + $1.xpEarned },
            averageStreak: habits.reduce(0) { $0 + $1.streak } / max(habits.count, 1)
        )
    }

    private func calculateStreakAnalytics(habits: [Habit]) -> AnalyticsStreakData {
        let streaks = habits.map(\.streak)
        return AnalyticsStreakData(
            currentStreaks: streaks,
            longestStreak: streaks.max() ?? 0,
            averageStreak: streaks.reduce(0, +) / max(streaks.count, 1),
            activeStreaks: streaks.count(where: { $0 > 0 })
        )
    }

    private func calculateMoodCorrelation(logs: [HabitLog]) -> MoodCorrelation {
        let moodGroups = Dictionary(grouping: logs.filter { $0.mood != nil }) { $0.mood! }
        let moodStats = moodGroups.mapValues { logs in
            MoodStats(
                mood: logs.first?.mood ?? .okay,
                completionRate: Double(logs.filter(\.isCompleted).count) / Double(max(logs.count, 1)),
                averageXP: logs.filter(\.isCompleted).reduce(0) { $0 + $1.xpEarned } / max(
                    logs.filter(\.isCompleted).count,
                    1
                )
            )
        }

        return MoodCorrelation(
            moodStats: Array(moodStats.values),
            strongestCorrelation: moodStats.values.max { $0.completionRate < $1.completionRate }?.mood ?? .okay
        )
    }

    private func calculateTimePatterns(logs: [HabitLog]) -> TimePatterns {
        let hourGroups = Dictionary(grouping: logs) {
            Calendar.current.component(.hour, from: $0.completionDate)
        }

        return TimePatterns(
            peakHours: hourGroups.max { $0.value.count < $1.value.count }?.key ?? 12,
            hourlyDistribution: hourGroups.mapValues { $0.count },
            weekdayPatterns: self.calculateWeekdayPatterns(logs: logs)
        )
    }

    private func calculateWeekdayPatterns(logs: [HabitLog]) -> [Int: Int] {
        let weekdayGroups = Dictionary(grouping: logs) {
            Calendar.current.component(.weekday, from: $0.completionDate)
        }
        return weekdayGroups.mapValues { $0.count }
    }

    private func calculateHabitPerformance(habits: [Habit]) async -> [HabitPerformance] {
        // Since all services are MainActor-isolated, process sequentially on main actor
        var performances: [HabitPerformance] = []

        for habit in habits {
            // Extract all data needed for processing
            let habitId = habit.id
            let habitName = habit.name
            let currentStreak = habit.streak
            let habitLogs = Array(habit.logs) // Create a copy of the logs

            let completedLogs = habitLogs.filter(\.isCompleted)
            let trends = await trendAnalysisService.calculateHabitTrends(logs: habitLogs)

            let performance = HabitPerformance(
                habitId: habitId,
                habitName: habitName,
                completionRate: Double(completedLogs.count) / Double(max(habitLogs.count, 1)),
                currentStreak: currentStreak,
                xpEarned: completedLogs.reduce(0) { $0 + $1.xpEarned },
                trend: trends
            )

            performances.append(performance)
        }

        return performances
    }
}
