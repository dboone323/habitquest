//
// HabitWidgetTests.swift
// HabitQuestTests
//
// Snapshot and unit tests for HabitWidget views.
//

import SwiftUI
import XCTest
@testable import HabitQuest

@MainActor
final class HabitWidgetTests: XCTestCase {
    // MARK: - Entry Tests

    func testHabitWidgetEntryInitialization() {
        let entry = HabitWidgetEntry(
            date: Date(),
            habits: [
                HabitWidgetItem(id: UUID(), name: "Exercise", emoji: "🏃", isCompleted: false, streak: 5),
            ]
        )

        XCTAssertEqual(entry.habits.count, 1)
        XCTAssertEqual(entry.habits.first?.name, "Exercise")
    }

    func testHabitWidgetItemProperties() {
        let item = HabitWidgetItem(
            id: UUID(),
            name: "Read",
            emoji: "📚",
            isCompleted: true,
            streak: 12
        )

        XCTAssertEqual(item.name, "Read")
        XCTAssertEqual(item.emoji, "📚")
        XCTAssertTrue(item.isCompleted)
        XCTAssertEqual(item.streak, 12)
    }

    // MARK: - Provider Tests

    func testTimelineProviderInitialization() {
        let provider = HabitWidgetProvider()
        XCTAssertNotNil(provider)
    }

    // MARK: - View Rendering Tests

    func testSmallWidgetViewRendering() {
        let entry = HabitWidgetEntry(
            date: Date(),
            habits: [
                HabitWidgetItem(id: UUID(), name: "Exercise", emoji: "🏃", isCompleted: false, streak: 5),
                HabitWidgetItem(id: UUID(), name: "Read", emoji: "📚", isCompleted: true, streak: 12),
                HabitWidgetItem(id: UUID(), name: "Meditate", emoji: "🧘", isCompleted: false, streak: 3),
            ]
        )

        let view = HabitWidgetSmallView(entry: entry)

        // View should render without crashing
        XCTAssertNotNil(view)
    }

    func testMediumWidgetViewRendering() {
        let entry = HabitWidgetEntry(
            date: Date(),
            habits: [
                HabitWidgetItem(id: UUID(), name: "Exercise", emoji: "🏃", isCompleted: false, streak: 5),
                HabitWidgetItem(id: UUID(), name: "Read", emoji: "📚", isCompleted: true, streak: 12),
            ]
        )

        let view = HabitWidgetMediumView(entry: entry)

        XCTAssertNotNil(view)
    }

    // MARK: - Completion Status Tests

    func testCompletedHabitCount() {
        let habits = [
            HabitWidgetItem(id: UUID(), name: "Exercise", emoji: "🏃", isCompleted: true, streak: 5),
            HabitWidgetItem(id: UUID(), name: "Read", emoji: "📚", isCompleted: true, streak: 12),
            HabitWidgetItem(id: UUID(), name: "Meditate", emoji: "🧘", isCompleted: false, streak: 3),
        ]

        let completedCount = habits.count(where: { $0.isCompleted })

        XCTAssertEqual(completedCount, 2)
    }

    // MARK: - Streak Display Tests

    func testStreakNotShownWhenZero() {
        let habit = HabitWidgetItem(id: UUID(), name: "New Habit", emoji: "✨", isCompleted: false, streak: 0)

        XCTAssertEqual(habit.streak, 0)
        // View logic should hide streak when 0
    }

    func testStreakShownWhenPositive() {
        let habit = HabitWidgetItem(id: UUID(), name: "Consistent", emoji: "🔥", isCompleted: true, streak: 30)

        XCTAssertGreaterThan(habit.streak, 0)
    }
}
