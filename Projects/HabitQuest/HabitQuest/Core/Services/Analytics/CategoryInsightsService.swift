import SwiftData
import SwiftUI

/// Service responsible for category-based analytics and insights
final class CategoryInsightsService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Get insights for all habit categories
    func getCategoryInsights() async -> [CategoryInsight] {
        let habits = await fetchAllHabits()
        let categories = Dictionary(grouping: habits) { $0.category }

        return categories.map { category, categoryHabits in
            let allLogs = categoryHabits.flatMap(\.logs)
            let completedLogs = allLogs.filter(\.isCompleted)

            return CategoryInsight(
                category: category,
                totalHabits: categoryHabits.count,
                completionRate: Double(completedLogs.count) / Double(max(allLogs.count, 1)),
                averageStreak: categoryHabits.reduce(0) { $0 + $1.streak } / max(categoryHabits.count, 1),
                totalXPEarned: completedLogs.reduce(0) { $0 + $1.xpEarned }
            )
        }
    }

    /// Calculate category breakdown statistics
    func calculateCategoryBreakdown(habits: [Habit]) async -> [CategoryStats] {
        let categories = Dictionary(grouping: habits) { $0.category }
        return categories.map { category, categoryHabits in
            let completedLogs = categoryHabits.flatMap(\.logs).filter(\.isCompleted)
            return CategoryStats(
                category: category,
                habitCount: categoryHabits.count,
                completionRate: Double(completedLogs.count) / Double(max(categoryHabits.count, 1)),
                totalXP: completedLogs.reduce(0) { $0 + $1.xpEarned }
            )
        }
    }

    /// Get detailed category performance metrics
    func getCategoryPerformance(category: HabitCategory) async -> CategoryPerformance {
        let habits = await fetchHabits(for: category)
        let allLogs = habits.flatMap(\.logs)
        let completedLogs = allLogs.filter(\.isCompleted)

        let completionRate = Double(completedLogs.count) / Double(max(allLogs.count, 1))
        let averageStreak = habits.reduce(0) { $0 + $1.streak } / max(habits.count, 1)
        let totalXP = completedLogs.reduce(0) { $0 + $1.xpEarned }

        // Calculate trend
        let recentLogs = allLogs.filter {
            $0.completionDate >= Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        }
        let olderLogs = allLogs.filter {
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: thirtyDaysAgo) ?? Date()
            return $0.completionDate >= sixtyDaysAgo && $0.completionDate < thirtyDaysAgo
        }

        let recentRate = Double(recentLogs.filter(\.isCompleted).count) / Double(max(recentLogs.count, 1))
        let olderRate = Double(olderLogs.filter(\.isCompleted).count) / Double(max(olderLogs.count, 1))

        let trend: CategoryTrend = if recentRate > olderRate + 0.1 {
            .improving
        } else if recentRate < olderRate - 0.1 {
            .declining
        } else {
            .stable
        }

        return CategoryPerformance(
            category: category,
            habitCount: habits.count,
            completionRate: completionRate,
            averageStreak: averageStreak,
            totalXP: totalXP,
            trend: trend,
            topPerformingHabits: self.getTopPerformingHabits(in: habits)
        )
    }

    /// Get category distribution across all habits
    func getCategoryDistribution() async -> [HabitCategory: Int] {
        let habits = await fetchAllHabits()
        return Dictionary(grouping: habits, by: \.category).mapValues { $0.count }
    }

    // MARK: - Private Methods

    private func fetchAllHabits() async -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        return (try? self.modelContext.fetch(descriptor)) ?? []
    }

    private func fetchHabits(for category: HabitCategory) async -> [Habit] {
        let habits = await fetchAllHabits()
        return habits.filter { $0.category == category }
    }

    private func getTopPerformingHabits(in habits: [Habit]) -> [HabitPerformanceSummary] {
        habits.map { habit in
            let completedLogs = habit.logs.filter(\.isCompleted)
            let completionRate = Double(completedLogs.count) / Double(max(habit.logs.count, 1))

            return HabitPerformanceSummary(
                habitId: habit.id,
                habitName: habit.name,
                completionRate: completionRate,
                currentStreak: habit.streak,
                totalXP: completedLogs.reduce(0) { $0 + $1.xpEarned }
            )
        }
        .sorted { $0.completionRate > $1.completionRate }
        .prefix(3)
        .map(\.self)
    }
}

// MARK: - Supporting Types

public struct CategoryPerformance {
    public let category: HabitCategory
    public let habitCount: Int
    public let completionRate: Double
    public let averageStreak: Int
    public let totalXP: Int
    public let trend: CategoryTrend
    public let topPerformingHabits: [HabitPerformanceSummary]
}

public struct HabitPerformanceSummary {
    let habitId: UUID
    let habitName: String
    let completionRate: Double
    let currentStreak: Int
    let totalXP: Int
}

public enum CategoryTrend {
    case improving
    case stable
    case declining
}
