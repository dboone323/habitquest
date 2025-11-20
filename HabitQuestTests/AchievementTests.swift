import XCTest

@testable import HabitQuest

final class AchievementTests: XCTestCase {
    // MARK: - enumAchievementCategory Tests

    func testAchievementCategoryInitialization() {
        // Test basic initialization
        let streakCategory = AchievementCategory.streak
        let completionCategory = AchievementCategory.completion
        let levelCategory = AchievementCategory.level
        let consistencyCategory = AchievementCategory.consistency
        let specialCategory = AchievementCategory.special

        XCTAssertEqual(streakCategory, .streak)
        XCTAssertEqual(completionCategory, .completion)
        XCTAssertEqual(levelCategory, .level)
        XCTAssertEqual(consistencyCategory, .consistency)
        XCTAssertEqual(specialCategory, .special)
    }

    func testAchievementCategoryProperties() async {
        // Test property access and validation
        let streakCategory = AchievementCategory.streak
        await MainActor.run {
            XCTAssertEqual(streakCategory.displayName, "Streak Master")
            XCTAssertEqual(streakCategory.color, "orange")
        }
        XCTAssertEqual(streakCategory.rawValue, "streak")

        let completionCategory = AchievementCategory.completion
        await MainActor.run {
            XCTAssertEqual(completionCategory.displayName, "Quest Completion")
            XCTAssertEqual(completionCategory.color, "green")
        }

        let levelCategory = AchievementCategory.level
        await MainActor.run {
            XCTAssertEqual(levelCategory.displayName, "Level Progression")
            XCTAssertEqual(levelCategory.color, "blue")
        }

        let consistencyCategory = AchievementCategory.consistency
        await MainActor.run {
            XCTAssertEqual(consistencyCategory.displayName, "Consistency")
            XCTAssertEqual(consistencyCategory.color, "purple")
        }

        let specialCategory = AchievementCategory.special
        await MainActor.run {
            XCTAssertEqual(specialCategory.displayName, "Special Events")
            XCTAssertEqual(specialCategory.color, "yellow")
        }
    }

    func testAchievementCategoryMethods() {
        // Test method functionality
        let allCategories = AchievementCategory.allCases
        XCTAssertEqual(allCategories.count, 5)
        XCTAssertTrue(allCategories.contains(.streak))
        XCTAssertTrue(allCategories.contains(.completion))
        XCTAssertTrue(allCategories.contains(.level))
        XCTAssertTrue(allCategories.contains(.consistency))
        XCTAssertTrue(allCategories.contains(.special))
    }

    // MARK: - enumAchievementRequirement Tests

    func testAchievementRequirementInitialization() {
        // Test basic initialization
        let streakRequirement = AchievementRequirement.streakDays(7)
        let completionRequirement = AchievementRequirement.totalCompletions(100)
        let levelRequirement = AchievementRequirement.reachLevel(10)
        let perfectWeekRequirement = AchievementRequirement.perfectWeek
        let varietyRequirement = AchievementRequirement.habitVariety(5)

        XCTAssertNotNil(streakRequirement)
        XCTAssertNotNil(completionRequirement)
        XCTAssertNotNil(levelRequirement)
        XCTAssertNotNil(perfectWeekRequirement)
        XCTAssertNotNil(varietyRequirement)
    }

