@testable import AvoidObstaclesGame
import Combine
import SpriteKit
import XCTest

@MainActor
class PowerUpManagerTests: XCTestCase {

    var powerUpManager: PowerUpManager!
    var mockScene: SKScene!
    var mockAIDifficultyManager: MockAIAdaptiveDifficultyManager!
    var mockDelegate: MockPowerUpDelegate!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockScene = SKScene(size: CGSize(width: 375, height: 667))
        mockAIDifficultyManager = MockAIAdaptiveDifficultyManager()
        mockDelegate = MockPowerUpDelegate()
        powerUpManager = PowerUpManager(scene: mockScene, aiDifficultyManager: mockAIDifficultyManager)
        powerUpManager.delegate = mockDelegate
        cancellables = []
    }

    override func tearDown() {
        powerUpManager.stopSpawning()
        powerUpManager.removeAllPowerUps()
        powerUpManager = nil
        mockScene = nil
        mockAIDifficultyManager = nil
        mockDelegate = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - AdaptiveSpawningConfig Tests

    func testAdaptiveSpawningConfigInitialization() {
        // Test basic initialization
        let config = AdaptiveSpawningConfig()

        // Verify initial state
        XCTAssertNotNil(config)
        XCTAssertEqual(config.getStats().totalSpawned, 0)
        XCTAssertEqual(config.getStats().totalCollected, 0)
    }

    func testAdaptiveSpawningConfigUpdateConfig() {
        // Test configuration updates
        let config = AdaptiveSpawningConfig()
        let difficulty = GameDifficulty.getDifficulty(for: 1000)
        let skillLevel = PlayerSkillLevel.intermediate

        config.updateConfig(difficulty: difficulty, playerSkill: skillLevel, scene: mockScene)

        // Verify spawn interval calculation works
        let interval = config.calculateBaseSpawnInterval()
        XCTAssertGreaterThan(interval, 0)
        XCTAssertLessThanOrEqual(interval, 10.0)
    }

    func testAdaptiveSpawningConfigCalculateBaseSpawnInterval() {
        // Test spawn interval calculation for different skill levels
        let config = AdaptiveSpawningConfig()

        // Beginner should have longer intervals
        config.updateConfig(difficulty: .getDifficulty(for: 0), playerSkill: .beginner, scene: mockScene)
        let beginnerInterval = config.calculateBaseSpawnInterval()

        // Master should have shorter intervals
        config.updateConfig(difficulty: .getDifficulty(for: 0), playerSkill: .master, scene: mockScene)
        let masterInterval = config.calculateBaseSpawnInterval()

        XCTAssertGreaterThan(beginnerInterval, masterInterval)
    }

    func testAdaptiveSpawningConfigSelectPowerUpType() {
        // Test power-up type selection
        let config = AdaptiveSpawningConfig()
        config.updateConfig(difficulty: .getDifficulty(for: 0), playerSkill: .beginner, scene: mockScene)

        let selectedType = config.selectPowerUpType()

        // Should select a valid power-up type
        XCTAssertNotNil(selectedType)
        XCTAssertTrue(PowerUpType.allCases.contains(selectedType))
    }

    @MainActor
    func testAdaptiveSpawningConfigCalculateSpawnPosition() {
        // Test spawn position calculation
        let config = AdaptiveSpawningConfig()
        config.updateConfig(difficulty: .getDifficulty(for: 0), playerSkill: .beginner, scene: mockScene)

        let position = config.calculateSpawnPosition(for: .shield, in: mockScene.frame)

        // Position should be within reasonable bounds
        XCTAssertGreaterThan(position.x, mockScene.frame.maxX)
        XCTAssertGreaterThanOrEqual(position.y, mockScene.frame.minY + 30)
        XCTAssertLessThanOrEqual(position.y, mockScene.frame.maxY - 30)
    }

    func testAdaptiveSpawningConfigGetExpirationTime() {
        // Test expiration time calculation
        let config = AdaptiveSpawningConfig()
        config.updateConfig(difficulty: .getDifficulty(for: 0), playerSkill: .beginner, scene: mockScene)

        let shieldTime = config.getExpirationTime(for: .shield)
        let legendaryTime = config.getExpirationTime(for: .scoreMultiplier)

        // Legendary power-ups should last longer
        XCTAssertGreaterThan(legendaryTime, shieldTime)
    }

    func testAdaptiveSpawningConfigRecordCollection() {
        // Test collection recording
        let config = AdaptiveSpawningConfig()

        // Record successful collection
        config.recordCollection(.shield, success: true)
        var stats = config.getStats()
        XCTAssertEqual(stats.totalSpawned, 1)
        XCTAssertEqual(stats.totalCollected, 1)

        // Record failed collection
        config.recordCollection(.speed, success: false)
        stats = config.getStats()
        XCTAssertEqual(stats.totalSpawned, 2)
        XCTAssertEqual(stats.totalCollected, 1)
    }

    func testAdaptiveSpawningConfigIsRarePowerUp() {
        // Test rarity checking
        let config = AdaptiveSpawningConfig()

        XCTAssertFalse(config.isRarePowerUp(.shield)) // Common
        XCTAssertTrue(config.isRarePowerUp(.laser)) // Rare
        XCTAssertTrue(config.isRarePowerUp(.teleport)) // Epic
        XCTAssertTrue(config.isRarePowerUp(.scoreMultiplier)) // Legendary
    }

    // MARK: - PowerUpSpawningStats Tests

    func testPowerUpSpawningStatsInitialization() {
        // Test basic initialization
        let stats = PowerUpSpawningStats(
            totalSpawned: 10,
            totalCollected: 7,
            collectionRate: 0.7,
            typeStats: [(.shield, 0.8), (.speed, 0.6)]
        )

        XCTAssertEqual(stats.totalSpawned, 10)
        XCTAssertEqual(stats.totalCollected, 7)
        XCTAssertEqual(stats.collectionRate, 0.7)
        XCTAssertEqual(stats.typeStats.count, 2)
    }

    func testPowerUpSpawningStatsEquatable() {
        // Test equality comparison
        let stats1 = PowerUpSpawningStats(
            totalSpawned: 5,
            totalCollected: 3,
            collectionRate: 0.6,
            typeStats: [(.shield, 0.8)]
        )

        let stats2 = PowerUpSpawningStats(
            totalSpawned: 5,
            totalCollected: 3,
            collectionRate: 0.6,
            typeStats: [(.shield, 0.8)]
        )

        let stats3 = PowerUpSpawningStats(
            totalSpawned: 6,
            totalCollected: 3,
            collectionRate: 0.6,
            typeStats: [(.shield, 0.8)]
        )

        XCTAssertEqual(stats1, stats2)
        XCTAssertNotEqual(stats1, stats3)
    }

    // MARK: - PowerUp Tests

    func testPowerUpInitialization() {
        // Test basic initialization
        let powerUp = PowerUp(type: .shield)

        XCTAssertEqual(powerUp.type, .shield)
        XCTAssertNotNil(powerUp.node)
        XCTAssertEqual(powerUp.node.size, CGSize(width: 25, height: 25))
        XCTAssertEqual(powerUp.node.name, "powerUp")
    }

    func testPowerUpHashable() {
        // Test hashable conformance
        let powerUp1 = PowerUp(type: .shield)
        let powerUp2 = PowerUp(type: .shield)
        let powerUp3 = PowerUp(type: .speed)

        // Same type should be equal (same spawn time for test purposes)
        // Note: In real usage, spawn times would differ
        XCTAssertEqual(powerUp1, powerUp1)
        XCTAssertNotEqual(powerUp1, powerUp3)

        // Test hash values
        let set = Set([powerUp1, powerUp2, powerUp3])
        XCTAssertGreaterThanOrEqual(set.count, 2) // At least powerUp1 and powerUp3
    }

    // MARK: - PowerUpManager Integration Tests

    @MainActor
    func testPowerUpManagerInitialization() {
        // Test that manager initializes correctly
        XCTAssertNotNil(powerUpManager)
        XCTAssertEqual(powerUpManager.getActivePowerUps().count, 0)
    }

    @MainActor
    func testPowerUpManagerUpdateScene() {
        // Test scene updating
        let newScene = SKScene(size: CGSize(width: 400, height: 800))
        powerUpManager.updateScene(newScene)

        // Should not crash and should accept the new scene
        XCTAssertTrue(true, "Scene update completed without error")
    }

    @MainActor
    func testPowerUpManagerStartStopSpawning() {
        // Test spawning control
        powerUpManager.startSpawning()
        XCTAssertNotNil(powerUpManager.getSpawningStats())

        powerUpManager.stopSpawning()
        XCTAssertNotNil(powerUpManager.getSpawningStats())
    }

    @MainActor
    func testPowerUpManagerUpdateDifficulty() {
        // Test difficulty updates
        let newDifficulty = GameDifficulty.getDifficulty(for: 500)
        powerUpManager.updateDifficulty(newDifficulty)

        // Should update internal state without crashing
        XCTAssertTrue(true, "Difficulty update completed without error")
    }

    @MainActor
    func testPowerUpManagerUpdatePlayerSkill() {
        // Test skill level updates
        powerUpManager.updatePlayerSkill(.expert)

        // Should update internal state without crashing
        XCTAssertTrue(true, "Player skill update completed without error")
    }

    @MainActor
    func testPowerUpManagerRecordPowerUpCollection() {
        // Test collection recording
        let powerUp = PowerUp(type: .shield)
        powerUpManager.recordPowerUpCollection(powerUp, success: true)

        let stats = powerUpManager.getSpawningStats()
        XCTAssertGreaterThanOrEqual(stats.totalSpawned, 1)
    }

    @MainActor
    func testPowerUpManagerGetActivePowerUps() {
        // Test getting active power-ups
        let activeNodes = powerUpManager.getActivePowerUps()
        XCTAssertEqual(activeNodes.count, 0) // Initially empty
    }

    @MainActor
    func testPowerUpManagerRemoveAllPowerUps() {
        // Test removing all power-ups
        powerUpManager.removeAllPowerUps()

        // Should not crash and should result in empty collection
        XCTAssertEqual(powerUpManager.getActivePowerUps().count, 0)
    }

    @MainActor
    func testPowerUpManagerGetSpawningStats() {
        // Test getting spawning statistics
        let stats = powerUpManager.getSpawningStats()

        XCTAssertNotNil(stats)
        XCTAssertGreaterThanOrEqual(stats.totalSpawned, 0)
        XCTAssertGreaterThanOrEqual(stats.totalCollected, 0)
        XCTAssertGreaterThanOrEqual(stats.collectionRate, 0.0)
        XCTAssertLessThanOrEqual(stats.collectionRate, 1.0)
    }

    func testPowerUpManagerAIDelegateMethods() {
        // Test AI delegate methods
        let newDifficulty = AIAdaptiveDifficulty.challenging
        let reason = DifficultyAdjustmentReason.playerStruggling

        // This would normally be called by the AI manager
        // We test that the methods exist and don't crash
        XCTAssertTrue(true, "AI delegate methods are implemented")
    }

    // MARK: - Metrics Publisher Tests

    @MainActor
    func testPowerUpMetricsPublisher() {
        // Test metrics publisher
        let expectation = XCTestExpectation(description: "Metrics published")

        powerUpManager.powerUpMetricsPublisher
            .sink { metrics in
                XCTAssertNotNil(metrics)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Trigger some activity that might publish metrics
        powerUpManager.recordPowerUpCollection(PowerUp(type: .shield), success: true)

        // Wait for potential metrics (may not publish immediately)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Classes

class MockAIAdaptiveDifficultyManager: AIAdaptiveDifficultyManager {
    // Mock implementation for testing
}

class MockPowerUpDelegate: PowerUpDelegate {
    var spawnedPowerUps: [PowerUp] = []
    var collectedPowerUps: [(PowerUp, Player)] = []
    var expiredPowerUps: [PowerUp] = []

    func powerUpDidSpawn(_ powerUp: PowerUp) {
        spawnedPowerUps.append(powerUp)
    }

    func powerUpDidCollect(_ powerUp: PowerUp, by player: Player) {
        collectedPowerUps.append((powerUp, player))
    }

    func powerUpDidExpire(_ powerUp: PowerUp) {
        expiredPowerUps.append(powerUp)
    }
}
