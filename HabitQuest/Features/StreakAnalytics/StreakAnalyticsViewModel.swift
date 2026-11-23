import Combine
import HabitQuestCore
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

    private let logger = HabitQuestLogger(category: .uiCategory)

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
        streakService = StreakService(modelContext: modelContext)
    }

    func loadAnalytics() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let modelContext, let service = streakService else {
            errorMessage = "Failed to initialize services"
            return
        }

        do {
            // Get all habits
            let habitDescriptor = FetchDescriptor<Habit>()
            let habits = try modelContext.fetch(habitDescriptor)

            let analytics = await generateAnalyticsData(habits: habits, service: service)
            analyticsData = analytics
        } catch {
            errorMessage = "Failed to load analytics: \(error.localizedDescription)"
        }
    }

    func refreshAnalytics() async {
        await loadAnalytics()
    }

    func exportAnalytics() async {
        guard let modelContext else { return }
        do {
            let data = try await DataExportService.exportUserData(from: modelContext)
            let filename = DataExportService.generateExportFilename()
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: tempURL)
            logger.info("Exported analytics data to \(tempURL.path)")
        } catch {
            logger.error("Failed to export analytics: \(error.localizedDescription)")
        }
    }

    func shareAnalyticsReport() {
        if let top = analyticsData?.topPerformingHabits.first {
            ShareManager.shared.shareStreak(top.currentStreak, habit: top.habit.name) { _ in }
        }
    }

    private func generateAnalyticsData(habits: [Habit], service: StreakService) async
        -> StreakAnalyticsData
    {
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
            averageConsistency: calculateAverageConsistency(streakAnalytics),
            milestonesAchieved: countRecentMilestones(streakAnalytics),
            streakDistribution: generateStreakDistribution(streakAnalytics),
            topPerformingHabits: topPerformers,
            consistencyInsights: generateConsistencyInsights(streakAnalytics),
            weeklyPatterns: generateWeeklyPatterns(habits: habits, service: service)
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
        -> [StreakDistributionData]
    {
        let streaks = analytics.map(\.currentStreak)
        let ranges = [
            (0...2, "Getting Started"),
            (3...6, "Building"),
            (7...29, "Strong"),
            (30...99, "Impressive"),
            (100...Int.max, "Legendary"),
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

    private func generateWeeklyPatterns(habits: [Habit], service: StreakService) async
        -> [WeeklyPattern]
    {
        let calendar = Calendar.current
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let weekdayMapping: [String: Int] = [
            "Sun": 1, "Mon": 2, "Tue": 3, "Wed": 4, "Thu": 5, "Fri": 6, "Sat": 7
        ]

        var weekdayCompletions: [Int: Int] = [:]
        var weekdayTotals: [Int: Int] = [:]

        for habit in habits {
            let streakData = await service.getStreakData(for: habit, days: 28)
            for day in streakData {
                let weekday = calendar.component(.weekday, from: day.date)
                weekdayTotals[weekday, default: 0] += 1
                if day.isCompleted {
                    weekdayCompletions[weekday, default: 0] += 1
                }
            }
        }

        return dayNames.map { day in
            let weekdayNumber = weekdayMapping[day] ?? 1
            let total = weekdayTotals[weekdayNumber] ?? 0
            let completed = weekdayCompletions[weekdayNumber] ?? 0
            let rate = total > 0 ? Double(completed) / Double(total) : 0.0
            return WeeklyPattern(day: day, completionRate: rate)
        }
    }
}
