import XCTest
@testable import HabitQuest

@MainActor
final class StreakMilestoneTests: XCTestCase {
    // MARK: - structStreakMilestone:Identifiable,@uncheckedSendable{ Tests

    func testStreakMilestoneInitialization() {
        // Given
        let streakCount = 7
        let title = "One Week Warrior"
        let description = "A full week of dedication!"
        let emoji = "🔥🔥"
        let celebrationLevel = StreakMilestone.CelebrationLevel.intermediate

        // When
        let milestone = StreakMilestone(
            streakCount: streakCount,
            title: title,
            description: description,
            emoji: emoji,
            celebrationLevel: celebrationLevel
        )

        // Then
        XCTAssertNotNil(milestone.id)
        XCTAssertEqual(milestone.streakCount, streakCount)
        XCTAssertEqual(milestone.title, title)
        XCTAssertEqual(milestone.description, description)
        XCTAssertEqual(milestone.emoji, emoji)
        XCTAssertEqual(milestone.celebrationLevel, celebrationLevel)
    }

    func testStreakMilestoneProperties() {
        // Given - Test predefined milestones
        let predefinedMilestones = StreakMilestone.predefinedMilestones

        // Then - Verify all 7 predefined milestones
        XCTAssertEqual(predefinedMilestones.count, 7)

        // Test specific milestones
        let first = predefinedMilestones[0]
        XCTAssertEqual(first.streakCount, 3)
        XCTAssertEqual(first.title, "Getting Started")
        XCTAssertEqual(first.celebrationLevel, .basic)

        let weekly = predefinedMilestones[1]
        XCTAssertEqual(weekly.streakCount, 7)
        XCTAssertEqual(weekly.title, "One Week Warrior")
        XCTAssertEqual(weekly.celebrationLevel, .intermediate)

        let monthly = predefinedMilestones[3]
        XCTAssertEqual(monthly.streakCount, 30)
        XCTAssertEqual(monthly.celebrationLevel, .advanced)

        let century = predefinedMilestones[5]
        XCTAssertEqual(century.streakCount, 100)
        XCTAssertEqual(century.celebrationLevel, .epic)

        let yearly = predefinedMilestones[6]
        XCTAssertEqual(yearly.streakCount, 365)
        XCTAssertEqual(yearly.celebrationLevel, .legendary)

        // Test celebration level properties
        XCTAssertEqual(StreakMilestone.CelebrationLevel.basic.particleCount, 10)
        XCTAssertEqual(StreakMilestone.CelebrationLevel.legendary.particleCount, 100)
        XCTAssertEqual(StreakMilestone.CelebrationLevel.basic.animationIntensity, 0.5)
        XCTAssertEqual(StreakMilestone.CelebrationLevel.legendary.animationIntensity, 1.5)
    }

    func testStreakMilestoneMethods() {
        // Test milestone(for:) - get current milestone
        let milestone5 = StreakMilestone.milestone(for: 5)
        XCTAssertNotNil(milestone5)
        XCTAssertEqual(milestone5?.streakCount, 3) // Should return "Getting Started" (3 days)

        let milestone7 = StreakMilestone.milestone(for: 7)
        XCTAssertEqual(milestone7?.streakCount, 7) // Exactly at 7 day milestone

        let milestone50 = StreakMilestone.milestone(for: 50)
        XCTAssertEqual(milestone50?.streakCount, 50) // Exactly at 50 day milestone

        let milestone200 = StreakMilestone.milestone(for: 200)
        XCTAssertEqual(milestone200?.streakCount, 100) // Should return century (100 days)

        // Test nextMilestone(for:) - get next milestone to achieve
        let next1 = StreakMilestone.nextMilestone(for: 1)
        XCTAssertNotNil(next1)
        XCTAssertEqual(next1?.streakCount, 3)

        let next7 = StreakMilestone.nextMilestone(for: 7)
        XCTAssertEqual(next7?.streakCount, 14) // Next after 7 is 14

        let next100 = StreakMilestone.nextMilestone(for: 100)
        XCTAssertEqual(next100?.streakCount, 365) // Next after 100 is 365

        let next365 = StreakMilestone.nextMilestone(for: 365)
        XCTAssertNil(next365) // No milestone after 365

        // Test isNewMilestone(streakCount:previousCount:)
        XCTAssertTrue(StreakMilestone.isNewMilestone(streakCount: 3, previousCount: 2))
        XCTAssertFalse(StreakMilestone.isNewMilestone(streakCount: 4, previousCount: 3))
        XCTAssertTrue(StreakMilestone.isNewMilestone(streakCount: 7, previousCount: 6))
        XCTAssertFalse(StreakMilestone.isNewMilestone(streakCount: 8, previousCount: 7))

        // Test Comparable conformance
        let milestone3 = StreakMilestone.predefinedMilestones[0] // 3 days
        let milestone30 = StreakMilestone.predefinedMilestones[3] // 30 days
        XCTAssertTrue(milestone3 < milestone30)
        XCTAssertFalse(milestone30 < milestone3)
    }
}
