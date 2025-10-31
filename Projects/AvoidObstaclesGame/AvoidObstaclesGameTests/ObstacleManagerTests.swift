@testable import AvoidObstaclesGame
import SpriteKit
import XCTest

class ObstacleManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here
    }

    override func tearDown() {
        // Put teardown code here
        super.tearDown()
    }

    // MARK: - ObstacleType Tests

    func testObstacleTypeInitialization() {
        // Test all cases can be initialized
        XCTAssertEqual(ObstacleType.normal, ObstacleType.normal)
        XCTAssertEqual(ObstacleType.fast, ObstacleType.fast)
        XCTAssertEqual(ObstacleType.large, ObstacleType.large)
        XCTAssertEqual(ObstacleType.small, ObstacleType.small)
    }

    func testObstacleTypeConfiguration() {
        // Test normal type configuration
        let normalConfig = ObstacleType.normal.configuration
        XCTAssertEqual(normalConfig.size, CGSize(width: 30, height: 30))
        XCTAssertEqual(normalConfig.color, .systemRed)
        XCTAssertEqual(normalConfig.fallSpeed, 3.5)
        XCTAssertFalse(normalConfig.canRotate)
        XCTAssertFalse(normalConfig.hasGlow)

        // Test fast type configuration
        let fastConfig = ObstacleType.fast.configuration
        XCTAssertEqual(fastConfig.size, CGSize(width: 25, height: 25))
        XCTAssertEqual(fastConfig.color, .systemOrange)
        XCTAssertEqual(fastConfig.fallSpeed, 4.5)
        XCTAssertTrue(fastConfig.canRotate)
        XCTAssertTrue(fastConfig.hasGlow)

        // Test large type configuration
        let largeConfig = ObstacleType.large.configuration
        XCTAssertEqual(largeConfig.size, CGSize(width: 45, height: 45))
        XCTAssertEqual(largeConfig.color, .systemPurple)
        XCTAssertEqual(largeConfig.fallSpeed, 2.8)
        XCTAssertFalse(largeConfig.canRotate)
        XCTAssertFalse(largeConfig.hasGlow)

        // Test small type configuration
        let smallConfig = ObstacleType.small.configuration
        XCTAssertEqual(smallConfig.size, CGSize(width: 20, height: 20))
        XCTAssertEqual(smallConfig.color, .systemPink)
        XCTAssertEqual(smallConfig.fallSpeed, 5.0)
        XCTAssertTrue(smallConfig.canRotate)
        XCTAssertTrue(smallConfig.hasGlow)
    }

    // MARK: - ObstacleConfiguration Tests

    func testObstacleConfigurationInitialization() {
        let config = ObstacleConfiguration(
            size: CGSize(width: 40, height: 40),
            color: .blue,
            borderColor: .white,
            fallSpeed: 3.0,
            canRotate: true,
            hasGlow: false
        )

        XCTAssertEqual(config.size, CGSize(width: 40, height: 40))
        XCTAssertEqual(config.color, .blue)
        XCTAssertEqual(config.borderColor, .white)
        XCTAssertEqual(config.fallSpeed, 3.0)
        XCTAssertTrue(config.canRotate)
        XCTAssertFalse(config.hasGlow)
    }

    func testObstacleConfigurationProperties() {
        let config = ObstacleConfiguration(
            size: CGSize(width: 50, height: 60),
            color: .red,
            borderColor: .black,
            fallSpeed: 4.0,
            canRotate: false,
            hasGlow: true
        )

        XCTAssertEqual(config.size.width, 50)
        XCTAssertEqual(config.size.height, 60)
        XCTAssertEqual(config.color, .red)
        XCTAssertEqual(config.borderColor, .black)
        XCTAssertEqual(config.fallSpeed, 4.0)
        XCTAssertFalse(config.canRotate)
        XCTAssertTrue(config.hasGlow)
    }

    // MARK: - ObstaclePatternType Tests

    func testObstaclePatternTypeInitialization() {
        // Test all cases can be initialized
        XCTAssertEqual(ObstaclePatternType.single, ObstaclePatternType.single)
        XCTAssertEqual(ObstaclePatternType.cluster, ObstaclePatternType.cluster)
        XCTAssertEqual(ObstaclePatternType.wave, ObstaclePatternType.wave)
        XCTAssertEqual(ObstaclePatternType.pattern, ObstaclePatternType.pattern)
    }

    func testObstaclePatternTypeAllCases() {
        // Test CaseIterable conformance
        let allCases = ObstaclePatternType.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.single))
        XCTAssertTrue(allCases.contains(.cluster))
        XCTAssertTrue(allCases.contains(.wave))
        XCTAssertTrue(allCases.contains(.pattern))
    }

    // MARK: - ObstacleGenerationPattern Tests

    func testObstacleGenerationPatternInitialization() {
        let pattern = ObstacleGenerationPattern(
            type: .single,
            obstacleType: .block,
            patternType: nil,
            speedMultiplier: 1.5,
            sizeMultiplier: 1.2,
            shouldRotate: true,
            colorVariation: .green,
            clusterSize: nil,
            clusterSpacing: nil,
            waveSize: nil,
            waveDelay: nil
        )

        XCTAssertEqual(pattern.type, .single)
        XCTAssertEqual(pattern.obstacleType, .block)
        XCTAssertNil(pattern.patternType)
        XCTAssertEqual(pattern.speedMultiplier, 1.5)
        XCTAssertEqual(pattern.sizeMultiplier, 1.2)
        XCTAssertTrue(pattern.shouldRotate)
        XCTAssertEqual(pattern.colorVariation, .green)
        XCTAssertNil(pattern.clusterSize)
        XCTAssertNil(pattern.clusterSpacing)
        XCTAssertNil(pattern.waveSize)
        XCTAssertNil(pattern.waveDelay)
    }

    func testObstacleGenerationPatternDefaultInitialization() {
        let pattern = ObstacleGenerationPattern(type: .cluster)

        XCTAssertEqual(pattern.type, .cluster)
        XCTAssertNil(pattern.obstacleType)
        XCTAssertNil(pattern.patternType)
        XCTAssertNil(pattern.speedMultiplier)
        XCTAssertNil(pattern.sizeMultiplier)
        XCTAssertFalse(pattern.shouldRotate)
        XCTAssertNil(pattern.colorVariation)
        XCTAssertNil(pattern.clusterSize)
        XCTAssertNil(pattern.clusterSpacing)
        XCTAssertNil(pattern.waveSize)
        XCTAssertNil(pattern.waveDelay)
    }

    func testObstacleGenerationPatternProperties() {
        let pattern = ObstacleGenerationPattern(
            type: .wave,
            obstacleType: .spike,
            patternType: .cluster,
            speedMultiplier: 2.0,
            sizeMultiplier: 0.8,
            shouldRotate: false,
            colorVariation: nil,
            clusterSize: 5,
            clusterSpacing: 30.0,
            waveSize: 8,
            waveDelay: 0.25
        )

        XCTAssertEqual(pattern.type, .wave)
        XCTAssertEqual(pattern.obstacleType, .spike)
        XCTAssertEqual(pattern.patternType, .cluster)
        XCTAssertEqual(pattern.speedMultiplier, 2.0)
        XCTAssertEqual(pattern.sizeMultiplier, 0.8)
        XCTAssertFalse(pattern.shouldRotate)
        XCTAssertNil(pattern.colorVariation)
        XCTAssertEqual(pattern.clusterSize, 5)
        XCTAssertEqual(pattern.clusterSpacing, 30.0)
        XCTAssertEqual(pattern.waveSize, 8)
        XCTAssertEqual(pattern.waveDelay, 0.25)
    }

    // MARK: - DynamicObstacleGenerator Tests

    func testDynamicObstacleGeneratorInitialization() {
        let generator = DynamicObstacleGenerator()
        XCTAssertNotNil(generator)
    }

    func testDynamicObstacleGeneratorUpdateDifficulty() {
        let generator = DynamicObstacleGenerator()
        let difficulty = GameDifficulty.getDifficulty(for: 1000) // Higher score

        generator.updateDifficulty(difficulty)

        // Generate a pattern to ensure difficulty is applied
        let pattern = generator.generateObstaclePattern()
        XCTAssertNotNil(pattern)
        XCTAssertTrue(ObstaclePatternType.allCases.contains(pattern.type))
    }

    func testDynamicObstacleGeneratorGenerateObstaclePattern() {
        let generator = DynamicObstacleGenerator()

        let pattern = generator.generateObstaclePattern()

        XCTAssertNotNil(pattern)
        XCTAssertTrue(ObstaclePatternType.allCases.contains(pattern.type))
    }

    @MainActor
    func testDynamicObstacleGeneratorPositionCalculations() {
        let generator = DynamicObstacleGenerator()
        let scene = SKScene(size: CGSize(width: 400, height: 600))
        let obstacle = Obstacle(type: .block)
        let frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        let pattern = ObstacleGenerationPattern(type: .single)

        let position = generator.calculateDynamicPosition(for: obstacle, in: frame, pattern: pattern)

        // Position should be within reasonable bounds
        XCTAssertGreaterThanOrEqual(position.x, frame.maxX)
        XCTAssertGreaterThanOrEqual(position.y, frame.minY - obstacle.node.frame.height)
        XCTAssertLessThanOrEqual(position.y, frame.maxY + obstacle.node.frame.height)
    }

    func testDynamicObstacleGeneratorClusterPositionCalculations() {
        let generator = DynamicObstacleGenerator()
        let frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        let pattern = ObstacleGenerationPattern(type: .cluster, clusterSize: 3, clusterSpacing: 50)

        let basePosition = generator.calculateClusterBasePosition(in: frame, pattern: pattern)
        XCTAssertGreaterThanOrEqual(basePosition.x, frame.maxX + 50)
        XCTAssertGreaterThanOrEqual(basePosition.y, frame.minY + 30)
        XCTAssertLessThanOrEqual(basePosition.y, frame.maxY - 30)

        let clusterPosition = generator.calculateClusterPosition(
            basePosition: basePosition,
            index: 1,
            total: 3,
            pattern: pattern
        )
        XCTAssertEqual(clusterPosition.x, basePosition.x + 50) // spacing * index
    }

    func testDynamicObstacleGeneratorWavePositionCalculations() {
        let generator = DynamicObstacleGenerator()
        let frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        let pattern = ObstacleGenerationPattern(type: .wave, waveSize: 5)

        let position = generator.calculateWavePosition(
            index: 2,
            total: 5,
            in: frame,
            pattern: pattern
        )

        XCTAssertGreaterThanOrEqual(position.x, frame.maxX + 30)
        XCTAssertGreaterThanOrEqual(position.y, frame.minY + 20)
        XCTAssertLessThanOrEqual(position.y, frame.maxY - 20)
    }

    func testDynamicObstacleGeneratorPatternPositions() {
        let generator = DynamicObstacleGenerator()
        let frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        let pattern = ObstacleGenerationPattern(type: .pattern)

        let positions = generator.calculatePatternPositions(type: .single, in: frame, pattern: pattern)

        XCTAssertEqual(positions.count, 4) // Current implementation returns 4 positions
        for position in positions {
            XCTAssertGreaterThanOrEqual(position.x, frame.maxX + 50)
        }
    }

    // MARK: - ObstacleMetrics Tests

    func testObstacleMetricsInitialization() {
        let metrics = ObstacleMetrics(spawnRate: 2.5, dynamicPatternUsage: 0.75)

        XCTAssertEqual(metrics.spawnRate, 2.5)
        XCTAssertEqual(metrics.dynamicPatternUsage, 0.75)
    }

    func testObstacleMetricsProperties() {
        let metrics = ObstacleMetrics(spawnRate: 1.0, dynamicPatternUsage: 0.3)

        XCTAssertEqual(metrics.spawnRate, 1.0)
        XCTAssertEqual(metrics.dynamicPatternUsage, 0.3)
    }

    // MARK: - Obstacle Tests

    @MainActor
    func testObstacleInitialization() {
        let obstacle = Obstacle(type: .block)

        XCTAssertNotNil(obstacle.node)
        XCTAssertEqual(obstacle.obstacleType, .block)
        XCTAssertTrue(obstacle.isVisible)
        XCTAssertNotNil(obstacle.physicsBody)
    }

    func testObstacleTypeEnumValues() {
        // Test all obstacle types
        XCTAssertEqual(Obstacle.ObstacleType.spike.color, .red)
        XCTAssertEqual(Obstacle.ObstacleType.block.color, .orange)
        XCTAssertEqual(Obstacle.ObstacleType.moving.color, .purple)
        XCTAssertEqual(Obstacle.ObstacleType.pulsing.color, .green)
        XCTAssertEqual(Obstacle.ObstacleType.rotating.color, .blue)
        XCTAssertEqual(Obstacle.ObstacleType.bouncing.color, .yellow)
        XCTAssertEqual(Obstacle.ObstacleType.teleporting.color, .cyan)
        XCTAssertEqual(Obstacle.ObstacleType.splitting.color, .magenta)
        XCTAssertEqual(Obstacle.ObstacleType.laser.color, .white)
    }

    func testObstacleTypeColors() {
        XCTAssertEqual(Obstacle.ObstacleType.spike.color, .red)
        XCTAssertEqual(Obstacle.ObstacleType.block.color, .orange)
        XCTAssertEqual(Obstacle.ObstacleType.laser.color, .white)
    }

    @MainActor
    func testObstacleUpdate() {
        let obstacle = Obstacle(type: .moving)
        let initialPosition = obstacle.position

        // Update should move the obstacle
        obstacle.update(deltaTime: 1.0)

        // Position should have changed for moving obstacles
        XCTAssertNotEqual(obstacle.position.x, initialPosition.x)
    }

    @MainActor
    func testObstacleReset() {
        let obstacle = Obstacle(type: .pulsing)
        obstacle.isVisible = false

        obstacle.reset()

        XCTAssertTrue(obstacle.isVisible)
        // Node actions should be cleared (can't easily test without accessing private properties)
    }

    @MainActor
    func testObstacleSetSpeed() {
        let obstacle = Obstacle(type: .block)
        let newSpeed: CGFloat = 200.0

        obstacle.setSpeed(newSpeed)

        // Speed is private, but we can verify it affects movement
        let initialX = obstacle.position.x
        obstacle.update(deltaTime: 1.0)
        XCTAssertNotEqual(obstacle.position.x, initialX)
    }
}
