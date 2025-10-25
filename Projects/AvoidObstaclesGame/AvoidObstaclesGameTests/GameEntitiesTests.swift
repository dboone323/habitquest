import XCTest
@testable import AvoidObstaclesGame

class GameEntitiesTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here
    }

    override func tearDown() {
        // Put teardown code here
        super.tearDown()
    }

    // MARK: - GameAction Enum Tests

    func testGameActionEnum() {
        // Test that GameAction enum exists and has expected cases
        XCTAssertNotNil(GameAction.jump)
        XCTAssertNotNil(GameAction.pause)
        XCTAssertNotNil(GameAction.menu)
    }

    // MARK: - Player Class Tests

    @MainActor
    func testPlayerInitialization() {
        let player = Player()

        XCTAssertNotNil(player.node)
        XCTAssertTrue(player.isVisible)
        XCTAssertNotNil(player.physicsBody)
        XCTAssertEqual(player.node.position, CGPoint(x: 100, y: 200))
    }

    @MainActor
    func testPlayerProperties() {
        let player = Player()

        // Test initial position
        XCTAssertEqual(player.position, CGPoint(x: 100, y: 200))

        // Test position setter
        player.position = CGPoint(x: 150, y: 250)
        XCTAssertEqual(player.position, CGPoint(x: 150, y: 250))
    }

    @MainActor
    func testPlayerMovement() {
        let player = Player()
        let initialPosition = player.position

        // Test movement
        let direction = CGVector(dx: 1, dy: 0) // Move right
        player.move(direction: direction, deltaTime: 1.0)

        XCTAssertGreaterThan(player.position.x, initialPosition.x)
        XCTAssertEqual(player.position.y, initialPosition.y)
    }

    @MainActor
    func testPlayerScreenBounds() {
        let player = Player()
        let screenSize = CGSize(width: 400, height: 600)

        // Test constraining to screen bounds
        player.position = CGPoint(x: -50, y: 300)
        player.constrainToScreenBounds(screenSize: screenSize)

        XCTAssertGreaterThanOrEqual(player.position.x, player.node.frame.width / 2)
        XCTAssertEqual(player.position.y, 300)

        player.position = CGPoint(x: 500, y: 300)
        player.constrainToScreenBounds(screenSize: screenSize)

        XCTAssertLessThanOrEqual(player.position.x, screenSize.width - player.node.frame.width / 2)
    }

    @MainActor
    func testPlayerReset() {
        let player = Player()

        // Change position and visibility
        player.position = CGPoint(x: 300, y: 400)
        player.isVisible = false

        player.reset()

        XCTAssertEqual(player.position, CGPoint(x: 100, y: 200))
        XCTAssertTrue(player.isVisible)
    }

    @MainActor
    func testPlayerSpeed() {
        let player = Player()

        // Test speed change
        player.setSpeed(300.0)

        let initialPosition = player.position
        let direction = CGVector(dx: 1, dy: 0)
        player.move(direction: direction, deltaTime: 1.0)

        // With speed 300, should move 300 units
        XCTAssertEqual(player.position.x, initialPosition.x + 300)
    }

    // MARK: - Obstacle Class Tests

    @MainActor
    func testObstacleInitialization() {
        let obstacle = Obstacle(type: .block)

        XCTAssertNotNil(obstacle.node)
        XCTAssertTrue(obstacle.isVisible)
        XCTAssertNotNil(obstacle.physicsBody)
        XCTAssertEqual(obstacle.obstacleType, .block)
    }

    @MainActor
    func testObstacleTypes() {
        // Test different obstacle types
        let spikeObstacle = Obstacle(type: .spike)
        XCTAssertEqual(spikeObstacle.obstacleType, .spike)

        let laserObstacle = Obstacle(type: .laser)
        XCTAssertEqual(laserObstacle.obstacleType, .laser)
    }

    @MainActor
    func testObstacleProperties() {
        let obstacle = Obstacle(type: .block)

        // Test position
        XCTAssertEqual(obstacle.position, CGPoint.zero)

        obstacle.position = CGPoint(x: 200, y: 300)
        XCTAssertEqual(obstacle.position, CGPoint(x: 200, y: 300))
    }

    @MainActor
    func testObstacleUpdate() {
        let obstacle = Obstacle(type: .block)
        let initialPosition = obstacle.position

        obstacle.update(deltaTime: 1.0)

        // Obstacle should move left
        XCTAssertLessThan(obstacle.position.x, initialPosition.x)
    }

    @MainActor
    func testObstacleReset() {
        let obstacle = Obstacle(type: .pulsing)

        obstacle.isVisible = false
        obstacle.reset()

        XCTAssertTrue(obstacle.isVisible)
    }

    @MainActor
    func testObstacleSpeed() {
        let obstacle = Obstacle(type: .block)

        obstacle.setSpeed(150.0)

        let initialPosition = obstacle.position
        obstacle.update(deltaTime: 1.0)

        // Should move 150 units left
        XCTAssertEqual(obstacle.position.x, initialPosition.x - 150)
    }

    @MainActor
    func testObstacleHashable() {
        let obstacle1 = Obstacle(type: .block)
        let obstacle2 = Obstacle(type: .block)
        let obstacle3 = obstacle1

        // Different instances should not be equal
        XCTAssertNotEqual(obstacle1, obstacle2)
        // Same instance should be equal
        XCTAssertEqual(obstacle1, obstacle3)
    }

    // MARK: - Boss Class Tests

    @MainActor
    func testBossInitialization() {
        let boss = Boss(type: .guardian)

        XCTAssertNotNil(boss.node)
        XCTAssertTrue(boss.isVisible)
        XCTAssertNotNil(boss.physicsBody)
        XCTAssertEqual(boss.bossType, .guardian)
        XCTAssertEqual(boss.health, 1000) // Guardian max health
        XCTAssertEqual(boss.currentPhase, .phase1)
    }

    @MainActor
    func testBossTypes() {
        let destroyerBoss = Boss(type: .destroyer)
        XCTAssertEqual(destroyerBoss.bossType, .destroyer)

        let overlordBoss = Boss(type: .overlord)
        XCTAssertEqual(overlordBoss.bossType, .overlord)
    }

    @MainActor
    func testBossTakeDamage() {
        let boss = Boss(type: .guardian)

        let initialHealth = boss.health
        boss.takeDamage(100)

        XCTAssertEqual(boss.health, initialHealth - 100)
    }

    @MainActor
    func testBossPhaseTransitions() {
        let boss = Boss(type: .guardian)

        // Phase 1 to Phase 2 (70% health threshold)
        boss.takeDamage(300) // 1000 - 300 = 700 (70% of 1000)
        XCTAssertEqual(boss.currentPhase, .phase2)

        // Phase 2 to Phase 3 (30% health threshold)
        boss.takeDamage(550) // 700 - 550 = 150 (15% of 1000, below 30%)
        XCTAssertEqual(boss.currentPhase, .phase3)

        // Phase 3 to Defeated
        boss.takeDamage(150) // 150 - 150 = 0
        XCTAssertEqual(boss.currentPhase, .defeated)
    }

    @MainActor
    func testBossReset() {
        let boss = Boss(type: .guardian)

        boss.takeDamage(500)

        boss.reset()

        XCTAssertEqual(boss.health, 1000) // Reset to initial health
        XCTAssertEqual(boss.currentPhase, .phase1)
        XCTAssertTrue(boss.isVisible)
    }

    @MainActor
    func testBossAttacks() {
        let guardianBoss = Boss(type: .guardian)
        let attack = guardianBoss.performAttack()

        XCTAssertNotNil(attack)

        let destroyerBoss = Boss(type: .destroyer)
        let destroyerAttack = destroyerBoss.performAttack()

        XCTAssertNotNil(destroyerAttack)
    }

    @MainActor
    func testBossHashable() {
        let boss1 = Boss(type: .guardian)
        let boss2 = Boss(type: .guardian)
        let boss3 = boss1

        // Different instances should not be equal
        XCTAssertNotEqual(boss1, boss2)
        // Same instance should be equal
        XCTAssertEqual(boss1, boss3)
    }

    // MARK: - BossAttack Enum Tests

    func testBossAttackEnum() {
        // Test that BossAttack enum exists and has expected cases
        XCTAssertNotNil(BossAttack.laserBeam)
        XCTAssertNotNil(BossAttack.spikeWave)
        XCTAssertNotNil(BossAttack.projectileBarrage)
        XCTAssertNotNil(BossAttack.shockwave)
        XCTAssertNotNil(BossAttack.minionSpawn)
        XCTAssertNotNil(BossAttack.teleportStrike)
        XCTAssertNotNil(BossAttack.ultimateAttack)
    }

    // MARK: - MovementDirection Enum Tests

    func testMovementDirectionEnum() {
        XCTAssertEqual(MovementDirection.left.displayName, "Left")
        XCTAssertEqual(MovementDirection.right.displayName, "Right")
        XCTAssertEqual(MovementDirection.up.displayName, "Up")
        XCTAssertEqual(MovementDirection.down.displayName, "Down")
    }

    func testMovementDirectionCodable() {
        let direction = MovementDirection.left
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        do {
            let data = try encoder.encode(direction)
            let decodedDirection = try decoder.decode(MovementDirection.self, from: data)
            XCTAssertEqual(direction, decodedDirection)
        } catch {
            XCTFail("MovementDirection encoding/decoding failed: \(error)")
        }
    }
}
