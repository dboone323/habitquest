//
// HabitViewModelTests.swift
// HabitQuestTests
//

@testable import HabitQuest
import SwiftData
import XCTest

@MainActor
final class HabitViewModelTests: XCTestCase {
    var viewModel: HabitViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        // Setup in-memory SwiftData
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(for: Habit.self, HabitLog.self, configurations: config)
            modelContext = ModelContext(modelContainer)
            viewModel = HabitViewModel()
            viewModel.setModelContext(modelContext)
        } catch {
            XCTFail("Failed to setup model container: \(error)")
        }
    }

    override func tearDown() {
        viewModel = nil
        modelContext = nil
        modelContainer = nil
    }

    @MainActor
    func testInitialState() {
        XCTAssertTrue(viewModel.state.habits.isEmpty)
        XCTAssertEqual(viewModel.state.searchText, "")
        XCTAssertNil(viewModel.state.selectedCategory)
    }

    @MainActor
    func testCreateHabit() {
        let name = "Test Habit"
        let description = "Test Description"

        viewModel.handle(.createHabit(
            name: name,
            description: description,
            frequency: .daily,
            category: .health,
            difficulty: .medium
        ))

        XCTAssertEqual(viewModel.state.habits.count, 1)
        let habit = viewModel.state.habits.first
        XCTAssertEqual(habit?.name, name)
        XCTAssertEqual(habit?.xpValue, 20) // base 10 * medium 2
        XCTAssertEqual(habit?.category, .health)
    }

    @MainActor
    func testCompleteHabit() {
        // Create habit
        viewModel.handle(.createHabit(
            name: "H1",
            description: "D1",
            frequency: .daily,
            category: .mindfulness,
            difficulty: .easy
        ))
        guard let habit = viewModel.state.habits.first else { XCTFail("Habit not created")
            return
        }

        // Complete it
        viewModel.handle(.completeHabit(habit))

        XCTAssertEqual(habit.streak, 1)
        XCTAssertTrue(habit.isCompletedToday)

        // Check logs
        XCTAssertEqual(habit.logs.count, 1)
        XCTAssertTrue(habit.logs.first?.isCompleted ?? false)
    }

    @MainActor
    func testCompleteHabit_Twice_Ignored() {
        viewModel.handle(.createHabit(
            name: "H1",
            description: "D1",
            frequency: .daily,
            category: .mindfulness,
            difficulty: .easy
        ))
        guard let habit = viewModel.state.habits.first else { return }

        viewModel.handle(.completeHabit(habit))
        viewModel.handle(.completeHabit(habit))

        XCTAssertEqual(habit.logs.count, 1, "Should only log completion once per day")
    }

    @MainActor
    func testDeleteHabit() {
        viewModel.handle(.createHabit(
            name: "Delete Me",
            description: "...",
            frequency: .daily,
            category: .health,
            difficulty: .easy
        ))
        guard let habit = viewModel.state.habits.first else { return }

        viewModel.handle(.deleteHabit(habit))

        // It uses soft delete (isActive = false) but FetchDescriptor predicate is { $0.isActive }
        // So it should disappear from state.habits
        XCTAssertTrue(viewModel.state.habits.isEmpty)
    }

    @MainActor
    func testFilterSearch() {
        viewModel.handle(.createHabit(
            name: "Read Book",
            description: "Read",
            frequency: .daily,
            category: .mindfulness,
            difficulty: .easy
        ))
        viewModel.handle(.createHabit(
            name: "Exercise",
            description: "Run",
            frequency: .daily,
            category: .health,
            difficulty: .hard
        ))

        // Search "Book"
        viewModel.handle(.setSearchText("Book"))
        XCTAssertEqual(viewModel.filteredHabits.count, 1)
        XCTAssertEqual(viewModel.filteredHabits.first?.name, "Read Book")

        // Search "Run"
        viewModel.handle(.setSearchText("Run"))
        XCTAssertEqual(viewModel.filteredHabits.count, 1)
        XCTAssertEqual(viewModel.filteredHabits.first?.name, "Exercise")

        // Clear search
        viewModel.handle(.setSearchText(""))
        XCTAssertEqual(viewModel.filteredHabits.count, 2)
    }

    @MainActor
    func testFilterCategory() {
        viewModel.handle(.createHabit(
            name: "H1",
            description: "D1",
            frequency: .daily,
            category: .mindfulness,
            difficulty: .easy
        )) // Mindfulness
        viewModel.handle(.createHabit(
            name: "H2",
            description: "D2",
            frequency: .daily,
            category: .health,
            difficulty: .easy
        )) // Health

        viewModel.handle(.setCategory(.mindfulness))
        XCTAssertEqual(viewModel.filteredHabits.count, 1)
        XCTAssertEqual(viewModel.filteredHabits.first?.name, "H1")

        viewModel.handle(.setCategory(nil))
        XCTAssertEqual(viewModel.filteredHabits.count, 2)
    }

    @MainActor
    func testTodaysHabits() {
        viewModel.handle(.createHabit(
            name: "Daily",
            description: "D",
            frequency: .daily,
            category: .health,
            difficulty: .easy
        ))

        // Not completed yet
        XCTAssertEqual(viewModel.todaysHabits.count, 1)

        // Complete it
        if let h = viewModel.state.habits.first {
            viewModel.handle(.completeHabit(h))
        }

        // Completed habits are filtered out of 'todaysHabits' (showing what is LEFT to do)
        // Code: todaysHabits ... filter { !habit.isCompletedToday }
        XCTAssertEqual(viewModel.todaysHabits.count, 0)
    }
}
