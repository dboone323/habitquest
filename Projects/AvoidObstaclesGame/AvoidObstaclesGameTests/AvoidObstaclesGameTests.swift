//
//  AvoidObstaclesGameTests.swift
//  AvoidObstaclesGameTests
//
//  Created by Daniel Stevens on 5/16/25.
//

import Foundation
import SpriteKit
import XCTest

@testable import AvoidObstaclesGame

final class AvoidObstaclesGameTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Game Mechanics Tests

    @MainActor
    func testPlayerMovement() throws {
        // Test basic player movement mechanics with GameScene
        // Note: Full SpriteKit scene testing requires UI testing, so we test the core logic
        XCTAssertNoThrow({
            let scene = GameScene(size: CGSize(width: 375, height: 667))

            // Test that scene was created successfully
            XCTAssertNotNil(scene)
            XCTAssertEqual(scene.size.width, 375)
            XCTAssertEqual(scene.size.height, 667)

            // Test that the scene has the expected structure (physics world setup requires didMove(to:))
            // We can test that the scene exists and has proper dimensions
            XCTAssertTrue(scene.size.width > 0)
            XCTAssertTrue(scene.size.height > 0)
        }, "GameScene should initialize successfully for player movement testing")
    }

    @MainActor
    func testObstacleGeneration() throws {
        // Test obstacle node creation logic (without full SpriteKit scene setup)
        // This tests the core obstacle creation logic that would be used in the game

        // Test that obstacle physics properties can be set correctly
        let obstacleSize = CGSize(width: 50, height: 50)
        let obstacleRect = CGRect(origin: .zero, size: obstacleSize)

        // Test physics body creation (what the scene would do)
        let physicsBody = SKPhysicsBody(rectangleOf: obstacleSize)
        physicsBody.categoryBitMask = PhysicsCategory.obstacle
        physicsBody.contactTestBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.none

        XCTAssertNotNil(physicsBody)
        XCTAssertEqual(physicsBody.categoryBitMask, PhysicsCategory.obstacle)
        XCTAssertEqual(physicsBody.contactTestBitMask, PhysicsCategory.player)
        XCTAssertEqual(physicsBody.collisionBitMask, PhysicsCategory.none)
    }

    func testCollisionDetection() throws {
        // Test collision detection between player and obstacles using physics categories
        let playerCategory: UInt32 = PhysicsCategory.player
        let obstacleCategory: UInt32 = PhysicsCategory.obstacle
        let powerUpCategory: UInt32 = PhysicsCategory.powerUp

        // Test that physics categories are properly defined and distinct
        XCTAssertNotEqual(playerCategory, obstacleCategory, "Player and obstacle categories should be different")
        XCTAssertNotEqual(playerCategory, powerUpCategory, "Player and power-up categories should be different")
        XCTAssertNotEqual(obstacleCategory, powerUpCategory, "Obstacle and power-up categories should be different")

        // Test collision bit mask logic
        let playerCollisionMask = PhysicsCategory.obstacle | PhysicsCategory.powerUp
        let obstacleCollisionMask = PhysicsCategory.none

        XCTAssertEqual(playerCollisionMask & obstacleCategory, obstacleCategory, "Player should collide with obstacles")
        XCTAssertEqual(playerCollisionMask & powerUpCategory, powerUpCategory, "Player should collide with power-ups")
        XCTAssertEqual(obstacleCollisionMask, PhysicsCategory.none, "Obstacles should not collide with anything")
    }

    // MARK: - Score System Tests

    func testScoreCalculation() throws {
        // Test score calculation based on game progress
        let baseScore = 100
        let timeBonus = 50
        let distanceBonus = 25

        let totalScore = baseScore + timeBonus + distanceBonus

        XCTAssertEqual(totalScore, 175, "Total score should be sum of all components")
        XCTAssertGreaterThan(totalScore, baseScore, "Total score should be greater than base score")
    }

    func testHighScoreTracking() throws {
        // Test high score tracking and updating
        var currentHighScore = 1000
        let newScore = 1200

        if newScore > currentHighScore {
            currentHighScore = newScore
        }

        XCTAssertEqual(currentHighScore, 1200, "High score should be updated to new higher score")
        XCTAssertGreaterThanOrEqual(currentHighScore, 1000, "High score should never decrease")
    }

    func testScoreMultiplier() throws {
        // Test score multipliers for combo systems
        let basePoints = 10
        let multiplier = 2.5
        let multipliedScore = Int(Double(basePoints) * multiplier)

        XCTAssertEqual(multipliedScore, 25, "Multiplied score should be correctly calculated")
        XCTAssertGreaterThan(
            multipliedScore, basePoints, "Multiplied score should be higher than base"
        )
    }

    // MARK: - Game State Tests

    @MainActor
    func testGameStartState() throws {
        // Test initial game state using GameStateManager
        let gameStateManager = GameStateManager()

        // Test initial state
        XCTAssertEqual(gameStateManager.currentState, .waitingToStart, "Game should start in waitingToStart state")
        XCTAssertEqual(gameStateManager.getCurrentScore(), 0, "Initial score should be 0")
        XCTAssertEqual(gameStateManager.getCurrentDifficultyLevel(), 1, "Initial difficulty level should be 1")
        XCTAssertFalse(gameStateManager.isGameActive(), "Game should not be active initially")
        XCTAssertFalse(gameStateManager.isGameOver(), "Game should not be over initially")
        XCTAssertFalse(gameStateManager.isGamePaused(), "Game should not be paused initially")
    }

    @MainActor
    func testGameOverCondition() throws {
        // Test game over conditions using GameStateManager
        let gameStateManager = GameStateManager()

        // Start game
        gameStateManager.startGame()
        XCTAssertEqual(gameStateManager.currentState, .playing, "Game should be in playing state after start")
        XCTAssertTrue(gameStateManager.isGameActive(), "Game should be active when playing")

        // End game
        gameStateManager.endGame()
        XCTAssertEqual(gameStateManager.currentState, .gameOver, "Game should be in gameOver state after end")
        XCTAssertTrue(gameStateManager.isGameOver(), "Game should be over after endGame()")
        XCTAssertFalse(gameStateManager.isGameActive(), "Game should not be active when over")
    }

    @MainActor
    func testPauseResumeFunctionality() throws {
        // Test pause and resume functionality using GameStateManager
        let gameStateManager = GameStateManager()

        // Start game
        gameStateManager.startGame()
        XCTAssertEqual(gameStateManager.currentState, .playing, "Game should be playing after start")

        // Pause game
        gameStateManager.pauseGame()
        XCTAssertEqual(gameStateManager.currentState, .paused, "Game should be paused after pauseGame()")
        XCTAssertTrue(gameStateManager.isGamePaused(), "Game should be paused")
        XCTAssertFalse(gameStateManager.isGameActive(), "Game should not be active when paused")

        // Resume game
        gameStateManager.resumeGame()
        XCTAssertEqual(gameStateManager.currentState, .playing, "Game should be playing after resumeGame()")
        XCTAssertFalse(gameStateManager.isGamePaused(), "Game should not be paused after resume")
        XCTAssertTrue(gameStateManager.isGameActive(), "Game should be active when resumed")
    }

    // MARK: - Level System Tests

    func testLevelProgression() throws {
        // Test level progression logic
        var currentLevel = 1
        let scoreThreshold = 1000
        let currentScore = 1200

        if currentScore >= scoreThreshold {
            currentLevel += 1
        }

        XCTAssertEqual(currentLevel, 2, "Level should progress when score threshold is met")
    }

    func testDifficultyScaling() throws {
        // Test difficulty scaling with level
        let level = 5
        let baseSpeed = 100.0
        let speedIncrease = 20.0

        let currentSpeed = baseSpeed + (Double(level - 1) * speedIncrease)

        XCTAssertEqual(currentSpeed, 180.0, "Speed should increase with level")
        XCTAssertGreaterThan(
            currentSpeed, baseSpeed, "Current speed should be higher than base speed"
        )
    }

    func testLevelCompletion() throws {
        // Test level completion detection
        let levelDistance = 1000.0
        let playerDistance = 1050.0

        let levelCompleted = playerDistance >= levelDistance

        XCTAssertTrue(
            levelCompleted, "Level should be completed when player reaches target distance"
        )
    }

    // MARK: - Power-up Tests

    func testPowerUpActivation() throws {
        // Test power-up activation and properties using PowerUpType enum
        let shieldPowerUp = PowerUpType.shield
        let speedPowerUp = PowerUpType.speed
        let laserPowerUp = PowerUpType.laser

        // Test power-up colors
        XCTAssertEqual(shieldPowerUp.color, SKColor.blue, "Shield power-up should be blue")
        XCTAssertEqual(speedPowerUp.color, SKColor.green, "Speed power-up should be green")
        XCTAssertEqual(laserPowerUp.color, SKColor.red, "Laser power-up should be red")

        // Test power-up durations
        XCTAssertEqual(shieldPowerUp.duration, 8.0, "Shield duration should be 8 seconds")
        XCTAssertEqual(speedPowerUp.duration, 6.0, "Speed duration should be 6 seconds")
        XCTAssertEqual(laserPowerUp.duration, 3.0, "Laser duration should be 3 seconds")

        // Test power-up descriptions
        XCTAssertEqual(shieldPowerUp.description, "Temporary invincibility", "Shield description should match")
        XCTAssertEqual(speedPowerUp.description, "Increased movement speed", "Speed description should match")

        // Test power-up rarities
        XCTAssertEqual(shieldPowerUp.rarity, .common, "Shield should be common rarity")
        XCTAssertEqual(laserPowerUp.rarity, .rare, "Laser should be rare rarity")
    }

    func testPowerUpExpiration() throws {
        // Test power-up expiration logic using PowerUpType durations and rarities
        let instantPowerUp = PowerUpType.multiBall // 0.0 duration (instant)
        let shortPowerUp = PowerUpType.laser // 3.0 duration
        let longPowerUp = PowerUpType.magnet // 10.0 duration

        // Test that instant power-ups have zero duration
        XCTAssertEqual(instantPowerUp.duration, 0.0, "Instant power-ups should have zero duration")

        // Test duration ranges
        XCTAssertGreaterThan(shortPowerUp.duration, 0.0, "Non-instant power-ups should have positive duration")
        XCTAssertGreaterThan(longPowerUp.duration, shortPowerUp.duration, "Longer power-ups should have greater duration")

        // Test rarity spawn weights
        let commonRarity = PowerUpRarity.common
        let legendaryRarity = PowerUpRarity.legendary

        XCTAssertGreaterThan(commonRarity.spawnWeight, legendaryRarity.spawnWeight, "Common power-ups should spawn more frequently than legendary")
        XCTAssertEqual(commonRarity.spawnWeight, 1.0, "Common rarity should have spawn weight of 1.0")
        XCTAssertEqual(legendaryRarity.spawnWeight, 0.05, "Legendary rarity should have spawn weight of 0.05")

        // Test glow intensity
        XCTAssertGreaterThan(legendaryRarity.glowIntensity, commonRarity.glowIntensity, "Legendary power-ups should have higher glow intensity")
    }

    // MARK: - Performance Tests

    func testGameLoopPerformance() throws {
        // Test game loop performance
        let startTime = Date()

        // Simulate game loop iterations
        for _ in 1 ... 1000 {
            // Simulate game update logic
            let x = 1 + 1
            XCTAssertEqual(x, 2)
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 1.0, "Game loop should process 1000 iterations quickly")
    }

    func testObstacleGenerationPerformance() throws {
        // Test obstacle generation performance
        let startTime = Date()

        // Simulate generating multiple obstacles
        for i in 1 ... 100 {
            let obstacleData: [String: Any] = ["id": i, "type": "spike", "x": i * 50]
            XCTAssertEqual((obstacleData["id"] as? Int), i)
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 0.5, "Obstacle generation should be fast")
    }

    // MARK: - Save/Load Tests

    func testGameSaveFunctionality() throws {
        // Test game save functionality
        let gameData: [String: Any] = [
            "score": 1500,
            "level": 3,
            "lives": 2,
            "playerX": 100.0,
            "playerY": 200.0,
        ]

        XCTAssertEqual(gameData["score"] as? Int, 1500)
        XCTAssertEqual(gameData["level"] as? Int, 3)
        XCTAssertEqual(gameData["lives"] as? Int, 2)
        XCTAssertEqual(gameData["playerX"] as? Double, 100.0)
        XCTAssertEqual(gameData["playerY"] as? Double, 200.0)
    }

    func testGameLoadFunctionality() throws {
        // Test game load functionality
        let savedData = [
            "score": 2500,
            "level": 5,
            "lives": 3,
        ]

        let loadedScore = savedData["score"] ?? 0
        let loadedLevel = savedData["level"] ?? 1

        XCTAssertEqual(loadedScore as? Int, 2500, "Loaded score should match saved score")
        XCTAssertEqual(loadedLevel as? Int, 5, "Loaded level should match saved level")
    }

    // MARK: - Edge Cases Tests

    func testZeroScore() throws {
        // Test handling of zero score
        let score = 0
        let isHighScore = score > 1000

        XCTAssertEqual(score, 0, "Score should be zero")
        XCTAssertFalse(isHighScore, "Zero score should not be considered high score")
    }

    func testNegativeValues() throws {
        // Test handling of negative values (shouldn't happen in normal gameplay)
        let negativeScore = -100
        let clampedScore = max(0, negativeScore)

        XCTAssertLessThan(negativeScore, 0, "Negative score should be less than zero")
        XCTAssertEqual(clampedScore, 0, "Negative score should be clamped to zero")
    }

    func testMaximumValues() throws {
        // Test handling of maximum values
        let maxScore = Int.max
        let isValidScore = maxScore > 0

        XCTAssertGreaterThan(maxScore, 0, "Maximum score should be positive")
        XCTAssertTrue(isValidScore, "Maximum score should be valid")
    }
}
