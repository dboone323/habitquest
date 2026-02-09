@testable import HabitQuest
import XCTest

final class HabitQuestAppTests: XCTestCase {
    var app: HabitQuestApp!

    override func setUp() {
        super.setUp()
        app = HabitQuestApp()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testSharedModelContainerCreationSuccess() {
        // Arrange

        // Act
        let container = app.sharedModelContainer

        // Assert
        XCTAssertNotNil(container, "ModelContainer should not be nil")
    }

    func testSharedModelContainerCreationFailure() {
        // Arrange
        let originalSchema = Schema([
            Habit.self,
            HabitLog.self,
            PlayerProfile.self,
            Achievement.self
        ])

        let fallbackConfig = ModelConfiguration(schema: originalSchema, isStoredInMemoryOnly: true)

        do {
            let fallbackContainer = try ModelContainer(for: originalSchema, configurations: [fallbackConfig])

            // Act
            app.sharedModelContainer = fallbackContainer

            // Assert
            XCTAssertNotNil(app.sharedModelContainer, "Fallback ModelContainer should not be nil")
        } catch {
            XCTFail("Failed to create fallback ModelContainer: \(error)")
        }
    }

    func testDatabaseErrorHandling() {
        // Arrange
        app.showDatabaseError = true

        // Act
        let view = app.body as! WindowGroup.View

        // Assert
        XCTAssertTrue(view.contains(where: { $0 is VStack }), "View should contain a VStack")

        if let errorView = view.first(where: { $0 is VStack }) as? VStack {
            XCTAssertTrue(errorView.contains(where: { $0 is Image }), "ErrorView should contain an Image")
            XCTAssertTrue(errorView.contains(where: { $0 is Text }), "ErrorView should contain two Text elements")
            XCTAssertTrue(errorView.contains(where: { $0 is Button }), "ErrorView should contain two Buttons")
        } else {
            XCTFail("VStack not found in the view hierarchy")
        }
    }
}
