import SpriteKit
import XCTest

@testable import AvoidObstaclesGame

final class GameSceneTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here
    }

    override func tearDown() {
        // Put teardown code here
        super.tearDown()
    }

    // MARK: - PhysicsCategory Tests

    func testPhysicsCategoryInitialization() {
        // Test basic initialization
        let playerCategory: UInt32 = PhysicsCategory.player
        let obstacleCategory: UInt32 = PhysicsCategory.obstacle
        XCTAssertEqual(playerCategory, 0x1, "Player category should have correct bit mask")
        XCTAssertEqual(obstacleCategory, 0x1 << 1, "Obstacle category should have correct bit mask")
    }

    func testPhysicsCategoryProperties() {
        // Test property access and validation
        XCTAssertEqual(PhysicsCategory.player, 0x1, "Player category should be correct")
        XCTAssertEqual(PhysicsCategory.obstacle, 0x1 << 1, "Obstacle category should be correct")
    }

    func testPhysicsCategoryMethods() {
        // Test method functionality - PhysicsCategory is an enum, so limited methods
        let categories = [PhysicsCategory.player, PhysicsCategory.obstacle]
        XCTAssertEqual(categories.count, 2, "Should have 2 physics categories")
    }

    // MARK: - GameScene Tests

    func testGameSceneInitialization() {
        // Test basic initialization
        let scene = GameScene(size: CGSize(width: 375, height: 667))
        XCTAssertNotNil(scene, "GameScene should initialize properly")
        XCTAssertEqual(scene.size.width, 375, "GameScene should have correct width")
        XCTAssertEqual(scene.size.height, 667, "GameScene should have correct height")
    }

    func testGameSceneProperties() {
        // Test property access and validation
        let scene = GameScene(size: CGSize(width: 375, height: 667))

        // Create a mock SKView to trigger didMove(to:)
        let mockView = SKView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        scene.didMove(to: mockView)

        XCTAssertNotNil(scene.physicsWorld, "GameScene should have physics world")
        XCTAssertTrue(
            scene.physicsWorld.contactDelegate === scene,
            "GameScene should be physics contact delegate"
        )
    }

    func testGameSceneMethods() {
        // Test method functionality
        let scene = GameScene(size: CGSize(width: 375, height: 667))
        // Test that scene can be created and has expected properties
        XCTAssertNotNil(scene, "GameScene should respond to methods")
    }
}
