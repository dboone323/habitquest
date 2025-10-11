import Combine
import SwiftData
import SwiftUI

/// ViewModel for StreakAnalyticsView handling business logic and data management
@MainActor
final class StreakAnalyticsViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @Published var showingExportSheet = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var analyticsData: StreakAnalyticsData?
    @Published var selectedTimeframe: Timeframe = .month

    enum Timeframe: String, CaseIterable, Equatable {
        case week = "7D"
        case month = "30D"
        case quarter = "90D"
        case year = "1Y"

        var days: Int {
            switch self {
            case .week: 7
            case .month: 30
            case .quarter: 90
            case .year: 365
            }
        }

        var title: String {
            switch self {
            case .week: "This Week"
            case .month: "This Month"
            case .quarter: "3 Months"
            case .year: "This Year"
            }
        }
    }

    private var modelContext: ModelContext?
    private var streakService: StreakService?

    init() {
        // ModelContext will be set up later via setupService
    }

    func setupService(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.streakService = StreakService(modelContext: modelContext)
    }

    func loadAnalytics() async {
        self.isLoading = true
        self.errorMessage = nil
        defer { isLoading = false }

        guard let modelContext, let service = streakService else {
            self.errorMessage = "Failed to initialize services"
            return
        }

        do {
            // Get all habits
            let habitDescriptor = FetchDescriptor<Habit>()
            let habits = try modelContext.fetch(habitDescriptor)

            let analytics = await generateAnalyticsData(habits: habits, service: service)
            self.analyticsData = analytics
        } catch {
            self.errorMessage = "Failed to load analytics: \(error.localizedDescription)"
        }
    }

    func refreshAnalytics() async {
        await self.loadAnalytics()
    }

    func exportAnalytics() async {
        // Export logic here - placeholder for future implementation
        print("Exporting analytics data...")
    }

    func shareAnalyticsReport() {
        // Sharing logic here
        // For now, just a placeholder action
        print("Sharing analytics report...")
    }

    private func generateAnalyticsData(habits: [Habit], service: StreakService) async
    -> StreakAnalyticsData {
        var streakAnalytics: [StreakAnalytics] = []
        var topPerformers: [TopPerformer] = []

        for habit in habits {
            let analytics = await service.getStreakAnalytics(for: habit)
            streakAnalytics.append(analytics)

            if analytics.currentStreak > 0 {
                topPerformers.append(
                    TopPerformer(
                        habit: habit,
                        currentStreak: analytics.currentStreak,
                        longestStreak: analytics.longestStreak,
                        consistency: analytics.streakPercentile
                    )
                )
            }
        }

        // Sort top performers by current streak
        topPerformers.sort { $0.currentStreak > $1.currentStreak }

        return await StreakAnalyticsData(
            totalActiveStreaks: streakAnalytics.count(where: { $0.currentStreak > 0 }),
            longestOverallStreak: streakAnalytics.map(\.longestStreak).max() ?? 0,
            averageConsistency: self.calculateAverageConsistency(streakAnalytics),
            milestonesAchieved: self.countRecentMilestones(streakAnalytics),
            streakDistribution: self.generateStreakDistribution(streakAnalytics),
            topPerformingHabits: topPerformers,
            consistencyInsights: self.generateConsistencyInsights(streakAnalytics),
            weeklyPatterns: self.generateWeeklyPatterns(habits: habits, service: service)
        )
    }

    private func calculateAverageConsistency(_ analytics: [StreakAnalytics]) -> Double {
        let consistencies = analytics.map(\.streakPercentile)
        return consistencies.isEmpty ? 0 : consistencies.reduce(0, +) / Double(consistencies.count)
    }

    private func countRecentMilestones(_ analytics: [StreakAnalytics]) -> Int {
        // Simplified - count current milestones as "recent achievements"
        analytics.compactMap(\.currentMilestone).count
    }

    private func generateStreakDistribution(_ analytics: [StreakAnalytics])
    -> [StreakDistributionData] {
        let streaks = analytics.map(\.currentStreak)
        let ranges = [
            (0 ... 2, "Getting Started"),
            (3 ... 6, "Building"),
            (7 ... 29, "Strong"),
            (30 ... 99, "Impressive"),
            (100 ... Int.max, "Legendary")
        ]

        return ranges.map { range, label in
            let count = streaks.count(where: { range.contains($0) })
            return StreakDistributionData(range: label, count: count)
        }
    }

    private func generateConsistencyInsights(_ analytics: [StreakAnalytics]) -> [ConsistencyInsight] {
        // Generate insights based on streak patterns
        var insights: [ConsistencyInsight] = []

        let strongStreaks = analytics.count(where: { $0.currentStreak >= 7 })

        if strongStreaks > 0 {
            insights.append(
                ConsistencyInsight(
                    title: "Strong Momentum",
                    description: "You have \(strongStreaks) habits with week+ streaks",
                    type: .positive
                )
            )
        }

        let strugglingHabits = analytics.count(where: { $0.currentStreak == 0 })
        if strugglingHabits > 0 {
            insights.append(
                ConsistencyInsight(
                    title: "Growth Opportunity",
                    description: "\(strugglingHabits) habits could use more attention",
                    type: .improvement
                )
            )
        }

        return insights
    }

    private func generateWeeklyPatterns(habits _: [Habit], service _: StreakService) async
    -> [WeeklyPattern] {
        // Simplified weekly pattern generation
        let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return daysOfWeek.map { day in
            WeeklyPattern(day: day, completionRate: Double.random(in: 0.3 ... 0.9)) // Placeholder
        }
    }
}
