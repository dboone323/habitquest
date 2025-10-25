// MARK: - Core Game Entities and Protocols

// Unified UI/UX improvements for AvoidObstaclesGame
// Implements AI-recommended architecture for better game management

import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

// MARK: - Core Enums

/// Movement directions for player input
public enum MovementDirection: String, Codable, Sendable {
    case left, right, up, down

    var displayName: String {
        switch self {
        case .left: return "Left"
        case .right: return "Right"
        case .up: return "Up"
        case .down: return "Down"
        }
    }
}

/// Game actions for special inputs
enum GameAction {
    case jump, pause, menu
}

// MARK: - Core Protocols

/// Protocol for all game components that need updates
@MainActor
protocol GameComponent: AnyObject {
    func update(deltaTime: TimeInterval)
    func reset()
}

/// Protocol for objects that can be rendered on screen
@MainActor
protocol Renderable {
    var node: SKNode { get }
    var isVisible: Bool { get set }
}

/// Protocol for objects that can collide
@MainActor
protocol Collidable {
    var physicsBody: SKPhysicsBody? { get }
    func handleCollision(with other: Collidable)
}

// MARK: - Core Game Entities

/// Represents the player character with enhanced UI feedback
@MainActor
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
        playerNode.fillColor = SKColor.blue
        playerNode.strokeColor = SKColor.white
        playerNode.lineWidth = 2
        playerNode.glowWidth = 1

        // Add subtle glow effect using blend mode
        playerNode.blendMode = .add

        self.node = playerNode

        setupPhysics()
        setupTrailEffect()
        reset()
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

        if let trail {
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
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1),
        ])
        node.run(flash)

        // Add screen shake effect
        if let scene = node.scene {
            let shake = SKAction.sequence([
                SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                SKAction.moveBy(x: 5, y: 0, duration: 0.05),
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
@MainActor
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
        case spike, block, moving, pulsing, rotating, bouncing, teleporting, splitting, laser

        var color: SKColor {
            switch self {
            case .spike: return .red
            case .block: return .orange
            case .moving: return .purple
            case .pulsing: return .green
            case .rotating: return .blue
            case .bouncing: return .yellow
            case .teleporting: return .cyan
            case .splitting: return .magenta
            case .laser: return .white
            }
        }

        var size: CGSize {
            switch self {
            case .spike: return CGSize(width: 20, height: 40)
            case .block: return CGSize(width: 30, height: 30)
            case .moving: return CGSize(width: 25, height: 25)
            case .pulsing: return CGSize(width: 35, height: 35)
            case .rotating: return CGSize(width: 28, height: 28)
            case .bouncing: return CGSize(width: 32, height: 32)
            case .teleporting: return CGSize(width: 26, height: 26)
            case .splitting: return CGSize(width: 40, height: 40)
            case .laser: return CGSize(width: 100, height: 8)
            }
        }

        var hasSpecialBehavior: Bool {
            switch self {
            case .spike, .block: return false
            case .moving, .pulsing, .rotating, .bouncing, .teleporting, .splitting, .laser: return true
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

        case .block, .moving, .pulsing, .rotating, .bouncing, .teleporting, .splitting:
            let shape = SKShapeNode(rectOf: type.size)
            shape.fillColor = type.color
            shape.strokeColor = .white
            shape.lineWidth = 1
            obstacleNode = shape

        case .laser:
            let shape = SKShapeNode(rectOf: type.size)
            shape.fillColor = type.color
            shape.strokeColor = .red
            shape.lineWidth = 2
            shape.glowWidth = 2
            obstacleNode = shape
        }

        self.node = obstacleNode
        setupPhysics()
        setupSpecialBehavior()
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

        case .block, .moving, .pulsing, .rotating, .bouncing, .teleporting, .splitting:
            physicsBody = SKPhysicsBody(rectangleOf: obstacleType.size)

        case .laser:
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

    private func setupSpecialBehavior() {
        switch obstacleType {
        case .pulsing:
            setupPulsingBehavior()
        case .rotating:
            setupRotatingBehavior()
        case .bouncing:
            setupBouncingBehavior()
        case .teleporting:
            setupTeleportingBehavior()
        case .laser:
            setupLaserBehavior()
        default:
            break // No special behavior for spike, block, moving, splitting
        }
    }

    private func setupPulsingBehavior() {
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.8),
            SKAction.scale(to: 0.7, duration: 0.8),
        ])
        node.run(SKAction.repeatForever(pulseAction))
    }

    private func setupRotatingBehavior() {
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
        node.run(SKAction.repeatForever(rotateAction))
    }

    private func setupBouncingBehavior() {
        let bounceAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 30, duration: 0.5),
            SKAction.moveBy(x: 0, y: -30, duration: 0.5),
        ])
        node.run(SKAction.repeatForever(bounceAction))
    }

    private func setupTeleportingBehavior() {
        let teleportAction = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 2.0),
        ])
        node.run(SKAction.repeatForever(teleportAction))
    }

    private func setupLaserBehavior() {
        // Laser obstacles pulse with a warning glow
        let laserPulse = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.3),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.3),
        ])
        node.run(SKAction.repeatForever(laserPulse))
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

        // Handle special behaviors
        updateSpecialBehavior(deltaTime)
    }

    private func updateSpecialBehavior(_ deltaTime: TimeInterval) {
        switch obstacleType {
        case .teleporting:
            // Teleporting obstacles change position randomly
            if Double.random(in: 0 ..< 1) < 0.02 { // 2% chance per frame
                if let scene = node.scene {
                    let newY = CGFloat.random(in: 50 ... (scene.frame.height - 50))
                    node.position.y = newY
                }
            }
        case .splitting:
            // Splitting obstacles occasionally spawn smaller obstacles
            if Double.random(in: 0 ..< 1) < 0.01 { // 1% chance per frame
                spawnSplitObstacle()
            }
        default:
            break
        }
    }

    private func spawnSplitObstacle() {
        // This would need to be handled by the ObstacleManager
        // For now, just add a visual effect
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1),
        ])
        node.run(flash)
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

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    nonisolated static func == (lhs: Obstacle, rhs: Obstacle) -> Bool {
        lhs === rhs
    }
}

