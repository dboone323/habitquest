//
// GameObjectPool.swift
// AvoidObstaclesGame
//
// Generic object pooling system for all game entities to improve performance
// by reusing object instances instead of creating new ones. Supports any type
// that conforms to Poolable protocol.
//

import SpriteKit
import Foundation

/// Protocol that all poolable game objects must conform to
protocol Poolable: AnyObject {
    /// Unique identifier for the object type
    var poolIdentifier: String { get }

    /// Whether the object is currently in use
    var isActive: Bool { get set }

    /// Resets the object to its initial state for reuse
    func reset()

    /// Prepares the object for activation with given parameters
    func prepareForActivation(parameters: [String: Any]?)

    /// Gets the memory footprint estimate for this object
    func memoryFootprint() -> Int
}

/// Protocol for object pool events
protocol GameObjectPoolDelegate: AnyObject {
    func objectDidSpawn<T: Poolable>(_ object: T)
    func objectDidRecycle<T: Poolable>(_ object: T)
}

/// Generic object pool for efficient reuse of game objects
class GameObjectPool<T: Poolable & Hashable> {
    // MARK: - Properties

    /// Delegate for pool events
    weak var delegate: GameObjectPoolDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Pool of available objects organized by identifier
    private var availablePool: [String: [T]] = [:]

    /// Currently active objects
    private var activeObjects: Set<T> = []

    /// Maximum pool size per object type to prevent memory bloat
    private let maxPoolSizePerType: Int

    /// Total maximum pool size across all types
    private let maxTotalPoolSize: Int

    /// Factory closure for creating new objects
    private let objectFactory: (String) -> T?

    /// Optional scene addition closure
    private let sceneAdditionHandler: ((T, SKScene) -> Void)?

    /// Optional scene removal closure
    private let sceneRemovalHandler: ((T, SKScene) -> Void)?

    // MARK: - Initialization

    /// Creates a new object pool
    /// - Parameters:
    ///   - scene: The game scene for object management
    ///   - maxPoolSizePerType: Maximum objects to keep in pool per type
    ///   - maxTotalPoolSize: Maximum total objects across all types
    ///   - objectFactory: Closure that creates new objects of type T
    ///   - sceneAdditionHandler: Optional closure for custom scene addition logic
    ///   - sceneRemovalHandler: Optional closure for custom scene removal logic
    init(
        scene: SKScene,
        maxPoolSizePerType: Int = 20,
        maxTotalPoolSize: Int = 100,
        objectFactory: @escaping (String) -> T?,
        sceneAdditionHandler: ((T, SKScene) -> Void)? = nil,
        sceneRemovalHandler: ((T, SKScene) -> Void)? = nil
    ) {
        self.scene = scene
        self.maxPoolSizePerType = maxPoolSizePerType
        self.maxTotalPoolSize = maxTotalPoolSize
        self.objectFactory = objectFactory
        self.sceneAdditionHandler = sceneAdditionHandler
        self.sceneRemovalHandler = sceneRemovalHandler
    }

    /// Updates the scene reference
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Pool Management

    /// Preloads the pool with initial objects
    /// - Parameters:
    ///   - identifiers: Array of object identifiers to preload
    ///   - countPerType: Number of objects to preload per identifier
    func preloadPool(with identifiers: [String], countPerType: Int = 5) {
        for identifier in identifiers {
            availablePool[identifier] = []
            for _ in 0..<countPerType {
                if let object = objectFactory(identifier) {
                    availablePool[identifier]?.append(object)
                }
            }
        }
    }

    /// Gets an object from the pool or creates a new one
    /// - Parameters:
    ///   - identifier: The identifier for the object type
    ///   - parameters: Optional parameters for object preparation
    /// - Returns: A configured object instance
    func getObject(withIdentifier identifier: String, parameters: [String: Any]? = nil) -> T? {
        // Try to get from pool first
        if let object = availablePool[identifier]?.popLast() {
            object.reset()
            object.prepareForActivation(parameters: parameters)
            object.isActive = true
            return object
        }

        // Create new object if pool is empty
        if let object = objectFactory(identifier) {
            object.prepareForActivation(parameters: parameters)
            object.isActive = true
            return object
        }

        return nil
    }

    /// Returns an object to the pool for reuse
    /// - Parameter object: The object to recycle
    func recycleObject(_ object: T) {
        guard activeObjects.contains(object) else { return }

        // Remove from active set
        activeObjects.remove(object)

        // Handle scene removal
        if let scene = scene, let removalHandler = sceneRemovalHandler {
            removalHandler(object, scene)
        }

        // Reset object state
        object.reset()
        object.isActive = false

        // Return to appropriate pool if not full
        let identifier = object.poolIdentifier
        let currentPoolSize = availablePool[identifier]?.count ?? 0
        let totalPoolSize = availablePool.values.flatMap { $0 }.count

        if currentPoolSize < maxPoolSizePerType && totalPoolSize < maxTotalPoolSize {
            availablePool[identifier, default: []].append(object)
        }

        delegate?.objectDidRecycle(object)
    }

