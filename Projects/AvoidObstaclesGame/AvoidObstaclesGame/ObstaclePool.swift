//
// ObstaclePool.swift
// AvoidObstaclesGame
//
// Implements object pooling for Obstacle entities to improve performance
// by reusing obstacle instances instead of creating new ones.
//

import SpriteKit
import UIKit

/// Protocol for obstacle pool events
protocol ObstaclePoolDelegate: AnyObject {
    func obstacleDidSpawn(_ obstacle: Obstacle)
    func obstacleDidRecycle(_ obstacle: Obstacle)
}

/// Manages a pool of Obstacle objects for efficient reuse
class ObstaclePool {
    // MARK: - Properties

    /// Delegate for pool events
    weak var delegate: ObstaclePoolDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Pool of available obstacles organized by type
    private var availablePools: [Obstacle.ObstacleType: [Obstacle]] = [:]

    /// Currently active obstacles
    private var activeObstacles: Set<Obstacle> = []

    /// Maximum pool size per obstacle type to prevent memory bloat
    private let maxPoolSizePerType = 20

    /// Total maximum pool size across all types
    private let maxTotalPoolSize = 100

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        self.preloadPools()
    }

    /// Updates the scene reference
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Pool Management

    /// Preloads pools with initial obstacles of each type
    func preloadPools() {
        let types: [Obstacle.ObstacleType] = [.spike, .block, .moving]

        for type in types {
            availablePools[type] = []
            // Preload 5 obstacles of each type
            for _ in 0..<5 {
                let obstacle = Obstacle(type: type)
                availablePools[type]?.append(obstacle)
            }
        }
    }

    /// Gets an obstacle from the pool or creates a new one
    /// - Parameter type: The type of obstacle to get
    /// - Returns: A configured obstacle instance
    func getObstacle(ofType type: Obstacle.ObstacleType) -> Obstacle {
        // Try to get from pool first
        if let obstacle = availablePools[type]?.popLast() {
            obstacle.reset()
            return obstacle
        }

        // Create new obstacle if pool is empty
        return Obstacle(type: type)
    }

    /// Returns an obstacle to the pool for reuse
    /// - Parameter obstacle: The obstacle to recycle
    func recycleObstacle(_ obstacle: Obstacle) {
        guard activeObstacles.contains(obstacle) else { return }

        // Remove from active set
        activeObstacles.remove(obstacle)

        // Remove from scene
        obstacle.node.removeFromParent()
        obstacle.node.removeAllActions()

        // Reset obstacle state
        obstacle.reset()

        // Return to appropriate pool if not full
        let type = obstacle.obstacleType
        let currentPoolSize = availablePools[type]?.count ?? 0
        let totalPoolSize = availablePools.values.flatMap { $0 }.count

        if currentPoolSize < maxPoolSizePerType && totalPoolSize < maxTotalPoolSize {
            availablePools[type, default: []].append(obstacle)
        }

        delegate?.obstacleDidRecycle(obstacle)
    }

    /// Adds an obstacle to the active set and scene
    /// - Parameters:
    ///   - obstacle: The obstacle to activate
    ///   - position: Position to place the obstacle
    func activateObstacle(_ obstacle: Obstacle, at position: CGPoint) {
        guard let scene = scene else { return }

        obstacle.position = position
        obstacle.isVisible = true

        // Add to scene and active set
        scene.addChild(obstacle.node)
        activeObstacles.insert(obstacle)

        delegate?.obstacleDidSpawn(obstacle)
    }

    // MARK: - Bulk Operations

    /// Recycles all active obstacles
    func recycleAllObstacles() {
        let obstaclesToRecycle = Array(activeObstacles)
        for obstacle in obstaclesToRecycle {
            recycleObstacle(obstacle)
        }
    }

    /// Updates all active obstacles
    /// - Parameter deltaTime: Time elapsed since last update
    func updateActiveObstacles(deltaTime: TimeInterval) {
        for obstacle in activeObstacles {
            obstacle.update(deltaTime: deltaTime)

            // Remove obstacles that have moved off screen
            if obstacle.position.x < -obstacle.node.frame.width {
                recycleObstacle(obstacle)
            }
        }
    }

    /// Gets all active obstacles
    /// - Returns: Array of active obstacle instances
    func getActiveObstacles() -> [Obstacle] {
        Array(activeObstacles)
    }

    /// Gets the count of active obstacles
    /// - Returns: Number of active obstacles
    func activeObstacleCount() -> Int {
        activeObstacles.count
    }

    /// Gets pool statistics
    /// - Returns: Dictionary with pool statistics
    func getPoolStatistics() -> [String: Int] {
        var stats: [String: Int] = [:]

        for (type, obstacles) in availablePools {
            stats["\(type)_available"] = obstacles.count
        }

        stats["active"] = activeObstacles.count
        stats["total_pooled"] = availablePools.values.flatMap { $0 }.count

        return stats
    }

    // MARK: - Memory Management

    /// Cleans up the pool by removing excess obstacles
    func cleanupPool() {
        for (type, obstacles) in availablePools {
            if obstacles.count > maxPoolSizePerType {
                let excess = obstacles.count - maxPoolSizePerType
                availablePools[type] = Array(obstacles.dropFirst(excess))
            }
        }
    }

    /// Clears all pools and active obstacles
    func clearAll() {
        // Remove all active obstacles from scene
        for obstacle in activeObstacles {
            obstacle.node.removeFromParent()
        }

        // Clear collections
        activeObstacles.removeAll()
        availablePools.removeAll()
    }

    // MARK: - Performance Monitoring

    /// Gets memory usage information
    /// - Returns: Memory usage statistics
    func getMemoryUsage() -> [String: Int] {
        let obstacleSizeEstimate = 1000 // Rough estimate per obstacle in bytes
        let activeMemory = activeObstacles.count * obstacleSizeEstimate
        let pooledMemory = availablePools.values.flatMap { $0 }.count * obstacleSizeEstimate

        return [
            "active_memory_bytes": activeMemory,
            "pooled_memory_bytes": pooledMemory,
            "total_memory_bytes": activeMemory + pooledMemory
        ]
    }
}
