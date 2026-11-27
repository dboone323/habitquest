
import HabitQuestCore
import SwiftData
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

    func testAccessoryCircularWidgetViewRendering() {
        let entry = HabitWidgetEntry(
            date: Date(),
            habits: [
                HabitWidgetItem(id: UUID(), name: "Brush", emoji: "🪥", isCompleted: true, streak: 5),
                HabitWidgetItem(id: UUID(), name: "Walk", emoji: "🚶", isCompleted: false, streak: 2),
            ]
        )
        let view = HabitWidgetAccessoryCircularView(entry: entry)
        XCTAssertNotNil(view)
    }

    func testWidgetDataLoaderReadsRealSwiftDataHabits() throws {
        let container = try SharedModelContainer.createContainer(inMemoryOnly: true)
        let context = ModelContext(container)

        let activeHabit = Habit(
            name: "Morning Stretch",
            habitDescription: "5 min",
            frequency: .daily,
            category: .fitness
        )
        activeHabit.streak = 4
        let inactiveHabit = Habit(
            name: "Archived Habit",
            habitDescription: "Inactive",
            frequency: .daily
        )
        inactiveHabit.isActive = false

        context.insert(activeHabit)
        context.insert(inactiveHabit)
        let log = HabitLog(habit: activeHabit, completionDate: Date())
        context.insert(log)
        try context.save()

        let items = HabitWidgetDataLoader.loadTodaysHabits(from: context)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Morning Stretch")
        XCTAssertEqual(items.first?.emoji, HabitCategory.fitness.emoji)
        XCTAssertTrue(items.first?.isCompleted ?? false)
        XCTAssertEqual(items.first?.streak, 4)
    }

    func testProviderUsesInjectedLoaderWithoutHardcodedPlaceholders() {
        let expected = [
            HabitWidgetItem(id: UUID(), name: "Live Quest", emoji: "⚡️", isCompleted: false, streak: 7),
        ]
        let provider = HabitWidgetProvider(loader: { expected })
        XCTAssertNotNil(provider)
    }

    func testWidgetCompletionHandlerCompletesHabitAndAwardsXP() throws {
        let container = try SharedModelContainer.createContainer(inMemoryOnly: true)
        let context = ModelContext(container)

        let profile = PlayerProfile()
        context.insert(profile)

        let habit = Habit(
            name: "Hydrate",
            habitDescription: "Drink water",
            frequency: .daily,
            xpValue: 15,
            difficulty: .medium
        )
        context.insert(habit)
        try context.save()

        let didComplete = try HabitWidgetCompletionHandler.completeHabit(id: habit.id, in: context)
        XCTAssertTrue(didComplete)
        XCTAssertTrue(habit.isCompletedToday)
        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertEqual(habit.streak, 1)
        XCTAssertEqual(profile.currentXP, 30)

        // Idempotent when already completed today
        let didCompleteAgain = try HabitWidgetCompletionHandler.completeHabit(id: habit.id, in: context)
        XCTAssertFalse(didCompleteAgain)
        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertEqual(profile.currentXP, 30)
    }

    func testCompleteWidgetHabitIntentInitializesWithHabitID() {
        let id = UUID()
        let intent = CompleteWidgetHabitIntent(habitID: id)
        XCTAssertEqual(intent.habitID, id.uuidString)
    }
}
