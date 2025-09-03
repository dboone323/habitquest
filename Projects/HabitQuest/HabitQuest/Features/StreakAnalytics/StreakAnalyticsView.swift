import SwiftData
import SwiftUI

/// Advanced analytics dashboard for streak insights and patterns
struct StreakAnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var streakService: StreakService?
    @State private var analyticsData: StreakAnalyticsData?
    @State private var selectedTimeframe: Timeframe = .month
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingExportSheet = false

    enum Timeframe: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case quarter = "90D"
        case year = "1Y"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            case .year: return 365
            }
        }

        var title: String {
            switch self {
            case .week: return "This Week"
            case .month: return "This Month"
            case .quarter: return "3 Months"
            case .year: return "This Year"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if let errorMessage = errorMessage {
                        errorView(message: errorMessage)
                    } else if isLoading {
                        loadingView
                    } else if let data = analyticsData {
                        timeframePicker
                        overviewCards(data: data)
                        streakDistributionChart(data: data)
                        topPerformersSection(data: data)
                        consistencyInsights(data: data)
                        weeklyPatternView(data: data)
                        lastUpdatedView
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Streak Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if let data = analyticsData {
                        Menu {
                            Button("Export Data", systemImage: "square.and.arrow.up") {
                                Task { await exportAnalytics(data) }
                            }

                            Button("Share Report", systemImage: "square.and.arrow.up.fill") {
                                shareAnalyticsReport(data)
                            }

                            Divider()

                            Button("Refresh", systemImage: "arrow.clockwise") {
                                Task { await refreshAnalytics() }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .disabled(isLoading)
                    } else {
                        Button("Refresh") {
                            Task { await refreshAnalytics() }
                        }
                        .disabled(isLoading)
                    }
                }
            }
            .onAppear {
                setupService()
            }
            .task {
                await loadAnalytics()
            }
            .refreshable {
                await refreshAnalytics()
            }
            .sheet(isPresented: $showingExportSheet) {
                AnalyticsExportView(analyticsData: analyticsData)
            }
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Analyzing your streak patterns...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Analytics Data")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Complete some habits to see your streak analytics")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Error Loading Analytics")
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }

    private var timeframePicker: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedTimeframe) { _, _ in
            Task { await loadAnalytics() }
        }
    }

    private func overviewCards(data: StreakAnalyticsData) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            AnalyticsCard(
                title: "Total Streaks",
                value: "\(data.totalActiveStreaks)",
                subtitle: "Active habits",
                color: .blue,
                icon: "flame.fill"
            )

            AnalyticsCard(
                title: "Longest Streak",
                value: "\(data.longestOverallStreak)",
                subtitle: "Days",
                color: .orange,
                icon: "trophy.fill"
            )

            AnalyticsCard(
                title: "Avg Consistency",
                value: "\(Int(data.averageConsistency * 100))%",
                subtitle: selectedTimeframe.title.lowercased(),
                color: .green,
                icon: "target"
            )

            AnalyticsCard(
                title: "Milestones Hit",
                value: "\(data.milestonesAchieved)",
                subtitle: "This period",
                color: .purple,
                icon: "star.fill"
            )
        }
    }

    private func streakDistributionChart(data: StreakAnalyticsData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Distribution")
                .font(.title3)
                .fontWeight(.semibold)

            StreakDistributionChartView(data: data.streakDistribution)
                .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    private func topPerformersSection(data: StreakAnalyticsData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Performers")
                .font(.title3)
                .fontWeight(.semibold)

            ForEach(data.topPerformingHabits.prefix(5), id: \.habit.id) { performer in
                TopPerformerRow(performer: performer)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    private func consistencyInsights(data: StreakAnalyticsData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Consistency Insights")
                .font(.title3)
                .fontWeight(.semibold)

            ConsistencyInsightView(insights: data.consistencyInsights)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    private func weeklyPatternView(data: StreakAnalyticsData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Patterns")
                .font(.title3)
                .fontWeight(.semibold)

            WeeklyPatternChartView(patterns: data.weeklyPatterns)
                .frame(height: 120)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    private var lastUpdatedView: some View {
        HStack {
            Spacer()

            Text("Last updated: Just now")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(.horizontal)
    }

    // MARK: - Data Loading

    private func setupService() {
        streakService = StreakService(modelContext: modelContext)
    }

    private func loadAnalytics() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let service = streakService else {
            errorMessage = "Failed to initialize streak service"
            return
        }

        do {
            // Get all habits
            let habitDescriptor = FetchDescriptor<Habit>()
            let habits = try modelContext.fetch(habitDescriptor)

            let analytics = await generateAnalyticsData(habits: habits, service: service)

            await MainActor.run {
                self.analyticsData = analytics
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load analytics: \(error.localizedDescription)"
            }
        }
    }

    private func generateAnalyticsData(habits: [Habit], service: StreakService) async -> StreakAnalyticsData {
        var streakAnalytics: [StreakAnalytics] = []
        var topPerformers: [TopPerformer] = []

        for habit in habits {
            let analytics = await service.getStreakAnalytics(for: habit)
            streakAnalytics.append(analytics)

            if analytics.currentStreak > 0 {
                topPerformers.append(TopPerformer(
                    habit: habit,
                    currentStreak: analytics.currentStreak,
                    longestStreak: analytics.longestStreak,
                    consistency: analytics.streakPercentile
                ))
            }
        }

        // Sort top performers by current streak
        topPerformers.sort { $0.currentStreak > $1.currentStreak }

        return StreakAnalyticsData(
            totalActiveStreaks: streakAnalytics.filter { $0.currentStreak > 0 }.count,
            longestOverallStreak: streakAnalytics.map(\.longestStreak).max() ?? 0,
            averageConsistency: calculateAverageConsistency(streakAnalytics),
            milestonesAchieved: countRecentMilestones(streakAnalytics),
            streakDistribution: generateStreakDistribution(streakAnalytics),
            topPerformingHabits: topPerformers,
            consistencyInsights: generateConsistencyInsights(streakAnalytics),
            weeklyPatterns: await generateWeeklyPatterns(habits: habits, service: service)
        )
    }

    private func calculateAverageConsistency(_ analytics: [StreakAnalytics]) -> Double {
        let consistencies = analytics.map(\.streakPercentile)
        return consistencies.isEmpty ? 0 : consistencies.reduce(0, +) / Double(consistencies.count)
    }

    private func countRecentMilestones(_ analytics: [StreakAnalytics]) -> Int {
        // Simplified - count current milestones as "recent achievements"
        return analytics.compactMap(\.currentMilestone).count
    }

    private func generateStreakDistribution(_ analytics: [StreakAnalytics]) -> [StreakDistributionData] {
        let streaks = analytics.map(\.currentStreak)
        let ranges = [(0...2, "Getting Started"), (3...6, "Building"), (7...29, "Strong"), (30...99, "Impressive"), (100...Int.max, "Legendary")]

        return ranges.map { range, label in
            let count = streaks.filter { range.contains($0) }.count
            return StreakDistributionData(range: label, count: count)
        }
    }

    private func generateConsistencyInsights(_ analytics: [StreakAnalytics]) -> [ConsistencyInsight] {
        // Generate insights based on streak patterns
        var insights: [ConsistencyInsight] = []

        let strongStreaks = analytics.filter { $0.currentStreak >= 7 }.count

        if strongStreaks > 0 {
            insights.append(ConsistencyInsight(
                title: "Strong Momentum",
                description: "You have \(strongStreaks) habits with week+ streaks",
                type: .positive
            ))
        }

        let strugglingHabits = analytics.filter { $0.currentStreak == 0 }.count
        if strugglingHabits > 0 {
            insights.append(ConsistencyInsight(
                title: "Growth Opportunity",
                description: "\(strugglingHabits) habits could use more attention",
                type: .improvement
            ))
        }

        return insights
    }

    private func generateWeeklyPatterns(habits: [Habit], service: StreakService) async -> [WeeklyPattern] {
        // Simplified weekly pattern generation
        let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return daysOfWeek.map { day in
            WeeklyPattern(day: day, completionRate: Double.random(in: 0.3...0.9)) // Placeholder
        }
    }

    // MARK: - Export and Sharing

    private func refreshAnalytics() async {
        await loadAnalytics()
    }

    private func exportAnalytics(_ data: StreakAnalyticsData) async {
        // Export logic here
        // For now, just a placeholder action
        showingExportSheet = true
    }

    private func shareAnalyticsReport(_ data: StreakAnalyticsData) {
        // Sharing logic here
        // For now, just a placeholder action
        print("Sharing analytics report...")
    }
}

// MARK: - Supporting Data Structures

struct StreakAnalyticsData {
    let totalActiveStreaks: Int
    let longestOverallStreak: Int
    let averageConsistency: Double
    let milestonesAchieved: Int
    let streakDistribution: [StreakDistributionData]
    let topPerformingHabits: [TopPerformer]
    let consistencyInsights: [ConsistencyInsight]
    let weeklyPatterns: [WeeklyPattern]
}

struct TopPerformer {
    let habit: Habit
    let currentStreak: Int
    let longestStreak: Int
    let consistency: Double
}

struct StreakDistributionData {
    let range: String
    let count: Int
}

struct ConsistencyInsight {
    let title: String
    let description: String
    let type: InsightType

    enum InsightType {
        case positive, improvement, neutral

        var color: Color {
            switch self {
            case .positive: return .green
            case .improvement: return .orange
            case .neutral: return .blue
            }
        }

        var icon: String {
            switch self {
            case .positive: return "checkmark.circle.fill"
            case .improvement: return "exclamationmark.triangle.fill"
            case .neutral: return "info.circle.fill"
            }
        }
    }
}

struct WeeklyPattern {
    let day: String
    let completionRate: Double
}