// MARK: - Boss Battle System

/// Represents a boss enemy with complex behaviors and multiple phases
@MainActor
class Boss: GameComponent, Renderable, Collidable, Hashable {
    private(set) var node: SKNode
    var isVisible: Bool = true
    var position: CGPoint {
        get { node.position }
        set { node.position = newValue }
    }

    private(set) var health: CGFloat
    private let maxHealth: CGFloat
    private(set) var currentPhase: BossPhase = .phase1
    private var attackTimer: TimeInterval = 0
    private var phaseTimer: TimeInterval = 0
    private var isInvulnerable: Bool = false
    private var invulnerabilityTimer: TimeInterval = 0

    let bossType: BossType

    enum BossType: String, CaseIterable {
        case guardian = "Guardian"
        case destroyer = "Destroyer"
        case overlord = "Overlord"

        var displayName: String {
            rawValue
        }

        var maxHealth: CGFloat {
            switch self {
            case .guardian: return 1000
            case .destroyer: return 1500
            case .overlord: return 2000
            }
        }

        var size: CGSize {
            switch self {
            case .guardian: return CGSize(width: 80, height: 120)
            case .destroyer: return CGSize(width: 100, height: 140)
            case .overlord: return CGSize(width: 120, height: 160)
            }
        }

        var color: SKColor {
            switch self {
            case .guardian: return .purple
            case .destroyer: return .red
            case .overlord: return .black
            }
        }
    }

    enum BossPhase {
        case phase1, phase2, phase3, defeated

        var healthThreshold: CGFloat {
            switch self {
            case .phase1: return 1.0
            case .phase2: return 0.7
            case .phase3: return 0.3
            case .defeated: return 0.0
            }
        }

        var attackSpeed: TimeInterval {
            switch self {
            case .phase1: return 2.0
            case .phase2: return 1.5
            case .phase3: return 1.0
            case .defeated: return 0.0
            }
        }
    }

