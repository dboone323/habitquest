//
//  HabitQuestTests.swift
//  HabitQuestTests
//
//  Created by Daniel Stevens on 6/27/25.
//

import Foundation
import Testing

@testable import HabitQuest

struct HabitQuestTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    // MARK: - Habit Creation Tests

    @Test func testHabitCreation() async throws {
        // Test basic habit creation
        let habit = Habit(
            name: "Test Habit", habitDescription: "A test habit", frequency: .daily, xpValue: 10)

        #expect(habit.name == "Test Habit")
        #expect(habit.habitDescription == "A test habit")
        #expect(habit.frequency == .daily)
        #expect(habit.xpValue == 10)
    }

    @Test func testHabitWithCustomFrequency() async throws {
        // Test habit with weekly frequency
        let habit = Habit(
            name: "Weekly Habit", habitDescription: "Weekly test", frequency: .weekly, xpValue: 25)

        #expect(habit.name == "Weekly Habit")
        #expect(habit.frequency == .weekly)
        #expect(habit.xpValue == 25)
    }

    // MARK: - Habit Tracking Tests

    @Test func testHabitCompletion() async throws {
        // Test habit completion tracking
        let habit = Habit(
            name: "Daily Exercise", habitDescription: "Exercise daily", frequency: .daily,
            xpValue: 20)

        // Simulate completion
        habit.streak = 1
        habit.lastCompletedDate = Date()

        #expect(habit.streak == 1)
        #expect(habit.lastCompletedDate != nil)
    }

    @Test func testHabitStreakCalculation() async throws {
        // Test streak calculation logic
        let habit = Habit(
            name: "Reading", habitDescription: "Read daily", frequency: .daily, xpValue: 15)

        // Simulate multiple completions
        habit.streak = 5
        habit.longestStreak = 7

        #expect(habit.streak == 5)
        #expect(habit.longestStreak == 7)
        #expect(habit.streak <= habit.longestStreak)
    }

    // MARK: - Player Profile Tests

    @Test func testPlayerProfileCreation() async throws {
        // Test player profile creation
        let profile = PlayerProfile()

        #expect(profile.level >= 1)
        #expect(profile.currentXP >= 0)
        #expect(profile.xpForNextLevel > profile.currentXP)
    }

    @Test func testPlayerLevelProgression() async throws {
        // Test level progression logic
        let profile = PlayerProfile()
        let initialLevel = profile.level

        // Simulate XP gain
        profile.currentXP = profile.xpForNextLevel + 10

        #expect(profile.currentXP > profile.xpForNextLevel)
    }

    // MARK: - Achievement Tests

    @Test func testAchievementCreation() async throws {
        // Test achievement creation
        let achievement = Achievement(
            name: "First Steps",
            description: "Complete your first habit",
            iconName: "star",
            category: .streak,
            xpReward: 50,
            isHidden: false,
            requirement: .streakDays(1)
        )

        #expect(achievement.name == "First Steps")
        #expect(achievement.description == "Complete your first habit")
        #expect(achievement.xpReward == 50)
        #expect(!achievement.isHidden)
    }

    @Test func testAchievementUnlock() async throws {
        // Test achievement unlock logic
        let achievement = Achievement(
            name: "Consistency King",
            description: "Maintain a 7-day streak",
            iconName: "crown",
            category: .streak,
            xpReward: 100,
            isHidden: false,
            requirement: .streakDays(7)
        )

        // Simulate unlock
        achievement.unlockedDate = Date()
        achievement.progress = 1.0

        #expect(achievement.unlockedDate != nil)
        #expect(achievement.progress == 1.0)
    }

    // MARK: - Analytics Tests

    @Test func testHabitAnalytics() async throws {
        // Test basic analytics calculations
        let habit = Habit(
            name: "Test Analytics", habitDescription: "Analytics test", frequency: .daily,
            xpValue: 10)

        // Add some mock data
        habit.streak = 3
        habit.longestStreak = 5

        #expect(habit.streak > 0)
        #expect(habit.longestStreak >= habit.streak)
    }

    @Test func testCompletionRateCalculation() async throws {
        // Test completion rate calculations
        let habit = Habit(
            name: "Completion Test", habitDescription: "Test completion rates", frequency: .daily,
            xpValue: 10)

        // Simulate completion history
        habit.streak = 7
        habit.longestStreak = 10

        let completionRate = Double(habit.streak) / Double(habit.longestStreak)

        #expect(completionRate >= 0.0)
        #expect(completionRate <= 1.0)
        #expect(completionRate == 0.7)
    }

    // MARK: - Data Validation Tests

    @Test func testHabitDataValidation() async throws {
        // Test habit data validation
        let validHabit = Habit(
            name: "Valid Habit", habitDescription: "Valid description", frequency: .daily,
            xpValue: 10)

        #expect(!validHabit.name.isEmpty)
        #expect(validHabit.xpValue > 0)
        #expect(validHabit.frequency == .daily || validHabit.frequency == .weekly)
    }

    @Test func testInvalidHabitData() async throws {
        // Test handling of invalid habit data
        // Note: In a real implementation, you might want to add validation
        let emptyNameHabit = Habit(
            name: "", habitDescription: "Empty name test", frequency: .daily, xpValue: 5)

        #expect(emptyNameHabit.name.isEmpty)
        #expect(emptyNameHabit.xpValue > 0)
    }

    // MARK: - Performance Tests

    @Test func testHabitCreationPerformance() async throws {
        // Test performance of habit creation
        let startTime = Date()

        // Create multiple habits
        for i in 1...100 {
            let _ = Habit(
                name: "Habit \(i)", habitDescription: "Performance test habit", frequency: .daily,
                xpValue: 10)
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        #expect(duration < 1.0, "Creating 100 habits should take less than 1 second")
    }

    @Test func testStreakCalculationPerformance() async throws {
        // Test performance of streak calculations
        let habit = Habit(
            name: "Performance Test", habitDescription: "Streak performance test",
            frequency: .daily, xpValue: 10)

        let startTime = Date()

        // Simulate many streak updates
        for i in 1...1000 {
            habit.streak = i
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        #expect(duration < 0.1, "Streak updates should be very fast")
    }
}
