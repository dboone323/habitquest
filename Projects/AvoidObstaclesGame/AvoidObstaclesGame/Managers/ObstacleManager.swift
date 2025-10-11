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
    func obstacleDidSpawn(_ obstacle: Obstacle)
    func obstacleDidRecycle(_ obstacle: Obstacle)
}

/// Manages obstacles with object pooling for performance
class ObstacleManager {
    // MARK: - Properties

    /// Delegate for obstacle events
    weak var delegate: ObstacleDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Object pool for obstacles (replaces simple array pool)
    private var obstaclePool: ObstaclePool!

    /// Currently active obstacles
    private var activeObstacles: Set<Obstacle> = []



    /// Different obstacle types
    private let obstacleTypes: [Obstacle.ObstacleType] = [.spike, .block, .moving]

    /// Spawn action key for management
    private let spawnActionKey = "spawnObstacleAction"

    /// Current spawning state
    private var isSpawning = false

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        self.obstaclePool = ObstaclePool(scene: scene)
        self.preloadObstaclePool()
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Object Pooling

    /// Preloads the obstacle pool with initial obstacles
    private func preloadObstaclePool() {
        self.obstaclePool.preloadPools()
    }

    /// Gets an obstacle from the pool or creates a new one
    /// - Parameter type: The type of obstacle to get
    /// - Returns: A configured obstacle instance
    private func getObstacle(ofType type: Obstacle.ObstacleType) -> Obstacle {
        // Get obstacle from pool
        return self.obstaclePool.getObstacle(ofType: type)
    }

    /// Returns an obstacle to the pool for reuse
    /// - Parameter obstacle: The obstacle to recycle
    func recycleObstacle(_ obstacle: Obstacle) {
        // Remove from active set
        self.activeObstacles.remove(obstacle)

        // Return to pool
        self.obstaclePool.recycleObstacle(obstacle)
    }



    // MARK: - Spawning

    /// Starts spawning obstacles based on difficulty
    /// - Parameter difficulty: Current game difficulty settings
    func startSpawning(with difficulty: GameDifficulty) {
        guard !self.isSpawning, let scene else { return }

        self.isSpawning = true

        let spawnAction = SKAction.run { [weak self] in
            self?.spawnObstacle(with: difficulty)
        }

        let waitAction = SKAction.wait(forDuration: difficulty.spawnInterval, withRange: 0.2)
        let sequenceAction = SKAction.sequence([spawnAction, waitAction])
        let repeatForeverAction = SKAction.repeatForever(sequenceAction)

        scene.run(repeatForeverAction, withKey: self.spawnActionKey)
    }

    /// Stops spawning obstacles
    func stopSpawning() {
        self.scene?.removeAction(forKey: self.spawnActionKey)
        self.isSpawning = false
    }

    /// Spawns a single obstacle or power-up
    /// - Parameter difficulty: Current difficulty settings
    private func spawnObstacle(with difficulty: GameDifficulty) {
        guard let scene else { return }

        // Occasionally spawn a power-up instead of an obstacle
        let shouldSpawnPowerUp = Double.random(in: 0 ... 1) < difficulty.powerUpSpawnChance

        if shouldSpawnPowerUp {
            self.spawnPowerUp()
            return
        }

        // Select obstacle type based on difficulty
        let obstacleType = self.selectObstacleType(for: difficulty)
        let obstacle = self.getObstacle(ofType: obstacleType)

        // Random horizontal position
        let randomX = CGFloat.random(in: obstacle.node.frame.width / 2 ... (scene.size.width - obstacle.node.frame.width / 2))
        obstacle.position = CGPoint(x: randomX, y: scene.size.height + obstacle.node.frame.height)

        // Add to scene and active set using pool's activate method
        self.obstaclePool.activateObstacle(obstacle, at: obstacle.position)
        self.activeObstacles.insert(obstacle)

        // Animate falling
        let fallDuration = 3.0 // Use fixed duration for now, can be made configurable later
        let moveAction = SKAction.moveTo(y: -obstacle.node.frame.height, duration: fallDuration)
        let removeAction = SKAction.run { [weak self] in
            self?.recycleObstacle(obstacle)
        }

        obstacle.node.run(SKAction.sequence([moveAction, removeAction]))

        self.delegate?.obstacleDidSpawn(obstacle)
    }

    /// Selects an obstacle type based on difficulty
    private func selectObstacleType(for difficulty: GameDifficulty) -> Obstacle.ObstacleType {
        let level = GameDifficulty.getDifficultyLevel(for: Int(difficulty.scoreMultiplier * 10))

        // Higher levels introduce more variety
        if level >= 5 {
            let types: [Obstacle.ObstacleType] = [.spike, .block, .moving]
            return types.randomElement() ?? .block
        } else if level >= 3 {
            let types: [Obstacle.ObstacleType] = [.block, .moving]
            return types.randomElement() ?? .block
        } else {
            return .block
        }
    }

    // MARK: - Management

    /// Gets the count of active obstacles
    /// - Returns: Number of active obstacles
    func activeObstacleCount() -> Int {
        self.activeObstacles.count
    }

    /// Removes all active obstacles
    func removeAllObstacles() {
        for obstacle in self.activeObstacles {
            self.obstaclePool.recycleObstacle(obstacle)
        }
        self.activeObstacles.removeAll()
    }

    /// Updates obstacle positions and handles off-screen removal
    func updateObstacles() {
        guard self.scene != nil else { return }

        for obstacle in self.activeObstacles {
            // Remove obstacles that have fallen off screen
            if obstacle.position.y < -obstacle.node.frame.height {
                self.recycleObstacle(obstacle)
            }
        }
    }

    /// Gets all active obstacles
    /// - Returns: Array of active obstacle nodes
    func getActiveObstacles() -> [SKNode] {
        self.activeObstacles.map { $0.node }
    }

    // MARK: - Power-ups

    /// Spawns a power-up at a random position
    func spawnPowerUp() {
        guard let scene else { return }

        let powerUpType = PowerUpType.allCases.randomElement() ?? .shield
        let powerUp = self.createPowerUp(ofType: powerUpType)

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
    func recycleObstacleAsync(_ obstacle: Obstacle) async {
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
    func getActiveObstaclesAsync() async -> [SKNode] {
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
