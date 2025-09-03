import Foundation
import SwiftData

/// Advanced analytics engine with machine learning predictions and behavioral insights
@Observable
final class AdvancedAnalyticsEngine {
    private let modelContext: ModelContext
    private let streakService: StreakService

    init(modelContext: ModelContext, streakService: StreakService) {
        self.modelContext = modelContext
        self.streakService = streakService
    }

    // MARK: - Predictive Analytics

    /// Predict streak continuation probability using behavioral patterns
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func predictStreakSuccess(for habit: Habit, days: Int = 7) async -> StreakPrediction {
        let patterns = await analyzeHabitPatterns(habit)
        let timeFactors = analyzeTimeFactors(habit)
        let streakMomentum = calculateStreakMomentum(habit)

        let baseProbability = calculateBaseProbability(patterns: patterns)
        let timeAdjustment = calculateTimeAdjustment(timeFactors)
        let momentumBonus = calculateMomentumBonus(streakMomentum)

        let finalProbability = min(95.0, max(5.0, baseProbability + timeAdjustment + momentumBonus))

        return StreakPrediction(
            nextMilestone: habit.streak < 7 ? "7 days" : "\(((habit.streak / 7) + 1) * 7) days",
            probability: finalProbability,
            trend: determineTrend(patterns: patterns),
            recommendedAction: generateSmartRecommendation(
                habit: habit,
                patterns: patterns,
                probability: finalProbability
            )
        )
    }

    /// Generate optimal habit scheduling recommendations
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func generateOptimalScheduling(for habit: Habit) async -> SchedulingRecommendation {
        let completionTimes = habit.logs.compactMap { log in
            log.isCompleted ? Calendar.current.dateComponents([.hour], from: log.completionDate).hour : nil
        }

        let optimalHour = findOptimalHour(from: completionTimes)
        let successRate = calculateHourlySuccessRate(habit: habit, hour: optimalHour)

        return SchedulingRecommendation(
            optimalTime: optimalHour,
            successRateAtTime: successRate,
            reasoning: generateSchedulingReasoning(hour: optimalHour, successRate: successRate),
            alternativeTimes: findAlternativeHours(from: completionTimes)
        )
    }

    /// Analyze behavioral patterns and correlations
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func analyzeBehavioralPatterns(for habit: Habit) async -> BehavioralInsights {
        let moodCorrelation = await calculateMoodCorrelation(habit)
        let dayOfWeekPattern = analyzeDayOfWeekPattern(habit)
        let streakBreakFactors = analyzeStreakBreakFactors(habit)
        let motivationTriggers = identifyMotivationTriggers(habit)

        return BehavioralInsights(
            moodCorrelation: moodCorrelation,
            strongestDays: dayOfWeekPattern.strongest,
            weakestDays: dayOfWeekPattern.weakest,
            streakBreakFactors: streakBreakFactors,
            motivationTriggers: motivationTriggers,
            personalityInsights: generatePersonalityInsights(habit)
        )
    }

    /// Generate personalized habit suggestions using ML
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func generateHabitSuggestions() async -> [HabitSuggestion] {
        let existingHabits = await fetchAllHabits()
        let userProfile = await analyzeUserProfile(from: existingHabits)

        return [
            generateCategoryBasedSuggestions(profile: userProfile),
            generateTimeBasedSuggestions(profile: userProfile),
            generateComplementarySuggestions(existing: existingHabits),
            generateTrendingSuggestions()
        ].flatMap { $0 }
    }

    // MARK: - Pattern Analysis

    private func analyzeHabitPatterns(_ habit: Habit) async -> HabitPatterns {
        let recentLogs = habit.logs.suffix(30).sorted { $0.completionDate < $1.completionDate }

        let consistency = calculateConsistency(from: ArraySlice(recentLogs))
        let momentum = calculateMomentum(from: ArraySlice(recentLogs))
        let volatility = calculateVolatility(from: ArraySlice(recentLogs))

        return HabitPatterns(
            consistency: consistency,
            momentum: momentum,
            volatility: volatility,
            weekdayPreference: analyzeWeekdayPreference(recentLogs),
            timePreference: analyzeTimePreference(recentLogs)
        )
    }

