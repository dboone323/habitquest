//
// PlayerManager.swift
// AvoidObstaclesGame
//
// Manages the player character, including creation, movement, visual effects,
// and physics setup.
//

import CoreMotion
import SpriteKit
import UIKit

/// Protocol for player-related events
protocol PlayerDelegate: AnyObject {
    func playerDidMove(to position: CGPoint)
    func playerDidCollide(with obstacle: SKNode)
}

/// Manages the player character and its interactions
class PlayerManager {
    // MARK: - Properties

    /// Delegate for player events
    weak var delegate: PlayerDelegate?

    /// The player sprite node
    private(set) var player: SKSpriteNode?

    /// Player's current position
    var position: CGPoint {
        self.player?.position ?? .zero
    }

    /// Player's size
    var size: CGSize {
        self.player?.size ?? .zero
    }

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Player movement speed multiplier
    private let movementSpeed: CGFloat = 800.0 // points per second

    /// Player visual effects
    private var glowEffect: SKEffectNode?
    private var trailEffect: SKEmitterNode?

    /// Motion manager for tilt controls
    private let motionManager = CMMotionManager()

    /// Current tilt sensitivity
    private var tiltSensitivity: CGFloat = 0.5

    /// Whether tilt controls are enabled
    private var tiltControlsEnabled = false

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Player Creation

    /// Creates and configures the player node
    /// - Parameter position: Initial position for the player
    func createPlayer(at position: CGPoint) {
        // Create main player sprite
        player = SKSpriteNode(color: .systemBlue, size: CGSize(width: 50, height: 50))
        guard let player else { return }

        player.name = "player"
        player.position = position

        // Add rounded corners for better appearance
        let cornerRadius = player.size.width / 8
        let roundedPlayer = self.createRoundedPlayerNode(size: player.size, cornerRadius: cornerRadius)
        player.addChild(roundedPlayer)

        // Setup physics
        self.setupPlayerPhysics(for: player)

        // Add visual effects
        self.addGlowEffect(to: player)
        self.addTrailEffect(to: player)

        // Add to scene
        self.scene?.addChild(player)
    }

