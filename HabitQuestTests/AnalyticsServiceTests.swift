import XCTest
@testable import HabitQuest

@MainActor
final class AnalyticsServiceTests: XCTestCase {
    // MARK: - enumTimePeriod{ Tests

    func testTimePeriodInitialization() {
        // Given - TimePeriod is an enum with 4 cases
        // When - Access all enum cases
        let week = TimePeriod.week
        let month = TimePeriod.month
        let quarter = TimePeriod.quarter
        let year = TimePeriod.year

        // Then - All cases should be accessible
        XCTAssertNotNil(week)
        XCTAssertNotNil(month)
        XCTAssertNotNil(quarter)
        XCTAssertNotNil(year)
    }

    func testTimePeriodProperties() {
        // Given - Test dayCount property for each period

        // Then - Verify day counts
        XCTAssertEqual(TimePeriod.week.dayCount, 7)
        XCTAssertEqual(TimePeriod.month.dayCount, 30)
        XCTAssertEqual(TimePeriod.quarter.dayCount, 90)
        XCTAssertEqual(TimePeriod.year.dayCount, 365)
    }

    func testTimePeriodMethods() {
        // Given - Test startDate calculation
        let now = Date()
        let calendar = Calendar.current

        // When - Get start dates for each period
        let weekStart = TimePeriod.week.startDate
        let monthStart = TimePeriod.month.startDate
        let quarterStart = TimePeriod.quarter.startDate
        let yearStart = TimePeriod.year.startDate

        // Then - Verify dates are in the past
        XCTAssertLessThan(weekStart, now)
        XCTAssertLessThan(monthStart, now)
        XCTAssertLessThan(quarterStart, now)
        XCTAssertLessThan(yearStart, now)

        // Verify approximate day differences (allowing for some tolerance)
        let weekDiff = calendar.dateComponents([.day], from: weekStart, to: now).day ?? 0
        let monthDiff = calendar.dateComponents([.day], from: monthStart, to: now).day ?? 0
        let quarterDiff = calendar.dateComponents([.day], from: quarterStart, to: now).day ?? 0
        let yearDiff = calendar.dateComponents([.day], from: yearStart, to: now).day ?? 0

        XCTAssertGreaterThanOrEqual(weekDiff, 6)
        XCTAssertLessThanOrEqual(weekDiff, 8)
        XCTAssertGreaterThanOrEqual(monthDiff, 29)
        XCTAssertLessThanOrEqual(monthDiff, 32)
        XCTAssertGreaterThanOrEqual(quarterDiff, 89)
        XCTAssertLessThanOrEqual(quarterDiff, 92)
        XCTAssertGreaterThanOrEqual(yearDiff, 364)
        XCTAssertLessThanOrEqual(yearDiff, 366)
    }

    // MARK: - structHabitAnalytics{ Tests

    func testHabitAnalyticsInitialization() {
        // Given
        let overallStats = OverallStats(
            totalHabits: 5,
            activeHabits: 3,
            totalCompletions: 100,
            completionRate: 0.75,
            totalXPEarned: 500,
            averageStreak: 7
        )
        let streakData = AnalyticsStreakData(
            currentStreaks: [3, 5, 7],
            longestStreak: 10,
            averageStreak: 5,
            activeStreaks: 3
        )
        let categoryBreakdown: [CategoryStats] = []
        let moodCorrelation = MoodCorrelation(moodStats: [], strongestCorrelation: .neutral)
        let timePatterns = TimePatterns(peakHours: 9, hourlyDistribution: [:], weekdayPatterns: [:])
        let weeklyProgress = WeeklyProgress(
            completedHabits: 20,
            totalOpportunities: 30,
            xpEarned: 200,
            dailyBreakdown: [:]
        )
        let monthlyTrends: [MonthlyTrend] = []
        let habitPerformance: [HabitPerformance] = []

        // When
        let analytics = HabitAnalytics(
            overallStats: overallStats,
            streakAnalytics: streakData,
            categoryBreakdown: categoryBreakdown,
            moodCorrelation: moodCorrelation,
            timePatterns: timePatterns,
            weeklyProgress: weeklyProgress,
            monthlyTrends: monthlyTrends,
            habitPerformance: habitPerformance
        )

        // Then
        XCTAssertEqual(analytics.overallStats.totalHabits, 5)
        XCTAssertEqual(analytics.streakAnalytics.longestStreak, 10)
        XCTAssertEqual(analytics.weeklyProgress.completedHabits, 20)
    }

