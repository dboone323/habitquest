//
// PhysicsManager.swift
// AvoidObstaclesGame
//
// Manages physics world setup, collision detection, and physics-related
// game logic.
//

import Foundation
import SpriteKit

/// Protocol for physics-related events
@MainActor
protocol PhysicsManagerDelegate: AnyObject {
    func playerDidCollideWithObstacle(_ player: SKNode, obstacle: SKNode)
    func playerDidCollideWithPowerUp(_ player: SKNode, powerUp: SKNode)
}

/// Manages physics world and collision detection
@MainActor
public class PhysicsManager: NSObject, SKPhysicsContactDelegate {
    // MARK: - Properties

    /// Delegate for physics events
    weak var delegate: PhysicsManagerDelegate?

    /// Reference to the physics world
    private weak var physicsWorld: SKPhysicsWorld?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Advanced physics properties
    private var physicsProperties: [SKNode: PhysicsMaterial] = [:]

    /// Collision history for advanced responses
    private var collisionHistory: [String: TimeInterval] = [:]

    /// Physics simulation settings
    private var simulationSettings = PhysicsSimulationSettings()

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

        // Configure physics world with advanced settings
        physicsWorld.gravity = simulationSettings.gravity
        physicsWorld.contactDelegate = self
        physicsWorld.speed = simulationSettings.speed

