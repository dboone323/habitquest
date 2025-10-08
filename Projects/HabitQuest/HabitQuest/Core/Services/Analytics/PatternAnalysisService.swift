import Foundation
import SwiftData

/// Service responsible for analyzing habit patterns and behavioral data
final class PatternAnalysisService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Analyze comprehensive habit patterns for predictive modeling
    func analyzeHabitPatterns(_ habit: Habit) -> HabitPatterns {
        let recentLogs = habit.logs.suffix(30).sorted { $0.completionDate < $1.completionDate }

        let consistency = self.calculateConsistency(from: ArraySlice(recentLogs))
        let momentum = self.calculateMomentum(from: ArraySlice(recentLogs))
        let volatility = self.calculateVolatility(from: ArraySlice(recentLogs))

        return HabitPatterns(
            consistency: consistency,
            momentum: momentum,
            volatility: volatility,
            weekdayPreference: self.analyzeWeekdayPreference(recentLogs),
            timePreference: self.analyzeTimePreference(recentLogs)
        )
    }

    /// Analyze time-based factors affecting habit completion
    func analyzeTimeFactors(_ habit: Habit) -> TimeFactors {
        let now = Date()
        let calendar = Calendar.current

        let currentHour = calendar.component(.hour, from: now)
        let dayOfWeek = calendar.component(.weekday, from: now)

        let hourSuccessRate = self.calculateSuccessRateForHour(habit: habit, hour: currentHour)
        let daySuccessRate = self.calculateSuccessRateForWeekday(habit: habit, weekday: dayOfWeek)

        return TimeFactors(
            currentHourSuccessRate: hourSuccessRate,
            currentDaySuccessRate: daySuccessRate,
            timesSinceLastCompletion: self.calculateTimeSinceLastCompletion(habit),
            optimalTimeWindow: self.findOptimalTimeWindow(habit)
        )
    }

    /// Calculate streak momentum and acceleration metrics
    func calculateStreakMomentum(_ habit: Habit) -> StreakMomentum {
        let recentCompletions = habit.logs.suffix(7).filter(\.isCompleted)
        let momentum = Double(recentCompletions.count) / 7.0

        let longestRecentStreak = self.calculateLongestRecentStreak(habit)
        let streakAcceleration = self.calculateStreakAcceleration(habit)

        return StreakMomentum(
            weeklyMomentum: momentum,
            longestRecentStreak: longestRecentStreak,
            acceleration: streakAcceleration
        )
    }

    /// Analyze day-of-week completion patterns
    func analyzeDayOfWeekPattern(_ habit: Habit) -> (strongest: [String], weakest: [String]) {
        let calendar = Calendar.current
        let weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

        var weekdaySuccessRates: [Int: Double] = [:]

        for weekday in 1 ... 7 {
            let logsOnWeekday = habit.logs.filter { log in
                calendar.component(.weekday, from: log.completionDate) == weekday
            }

            if !logsOnWeekday.isEmpty {
                let completedCount = logsOnWeekday.filter(\.isCompleted).count
                weekdaySuccessRates[weekday] = Double(completedCount) / Double(logsOnWeekday.count)
            }
        }

        let sortedRates = weekdaySuccessRates.sorted { $0.value > $1.value }
        let strongest = sortedRates.prefix(2).compactMap { weekdayNames[$0.key - 1] }
        let weakest = sortedRates.suffix(2).compactMap { weekdayNames[$0.key - 1] }

        return (strongest: strongest, weakest: weakest)
    }

    /// Analyze factors that commonly break streaks
    func analyzeStreakBreakFactors(_ habit: Habit) -> [String] {
        var factors: [String] = []

        // Analyze weekend patterns
        let weekendBreaks = self.analyzeWeekendBreakPattern(habit)
        if weekendBreaks > 0.3 {
            factors.append("Weekend disruption")
        }

        // Analyze time gaps
        let averageGap = self.calculateAverageCompletionGap(habit)
        if averageGap > 2.0 {
            factors.append("Inconsistent timing")
        }

        // Analyze recent failures
        let recentFailureRate = self.calculateRecentFailureRate(habit)
        if recentFailureRate > 0.4 {
            factors.append("Recent setbacks")
        }

        // Default factors if none detected
        if factors.isEmpty {
            factors = ["Travel", "Stress", "Schedule changes"]
        }

        return factors
    }

    // MARK: - Private Helper Methods

    private func calculateConsistency(from logs: ArraySlice<HabitLog>) -> Double {
        guard !logs.isEmpty else { return 0 }
        let completedCount = logs.filter(\.isCompleted).count
        return Double(completedCount) / Double(logs.count)
    }

    private func calculateMomentum(from logs: ArraySlice<HabitLog>) -> Double {
        guard logs.count >= 14 else { return 0.5 }

        let firstHalf = logs.prefix(logs.count / 2)
        let secondHalf = logs.suffix(logs.count / 2)

        let firstConsistency = self.calculateConsistency(from: firstHalf)
        let secondConsistency = self.calculateConsistency(from: secondHalf)

        return secondConsistency > firstConsistency ?
            min(1.0, secondConsistency + 0.1) : secondConsistency
    }

    private func calculateVolatility(from logs: ArraySlice<HabitLog>) -> Double {
        guard logs.count > 1 else { return 0 }

        let completions = logs.map { $0.isCompleted ? 1.0 : 0.0 }
        let mean = completions.reduce(0, +) / Double(completions.count)
        let variance = completions.map { pow($0 - mean, 2) }.reduce(0, +) / Double(completions.count)

        return sqrt(variance)
    }

    private func analyzeWeekdayPreference(_ logs: [HabitLog]) -> Int {
        let calendar = Calendar.current
        var weekdayCounts: [Int: Int] = [:]

        for log in logs where log.isCompleted {
            let weekday = calendar.component(.weekday, from: log.completionDate)
            weekdayCounts[weekday, default: 0] += 1
        }

        return weekdayCounts.max(by: { $0.value < $1.value })?.key ?? 2 // Default to Tuesday
    }

    private func analyzeTimePreference(_ logs: [HabitLog]) -> [String] {
        let completionHours = logs.compactMap { log in
            log.isCompleted ? Calendar.current.component(.hour, from: log.completionDate) : nil
        }

        guard !completionHours.isEmpty else { return ["9:00 AM"] } // Default to 9 AM

        let hourCounts = Dictionary(grouping: completionHours, by: { $0 })
            .mapValues(\.count)

        let optimalHour = hourCounts.max(by: { $0.value < $1.value })?.key ?? 9

        // Convert hour to time string
        let hour12 = optimalHour == 0 ? 12 : (optimalHour > 12 ? optimalHour - 12 : optimalHour)
        let amPm = optimalHour >= 12 ? "PM" : "AM"
        return ["\(hour12):00 \(amPm)"]
    }

    private func calculateSuccessRateForHour(habit: Habit, hour: Int) -> Double {
        let logsInHour = habit.logs.filter { log in
            Calendar.current.component(.hour, from: log.completionDate) == hour
        }

        guard !logsInHour.isEmpty else { return 0.5 }

        let completedInHour = logsInHour.filter(\.isCompleted).count
        return Double(completedInHour) / Double(logsInHour.count)
    }

    private func calculateSuccessRateForWeekday(habit: Habit, weekday: Int) -> Double {
        let logsOnWeekday = habit.logs.filter { log in
            Calendar.current.component(.weekday, from: log.completionDate) == weekday
        }

        guard !logsOnWeekday.isEmpty else { return 0.5 }

        let completedOnWeekday = logsOnWeekday.filter(\.isCompleted).count
        return Double(completedOnWeekday) / Double(logsOnWeekday.count)
    }

    private func calculateTimeSinceLastCompletion(_ habit: Habit) -> TimeInterval {
        guard let lastCompletion = habit.logs.filter(\.isCompleted).last?.completionDate else {
            return 0
        }
        return Date().timeIntervalSince(lastCompletion)
    }

    private func findOptimalTimeWindow(_ habit: Habit) -> ClosedRange<Int> {
        let completionHours = habit.logs.compactMap { log in
            log.isCompleted ? Calendar.current.component(.hour, from: log.completionDate) : nil
        }

        guard !completionHours.isEmpty else { return 9 ... 11 } // Default morning window

        // Find the most frequent completion hour
        let hourCounts = Dictionary(grouping: completionHours, by: { $0 }).mapValues { $0.count }
        let optimalHour = hourCounts.max(by: { $0.value < $1.value })?.key ?? 9
        return (optimalHour - 1) ... (optimalHour + 1)
    }

    private func calculateLongestRecentStreak(_ habit: Habit) -> Int {
        let recentLogs = habit.logs.suffix(30).sorted { $0.completionDate < $1.completionDate }
        var currentStreak = 0
        var longestStreak = 0

        for log in recentLogs {
            if log.isCompleted {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return longestStreak
    }

    private func calculateStreakAcceleration(_ habit: Habit) -> Double {
        let recentLogs = habit.logs.suffix(14).sorted { $0.completionDate < $1.completionDate }
        guard recentLogs.count >= 7 else { return 0.0 }

        let firstHalf = recentLogs.prefix(7)
        let secondHalf = recentLogs.suffix(7)

        let firstHalfRate = Double(firstHalf.filter(\.isCompleted).count) / Double(firstHalf.count)
        let secondHalfRate = Double(secondHalf.filter(\.isCompleted).count) / Double(secondHalf.count)

        return secondHalfRate - firstHalfRate
    }

    private func analyzeWeekendBreakPattern(_ habit: Habit) -> Double {
        let calendar = Calendar.current
        let weekendLogs = habit.logs.filter { log in
            let weekday = calendar.component(.weekday, from: log.completionDate)
            return weekday == 1 || weekday == 7 // Sunday or Saturday
        }

        guard !weekendLogs.isEmpty else { return 0.0 }

        let weekendCompletionRate = Double(weekendLogs.filter(\.isCompleted).count) / Double(weekendLogs.count)

        let weekdayLogs = habit.logs.filter { log in
            let weekday = calendar.component(.weekday, from: log.completionDate)
            return weekday >= 2 && weekday <= 6 // Monday to Friday
        }

        guard !weekdayLogs.isEmpty else { return 0.0 }

        let weekdayCompletionRate = Double(weekdayLogs.filter(\.isCompleted).count) / Double(weekdayLogs.count)

        return max(0, weekdayCompletionRate - weekendCompletionRate)
    }

    private func calculateAverageCompletionGap(_ habit: Habit) -> Double {
        let completedLogs = habit.logs.filter(\.isCompleted).sorted { $0.completionDate < $1.completionDate }

        guard completedLogs.count >= 2 else { return 0.0 }

        var totalGap: TimeInterval = 0
        var gapCount = 0

        for i in 1 ..< completedLogs.count {
            let gap = completedLogs[i].completionDate.timeIntervalSince(completedLogs[i - 1].completionDate)
            totalGap += gap
            gapCount += 1
        }

        return totalGap / Double(gapCount) / (24 * 60 * 60) // Convert to days
    }

    private func calculateRecentFailureRate(_ habit: Habit) -> Double {
        let recentLogs = habit.logs.suffix(10)
        guard !recentLogs.isEmpty else { return 0.0 }

        let failedLogs = recentLogs.filter { !$0.isCompleted }
        return Double(failedLogs.count) / Double(recentLogs.count)
    }
}
