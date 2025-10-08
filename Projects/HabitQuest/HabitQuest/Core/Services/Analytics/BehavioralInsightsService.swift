import Foundation
import SwiftData

/// Service responsible for analyzing behavioral patterns and generating insights
final class BehavioralInsightsService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Analyze comprehensive behavioral patterns and correlations
    func analyzeBehavioralPatterns(for habit: Habit) async -> BehavioralInsights {
        let moodCorrelation = await calculateMoodCorrelation(habit)
        let dayOfWeekPattern = self.analyzeDayOfWeekPattern(habit)
        let streakBreakFactors = self.analyzeStreakBreakFactors(habit)
        let motivationTriggers = self.identifyMotivationTriggers(habit)

        return BehavioralInsights(
            moodCorrelation: moodCorrelation,
            motivationTriggers: motivationTriggers,
            commonBreakPoints: streakBreakFactors,
            personalityInsights: self.generatePersonalityInsights(habit),
            recommendations: self.generateRecommendations(habit)
        )
    }

    /// Calculate correlation between mood and habit completion
    func calculateMoodCorrelation(_ habit: Habit) async -> Double {
        // This would integrate with mood tracking data
        // For now, return a placeholder based on completion patterns
        let recentCompletions = habit.logs.suffix(14).filter(\.isCompleted)
        let completionRate = Double(recentCompletions.count) / 14.0

        // Simulate mood correlation - higher completion rates correlate with better mood
        return min(1.0, completionRate + 0.2)
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

        // Analyze stress indicators
        let stressIndicators = self.analyzeStressIndicators(habit)
        factors.append(contentsOf: stressIndicators)

        // Default factors if none detected
        if factors.isEmpty {
            factors = ["Travel", "Stress", "Schedule changes"]
        }

        return factors
    }

    /// Identify motivation triggers based on completion patterns
    func identifyMotivationTriggers(_ habit: Habit) -> [String] {
        var triggers: [String] = []

        // Analyze morning routine patterns
        if self.analyzeMorningRoutinePattern(habit) > 0.7 {
            triggers.append("Morning routine")
        }

        // Analyze social accountability
        if self.analyzeSocialPatterns(habit) > 0.6 {
            triggers.append("Social accountability")
        }

        // Analyze progress tracking motivation
        if self.analyzeProgressTrackingMotivation(habit) > 0.5 {
            triggers.append("Progress tracking")
        }

        // Analyze reward system effectiveness
        if self.analyzeRewardSystemEffectiveness(habit) > 0.6 {
            triggers.append("Reward system")
        }

        // Default triggers if none strongly detected
        if triggers.isEmpty {
            triggers = ["Personal commitment", "Goal setting", "Habit stacking"]
        }

        return triggers
    }

    /// Generate personality insights based on habit patterns
    func generatePersonalityInsights(_ habit: Habit) -> [String] {
        var insights: [String] = []

        // Analyze consistency patterns
        let consistency = self.calculateConsistencyScore(habit)
        if consistency > 0.8 {
            insights.append("Highly disciplined and consistent")
        } else if consistency > 0.6 {
            insights.append("Reliable performer with good follow-through")
        } else {
            insights.append("Building consistency through practice")
        }

        // Analyze adaptability
        let adaptability = self.calculateAdaptabilityScore(habit)
        if adaptability > 0.7 {
            insights.append("Highly adaptable to changing circumstances")
        } else if adaptability > 0.4 {
            insights.append("Moderately flexible with routine changes")
        } else {
            insights.append("Prefers stable, predictable routines")
        }

        // Analyze time preferences
        let timePreference = self.analyzeTimePreference(habit)
        if timePreference.hour < 10 {
            insights.append("Early riser who thrives in the morning")
        } else if timePreference.hour < 15 {
            insights.append("Midday performer with steady energy")
        } else {
            insights.append("Evening person who peaks later in the day")
        }

        // Analyze streak patterns
        let streakPatterns = self.analyzeStreakPatterns(habit)
        if streakPatterns.longestStreak > 30 {
            insights.append("Capable of maintaining long-term commitments")
        } else if streakPatterns.averageStreak > 7 {
            insights.append("Good at building and maintaining momentum")
        } else {
            insights.append("Focuses on daily consistency over long streaks")
        }

        return insights
    }

    /// Generate personalized recommendations based on habit patterns
    func generateRecommendations(_ habit: Habit) -> [String] {
        var recommendations: [String] = []

        let consistency = self.calculateConsistencyScore(habit)
        let adaptability = self.calculateAdaptabilityScore(habit)
        let timePreference = self.analyzeTimePreference(habit)

        // Consistency-based recommendations
        if consistency < 0.5 {
            recommendations.append("Start with smaller, more achievable goals to build momentum")
            recommendations.append("Use habit stacking - attach new habits to existing routines")
        } else if consistency < 0.7 {
            recommendations.append("Set up accountability reminders or partner with a friend")
        }

        // Adaptability-based recommendations
        if adaptability < 0.4 {
            recommendations.append("Create a consistent environment that supports your habits")
            recommendations.append("Minimize major schedule disruptions during habit formation")
        }

        // Time-based recommendations
        if timePreference.hour < 10 {
            recommendations.append("Schedule important habits early in the day when energy is highest")
        } else if timePreference.hour > 18 {
            recommendations.append("Consider evening routines that align with your natural rhythm")
        }

        // Streak-based recommendations
        let streakPatterns = self.analyzeStreakPatterns(habit)
        if streakPatterns.longestStreak < 7 {
            recommendations.append("Focus on building 7-day streaks before extending goals")
        }

        // Default recommendations if analysis is inconclusive
        if recommendations.isEmpty {
            recommendations = [
                "Track your habits consistently to identify patterns",
                "Celebrate small wins to maintain motivation",
                "Adjust your approach based on what works for your lifestyle"
            ]
        }

        return recommendations
    }

    // MARK: - Private Analysis Methods

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

    private func analyzeStressIndicators(_ habit: Habit) -> [String] {
        var indicators: [String] = []

        // Analyze completion gaps during work weeks
        let workWeekGaps = self.analyzeWorkWeekGaps(habit)
        if workWeekGaps > 3.0 {
            indicators.append("Work stress")
        }

        // Analyze sudden drop-offs
        if self.analyzeSuddenDropOffs(habit) > 0.5 {
            indicators.append("Overwhelm or burnout")
        }

        return indicators
    }

    private func analyzeMorningRoutinePattern(_ habit: Habit) -> Double {
        let morningLogs = habit.logs.filter { log in
            Calendar.current.component(.hour, from: log.completionDate) < 10
        }

        guard !morningLogs.isEmpty else { return 0.0 }

        let morningCompletionRate = Double(morningLogs.filter(\.isCompleted).count) / Double(morningLogs.count)
        let overallCompletionRate = Double(habit.logs.filter(\.isCompleted).count) / Double(habit.logs.count)

        return morningCompletionRate / max(overallCompletionRate, 0.1)
    }

    private func analyzeSocialPatterns(_ habit: Habit) -> Double {
        // This would analyze social sharing/check-in patterns
        // For now, return a placeholder based on consistency
        let consistency = self.calculateConsistencyScore(habit)
        return min(1.0, consistency + 0.1)
    }

    private func analyzeProgressTrackingMotivation(_ habit: Habit) -> Double {
        // Analyze if completions increase after viewing progress
        // This is a simplified analysis based on streak patterns
        let streakConsistency = self.calculateStreakConsistency(habit)
        return streakConsistency
    }

    private func analyzeRewardSystemEffectiveness(_ habit: Habit) -> Double {
        // Analyze if completions cluster around reward milestones
        // Simplified analysis based on milestone achievement patterns
        let milestoneAchievements = habit.logs.filter { log in
            log.isCompleted && habit.streak > 0 && habit.streak % 7 == 0
        }

        guard !milestoneAchievements.isEmpty else { return 0.5 }

        // Calculate if completions increase around milestones
        let milestoneRate = Double(milestoneAchievements.count) / Double(habit.logs.count)
        return min(1.0, milestoneRate * 2.0)
    }

    private func calculateConsistencyScore(_ habit: Habit) -> Double {
        let recentLogs = habit.logs.suffix(30)
        guard !recentLogs.isEmpty else { return 0.0 }

        let completedCount = recentLogs.filter(\.isCompleted).count
        return Double(completedCount) / Double(recentLogs.count)
    }

    private func calculateAdaptabilityScore(_ habit: Habit) -> Double {
        // Analyze how well the habit maintains consistency despite schedule changes
        let monthlySegments = self.segmentLogsByMonth(habit.logs)

        guard monthlySegments.count >= 2 else { return 0.5 }

        var consistencyScores: [Double] = []

        for segment in monthlySegments {
            let completedCount = segment.filter(\.isCompleted).count
            let consistency = Double(completedCount) / Double(segment.count)
            consistencyScores.append(consistency)
        }

        // Calculate variance in consistency (lower variance = higher adaptability)
        let mean = consistencyScores.reduce(0, +) / Double(consistencyScores.count)
        let variance = consistencyScores.map { pow($0 - mean, 2) }.reduce(0, +) / Double(consistencyScores.count)

        return max(0, 1.0 - variance) // Lower variance = higher adaptability
    }

    private func analyzeTimePreference(_ habit: Habit) -> (hour: Int, reliability: Double) {
        let completionHours = habit.logs.compactMap { log in
            log.isCompleted ? Calendar.current.component(.hour, from: log.completionDate) : nil
        }

        guard !completionHours.isEmpty else { return (9, 0.5) }

        // Find the most frequent completion hour
        let hourCounts = Dictionary(grouping: completionHours, by: { $0 }).mapValues { $0.count }
        let mostCommonHour = hourCounts.max(by: { $0.value < $1.value })?.key ?? 9
        let hourFrequency = Double(completionHours.count(where: { $0 == mostCommonHour })) /
            Double(completionHours.count)

        return (mostCommonHour, hourFrequency)
    }

    private func analyzeStreakPatterns(_ habit: Habit) -> (longestStreak: Int, averageStreak: Double) {
        let completedLogs = habit.logs.filter(\.isCompleted).sorted { $0.completionDate < $1.completionDate }

        var currentStreak = 0
        var longestStreak = 0
        var allStreaks: [Int] = []

        for log in completedLogs {
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        }

        // Calculate average streak from streak history
        let averageStreak = allStreaks
            .isEmpty ? Double(habit.streak) : Double(allStreaks.reduce(0, +)) / Double(allStreaks.count)

        return (longestStreak, averageStreak)
    }

    private func calculateStreakConsistency(_ habit: Habit) -> Double {
        // Analyze how consistent streak maintenance is
        let streaks = self.calculateIndividualStreaks(habit)
        guard !streaks.isEmpty else { return 0.0 }

        let meanStreak = Double(streaks.reduce(0, +)) / Double(streaks.count)
        let variance = streaks.map { pow(Double($0) - meanStreak, 2) }.reduce(0, +) / Double(streaks.count)

        return max(
            0,
            1.0 - (variance / (meanStreak * meanStreak))
        ) // Lower variance relative to mean = higher consistency
    }

    private func segmentLogsByMonth(_ logs: [HabitLog]) -> [[HabitLog]] {
        let calendar = Calendar.current
        let groupedByMonth = Dictionary(grouping: logs) { log in
            calendar.component(.month, from: log.completionDate)
        }

        return groupedByMonth.values.map { Array($0) }
    }

    private func analyzeWorkWeekGaps(_ habit: Habit) -> Double {
        let calendar = Calendar.current
        let workWeekLogs = habit.logs.filter { log in
            let weekday = calendar.component(.weekday, from: log.completionDate)
            return weekday >= 2 && weekday <= 6 // Monday to Friday
        }

        guard workWeekLogs.count >= 2 else { return 0.0 }

        let sortedLogs = workWeekLogs.sorted { $0.completionDate < $1.completionDate }
        var totalGap: TimeInterval = 0
        var gapCount = 0

        for i in 1 ..< sortedLogs.count {
            let gap = sortedLogs[i].completionDate.timeIntervalSince(sortedLogs[i - 1].completionDate)
            totalGap += gap
            gapCount += 1
        }

        return totalGap / Double(gapCount) / (24 * 60 * 60) // Convert to days
    }

    private func analyzeSuddenDropOffs(_ habit: Habit) -> Double {
        let recentLogs = habit.logs.suffix(14).sorted { $0.completionDate < $1.completionDate }

        guard recentLogs.count >= 7 else { return 0.0 }

        let firstHalf = recentLogs.prefix(7)
        let secondHalf = recentLogs.suffix(7)

        let firstHalfRate = Double(firstHalf.filter(\.isCompleted).count) / Double(firstHalf.count)
        let secondHalfRate = Double(secondHalf.filter(\.isCompleted).count) / Double(secondHalf.count)

        return max(0, firstHalfRate - secondHalfRate)
    }

    private func calculateIndividualStreaks(_ habit: Habit) -> [Int] {
        var streaks: [Int] = []
        var currentStreak = 0

        for log in habit.logs.sorted { $0.completionDate < $1.completionDate } {
            if log.isCompleted {
                currentStreak += 1
            } else {
                if currentStreak > 0 {
                    streaks.append(currentStreak)
                    currentStreak = 0
                }
            }
        }

        if currentStreak > 0 {
            streaks.append(currentStreak)
        }

        return streaks
    }
}
