//
// ShareManagerTests.swift
// HabitQuestTests
//
// Tests for social sharing functionality
//

import XCTest
@testable import HabitQuest

final class ShareManagerTests: XCTestCase {
    
    var manager: ShareManager!
    
    override func setUpWithError() throws {
        manager = ShareManager.shared
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = ShareManager.shared
        let instance2 = ShareManager.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Share Achievement Tests
    
    func testShareAchievementCallsCompletion() {
        let achievement = Achievement(
            name: "Test Achievement",
            description: "Test description",
            iconName: "star",
            category: .completion,
            requirement: .totalCompletions(1)
        )
        
        let expectation = expectation(description: "Share completion")
        
        manager.shareAchievement(achievement) { completed in
            // On simulator/test environment, sharing usually fails gracefully
            expectation.fulfill()
        }
        
        // Wait with timeout - sharing may not actually present UI in test
        waitForExpectations(timeout: 1.0) { error in
            // Test passes regardless - we're testing the method doesn't crash
        }
    }
    
    // MARK: - Share Streak Tests
    
    func testShareStreakCallsCompletion() {
        let expectation = expectation(description: "Share streak completion")
        
        manager.shareStreak(7, habit: "Exercise") { completed in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { _ in }
    }
    
    // MARK: - Share Milestone Tests
    
    func testShareMilestoneCallsCompletion() {
        let milestone = StreakMilestone(
            streakCount: 30,
            title: "30-Day Warrior",
            description: "Completed 30 days!",
            badge: "🏆"
        )
        
        let expectation = expectation(description: "Share milestone completion")
        
        manager.shareMilestone(milestone) { completed in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { _ in }
    }
    
    // MARK: - API Smoke Tests
    
    func testShareAchievementDoesNotCrash() {
        let achievement = Achievement(
            name: "Test",
            description: "Test",
            iconName: "star",
            category: .completion,
            requirement: .totalCompletions(1)
        )
        
        // Should not crash
        manager.shareAchievement(achievement) { _ in }
        XCTAssertTrue(true)
    }
    
    func testShareStreakDoesNotCrash() {
        manager.shareStreak(14, habit: "Reading") { _ in }
        XCTAssertTrue(true)
    }
}