    func testHabitAnalyticsProperties() {
        // Given - Test the empty static property
        let empty = HabitAnalytics.empty

        // Then - Verify all properties are zeroed out
        XCTAssertEqual(empty.overallStats.totalHabits, 0)
        XCTAssertEqual(empty.overallStats.activeHabits, 0)
        XCTAssertEqual(empty.overallStats.totalCompletions, 0)
        XCTAssertEqual(empty.overallStats.completionRate, 0.0)
        XCTAssertEqual(empty.overallStats.totalXPEarned, 0)
        XCTAssertEqual(empty.overallStats.averageStreak, 0)
        XCTAssertEqual(empty.streakAnalytics.longestStreak, 0)
        XCTAssertEqual(empty.streakAnalytics.averageStreak, 0)
        XCTAssertEqual(empty.streakAnalytics.activeStreaks, 0)
        XCTAssertTrue(empty.categoryBreakdown.isEmpty)
        XCTAssertTrue(empty.monthlyTrends.isEmpty)
        XCTAssertTrue(empty.habitPerformance.isEmpty)
    }

    func testHabitAnalyticsMethods() {
        // Given - HabitAnalytics is a struct with no methods, only properties
        let analytics = HabitAnalytics.empty

        // Then - Verify struct can be accessed
        XCTAssertNotNil(analytics.overallStats)
        XCTAssertNotNil(analytics.streakAnalytics)
        XCTAssertNotNil(analytics.moodCorrelation)
    }

    // MARK: - structOverallStats{ Tests

    func testOverallStatsInitialization() {
        // Given
        let totalHabits = 10
        let activeHabits = 7
        let totalCompletions = 250
        let completionRate = 0.85
        let totalXPEarned = 1500
        let averageStreak = 12

        // When
        let stats = OverallStats(
            totalHabits: totalHabits,
            activeHabits: activeHabits,
            totalCompletions: totalCompletions,
            completionRate: completionRate,
            totalXPEarned: totalXPEarned,
            averageStreak: averageStreak
        )

        // Then
        XCTAssertEqual(stats.totalHabits, totalHabits)
        XCTAssertEqual(stats.activeHabits, activeHabits)
        XCTAssertEqual(stats.totalCompletions, totalCompletions)
        XCTAssertEqual(stats.completionRate, completionRate)
        XCTAssertEqual(stats.totalXPEarned, totalXPEarned)
        XCTAssertEqual(stats.averageStreak, averageStreak)
    }

    func testOverallStatsProperties() {
        // Given - Test edge case with zero values
        let stats = OverallStats(
            totalHabits: 0,
            activeHabits: 0,
            totalCompletions: 0,
            completionRate: 0.0,
            totalXPEarned: 0,
            averageStreak: 0
        )

        // Then
        XCTAssertEqual(stats.totalHabits, 0)
        XCTAssertEqual(stats.completionRate, 0.0)
    }

    func testOverallStatsMethods() {
        // Given - OverallStats is a simple data struct with no methods
        let stats = OverallStats(
            totalHabits: 5,
            activeHabits: 3,
            totalCompletions: 100,
            completionRate: 0.75,
            totalXPEarned: 500,
            averageStreak: 7
        )

        // Then - Verify all properties are accessible
        XCTAssertGreaterThan(stats.totalHabits, 0)
        XCTAssertGreaterThan(stats.completionRate, 0.0)
    }

    // MARK: - structAnalyticsStreakData{ Tests

