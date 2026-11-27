import HabitQuestCore
import SwiftData
import XCTest
@testable import HabitQuest

final class PlayerProfileTests: XCTestCase {

    // MARK: - Initialization & Default Property Tests

    func testDefaultInitialization() {
        let profile = PlayerProfile()

        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.currentXP, 0)
        XCTAssertEqual(profile.xpForNextLevel, 100)
        XCTAssertEqual(profile.longestStreak, 0)
        XCTAssertEqual(profile.streakFreezes, 0)
        XCTAssertNotNil(profile.creationDate)
        XCTAssertEqual(profile.xpProgress, 0.0)
    }

    func testCustomPropertyUpdates() {
        let profile = PlayerProfile()
        profile.level = 5
        profile.currentXP = 600
        profile.xpForNextLevel = 750
        profile.longestStreak = 14
        profile.streakFreezes = 3

        XCTAssertEqual(profile.level, 5)
        XCTAssertEqual(profile.currentXP, 600)
        XCTAssertEqual(profile.xpForNextLevel, 750)
        XCTAssertEqual(profile.longestStreak, 14)
        XCTAssertEqual(profile.streakFreezes, 3)
    }

    func testXPProgressCalculation() {
        let profile = PlayerProfile()
        profile.level = 1
        profile.currentXP = 50
        profile.xpForNextLevel = 100

        // At level 1, currentThreshold = 100 * 1.5^0 = 100, nextThreshold = 100, range <= 0 -> 0.0
        XCTAssertEqual(profile.xpProgress, 0.0)

        // At level 2
        profile.level = 2
        profile.xpForNextLevel = 225
        profile.currentXP = 180
        // currentThreshold = 100 * 1.5^1 = 150
        // nextThreshold = 225, range = 75
        // (180 - 150) / 75 = 30 / 75 = 0.4
        XCTAssertEqual(profile.xpProgress, 0.4, accuracy: 0.001)
    }
}
