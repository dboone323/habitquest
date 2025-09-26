//
// ObstacleManager.swift
// AvoidObstaclesGame
//
// Manages obstacle creation, spawning, recycling, and object pooling
// for optimal performance.
//

import SpriteKit
import UIKit

/// Protocol for obstacle-related events
protocol ObstacleDelegate: AnyObject {
    func obstacleDidSpawn(_ obstacle: SKSpriteNode)
    func obstacleDidRecycle(_ obstacle: SKSpriteNode)
}

/// Manages obstacles with object pooling for performance
class ObstacleManager {
    // MARK: - Properties

    /// Delegate for obstacle events
    weak var delegate: ObstacleDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Object pool for obstacles
    private var obstaclePool: [SKSpriteNode] = []

    /// Currently active obstacles
    private var activeObstacles: Set<SKSpriteNode> = []

    /// Maximum pool size to prevent memory bloat
    private let maxPoolSize = 50

    /// Different obstacle types
    private let obstacleTypes: [ObstacleType] = [.normal, .fast, .large, .small]

    /// Spawn action key for management
    private let spawnActionKey = "spawnObstacleAction"

    /// Current spawning state
    private var isSpawning = false

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        preloadObstaclePool()
    }

    // MARK: - Object Pooling

    /// Preloads the obstacle pool with initial obstacles
    private func preloadObstaclePool() {
        for _ in 0 ..< 10 {
            let obstacle = createNewObstacle(ofType: .normal)
            obstaclePool.append(obstacle)
        }
    }

    /// Gets an obstacle from the pool or creates a new one
    /// - Parameter type: The type of obstacle to get
    /// - Returns: A configured obstacle node
    private func getObstacle(ofType type: ObstacleType) -> SKSpriteNode {
        // Try to get from pool first
        if let recycledObstacle = obstaclePool.popLast() {
            resetObstacle(recycledObstacle, toType: type)
            return recycledObstacle
        }

        // Create new obstacle if pool is empty
        return createNewObstacle(ofType: type)
    }

    /// Returns an obstacle to the pool for reuse
    /// - Parameter obstacle: The obstacle to recycle
    func recycleObstacle(_ obstacle: SKSpriteNode) {
        guard activeObstacles.contains(obstacle) else { return }

        // Remove from active set
        activeObstacles.remove(obstacle)

        // Reset obstacle state
        obstacle.removeFromParent()
        obstacle.removeAllActions()
        obstacle.alpha = 1.0
        obstacle.isHidden = false
        obstacle.physicsBody?.velocity = .zero
        obstacle.physicsBody?.angularVelocity = 0

        // Return to pool if not full
        if obstaclePool.count < maxPoolSize {
            obstaclePool.append(obstacle)
        }

        delegate?.obstacleDidRecycle(obstacle)
    }

    /// Creates a new obstacle of the specified type
    /// - Parameter type: The type of obstacle to create
    /// - Returns: A new obstacle node
    private func createNewObstacle(ofType type: ObstacleType) -> SKSpriteNode {
        let config = type.configuration
        let obstacle = SKSpriteNode(color: config.color, size: config.size)
        obstacle.name = "obstacle"

        // Add visual enhancements
        addObstacleVisualEffects(to: obstacle, config: config)

        // Setup physics
        setupObstaclePhysics(for: obstacle, config: config)

        return obstacle
    }

    /// Resets an existing obstacle for reuse
    /// - Parameters:
    ///   - obstacle: The obstacle to reset
    ///   - type: The new type to configure it as
    private func resetObstacle(_ obstacle: SKSpriteNode, toType type: ObstacleType) {
        let config = type.configuration

        obstacle.color = config.color
        obstacle.size = config.size
        obstacle.alpha = 1.0
        obstacle.isHidden = false

        // Update physics body
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: config.size)
        setupObstaclePhysics(for: obstacle, config: config)

        // Clear and re-add visual effects
        obstacle.removeAllChildren()
        addObstacleVisualEffects(to: obstacle, config: config)
    }

    /// Adds visual effects to an obstacle
    private func addObstacleVisualEffects(to obstacle: SKSpriteNode, config: ObstacleConfiguration) {
        // Add border effect
        let borderWidth: CGFloat = 2.0
        let borderColor = config.borderColor

        // Create border nodes
        let topBorder = SKSpriteNode(color: borderColor, size: CGSize(width: config.size.width, height: borderWidth))
        topBorder.position = CGPoint(x: 0, y: config.size.height / 2 - borderWidth / 2)
        obstacle.addChild(topBorder)

        let bottomBorder = SKSpriteNode(color: borderColor, size: CGSize(width: config.size.width, height: borderWidth))
        bottomBorder.position = CGPoint(x: 0, y: -config.size.height / 2 + borderWidth / 2)
        obstacle.addChild(bottomBorder)

        let leftBorder = SKSpriteNode(color: borderColor, size: CGSize(width: borderWidth, height: config.size.height))
        leftBorder.position = CGPoint(x: -config.size.width / 2 + borderWidth / 2, y: 0)
        obstacle.addChild(leftBorder)

        let rightBorder = SKSpriteNode(color: borderColor, size: CGSize(width: borderWidth, height: config.size.height))
        rightBorder.position = CGPoint(x: config.size.width / 2 - borderWidth / 2, y: 0)
        obstacle.addChild(rightBorder)

        // Add glow effect for special obstacles
        if config.hasGlow {
            let glowSize = CGSize(width: config.size.width * 1.2, height: config.size.height * 1.2)
            let glowNode = SKSpriteNode(color: config.color.withAlphaComponent(0.3), size: glowSize)
            glowNode.zPosition = -1
            obstacle.addChild(glowNode)
        }
    }

    /// Sets up physics for an obstacle
    private func setupObstaclePhysics(for obstacle: SKSpriteNode, config: ObstacleConfiguration) {
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.allowsRotation = config.canRotate
    }

    // MARK: - Spawning

    /// Starts spawning obstacles based on difficulty
    /// - Parameter difficulty: Current game difficulty settings
    func startSpawning(with difficulty: GameDifficulty) {
        guard !isSpawning, let scene else { return }

        isSpawning = true

        let spawnAction = SKAction.run { [weak self] in
            self?.spawnObstacle(with: difficulty)
        }

        let waitAction = SKAction.wait(forDuration: difficulty.spawnInterval, withRange: 0.2)
        let sequenceAction = SKAction.sequence([spawnAction, waitAction])
        let repeatForeverAction = SKAction.repeatForever(sequenceAction)

        scene.run(repeatForeverAction, withKey: spawnActionKey)
    }

    /// Stops spawning obstacles
    func stopSpawning() {
        scene?.removeAction(forKey: spawnActionKey)
        isSpawning = false
    }

    /// Spawns a single obstacle or power-up
    /// - Parameter difficulty: Current difficulty settings
    private func spawnObstacle(with difficulty: GameDifficulty) {
        guard let scene else { return }

        // Occasionally spawn a power-up instead of an obstacle
        let shouldSpawnPowerUp = Double.random(in: 0 ... 1) < difficulty.powerUpSpawnChance

        if shouldSpawnPowerUp {
            spawnPowerUp()
            return
        }

        // Select obstacle type based on difficulty
        let obstacleType = selectObstacleType(for: difficulty)
        let obstacle = getObstacle(ofType: obstacleType)

        // Random horizontal position
        let randomX = CGFloat.random(in: obstacle.size.width / 2 ... (scene.size.width - obstacle.size.width / 2))
        obstacle.position = CGPoint(x: randomX, y: scene.size.height + obstacle.size.height)

        // Add to scene and active set
        scene.addChild(obstacle)
        activeObstacles.insert(obstacle)

        // Animate falling
        let fallDuration = obstacleType.configuration.fallSpeed / difficulty.obstacleSpeed
        let moveAction = SKAction.moveTo(y: -obstacle.size.height, duration: fallDuration)
        let removeAction = SKAction.run { [weak self] in
            self?.recycleObstacle(obstacle)
        }

        obstacle.run(SKAction.sequence([moveAction, removeAction]))

        delegate?.obstacleDidSpawn(obstacle)
    }

    /// Selects an obstacle type based on difficulty
    private func selectObstacleType(for difficulty: GameDifficulty) -> ObstacleType {
        let level = GameDifficulty.getDifficultyLevel(for: Int(difficulty.scoreMultiplier * 10))

        // Higher levels introduce more variety
        if level >= 5 {
            let types: [ObstacleType] = [.normal, .fast, .large, .small]
            return types.randomElement() ?? .normal
        } else if level >= 3 {
            let types: [ObstacleType] = [.normal, .fast, .large]
            return types.randomElement() ?? .normal
        } else {
            return .normal
        }
    }

    // MARK: - Management

    /// Gets the count of active obstacles
    /// - Returns: Number of active obstacles
    func activeObstacleCount() -> Int {
        activeObstacles.count
    }

    /// Removes all active obstacles
    func removeAllObstacles() {
        for obstacle in activeObstacles {
            recycleObstacle(obstacle)
        }
    }

    /// Updates obstacle positions and handles off-screen removal
    func updateObstacles() {
        guard scene != nil else { return }

        for obstacle in activeObstacles {
            // Remove obstacles that have fallen off screen
            if obstacle.position.y < -obstacle.size.height {
                recycleObstacle(obstacle)
            }
        }
    }

    /// Gets all active obstacles
    /// - Returns: Array of active obstacle nodes
    func getActiveObstacles() -> [SKSpriteNode] {
        Array(activeObstacles)
    }

    // MARK: - Power-ups

    /// Spawns a power-up at a random position
    func spawnPowerUp() {
        guard let scene else { return }

        let powerUpType = PowerUpType.allCases.randomElement() ?? .shield
        let powerUp = createPowerUp(ofType: powerUpType)

        // Random position across the screen width
        let randomX = CGFloat.random(in: powerUp.size.width / 2 ... (scene.size.width - powerUp.size.width / 2))
        powerUp.position = CGPoint(x: randomX, y: scene.size.height + powerUp.size.height)

        // Add physics body
        powerUp.physicsBody = SKPhysicsBody(rectangleOf: powerUp.size)
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.player
        powerUp.physicsBody?.collisionBitMask = PhysicsCategory.none
        powerUp.physicsBody?.affectedByGravity = false
        powerUp.physicsBody?.isDynamic = true

        scene.addChild(powerUp)

        // Move power-up down the screen
        let moveAction = SKAction.moveTo(y: -powerUp.size.height, duration: 8.0) // Slower than obstacles
        let removeAction = SKAction.removeFromParent()
        powerUp.run(SKAction.sequence([moveAction, removeAction]))
    }

    /// Creates a power-up node of the specified type
    private func createPowerUp(ofType type: PowerUpType) -> SKSpriteNode {
        let size = CGSize(width: 25, height: 25)
        let powerUp = SKSpriteNode(color: type.color, size: size)
        powerUp.name = "powerUp"

        // Add visual enhancement
        let glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        let glowFilter = CIFilter(name: "CIGaussianBlur")
        glowFilter?.setValue(2.0, forKey: kCIInputRadiusKey)
        glowEffect.filter = glowFilter
        glowEffect.addChild(SKSpriteNode(color: type.color.withAlphaComponent(0.7), size: CGSize(width: 30, height: 30)))
        glowEffect.zPosition = -1
        powerUp.addChild(glowEffect)

        // Add pulsing animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        powerUp.run(SKAction.repeatForever(pulse))

        return powerUp
    }

    // MARK: - Async Obstacle Management

    /// Returns an obstacle to the pool for reuse asynchronously
    /// - Parameter obstacle: The obstacle to recycle
    func recycleObstacleAsync(_ obstacle: SKSpriteNode) async {
        await Task.detached {
            self.recycleObstacle(obstacle)
        }.value
    }

    /// Starts spawning obstacles based on difficulty asynchronously
    /// - Parameter difficulty: Current game difficulty settings
    func startSpawningAsync(with difficulty: GameDifficulty) async {
        await Task.detached {
            self.startSpawning(with: difficulty)
        }.value
    }

    /// Stops spawning obstacles asynchronously
    func stopSpawningAsync() async {
        await Task.detached {
            self.stopSpawning()
        }.value
    }

    /// Gets the count of active obstacles asynchronously
    /// - Returns: Number of active obstacles
    func activeObstacleCountAsync() async -> Int {
        await Task.detached {
            self.activeObstacleCount()
        }.value
    }

    /// Removes all active obstacles asynchronously
    func removeAllObstaclesAsync() async {
        await Task.detached {
            self.removeAllObstacles()
        }.value
    }

    /// Updates obstacle positions and handles off-screen removal asynchronously
    func updateObstaclesAsync() async {
        await Task.detached {
            self.updateObstacles()
        }.value
    }

    /// Gets all active obstacles asynchronously
    /// - Returns: Array of active obstacle nodes
    func getActiveObstaclesAsync() async -> [SKSpriteNode] {
        await Task.detached {
            self.getActiveObstacles()
        }.value
    }

    /// Spawns a power-up at a random position asynchronously
    func spawnPowerUpAsync() async {
        await Task.detached {
            self.spawnPowerUp()
        }.value
    }
}