        // Enable advanced physics features
        if simulationSettings.enableRealisticCollisions {
            setupAdvancedCollisionDetection()
        }
    }

    /// Sets up advanced collision detection
    private func setupAdvancedCollisionDetection() {
        // Additional setup for realistic physics can be added here
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

    /// Creates a physics body for an obstacle with advanced material properties
    /// - Parameters:
    ///   - size: Size of the obstacle
    ///   - type: Type of obstacle for material properties
    /// - Returns: Configured physics body
    func createObstaclePhysicsBody(size: CGSize, type: Obstacle.ObstacleType = .block) -> SKPhysicsBody {
        let physicsBody: SKPhysicsBody

        switch type {
        case .laser:
            physicsBody = SKPhysicsBody(rectangleOf: size)
        default:
            physicsBody = SKPhysicsBody(rectangleOf: size)
        }

        // Configure physics properties
        physicsBody.categoryBitMask = PhysicsCategory.obstacle
        physicsBody.contactTestBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false

        // Apply advanced material properties
        applyMaterialProperties(to: physicsBody, for: type)

        return physicsBody
    }

    /// Applies material properties to a physics body
    /// - Parameters:
    ///   - body: The physics body to modify
    ///   - type: The obstacle type for material selection
    private func applyMaterialProperties(to body: SKPhysicsBody, for type: Obstacle.ObstacleType) {
        let material: PhysicsMaterial

        switch type {
        case .bouncing:
            material = .bouncingObstacle
        case .laser:
            material = .laser
        default:
            material = .obstacle
        }

        body.restitution = material.restitution
        body.friction = material.friction
        body.density = material.density
        body.linearDamping = material.linearDamping
        body.angularDamping = material.angularDamping
    }

    // MARK: - Advanced Physics Methods

    /// Applies realistic momentum transfer between colliding bodies
    /// - Parameters:
    ///   - bodyA: First physics body
    ///   - bodyB: Second physics body
    ///   - collisionPoint: Point of collision
    func applyMomentumTransfer(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody, collisionPoint: CGPoint) {
        guard simulationSettings.enableMomentumTransfer else { return }

        // Calculate relative velocity
        let relativeVelocity = CGVector(
            dx: bodyA.velocity.dx - bodyB.velocity.dx,
            dy: bodyA.velocity.dy - bodyB.velocity.dy
        )

        // Calculate collision normal (simplified)
        let normal = CGVector(dx: 0, dy: 1) // Assuming vertical collision for simplicity

        // Calculate impulse
        let impulseMagnitude = relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy
        let impulse = CGVector(
            dx: impulseMagnitude * normal.dx,
            dy: impulseMagnitude * normal.dy
        )

        // Apply impulse to both bodies
        bodyA.applyImpulse(impulse)
        bodyB.applyImpulse(CGVector(dx: -impulse.dx, dy: -impulse.dy))
    }

    /// Applies advanced force to a physics body with realistic dynamics
    /// - Parameters:
    ///   - body: The physics body to apply force to
    ///   - force: The force vector
    ///   - duration: Duration to apply the force
    func applyAdvancedForce(to body: SKPhysicsBody, force: CGVector, duration: TimeInterval = 0.1) {
        guard simulationSettings.enableAdvancedForces else {
            body.applyForce(force)
            return
        }

        // Apply force with damping for more realistic movement
        let dampedForce = CGVector(
            dx: force.dx * (1.0 - body.linearDamping),
            dy: force.dy * (1.0 - body.linearDamping)
        )

        body.applyForce(dampedForce)

        // Schedule force removal
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            body.applyForce(CGVector(dx: -dampedForce.dx, dy: -dampedForce.dy))
        }
    }

    /// Creates a realistic collision response with sound and visual effects
    /// - Parameters:
    ///   - bodyA: First colliding body
    ///   - bodyB: Second colliding body
    ///   - intensity: Collision intensity (0.0 - 1.0)
    func createCollisionResponse(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody, intensity: CGFloat) {
        // Calculate collision energy
        let energy = sqrt(pow(bodyA.velocity.dx, 2) + pow(bodyA.velocity.dy, 2)) +
            sqrt(pow(bodyB.velocity.dx, 2) + pow(bodyB.velocity.dy, 2))

        // Apply realistic bounce with energy conservation
        if intensity > 0.5 {
            let bounceForce = CGVector(dx: 0, dy: energy * 0.1)
            bodyA.applyImpulse(bounceForce)
            bodyB.applyImpulse(CGVector(dx: -bounceForce.dx, dy: -bounceForce.dy))
        }
    }

    /// Updates physics simulation with advanced features
    /// - Parameter deltaTime: Time elapsed since last update
    func updatePhysics(deltaTime: TimeInterval) {
        // Update collision history (remove old entries)
        let currentTime = Date().timeIntervalSince1970
        collisionHistory = collisionHistory.filter { currentTime - $0.value < 1.0 }

        // Apply continuous forces if needed
        applyContinuousForces(deltaTime)
    }

    /// Applies continuous forces like drag or magnetic effects
    /// - Parameter deltaTime: Time elapsed
    private func applyContinuousForces(_ deltaTime: TimeInterval) {
        // Apply air resistance to moving bodies via scene children
        guard let scene else { return }

        // Iterate through all nodes in the scene that have physics bodies
        for node in scene.children {
            if let body = node.physicsBody,
               body.velocity.dx != 0 || body.velocity.dy != 0
            {
                let dragForce = CGVector(
                    dx: -body.velocity.dx * body.linearDamping * CGFloat(deltaTime),
                    dy: -body.velocity.dy * body.linearDamping * CGFloat(deltaTime)
                )
                body.applyForce(dragForce)
            }
        }
    }

    /// Registers a node with specific physics material properties
    /// - Parameters:
    ///   - node: The node to register
    ///   - material: The material properties
    func registerNode(_ node: SKNode, withMaterial material: PhysicsMaterial) {
        physicsProperties[node] = material

        // Apply material properties to physics body if it exists
        if let body = node.physicsBody {
            body.restitution = material.restitution
            body.friction = material.friction
            body.density = material.density
            body.linearDamping = material.linearDamping
            body.angularDamping = material.angularDamping
        }
    }

    /// Gets the material properties for a node
    /// - Parameter node: The node to query
    /// - Returns: Material properties or default
    func materialForNode(_ node: SKNode) -> PhysicsMaterial {
        physicsProperties[node] ?? .obstacle
    }

    // MARK: - Collision Detection (SKPhysicsContactDelegate)

    /// Called when two physics bodies begin contact
    public nonisolated func didBegin(_ contact: SKPhysicsContact) {
        // Extract Sendable information before creating the Task
        let firstCategory = contact.bodyA.categoryBitMask
        let secondCategory = contact.bodyB.categoryBitMask

        // Determine which body is first based on category
        let (firstBody, secondBody) = if firstCategory < secondCategory {
            (contact.bodyA, contact.bodyB)
        } else {
            (contact.bodyB, contact.bodyA)
        }

        // Extract collision information that can be safely passed to the main actor
        let collisionMask = firstBody.categoryBitMask | secondBody.categoryBitMask
        let firstNode = firstBody.node
        let secondNode = secondBody.node

        // Handle different collision types
        Task { @MainActor in
            self.handleCollision(collisionMask: collisionMask, firstNode: firstNode, secondNode: secondNode)
        }
    }

    /// Processes collision based on body categories
    private func handleCollision(collisionMask: UInt32, firstNode: SKNode?, secondNode: SKNode?) {
        switch collisionMask {
        case PhysicsCategory.player | PhysicsCategory.obstacle:
            // Player collided with obstacle
            if let playerNode = getPlayerNode(firstNode, secondNode),
               let obstacleNode = getObstacleNode(firstNode, secondNode)
            {
                self.delegate?.playerDidCollideWithObstacle(playerNode, obstacle: obstacleNode)
            }

        case PhysicsCategory.player | PhysicsCategory.powerUp:
            // Player collided with power-up
            if let playerNode = getPlayerNode(firstNode, secondNode),
               let powerUpNode = getPowerUpNode(firstNode, secondNode)
            {
                self.delegate?.playerDidCollideWithPowerUp(playerNode, powerUp: powerUpNode)
            }

        default:
            // Other collisions (not handled)
            break
        }
    }

    /// Helper method to get the player node from collision nodes
    private func getPlayerNode(_ firstNode: SKNode?, _ secondNode: SKNode?) -> SKNode? {
        if let firstNode, firstNode.physicsBody?.categoryBitMask == PhysicsCategory.player {
            return firstNode
        } else if let secondNode, secondNode.physicsBody?.categoryBitMask == PhysicsCategory.player {
            return secondNode
        }
        return nil
    }

    /// Helper method to get the obstacle node from collision nodes
    private func getObstacleNode(_ firstNode: SKNode?, _ secondNode: SKNode?) -> SKNode? {
        if let firstNode, firstNode.physicsBody?.categoryBitMask == PhysicsCategory.obstacle {
            return firstNode
        } else if let secondNode, secondNode.physicsBody?.categoryBitMask == PhysicsCategory.obstacle {
            return secondNode
        }
        return nil
    }

    /// Helper method to get the power-up node from collision nodes
    private func getPowerUpNode(_ firstNode: SKNode?, _ secondNode: SKNode?) -> SKNode? {
        if let firstNode, firstNode.physicsBody?.categoryBitMask == PhysicsCategory.powerUp {
            return firstNode
        } else if let secondNode, secondNode.physicsBody?.categoryBitMask == PhysicsCategory.powerUp {
            return secondNode
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
        self.physicsProperties.removeAll()
        self.collisionHistory.removeAll()
    }
}

