//
// PhysicsManager.swift
// AvoidObstaclesGame
//
// Manages physics world setup, collision detection, and physics-related
// game logic.
//

import SpriteKit

/// Protocol for physics-related events
protocol PhysicsManagerDelegate: AnyObject {
    func playerDidCollideWithObstacle(_ player: SKNode, obstacle: SKNode)
    func playerDidCollideWithPowerUp(_ player: SKNode, powerUp: SKNode)
}

/// Manages physics world and collision detection
public class PhysicsManager: NSObject, SKPhysicsContactDelegate {
    // MARK: - Properties

    /// Delegate for physics events
    weak var delegate: PhysicsManagerDelegate?

    /// Reference to the physics world
    private weak var physicsWorld: SKPhysicsWorld?

    /// Reference to the game scene
    private weak var scene: SKScene?

    // MARK: - Initialization

    init(scene: SKScene) {
        super.init()
        self.scene = scene
        self.physicsWorld = scene.physicsWorld
        self.setupPhysicsWorld()
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
        self.physicsWorld = scene.physicsWorld
        self.setupPhysicsWorld()
    }

    // MARK: - Physics World Setup

    /// Sets up the physics world with proper configuration
    private func setupPhysicsWorld() {
        guard let physicsWorld else { return }

        // Configure physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // No gravity for top-down game
        physicsWorld.contactDelegate = self

        // Set speed for consistent physics across devices
        physicsWorld.speed = 1.0
    }

    // MARK: - Physics Body Creation

    /// Creates a physics body for the player
    /// - Parameter size: Size of the player
    /// - Returns: Configured physics body
    func createPlayerPhysicsBody(size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        // Configure physics properties
        physicsBody.categoryBitMask = PhysicsCategory.player
        physicsBody.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.powerUp
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.allowsRotation = false

        return physicsBody
    }

    /// Creates a physics body for an obstacle
    /// - Parameter size: Size of the obstacle
    /// - Returns: Configured physics body
    func createObstaclePhysicsBody(size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        // Configure physics properties
        physicsBody.categoryBitMask = PhysicsCategory.obstacle
        physicsBody.contactTestBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false

        return physicsBody
    }

    /// Creates a physics body for a power-up
    /// - Parameter size: Size of the power-up
    /// - Returns: Configured physics body
    func createPowerUpPhysicsBody(size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        // Configure physics properties
        physicsBody.categoryBitMask = PhysicsCategory.powerUp
        physicsBody.contactTestBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false

        return physicsBody
    }

    // MARK: - Collision Detection (SKPhysicsContactDelegate)

    /// Called when two physics bodies begin contact
    public func didBegin(_ contact: SKPhysicsContact) {
        // Order bodies by category for consistent processing
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // Handle different collision types
        self.handleCollision(firstBody: firstBody, secondBody: secondBody)
    }

    /// Processes collision based on body categories
    private func handleCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
        let collision = firstBody.categoryBitMask | secondBody.categoryBitMask