    /// Creates a rounded rectangle player node
    private func createRoundedPlayerNode(size: CGSize, cornerRadius: CGFloat) -> SKShapeNode {
        let path = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -size.width / 2, y: -size.height / 2),
                size: size
            ),
            cornerRadius: cornerRadius
        )
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.fillColor = .systemBlue
        shapeNode.strokeColor = .cyan
        shapeNode.lineWidth = 2
        shapeNode.glowWidth = 1
        return shapeNode
    }

    /// Sets up physics body for the player
    private func setupPlayerPhysics(for player: SKSpriteNode) {
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.powerUp
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = false
        player.physicsBody?.allowsRotation = false
    }

    // MARK: - Visual Effects

    /// Adds a glow effect to the player
    private func addGlowEffect(to player: SKSpriteNode) {
        glowEffect = SKEffectNode()
        guard let glowEffect else { return }

        glowEffect.shouldRasterize = true
        let glowFilter = CIFilter(name: "CIGaussianBlur")
        glowFilter?.setValue(3.0, forKey: kCIInputRadiusKey)
        glowEffect.filter = glowFilter

        let glowNode = SKSpriteNode(color: .cyan, size: CGSize(width: 55, height: 55))
        glowEffect.addChild(glowNode)
        glowEffect.zPosition = -1

        player.addChild(glowEffect)
    }

    /// Adds a trail effect behind the player
    private func addTrailEffect(to player: SKSpriteNode) {
        trailEffect = SKEmitterNode()
        guard let trailEffect else { return }

        // Create simple particle texture
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        let particleImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.cyan.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
        }

        trailEffect.particleTexture = SKTexture(image: particleImage)
        trailEffect.particleBirthRate = 20
        trailEffect.numParticlesToEmit = 50
        trailEffect.particleLifetime = 0.5
        trailEffect.particleLifetimeRange = 0.2
        trailEffect.particleScale = 0.5
        trailEffect.particleScaleRange = 0.2
        trailEffect.particleAlpha = 0.6
        trailEffect.particleAlphaSpeed = -1.0
        trailEffect.particleSpeed = 50
        trailEffect.emissionAngle = .pi
        trailEffect.emissionAngleRange = .pi / 4
        trailEffect.particleColor = .cyan
        trailEffect.particleBlendMode = .add
        trailEffect.zPosition = -2

        player.addChild(trailEffect)
    }

    // MARK: - Movement

    /// Moves the player to a target position with smooth animation
    /// - Parameter targetPosition: The target position to move to
    func moveTo(_ targetPosition: CGPoint) {
        guard let player, let scene else { return }

        // Constrain movement to screen bounds
        let halfWidth = player.size.width / 2
        let constrainedX = max(halfWidth, min(targetPosition.x, scene.size.width - halfWidth))
        let targetPoint = CGPoint(x: constrainedX, y: player.position.y)

        // Calculate distance and time for smooth movement
        let distance = abs(player.position.x - targetPoint.x)
        let duration = min(TimeInterval(distance / self.movementSpeed), 0.1)

        // Create smooth movement action
        let moveAction = SKAction.move(to: targetPoint, duration: duration)
        moveAction.timingMode = .easeOut

        player.run(moveAction, withKey: "playerMovement")

        // Notify delegate
        self.delegate?.playerDidMove(to: targetPoint)
    }

    /// Instantly moves the player to a position (for initialization)
    /// - Parameter position: The position to move to
    func setPosition(_ position: CGPoint) {
        self.player?.position = position
        self.delegate?.playerDidMove(to: position)
    }

    // MARK: - Collision Handling

    /// Handles collision with an obstacle
    /// - Parameter obstacle: The obstacle node that was hit
    func handleCollision(with obstacle: SKNode) {
        guard let player else { return }

        // Visual feedback for collision
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1),
        ])
        player.run(flashAction)

        // Notify delegate
        self.delegate?.playerDidCollide(with: obstacle)
    }

    // MARK: - Visual States

    /// Sets the player to hidden state
    func hide() {
        self.player?.isHidden = true
        self.trailEffect?.isHidden = true
    }

    /// Sets the player to visible state
    func show() {
        self.player?.isHidden = false
        self.trailEffect?.isHidden = false
    }

    /// Resets the player to initial state
    func reset() {
        self.player?.removeAllActions()
        self.player?.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0.1))
        self.show()
    }

    /// Applies a power-up effect to the player
    /// - Parameter type: The type of power-up effect
    func applyPowerUpEffect(_ type: PowerUpType) {
        guard self.player != nil else { return }

        switch type {
        case .shield:
            self.addShieldEffect()
        case .speed:
            self.addSpeedEffect()
        case .magnet:
            self.addMagnetEffect()
        }
    }

    /// Removes power-up effects from the player
    func removePowerUpEffects() {
        // Remove shield, speed, and magnet effects
        self.player?.childNode(withName: "shield")?.removeFromParent()
        self.player?.childNode(withName: "speedEffect")?.removeFromParent()
        self.player?.childNode(withName: "magnet")?.removeFromParent()
    }

    // MARK: - Power-up Effects

    private func addShieldEffect() {
        guard let player else { return }

        let shield = SKShapeNode(circleOfRadius: player.size.width / 2 + 10)
        shield.name = "shield"
        shield.fillColor = .clear
        shield.strokeColor = .green
        shield.lineWidth = 3
        shield.glowWidth = 2
        shield.zPosition = 10

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5),
        ])
        shield.run(SKAction.repeatForever(pulse))

        player.addChild(shield)
    }

    private func addSpeedEffect() {
        guard let player else { return }

        let speedEffect = SKShapeNode(circleOfRadius: player.size.width / 2 + 5)
        speedEffect.name = "speedEffect"
        speedEffect.fillColor = .clear
        speedEffect.strokeColor = .orange
        speedEffect.lineWidth = 2
        speedEffect.glowWidth = 1
        speedEffect.zPosition = 10

        // Rotating animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 1.0)
        speedEffect.run(SKAction.repeatForever(rotate))

        player.addChild(speedEffect)
    }

    private func addMagnetEffect() {
        guard let player else { return }

        let magnet = SKShapeNode(circleOfRadius: player.size.width / 2 + 15)
        magnet.name = "magnet"
        magnet.fillColor = .clear
        magnet.strokeColor = .purple
        magnet.lineWidth = 2
        magnet.glowWidth = 1
        magnet.zPosition = 10

        // Pulsing and rotating animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3),
        ])
        let rotate = SKAction.rotate(byAngle: .pi, duration: 0.6)
        let group = SKAction.group([pulse, rotate])
        magnet.run(SKAction.repeatForever(group))

        player.addChild(magnet)
    }

    // MARK: - Cleanup

    /// Enables tilt-based movement controls
    /// - Parameter sensitivity: Sensitivity multiplier for tilt controls (0.1 to 2.0)
    func enableTiltControls(sensitivity: CGFloat = 0.5) {
        self.tiltSensitivity = max(0.1, min(sensitivity, 2.0))
        self.tiltControlsEnabled = true

        // Start motion updates
        if self.motionManager.isDeviceMotionAvailable {
            self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 FPS
            self.motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, error in
                guard let self, let motion, error == nil, tiltControlsEnabled else { return }
                self.handleMotionUpdate(motion)
            }
        }
    }

    /// Disables tilt-based movement controls
    func disableTiltControls() {
        self.tiltControlsEnabled = false
        self.motionManager.stopDeviceMotionUpdates()
    }

    /// Handles device motion updates for tilt controls
    /// - Parameter motion: The device motion data
    private func handleMotionUpdate(_ motion: CMDeviceMotion) {
        guard let player, let scene, tiltControlsEnabled else { return }

        // Use roll (tilting left/right) for horizontal movement
        let roll = CGFloat(motion.attitude.roll)

        // Convert roll to movement delta
        // Roll ranges from -π/2 to π/2, we want to map this to screen movement
        let maxRoll: CGFloat = .pi / 3 // About 60 degrees
        let normalizedRoll = max(-maxRoll, min(roll, maxRoll)) / maxRoll // -1 to 1

        // Calculate target position based on tilt
        let screenCenterX = scene.size.width / 2
        let maxOffset = scene.size.width / 3 // Allow movement within 1/3 of screen width
        let targetX = screenCenterX + (normalizedRoll * maxOffset * self.tiltSensitivity)

        // Constrain to screen bounds
        let halfWidth = player.size.width / 2
        let constrainedX = max(halfWidth, min(targetX, scene.size.width - halfWidth))

        let targetPosition = CGPoint(x: constrainedX, y: player.position.y)

        // Smooth movement towards target position
        let distance = abs(player.position.x - targetPosition.x)
        if distance > 1.0 { // Only move if significant change
            let duration = min(TimeInterval(distance / (movementSpeed * 0.5)), 0.05) // Faster response for tilt
            let moveAction = SKAction.move(to: targetPosition, duration: duration)
            moveAction.timingMode = .easeOut
            player.run(moveAction, withKey: "tiltMovement")

            self.delegate?.playerDidMove(to: targetPosition)
        }
    }

    // MARK: - Async Player Management

    /// Creates and configures the player node asynchronously
    /// - Parameter position: Initial position for the player
    func createPlayerAsync(at position: CGPoint) async {
        await Task.detached {
            self.createPlayer(at: position)
        }.value
    }

    /// Moves the player to a target position with smooth animation asynchronously
    /// - Parameter targetPosition: The target position to move to
    func moveToAsync(_ targetPosition: CGPoint) async {
        await Task.detached {
            self.moveTo(targetPosition)
        }.value
    }

    /// Instantly moves the player to a position asynchronously (for initialization)
    /// - Parameter position: The position to move to
    func setPositionAsync(_ position: CGPoint) async {
        await Task.detached {
            self.setPosition(position)
        }.value
    }

    /// Handles collision with an obstacle asynchronously
    /// - Parameter obstacle: The obstacle node that was hit
    func handleCollisionAsync(with obstacle: SKNode) async {
        await Task.detached {
            self.handleCollision(with: obstacle)
        }.value
    }

    /// Sets the player to hidden state asynchronously
    func hideAsync() async {
        await Task.detached {
            self.hide()
        }.value
    }

    /// Sets the player to visible state asynchronously
    func showAsync() async {
        await Task.detached {
            self.show()
        }.value
    }

    /// Resets the player to initial state asynchronously
    func resetAsync() async {
        await Task.detached {
            self.reset()
        }.value
    }

    /// Applies a power-up effect to the player asynchronously
    /// - Parameter type: The type of power-up effect
    func applyPowerUpEffectAsync(_ type: PowerUpType) async {
        await Task.detached {
            self.applyPowerUpEffect(type)
        }.value
    }

    /// Removes power-up effects from the player asynchronously
    func removePowerUpEffectsAsync() async {
        await Task.detached {
            self.removePowerUpEffects()
        }.value
    }

    /// Enables tilt-based movement controls asynchronously
    /// - Parameter sensitivity: Sensitivity multiplier for tilt controls (0.1 to 2.0)
    func enableTiltControlsAsync(sensitivity: CGFloat = 0.5) async {
        await Task.detached {
            self.enableTiltControls(sensitivity: sensitivity)
        }.value
    }

    /// Disables tilt-based movement controls asynchronously
    func disableTiltControlsAsync() async {
        await Task.detached {
            self.disableTiltControls()
        }.value
    }
}

/// Types of power-ups available
public enum PowerUpType: CaseIterable {
    case shield
    case speed
    case magnet

    var color: UIColor {
        switch self {
        case .shield: .blue
        case .speed: .green
        case .magnet: .yellow
        }
    }
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
