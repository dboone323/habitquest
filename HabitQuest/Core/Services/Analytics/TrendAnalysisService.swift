import SwiftData
import SwiftUI

/// Service responsible for analyzing trends and time-based patterns
final class TrendAnalysisService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Get habit trends for specific habit over time period
    func getHabitTrends(for habitId: UUID, days: Int = 30) async -> HabitTrendData {
        let habit = await fetchHabit(id: habitId)
        guard let habit else {
            return HabitTrendData(habitId: habitId, completionRates: [], streaks: [], xpEarned: [])
        }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recentLogs = habit.logs.filter { $0.completionDate >= cutoffDate }
            .sorted { $0.completionDate < $1.completionDate }

        return HabitTrendData(
            habitId: habitId,
            completionRates: self.calculateDailyCompletionRates(logs: recentLogs, days: days),
            streaks: self.calculateDailyStreaks(logs: recentLogs),
            xpEarned: self.calculateDailyXP(logs: recentLogs, days: days)
        )
    }

    /// Calculate weekly progress metrics
    func calculateWeeklyProgress(logs: [HabitLog]) async -> WeeklyProgress {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekLogs = logs.filter { $0.completionDate >= weekAgo }
        let completedThisWeek = weekLogs.filter(\.isCompleted).count

        return WeeklyProgress(
            completedHabits: completedThisWeek,
            totalOpportunities: weekLogs.count,
            xpEarned: weekLogs.filter(\.isCompleted).reduce(0) { $0 + $1.xpEarned },
            dailyBreakdown: self.calculateDailyBreakdown(logs: weekLogs)
        )
    }

    /// Calculate monthly trends over time
    func calculateMonthlyTrends(logs: [HabitLog]) async -> [MonthlyTrend] {
        let monthGroups = Dictionary(grouping: logs) {
            Calendar.current.component(.month, from: $0.completionDate)
        }

        return monthGroups.map { month, monthLogs in
            MonthlyTrend(
                month: month,
                completions: monthLogs.filter(\.isCompleted).count,
                xpEarned: monthLogs.filter(\.isCompleted).reduce(0) { $0 + $1.xpEarned },
                averageDaily: Double(monthLogs.count) / 30.0
            )
        }.sorted { $0.month < $1.month }
    }

    /// Calculate habit trend direction
    func calculateHabitTrends(logs: [HabitLog]) async -> HabitTrend {
        let recentLogs = logs.suffix(30)
        let olderLogs = logs.dropLast(30).suffix(30)

        let recentRate = Double(recentLogs.filter(\.isCompleted).count) / Double(max(recentLogs.count, 1))
        let olderRate = Double(olderLogs.filter(\.isCompleted).count) / Double(max(olderLogs.count, 1))

        if recentRate > olderRate + 0.1 {
            return .improving
        } else if recentRate < olderRate - 0.1 {
            return .declining
        } else {
            return .stable
        }
    }

    // MARK: - Private Methods

    private func fetchHabit(id: UUID) async -> Habit? {
        let descriptor = FetchDescriptor<Habit>()
        let habits = try? self.modelContext.fetch(descriptor)
        return habits?.first { $0.id == id }
    }

    private func calculateDailyCompletionRates(logs: [HabitLog], days: Int) -> [Double] {
        var rates: [Double] = []
        let calendar = Calendar.current

        for day in 0 ..< days {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            let dayLogs = logs.filter { calendar.isDate($0.completionDate, inSameDayAs: date) }
            let completionRate = Double(dayLogs.filter(\.isCompleted).count) / Double(max(dayLogs.count, 1))
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

        for day in 0 ..< days {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            let dayLogs = logs.filter { calendar.isDate($0.completionDate, inSameDayAs: date) }
            let dailyXP = dayLogs.filter(\.isCompleted).reduce(0) { $0 + $1.xpEarned }
            xpData.append(dailyXP)
        }

        return xpData.reversed()
    }

    private func calculateDailyBreakdown(logs: [HabitLog]) -> [String: Int] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"

        let dayGroups = Dictionary(grouping: logs) {
            dateFormatter.string(from: $0.completionDate)
        }

        return dayGroups.mapValues { $0.filter(\.isCompleted).count }
    }
}
