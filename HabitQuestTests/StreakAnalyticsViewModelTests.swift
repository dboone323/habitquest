import HabitQuestCore
import SwiftData
import XCTest
@testable import HabitQuest

final class StreakAnalyticsViewModelTests: XCTestCase {
    @MainActor
    private func createSUT() throws -> (ModelContext, StreakAnalyticsViewModel) {
        let container = try ModelContainer(
            for: Habit.self, HabitLog.self, HabitQuestCore.Achievement.self, PlayerProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let vm = StreakAnalyticsViewModel()
        return (context, vm)
    }

    // MARK: - Initialization & Property Tests

    @MainActor
    func testInitialization() throws {
        let (_, viewModel) = try createSUT()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.analyticsData)
        XCTAssertEqual(viewModel.selectedTimeframe, .month)
    }

    @MainActor
    func testTimeframeProperties() {
        XCTAssertEqual(StreakAnalyticsViewModel.Timeframe.week.days, 7)
        XCTAssertEqual(StreakAnalyticsViewModel.Timeframe.month.days, 30)
        XCTAssertEqual(StreakAnalyticsViewModel.Timeframe.quarter.days, 90)
        XCTAssertEqual(StreakAnalyticsViewModel.Timeframe.year.days, 365)

        XCTAssertEqual(StreakAnalyticsViewModel.Timeframe.week.title, "This Week")
        XCTAssertEqual(StreakAnalyticsViewModel.Timeframe.month.title, "This Month")
        XCTAssertEqual(StreakAnalyticsViewModel.Timeframe.quarter.title, "3 Months")
        XCTAssertEqual(StreakAnalyticsViewModel.Timeframe.year.title, "This Year")
    }

    // MARK: - Error Handling Tests (Issue #66)

    @MainActor
    func testLoadAnalyticsWithoutServiceSetsErrorMessage() async throws {
        let (_, viewModel) = try createSUT()
        // Without calling setupService(modelContext:), loadAnalytics must report failure
        await viewModel.loadAnalytics()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Failed to initialize services")
        XCTAssertNil(viewModel.analyticsData)
    }

    // MARK: - Data Loading Tests (Issue #66)

    @MainActor
    func testLoadAnalyticsWithEmptyHabitsSetsNilData() async throws {
        let (context, viewModel) = try createSUT()
        viewModel.setupService(modelContext: context)
        await viewModel.loadAnalytics()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.analyticsData)
    }

    @MainActor
    func testLoadAnalyticsWithHabitsComputesRealData() async throws {
        let (context, viewModel) = try createSUT()
        let habit1 = Habit(name: "Morning Run", habitDescription: "5km", frequency: .daily, xpValue: 20)
        let habit2 = Habit(name: "Read Book", habitDescription: "Read 20 pages", frequency: .daily, xpValue: 15)
        context.insert(habit1)
        context.insert(habit2)

        let log1 = HabitLog(habit: habit1, completionDate: Date(), isCompleted: true)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let log2 = HabitLog(habit: habit1, completionDate: yesterday, isCompleted: true)
        let log3 = HabitLog(habit: habit2, completionDate: Date(), isCompleted: true)
        context.insert(log1)
        context.insert(log2)
        context.insert(log3)
        try context.save()

        viewModel.setupService(modelContext: context)
        await viewModel.loadAnalytics()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.analyticsData)

        guard let data = viewModel.analyticsData else {
            XCTFail("analyticsData should not be nil")
            return
        }

        XCTAssertGreaterThanOrEqual(data.totalActiveStreaks, 1)
        XCTAssertEqual(data.streakDistribution.count, 5)
        XCTAssertEqual(data.weeklyPatterns.count, 7)
    }

    @MainActor
    func testRefreshAnalyticsReloadsData() async throws {
        let (context, viewModel) = try createSUT()
        viewModel.setupService(modelContext: context)
        await viewModel.refreshAnalytics()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
}
