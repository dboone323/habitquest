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

    // MARK: - Streak Freeze Consumption Tests (Issue #76 Round 2)

    @MainActor
    func testStreakFreezeConsumedOnBridgedGap() throws {
        let gamification = GamificationService()
        let profile = PlayerProfile()
        profile.streakFreezes = 1
        modelContext.insert(profile)

        let habit = Habit(name: "Morning Run", habitDescription: "5km", frequency: .daily, xpValue: 20)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Completed 9, 8, 7 days ago (3 consecutive days)
        for daysAgo in [9, 8, 7] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        // Complete today: 6 missed days between 7 days ago and today
        let todayLog = HabitLog(habit: habit, completionDate: today, isCompleted: true)
        modelContext.insert(todayLog)
        try modelContext.save()

        gamification.processHabitCompletion(habit: habit, profile: profile)
        try modelContext.save()

        // 6 missed days bridged by 1 freeze + 5-day threshold -> streak survives (4)
        XCTAssertEqual(habit.streak, 4, "Streak should survive 6 missed days bridged by 1 freeze")
        // But freeze MUST be consumed and deducted from inventory
        XCTAssertEqual(profile.streakFreezes, 0, "Streak freeze must be consumed after bridging gap")
    }

    @MainActor
    func testStreakResetsWhenFreezeAlreadySpent() throws {
        let gamification = GamificationService()
        let profile = PlayerProfile()
        profile.streakFreezes = 1
        modelContext.insert(profile)

        let habit1 = Habit(name: "Morning Run", habitDescription: "5km", frequency: .daily, xpValue: 20)
        modelContext.insert(habit1)

        let today = calendar.startOfDay(for: Date())
        // Habit 1: Completed 9, 8, 7 days ago, complete today -> bridges 6 missed days and consumes the 1 freeze
        for daysAgo in [9, 8, 7] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit1, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        let todayLog1 = HabitLog(habit: habit1, completionDate: today, isCompleted: true)
        modelContext.insert(todayLog1)
        try modelContext.save()

        gamification.processHabitCompletion(habit: habit1, profile: profile)
        try modelContext.save()

        XCTAssertEqual(habit1.streak, 4)
        XCTAssertEqual(profile.streakFreezes, 0, "Freeze should be spent")

        // Habit 2: With the freeze spent (streakFreezes == 0), the same 6-day gap a second time must NOT survive
        let habit2 = Habit(name: "Meditation", habitDescription: "10 mins", frequency: .daily, xpValue: 15)
        modelContext.insert(habit2)
        for daysAgo in [9, 8, 7] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit2, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        gamification.updateHabitStreak(habit: habit2, profile: profile)
        try modelContext.save()

        // 6 missed days exceeds 5-day threshold with 0 freezes -> streak resets to 0
        XCTAssertEqual(habit2.streak, 0, "With freeze spent, a 6-day gap must NOT survive (streak resets to 0)")
    }

    // MARK: - Round 3 Reproduction Tests: Issue #80 & Issue #82

    @MainActor
    func testStreakAnalyticsWithFreezeBridgedGapReportsStreakAlive() async throws {
        let sut = StreakService(modelContext: modelContext)
        let profile = PlayerProfile()
        profile.streakFreezes = 1
        modelContext.insert(profile)

        let habit = Habit(name: "Reading", habitDescription: "Read 20 pages", frequency: .daily, xpValue: 15)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Completed 9, 8, 7 days ago (streak of 3, gap of 6 missed days to today)
        for daysAgo in [9, 8, 7] {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        try modelContext.save()

        // When passing profile with 1 freeze, 6-day gap is bridged -> streak alive (3)
        let analyticsWithFreeze = await sut.getStreakAnalytics(for: habit, profile: profile)
        XCTAssertEqual(analyticsWithFreeze.currentStreak, 3, "Analytics with 1 freeze should report 6-day gap bridged as alive streak")

        // Without profile (0 freezes available), 6-day gap exceeds default 5-day threshold -> streak is 0 (broken)
        let analyticsWithoutFreeze = await sut.getStreakAnalytics(for: habit)
        XCTAssertEqual(analyticsWithoutFreeze.currentStreak, 0, "Analytics without freezes should report streak broken (0)")
    }

    @MainActor
    func testWeeklyHabitStreakForgivenessJudgedInDays() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Weekly Review", habitDescription: "Review goals", frequency: .weekly, xpValue: 30)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Normal 1-week cadence: completed 7 days ago and today
        let log7DaysAgo = HabitLog(habit: habit, completionDate: calendar.date(byAdding: .day, value: -7, to: today)!, isCompleted: true)
        let todayLog = HabitLog(habit: habit, completionDate: today, isCompleted: true)
        modelContext.insert(log7DaysAgo)
        modelContext.insert(todayLog)
        try modelContext.save()

        let normalStreak = await sut.calculateCurrentStreak(for: habit)
        XCTAssertEqual(normalStreak, 2, "Weekly habit on normal 7-day cadence must survive with streak 2")
        let longestNormal = await sut.calculateLongestStreak(for: habit)
        XCTAssertEqual(longestNormal, 2, "calculateLongestStreak must survive 7-day cadence for weekly habit")
    }

    @MainActor
    func testWeeklyHabitMissingTwoWeeksResetsWithFiveDayThreshold() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Weekly Review", habitDescription: "Review goals", frequency: .weekly, xpValue: 30)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Missing 2 weeks (21 days between completions -> 14 missed days)
        let log21DaysAgo = HabitLog(habit: habit, completionDate: calendar.date(byAdding: .day, value: -21, to: today)!, isCompleted: true)
        let todayLog = HabitLog(habit: habit, completionDate: today, isCompleted: true)
        modelContext.insert(log21DaysAgo)
        modelContext.insert(todayLog)
        try modelContext.save()

        let streak = await sut.calculateCurrentStreak(for: habit, forgivenessThreshold: 5)
        XCTAssertEqual(streak, 1, "Weekly habit missing 2 weeks exceeds 5-day threshold and resets streak")
    }

    @MainActor
    func testWeeklyHabitMissingOneWeekSurvivesWithFreezes() async throws {
        let gamification = GamificationService()
        let profile = PlayerProfile()
        profile.streakFreezes = 2
        modelContext.insert(profile)

        let habit = Habit(name: "Weekly Review", habitDescription: "Review goals", frequency: .weekly, xpValue: 30)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // Missing 1 week: completed 14 days ago and today (7 missed days beyond expected 7-day cadence)
        let log14DaysAgo = HabitLog(habit: habit, completionDate: calendar.date(byAdding: .day, value: -14, to: today)!, isCompleted: true)
        let todayLog = HabitLog(habit: habit, completionDate: today, isCompleted: true)
        modelContext.insert(log14DaysAgo)
        modelContext.insert(todayLog)
        try modelContext.save()

        gamification.updateHabitStreak(habit: habit, profile: profile, forgivenessThreshold: 5)
        try modelContext.save()

        // 7 missed days - 2 freezes = 5 effective missed days <= 5 threshold -> streak survives (2)
        XCTAssertEqual(habit.streak, 2, "Weekly habit missing 1 week survives with 2 freezes bridging the gap")
        XCTAssertEqual(profile.streakFreezes, 0, "2 freezes should be consumed")
    }

    @MainActor
    func testMonthlyHabitStreakForgivenessJudgedInDays() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Monthly Audit", habitDescription: "Audit finances", frequency: .monthly, xpValue: 50)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: today)!
        let logMonthAgo = HabitLog(habit: habit, completionDate: oneMonthAgo, isCompleted: true)
        let todayLog = HabitLog(habit: habit, completionDate: today, isCompleted: true)
        modelContext.insert(logMonthAgo)
        modelContext.insert(todayLog)
        try modelContext.save()

        let normalStreak = await sut.calculateCurrentStreak(for: habit)
        XCTAssertEqual(normalStreak, 2, "Monthly habit on normal 1-month cadence must survive with streak 2")
        let longestNormal = await sut.calculateLongestStreak(for: habit)
        XCTAssertEqual(longestNormal, 2, "calculateLongestStreak must survive 1-month cadence for monthly habit")
    }

    @MainActor
    func testMonthlyHabitMissingTwoMonthsResetsWithFiveDayThreshold() async throws {
        let sut = StreakService(modelContext: modelContext)
        let habit = Habit(name: "Monthly Audit", habitDescription: "Audit finances", frequency: .monthly, xpValue: 50)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: today)!
        let logTwoMonthsAgo = HabitLog(habit: habit, completionDate: twoMonthsAgo, isCompleted: true)
        let todayLog = HabitLog(habit: habit, completionDate: today, isCompleted: true)
        modelContext.insert(logTwoMonthsAgo)
        modelContext.insert(todayLog)
        try modelContext.save()

        let streak = await sut.calculateCurrentStreak(for: habit, forgivenessThreshold: 5)
        XCTAssertEqual(streak, 1, "Monthly habit missing 2 months exceeds 5-day threshold and resets streak")
    }

    @MainActor
    func testMilestoneHelpersThreadProfileWithFreezes() async throws {
        let sut = StreakService(modelContext: modelContext)
        let profile = PlayerProfile()
        profile.streakFreezes = 1
        modelContext.insert(profile)

        let habit = Habit(name: "Daily Meditation", habitDescription: "Mindfulness", frequency: .daily, xpValue: 20)
        modelContext.insert(habit)

        let today = calendar.startOfDay(for: Date())
        // 6 completions ending 7 days ago (streak of 6)
        for daysAgo in 7...12 {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let log = HabitLog(habit: habit, completionDate: logDate, isCompleted: true)
            modelContext.insert(log)
        }
        // Completed today -> bridges 6 missed days with 1 freeze + 5 threshold -> streak becomes 7 (Milestone!)
        let todayLog = HabitLog(habit: habit, completionDate: today, isCompleted: true)
        modelContext.insert(todayLog)
        try modelContext.save()

        // With profile, current milestone detects 7-day milestone
        let currentMilestone = await sut.getCurrentMilestone(for: habit, profile: profile)
        XCTAssertNotNil(currentMilestone)
        XCTAssertEqual(currentMilestone?.streakCount, 7)

        // checkForNewMilestone detects transition to 7
        let newMilestone = await sut.checkForNewMilestone(habit: habit, previousStreak: 6, profile: profile)
        XCTAssertNotNil(newMilestone)
        XCTAssertEqual(newMilestone?.streakCount, 7)

        // Without profile (0 freezes), 6 missed days breaks streak to 1 -> no 7-day milestone reached
        let noFreezeMilestone = await sut.checkForNewMilestone(habit: habit, previousStreak: 6)
        XCTAssertNil(noFreezeMilestone, "Without freeze, streak breaks to 1 so no milestone transition is achieved")
    }
}
