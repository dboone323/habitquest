@testable import HabitQuest
import XCTest

@MainActor
final class StreakManagerTests: XCTestCase {
    var streakManager: StreakManager!

    override func setUp() {
        super.setUp()
        streakManager = StreakManager()
    }

    override func tearDown() {
        streakManager = nil
        super.tearDown()
    }

    // MARK: - Streak Calculation Tests

    func testCalculateStreak_NoCompletions() {
        let completions: [Date] = []
        let streak = streakManager.calculateStreak(completions: completions)

        XCTAssertEqual(streak, 0)
    }

    func testCalculateStreak_SingleDay() {
        let completions = [Date()]
        let streak = streakManager.calculateStreak(completions: completions)

        XCTAssertEqual(streak, 1)
    }

    func testCalculateStreak_ConsecutiveDays() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!

        let completions = [today, yesterday, twoDaysAgo]
        let streak = streakManager.calculateStreak(completions: completions)

        XCTAssertEqual(streak, 3)
    }

    func testCalculateStreak_BrokenStreak() {
        let today = Date()
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!

        let completions = [today, threeDaysAgo]
        let streak = streakManager.calculateStreak(completions: completions)

        XCTAssertEqual(streak, 1, "Streak should reset after gap")
    }

    func testCalculateStreak_LongestStreak() {
        var completions: [Date] = []
        for i in 0 ..< 30 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            completions.append(date)
        }

        let streak = streakManager.calculateStreak(completions: completions)
        XCTAssertEqual(streak, 30)
    }

    // MARK: - Streak Reset Tests

    func testStreakReset_MissedDay() {
        let today = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!

        let completions = [twoDaysAgo]
        let streak = streakManager.calculateStreak(completions: completions)

        XCTAssertEqual(streak, 0, "Should reset if last completion was not yesterday or today")
    }

    func testStreakReset_ExplicitReset() {
        var completions = [Date(), Date().addingTimeInterval(-86400)]
        streakManager.resetStreak(completions: &completions)

        XCTAssertEqual(completions.count, 0)
    }

    // MARK: - Milestone Detection Tests

    func testMilestoneDetection_7Days() {
        var completions: [Date] = []
        for i in 0 ..< 7 {
            completions.append(Calendar.current.date(byAdding: .day, value: -i, to: Date())!)
        }

        let milestone = streakManager.checkMilestone(streak: 7)
        XCTAssertEqual(milestone?.streakCount, 7)
    }

    func testMilestoneDetection_30Days() {
        let milestone = streakManager.checkMilestone(streak: 30)
        XCTAssertEqual(milestone?.streakCount, 30)
    }

    func testMilestoneDetection_100Days() {
        let milestone = streakManager.checkMilestone(streak: 100)
        XCTAssertEqual(milestone?.streakCount, 100)
    }

    func testMilestoneDetection_365Days() {
        let milestone = streakManager.checkMilestone(streak: 365)
        XCTAssertEqual(milestone?.streakCount, 365)
    }

    func testMilestoneDetection_NoMilestone() {
        let milestone = streakManager.checkMilestone(streak: 5)
        XCTAssertNil(milestone)
    }

    // MARK: - Streak Statistics Tests

    func testStreakStatistics() {
        var completions: [Date] = []
        for i in 0 ..< 15 {
            completions.append(Calendar.current.date(byAdding: .day, value: -i, to: Date())!)
        }

        let stats = streakManager.getStatistics(completions: completions)

        XCTAssertEqual(stats.currentStreak, 15)
        XCTAssertEqual(stats.longestStreak, 15)
        XCTAssertEqual(stats.totalCompletions, 15)
    }

    func testStreakPercentage() {
        let totalDays = 30
        let completedDays = 20

        let percentage = streakManager.calculateCompletionPercentage(
            completed: completedDays,
            total: totalDays
        )

        XCTAssertEqual(percentage, 66.67, accuracy: 0.1)
    }
}