    func testAnalyticsStreakDataInitialization() {
        // Given
        let currentStreaks = [3, 5, 7, 10]
        let longestStreak = 15
        let averageStreak = 6
        let activeStreaks = 4

        // When
        let data = AnalyticsStreakData(
            currentStreaks: currentStreaks,
            longestStreak: longestStreak,
            averageStreak: averageStreak,
            activeStreaks: activeStreaks
        )

        // Then
        XCTAssertEqual(data.currentStreaks, currentStreaks)
        XCTAssertEqual(data.longestStreak, longestStreak)
        XCTAssertEqual(data.averageStreak, averageStreak)
        XCTAssertEqual(data.activeStreaks, activeStreaks)
    }

    func testAnalyticsStreakDataProperties() {
        // Given - Test with empty streaks
        let data = AnalyticsStreakData(
            currentStreaks: [],
            longestStreak: 0,
            averageStreak: 0,
            activeStreaks: 0
        )

        // Then
        XCTAssertTrue(data.currentStreaks.isEmpty)
        XCTAssertEqual(data.longestStreak, 0)
        XCTAssertEqual(data.activeStreaks, 0)
    }

    func testAnalyticsStreakDataMethods() {
        // Given - Test streak data with multiple values
        let data = AnalyticsStreakData(
            currentStreaks: [1, 2, 3, 4, 5],
            longestStreak: 10,
            averageStreak: 3,
            activeStreaks: 5
        )

        // Then - Verify count matches activeStreaks
        XCTAssertEqual(data.currentStreaks.count, data.activeStreaks)
    }

    // MARK: - structCategoryStats{ Tests

    func testCategoryStatsInitialization() {
        // Given
        let category = HabitCategory.health
        let habitCount = 5
        let completionRate = 0.80
        let totalXP = 400

        // When
        let stats = CategoryStats(
            category: category,
            habitCount: habitCount,
            completionRate: completionRate,
            totalXP: totalXP
        )

        // Then
        XCTAssertEqual(stats.category, category)
        XCTAssertEqual(stats.habitCount, habitCount)
        XCTAssertEqual(stats.completionRate, completionRate)
        XCTAssertEqual(stats.totalXP, totalXP)
    }

    func testCategoryStatsProperties() {
        // Given - Test different categories
        let healthStats = CategoryStats(category: .health, habitCount: 3, completionRate: 0.9, totalXP: 300)
        let productivityStats = CategoryStats(category: .productivity, habitCount: 5, completionRate: 0.7, totalXP: 500)

        // Then
        XCTAssertEqual(healthStats.category, .health)
        XCTAssertEqual(productivityStats.category, .productivity)
        XCTAssertNotEqual(healthStats.category, productivityStats.category)
    }

    func testCategoryStatsMethods() {
        // Given - Test completion rate validation
        let stats = CategoryStats(category: .mindfulness, habitCount: 2, completionRate: 1.0, totalXP: 200)

        // Then - Verify completion rate is valid percentage
        XCTAssertGreaterThanOrEqual(stats.completionRate, 0.0)
        XCTAssertLessThanOrEqual(stats.completionRate, 1.0)
    }

    // MARK: - structMoodCorrelation{ Tests

    func testMoodCorrelationInitialization() {
        // Given
        let moodStats = [
            MoodStats(mood: .excellent, completionRate: 0.9, averageXP: 100),
            MoodStats(mood: .good, completionRate: 0.8, averageXP: 80),
        ]
        let strongestCorrelation = MoodRating.excellent

        // When
        let correlation = MoodCorrelation(
            moodStats: moodStats,
            strongestCorrelation: strongestCorrelation
        )

        // Then
        XCTAssertEqual(correlation.moodStats.count, 2)
        XCTAssertEqual(correlation.strongestCorrelation, strongestCorrelation)
    }

    func testMoodCorrelationProperties() {
        // Given - Test with empty mood stats
        let correlation = MoodCorrelation(moodStats: [], strongestCorrelation: .neutral)

        // Then
        XCTAssertTrue(correlation.moodStats.isEmpty)
        XCTAssertEqual(correlation.strongestCorrelation, .neutral)
    }

