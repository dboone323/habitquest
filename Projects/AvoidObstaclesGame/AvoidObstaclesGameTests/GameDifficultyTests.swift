import XCTest

@testable import AvoidObstaclesGame

final class GameDifficultyTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here
    }

    override func tearDown() {
        // Put teardown code here
        super.tearDown()
    }

    // MARK: - GameDifficulty Tests

    func testGameDifficultyInitialization() {
        // Test basic initialization with parameters
        let difficulty = GameDifficulty(
            spawnInterval: 1.0, obstacleSpeed: 3.0, scoreMultiplier: 1.5, powerUpSpawnChance: 0.1
        )
        XCTAssertNotNil(difficulty, "GameDifficulty should initialize properly")
        XCTAssertEqual(
            difficulty.spawnInterval, 1.0, "GameDifficulty should have correct spawn interval"
        )
        XCTAssertEqual(
            difficulty.obstacleSpeed, 3.0, "GameDifficulty should have correct obstacle speed"
        )
        XCTAssertEqual(
            difficulty.scoreMultiplier, 1.5, "GameDifficulty should have correct score multiplier"
        )
        XCTAssertEqual(
            difficulty.powerUpSpawnChance, 0.1, "GameDifficulty should have correct power-up spawn chance"
        )
    }

    func testGameDifficultyProperties() {
        // Test property access and validation
        let difficulty = GameDifficulty(
            spawnInterval: 0.8, obstacleSpeed: 2.5, scoreMultiplier: 2.0, powerUpSpawnChance: 0.15
        )
        XCTAssertEqual(
            difficulty.spawnInterval, 0.8, "GameDifficulty should have correct spawn interval"
        )
        XCTAssertEqual(
            difficulty.obstacleSpeed, 2.5, "GameDifficulty should have correct obstacle speed"
        )
        XCTAssertEqual(
            difficulty.scoreMultiplier, 2.0, "GameDifficulty should have correct score multiplier"
        )
        XCTAssertEqual(
            difficulty.powerUpSpawnChance, 0.15, "GameDifficulty should have correct power-up spawn chance"
        )
    }

    func testGameDifficultyMethods() {
        // Test static method functionality
        let easyDifficulty = GameDifficulty.getDifficulty(for: 5)
        _ = GameDifficulty.getDifficulty(for: 20)
        let hardDifficulty = GameDifficulty.getDifficulty(for: 75)

        XCTAssertGreaterThan(
            easyDifficulty.spawnInterval, hardDifficulty.spawnInterval,
            "Easy should have slower spawn than hard"
        )
        XCTAssertGreaterThan(
            easyDifficulty.obstacleSpeed, hardDifficulty.obstacleSpeed,
            "Easy should have slower obstacles than hard"
        )
        XCTAssertLessThan(
            easyDifficulty.scoreMultiplier, hardDifficulty.scoreMultiplier,
            "Easy should have lower multiplier than hard"
        )
    }

    func testGameDifficultyStaticMethods() {
        // Test static method functionality
        let level1 = GameDifficulty.getDifficultyLevel(for: 5)
        let level2 = GameDifficulty.getDifficultyLevel(for: 15)
        let level3 = GameDifficulty.getDifficultyLevel(for: 35)
        let level4 = GameDifficulty.getDifficultyLevel(for: 75)
        let level5 = GameDifficulty.getDifficultyLevel(for: 150)
        let level6 = GameDifficulty.getDifficultyLevel(for: 250)

        XCTAssertEqual(level1, 1, "Score 5 should be level 1")
        XCTAssertEqual(level2, 2, "Score 15 should be level 2")
        XCTAssertEqual(level3, 3, "Score 35 should be level 3")
        XCTAssertEqual(level4, 4, "Score 75 should be level 4")
        XCTAssertEqual(level5, 5, "Score 150 should be level 5")
        XCTAssertEqual(level6, 6, "Score 250 should be level 6")
    }

    func testGameDifficultyProgression() {
        // Test that difficulty increases with score
        let lowScore = GameDifficulty.getDifficulty(for: 0)
        let highScore = GameDifficulty.getDifficulty(for: 1000)

        XCTAssertGreaterThan(
            lowScore.spawnInterval, highScore.spawnInterval,
            "Higher scores should have faster spawn rates"
        )
        XCTAssertGreaterThan(
            lowScore.obstacleSpeed, highScore.obstacleSpeed,
            "Higher scores should have faster obstacles"
        )
        XCTAssertLessThan(
            lowScore.scoreMultiplier, highScore.scoreMultiplier,
            "Higher scores should have higher multipliers"
        )
    }
}
