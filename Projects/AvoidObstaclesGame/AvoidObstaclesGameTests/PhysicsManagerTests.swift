@testable import AvoidObstaclesGame
import SpriteKit
import XCTest

@MainActor
class PhysicsManagerTests: XCTestCase {

    var physicsManager: PhysicsManager!
    var mockScene: SKScene!

    override func setUp() {
        super.setUp()
        mockScene = SKScene(size: CGSize(width: 375, height: 667))
        physicsManager = PhysicsManager(scene: mockScene)
    }

    override func tearDown() {
        physicsManager.cleanup()
        physicsManager = nil
        mockScene = nil
        super.tearDown()
    }

    // MARK: - PhysicsQuality Tests

    func testPhysicsQualityEnumValues() {
        // Test that all enum cases exist and are accessible
        XCTAssertEqual(PhysicsQuality.high, PhysicsQuality.high)
        XCTAssertEqual(PhysicsQuality.medium, PhysicsQuality.medium)
        XCTAssertEqual(PhysicsQuality.low, PhysicsQuality.low)

        // Test enum raw values if they exist
        XCTAssertNotNil(PhysicsQuality.high)
        XCTAssertNotNil(PhysicsQuality.medium)
        XCTAssertNotNil(PhysicsQuality.low)
    }

    func testPhysicsQualitySwitchCoverage() {
        // Test that switch statements cover all cases
        let qualities: [PhysicsQuality] = [.high, .medium, .low]

        for quality in qualities {
            switch quality {
            case .high, .medium, .low:
                XCTAssertTrue(true, "Quality \(quality) is handled")
            }
        }
    }

    func testPhysicsQualityHashable() {
        // Test that enum values can be used as dictionary keys
        var qualityDict = [PhysicsQuality: String]()
        qualityDict[.high] = "High Quality"
        qualityDict[.medium] = "Medium Quality"
        qualityDict[.low] = "Low Quality"

        XCTAssertEqual(qualityDict[.high], "High Quality")
        XCTAssertEqual(qualityDict[.medium], "Medium Quality")
        XCTAssertEqual(qualityDict[.low], "Low Quality")
    }

    // MARK: - PhysicsMaterial Tests

    func testPhysicsMaterialInitialization() {
        // Test basic initialization with custom values
        let material = PhysicsMaterial(
            restitution: 0.5,
            friction: 0.3,
            density: 1.2,
            linearDamping: 0.1,
            angularDamping: 0.2
        )

        XCTAssertEqual(material.restitution, 0.5)
        XCTAssertEqual(material.friction, 0.3)
        XCTAssertEqual(material.density, 1.2)
        XCTAssertEqual(material.linearDamping, 0.1)
        XCTAssertEqual(material.angularDamping, 0.2)
    }

    func testPhysicsMaterialProperties() {
        // Test property access and validation
        let material = PhysicsMaterial.player

        XCTAssertEqual(material.restitution, 0.0)
        XCTAssertEqual(material.friction, 0.0)
        XCTAssertEqual(material.density, 1.0)
        XCTAssertEqual(material.linearDamping, 0.1)
        XCTAssertEqual(material.angularDamping, 0.1)
    }

    func testPhysicsMaterialStaticInstances() {
        // Test all predefined material instances
        let player = PhysicsMaterial.player
        XCTAssertEqual(player.restitution, 0.0)
        XCTAssertEqual(player.density, 1.0)

        let obstacle = PhysicsMaterial.obstacle
        XCTAssertEqual(obstacle.restitution, 0.2)
        XCTAssertEqual(obstacle.density, 0.8)

        let powerUp = PhysicsMaterial.powerUp
        XCTAssertEqual(powerUp.restitution, 0.8)
        XCTAssertEqual(powerUp.density, 0.3)

        let bouncingObstacle = PhysicsMaterial.bouncingObstacle
        XCTAssertEqual(bouncingObstacle.restitution, 0.9)
        XCTAssertEqual(bouncingObstacle.density, 0.6)

        let laser = PhysicsMaterial.laser
        XCTAssertEqual(laser.restitution, 0.0)
        XCTAssertEqual(laser.density, 2.0)
    }

    func testPhysicsMaterialEquatable() {
        // Test equality comparison
        let material1 = PhysicsMaterial(
            restitution: 0.5,
            friction: 0.3,
            density: 1.0,
            linearDamping: 0.1,
            angularDamping: 0.2
        )

        let material2 = PhysicsMaterial(
            restitution: 0.5,
            friction: 0.3,
            density: 1.0,
            linearDamping: 0.1,
            angularDamping: 0.2
        )

        let material3 = PhysicsMaterial(
            restitution: 0.6,
            friction: 0.3,
            density: 1.0,
            linearDamping: 0.1,
            angularDamping: 0.2
        )

        XCTAssertEqual(material1, material2)
        XCTAssertNotEqual(material1, material3)
    }

