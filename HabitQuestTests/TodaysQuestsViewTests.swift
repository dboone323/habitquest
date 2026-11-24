import HabitQuestCore
import SwiftData
import XCTest
@testable import HabitQuest

final class TodaysQuestsViewTests: XCTestCase {
    @MainActor
    private func createSUT() throws -> (ModelContext, StreakService) {
        let container = try ModelContainer(
            for: Habit.self, HabitLog.self, Achievement.self, PlayerProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let service = StreakService(modelContext: context)
        return (context, service)
    }

    // MARK: - Issue #92: Today Tab Analytics Shared Freeze Allocation Test

    @MainActor
    func testTodayTabAnalyticsDoesNotDoubleCountSingleFreezeAcrossHabits() async throws {
        let (modelContext, service) = try createSUT()
        let calendar = Calendar.current

        let profile = PlayerProfile()
        profile.streakFreezes = 1
        modelContext.insert(profile)

        let habit1 = Habit(name: "Morning Run", habitDescription: "5km", frequency: .daily, xpValue: 20)
        let habit2 = Habit(name: "Read Book", habitDescription: "Read 20 pages", frequency: .daily, xpValue: 15)
        modelContext.insert(habit1)
        modelContext.insert(habit2)

        let today = calendar.startOfDay(for: Date())
        // Both habits completed 9, 8, 7 days ago (gap of 6 missed days to today)
        // Default threshold is 5 days, so each habit needs 1 freeze to survive.
        for daysAgo in [9, 8, 7] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            modelContext.insert(HabitLog(habit: habit1, completionDate: logDate, isCompleted: true))
            modelContext.insert(HabitLog(habit: habit2, completionDate: logDate, isCompleted: true))
        }
        try modelContext.save()

        let analytics = await TodaysQuestsView.computeHabitAnalytics(
            for: [habit1, habit2],
            profile: profile,
            service: service
        )

        // With only 1 freeze total in player profile inventory, at most ONE habit may be reported as protected (alive streak)
        let protectedHabits = analytics.values.filter { $0.currentStreak > 0 }
        XCTAssertEqual(protectedHabits.count, 1, "Only one habit should be freeze-protected across Today tab's habit analytics with 1 freeze")
    }
}