    init(type: BossType) {
        self.bossType = type
        self.maxHealth = type.maxHealth
        self.health = type.maxHealth

        // Create boss node with enhanced visuals
        let bossNode = SKShapeNode(rectOf: type.size)
        bossNode.fillColor = type.color
        bossNode.strokeColor = .white
        bossNode.lineWidth = 3
        bossNode.glowWidth = 5

        self.node = bossNode

        // Add health bar after node is initialized
        let healthBar = createHealthBar()
        bossNode.addChild(healthBar)

        setupPhysics()
        setupAnimations()
    }

    private func createHealthBar() -> SKNode {
        let healthBarContainer = SKShapeNode(rectOf: CGSize(width: bossType.size.width + 20, height: 10))
        healthBarContainer.fillColor = .black
        healthBarContainer.strokeColor = .white
        healthBarContainer.lineWidth = 1
        healthBarContainer.position = CGPoint(x: 0, y: bossType.size.height / 2 + 15)

        let healthBarFill = SKShapeNode(rectOf: CGSize(width: bossType.size.width, height: 8))
        healthBarFill.fillColor = .green
        healthBarFill.strokeColor = .clear
        healthBarFill.position = CGPoint(x: 0, y: bossType.size.height / 2 + 15)
        healthBarFill.name = "healthBar"

        healthBarContainer.addChild(healthBarFill)
        return healthBarContainer
    }

    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(rectangleOf: bossType.size)
        physicsBody.categoryBitMask = PhysicsCategory.boss
        physicsBody.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.powerUp
        physicsBody.collisionBitMask = PhysicsCategory.player
        physicsBody.isDynamic = false
        physicsBody.restitution = 0.0
        physicsBody.friction = 0.0

