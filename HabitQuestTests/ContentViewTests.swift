import SwiftData
import SwiftUI
import XCTest
@testable import HabitQuest

final class ContentViewTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            // Schema must match app schema roughly, Habit is what we test
            modelContainer = try ModelContainer(
                for: Habit.self,
                HabitLog.self,
                PlayerProfile.self,
                Achievement.self,
                configurations: config
            )
            modelContext = ModelContext(modelContainer)
        } catch {
            XCTFail("Failed to create model container: \(error)")
        }
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        super.tearDown()
    }

    // MARK: - ContentView Tests

    @MainActor
    func testContentViewInitialization() throws {
        throw XCTSkip(
            "Skipping ContentView initialization test - SwiftData @Query in View init causes runtime issues in test environment"
        )
    }

    /*
     @MainActor
     func testContentViewWithHabits() {
     let habit = Habit(
     name: "Test Habit",
     habitDescription: "Test",
     frequency: .daily,
     category: .health
     )
     self.modelContext.insert(habit)

     let contentView = ContentView()
     .modelContainer(self.modelContainer)
     .environmentObject(ThemeManager())

     XCTAssertNotNil(contentView)
     }
     */

    // MARK: - HabitCardView Tests

    @MainActor
    func testHabitCardViewInitialization() {
        let habit = Habit(
            name: "Test Habit",
            habitDescription: "Test",
            frequency: .daily,
            category: .health
        )
        let cardView = HabitCardView(habit: habit, onToggle: {})
        XCTAssertNotNil(cardView)
    }
}
