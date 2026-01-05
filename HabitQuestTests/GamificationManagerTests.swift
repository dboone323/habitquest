//
// GamificationManagerTests.swift
// HabitQuestTests
//
// Tests for gamification and achievement management
//

import XCTest
@testable import HabitQuest

final class GamificationManagerTests: XCTestCase {
    
    var manager: GamificationManager!
    
    override func setUpWithError() throws {
        manager = GamificationManager()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialAchievementsExist() {
        XCTAssertFalse(manager.achievements.isEmpty)
    }
    
    func testFirstStepAchievementExists() {
        let firstStep = manager.achievements.first { $0.name == "First Step" }
        XCTAssertNotNil(firstStep)
        XCTAssertEqual(firstStep?.description, "Complete your first habit")
    }
    
    func testOnFireAchievementExists() {
        let onFire = manager.achievements.first { $0.name == "On Fire" }
        XCTAssertNotNil(onFire)
        XCTAssertEqual(onFire?.description, "7-day streak")
    }
    
    func testInitialAchievementsNotUnlocked() {
        for achievement in manager.achievements {
            XCTAssertFalse(achievement.isUnlocked)
        }
    }
    
    // MARK: - Achievement Unlock Tests
    
    func testCheckAchievementsUnlocksFirstStep() {
        // Given: No completions
        XCTAssertFalse(manager.achievements.first { $0.name == "First Step" }?.isUnlocked ?? true)
        
        // When: Complete first habit
        manager.checkAchievements(habitsCompleted: 1, currentStreak: 0)
        
        // Then: First Step should be unlocked
        let firstStep = manager.achievements.first { $0.name == "First Step" }
        XCTAssertTrue(firstStep?.isUnlocked ?? false)
    }
    
    func testCheckAchievementsUnlocksOnFire() {
        // Given: No streak
        XCTAssertFalse(manager.achievements.first { $0.name == "On Fire" }?.isUnlocked ?? true)
        
        // When: Reach 7-day streak
        manager.checkAchievements(habitsCompleted: 7, currentStreak: 7)
        
        // Then: On Fire should be unlocked
        let onFire = manager.achievements.first { $0.name == "On Fire" }
        XCTAssertTrue(onFire?.isUnlocked ?? false)
    }
    
    func testCheckAchievementsDoesNotUnlockWithoutRequirement() {
        // When: No completions or streak
        manager.checkAchievements(habitsCompleted: 0, currentStreak: 0)
        
        // Then: Nothing should be unlocked
        for achievement in manager.achievements {
            XCTAssertFalse(achievement.isUnlocked)
        }
    }
    
    func testUnlockSetsProgress() {
        // When: Complete first habit
        manager.checkAchievements(habitsCompleted: 1, currentStreak: 0)
        
        // Then: Progress should be 1.0
        let firstStep = manager.achievements.first { $0.name == "First Step" }
        XCTAssertEqual(firstStep?.progress, 1.0)
    }
    
    func testUnlockSetsDate() {
        // When: Complete first habit
        manager.checkAchievements(habitsCompleted: 1, currentStreak: 0)
        
        // Then: Should have unlock date
        let firstStep = manager.achievements.first { $0.name == "First Step" }
        XCTAssertNotNil(firstStep?.unlockedDate)
    }
    
    // MARK: - Achievement Category Tests
    
    func testFirstStepIsCompletionCategory() {
        let firstStep = manager.achievements.first { $0.name == "First Step" }
        XCTAssertEqual(firstStep?.category, .completion)
    }
    
    func testOnFireIsStreakCategory() {
        let onFire = manager.achievements.first { $0.name == "On Fire" }
        XCTAssertEqual(onFire?.category, .streak)
    }
}