    func testMoodCorrelationMethods() {
        // Given - Test with all mood ratings
        let allMoods = [
            MoodStats(mood: .terrible, completionRate: 0.3, averageXP: 30),
            MoodStats(mood: .bad, completionRate: 0.5, averageXP: 50),
            MoodStats(mood: .neutral, completionRate: 0.7, averageXP: 70),
            MoodStats(mood: .good, completionRate: 0.85, averageXP: 85),
            MoodStats(mood: .excellent, completionRate: 0.95, averageXP: 95),
        ]
        let correlation = MoodCorrelation(moodStats: allMoods, strongestCorrelation: .excellent)

        // Then
        XCTAssertEqual(correlation.moodStats.count, 5)
    }

    // MARK: - structMoodStats{ Tests

    func testMoodStatsInitialization() {
        // Given
        let mood = MoodRating.excellent
        let completionRate = 0.92
        let averageXP = 150

        // When
        let stats = MoodStats(
            mood: mood,
            completionRate: completionRate,
            averageXP: averageXP
        )

        // Then
        XCTAssertEqual(stats.mood, mood)
        XCTAssertEqual(stats.completionRate, completionRate)
        XCTAssertEqual(stats.averageXP, averageXP)
    }

    func testMoodStatsProperties() {
        // Given - Test all mood ratings
        let terribleStats = MoodStats(mood: .terrible, completionRate: 0.2, averageXP: 20)
        let greatStats = MoodStats(mood: .excellent, completionRate: 0.95, averageXP: 95)

        // Then
        XCTAssertEqual(terribleStats.mood, .terrible)
        XCTAssertEqual(greatStats.mood, .excellent)
        XCTAssertLessThan(terribleStats.completionRate, greatStats.completionRate)
    }

    func testMoodStatsMethods() {
        // Given - Test completion rate bounds
        let stats = MoodStats(mood: .good, completionRate: 0.85, averageXP: 85)

        // Then - Verify valid percentage
        XCTAssertGreaterThanOrEqual(stats.completionRate, 0.0)
        XCTAssertLessThanOrEqual(stats.completionRate, 1.0)
        XCTAssertGreaterThanOrEqual(stats.averageXP, 0)
    }

    // MARK: - structTimePatterns{ Tests

    func testTimePatternsInitialization() {
        // Given
        let peakHours = 14
        let hourlyDistribution = [9: 5, 14: 10, 18: 7]
        let weekdayPatterns = [1: 8, 2: 10, 3: 9, 4: 7, 5: 6]

        // When
        let patterns = TimePatterns(
            peakHours: peakHours,
            hourlyDistribution: hourlyDistribution,
            weekdayPatterns: weekdayPatterns
        )

        // Then
        XCTAssertEqual(patterns.peakHours, peakHours)
        XCTAssertEqual(patterns.hourlyDistribution.count, 3)
        XCTAssertEqual(patterns.weekdayPatterns.count, 5)
    }

    func testTimePatternsProperties() {
        // Given - Test with empty distributions
        let patterns = TimePatterns(
            peakHours: 0,
            hourlyDistribution: [:],
            weekdayPatterns: [:]
        )

        // Then
        XCTAssertEqual(patterns.peakHours, 0)
        XCTAssertTrue(patterns.hourlyDistribution.isEmpty)
        XCTAssertTrue(patterns.weekdayPatterns.isEmpty)
    }

    func testTimePatternsMethods() {
        // Given - Test peak hours validation
        let patterns = TimePatterns(
            peakHours: 9,
            hourlyDistribution: [9: 15, 10: 12, 11: 8],
            weekdayPatterns: [1: 10, 5: 8]
        )

        // Then - Verify peak hours is valid (0-23)
        XCTAssertGreaterThanOrEqual(patterns.peakHours, 0)
        XCTAssertLessThan(patterns.peakHours, 24)
    }

    // MARK: - structWeeklyProgress{ Tests

    func testWeeklyProgressInitialization() {
        // Given
        let completedHabits = 25
        let totalOpportunities = 35
        let xpEarned = 500
        let dailyBreakdown = ["Monday": 5, "Tuesday": 4, "Wednesday": 6]

        // When
        let progress = WeeklyProgress(
            completedHabits: completedHabits,
            totalOpportunities: totalOpportunities,
            xpEarned: xpEarned,
            dailyBreakdown: dailyBreakdown
        )

        // Then
        XCTAssertEqual(progress.completedHabits, completedHabits)
        XCTAssertEqual(progress.totalOpportunities, totalOpportunities)
        XCTAssertEqual(progress.xpEarned, xpEarned)
        XCTAssertEqual(progress.dailyBreakdown.count, 3)
    }