        node.physicsBody = physicsBody
    }

    @MainActor
    private func setupAnimations() {
        // Add breathing animation
        let breatheAction = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 0.95, duration: 1.0),
        ])
        node.run(SKAction.repeatForever(breatheAction))

        // Add glow pulsing
        let glowAction = SKAction.sequence([
            SKAction.run { [weak self] in
                if let shapeNode = self?.node as? SKShapeNode {
                    shapeNode.glowWidth = 10
                }
            },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                if let shapeNode = self?.node as? SKShapeNode {
                    shapeNode.glowWidth = 5
                }
            },
            SKAction.wait(forDuration: 0.5),
        ])
        node.run(SKAction.repeatForever(glowAction))
    }

    var physicsBody: SKPhysicsBody? {
        node.physicsBody
    }

    func takeDamage(_ damage: CGFloat) {
        guard !isInvulnerable else { return }

        health = max(0, health - damage)
        updateHealthBar()

        // Visual feedback
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1),
        ])
        node.run(flashAction)

        // Become temporarily invulnerable
        // isInvulnerable = true
        // invulnerabilityTimer = 0.5

        // Check for phase transitions
        updatePhase()
    }

    private func updateHealthBar() {
        guard let healthBar = node.childNode(withName: "healthBar") as? SKShapeNode else { return }

        let healthPercentage = health / maxHealth
        let barWidth = bossType.size.width * healthPercentage

        let newSize = CGSize(width: max(0, barWidth), height: 8)
        let updateAction = SKAction.run {
            healthBar.path = CGPath(rect: CGRect(origin: CGPoint(x: -newSize.width / 2, y: -newSize.height / 2), size: newSize), transform: nil)

            // Change color based on health
            if healthPercentage > 0.6 {
                healthBar.fillColor = .green
            } else if healthPercentage > 0.3 {
                healthBar.fillColor = .yellow
            } else {
                healthBar.fillColor = .red
            }
        }
        healthBar.run(updateAction)
    }

    private func updatePhase() {
        let healthPercentage = health / maxHealth

        if healthPercentage <= BossPhase.phase3.healthThreshold && currentPhase == .phase2 {
            enterPhase(.phase3)
        } else if healthPercentage <= BossPhase.phase2.healthThreshold && currentPhase == .phase1 {
            enterPhase(.phase2)
        } else if health <= 0 && currentPhase != .defeated {
            enterPhase(.defeated)
        }
    }

    private func enterPhase(_ phase: BossPhase) {
        currentPhase = phase

        switch phase {
        case .phase2:
            phase2Transition()
        case .phase3:
            phase3Transition()
        case .defeated:
            defeatSequence()
        default:
            break
        }
    }

    private func phase2Transition() {
        // Enhanced visuals for phase 2
        let colorAction = SKAction.colorize(with: .orange, colorBlendFactor: 0.3, duration: 1.0)
        node.run(colorAction)

        // Increase glow
        if let shapeNode = node as? SKShapeNode {
            shapeNode.glowWidth = 8
        }
    }

    private func phase3Transition() {
        // Enhanced visuals for phase 3
        let colorAction = SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 1.0)
        node.run(colorAction)

        // Maximum glow
        if let shapeNode = node as? SKShapeNode {
            shapeNode.glowWidth = 12
        }
    }

    private func defeatSequence() {
        // Victory animation
        let defeatAction = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.5),
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent(),
        ])
        node.run(defeatAction)
    }

    func performAttack() -> BossAttack? {
        guard currentPhase != .defeated else { return nil }

        switch bossType {
        case .guardian:
            return performGuardianAttack()
        case .destroyer:
            return performDestroyerAttack()
        case .overlord:
            return performOverlordAttack()
        }
    }

    private func performGuardianAttack() -> BossAttack {
        switch currentPhase {
        case .phase1:
            return .laserBeam
        case .phase2:
            return .spikeWave
        case .phase3:
            return Bool.random() ? .laserBeam : .spikeWave
        default:
            return .laserBeam
        }
    }

    private func performDestroyerAttack() -> BossAttack {
        switch currentPhase {
        case .phase1:
            return .projectileBarrage
        case .phase2:
            return .shockwave
        case .phase3:
            return Bool.random() ? .projectileBarrage : .shockwave
        default:
            return .projectileBarrage
        }
    }

    private func performOverlordAttack() -> BossAttack {
        switch currentPhase {
        case .phase1:
            return .minionSpawn
        case .phase2:
            return .teleportStrike
        case .phase3:
            let attacks: [BossAttack] = [.minionSpawn, .teleportStrike, .ultimateAttack]
            return attacks.randomElement()!
        default:
            return .minionSpawn
        }
    }

    func handleCollision(with other: Collidable) {
        // Boss reacts to player collisions
        if other is Player {
            // Damage player or trigger special effect
            let damageAction = SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.2),
                SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2),
            ])
            node.run(damageAction)
        }
    }

    func update(deltaTime: TimeInterval) {
        attackTimer += deltaTime
        phaseTimer += deltaTime

        if isInvulnerable {
            invulnerabilityTimer -= deltaTime
            if invulnerabilityTimer <= 0 {
                isInvulnerable = false
            }
        }

        // Update visual effects based on phase
        updatePhaseEffects(deltaTime)
    }

    private func updatePhaseEffects(_ deltaTime: TimeInterval) {
        // Add phase-specific visual effects
        switch currentPhase {
        case .phase2:
            // Pulsing effect
            let pulse = sin(phaseTimer * 4) * 0.1 + 1.0
            node.xScale = pulse
            node.yScale = pulse
        case .phase3:
            // More intense pulsing
            let pulse = sin(phaseTimer * 6) * 0.2 + 1.0
            node.xScale = pulse
            node.yScale = pulse
        default:
            node.xScale = 1.0
            node.yScale = 1.0
        }
    }

    func reset() {
        health = maxHealth
        currentPhase = .phase1
        attackTimer = 0
        phaseTimer = 0
        isInvulnerable = false
        invulnerabilityTimer = 0
        isVisible = true

        // Reset visual state
        node.alpha = 1.0
        if let shapeNode = node as? SKShapeNode {
            shapeNode.glowWidth = 5
        }
        node.removeAllActions()
        setupAnimations()

        updateHealthBar()
    }

    // MARK: - Hashable Conformance

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    nonisolated static func == (lhs: Boss, rhs: Boss) -> Bool {
        lhs === rhs
    }
}

/// Types of boss attacks
enum BossAttack {
    case laserBeam
    case spikeWave
    case projectileBarrage
    case shockwave
    case minionSpawn
    case teleportStrike
    case ultimateAttack
}
