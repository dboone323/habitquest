import SwiftData
import SwiftUI
import class HabitQuest.Habit
import class HabitQuest.HabitLog
import enum HabitQuest.HabitCategory

// Import model types
/// Service responsible for productivity metrics and performance analysis
final class ProductivityMetricsService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Get productivity metrics for a specific time period
    func getProductivityMetrics(for period: TimePeriod) async -> ProductivityMetrics {
        let habits = await fetchAllHabits()
        let startDate = period.startDate
        let logs = habits.flatMap(\.logs).filter { $0.completionDate >= startDate }

        let completedLogs = logs.filter(\.isCompleted)
        let totalPossibleCompletions = habits.count * period.dayCount

        return ProductivityMetrics(
            period: period,
            completionRate: Double(completedLogs.count) / Double(max(totalPossibleCompletions, 1)),
            streakCount: self.calculateActiveStreaks(habits: habits),
            xpEarned: completedLogs.reduce(0) { $0 + $1.xpEarned },
            missedOpportunities: totalPossibleCompletions - completedLogs.count
        )
    }

    /// Calculate productivity score based on various metrics
    func calculateProductivityScore() async -> ProductivityScore {
        let habits = await fetchAllHabits()
        let logs = await fetchAllLogs()

        // Calculate completion consistency
        let completionRate = self.calculateOverallCompletionRate(logs: logs)

        // Calculate streak health
        let streakHealth = self.calculateStreakHealth(habits: habits)

        // Calculate habit diversity score
        let diversityScore = self.calculateHabitDiversityScore(habits: habits)

        // Calculate momentum score
        let momentumScore = self.calculateMomentumScore(logs: logs)

        // Overall productivity score (weighted average)
        let overallScore = (completionRate * 0.4) + (streakHealth * 0.3) + (diversityScore * 0.15) +
            (momentumScore * 0.15)

        return ProductivityScore(
            overallScore: overallScore,
            completionRate: completionRate,
            streakHealth: streakHealth,
            diversityScore: diversityScore,
            momentumScore: momentumScore,
            recommendations: self.generateProductivityRecommendations(
                completionRate: completionRate,
                streakHealth: streakHealth,
                diversityScore: diversityScore,
                momentumScore: momentumScore
            )
        )
    }

    /// Get productivity insights and recommendations
    func getProductivityInsights() async -> ProductivityInsights {
        let score = await calculateProductivityScore()
        let habits = await fetchAllHabits()
        let recentLogs = await fetchRecentLogs(days: 7)

        let weeklyCompletionRate = Double(recentLogs.filter(\.isCompleted).count) / Double(max(recentLogs.count, 1))
        let activeStreaks = self.calculateActiveStreaks(habits: habits)
        let totalXPThisWeek = recentLogs.filter(\.isCompleted).reduce(0) { $0 + $1.xpEarned }

        return await ProductivityInsights(
            currentScore: score,
            weeklyCompletionRate: weeklyCompletionRate,
            activeStreaks: activeStreaks,
            xpEarnedThisWeek: totalXPThisWeek,
            topPerformingCategories: self.getTopPerformingCategories(),
            improvementAreas: self.identifyImprovementAreas(score: score),
            nextMilestones: self.calculateNextMilestones(habits: habits)
        )
    }

    /// Calculate productivity trends over time
    func calculateProductivityTrends(days: Int = 30) async -> ProductivityTrends {
        var dailyScores: [Date: Double] = [:]
        let calendar = Calendar.current

        for dayOffset in 0 ..< days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let dayLogs = await fetchLogs(for: date)

            if !dayLogs.isEmpty {
                let dayCompletionRate = Double(dayLogs.filter(\.isCompleted).count) / Double(dayLogs.count)
                dailyScores[date] = dayCompletionRate
            }
        }

        let sortedDates = dailyScores.keys.sorted()
        let scores = sortedDates.compactMap { dailyScores[$0] }

        // Calculate trend
        let trend: ProductivityTrend
        if scores.count >= 7 {
            let recent = scores.suffix(3).reduce(0, +) / 3
            let previous = scores.dropLast(3).suffix(3).reduce(0, +) / 3

            if recent > previous + 0.05 {
                trend = .improving
            } else if recent < previous - 0.05 {
                trend = .declining
            } else {
                trend = .stable
            }
        } else {
            trend = .stable
        }

        return ProductivityTrends(
            dailyScores: scores,
            trend: trend,
            averageScore: scores.reduce(0, +) / Double(max(scores.count, 1)),
            bestDay: scores.max() ?? 0,
            consistencyScore: self.calculateConsistencyScore(scores: scores)
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

    private func fetchRecentLogs(days: Int) async -> [HabitLog] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let logs = await fetchAllLogs()
        return logs.filter { $0.completionDate >= startDate }
    }

    private func fetchLogs(for date: Date) async -> [HabitLog] {
        let logs = await fetchAllLogs()
        return logs.filter { Calendar.current.isDate($0.completionDate, inSameDayAs: date) }
    }

    private func calculateActiveStreaks(habits: [Habit]) -> Int {
        habits.count(where: { $0.streak > 0 })
    }

    private func calculateOverallCompletionRate(logs: [HabitLog]) -> Double {
        guard !logs.isEmpty else { return 0.0 }
        let completedCount = logs.filter(\.isCompleted).count
        return Double(completedCount) / Double(logs.count)
    }

    private func calculateStreakHealth(habits: [Habit]) -> Double {
        let totalStreaks = habits.reduce(0) { $0 + $1.streak }
        let averageStreak = Double(totalStreaks) / Double(max(habits.count, 1))

        // Normalize to 0-1 scale (assuming 30 days is excellent streak health)
        return min(averageStreak / 30.0, 1.0)
    }

    private func calculateHabitDiversityScore(habits: [Habit]) -> Double {
        let categories = Set(habits.map(\.category))
        let totalCategories = HabitCategory.allCases.count

        // Score based on category diversity
        return Double(categories.count) / Double(totalCategories)
    }

    private func calculateMomentumScore(logs: [HabitLog]) -> Double {
        let recentLogs = logs.filter {
            $0.completionDate >= Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        }
        let olderLogs = logs.filter {
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: weekAgo) ?? Date()
            return $0.completionDate >= twoWeeksAgo && $0.completionDate < weekAgo
        }

        let recentRate = Double(recentLogs.filter(\.isCompleted).count) / Double(max(recentLogs.count, 1))
        let olderRate = Double(olderLogs.filter(\.isCompleted).count) / Double(max(olderLogs.count, 1))

        // Momentum score based on improvement
        let momentum = recentRate - olderRate
        return max(0, min(1, (momentum + 0.2) / 0.4)) // Normalize to 0-1 scale
    }

    private func generateProductivityRecommendations(
        completionRate: Double,
        streakHealth: Double,
        diversityScore: Double,
        momentumScore: Double
    ) -> [String] {
        var recommendations: [String] = []

        if completionRate < 0.6 {
            recommendations.append("Focus on building consistency by completing habits daily")
        }

        if streakHealth < 0.3 {
            recommendations.append("Work on maintaining longer streaks by setting realistic goals")
        }

        if diversityScore < 0.5 {
            recommendations.append("Add habits from different categories to create balance")
        }

        if momentumScore < 0.4 {
            recommendations.append("Review recent performance and adjust habits that aren't working")
        }

        if recommendations.isEmpty {
            recommendations.append("Keep up the excellent work! Consider challenging yourself with harder habits")
        }

        return recommendations
    }

    private func getTopPerformingCategories() async -> [AnalyticsHabitCategory] {
        let habits = await fetchAllHabits()
        let categoryPerformance = Dictionary(grouping: habits, by: \.category).mapValues { categoryHabits in
            let allLogs = categoryHabits.flatMap(\.logs)
            return Double(allLogs.filter(\.isCompleted).count) / Double(max(allLogs.count, 1))
        }

        return categoryPerformance.sorted { $0.value > $1.value }.prefix(3).map { self.convertToAnalyticsCategory($0.key) }
    }

    private func convertToAnalyticsCategory(_ category: HabitCategory) -> AnalyticsHabitCategory {
        switch category {
        case .health: .health
        case .fitness: .fitness
        case .learning: .learning
        case .productivity: .productivity
        case .social: .social
        case .creativity: .creativity
        case .mindfulness: .mindfulness
        case .other: .other
        }
    }

    private func identifyImprovementAreas(score: ProductivityScore) -> [ProductivityArea] {
        var areas: [ProductivityArea] = []

        if score.completionRate < 0.7 {
            areas.append(.consistency)
        }

        if score.streakHealth < 0.5 {
            areas.append(.streaks)
        }

        if score.diversityScore < 0.6 {
            areas.append(.diversity)
        }

        if score.momentumScore < 0.5 {
            areas.append(.momentum)
        }

        return areas
    }

    private func calculateNextMilestones(habits: [Habit]) -> [ProductivityMilestone] {
        var milestones: [ProductivityMilestone] = []

        let totalCompletions = habits.reduce(0) { $0 + $1.logs.filter(\.isCompleted).count }
        let nextCompletionMilestone = ((totalCompletions / 100) + 1) * 100

        milestones.append(ProductivityMilestone(
            type: .totalCompletions,
            currentValue: totalCompletions,
            targetValue: nextCompletionMilestone,
            description: "Reach \(nextCompletionMilestone) total habit completions"
        ))

        let longestStreak = habits.map(\.streak).max() ?? 0
        let nextStreakMilestone = ((longestStreak / 30) + 1) * 30

        milestones.append(ProductivityMilestone(
            type: .longestStreak,
            currentValue: longestStreak,
            targetValue: nextStreakMilestone,
            description: "Achieve a \(nextStreakMilestone)-day streak"
        ))

        return milestones
    }

    private func calculateConsistencyScore(scores: [Double]) -> Double {
        guard scores.count > 1 else { return 1.0 }

        let mean = scores.reduce(0, +) / Double(scores.count)
        let variance = scores.map { pow($0 - mean, 2) }.reduce(0, +) / Double(scores.count)
        let standardDeviation = sqrt(variance)

        // Lower standard deviation means higher consistency
        return max(0, 1.0 - (standardDeviation / mean))
    }
}

// MARK: - Supporting Types
