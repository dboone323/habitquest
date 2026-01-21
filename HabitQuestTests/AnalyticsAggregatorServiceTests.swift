@testable import HabitQuest
import SwiftData
import XCTest

@MainActor
final class AnalyticsAggregatorServiceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var analyticsService: AnalyticsAggregatorService!

    // Dependencies
    var trendService: TrendAnalysisService!
    var categoryInsightsService: CategoryInsightsService!
    var productivityMetricsService: ProductivityMetricsService!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Habit.self, HabitLog.self, configurations: config)
        modelContext = modelContainer.mainContext

        // Initialize dependencies
        trendService = TrendAnalysisService(modelContext: modelContext)
        categoryInsightsService = CategoryInsightsService(modelContext: modelContext)
        productivityMetricsService = ProductivityMetricsService(modelContext: modelContext)

        // Initialize CUT
        analyticsService = AnalyticsAggregatorService(
            modelContext: modelContext,
            trendAnalysisService: trendService,
            categoryInsightsService: categoryInsightsService,
            productivityMetricsService: productivityMetricsService
        )
    }

    override func tearDown() {
        analyticsService = nil
        modelContext = nil
        modelContainer = nil
    }

    func testGetAnalytics_WithEmptyData() async {
        let analytics = await analyticsService.getAnalytics()

        XCTAssertEqual(analytics.overallStats.totalHabits, 0)
        XCTAssertEqual(analytics.overallStats.completionRate, 0.0)
        XCTAssertEqual(analytics.streakAnalytics.activeStreaks, 0)
    }

    func testGetAnalytics_WithHabitData() async throws {
        // Given
        let habit1 = Habit(name: "Run", habitDescription: "Run 5km", frequency: .daily, category: .fitness)
        let habit2 = Habit(name: "Read", habitDescription: "Read 20 pages", frequency: .daily, category: .learning)

        modelContext.insert(habit1)
        modelContext.insert(habit2)

        // Simulate logs for Habit 1 (3 completions)
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let dayBefore = Calendar.current.date(byAdding: .day, value: -2, to: today)!

        let log1 = HabitLog(habit: habit1, completionDate: today, isCompleted: true)
        let log2 = HabitLog(habit: habit1, completionDate: yesterday, isCompleted: true)
        let log3 = HabitLog(habit: habit1, completionDate: dayBefore, isCompleted: true)

        habit1.logs.append(log1)
        habit1.logs.append(log2)
        habit1.logs.append(log3)
        habit1.streak = 3

        modelContext.insert(log1)
        modelContext.insert(log2)
        modelContext.insert(log3)

        // When
        let analytics = await analyticsService.getAnalytics()

        // Then
        XCTAssertEqual(analytics.overallStats.totalHabits, 2)
        XCTAssertEqual(analytics.overallStats.totalCompletions, 3)
        XCTAssertEqual(analytics.overallStats.activeHabits, 2) // Default is active

        // Streak checks
        XCTAssertEqual(analytics.streakAnalytics.longestStreak, 3)
        XCTAssertEqual(analytics.streakAnalytics.activeStreaks, 1) // Only habit1 has streak > 0

        // Category checks
        XCTAssertEqual(analytics.categoryBreakdown.count, 2) // Fitness + Learning
    }
}
