import HabitQuestCore
import SwiftData
import XCTest
@testable import HabitQuest

final class TodaysQuestsViewModelTests: XCTestCase {
    @MainActor
    private func createSUT() throws -> (ModelContext, TodaysQuestsViewModel) {
        let container = try ModelContainer(
            for: Habit.self, HabitLog.self, HabitQuestCore.Achievement.self, PlayerProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let vm = TodaysQuestsViewModel()
        vm.setModelContext(context)
        return (context, vm)
    }

    // MARK: - Initialization & Property Tests

    @MainActor
    func testTodaysQuestsViewModelInitialization() throws {
        let (_, viewModel) = try createSUT()
        XCTAssertTrue(viewModel.todaysHabits.isEmpty)
        XCTAssertFalse(viewModel.showingAddQuest)
        XCTAssertFalse(viewModel.showingCompletionAlert)
        XCTAssertEqual(viewModel.completionMessage, "")
    }

    // MARK: - Completion & Toggle Tests (Issue #68)

    @MainActor
    func testIsHabitCompletedToday() throws {
        let (context, viewModel) = try createSUT()
        let habit = Habit(name: "Morning Run", habitDescription: "5km run", frequency: .daily, xpValue: 20)
        context.insert(habit)
        try context.save()

        XCTAssertFalse(viewModel.isHabitCompletedToday(habit))

        let log = HabitLog(habit: habit, completionDate: Date(), isCompleted: true)
        context.insert(log)
        try context.save()

        XCTAssertTrue(viewModel.isHabitCompletedToday(habit))
    }

    @MainActor
    func testCompletingTwiceInOneDayLogsOnce() throws {
        let (context, viewModel) = try createSUT()
        let profile = PlayerProfile()
        context.insert(profile)
        let habit = Habit(
            name: "Read Book",
            habitDescription: "Read 10 pages",
            frequency: .daily,
            xpValue: 15,
            difficulty: .easy
        )
        context.insert(habit)
        try context.save()

        viewModel.completeHabit(habit)

        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertEqual(profile.currentXP, 15)
        XCTAssertEqual(habit.streak, 1)

        // Attempting to complete again the same day must not duplicate log or stack XP
        viewModel.completeHabit(habit)

        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertEqual(profile.currentXP, 15)
        XCTAssertEqual(habit.streak, 1)
    }

    @MainActor
    func testTogglingOffRemovesLogAndRevertsXP() throws {
        let (context, viewModel) = try createSUT()
        let profile = PlayerProfile()
        context.insert(profile)
        let habit = Habit(
            name: "Meditate",
            habitDescription: "10 mins mindfulness",
            frequency: .daily,
            xpValue: 25,
            difficulty: .medium
        )
        context.insert(habit)
        try context.save()

        // Complete the habit via toggle
        viewModel.toggleHabitCompletion(habit)

        let expectedXP = 25 * habit.difficulty.xpMultiplier // 25 * 2 = 50
        XCTAssertTrue(viewModel.isHabitCompletedToday(habit))
        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertEqual(profile.currentXP, expectedXP)
        XCTAssertEqual(habit.streak, 1)

        // Toggle off (uncomplete)
        viewModel.toggleHabitCompletion(habit)

        XCTAssertFalse(viewModel.isHabitCompletedToday(habit))
        XCTAssertEqual(habit.logs.count, 0)
        XCTAssertEqual(profile.currentXP, 0)
        XCTAssertEqual(habit.streak, 0)
    }

    @MainActor
    func testTogglingBackOnReawardsOnce() throws {
        let (context, viewModel) = try createSUT()
        let profile = PlayerProfile()
        context.insert(profile)
        let habit = Habit(
            name: "Drink Water",
            habitDescription: "2L water",
            frequency: .daily,
            xpValue: 10,
            difficulty: .easy
        )
        context.insert(habit)
        try context.save()

        // Toggle on
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.currentXP, 10)
        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertEqual(habit.streak, 1)

        // Toggle off
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.currentXP, 0)
        XCTAssertEqual(habit.logs.count, 0)
        XCTAssertEqual(habit.streak, 0)

