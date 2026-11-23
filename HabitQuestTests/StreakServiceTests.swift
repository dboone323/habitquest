import HabitQuestCore
import SwiftData
import XCTest
@testable import HabitQuest

final class StreakServiceTests: XCTestCase {
    private var container: ModelContainer!
    private var modelContext: ModelContext!
    private var calendar: Calendar!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        calendar = Calendar.current
        container = try ModelContainer(
            for: Habit.self, HabitLog.self, HabitQuestCore.Achievement.self, PlayerProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        modelContext = ModelContext(container)
        StreakForgivenessConfig.threshold = StreakForgivenessConfig.defaultThreshold
    }

    @MainActor
    override func tearDown() async throws {
        StreakForgivenessConfig.threshold = StreakForgivenessConfig.defaultThreshold
        container = nil
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - Forgiving Streak Tests (Issue #76)

    @MainActor
    func testStreakSurvivesThreeMissedDays() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Morning Run", habitDescription: "5km", frequency: .daily, xpValue: 20)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Completed 5, 4, 3 days ago (3 consecutive days)
        // Missed 2 days ago, 1 day ago, and today (3 missed days before today: daysSinceLast = 3)
        for daysAgo in [5, 4, 3] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        // With default threshold of 5 days, 3 missed days is forgiven
        let currentStreak = await sut.calculateCurrentStreak(for: habit)
        XCTAssertEqual(currentStreak, 3, "Streak should survive 3 missed days under 5-day forgiveness threshold")
    }

    @MainActor
    func testStreakResetsAfterSixMissedDays() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Morning Meditation", habitDescription: "10 mins", frequency: .daily, xpValue: 15)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Completed 9, 8, 7 days ago (3 consecutive days)
        // Missed 6, 5, 4, 3, 2, 1 days ago (6 missed days: daysSinceLast = 7, missedDays = 6)
        for daysAgo in [9, 8, 7] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        // 6 missed days exceeds the default threshold of 5 days
        let currentStreak = await sut.calculateCurrentStreak(for: habit)
        XCTAssertEqual(currentStreak, 0, "Streak should reset to 0 after 6 missed days exceeding 5-day threshold")
    }

    @MainActor
    func testStreakFreezeCoversMissedDayWithoutConsumingThreshold() async throws {
        let sut = StreakService(modelContext: modelContext)
        let profile = PlayerProfile()
        profile.streakFreezes = 1
        modelContext.insert(profile)

        let habit = Habit(name: "Evening Reading", habitDescription: "10 pages", frequency: .daily, xpValue: 10)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Completed 9, 8, 7 days ago (3 consecutive days)
        // Missed 6 days before today.
        // With 1 streak freeze covering 1 missed day, remaining missed days = 5.
        // 5 is within the 5-day threshold, so the streak survives!
        for daysAgo in [9, 8, 7] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        let currentStreak = await sut.calculateCurrentStreak(for: habit, profile: profile)
        XCTAssertEqual(currentStreak, 3, "Streak freeze covers a missed day without consuming the threshold, allowing streak to survive")
    }

    @MainActor
    func testThresholdChangeInSettingsTakesEffect() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Guitar Practice", habitDescription: "15 mins", frequency: .daily, xpValue: 15)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Completed 5, 4, 3 days ago (missed 2 days ago, yesterday, today -> 2 missed days before today: daysSinceLast = 3, missed = 2)
        for daysAgo in [5, 4, 3] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        // Default threshold (5) -> survives
        let streakDefault = await sut.calculateCurrentStreak(for: habit)
        XCTAssertEqual(streakDefault, 3)

        // Change threshold in Settings/UserDefaults to 1 day
        StreakForgivenessConfig.threshold = 1
        XCTAssertEqual(StreakForgivenessConfig.threshold, 1)

        let streakWithLowerThreshold = await sut.calculateCurrentStreak(for: habit)
        XCTAssertEqual(streakWithLowerThreshold, 0, "Lowering threshold to 1 in Settings should cause 2 missed days to reset streak")

        // Change threshold to 10 days
        StreakForgivenessConfig.threshold = 10
        XCTAssertEqual(StreakForgivenessConfig.threshold, 10)

        // Even with 6 missed days (completed 9, 8, 7 days ago), it survives under threshold 10
        let habit2 = Habit(name: "Pushups", habitDescription: "20 reps", frequency: .daily, xpValue: 10)
        modelContext.insert(habit2)
        for daysAgo in [9, 8, 7] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit2, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        let streakWithHigherThreshold = await sut.calculateCurrentStreak(for: habit2)
        XCTAssertEqual(streakWithHigherThreshold, 3, "Higher threshold in Settings preserves streak through 6 missed days")
    }

    @MainActor
    func testStreakFreezeEarnedOnLevelUp() throws {
        let gamification = GamificationService()
        let profile = PlayerProfile()
        profile.level = 1
        profile.currentXP = 0
        profile.streakFreezes = 0
        modelContext.insert(profile)

        // Level 2 requires calculateXPForLevel(2) = 150 XP
        let neededXP = gamification.calculateXPForLevel(2)
        let result = gamification.processXPGain(experiencePoints: neededXP, for: profile)

        XCTAssertTrue(result.leveledUp)
        XCTAssertEqual(result.newLevel, 2)
        XCTAssertEqual(profile.level, 2)
        XCTAssertEqual(profile.streakFreezes, 1, "Level-up should award 1 streak freeze into inventory")
    }

    @MainActor
    func testCalculateLongestStreakWithForgiveness() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Hydrate", habitDescription: "8 glasses", frequency: .daily, xpValue: 10)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // First run: 12, 11, 10 days ago (3 days)
        // Gap of 2 missed days (9, 8 days ago) -> forgiven under 5-day threshold
        // Second run: 7, 6, 5, 4 days ago (4 days) -> total joined = 7
        // Gap of 8 missed days -> reset
        // Third run: 2 days ago (1 day)
        for daysAgo in [12, 11, 10, 7, 6, 5, 4] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        let longestStreak = await sut.calculateLongestStreak(for: habit)
        XCTAssertEqual(longestStreak, 7, "Longest streak bridges 2-day gap under 5-day forgiveness threshold")
    }

    @MainActor
    func testStreakAnalyticsAndMilestones() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Deep Work", habitDescription: "45 mins", frequency: .daily, xpValue: 25)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // 7 days consecutive completed ending today
        for daysAgo in 0..<7 {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        let analytics = await sut.getStreakAnalytics(for: habit)
        XCTAssertEqual(analytics.currentStreak, 7)
        XCTAssertEqual(analytics.longestStreak, 7)
        XCTAssertEqual(analytics.streakDescription, "7 day streak")
        XCTAssertGreaterThan(analytics.streakPercentile, 0.0)

        let milestone = await sut.getCurrentMilestone(for: habit)
        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.streakCount, 7)
    }
}
