import Combine
import SwiftData
import SwiftUI

/// ViewModel for StreakAnalyticsView handling business logic and data management
@MainActor
final class StreakAnalyticsViewModel: ObservableObject, BaseViewModel {
    // MARK: - State

    struct State {
        var showingExportSheet = false
        var isLoading = false
        var errorMessage: String?
        var analyticsData: StreakAnalyticsData?
        var selectedTimeframe: Timeframe = .month
    }

    // MARK: - Actions

    enum Action {
        case setupService(ModelContext)
        case loadAnalytics
        case refreshAnalytics
        case exportAnalytics
        case shareAnalyticsReport
        case setTimeframe(Timeframe)
        case setShowingExportSheet(Bool)
    }

    // MARK: - Properties

    @Published var state = State()

    var isLoading: Bool {
        get { state.isLoading }
        set { state.isLoading = newValue }
    }

    var errorMessage: String? {
        get { state.errorMessage }
        set { state.errorMessage = newValue }
    }

    var analyticsData: StreakAnalyticsData? {
        get { state.analyticsData }
        set { state.analyticsData = newValue }
    }

    var selectedTimeframe: Timeframe {
        get { state.selectedTimeframe }
        set { state.selectedTimeframe = newValue }
    }

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

    // MARK: - BaseViewModel Protocol

    func handle(_ action: Action) {
        switch action {
        case let .setupService(context):
            self.modelContext = context
            self.streakService = StreakService(modelContext: context)

        case .loadAnalytics:
            self.loadAnalytics()

        case .refreshAnalytics:
            self.handle(.loadAnalytics)

        case .exportAnalytics:
            self.exportAnalytics()

        case .shareAnalyticsReport:
            self.shareAnalyticsReport()

        case let .setTimeframe(timeframe):
            self.state.selectedTimeframe = timeframe
            self.handle(.loadAnalytics)

        case let .setShowingExportSheet(showing):
            self.state.showingExportSheet = showing
        }
    }

    // MARK: - Public Methods

    func loadAnalytics() {
        self.state.isLoading = true
        self.state.errorMessage = nil
        defer { self.state.isLoading = false }

        guard let modelContext, let service = streakService else {
            self.state.errorMessage = "Failed to initialize services"
            return
        }

        do {
            // Get all habits
            let habitDescriptor = FetchDescriptor<Habit>()
            let habits = try modelContext.fetch(habitDescriptor)

            let analytics = generateAnalyticsData(habits: habits, service: service)
            self.state.analyticsData = analytics
        } catch {
            self.state.errorMessage = "Failed to load analytics: \(error.localizedDescription)"
        }
    }

    func refreshAnalytics() {
        self.loadAnalytics()
    }

    func exportAnalytics() {
        // Export logic here - placeholder for future implementation
        print("Exporting analytics data...")
    }

    func shareAnalyticsReport() {
        // Sharing logic here
        // For now, just a placeholder action
        print("Sharing analytics report...")
    }

    private func generateAnalyticsData(habits: [Habit], service: StreakService)
        -> StreakAnalyticsData
    {
        var streakAnalytics: [StreakAnalytics] = []
        var topPerformers: [TopPerformer] = []

        for habit in habits {
            let analytics = service.getStreakAnalytics(for: habit)
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

        return StreakAnalyticsData(
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
        -> [StreakDistributionData]
    {
        let streaks = analytics.map(\.currentStreak)
        let ranges = [
            (0 ... 2, "Getting Started"),
            (3 ... 6, "Building"),
            (7 ... 29, "Strong"),
            (30 ... 99, "Impressive"),
            (100 ... Int.max, "Legendary"),
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

    private func generateWeeklyPatterns(habits _: [Habit], service _: StreakService)
        -> [WeeklyPattern]
    {
        // Simplified weekly pattern generation
        let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return daysOfWeek.map { day in
            WeeklyPattern(day: day, completionRate: Double.random(in: 0.3 ... 0.9)) // Placeholder
        }
    }
}