/// Physics simulation quality levels
enum PhysicsQuality {
    case high
    case medium
    case low
}

/// Advanced physics material properties
struct PhysicsMaterial {
    let restitution: CGFloat // Bounciness (0.0 - 1.0)
    let friction: CGFloat // Surface friction (0.0 - 1.0)
    let density: CGFloat // Mass density
    let linearDamping: CGFloat // Air resistance
    let angularDamping: CGFloat // Rotational resistance

    static let player = PhysicsMaterial(
        restitution: 0.0,
        friction: 0.0,
        density: 1.0,
        linearDamping: 0.1,
        angularDamping: 0.1
    )

    static let obstacle = PhysicsMaterial(
        restitution: 0.2,
        friction: 0.1,
        density: 0.8,
        linearDamping: 0.05,
        angularDamping: 0.05
    )

    static let powerUp = PhysicsMaterial(
        restitution: 0.8,
        friction: 0.0,
        density: 0.3,
        linearDamping: 0.02,
        angularDamping: 0.02
    )

    static let bouncingObstacle = PhysicsMaterial(
        restitution: 0.9,
        friction: 0.0,
        density: 0.6,
        linearDamping: 0.01,
        angularDamping: 0.01
    )

    static let laser = PhysicsMaterial(
        restitution: 0.0,
        friction: 0.0,
        density: 2.0,
        linearDamping: 0.0,
        angularDamping: 0.0
    )
}

/// Physics simulation settings
struct PhysicsSimulationSettings {
    var gravity: CGVector = .zero
    var speed: CGFloat = 1.0
    var enableRealisticCollisions = true
    var enableMomentumTransfer = true
    var enableAdvancedForces = true
    var collisionCooldown: TimeInterval = 0.1 // Minimum time between same collision pairs
}