    func testWeeklyProgressProperties() {
        // Given - Test completion rate calculation
        let progress = WeeklyProgress(
            completedHabits: 20,
            totalOpportunities: 25,
            xpEarned: 400,
            dailyBreakdown: [:]
        )

        // Then - Verify completed is less than or equal to total
        XCTAssertLessThanOrEqual(progress.completedHabits, progress.totalOpportunities)
    }

    func testWeeklyProgressMethods() {
        // Given - Test with full week breakdown
        let fullWeek = [
            "Monday": 5, "Tuesday": 4, "Wednesday": 6,
            "Thursday": 5, "Friday": 3, "Saturday": 2, "Sunday": 4,
        ]
        let progress = WeeklyProgress(
            completedHabits: 29,
            totalOpportunities: 35,
            xpEarned: 580,
            dailyBreakdown: fullWeek
        )

        // Then
        XCTAssertEqual(progress.dailyBreakdown.count, 7)
    }

    // MARK: - structMonthlyTrend{ Tests

    func testMonthlyTrendInitialization() {
        // Given
        let month = 6
        let completions = 120
        let xpEarned = 2400
        let averageDaily = 4.0

        // When
        let trend = MonthlyTrend(
            month: month,
            completions: completions,
            xpEarned: xpEarned,
            averageDaily: averageDaily
        )

        // Then
        XCTAssertEqual(trend.month, month)
        XCTAssertEqual(trend.completions, completions)
        XCTAssertEqual(trend.xpEarned, xpEarned)
        XCTAssertEqual(trend.averageDaily, averageDaily)
    }

    func testMonthlyTrendProperties() {
        // Given - Test month validation
        let januaryTrend = MonthlyTrend(month: 1, completions: 90, xpEarned: 1800, averageDaily: 3.0)
        let decemberTrend = MonthlyTrend(month: 12, completions: 100, xpEarned: 2000, averageDaily: 3.3)

        // Then - Verify months are valid (1-12)
        XCTAssertGreaterThanOrEqual(januaryTrend.month, 1)
        XCTAssertLessThanOrEqual(januaryTrend.month, 12)
        XCTAssertGreaterThanOrEqual(decemberTrend.month, 1)
        XCTAssertLessThanOrEqual(decemberTrend.month, 12)
    }

    func testMonthlyTrendMethods() {
        // Given - Test average daily calculation consistency
        let trend = MonthlyTrend(month: 3, completions: 93, xpEarned: 1860, averageDaily: 3.1)

        // Then - Verify averageDaily is reasonable (completions / ~30 days)
        XCTAssertGreaterThan(trend.averageDaily, 0.0)
        XCTAssertLessThan(trend.averageDaily, Double(trend.completions))
    }

    // MARK: - structHabitPerformance{ Tests

    func testHabitPerformanceInitialization() {
        // Given
        let habitId = UUID()
        let habitName = "Morning Exercise"
        let completionRate = 0.88
        let currentStreak = 12
        let xpEarned = 600
        let trend = HabitTrend.improving

        // When
        let performance = HabitPerformance(
            habitId: habitId,
            habitName: habitName,
            completionRate: completionRate,
            currentStreak: currentStreak,
            xpEarned: xpEarned,
            trend: trend
        )

        // Then
        XCTAssertEqual(performance.habitId, habitId)
        XCTAssertEqual(performance.habitName, habitName)
        XCTAssertEqual(performance.completionRate, completionRate)
        XCTAssertEqual(performance.currentStreak, currentStreak)
        XCTAssertEqual(performance.xpEarned, xpEarned)
        XCTAssertEqual(performance.trend, trend)
    }

