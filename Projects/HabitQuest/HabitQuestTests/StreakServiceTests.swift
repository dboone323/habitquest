@testable import HabitQuest
import SwiftData
import XCTest

@MainActor
final class StreakServiceTests: XCTestCase {
    // Remove instance variables - we'll set them up in each test

    // MARK: - Helper Methods

    private func createTestContainer() throws -> (ModelContext, Habit) {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Habit.self, HabitLog.self, configurations: config)
        let modelContext = ModelContext(container)

        // Create test habit
        let testHabit = Habit(
            name: "Test Habit",
            habitDescription: "A habit for testing",
            frequency: .daily,
            xpValue: 10,
            category: .health,
            difficulty: .easy
        )
        modelContext.insert(testHabit)

        return (modelContext, testHabit)
    }

    // MARK: - StreakService Tests

    func testStreakServiceInitialization() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        // Test basic initialization
        XCTAssertNotNil(streakService, "StreakService should initialize successfully")
    }

    func testCalculateCurrentStreak_NoCompletions() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        // Test with no completion logs
        let streak = streakService.calculateCurrentStreak(for: testHabit)
        XCTAssertEqual(streak, 0, "Streak should be 0 with no completions")
    }

    func testCalculateCurrentStreak_SingleCompletionToday() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        // Add a completion for today
        let todayLog = HabitLog(habit: testHabit, completionDate: Date(), isCompleted: true)
        testHabit.logs.append(todayLog)

        let streak = streakService.calculateCurrentStreak(for: testHabit)
        XCTAssertEqual(streak, 1, "Streak should be 1 with today's completion")
    }

    func testCalculateCurrentStreak_ConsecutiveDays() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let calendar = Calendar.current

        // Add completions for yesterday and today
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayLog = HabitLog(habit: testHabit, completionDate: yesterday, isCompleted: true)
        let todayLog = HabitLog(habit: testHabit, completionDate: Date(), isCompleted: true)

        testHabit.logs.append(yesterdayLog)
        testHabit.logs.append(todayLog)

        let streak = streakService.calculateCurrentStreak(for: testHabit)
        XCTAssertEqual(streak, 2, "Streak should be 2 with consecutive completions")
    }

    func testCalculateCurrentStreak_WithGap() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let calendar = Calendar.current

        // Add completion for 2 days ago, skip yesterday, complete today
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        let twoDaysAgoLog = HabitLog(habit: testHabit, completionDate: twoDaysAgo, isCompleted: true)
        let todayLog = HabitLog(habit: testHabit, completionDate: Date(), isCompleted: true)

        testHabit.logs.append(twoDaysAgoLog)
        testHabit.logs.append(todayLog)

        let streak = streakService.calculateCurrentStreak(for: testHabit)
        XCTAssertEqual(streak, 1, "Streak should be 1 due to gap yesterday")
    }

    func testCalculateLongestStreak_NoCompletions() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let longestStreak = streakService.calculateLongestStreak(for: testHabit)
        XCTAssertEqual(longestStreak, 0, "Longest streak should be 0 with no completions")
    }

    func testCalculateLongestStreak_SingleStreak() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let calendar = Calendar.current

        // Add 3 consecutive completions
        for i in 0 ..< 3 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let log = HabitLog(habit: testHabit, completionDate: date, isCompleted: true)
            testHabit.logs.append(log)
        }

        let longestStreak = streakService.calculateLongestStreak(for: testHabit)
        XCTAssertEqual(longestStreak, 3, "Longest streak should be 3")
    }

    func testCalculateLongestStreak_MultipleStreaks() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let calendar = Calendar.current

        // Add 3 consecutive completions (first streak)
        for i in 0 ..< 3 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let log = HabitLog(habit: testHabit, completionDate: date, isCompleted: true)
            testHabit.logs.append(log)
        }

        // Add 5 consecutive completions 2 weeks ago (longer streak)
        for i in 0 ..< 5 {
            let date = calendar.date(byAdding: .day, value: -i - 14, to: Date())!
            let log = HabitLog(habit: testHabit, completionDate: date, isCompleted: true)
            testHabit.logs.append(log)
        }

        let longestStreak = streakService.calculateLongestStreak(for: testHabit)
        XCTAssertEqual(longestStreak, 5, "Longest streak should be 5")
    }

    func testGetStreakData_DefaultDays() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let streakData = streakService.getStreakData(for: testHabit)
        XCTAssertEqual(streakData.count, 30, "Should return 30 days of data by default")
    }

    func testGetStreakData_CustomDays() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let streakData = streakService.getStreakData(for: testHabit, days: 7)
        XCTAssertEqual(streakData.count, 8, "Should return 8 days of data (7 days back + today)")
    }

    func testGetStreakData_WithCompletions() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let calendar = Calendar.current

        // Add completion for today
        let todayLog = HabitLog(habit: testHabit, completionDate: Date(), isCompleted: true)
        testHabit.logs.append(todayLog)

        let streakData = streakService.getStreakData(for: testHabit, days: 7)

        // Find today's data
        let today = calendar.startOfDay(for: Date())
        let todayData = streakData.first { calendar.isDate($0.date, inSameDayAs: today) }

        XCTAssertNotNil(todayData, "Should have data for today")
        XCTAssertTrue(todayData!.isCompleted, "Today should be marked as completed")
        XCTAssertEqual(todayData!.intensity, 1.0, "Completed day should have full intensity")
    }

    func testCheckForNewMilestone_NoMilestone() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let milestone = streakService.checkForNewMilestone(habit: testHabit, previousStreak: 0)
        XCTAssertNil(milestone, "Should not have new milestone with 0 streak")
    }

    func testCheckForNewMilestone_NewMilestone() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        // Add 3 completions to reach first milestone
        let calendar = Calendar.current
        for i in 0 ..< 3 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let log = HabitLog(habit: testHabit, completionDate: date, isCompleted: true)
            testHabit.logs.append(log)
        }

        let milestone = streakService.checkForNewMilestone(habit: testHabit, previousStreak: 2)
        XCTAssertNotNil(milestone, "Should have new milestone at streak 3")
        XCTAssertEqual(milestone?.streakCount, 3, "Should be the 3-day milestone")
        XCTAssertEqual(milestone?.title, "Getting Started", "Should be the correct milestone title")
    }

    func testGetCurrentMilestone_NoCompletions() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let milestone = streakService.getCurrentMilestone(for: testHabit)
        XCTAssertNil(milestone, "Should not have current milestone with no completions")
    }

    func testGetCurrentMilestone_WithStreak() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        // Add 7 completions to reach milestone
        let calendar = Calendar.current
        for i in 0 ..< 7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let log = HabitLog(habit: testHabit, completionDate: date, isCompleted: true)
            testHabit.logs.append(log)
        }

        let milestone = streakService.getCurrentMilestone(for: testHabit)
        XCTAssertNotNil(milestone, "Should have current milestone")
        XCTAssertEqual(milestone?.streakCount, 7, "Should be the 7-day milestone")
        XCTAssertEqual(milestone?.title, "One Week Warrior", "Should be the correct milestone title")
    }

    func testGetNextMilestone_NoCompletions() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        let milestone = streakService.getNextMilestone(for: testHabit)
        XCTAssertNotNil(milestone, "Should have next milestone even with no completions")
        XCTAssertEqual(milestone?.streakCount, 3, "Next milestone should be 3 days")
    }

    func testGetNextMilestone_WithStreak() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        // Add 3 completions
        let calendar = Calendar.current
        for i in 0 ..< 3 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let log = HabitLog(habit: testHabit, completionDate: date, isCompleted: true)
            testHabit.logs.append(log)
        }

        let milestone = streakService.getNextMilestone(for: testHabit)
        XCTAssertNotNil(milestone, "Should have next milestone")
        XCTAssertEqual(milestone?.streakCount, 7, "Next milestone should be 7 days")
    }

    func testGetProgressToNextMilestone() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        // Add 5 completions (between 3 and 7 day milestones)
        let calendar = Calendar.current
        for i in 0 ..< 5 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let log = HabitLog(habit: testHabit, completionDate: date, isCompleted: true)
            testHabit.logs.append(log)
        }

        let progress = streakService.getProgressToNextMilestone(for: testHabit)
        XCTAssertEqual(progress, 0.5, "Progress should be 0.5 (2 out of 4 days toward next milestone)")
    }

    func testGetStreakAnalytics() async throws {
        let (modelContext, testHabit) = try createTestContainer()
        let streakService = StreakService(modelContext: modelContext)

        // Add 3 completions
        let calendar = Calendar.current
        for i in 0 ..< 3 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let log = HabitLog(habit: testHabit, completionDate: date, isCompleted: true)
            testHabit.logs.append(log)
        }

        let analytics = streakService.getStreakAnalytics(for: testHabit)

        XCTAssertEqual(analytics.currentStreak, 3, "Current streak should be 3")
        XCTAssertEqual(analytics.longestStreak, 3, "Longest streak should be 3")
        XCTAssertNotNil(analytics.currentMilestone, "Should have current milestone")
        XCTAssertNotNil(analytics.nextMilestone, "Should have next milestone")
        XCTAssertEqual(analytics.progressToNextMilestone, 0.0, "Progress should be 0 (at milestone)")
        XCTAssertEqual(analytics.streakPercentile, 0.25, "Percentile should be 0.25 for streak of 3-6")
    }

    // MARK: - StreakDayData Tests

    func testStreakDayDataInitialization() async throws {
        let date = Date()
        let data = StreakDayData(date: date, isCompleted: true, intensity: 1.0)

        XCTAssertEqual(data.date, date, "Date should be set correctly")
        XCTAssertTrue(data.isCompleted, "isCompleted should be true")
        XCTAssertEqual(data.intensity, 1.0, "Intensity should be 1.0")
        XCTAssertNotEqual(data.id, UUID(), "ID should be generated")
    }

    func testStreakDayDataProperties() async throws {
        let date = Date()
        let data = StreakDayData(date: date, isCompleted: false, intensity: 0.5)

        XCTAssertEqual(data.date, date, "Date property should work")
        XCTAssertFalse(data.isCompleted, "isCompleted property should work")
        XCTAssertEqual(data.intensity, 0.5, "Intensity property should work")
    }

    // MARK: - StreakAnalytics Tests

    func testStreakAnalyticsInitialization() async throws {
        let analytics = StreakAnalytics(
            currentStreak: 5,
            longestStreak: 10,
            currentMilestone: StreakMilestone.predefinedMilestones.first,
            nextMilestone: StreakMilestone.predefinedMilestones[1],
            progressToNextMilestone: 0.5,
            streakPercentile: 0.25
        )

        XCTAssertEqual(analytics.currentStreak, 5, "Current streak should be set")
        XCTAssertEqual(analytics.longestStreak, 10, "Longest streak should be set")
        XCTAssertNotNil(analytics.currentMilestone, "Current milestone should be set")
        XCTAssertNotNil(analytics.nextMilestone, "Next milestone should be set")
        XCTAssertEqual(analytics.progressToNextMilestone, 0.5, "Progress should be set")
        XCTAssertEqual(analytics.streakPercentile, 0.25, "Percentile should be set")
    }

    func testStreakAnalyticsProperties() async throws {
        let analytics = StreakAnalytics(
            currentStreak: 0,
            longestStreak: 0,
            currentMilestone: nil,
            nextMilestone: StreakMilestone.predefinedMilestones.first,
            progressToNextMilestone: 0.0,
            streakPercentile: 0.1
        )

        XCTAssertEqual(analytics.streakDescription, "Ready to start your streak!", "Description should be correct for 0 streak")
        XCTAssertEqual(analytics.motivationalMessage, "Working towards Getting Started", "Motivational message should be correct")
    }

    func testStreakAnalyticsProperties_WithStreak() async throws {
        let analytics = StreakAnalytics(
            currentStreak: 1,
            longestStreak: 1,
            currentMilestone: nil,
            nextMilestone: StreakMilestone.predefinedMilestones.first,
            progressToNextMilestone: 1.0 / 3.0,
            streakPercentile: 0.1
        )

        XCTAssertEqual(analytics.streakDescription, "1 day streak - great start!", "Description should be correct for 1 day streak")
        XCTAssertEqual(analytics.motivationalMessage, "Working towards Getting Started", "Motivational message should be correct")
    }

    func testStreakAnalyticsProperties_AtMilestone() async throws {
        let analytics = StreakAnalytics(
            currentStreak: 3,
            longestStreak: 3,
            currentMilestone: StreakMilestone.predefinedMilestones.first,
            nextMilestone: StreakMilestone.predefinedMilestones[1],
            progressToNextMilestone: 0.0,
            streakPercentile: 0.25
        )

        XCTAssertEqual(analytics.streakDescription, "3 day streak", "Description should be correct for 3 day streak")
        XCTAssertEqual(analytics.motivationalMessage, "Working towards One Week Warrior", "Motivational message should be correct")
    }

    func testStreakAnalyticsProperties_OneDayFromMilestone() async throws {
        let analytics = StreakAnalytics(
            currentStreak: 6,
            longestStreak: 6,
            currentMilestone: StreakMilestone.predefinedMilestones.first,
            nextMilestone: StreakMilestone.predefinedMilestones[1],
            progressToNextMilestone: 3.0 / 4.0,
            streakPercentile: 0.25
        )

        XCTAssertEqual(
            analytics.motivationalMessage,
            "1 days to One Week Warrior!",
            "Motivational message should be correct for 1 day remaining"
        )
    }
}
