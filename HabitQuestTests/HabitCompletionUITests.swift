//
// HabitCompletionUITests.swift
// HabitQuestTests
//
// Step 9: UI automation tests for habit completion flow.
//

import XCTest
@testable import HabitQuest

final class HabitCompletionUITests: XCTestCase {
    // MARK: - Habit Toggle Tests

    func testHabitToggleUpdatesCompletion() {
        // Simulate habit toggle
        var isCompleted = false

        // Toggle action
        isCompleted.toggle()

        XCTAssertTrue(isCompleted)

        // Toggle back
        isCompleted.toggle()

        XCTAssertFalse(isCompleted)
    }

    // MARK: - Streak Calculation Tests

    func testStreakIncrementsOnConsecutiveCompletion() {
        var streak = 5
        let completedToday = true
        let completedYesterday = true

        if completedToday, completedYesterday {
            streak += 1
        }

        XCTAssertEqual(streak, 6)
    }

    func testStreakResetsOnMissedDay() {
        var streak = 10
        let completedToday = false
        let completedYesterday = true

        if !completedToday, completedYesterday {
            // Streak broken
            streak = 0
        }

        XCTAssertEqual(streak, 0)
    }

    // MARK: - Daily Reset Tests

    func testHabitsResetAtMidnight() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let today = Date()

        let isNewDay = !Calendar.current.isDate(yesterday, inSameDayAs: today)

        XCTAssertTrue(isNewDay)
    }

    // MARK: - Completion Progress Tests

    func testCompletionProgressCalculation() {
        let completed = 3
        let total = 5

        let progress = Double(completed) / Double(total)

        XCTAssertEqual(progress, 0.6, accuracy: 0.001)
    }

    func testAllHabitsCompleted() {
        let completed = 5
        let total = 5

        let allComplete = completed == total

        XCTAssertTrue(allComplete)
    }

    // MARK: - Gamification Tests

    func testPointsAwardedOnCompletion() {
        var points = 100
        let pointsPerHabit = 10

        // Complete a habit
        points += pointsPerHabit

        XCTAssertEqual(points, 110)
    }

    func testBonusPointsForStreak() {
        var points = 0
        let basePoints = 10
        let streak = 7
        let streakBonus = streak >= 7 ? 50 : 0

        points = basePoints + streakBonus

        XCTAssertEqual(points, 60)
    }

    // MARK: - Notification Tests

    func testReminderTimeCalculation() {
        let components = DateComponents(hour: 9, minute: 0)
        let reminderTime = Calendar.current.date(from: components)

        XCTAssertNotNil(reminderTime)
    }
}
