//
// PlayerManager.swift
// AvoidObstaclesGame
//
// Manages the player character, including creation, movement, visual effects,
// and physics setup.
//

import CoreMotion
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Protocol for player-related events
@MainActor
protocol PlayerDelegate: AnyObject {
    func playerDidMove(to position: CGPoint)
    func playerDidCollide(with obstacle: SKNode)
}

/// Manages the player character and its interactions
@MainActor
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

    /// Reference to the game state manager for score/time management
    private weak var gameStateManager: GameStateManager?

    /// Player movement speed multiplier
    private let movementSpeed: CGFloat = 800.0 // points per second

    /// Player visual effects
    private var glowEffect: SKEffectNode?
    private var trailEffect: SKEmitterNode?

    /// Motion manager for tilt controls (iOS/tvOS only)
    #if os(iOS) || os(tvOS)
        private let motionManager = CMMotionManager()
    #endif

    /// Current tilt sensitivity
    private var tiltSensitivity: CGFloat = 0.5

    /// Whether tilt controls are enabled
    private var tiltControlsEnabled = false

    /// Active movement directions for keyboard/gamepad input
    private var activeMovementDirections: Set<MovementDirection> = []

    // MARK: - Initialization

    init(scene: SKScene, gameStateManager: GameStateManager) {
        self.scene = scene
        self.gameStateManager = gameStateManager
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    /// Updates the player manager with delta time
    /// - Parameter deltaTime: Time elapsed since last update
    func update(_ deltaTime: TimeInterval) {
        // Handle continuous movement from active directions
        applyMovementDirections(deltaTime)

        // Update player-specific logic here
        // For now, this is mainly for future expansion
    }

    /// Sets a movement direction as active or inactive
    /// - Parameters:
    ///   - direction: The movement direction to set
    ///   - active: Whether the direction should be active
    func setMovementDirection(_ direction: MovementDirection, active: Bool) {
        if active {
            activeMovementDirections.insert(direction)
        } else {
            activeMovementDirections.remove(direction)
        }
    }

    /// Applies movement based on currently active directions
    /// - Parameter deltaTime: Time elapsed since last update
    private func applyMovementDirections(_ deltaTime: TimeInterval) {
        guard let player, let scene else { return }

        // Calculate movement vector from active directions
        var movementVector = CGVector.zero

        for direction in activeMovementDirections {
            switch direction {
            case .left:
                movementVector.dx -= 1
            case .right:
                movementVector.dx += 1
            case .up:
                movementVector.dy += 1
            case .down:
                movementVector.dy -= 1
            }
        }

        // Normalize diagonal movement
        if movementVector != .zero {
            let length = sqrt(movementVector.dx * movementVector.dx + movementVector.dy * movementVector.dy)
            movementVector.dx /= length
            movementVector.dy /= length

            // Apply movement
            let movement = CGVector(
                dx: movementVector.dx * movementSpeed * deltaTime,
                dy: movementVector.dy * movementSpeed * deltaTime
            )

            player.position.x += movement.dx
            player.position.y += movement.dy

            // Constrain to screen bounds
            let halfWidth = player.size.width / 2
            let halfHeight = player.size.height / 2
            player.position.x = max(halfWidth, min(scene.size.width - halfWidth, player.position.x))
            player.position.y = max(halfHeight, min(scene.size.height - halfHeight, player.position.y))

            // Notify delegate of movement
            self.delegate?.playerDidMove(to: player.position)
        }
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
        #if os(iOS) || os(tvOS)
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
        #else
            // macOS fallback - use simple rectangle
            let shapeNode = SKShapeNode(rectOf: size)
            shapeNode.fillColor = .blue
            shapeNode.strokeColor = .cyan
        #endif
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
        #if os(iOS) || os(tvOS)
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
            let particleImage = renderer.image { context in
                context.cgContext.setFillColor(UIColor.cyan.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
            }
            trailEffect.particleTexture = SKTexture(image: particleImage)
        #else
            // macOS fallback - use simple colored texture
            let particleImage = NSImage(size: NSSize(width: 4, height: 4))
            particleImage.lockFocus()
            NSColor.cyan.setFill()
            NSRect(origin: .zero, size: NSSize(width: 4, height: 4)).fill()
            particleImage.unlockFocus()
            trailEffect.particleTexture = SKTexture(image: particleImage)
        #endif

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
        case .slowMotion:
            self.addSlowMotionEffect()
        case .multiBall:
            self.addMultiBallEffect()
        case .laser:
            self.addLaserEffect()
        case .freeze:
            self.addFreezeEffect()
        case .teleport:
            self.addTeleportEffect()
        case .scoreMultiplier:
            self.addScoreMultiplierEffect()
        case .timeBonus:
            self.addTimeBonusEffect()
        }
    }

    /// Removes power-up effects from the player
    @MainActor
    func removePowerUpEffects() {
        // Remove shield, speed, and magnet effects
        self.player?.childNode(withName: "shield")?.removeFromParent()
        self.player?.childNode(withName: "speedEffect")?.removeFromParent()
        self.player?.childNode(withName: "magnet")?.removeFromParent()
        self.player?.childNode(withName: "slowMotion")?.removeFromParent()
        self.player?.childNode(withName: "multiBall")?.removeFromParent()
        self.player?.childNode(withName: "laser")?.removeFromParent()
        self.player?.childNode(withName: "freeze")?.removeFromParent()
        self.player?.childNode(withName: "teleport")?.removeFromParent()
        self.player?.childNode(withName: "scoreMultiplier")?.removeFromParent()
        self.player?.childNode(withName: "timeBonus")?.removeFromParent()
    }

    // MARK: - Power-up Effects

    @MainActor
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

    @MainActor
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

    @MainActor
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

    @MainActor
    private func addSlowMotionEffect() {
        // Implement slow motion effect (e.g., by adjusting the scene's speed)
        guard let scene else { return }

        scene.isPaused = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            scene.isPaused = false
        }
    }

    @MainActor
    private func addMultiBallEffect() {
        guard let player else { return }

        // Create multiple player instances
        for _ in 0 ..< 3 {
            let clone = player.copy() as! SKSpriteNode
            clone.name = "multiBall"
            clone.position = player.position
            clone.physicsBody = player.physicsBody?.copy() as? SKPhysicsBody

            // Add to scene and run random movement
            self.scene?.addChild(clone)
            let randomX = CGFloat.random(in: -200 ... 200)
            let randomY = CGFloat.random(in: -200 ... 200)
            clone.run(SKAction.move(by: CGVector(dx: randomX, dy: randomY), duration: 2.0))
        }
    }

    @MainActor
    private func addLaserEffect() {
        guard let player else { return }

        let laser = SKSpriteNode(color: .red, size: CGSize(width: 10, height: 10))
        laser.name = "laser"
        laser.position = player.position
        laser.zPosition = 10

        // Laser beam effect
        let beam = SKShapeNode(rectOf: CGSize(width: 2, height: 100))
        beam.fillColor = .red
        beam.position = CGPoint(x: 0, y: -60)
        beam.zPosition = 1

        laser.addChild(beam)
        self.scene?.addChild(laser)

        // Move laser forward
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -1000), duration: 1.0)
        laser.run(moveAction)

        // Remove laser after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            laser.removeFromParent()
        }
    }

    @MainActor
    private func addFreezeEffect() {
        // Implement freeze effect (e.g., by freezing all obstacles)
        for obstacle in self.scene?.children.filter({ $0.name == "obstacle" }) ?? [] {
            obstacle.isPaused = true
        }

        // Thaw after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            for obstacle in self.scene?.children.filter({ $0.name == "obstacle" }) ?? [] {
                obstacle.isPaused = false
            }
        }
    }

    @MainActor
    private func addTeleportEffect() {
        guard let player, let scene else { return }

        // Random teleport within scene bounds
        let randomX = CGFloat.random(in: player.size.width / 2 ... (scene.size.width - player.size.width / 2))
        let randomY = CGFloat.random(in: player.size.height / 2 ... (scene.size.height - player.size.height / 2))
        let targetPosition = CGPoint(x: randomX, y: randomY)

        player.position = targetPosition
    }

    @MainActor
    private func addScoreMultiplierEffect() {
        // Implement score multiplier effect (e.g., by doubling the score for a duration)
        self.gameStateManager?.setScoreMultiplier(2)

        // Reset multiplier after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) { [weak self] in
            self?.gameStateManager?.resetScoreMultiplier()
        }
    }

    @MainActor
    private func addTimeBonusEffect() {
        // Implement time bonus effect (e.g., by adding extra time to the game timer)
        self.gameStateManager?.addBonusTime(10) // Add 10 seconds
    }

    // MARK: - Cleanup

    /// Enables tilt-based movement controls (iOS/tvOS only)
    /// - Parameter sensitivity: Sensitivity multiplier for tilt controls (0.1 to 2.0)
    func enableTiltControls(sensitivity: CGFloat = 0.5) {
        #if os(iOS) || os(tvOS)
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
        #endif
    }

    /// Disables tilt-based movement controls
    func disableTiltControls() {
        #if os(iOS) || os(tvOS)
            self.tiltControlsEnabled = false
            self.motionManager.stopDeviceMotionUpdates()
        #endif
    }

    /// Handles device motion updates for tilt controls
    /// - Parameter motion: The device motion data
    @MainActor
    private func handleMotionUpdate(_ motion: CMDeviceMotion) {
        #if os(iOS) || os(tvOS)
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
        #endif
    }

    // MARK: - Async Player Management

    /// Creates and configures the player node asynchronously
    /// - Parameter position: Initial position for the player
    @MainActor
    func createPlayerAsync(at position: CGPoint) async {
        createPlayer(at: position)
    }

    /// Moves the player to a target position with smooth animation asynchronously
    /// - Parameter targetPosition: The target position to move to
    @MainActor
    func moveToAsync(_ targetPosition: CGPoint) async {
        moveTo(targetPosition)
    }

    /// Instantly moves the player to a position asynchronously (for initialization)
    /// - Parameter position: The position to move to
    @MainActor
    func setPositionAsync(_ position: CGPoint) async {
        setPosition(position)
    }

    /// Handles collision with an obstacle asynchronously
    /// - Parameter obstacle: The obstacle node that was hit
    @MainActor
    func handleCollisionAsync(with obstacle: SKNode) async {
        handleCollision(with: obstacle)
    }

    /// Sets the player to hidden state asynchronously
    @MainActor
    func hideAsync() async {
        hide()
    }

    /// Sets the player to visible state asynchronously
    @MainActor
    func showAsync() async {
        show()
    }

    /// Resets the player to initial state asynchronously
    @MainActor
    func resetAsync() async {
        reset()
    }

    /// Applies a power-up effect to the player asynchronously
    /// - Parameter type: The type of power-up effect
    @MainActor
    func applyPowerUpEffectAsync(_ type: PowerUpType) async {
        applyPowerUpEffect(type)
    }

    /// Removes power-up effects from the player asynchronously
    @MainActor
    func removePowerUpEffectsAsync() async {
        removePowerUpEffects()
    }

    /// Enables tilt-based movement controls asynchronously
    /// - Parameter sensitivity: Sensitivity multiplier for tilt controls (0.1 to 2.0)
    @MainActor
    func enableTiltControlsAsync(sensitivity: CGFloat = 0.5) async {
        enableTiltControls(sensitivity: sensitivity)
    }

    /// Disables tilt-based movement controls asynchronously
    @MainActor
    func disableTiltControlsAsync() async {
        disableTiltControls()
    }

    // MARK: - Touch Input Handling

    /// Handles touch input at a specific location
    /// - Parameter location: The touch location in scene coordinates
    func handleTouch(at location: CGPoint) {
        // For touch input, move player towards the touch location
        moveTo(location)
    }

    /// Handles touch release at a specific location
    /// - Parameter location: The touch release location in scene coordinates
    func handleTouchRelease(at location: CGPoint) {
        // For now, touch release doesn't need special handling
        // Could be used for different input modes in the future
    }

    // MARK: - Advanced Gesture Methods

    /// Activates dash ability
    func activateDash() {
        guard let player else { return }

        // Quick dash forward
        let dashDistance: CGFloat = 150
        let dashAction = SKAction.move(by: CGVector(dx: 0, dy: dashDistance), duration: 0.2)
        dashAction.timingMode = .easeOut
        player.run(dashAction)

        // Visual feedback
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1),
        ])
        player.run(flashAction)

        self.delegate?.playerDidMove(to: player.position)
    }

    /// Activates shield ability
    func activateShield() {
        applyPowerUpEffect(.shield)
    }

    /// Sets diagonal movement direction
    /// - Parameters:
    ///   - vertical: Vertical direction component
    ///   - horizontal: Horizontal direction component
    ///   - active: Whether to activate or deactivate the movement
    func setDiagonalMovement(_ vertical: MovementDirection, _ horizontal: MovementDirection, active: Bool) {
        // For diagonal movement, we need to handle both directions simultaneously
        if active {
            activeMovementDirections.insert(vertical)
            activeMovementDirections.insert(horizontal)
        } else {
            activeMovementDirections.remove(vertical)
            activeMovementDirections.remove(horizontal)
        }
    }

    /// Activates super jump ability
    func activateSuperJump() {
        guard let player else { return }

        // Super jump upward
        let jumpDistance: CGFloat = 200
        let jumpAction = SKAction.move(by: CGVector(dx: 0, dy: jumpDistance), duration: 0.3)
        jumpAction.timingMode = .easeOut
        player.run(jumpAction)

        // Visual feedback
        let scaleAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.2),
        ])
        player.run(scaleAction)

        self.delegate?.playerDidMove(to: player.position)
    }

    /// Activates spin attack ability
    func activateSpinAttack() {
        guard let player else { return }

        // Spin animation
        let spinAction = SKAction.rotate(byAngle: .pi * 4, duration: 0.5)
        spinAction.timingMode = .easeOut
        player.run(spinAction)

        // Visual feedback
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.3, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.2),
        ])
        player.run(flashAction)
    }

    /// Activates powerful attack
    func activatePowerfulAttack() {
        applyPowerUpEffect(.laser)
    }

    /// Activates normal attack
    func activateNormalAttack() {
        // Simple attack - could create a projectile or effect
        guard let player, let scene else { return }

        let projectile = SKSpriteNode(color: .yellow, size: CGSize(width: 10, height: 10))
        projectile.position = player.position
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.player
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.affectedByGravity = false

        scene.addChild(projectile)

        // Move projectile forward
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 300), duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([moveAction, removeAction]))
    }

    /// Activates defensive ability
    func activateDefensiveAbility() {
        applyPowerUpEffect(.shield)
    }

    /// Activates offensive ability
    func activateOffensiveAbility() {
        applyPowerUpEffect(.laser)
    }

    /// Activates directional dash
    /// - Parameter direction: Direction to dash in
    func activateDirectionalDash(_ direction: SwipeDirection) {
        guard let player else { return }

        let dashDistance: CGFloat = 120
        var dashVector = CGVector.zero

        switch direction {
        case .up:
            dashVector = CGVector(dx: 0, dy: dashDistance)
        case .down:
            dashVector = CGVector(dx: 0, dy: -dashDistance)
        case .left:
            dashVector = CGVector(dx: -dashDistance, dy: 0)
        case .right:
            dashVector = CGVector(dx: dashDistance, dy: 0)
        }

        let dashAction = SKAction.move(by: dashVector, duration: 0.15)
        dashAction.timingMode = .easeOut
        player.run(dashAction)

        // Visual feedback
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.4, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1),
        ])
        player.run(flashAction)

        self.delegate?.playerDidMove(to: player.position)
    }

    /// Activates ultimate ability
    func activateUltimateAbility() {
        // Combine multiple effects for ultimate ability
        applyPowerUpEffect(.multiBall)
        applyPowerUpEffect(.laser)
        applyPowerUpEffect(.shield)

        // Visual feedback
        guard let player else { return }
        let ultimateAction = SKAction.sequence([
            SKAction.colorize(with: .purple, colorBlendFactor: 0.6, duration: 0.2),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.3),
        ])
        player.run(ultimateAction)
    }

    /// Gets the player's current position
    var playerPosition: CGPoint {
        player?.position ?? .zero
    }
}