    // MARK: - PhysicsSimulationSettings Tests

    func testPhysicsSimulationSettingsInitialization() {
        // Test default initialization
        let settings = PhysicsSimulationSettings()

        XCTAssertEqual(settings.gravity, .zero)
        XCTAssertEqual(settings.speed, 1.0)
        XCTAssertTrue(settings.enableRealisticCollisions)
        XCTAssertTrue(settings.enableMomentumTransfer)
        XCTAssertTrue(settings.enableAdvancedForces)
        XCTAssertEqual(settings.collisionCooldown, 0.1)
    }

    func testPhysicsSimulationSettingsCustomInitialization() {
        // Test custom initialization
        let settings = PhysicsSimulationSettings(
            gravity: CGVector(dx: 0, dy: -9.8),
            speed: 0.8,
            enableRealisticCollisions: false,
            enableMomentumTransfer: false,
            enableAdvancedForces: false,
            collisionCooldown: 0.2
        )

        XCTAssertEqual(settings.gravity, CGVector(dx: 0, dy: -9.8))
        XCTAssertEqual(settings.speed, 0.8)
        XCTAssertFalse(settings.enableRealisticCollisions)
        XCTAssertFalse(settings.enableMomentumTransfer)
        XCTAssertFalse(settings.enableAdvancedForces)
        XCTAssertEqual(settings.collisionCooldown, 0.2)
    }

    func testPhysicsSimulationSettingsPropertyModification() {
        // Test property modification
        var settings = PhysicsSimulationSettings()

        settings.gravity = CGVector(dx: 0, dy: -5.0)
        settings.speed = 1.2
        settings.enableRealisticCollisions = false
        settings.collisionCooldown = 0.05

        XCTAssertEqual(settings.gravity, CGVector(dx: 0, dy: -5.0))
        XCTAssertEqual(settings.speed, 1.2)
        XCTAssertFalse(settings.enableRealisticCollisions)
        XCTAssertEqual(settings.collisionCooldown, 0.05)
    }

    func testPhysicsSimulationSettingsEquatable() {
        // Test equality comparison
        let settings1 = PhysicsSimulationSettings()
        let settings2 = PhysicsSimulationSettings()

        XCTAssertEqual(settings1, settings2)

        var settings3 = PhysicsSimulationSettings()
        settings3.speed = 0.9

        XCTAssertNotEqual(settings1, settings3)
    }

    // MARK: - PhysicsManager Integration Tests

    @MainActor
    func testPhysicsManagerInitialization() {
        // Test that physics manager initializes correctly
        XCTAssertNotNil(physicsManager)
        XCTAssertNotNil(mockScene.physicsWorld)
    }

    @MainActor
    func testPhysicsManagerCreatePlayerPhysicsBody() {
        // Test player physics body creation
        let size = CGSize(width: 50, height: 50)
        let physicsBody = physicsManager.createPlayerPhysicsBody(size: size)

        XCTAssertNotNil(physicsBody)
        XCTAssertEqual(physicsBody.categoryBitMask, PhysicsCategory.player)
        XCTAssertEqual(physicsBody.contactTestBitMask, PhysicsCategory.obstacle | PhysicsCategory.powerUp)
        XCTAssertEqual(physicsBody.collisionBitMask, PhysicsCategory.none)
        XCTAssertFalse(physicsBody.affectedByGravity)
        XCTAssertFalse(physicsBody.isDynamic)
        XCTAssertFalse(physicsBody.allowsRotation)
    }

    @MainActor
    func testPhysicsManagerSimulationQuality() {
        // Test simulation quality setting
        XCTAssertNotNil(mockScene.physicsWorld, "Scene physics world should be initialized")

        // Verify that the physics manager has access to the physics world
        XCTAssertTrue(physicsManager.hasPhysicsWorld(), "Physics manager should have physics world reference")

        // Test that the method can be called without error
        physicsManager.setSimulationQuality(.high)
        XCTAssertNotNil(mockScene.physicsWorld, "Physics world should still exist after setting quality")

        physicsManager.setSimulationQuality(.medium)
        XCTAssertNotNil(mockScene.physicsWorld, "Physics world should still exist after setting quality")

        physicsManager.setSimulationQuality(.low)
        XCTAssertNotNil(mockScene.physicsWorld, "Physics world should still exist after setting quality")
    }

    @MainActor
    func testPhysicsManagerDebugVisualization() {
        // Test debug visualization (requires view to be set)
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))

        // Present the scene on the view to set the view property
        view.presentScene(mockScene)

        physicsManager.setDebugVisualization(enabled: true)
        XCTAssertTrue(view.showsPhysics)

        physicsManager.setDebugVisualization(enabled: false)
        XCTAssertFalse(view.showsPhysics)
    }
}