        // Toggle back on re-awards once
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.currentXP, 10)
        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertEqual(habit.streak, 1)
    }

    @MainActor
    func testStreakRevertsToPreviousStreakOnToggleOff() throws {
        let (context, viewModel) = try createSUT()
        let profile = PlayerProfile()
        context.insert(profile)
        let habit = Habit(name: "Exercise", habitDescription: "Gym workout", frequency: .daily, xpValue: 20)
        context.insert(habit)

        // Simulate yesterday's completion
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayLog = HabitLog(habit: habit, completionDate: yesterday, isCompleted: true)
        context.insert(yesterdayLog)
        habit.streak = 1
        try context.save()

        // Complete today -> streak becomes 2
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(habit.streak, 2)
        XCTAssertEqual(habit.logs.count, 2)

        // Toggle off -> streak reverts to 1
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(habit.streak, 1)
        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertFalse(viewModel.isHabitCompletedToday(habit))
    }

    @MainActor
    func testLevelRevertsOnToggleOffIfLeveledUp() throws {
        let (context, viewModel) = try createSUT()
        let profile = PlayerProfile()
        profile.currentXP = 140
        profile.level = 1
        profile.xpForNextLevel = 150
        context.insert(profile)

        let habit = Habit(
            name: "Coding",
            habitDescription: "Build app",
            frequency: .daily,
            xpValue: 20,
            difficulty: .medium
        ) // 20 * 2 = 40 XP
        context.insert(habit)
        try context.save()

        // Complete -> 140 + 40 = 180 XP -> Level 2
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.level, 2)
        XCTAssertEqual(profile.currentXP, 180)

        // Toggle off -> reverts 40 XP -> 140 XP -> Level reverts to 1
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.currentXP, 140)
    }

    // MARK: - Round 3 Reproduction Tests: Issue #81

    @MainActor
    func testUndoingLevelUpCompletionDeductsAwardedStreakFreeze() throws {
        let (context, viewModel) = try createSUT()
        let profile = PlayerProfile()
        profile.currentXP = 140
        profile.level = 1
        profile.xpForNextLevel = 150
        profile.streakFreezes = 0
        context.insert(profile)

        let habit = Habit(
            name: "Workout",
            habitDescription: "Gym",
            frequency: .daily,
            xpValue: 20,
            difficulty: .medium
        ) // 20 * 2 = 40 XP
        context.insert(habit)
        try context.save()

        // Complete -> 140 + 40 = 180 XP -> Level 2, +1 streak freeze awarded
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.level, 2)
        XCTAssertEqual(profile.streakFreezes, 1, "Leveling up should award 1 streak freeze")

        // Toggle off (uncomplete) -> Reverts to Level 1 -> Awarded freeze must be deducted!
        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.streakFreezes, 0, "Undoing level-up completion must deduct awarded streak freeze")
    }

    @MainActor
    func testUndoingNonLevelUpCompletionPreservesStreakFreezes() throws {
        let (context, viewModel) = try createSUT()
        let profile = PlayerProfile()
        profile.currentXP = 10
        profile.level = 1
        profile.xpForNextLevel = 150
        profile.streakFreezes = 2
        context.insert(profile)

        let habit = Habit(name: "Hydrate", habitDescription: "Water", frequency: .daily, xpValue: 10, difficulty: .easy)
        context.insert(habit)
        try context.save()

        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.streakFreezes, 2)

        viewModel.toggleHabitCompletion(habit)
        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.streakFreezes, 2, "Undoing completion without level-up must not change streak freezes")
    }

    // MARK: - Issue #93: Un-completing Today Preserves Freeze-Protected Streak

    @MainActor
    func testUncompletingTodayDoesNotEvaporateFreezeProtectedStreak() async throws {
        let (context, viewModel) = try createSUT()
        let profile = PlayerProfile()
        profile.streakFreezes = 1
        context.insert(profile)

        let habit = Habit(name: "Workout", habitDescription: "Gym session", frequency: .daily, xpValue: 25)
        context.insert(habit)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Completed 7 days ago (gap of 6 missed days to today, needing 1 freeze beyond default 5-day threshold)
        let log7DaysAgo = try XCTUnwrap(calendar.date(byAdding: .day, value: -7, to: today))
        let oldLog = HabitLog(habit: habit, completionDate: log7DaysAgo, isCompleted: true)
        context.insert(oldLog)
        try context.save()

        // Complete habit today: bridges 6-day gap using the 1 freeze
        viewModel.completeHabit(habit)
        try context.save()

        XCTAssertEqual(habit.streak, 2, "Completing today across 6-day gap with 1 freeze results in streak 2")
        XCTAssertEqual(profile.streakFreezes, 0, "Freeze was consumed for completion")

        // Uncomplete habit today (undo completion)
        viewModel.uncompleteHabit(habit)
        try context.save()

        // Habit streak and profile inventory after uncompleting
        XCTAssertEqual(habit.streak, 1, "Streak should revert to 1 after uncompleting today")
        XCTAssertEqual(profile.streakFreezes, 1, "Uncompleting completion that consumed freeze must refund the freeze")

        // Subsequent read path via StreakService must NOT evaporate the streak to 0
        let streakService = StreakService(modelContext: context)
        let analytics = await streakService.getStreakAnalytics(for: habit, profile: profile)
        XCTAssertEqual(
            analytics.currentStreak,
            1,
            "Subsequent analytics read must preserve freeze-protected streak after uncompleting today"
        )

        let currentStreak = await streakService.calculateCurrentStreak(for: habit, profile: profile)
        XCTAssertEqual(
            currentStreak,
            1,
            "Subsequent calculateCurrentStreak read must preserve freeze-protected streak after uncompleting today"
        )
    }
}