    func testHabitPerformanceProperties() {
        // Given - Test different trends
        let improving = HabitPerformance(
            habitId: UUID(),
            habitName: "Reading",
            completionRate: 0.9,
            currentStreak: 15,
            xpEarned: 750,
            trend: .improving
        )
        let declining = HabitPerformance(
            habitId: UUID(),
            habitName: "Meditation",
            completionRate: 0.5,
            currentStreak: 2,
            xpEarned: 100,
            trend: .declining
        )

        // Then
        XCTAssertEqual(improving.trend, .improving)
        XCTAssertEqual(declining.trend, .declining)
        XCTAssertNotEqual(improving.trend, declining.trend)
    }

    func testHabitPerformanceMethods() {
        // Given - Test completion rate validation
        let performance = HabitPerformance(
            habitId: UUID(),
            habitName: "Water Intake",
            completionRate: 1.0,
            currentStreak: 30,
            xpEarned: 1500,
            trend: .stable
        )

        // Then - Verify completion rate is valid percentage
        XCTAssertGreaterThanOrEqual(performance.completionRate, 0.0)
        XCTAssertLessThanOrEqual(performance.completionRate, 1.0)
    }

    // MARK: - structHabitTrendData{ Tests

    func testHabitTrendDataInitialization() {
        // Given
        let habitId = UUID()
        let completionRates = [0.8, 0.85, 0.9, 0.88]
        let streaks = [5, 7, 10, 12]
        let xpEarned = [100, 120, 150, 140]

        // When
        let trendData = HabitTrendData(
            habitId: habitId,
            completionRates: completionRates,
            streaks: streaks,
            xpEarned: xpEarned
        )

        // Then
        XCTAssertEqual(trendData.habitId, habitId)
        XCTAssertEqual(trendData.completionRates, completionRates)
        XCTAssertEqual(trendData.streaks, streaks)
        XCTAssertEqual(trendData.xpEarned, xpEarned)
    }

    func testHabitTrendDataProperties() {
        // Given - Test with empty arrays
        let trendData = HabitTrendData(
            habitId: UUID(),
            completionRates: [],
            streaks: [],
            xpEarned: []
        )

        // Then
        XCTAssertTrue(trendData.completionRates.isEmpty)
        XCTAssertTrue(trendData.streaks.isEmpty)
        XCTAssertTrue(trendData.xpEarned.isEmpty)
    }

    func testHabitTrendDataMethods() {
        // Given - Test with consistent array lengths
        let trendData = HabitTrendData(
            habitId: UUID(),
            completionRates: [0.7, 0.8, 0.9],
            streaks: [3, 5, 7],
            xpEarned: [70, 80, 90]
        )

        // Then - Verify all arrays have same length
        XCTAssertEqual(trendData.completionRates.count, trendData.streaks.count)
        XCTAssertEqual(trendData.streaks.count, trendData.xpEarned.count)
    }

    // MARK: - structCategoryInsight{ Tests

    func testCategoryInsightInitialization() {
        // Given
        let category = HabitCategory.productivity
        let totalHabits = 8
        let completionRate = 0.82
        let averageStreak = 9
        let totalXPEarned = 1600

        // When
        let insight = CategoryInsight(
            category: category,
            totalHabits: totalHabits,
            completionRate: completionRate,
            averageStreak: averageStreak,
            totalXPEarned: totalXPEarned
        )

        // Then
        XCTAssertEqual(insight.category, category)
        XCTAssertEqual(insight.totalHabits, totalHabits)
        XCTAssertEqual(insight.completionRate, completionRate)
        XCTAssertEqual(insight.averageStreak, averageStreak)
        XCTAssertEqual(insight.totalXPEarned, totalXPEarned)
    }

    func testCategoryInsightProperties() {
        // Given - Test different categories
        let healthInsight = CategoryInsight(
            category: .health,
            totalHabits: 5,
            completionRate: 0.9,
            averageStreak: 12,
            totalXPEarned: 1200
        )
        let mindfulnessInsight = CategoryInsight(
            category: .mindfulness,
            totalHabits: 3,
            completionRate: 0.75,
            averageStreak: 8,
            totalXPEarned: 600
        )

        // Then
        XCTAssertEqual(healthInsight.category, .health)
        XCTAssertEqual(mindfulnessInsight.category, .mindfulness)
        XCTAssertNotEqual(healthInsight.category, mindfulnessInsight.category)
    }