    /// Adds an object to the active set and scene
    /// - Parameters:
    ///   - object: The object to activate
    ///   - parameters: Optional parameters for activation
    func activateObject(_ object: T, parameters: [String: Any]? = nil) {
        guard let scene = scene else { return }

        object.prepareForActivation(parameters: parameters)
        object.isActive = true

        // Add to scene using custom handler or default logic
        if let additionHandler = sceneAdditionHandler {
            additionHandler(object, scene)
        }

        // Add to active set
        activeObjects.insert(object)

        delegate?.objectDidSpawn(object)
    }

    // MARK: - Bulk Operations

    /// Recycles all active objects
    func recycleAllObjects() {
        let objectsToRecycle = Array(activeObjects)
        for object in objectsToRecycle {
            recycleObject(object)
        }
    }

    /// Updates all active objects
    /// - Parameter deltaTime: Time elapsed since last update
    func updateActiveObjects(deltaTime: TimeInterval) {
        // Generic update - subclasses should override for specific behavior
        // This is a placeholder for the generic interface
    }

    /// Gets all active objects
    /// - Returns: Array of active object instances
    func getActiveObjects() -> [T] {
        Array(activeObjects)
    }

    /// Gets the count of active objects
    /// - Returns: Number of active objects
    func activeObjectCount() -> Int {
        activeObjects.count
    }

    /// Gets objects of a specific type
    /// - Parameter identifier: The object identifier to filter by
    /// - Returns: Array of active objects with the specified identifier
    func getActiveObjects(withIdentifier identifier: String) -> [T] {
        activeObjects.filter { $0.poolIdentifier == identifier }
    }

    // MARK: - Pool Statistics

    /// Gets pool statistics
    /// - Returns: Dictionary with pool statistics
    func getPoolStatistics() -> [String: Any] {
        var stats: [String: Any] = [:]

        for (identifier, objects) in availablePool {
            stats["\(identifier)_available"] = objects.count
        }

        stats["active"] = activeObjects.count
        stats["total_pooled"] = availablePool.values.flatMap { $0 }.count
        stats["pool_hit_rate"] = calculatePoolHitRate()

        return stats
    }

    /// Calculates the pool hit rate (percentage of requests served from pool)
    private func calculatePoolHitRate() -> Double {
        // This would require tracking total requests vs pool hits
        // For now, return a placeholder
        return 0.0
    }

    // MARK: - Memory Management

    /// Cleans up the pool by removing excess objects
    func cleanupPool() {
        for (identifier, objects) in availablePool {
            if objects.count > maxPoolSizePerType {
                let excess = objects.count - maxPoolSizePerType
                availablePool[identifier] = Array(objects.dropFirst(excess))
            }
        }
    }

    /// Clears all pools and active objects
    func clearAll() {
        // Remove all active objects from scene
        if let scene = scene {
            for object in activeObjects {
                if let removalHandler = sceneRemovalHandler {
                    removalHandler(object, scene)
                }
            }
        }

        // Clear collections
        activeObjects.removeAll()
        availablePool.removeAll()
    }

    // MARK: - Performance Monitoring

    /// Gets memory usage information
    /// - Returns: Memory usage statistics
    func getMemoryUsage() -> [String: Any] {
        let activeMemory = activeObjects.reduce(0) { $0 + $1.memoryFootprint() }
        let pooledMemory = availablePool.values.flatMap { $0 }.reduce(0) { $0 + $1.memoryFootprint() }

        return [
            "active_memory_bytes": activeMemory,
            "pooled_memory_bytes": pooledMemory,
            "total_memory_bytes": activeMemory + pooledMemory,
            "active_object_count": activeObjects.count,
            "pooled_object_count": availablePool.values.flatMap { $0 }.count
        ]
    }

    /// Gets performance metrics
    /// - Returns: Performance statistics
    func getPerformanceMetrics() -> [String: Any] {
        let stats = getPoolStatistics()
        let memory = getMemoryUsage()

        return [
            "pool_stats": stats,
            "memory_stats": memory,
            "pool_efficiency": calculatePoolEfficiency()
        ]
    }

    /// Calculates pool efficiency (memory saved vs objects created)
    private func calculatePoolEfficiency() -> Double {
        let totalObjects = activeObjects.count + availablePool.values.flatMap { $0 }.count
        let pooledObjects = availablePool.values.flatMap { $0 }.count

        return totalObjects > 0 ? Double(pooledObjects) / Double(totalObjects) : 0.0
    }
}