        switch collision {
        case PhysicsCategory.player | PhysicsCategory.obstacle:
            // Player collided with obstacle
            if let playerNode = getNode(from: firstBody, secondBody),
               let obstacleNode = getNode(from: secondBody, firstBody) {
                self.delegate?.playerDidCollideWithObstacle(playerNode, obstacle: obstacleNode)
            }

        case PhysicsCategory.player | PhysicsCategory.powerUp:
            // Player collided with power-up
            if let playerNode = getNode(from: firstBody, secondBody),
               let powerUpNode = getNode(from: secondBody, firstBody) {
                self.delegate?.playerDidCollideWithPowerUp(playerNode, powerUp: powerUpNode)
            }

        default:
            // Other collisions (not handled)
            break
        }
    }

    /// Helper method to get the correct node from physics bodies
    private func getNode(from bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) -> SKNode? {
        if bodyA.categoryBitMask == PhysicsCategory.player {
            return bodyA.node
        } else if bodyB.categoryBitMask == PhysicsCategory.player {
            return bodyB.node
        }
        return nil
    }

    // MARK: - Physics Utilities

    /// Applies an impulse to a physics body
    /// - Parameters:
    ///   - body: The physics body to apply impulse to
    ///   - impulse: The impulse vector
    func applyImpulse(to body: SKPhysicsBody, impulse: CGVector) {
        body.applyImpulse(impulse)
    }

    /// Applies a force to a physics body
    /// - Parameters:
    ///   - body: The physics body to apply force to
    ///   - force: The force vector
    func applyForce(to body: SKPhysicsBody, force: CGVector) {
        body.applyForce(force)
    }

    /// Sets the velocity of a physics body
    /// - Parameters:
    ///   - body: The physics body to modify
    ///   - velocity: The new velocity
    func setVelocity(of body: SKPhysicsBody, to velocity: CGVector) {
        body.velocity = velocity
    }

    /// Gets the velocity of a physics body
    /// - Parameter body: The physics body to query
    /// - Returns: Current velocity
    func getVelocity(of body: SKPhysicsBody) -> CGVector {
        body.velocity
    }

    // MARK: - Physics World Queries

    /// Performs a ray cast from a point in a direction
    /// - Parameters:
    ///   - startPoint: Starting point of the ray
    ///   - endPoint: Ending point of the ray
    /// - Returns: Array of physics bodies hit by the ray
    func rayCast(from startPoint: CGPoint, to endPoint: CGPoint) -> [SKPhysicsBody] {
        guard let physicsWorld else { return [] }

        var bodies = [SKPhysicsBody]()
        physicsWorld.enumerateBodies(alongRayStart: startPoint, end: endPoint) { body, _, _, _ in
            bodies.append(body)
        }

        return bodies
    }

    /// Performs a point query to find bodies at a specific point
    /// - Parameter point: The point to query
    /// - Returns: Array of physics bodies at the point
    func bodies(at point: CGPoint) -> [SKPhysicsBody] {
        guard let physicsWorld else { return [] }

        // Create a small rectangle around the point for querying
        let queryRect = CGRect(x: point.x - 1, y: point.y - 1, width: 2, height: 2)
        var bodies = [SKPhysicsBody]()

        physicsWorld.enumerateBodies(in: queryRect) { body, _ in
            bodies.append(body)
            // Stop after finding bodies (optional, can be removed to find all)
        }

        return bodies
    }

    /// Performs an area query to find bodies within a rectangle
    /// - Parameter rect: The rectangle to query
    /// - Returns: Array of physics bodies in the rectangle
    func bodies(in rect: CGRect) -> [SKPhysicsBody] {
        guard let physicsWorld else { return [] }

        var bodies = [SKPhysicsBody]()
        physicsWorld.enumerateBodies(in: rect) { body, _ in
            bodies.append(body)
        }

        return bodies
    }

    // MARK: - Physics Debugging

    /// Enables or disables physics debugging visualization
    /// - Parameter enabled: Whether to show physics bodies
    func setDebugVisualization(enabled: Bool) {
        guard let scene, let view = scene.view else { return }
        view.showsPhysics = enabled
    }

    /// Enables or disables FPS display
    /// - Parameter enabled: Whether to show FPS
    func setFPSDisplay(enabled: Bool) {
        guard let scene, let view = scene.view else { return }
        view.showsFPS = enabled
    }

    /// Enables or disables node count display
    /// - Parameter enabled: Whether to show node count
    func setNodeCountDisplay(enabled: Bool) {
        guard let scene, let view = scene.view else { return }
        view.showsNodeCount = enabled
    }

    // MARK: - Performance Optimization

    /// Updates physics simulation quality
    /// - Parameter quality: The desired quality level
    func setSimulationQuality(_ quality: PhysicsQuality) {
        guard let physicsWorld else { return }

        switch quality {
        case .high:
            physicsWorld.speed = 1.0
        case .medium:
            physicsWorld.speed = 0.8
        case .low:
            physicsWorld.speed = 0.6
        }
    }

    // MARK: - Cleanup

    /// Cleans up physics-related resources
    func cleanup() {
        self.physicsWorld?.contactDelegate = nil
    }

    // MARK: - Async Physics Operations

    /// Creates a physics body for the player asynchronously
    /// - Parameter size: Size of the player
    /// - Returns: Configured physics body
    func createPlayerPhysicsBodyAsync(size: CGSize) async -> SKPhysicsBody {
        await Task.detached {
            self.createPlayerPhysicsBody(size: size)
        }.value
    }

    /// Creates a physics body for an obstacle asynchronously
    /// - Parameter size: Size of the obstacle
    /// - Returns: Configured physics body
    func createObstaclePhysicsBodyAsync(size: CGSize) async -> SKPhysicsBody {
        await Task.detached {
            self.createObstaclePhysicsBody(size: size)
        }.value
    }

    /// Creates a physics body for a power-up asynchronously
    /// - Parameter size: Size of the power-up
    /// - Returns: Configured physics body
    func createPowerUpPhysicsBodyAsync(size: CGSize) async -> SKPhysicsBody {
        await Task.detached {
            self.createPowerUpPhysicsBody(size: size)
        }.value
    }

    /// Applies an impulse to a physics body asynchronously
    /// - Parameters:
    ///   - body: The physics body to apply impulse to
    ///   - impulse: The impulse vector
    func applyImpulseAsync(to body: SKPhysicsBody, impulse: CGVector) async {
        await Task.detached {
            self.applyImpulse(to: body, impulse: impulse)
        }.value
    }

    /// Applies a force to a physics body asynchronously
    /// - Parameters:
    ///   - body: The physics body to apply force to
    ///   - force: The force vector
    func applyForceAsync(to body: SKPhysicsBody, force: CGVector) async {
        await Task.detached {
            self.applyForce(to: body, force: force)
        }.value
    }

    /// Sets the velocity of a physics body asynchronously
    /// - Parameters:
    ///   - body: The physics body to modify
    ///   - velocity: The new velocity
    func setVelocityAsync(of body: SKPhysicsBody, to velocity: CGVector) async {
        await Task.detached {
            self.setVelocity(of: body, to: velocity)
        }.value
    }

    /// Gets the velocity of a physics body asynchronously
    /// - Parameter body: The physics body to query
    /// - Returns: Current velocity
    func getVelocityAsync(of body: SKPhysicsBody) async -> CGVector {
        await Task.detached {
            self.getVelocity(of: body)
        }.value
    }

    /// Performs a ray cast from a point in a direction asynchronously
    /// - Parameters:
    ///   - startPoint: Starting point of the ray
    ///   - endPoint: Ending point of the ray
    /// - Returns: Array of physics bodies hit by the ray
    func rayCastAsync(from startPoint: CGPoint, to endPoint: CGPoint) async -> [SKPhysicsBody] {
        await Task.detached {
            self.rayCast(from: startPoint, to: endPoint)
        }.value
    }

    /// Performs a point query to find bodies at a specific point asynchronously
    /// - Parameter point: The point to query
    /// - Returns: Array of physics bodies at the point
    func bodiesAsync(at point: CGPoint) async -> [SKPhysicsBody] {
        await Task.detached {
            self.bodies(at: point)
        }.value
    }

    /// Performs an area query to find bodies within a rectangle asynchronously
    /// - Parameter rect: The rectangle to query
    /// - Returns: Array of physics bodies in the rectangle
    func bodiesAsync(in rect: CGRect) async -> [SKPhysicsBody] {
        await Task.detached {
            self.bodies(in: rect)
        }.value
    }

    /// Enables or disables physics debugging visualization asynchronously
    /// - Parameter enabled: Whether to show physics bodies
    func setDebugVisualizationAsync(enabled: Bool) async {
        await Task.detached {
            self.setDebugVisualization(enabled: enabled)
        }.value
    }

    /// Enables or disables FPS display asynchronously
    /// - Parameter enabled: Whether to show FPS
    func setFPSDisplayAsync(enabled: Bool) async {
        await Task.detached {
            self.setFPSDisplay(enabled: enabled)
        }.value
    }

    /// Enables or disables node count display asynchronously
    /// - Parameter enabled: Whether to show node count
    func setNodeCountDisplayAsync(enabled: Bool) async {
        await Task.detached {
            self.setNodeCountDisplay(enabled: enabled)
        }.value
    }

    /// Updates physics simulation quality asynchronously
    /// - Parameter quality: The desired quality level
    func setSimulationQualityAsync(_ quality: PhysicsQuality) async {
        await Task.detached {
            self.setSimulationQuality(quality)
        }.value
    }

    /// Cleans up physics-related resources asynchronously
    func cleanupAsync() async {
        await Task.detached {
            self.cleanup()
        }.value
    }
}

/// Physics simulation quality levels
enum PhysicsQuality {
    case high
    case medium
    case low
}

// MARK: - Object Pooling

/// Object pool for performance optimization
private var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
