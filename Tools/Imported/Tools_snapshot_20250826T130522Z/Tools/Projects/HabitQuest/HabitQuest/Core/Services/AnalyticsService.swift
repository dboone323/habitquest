import SwiftData
import SwiftUI

/// Comprehensive analytics service for tracking habit performance and user insights
@Observable
final class AnalyticsService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Core Analytics Data

    /// Get comprehensive analytics data
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func getAnalytics() async -> HabitAnalytics {
        let habits = await fetchAllHabits()
        let logs = await fetchAllLogs()

        return HabitAnalytics(
            overallStats: calculateOverallStats(habits: habits, logs: logs),
            streakAnalytics: calculateStreakAnalytics(habits: habits),
            categoryBreakdown: calculateCategoryBreakdown(habits: habits),
            moodCorrelation: calculateMoodCorrelation(logs: logs),
            timePatterns: calculateTimePatterns(logs: logs),
            weeklyProgress: calculateWeeklyProgress(logs: logs),
            monthlyTrends: calculateMonthlyTrends(logs: logs),
            habitPerformance: calculateHabitPerformance(habits: habits)
        )
    }

    // MARK: - Specific Analytics Queries

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func getHabitTrends(for habitId: UUID, days: Int = 30) async -> HabitTrendData {
        let habit = await fetchHabit(id: habitId)
        guard let habit = habit else {
            return HabitTrendData(habitId: habitId, completionRates: [], streaks: [], xpEarned: [])
        }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recentLogs = habit.logs.filter { $0.completionDate >= cutoffDate }.sorted { $0.completionDate < $1.completionDate }

        return HabitTrendData(
            habitId: habitId,
            completionRates: calculateDailyCompletionRates(logs: recentLogs, days: days),
            streaks: calculateDailyStreaks(logs: recentLogs),
            xpEarned: calculateDailyXP(logs: recentLogs, days: days)
        )
    }

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func getCategoryInsights() async -> [CategoryInsight] {
        let habits = await fetchAllHabits()
        let categories = Dictionary(grouping: habits) { $0.category }

        return categories.map { category, categoryHabits in
            let allLogs = categoryHabits.flatMap { $0.logs }
            let completedLogs = allLogs.filter { $0.isCompleted }

            return CategoryInsight(
                category: category,
                totalHabits: categoryHabits.count,
                completionRate: Double(completedLogs.count) / Double(max(allLogs.count, 1)),
                averageStreak: categoryHabits.reduce(0) { $0 + $1.streak } / max(categoryHabits.count, 1),
                totalXPEarned: completedLogs.reduce(0) { $0 + $1.xpEarned }
            )
        }
    }

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func getProductivityMetrics(for period: TimePeriod) async -> ProductivityMetrics {
        let habits = await fetchAllHabits()
        let startDate = period.startDate
        let logs = habits.flatMap { $0.logs }.filter { $0.completionDate >= startDate }

        let completedLogs = logs.filter { $0.isCompleted }
        let totalPossibleCompletions = habits.count * period.dayCount

        return ProductivityMetrics(
            period: period,
            completionRate: Double(completedLogs.count) / Double(max(totalPossibleCompletions, 1)),
            streakCount: calculateActiveStreaks(habits: habits),
            xpEarned: completedLogs.reduce(0) { $0 + $1.xpEarned },
            missedOpportunities: totalPossibleCompletions - completedLogs.count
        )
    }

    // MARK: - Private Calculation Methods

    private func fetchAllHabits() async -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchAllLogs() async -> [HabitLog] {
        let descriptor = FetchDescriptor<HabitLog>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchHabit(id: UUID) async -> Habit? {
        let descriptor = FetchDescriptor<Habit>()
        let habits = try? modelContext.fetch(descriptor)
        return habits?.first { $0.id == id }
    }

    private func calculateOverallStats(habits: [Habit], logs: [HabitLog]) -> OverallStats {
        let completedLogs = logs.filter { $0.isCompleted }
        let totalCompletions = completedLogs.count
        let completionRate = Double(totalCompletions) / Double(max(logs.count, 1))

        return OverallStats(
            totalHabits: habits.count,
            activeHabits: habits.filter { $0.isActive }.count,
            totalCompletions: totalCompletions,
            completionRate: completionRate,
            totalXPEarned: completedLogs.reduce(0) { $0 + $1.xpEarned },
            averageStreak: habits.reduce(0) { $0 + $1.streak } / max(habits.count, 1)
        )
    }

    private func calculateStreakAnalytics(habits: [Habit]) -> AnalyticsStreakData {
        let streaks = habits.map { $0.streak }
        return AnalyticsStreakData(
            currentStreaks: streaks,
            longestStreak: streaks.max() ?? 0,
            averageStreak: streaks.reduce(0, +) / max(streaks.count, 1),
            activeStreaks: streaks.filter { $0 > 0 }.count
        )
    }

    private func calculateCategoryBreakdown(habits: [Habit]) -> [CategoryStats] {
        let categories = Dictionary(grouping: habits) { $0.category }
        return categories.map { category, categoryHabits in
            let completedLogs = categoryHabits.flatMap { $0.logs }.filter { $0.isCompleted }
            return CategoryStats(
                category: category,
                habitCount: categoryHabits.count,
                completionRate: Double(completedLogs.count) / Double(max(categoryHabits.count, 1)),
                totalXP: completedLogs.reduce(0) { $0 + $1.xpEarned }
            )
        }
    }

    private func calculateMoodCorrelation(logs: [HabitLog]) -> MoodCorrelation {
        let moodGroups = Dictionary(grouping: logs.filter { $0.mood != nil }) { $0.mood! }
        let moodStats = moodGroups.mapValues { logs in
            MoodStats(
                mood: logs.first?.mood ?? .okay,
                completionRate: Double(logs.filter { $0.isCompleted }.count) / Double(max(logs.count, 1)),
                averageXP: logs.filter { $0.isCompleted }.reduce(0) { $0 + $1.xpEarned } / max(logs.filter { $0.isCompleted }.count, 1)
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
            weekdayPatterns: calculateWeekdayPatterns(logs: logs)
        )
    }

    private func calculateWeeklyProgress(logs: [HabitLog]) -> WeeklyProgress {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekLogs = logs.filter { $0.completionDate >= weekAgo }
        let completedThisWeek = weekLogs.filter { $0.isCompleted }.count

        return WeeklyProgress(
            completedHabits: completedThisWeek,
            totalOpportunities: weekLogs.count,
            xpEarned: weekLogs.filter { $0.isCompleted }.reduce(0) { $0 + $1.xpEarned },
            dailyBreakdown: calculateDailyBreakdown(logs: weekLogs)
        )
    }

    private func calculateMonthlyTrends(logs: [HabitLog]) -> [MonthlyTrend] {
        let monthGroups = Dictionary(grouping: logs) {
            Calendar.current.component(.month, from: $0.completionDate)
        }

        return monthGroups.map { month, monthLogs in
            MonthlyTrend(
                month: month,
                completions: monthLogs.filter { $0.isCompleted }.count,
                xpEarned: monthLogs.filter { $0.isCompleted }.reduce(0) { $0 + $1.xpEarned },
                averageDaily: Double(monthLogs.count) / 30.0
            )
        }.sorted { $0.month < $1.month }
    }

    private func calculateHabitPerformance(habits: [Habit]) -> [HabitPerformance] {
        return habits.map { habit in
            let completedLogs = habit.logs.filter { $0.isCompleted }
            let trends = calculateHabitTrends(logs: habit.logs)

            return HabitPerformance(
                habitId: habit.id,
                habitName: habit.name,
                completionRate: Double(completedLogs.count) / Double(max(habit.logs.count, 1)),
                currentStreak: habit.streak,
                xpEarned: completedLogs.reduce(0) { $0 + $1.xpEarned },
                trend: trends
            )
        }
    }

    // MARK: - Helper Methods

    private func calculateDailyCompletionRates(logs: [HabitLog], days: Int) -> [Double] {
        var rates: [Double] = []
        let calendar = Calendar.current

        for day in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            let dayLogs = logs.filter { calendar.isDate($0.completionDate, inSameDayAs: date) }
            let completionRate = Double(dayLogs.filter { $0.isCompleted }.count) / Double(max(dayLogs.count, 1))
            rates.append(completionRate)
        }

        return rates.reversed()
    }

    private func calculateDailyStreaks(logs: [HabitLog]) -> [Int] {
        let sortedLogs = logs.sorted { $0.completionDate < $1.completionDate }
        var streaks: [Int] = []
        var currentStreak = 0

        for log in sortedLogs {
            if log.isCompleted {
                currentStreak += 1
            } else {
                streaks.append(currentStreak)
                currentStreak = 0
            }
        }

        if currentStreak > 0 {
            streaks.append(currentStreak)
        }

        return streaks
    }

    private func calculateDailyXP(logs: [HabitLog], days: Int) -> [Int] {
        var xpData: [Int] = []
        let calendar = Calendar.current

        for day in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            let dayLogs = logs.filter { calendar.isDate($0.completionDate, inSameDayAs: date) }
            let dailyXP = dayLogs.filter { $0.isCompleted }.reduce(0) { $0 + $1.xpEarned }
            xpData.append(dailyXP)
        }

        return xpData.reversed()
    }

    private func calculateActiveStreaks(habits: [Habit]) -> Int {
        return habits.filter { $0.streak > 0 }.count
    }

    private func calculateWeekdayPatterns(logs: [HabitLog]) -> [Int: Int] {
        let weekdayGroups = Dictionary(grouping: logs) {
            Calendar.current.component(.weekday, from: $0.completionDate)
        }
        return weekdayGroups.mapValues { $0.count }
    }

    private func calculateDailyBreakdown(logs: [HabitLog]) -> [String: Int] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"

        let dayGroups = Dictionary(grouping: logs) {
            dateFormatter.string(from: $0.completionDate)
        }

        return dayGroups.mapValues { $0.filter { $0.isCompleted }.count }
    }

    private func calculateHabitTrends(logs: [HabitLog]) -> HabitTrend {
        let recentLogs = logs.suffix(30)
        let olderLogs = logs.dropLast(30).suffix(30)

        let recentRate = Double(recentLogs.filter { $0.isCompleted }.count) / Double(max(recentLogs.count, 1))
        let olderRate = Double(olderLogs.filter { $0.isCompleted }.count) / Double(max(olderLogs.count, 1))

        if recentRate > olderRate + 0.1 {
            return .improving
        } else if recentRate < olderRate - 0.1 {
            return .declining
        } else {
            return .stable
        }
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
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .year: return 365
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

enum HabitTrend: String {
    case improving
    case stable
    case declining
}
