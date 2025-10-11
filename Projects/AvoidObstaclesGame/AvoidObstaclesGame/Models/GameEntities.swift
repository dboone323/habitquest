// MARK: - Core Game Entities and Protocols
// Unified UI/UX improvements for AvoidObstaclesGame
// Implements AI-recommended architecture for better game management

import SpriteKit
import UIKit

// MARK: - Core Protocols

/// Protocol for all game components that need updates
protocol GameComponent: AnyObject {
    func update(deltaTime: TimeInterval)
    func reset()
}

/// Protocol for objects that can be rendered on screen
protocol Renderable {
    var node: SKNode { get }
    var isVisible: Bool { get set }
}

/// Protocol for objects that can collide
protocol Collidable {
    var physicsBody: SKPhysicsBody? { get }
    func handleCollision(with other: Collidable)
}

// MARK: - Core Game Entities

/// Represents the player character with enhanced UI feedback
class Player: GameComponent, Renderable, Collidable {
    private(set) var node: SKNode
    var isVisible: Bool = true
    var position: CGPoint {
        get { node.position }
        set { node.position = newValue }
    }

    private var currentSpeed: CGFloat = 200.0
    private var trailParticles: SKEmitterNode?

    init() {
        // Create player node with improved visual design
        let playerNode = SKShapeNode(circleOfRadius: 15)
        playerNode.fillColor = UIColor.systemBlue
        playerNode.strokeColor = UIColor.white
        playerNode.lineWidth = 2
        playerNode.glowWidth = 1

        // Add subtle glow effect using blend mode
        playerNode.blendMode = .add

        self.node = playerNode

        setupPhysics()
        setupTrailEffect()
    }

    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(circleOfRadius: 15)
        physicsBody.categoryBitMask = PhysicsCategory.player
        physicsBody.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.powerUp
        physicsBody.collisionBitMask = PhysicsCategory.obstacle
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false
        physicsBody.restitution = 0.0
        physicsBody.friction = 0.0

        node.physicsBody = physicsBody
    }

    private func setupTrailEffect() {
        // Add particle trail for better visual feedback
        let trail = SKEmitterNode(fileNamed: "PlayerTrail")
        trail?.position = .zero
        trail?.targetNode = node.scene
        trailParticles = trail

        if let trail = trail {
            node.addChild(trail)
        }
    }

    var physicsBody: SKPhysicsBody? {
        node.physicsBody
    }

    func move(direction: CGVector, deltaTime: TimeInterval) {
        let movement = CGVector(
            dx: direction.dx * currentSpeed * deltaTime,
            dy: direction.dy * currentSpeed * deltaTime
        )

        node.position.x += movement.dx
        node.position.y += movement.dy

        // Update trail effect
        trailParticles?.position = node.position
    }

    func constrainToScreenBounds(screenSize: CGSize) {
        let halfWidth = node.frame.width / 2
        let halfHeight = node.frame.height / 2

        node.position.x = max(halfWidth, min(screenSize.width - halfWidth, node.position.x))
        node.position.y = max(halfHeight, min(screenSize.height - halfHeight, node.position.y))
    }

    func handleCollision(with other: Collidable) {
        // Add visual feedback for collision
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        node.run(flash)

        // Add screen shake effect
        if let scene = node.scene {
            let shake = SKAction.sequence([
                SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            ])
            scene.run(shake)
        }
    }

    func update(deltaTime: TimeInterval) {
        // Update player-specific logic
        // Could include animation updates, power-up effects, etc.
    }

    func reset() {
        node.position = CGPoint(x: 100, y: 200)
        node.removeAllActions()
        trailParticles?.resetSimulation()
        isVisible = true
    }

    func setSpeed(_ speed: CGFloat) {
        currentSpeed = speed
    }

    func activatePowerUp(_ type: PowerUpType) {
        // This method should be called on the PowerUp instance, not the Player
        // The logic should be in the PowerUp class
    }
}

/// Represents game obstacles with improved visual design
class Obstacle: GameComponent, Renderable, Collidable, Hashable {
    private(set) var node: SKNode
    var isVisible: Bool = true
    var position: CGPoint {
        get { node.position }
        set { node.position = newValue }
    }

    private var speed: CGFloat = 100.0
    let obstacleType: ObstacleType

    enum ObstacleType {
        case spike, block, moving

        var color: UIColor {
            switch self {
            case .spike: return .red
            case .block: return .orange
            case .moving: return .purple
            }
        }

        var size: CGSize {
            switch self {
            case .spike: return CGSize(width: 20, height: 40)
            case .block: return CGSize(width: 30, height: 30)
            case .moving: return CGSize(width: 25, height: 25)
            }
        }
    }

