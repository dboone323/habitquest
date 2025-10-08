import Foundation
import SwiftData

/// Service responsible for predictive analytics and habit scheduling recommendations
final class PredictionService {
    private let modelContext: ModelContext
    private let streakService: StreakService

    init(modelContext: ModelContext, streakService: StreakService) {
        self.modelContext = modelContext
        self.streakService = streakService
    }

    /// Predict streak continuation probability using behavioral patterns
    func predictStreakSuccess(for habit: Habit, days _: Int = 7) async -> StreakPrediction {
        let patterns = await analyzeHabitPatterns(habit)
        let timeFactors = self.analyzeTimeFactors(habit)
        let streakMomentum = self.calculateStreakMomentum(habit)

        let baseProbability = self.calculateBaseProbability(patterns: patterns)
        let timeAdjustment = self.calculateTimeAdjustment(timeFactors)
        let momentumBonus = self.calculateMomentumBonus(streakMomentum)

        let finalProbability = min(95.0, max(5.0, baseProbability + timeAdjustment + momentumBonus))

        return StreakPrediction(
            nextMilestone: habit.streak < 7 ? "7 days" : "\(((habit.streak / 7) + 1) * 7) days",
            probability: finalProbability,
            trend: self.determineTrend(patterns: patterns),
            recommendedAction: self.generateSmartRecommendation(
                habit: habit,
                patterns: patterns,
                probability: finalProbability
            )
        )
    }

    /// Generate optimal habit scheduling recommendations
    func generateOptimalScheduling(for habit: Habit) async -> SchedulingRecommendation {
        let completionTimes = habit.logs.compactMap { log in
            log.isCompleted ? Calendar.current.dateComponents([.hour], from: log.completionDate).hour : nil
        }

        let optimalHour = self.findOptimalHour(from: completionTimes)
        let successRate = self.calculateHourlySuccessRate(habit: habit, hour: optimalHour)

        return SchedulingRecommendation(
            optimalTime: optimalHour,
            successRateAtTime: successRate,
            reasoning: self.generateSchedulingReasoning(hour: optimalHour, successRate: successRate),
            alternativeTimes: self.findAlternativeHours(from: completionTimes)
        )
    }

    // MARK: - Private Methods

    private func analyzeHabitPatterns(_ habit: Habit) async -> HabitPatterns {
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

    private func analyzeTimeFactors(_ habit: Habit) -> TimeFactors {
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

    private func calculateStreakMomentum(_ habit: Habit) -> StreakMomentum {
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

    private func calculateBaseProbability(patterns: HabitPatterns) -> Double {
        let consistencyWeight = 0.4
        let momentumWeight = 0.3
        let volatilityWeight = 0.3

        return (patterns.consistency * consistencyWeight) +
            (patterns.momentum * momentumWeight) +
            ((1.0 - patterns.volatility) * volatilityWeight) * 100
    }

    private func calculateTimeAdjustment(_ timeFactors: TimeFactors) -> Double {
        let hourAdjustment = (timeFactors.currentHourSuccessRate - 0.5) * 20
        let dayAdjustment = (timeFactors.currentDaySuccessRate - 0.5) * 15

        return hourAdjustment + dayAdjustment
    }

    private func calculateMomentumBonus(_ momentum: StreakMomentum) -> Double {
        let weeklyBonus = momentum.weeklyMomentum * 10
        let accelerationBonus = momentum.acceleration * 5

        return weeklyBonus + accelerationBonus
    }

    private func determineTrend(patterns: HabitPatterns) -> String {
        if patterns.momentum > 0.7 {
            "strongly improving"
        } else if patterns.momentum > 0.5 {
            "improving"
        } else if patterns.momentum < 0.3 {
            "declining"
        } else {
            "stable"
        }
    }

    private func generateSmartRecommendation(
        habit _: Habit,
        patterns: HabitPatterns,
        probability: Double
    ) -> String {
        switch (patterns.momentum, probability) {
        case let (momentumValue, probabilityValue) where momentumValue > 0.8 && probabilityValue > 80:
            "🚀 Exceptional momentum! Consider expanding this habit or adding a complementary one."
        case let (momentumValue, probabilityValue) where momentumValue > 0.6 && probabilityValue > 70:
            "💪 Strong pattern! Focus on maintaining consistency during weekends."
        case let (momentumValue, probabilityValue) where momentumValue < 0.4 && probabilityValue < 50:
            "🎯 Try habit stacking: attach this to an established routine."
        case let (_, probabilityValue) where probabilityValue < 30:
            "🔄 Consider reducing frequency or simplifying the habit to rebuild momentum."
        default:
            "📈 Small wins lead to big changes. Focus on consistency over perfection."
        }
    }

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

    private func findOptimalHour(from hours: [Int]) -> Int {
        guard !hours.isEmpty else { return 9 } // Default to 9 AM

        let hourCounts = Dictionary(grouping: hours, by: { $0 })
            .mapValues(\.count)

        return hourCounts.max(by: { $0.value < $1.value })?.key ?? 9
    }

    private func calculateHourlySuccessRate(habit: Habit, hour: Int) -> Double {
        let logsInHour = habit.logs.filter { log in
            Calendar.current.component(.hour, from: log.completionDate) == hour
        }

        guard !logsInHour.isEmpty else { return 0.5 }

        let completedInHour = logsInHour.filter(\.isCompleted).count
        return Double(completedInHour) / Double(logsInHour.count)
    }

    private func generateSchedulingReasoning(hour: Int, successRate: Double) -> String {
        let timeOfDay = hour < 12 ? "morning" : hour < 17 ? "afternoon" : "evening"
        return "Based on your patterns, \(timeOfDay) shows \(Int(successRate * 100))% success rate"
    }

    private func findAlternativeHours(from hours: [Int]) -> [Int] {
        let hourCounts = Dictionary(grouping: hours, by: { $0 })
            .mapValues(\.count)
            .sorted { $0.value > $1.value }

        return Array(hourCounts.prefix(3).map(\.key))
    }

    private func analyzeWeekdayPreference(_: [HabitLog]) -> Int {
        2 // Tuesday
    }

    private func analyzeTimePreference(_: [HabitLog]) -> [String] {
        ["9:00 AM"] // Default to 9 AM
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

        let optimalHour = self.findOptimalHour(from: completionHours)
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
}