    func testAchievementRequirementProperties() async {
        // Test property access and validation
        let streakRequirement = AchievementRequirement.streakDays(14)
        await MainActor.run {
            XCTAssertEqual(streakRequirement.description, "Maintain a 14-day streak")
        }

        let completionRequirement = AchievementRequirement.totalCompletions(50)
        await MainActor.run {
            XCTAssertEqual(completionRequirement.description, "Complete 50 habits total")
        }

        let levelRequirement = AchievementRequirement.reachLevel(5)
        await MainActor.run {
            XCTAssertEqual(levelRequirement.description, "Reach level 5")
        }

        let perfectWeekRequirement = AchievementRequirement.perfectWeek
        await MainActor.run {
            XCTAssertEqual(
                perfectWeekRequirement.description, "Complete all habits for 7 consecutive days"
            )
        }

        let varietyRequirement = AchievementRequirement.habitVariety(3)
        await MainActor.run {
            XCTAssertEqual(varietyRequirement.description, "Have 3 different active habits")
        }

        let earlyBirdRequirement = AchievementRequirement.earlyBird
        await MainActor.run {
            XCTAssertEqual(earlyBirdRequirement.description, "Complete habits before 9 AM for 7 days")
        }

        let nightOwlRequirement = AchievementRequirement.nightOwl
        await MainActor.run {
            XCTAssertEqual(nightOwlRequirement.description, "Complete habits after 9 PM for 7 days")
        }

        let weekendWarriorRequirement = AchievementRequirement.weekendWarrior
        await MainActor.run {
            XCTAssertEqual(
                weekendWarriorRequirement.description, "Complete habits on weekends for 4 weeks"
            )
        }
    }

    // MARK: - Achievement Tests

    func testAchievementInitialization() {
        // Test basic initialization
        let achievement = Achievement(
            name: "Test Achievement",
            description: "A test achievement",
            iconName: "trophy",
            category: .streak,
            xpReward: 100,
            isHidden: false,
            requirement: .streakDays(7)
        )

        XCTAssertNotNil(achievement)
        XCTAssertEqual(achievement.name, "Test Achievement")
        XCTAssertEqual(achievement.category, .streak)
        XCTAssertEqual(achievement.xpReward, 100)
        XCTAssertFalse(achievement.isUnlocked)
        XCTAssertEqual(achievement.progress, 0.0)
    }

    func testAchievementProgress() {
        // Test progress tracking
        var achievement = Achievement(
            name: "Progress Test",
            description: "Testing progress",
            iconName: "star",
            category: .completion,
            xpReward: 50,
            isHidden: false,
            requirement: .totalCompletions(10)
        )
        achievement.progress = 0.5

        XCTAssertEqual(achievement.progress, 0.5)

        achievement.progress = 0.8
        XCTAssertEqual(achievement.progress, 0.8)

        achievement.unlockedDate = Date()
        XCTAssertTrue(achievement.isUnlocked)
        XCTAssertNotNil(achievement.unlockedDate)
    }

    func testAchievementUnlocking() {
        // Test unlocking functionality
        var achievement = Achievement(
            name: "Unlock Test",
            description: "Testing unlock",
            iconName: "level",
            category: .level,
            xpReward: 200,
            isHidden: false,
            requirement: .reachLevel(5)
        )
        achievement.progress = 1.0

        XCTAssertFalse(achievement.isUnlocked)
        XCTAssertNil(achievement.unlockedDate)

        achievement.unlockedDate = Date()

        XCTAssertTrue(achievement.isUnlocked)
        XCTAssertNotNil(achievement.unlockedDate)
    }

    func testAchievementCategories() {
        // Test all achievement categories
        let achievements = [
            Achievement(
                name: "Streak", description: "Streak", iconName: "fire", category: .streak,
                xpReward: 100, isHidden: false, requirement: .streakDays(7)
            ),
            Achievement(
                name: "Completion", description: "Completion", iconName: "check", category: .completion,
                xpReward: 100, isHidden: false, requirement: .totalCompletions(100)
            ),
            Achievement(
                name: "Level", description: "Level", iconName: "star", category: .level,
                xpReward: 100, isHidden: false, requirement: .reachLevel(10)
            ),
            Achievement(
                name: "Consistency", description: "Consistency", iconName: "clock", category: .consistency,
                xpReward: 100, isHidden: false, requirement: .perfectWeek
            ),
            Achievement(
                name: "Special", description: "Special", iconName: "gem", category: .special,
                xpReward: 100, isHidden: false, requirement: .earlyBird
            )
        ]

        XCTAssertEqual(achievements.count, 5)
        XCTAssertTrue(achievements.contains { $0.category == .streak })
        XCTAssertTrue(achievements.contains { $0.category == .completion })
        XCTAssertTrue(achievements.contains { $0.category == .level })
        XCTAssertTrue(achievements.contains { $0.category == .consistency })
        XCTAssertTrue(achievements.contains { $0.category == .special })
    }
}