    init(type: ObstacleType = .block) {
        self.obstacleType = type

        // Create obstacle node with improved visuals
        let obstacleNode: SKNode
        switch type {
        case .spike:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -10, y: -20))
            path.addLine(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 10, y: -20))
            path.closeSubpath()

            let shape = SKShapeNode(path: path)
            shape.fillColor = type.color
            shape.strokeColor = .white
            shape.lineWidth = 1
            obstacleNode = shape

        case .block, .moving:
            let shape = SKShapeNode(rectOf: type.size)
            shape.fillColor = type.color
            shape.strokeColor = .white
            shape.lineWidth = 1
            obstacleNode = shape
        }

        self.node = obstacleNode
        setupPhysics()
    }

    private func setupPhysics() {
        let physicsBody: SKPhysicsBody

        switch obstacleType {
        case .spike:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -10, y: -20))
            path.addLine(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 10, y: -20))
            path.closeSubpath()
            physicsBody = SKPhysicsBody(polygonFrom: path)

        case .block, .moving:
            physicsBody = SKPhysicsBody(rectangleOf: obstacleType.size)
        }

        physicsBody.categoryBitMask = PhysicsCategory.obstacle
        physicsBody.contactTestBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.player
        physicsBody.isDynamic = false
        physicsBody.restitution = 0.0
        physicsBody.friction = 0.0

        node.physicsBody = physicsBody
    }

    var physicsBody: SKPhysicsBody? {
        node.physicsBody
    }

    func handleCollision(with other: Collidable) {
        // Obstacles don't react to collisions, they cause game over
        // Visual feedback is handled by the player
    }

    func update(deltaTime: TimeInterval) {
        // Move obstacle from right to left
        node.position.x -= speed * deltaTime

        // Add movement for moving obstacles
        if obstacleType == .moving {
            let verticalMovement = sin(node.position.x * 0.01) * 50
            node.position.y = 200 + verticalMovement
        }
    }

    func reset() {
        // Reset will be handled by the pool
        isVisible = true
        node.removeAllActions()
    }

    func setSpeed(_ newSpeed: CGFloat) {
        speed = newSpeed
    }

    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: Obstacle, rhs: Obstacle) -> Bool {
        return lhs === rhs
    }
}

/// Represents power-ups with enhanced visual effects
class PowerUp: GameComponent, Renderable, Collidable {
    private(set) var node: SKNode
    var isVisible: Bool = true
    var position: CGPoint {
        get { node.position }
        set { node.position = newValue }
    }

    private let type: PowerUpType
    private var collected = false

    init(type: PowerUpType) {
        self.type = type

        // Create power-up node with enhanced visuals
        let powerUpNode = SKShapeNode(circleOfRadius: 12)
        powerUpNode.fillColor = type.color.withAlphaComponent(0.8)
        powerUpNode.strokeColor = .white
        powerUpNode.lineWidth = 2
        powerUpNode.glowWidth = 3

        // Add symbol label based on type
        let symbol: String
        switch type {
        case .shield: symbol = "🛡️"
        case .speed: symbol = "⚡"
        case .magnet: symbol = "🧲"
        }

        let label = SKLabelNode(text: symbol)
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        powerUpNode.addChild(label)

        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 0.8, duration: 0.5)
        ])
        powerUpNode.run(SKAction.repeatForever(pulse))

        self.node = powerUpNode
        setupPhysics()
    }

    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(circleOfRadius: 12)
        physicsBody.categoryBitMask = PhysicsCategory.powerUp
        physicsBody.contactTestBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.isDynamic = false

        node.physicsBody = physicsBody
    }

    var physicsBody: SKPhysicsBody? {
        node.physicsBody
    }

    func handleCollision(with other: Collidable) {
        guard !collected else { return }
        collected = true

        // Add collection effect
        let collectEffect = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])
        node.run(collectEffect)

        // Notify game manager about collection
        NotificationCenter.default.post(
            name: NSNotification.Name("PowerUpCollected"),
            object: self,
            userInfo: ["type": type]
        )
    }

    func update(deltaTime: TimeInterval) {
        guard !collected else { return }
        // Move power-up from right to left
        node.position.x -= 80 * deltaTime
    }

    func reset() {
        collected = false
        isVisible = true
        node.alpha = 1.0
        node.setScale(1.0)
    }

    func activate() {
        // This method is called when the power-up is collected
        // The actual effect application is handled by the PlayerManager
        NotificationCenter.default.post(
            name: NSNotification.Name("PowerUpActivated"),
            object: self,
            userInfo: ["type": type]
        )
    }
}


