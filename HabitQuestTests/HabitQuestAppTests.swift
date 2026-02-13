import SwiftData
import SwiftUI
import XCTest
@testable import HabitQuest

@MainActor
final class HabitQuestAppTests: XCTestCase {
    private var app: HabitQuestApp!

    override func setUpWithError() throws {
        app = HabitQuestApp()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testSharedModelContainerCreationSuccess() {
        XCTAssertNotNil(app.sharedModelContainer, "ModelContainer should not be nil")
    }

    func testSharedModelContainerCanPersistAndFetchHabit() throws {
        let container = try XCTUnwrap(app.sharedModelContainer)
        let context = ModelContext(container)

        let habit = Habit(
            name: "Integration Habit",
            habitDescription: "Created by app test",
            frequency: .daily
        )
        context.insert(habit)
        try context.save()

        let fetchedHabits = try context.fetch(FetchDescriptor<Habit>())
        XCTAssertTrue(fetchedHabits.contains { $0.id == habit.id })
    }

    func testBodySceneCanBeConstructed() {
        _ = app.body
    }
}