    func testCategoryInsightMethods() {
        // Given - Test completion rate validation
        let insight = CategoryInsight(
            category: .social,
            totalHabits: 4,
            completionRate: 0.95,
            averageStreak: 15,
            totalXPEarned: 1900
        )

        // Then - Verify completion rate is valid percentage
        XCTAssertGreaterThanOrEqual(insight.completionRate, 0.0)
        XCTAssertLessThanOrEqual(insight.completionRate, 1.0)
    }

    // MARK: - structProductivityMetrics{ Tests

    func testProductivityMetricsInitialization() {
        // Given
        let period = TimePeriod.month
        let completionRate = 0.78
        let streakCount = 6
        let xpEarned = 1560
        let missedOpportunities = 15

        // When
        let metrics = ProductivityMetrics(
            period: period,
            completionRate: completionRate,
            streakCount: streakCount,
            xpEarned: xpEarned,
            missedOpportunities: missedOpportunities
        )

        // Then
        XCTAssertEqual(metrics.period.dayCount, 30)
        XCTAssertEqual(metrics.completionRate, completionRate)
        XCTAssertEqual(metrics.streakCount, streakCount)
        XCTAssertEqual(metrics.xpEarned, xpEarned)
        XCTAssertEqual(metrics.missedOpportunities, missedOpportunities)
    }

    func testProductivityMetricsProperties() {
        // Given - Test different time periods
        let weekMetrics = ProductivityMetrics(
            period: .week,
            completionRate: 0.85,
            streakCount: 3,
            xpEarned: 350,
            missedOpportunities: 5
        )
        let yearMetrics = ProductivityMetrics(
            period: .year,
            completionRate: 0.72,
            streakCount: 25,
            xpEarned: 18000,
            missedOpportunities: 120
        )

        // Then
        XCTAssertEqual(weekMetrics.period.dayCount, 7)
        XCTAssertEqual(yearMetrics.period.dayCount, 365)
        XCTAssertNotEqual(weekMetrics.period.dayCount, yearMetrics.period.dayCount)
    }

    func testProductivityMetricsMethods() {
        // Given - Test completion rate validation
        let metrics = ProductivityMetrics(
            period: .quarter,
            completionRate: 1.0,
            streakCount: 15,
            xpEarned: 4500,
            missedOpportunities: 0
        )

        // Then - Verify completion rate is valid percentage
        XCTAssertGreaterThanOrEqual(metrics.completionRate, 0.0)
        XCTAssertLessThanOrEqual(metrics.completionRate, 1.0)
        XCTAssertGreaterThanOrEqual(metrics.missedOpportunities, 0)
    }

    // MARK: - enumHabitTrend:String{ Tests

    func testHabitTrendInitialization() {
        // Given - HabitTrend is an enum with String raw values
        // When - Access all enum cases
        let improving = HabitTrend.improving
        let stable = HabitTrend.stable
        let declining = HabitTrend.declining

        // Then - All cases should be accessible
        XCTAssertNotNil(improving)
        XCTAssertNotNil(stable)
        XCTAssertNotNil(declining)
    }

    func testHabitTrendProperties() {
        // Given - Test raw values

        // Then - Verify raw values match expected strings
        XCTAssertEqual(HabitTrend.improving.rawValue, "improving")
        XCTAssertEqual(HabitTrend.stable.rawValue, "stable")
        XCTAssertEqual(HabitTrend.declining.rawValue, "declining")
    }

    func testHabitTrendMethods() {
        // Given - Test enum initialization from raw value
        let improvingFromRaw = HabitTrend(rawValue: "improving")
        let stableFromRaw = HabitTrend(rawValue: "stable")
        let decliningFromRaw = HabitTrend(rawValue: "declining")
        let invalidFromRaw = HabitTrend(rawValue: "invalid")

        // Then - Verify initialization works correctly
        XCTAssertEqual(improvingFromRaw, .improving)
        XCTAssertEqual(stableFromRaw, .stable)
        XCTAssertEqual(decliningFromRaw, .declining)
        XCTAssertNil(invalidFromRaw)
    }
}
