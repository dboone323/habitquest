@testable import HabitQuest
import XCTest

@MainActor
final class AchievementServiceTests: XCTestCase {
    // MARK: - enumAchievementService{ Tests

    func testAchievementServiceInitialization() {
        // Given - AchievementService is an enum with static methods, not instantiatable
        // Test that createDefaultAchievements() creates the expected set of achievements
        
        // When
        let achievements = AchievementService.createDefaultAchievements()
        
        // Then - Verify 15 default achievements are created
        XCTAssertEqual(achievements.count, 15)
        
        // Verify category distribution
        let streakAchievements = achievements.filter { $0.category == .streak }
        XCTAssertEqual(streakAchievements.count, 4)
        
        let completionAchievements = achievements.filter { $0.category == .completion }
        XCTAssertEqual(completionAchievements.count, 3)
        
        let levelAchievements = achievements.filter { $0.category == .level }
        XCTAssertEqual(levelAchievements.count, 3)
        
        let consistencyAchievements = achievements.filter { $0.category == .consistency }
        XCTAssertEqual(consistencyAchievements.count, 2)
        
        let specialAchievements = achievements.filter { $0.category == .special }
        XCTAssertEqual(specialAchievements.count, 3)
        
        // Verify specific achievements
        let firstSteps = achievements.first { $0.name == "First Steps" }
        XCTAssertNotNil(firstSteps)
        XCTAssertEqual(firstSteps?.xpReward, 25)
        XCTAssertEqual(firstSteps?.isHidden, false)
        
        let legend = achievements.first { $0.name == "Legend" }
        XCTAssertNotNil(legend)
        XCTAssertEqual(legend?.xpReward, 1000)
        XCTAssertEqual(legend?.isHidden, true)
    }

    func testAchievementServiceProperties() {
        // Given - Test achievement properties and requirement types
        let achievements = AchievementService.createDefaultAchievements()
        
        // Then - All achievements should start unlocked = false and progress = 0
        for achievement in achievements {
            XCTAssertEqual(achievement.isUnlocked, false)
            XCTAssertEqual(achievement.progress, 0.0)
            XCTAssertNil(achievement.unlockedDate)
            XCTAssertFalse(achievement.name.isEmpty)
            XCTAssertFalse(achievement.achievementDescription.isEmpty)
            XCTAssertFalse(achievement.iconName.isEmpty)
            XCTAssertGreaterThan(achievement.xpReward, 0)
        }
        
        // Test achievement requirement types
        let weekWarrior = achievements.first { $0.name == "Week Warrior" }
        if case .streakDays(let days) = weekWarrior?.requirement {
            XCTAssertEqual(days, 7)
        } else {
            XCTFail("Expected streakDays requirement")
        }
        
        let gettingStarted = achievements.first { $0.name == "Getting Started" }
        if case .totalCompletions(let count) = gettingStarted?.requirement {
            XCTAssertEqual(count, 10)
        } else {
            XCTFail("Expected totalCompletions requirement")
        }
        
        let levelUp = achievements.first { $0.name == "Level Up!" }
        if case .reachLevel(let level) = levelUp?.requirement {
            XCTAssertEqual(level, 5)
        } else {
            XCTFail("Expected reachLevel requirement")
        }
        
        // Test AchievementCategory properties
        XCTAssertEqual(AchievementCategory.streak.displayName, "Streak Master")
        XCTAssertEqual(AchievementCategory.completion.displayName, "Quest Completion")
        XCTAssertEqual(AchievementCategory.level.displayName, "Level Progression")
        
        // Test AchievementRequirement descriptions
        XCTAssertEqual(AchievementRequirement.streakDays(7).description, "Maintain a 7-day streak")
        XCTAssertEqual(AchievementRequirement.totalCompletions(100).description, "Complete 100 habits total")
        XCTAssertEqual(AchievementRequirement.perfectWeek.description, "Complete all habits for 7 consecutive days")
    }

    func testAchievementServiceMethods() {
        // Given - Create test data for achievement progress tracking
        // This is a simplified test since full testing would require complex mocking of PlayerProfile and Habit
        
        // Test that the service methods exist and are callable
        let achievements = AchievementService.createDefaultAchievements()
        XCTAssertFalse(achievements.isEmpty)
        
        // Test achievement progress percentage formatting
        let testAchievement = achievements[0]
        testAchievement.progress = 0.5
        XCTAssertEqual(testAchievement.progressPercentage, "50%")
        
        testAchievement.progress = 0.0
        XCTAssertEqual(testAchievement.progressPercentage, "0%")
        
        testAchievement.progress = 1.0
        XCTAssertEqual(testAchievement.progressPercentage, "100%")
        
        testAchievement.progress = 0.755
        XCTAssertEqual(testAchievement.progressPercentage, "76%") // Rounds to nearest integer
    }
}
