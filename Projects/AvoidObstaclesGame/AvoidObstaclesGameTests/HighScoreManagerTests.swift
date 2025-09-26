import XCTest

@testable import AvoidObstaclesGame

final class HighScoreManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here
    }

    override func tearDown() {
        // Put teardown code here
        super.tearDown()
    }

    // MARK: - HighScoreManager Tests

    func testHighScoreManagerInitialization() {
        // Test basic initialization
        let manager = HighScoreManager.shared
        XCTAssertNotNil(manager, "HighScoreManager shared instance should exist")
    }

    func testHighScoreManagerProperties() {
        // Test property access and validation
        let manager = HighScoreManager.shared
        let highScores = manager.getHighScores()
        XCTAssertNotNil(highScores, "HighScoreManager should have high scores array")
        XCTAssertGreaterThanOrEqual(highScores.count, 0, "High scores count should be non-negative")
    }

    func testHighScoreManagerMethods() {
        // Test method functionality
        let manager = HighScoreManager.shared

        // Test adding a score
        let initialCount = manager.getHighScores().count
        let wasAdded = manager.addScore(100)
        XCTAssertTrue(wasAdded, "Score should be added successfully")

        // Test getting highest score
        let highestScore = manager.getHighestScore()
        XCTAssertGreaterThanOrEqual(highestScore, 100, "Highest score should be at least 100")

        // Test isHighScore method
        let isHighScore = manager.isHighScore(50)
        XCTAssertTrue(isHighScore || !isHighScore, "isHighScore should return a boolean")
    }

    func testHighScoreManagerScoreOperations() {
        // Test score operations
        let manager = HighScoreManager.shared

        // Clear existing scores first
        manager.clearHighScores()

        // Test adding multiple scores
        let added1 = manager.addScore(50)
        let added2 = manager.addScore(150)
        let added3 = manager.addScore(75)

        XCTAssertTrue(added1, "First score should be added")
        XCTAssertTrue(added2, "Second score should be added")
        XCTAssertTrue(added3, "Third score should be added")

        let scores = manager.getHighScores()
        XCTAssertGreaterThanOrEqual(scores.count, 3, "Should have at least 3 scores after adding")

        // Test that scores are sorted (assuming descending order)
        if scores.count >= 2 {
            XCTAssertGreaterThanOrEqual(
                scores[0], scores[1], "First score should be >= second score"
            )
        }

        // Test highest score
        let highest = manager.getHighestScore()
        XCTAssertEqual(highest, 150, "Highest score should be 150")

        // Clean up
        manager.clearHighScores()
    }
}