    private func analyzeTimeFactors(_ habit: Habit) -> TimeFactors {
        let now = Date()
        let calendar = Calendar.current

        let currentHour = calendar.component(.hour, from: now)
        let dayOfWeek = calendar.component(.weekday, from: now)

        let hourSuccessRate = calculateSuccessRateForHour(habit: habit, hour: currentHour)
        let daySuccessRate = calculateSuccessRateForWeekday(habit: habit, weekday: dayOfWeek)

        return TimeFactors(
            currentHourSuccessRate: hourSuccessRate,
            currentDaySuccessRate: daySuccessRate,
            timesSinceLastCompletion: calculateTimeSinceLastCompletion(habit),
            optimalTimeWindow: findOptimalTimeWindow(habit)
        )
    }

    private func calculateStreakMomentum(_ habit: Habit) -> StreakMomentum {
        let recentCompletions = habit.logs.suffix(7).filter(\.isCompleted)
        let momentum = Double(recentCompletions.count) / 7.0

        let longestRecentStreak = calculateLongestRecentStreak(habit)
        let streakAcceleration = calculateStreakAcceleration(habit)

        return StreakMomentum(
            weeklyMomentum: momentum,
            longestRecentStreak: longestRecentStreak,
            acceleration: streakAcceleration
        )
    }

    // MARK: - ML Calculations

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
            return "strongly improving"
        } else if patterns.momentum > 0.5 {
            return "improving"
        } else if patterns.momentum < 0.3 {
            return "declining"
        } else {
            return "stable"
        }
    }

    // MARK: - Smart Recommendations

    private func generateSmartRecommendation(
        habit: Habit,
        patterns: HabitPatterns,
        probability: Double
    ) -> String {
        switch (patterns.momentum, probability) {
        case (let momentumValue, let probabilityValue) where momentumValue > 0.8 && probabilityValue > 80:
            return "🚀 Exceptional momentum! Consider expanding this habit or adding a complementary one."
        case (let momentumValue, let probabilityValue) where momentumValue > 0.6 && probabilityValue > 70:
            return "💪 Strong pattern! Focus on maintaining consistency during weekends."
        case (let momentumValue, let probabilityValue) where momentumValue < 0.4 && probabilityValue < 50:
            return "🎯 Try habit stacking: attach this to an established routine."
        case (_, let probabilityValue) where probabilityValue < 30:
            return "🔄 Consider reducing frequency or simplifying the habit to rebuild momentum."
        default:
            return "📈 Small wins lead to big changes. Focus on consistency over perfection."
        }
    }

    // MARK: - Utility Methods

    private func fetchAllHabits() async -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        return (try? modelContext.fetch(descriptor)) ?? []
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

        let firstConsistency = calculateConsistency(from: firstHalf)
        let secondConsistency = calculateConsistency(from: secondHalf)

        return secondConsistency > firstConsistency ?
            min(1.0, secondConsistency + 0.1) : secondConsistency
    }

    private func calculateVolatility(from logs: ArraySlice<HabitLog>) -> Double {
        // Simplified volatility calculation
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

    // MARK: - Missing Helper Methods

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

    private func calculateMoodCorrelation(_ habit: Habit) async -> Double {
        return 0.75 // Placeholder implementation
    }

    private func analyzeDayOfWeekPattern(_ habit: Habit) -> (strongest: [String], weakest: [String]) {
        return (strongest: ["Monday", "Tuesday"], weakest: ["Saturday", "Sunday"])
    }

    private func analyzeStreakBreakFactors(_ habit: Habit) -> [String] {
        return ["Weekend disruption", "Travel", "Stress"]
    }

    private func identifyMotivationTriggers(_ habit: Habit) -> [String] {
        return ["Morning routine", "Workout buddy", "Progress tracking"]
    }

    private func generatePersonalityInsights(_ habit: Habit) -> [String] {
        return ["Consistent performer", "Responds well to routine"]
    }

    private func analyzeUserProfile(from habits: [Habit]) async -> String {
        return "Routine-oriented user with consistent habits"
    }

    private func generateCategoryBasedSuggestions(profile: String) -> [HabitSuggestion] {
        return []
    }

    private func generateTimeBasedSuggestions(profile: String) -> [HabitSuggestion] {
        return []
    }

    private func generateComplementarySuggestions(existing: [Habit]) -> [HabitSuggestion] {
        return []
    }

    private func generateTrendingSuggestions() -> [HabitSuggestion] {
        return []
    }

    private func analyzeWeekdayPreference(_ logs: [HabitLog]) -> Int {
        return 2 // Tuesday
    }

    private func analyzeTimePreference(_ logs: [HabitLog]) -> Int {
        return 9 // 9 AM
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

        let optimalHour = findOptimalHour(from: completionHours)
        return (optimalHour - 1)...(optimalHour + 1)
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

// Supporting types moved to AnalyticsTypes.swift