/// Types of power-ups available
public enum PowerUpType: String, CaseIterable, Sendable, Codable {
    case shield
    case speed
    case magnet
    case slowMotion
    case multiBall
    case laser
    case freeze
    case teleport
    case scoreMultiplier
    case timeBonus

    var color: SKColor {
        switch self {
        case .shield: .blue
        case .speed: .green
        case .magnet: .yellow
        case .slowMotion: .purple
        case .multiBall: .orange
        case .laser: .red
        case .freeze: .cyan
        case .teleport: .magenta
        case .scoreMultiplier: .systemPink
        case .timeBonus: .brown
        }
    }

    var duration: TimeInterval {
        switch self {
        case .shield: 8.0
        case .speed: 6.0
        case .magnet: 10.0
        case .slowMotion: 5.0
        case .multiBall: 0.0 // Instant effect
        case .laser: 3.0
        case .freeze: 4.0
        case .teleport: 0.0 // Instant effect
        case .scoreMultiplier: 12.0
        case .timeBonus: 0.0 // Instant effect
        }
    }

    var description: String {
        switch self {
        case .shield: "Temporary invincibility"
        case .speed: "Increased movement speed"
        case .magnet: "Attracts nearby coins"
        case .slowMotion: "Slows down time"
        case .multiBall: "Creates multiple player instances"
        case .laser: "Destroys obstacles in path"
        case .freeze: "Freezes all obstacles"
        case .teleport: "Instantly moves to safe position"
        case .scoreMultiplier: "Doubles score earned"
        case .timeBonus: "Adds extra time to timer"
        }
    }

    var rarity: PowerUpRarity {
        switch self {
        case .shield: .common
        case .speed: .common
        case .magnet: .uncommon
        case .slowMotion: .uncommon
        case .multiBall: .rare
        case .laser: .rare
        case .freeze: .epic
        case .teleport: .epic
        case .scoreMultiplier: .legendary
        case .timeBonus: .legendary
        }
    }
}

public enum PowerUpRarity {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    var spawnWeight: Double {
        switch self {
        case .common: 1.0
        case .uncommon: 0.6
        case .rare: 0.3
        case .epic: 0.1
        case .legendary: 0.05
        }
    }

    var glowIntensity: Float {
        switch self {
        case .common: 0.3
        case .uncommon: 0.5
        case .rare: 0.7
        case .epic: 0.9
        case .legendary: 1.0
        }
    }
}

// MARK: - Object Pooling

/// Object pool for performance optimization
private nonisolated(unsafe) var objectPool: [Any] = []
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