/// Types of obstacles available
enum ObstacleType {
    case normal
    case fast
    case large
    case small

    var configuration: ObstacleConfiguration {
        switch self {
        case .normal:
            ObstacleConfiguration(
                size: CGSize(width: 30, height: 30),
                color: .systemRed,
                borderColor: UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0),
                fallSpeed: 3.5,
                canRotate: false,
                hasGlow: false
            )
        case .fast:
            ObstacleConfiguration(
                size: CGSize(width: 25, height: 25),
                color: .systemOrange,
                borderColor: UIColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0),
                fallSpeed: 4.5,
                canRotate: true,
                hasGlow: true
            )
        case .large:
            ObstacleConfiguration(
                size: CGSize(width: 45, height: 45),
                color: .systemPurple,
                borderColor: UIColor(red: 0.4, green: 0.0, blue: 0.6, alpha: 1.0),
                fallSpeed: 2.8,
                canRotate: false,
                hasGlow: false
            )
        case .small:
            ObstacleConfiguration(
                size: CGSize(width: 20, height: 20),
                color: .systemPink,
                borderColor: UIColor(red: 0.8, green: 0.0, blue: 0.4, alpha: 1.0),
                fallSpeed: 5.0,
                canRotate: true,
                hasGlow: true
            )
        }
    }
}

/// Configuration for obstacle types
struct ObstacleConfiguration {
    let size: CGSize
    let color: UIColor
    let borderColor: UIColor
    let fallSpeed: CGFloat
    let canRotate: Bool
    let hasGlow: Bool
}
