//
// ObstacleManager.swift
// AvoidObstaclesGame
//
// Manages obstacle creation, spawning, recycling, and object pooling
// for optimal performance.
//

import Combine
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Protocol for obstacle-related events
@MainActor
protocol ObstacleDelegate: AnyObject {
    func obstacleDidSpawn(_ obstacle: Obstacle)
    func obstacleDidRecycle(_ obstacle: Obstacle)
    func obstacleDidAvoid(_ obstacle: Obstacle)
}

/// Manages obstacles with object pooling for performance
@MainActor
final class ObstacleManager {
    // MARK: - Properties

    /// Delegate for obstacle events
    weak var delegate: ObstacleDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Object pool for obstacles (replaces simple array pool)
    private var obstaclePool: ObstaclePool!

    /// Currently active obstacles
    private var activeObstacles: Set<Obstacle> = []

    /// AI-powered dynamic generation system
    private let dynamicGenerator: DynamicObstacleGenerator

    /// Adaptive power-up manager
    private let powerUpManager: PowerUpManager

    /// Current difficulty settings
    private var currentDifficulty: GameDifficulty

    /// Different obstacle types
    private let obstacleTypes: [Obstacle.ObstacleType] = [.spike, .block, .moving, .pulsing, .rotating, .bouncing, .teleporting, .splitting, .laser]

    /// Spawn action key for management
    private let spawnActionKey = "spawnObstacleAction"

    /// Current spawning state
    private var isSpawning = false

    /// Publisher for obstacle metrics
    let obstacleMetricsPublisher = PassthroughSubject<ObstacleMetrics, Never>()

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        self.obstaclePool = ObstaclePool(scene: scene)
        self.dynamicGenerator = DynamicObstacleGenerator()
        self.powerUpManager = PowerUpManager(scene: scene, aiDifficultyManager: AIAdaptiveDifficultyManager())
        self.currentDifficulty = GameDifficulty.getDifficulty(for: 0) // Start with easiest
        self.preloadObstaclePool()
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    /// Updates the obstacle manager with delta time
    /// - Parameter deltaTime: Time elapsed since last update
    func update(_ deltaTime: TimeInterval) {
        // Update obstacle-specific logic here
        // For now, this is mainly for future expansion
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
        self.obstaclePool.getObstacle(ofType: type)
    }

    /// Returns an obstacle to the pool for reuse
    /// - Parameter obstacle: The obstacle to recycle
    func recycleObstacle(_ obstacle: Obstacle) {
        // Remove from active set
        self.activeObstacles.remove(obstacle)

        // Return to pool
        self.obstaclePool.recycleObstacle(obstacle)
    }

    /// Records successful obstacle avoidance
    /// - Parameter obstacle: The obstacle that was successfully avoided
    private func recordSuccessfulAvoidance(_ obstacle: Obstacle) {
        // Notify delegate of successful avoidance
        self.delegate?.obstacleDidAvoid(obstacle)
    }

    // MARK: - Spawning

    /// Starts spawning obstacles based on difficulty
    /// - Parameter difficulty: Current game difficulty settings
    func startSpawning(with difficulty: GameDifficulty) {
        guard !self.isSpawning, let scene else { return }

        self.isSpawning = true
        self.currentDifficulty = difficulty

        // Initialize dynamic generation with current difficulty
        dynamicGenerator.updateDifficulty(difficulty)
        powerUpManager.updateDifficulty(difficulty)

        let spawnAction = SKAction.run { [weak self] in
            self?.spawnDynamicObstacle()
        }

        let waitAction = SKAction.wait(forDuration: difficulty.spawnInterval, withRange: 0.2)
        let sequenceAction = SKAction.sequence([spawnAction, waitAction])
        let repeatForeverAction = SKAction.repeatForever(sequenceAction)

        scene.run(repeatForeverAction, withKey: self.spawnActionKey)

        // Start adaptive power-up spawning
        powerUpManager.startSpawning()
    }

    /// Stops spawning obstacles
    func stopSpawning() {
        self.scene?.removeAction(forKey: self.spawnActionKey)
        self.isSpawning = false
        powerUpManager.stopSpawning()
    }

    /// Spawns obstacles using dynamic AI-based generation
    private func spawnDynamicObstacle() {
        guard let scene else { return }

        // Get dynamic generation pattern from AI
        let generationPattern = dynamicGenerator.generateObstaclePattern()

        // Spawn based on the pattern
        switch generationPattern.type {
        case .single:
            spawnSingleObstacle(with: generationPattern)
        case .cluster:
            spawnObstacleCluster(with: generationPattern)
        case .wave:
            spawnObstacleWave(with: generationPattern)
        case .pattern:
            spawnObstaclePattern(with: generationPattern)
        }
    }

    /// Spawns a single obstacle with dynamic properties
    private func spawnSingleObstacle(with pattern: ObstacleGenerationPattern) {
        guard let scene else { return }

        let obstacleType = pattern.obstacleType ?? selectObstacleType(for: currentDifficulty)
        let obstacle = self.getObstacle(ofType: obstacleType)

        // Apply dynamic positioning
        let position = dynamicGenerator.calculateDynamicPosition(for: obstacle, in: scene.frame, pattern: pattern)
        obstacle.position = position

        // Apply dynamic properties
        applyDynamicProperties(to: obstacle, pattern: pattern)

        // Add to scene and active set
        self.obstaclePool.activateObstacle(obstacle, at: obstacle.position)
        self.activeObstacles.insert(obstacle)

        // Animate with dynamic movement
        let moveAction = dynamicGenerator.createDynamicMovement(for: obstacle, pattern: pattern)
        let removeAction = SKAction.run { [weak self] in
            self?.recycleObstacle(obstacle)
        }

        obstacle.node.run(SKAction.sequence([moveAction, removeAction]))
        self.delegate?.obstacleDidSpawn(obstacle)
    }

    /// Spawns a cluster of obstacles
    private func spawnObstacleCluster(with pattern: ObstacleGenerationPattern) {
        guard let scene else { return }

        let clusterSize = pattern.clusterSize ?? 3
        let basePosition = dynamicGenerator.calculateClusterBasePosition(in: scene.frame, pattern: pattern)

        for i in 0 ..< clusterSize {
            let obstacleType = pattern.obstacleType ?? selectObstacleType(for: currentDifficulty)
            let obstacle = self.getObstacle(ofType: obstacleType)

            // Calculate position within cluster
            let clusterPosition = dynamicGenerator.calculateClusterPosition(
                basePosition: basePosition,
                index: i,
                total: clusterSize,
                pattern: pattern
            )
            obstacle.position = clusterPosition

            // Apply cluster-specific properties
            applyDynamicProperties(to: obstacle, pattern: pattern)

            // Add to scene
            self.obstaclePool.activateObstacle(obstacle, at: obstacle.position)
            self.activeObstacles.insert(obstacle)

            // Animate cluster movement
            let moveAction = dynamicGenerator.createClusterMovement(for: obstacle, pattern: pattern, index: i)
            let removeAction = SKAction.run { [weak self] in
                self?.recycleObstacle(obstacle)
            }

            obstacle.node.run(SKAction.sequence([moveAction, removeAction]))
            self.delegate?.obstacleDidSpawn(obstacle)
        }
    }

    /// Spawns a wave of obstacles
    private func spawnObstacleWave(with pattern: ObstacleGenerationPattern) {
        guard let scene else { return }

        let waveSize = pattern.waveSize ?? 5
        let waveDelay = pattern.waveDelay ?? 0.2

        for i in 0 ..< waveSize {
            let delay = Double(i) * waveDelay

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.spawnWaveObstacle(at: i, in: waveSize, pattern: pattern)
            }
        }
    }

    private func spawnWaveObstacle(at index: Int, in total: Int, pattern: ObstacleGenerationPattern) {
        guard let scene else { return }

        let obstacleType = pattern.obstacleType ?? selectObstacleType(for: currentDifficulty)
        let obstacle = self.getObstacle(ofType: obstacleType)

        let position = dynamicGenerator.calculateWavePosition(
            index: index,
            total: total,
            in: scene.frame,
            pattern: pattern
        )
        obstacle.position = position

        applyDynamicProperties(to: obstacle, pattern: pattern)

        self.obstaclePool.activateObstacle(obstacle, at: obstacle.position)
        self.activeObstacles.insert(obstacle)

        let moveAction = dynamicGenerator.createWaveMovement(for: obstacle, pattern: pattern)
        let removeAction = SKAction.run { [weak self] in
            self?.recycleObstacle(obstacle)
        }

        obstacle.node.run(SKAction.sequence([moveAction, removeAction]))
        self.delegate?.obstacleDidSpawn(obstacle)
    }

    /// Spawns obstacles in a predefined pattern
    private func spawnObstaclePattern(with pattern: ObstacleGenerationPattern) {
        guard let scene, let patternType = pattern.patternType else { return }

        let positions = dynamicGenerator.calculatePatternPositions(
            type: patternType,
            in: scene.frame,
            pattern: pattern
        )

        for position in positions {
            let obstacleType = pattern.obstacleType ?? selectObstacleType(for: currentDifficulty)
            let obstacle = self.getObstacle(ofType: obstacleType)

            obstacle.position = position
            applyDynamicProperties(to: obstacle, pattern: pattern)

            self.obstaclePool.activateObstacle(obstacle, at: obstacle.position)
            self.activeObstacles.insert(obstacle)

            let moveAction = dynamicGenerator.createPatternMovement(for: obstacle, pattern: pattern)
            let removeAction = SKAction.run { [weak self] in
                self?.recycleObstacle(obstacle)
            }

            obstacle.node.run(SKAction.sequence([moveAction, removeAction]))
            self.delegate?.obstacleDidSpawn(obstacle)
        }
    }

    /// Applies dynamic properties to an obstacle based on the generation pattern
    private func applyDynamicProperties(to obstacle: Obstacle, pattern: ObstacleGenerationPattern) {
        // Apply speed modifications
        if let speedMultiplier = pattern.speedMultiplier {
            obstacle.node.speed = speedMultiplier
        }

        // Apply size modifications
        if let sizeMultiplier = pattern.sizeMultiplier {
            obstacle.node.xScale = sizeMultiplier
            obstacle.node.yScale = sizeMultiplier
        }

        // Apply rotation if specified
        if pattern.shouldRotate {
            let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
            obstacle.node.run(SKAction.repeatForever(rotateAction))
        }

        // Apply color variations
        if let colorVariation = pattern.colorVariation {
            if let shapeNode = obstacle.node as? SKShapeNode {
                shapeNode.fillColor = colorVariation
            }
        }
    }

    /// Selects an obstacle type based on difficulty
    private func selectObstacleType(for difficulty: GameDifficulty) -> Obstacle.ObstacleType {
        let level = GameDifficulty.getDifficultyLevel(for: Int(difficulty.scoreMultiplier * 10))

        // Higher levels introduce more variety and complex obstacles
        if level >= 8 {
            let types: [Obstacle.ObstacleType] = [.spike, .block, .moving, .pulsing, .rotating, .bouncing, .teleporting, .splitting, .laser]
            return types.randomElement() ?? .block
        } else if level >= 6 {
            let types: [Obstacle.ObstacleType] = [.spike, .block, .moving, .pulsing, .rotating, .bouncing, .teleporting]
            return types.randomElement() ?? .block
        } else if level >= 4 {
            let types: [Obstacle.ObstacleType] = [.spike, .block, .moving, .pulsing, .rotating, .bouncing]
            return types.randomElement() ?? .block
        } else if level >= 3 {
            let types: [Obstacle.ObstacleType] = [.block, .moving, .pulsing, .rotating]
            return types.randomElement() ?? .block
        } else if level >= 2 {
            let types: [Obstacle.ObstacleType] = [.block, .moving, .pulsing]
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

    /// Gets all active obstacles
    /// - Returns: Array of active obstacle nodes
    func getActiveObstacles() -> [SKNode] {
        self.activeObstacles.map(\.node)
    }

    /// Gets the Obstacle object for a given node
    /// - Parameter node: The SKNode to find the Obstacle for
    /// - Returns: The Obstacle object if found, nil otherwise
    func getObstacleForNode(_ node: SKNode) -> Obstacle? {
        self.activeObstacles.first { $0.node === node }
    }

    /// Gets all active power-ups
    /// - Returns: Array of active power-up nodes
    func getActivePowerUps() -> [SKNode] {
        powerUpManager.getActivePowerUps()
    }

    /// Updates obstacle positions and handles off-screen removal
    func updateObstacles() {
        // Update active obstacles through the pool
        // Note: deltaTime would be needed for proper physics updates
        // For now, this is a placeholder for future implementation
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
                borderColor: SKColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0),
                fallSpeed: 3.5,
                canRotate: false,
                hasGlow: false
            )
        case .fast:
            ObstacleConfiguration(
                size: CGSize(width: 25, height: 25),
                color: .systemOrange,
                borderColor: SKColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0),
                fallSpeed: 4.5,
                canRotate: true,
                hasGlow: true
            )
        case .large:
            ObstacleConfiguration(
                size: CGSize(width: 45, height: 45),
                color: .systemPurple,
                borderColor: SKColor(red: 0.4, green: 0.0, blue: 0.6, alpha: 1.0),
                fallSpeed: 2.8,
                canRotate: false,
                hasGlow: false
            )
        case .small:
            ObstacleConfiguration(
                size: CGSize(width: 20, height: 20),
                color: .systemPink,
                borderColor: SKColor(red: 0.8, green: 0.0, blue: 0.4, alpha: 1.0),
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
    let color: SKColor
    let borderColor: SKColor
    let fallSpeed: CGFloat
    let canRotate: Bool
    let hasGlow: Bool
}

// MARK: - Dynamic Generation Data Structures

/// Types of obstacle generation patterns
enum ObstaclePatternType: CaseIterable {
    case single
    case cluster
    case wave
    case pattern
}

/// Configuration for dynamic obstacle generation
struct ObstacleGenerationPattern {
    let type: ObstaclePatternType
    let obstacleType: Obstacle.ObstacleType?
    let patternType: ObstaclePatternType?

    // Single obstacle properties
    let speedMultiplier: Double?
    let sizeMultiplier: Double?
    let shouldRotate: Bool
    let colorVariation: SKColor?

    // Cluster properties
    let clusterSize: Int?
    let clusterSpacing: Double?

    // Wave properties
    let waveSize: Int?
    let waveDelay: Double?

    init(type: ObstaclePatternType,
         obstacleType: Obstacle.ObstacleType? = nil,
         patternType: ObstaclePatternType? = nil,
         speedMultiplier: Double? = nil,
         sizeMultiplier: Double? = nil,
         shouldRotate: Bool = false,
         colorVariation: SKColor? = nil,
         clusterSize: Int? = nil,
         clusterSpacing: Double? = nil,
         waveSize: Int? = nil,
         waveDelay: Double? = nil)
    {

        self.type = type
        self.obstacleType = obstacleType
        self.patternType = patternType
        self.speedMultiplier = speedMultiplier
        self.sizeMultiplier = sizeMultiplier
        self.shouldRotate = shouldRotate
        self.colorVariation = colorVariation
        self.clusterSize = clusterSize
        self.clusterSpacing = clusterSpacing
        self.waveSize = waveSize
        self.waveDelay = waveDelay
    }
}

/// AI-powered dynamic obstacle generation system
class DynamicObstacleGenerator {
    private var currentDifficulty: GameDifficulty
    private var generationHistory: [ObstacleGenerationPattern] = []
    private let maxHistorySize = 20

    // Pattern weights for different difficulty levels
    private var patternWeights: [ObstaclePatternType: Double] = [
        .single: 0.6,
        .cluster: 0.2,
        .wave: 0.15,
        .pattern: 0.05,
    ]

    init() {
        self.currentDifficulty = GameDifficulty.getDifficulty(for: 0)
    }

    func updateDifficulty(_ difficulty: GameDifficulty) {
        self.currentDifficulty = difficulty
        updatePatternWeights(for: difficulty)
    }

    func generateObstaclePattern() -> ObstacleGenerationPattern {
        let patternType = selectPatternType()
        let pattern = createPattern(of: patternType)

        // Add to history
        generationHistory.append(pattern)
        if generationHistory.count > maxHistorySize {
            generationHistory.removeFirst()
        }

        return pattern
    }

    private func selectPatternType() -> ObstaclePatternType {
        let randomValue = Double.random(in: 0 ..< 1)
        var cumulativeWeight = 0.0

        for (patternType, weight) in patternWeights {
            cumulativeWeight += weight
            if randomValue <= cumulativeWeight {
                return patternType
            }
        }

        return .single // Fallback
    }

    private func updatePatternWeights(for difficulty: GameDifficulty) {
        let level = GameDifficulty.getDifficultyLevel(for: Int(difficulty.scoreMultiplier * 10))

        switch level {
        case 1:
            patternWeights = [.single: 0.8, .cluster: 0.15, .wave: 0.04, .pattern: 0.01]
        case 2:
            patternWeights = [.single: 0.7, .cluster: 0.2, .wave: 0.08, .pattern: 0.02]
        case 3:
            patternWeights = [.single: 0.6, .cluster: 0.25, .wave: 0.12, .pattern: 0.03]
        case 4:
            patternWeights = [.single: 0.5, .cluster: 0.3, .wave: 0.15, .pattern: 0.05]
        case 5:
            patternWeights = [.single: 0.4, .cluster: 0.3, .wave: 0.2, .pattern: 0.1]
        default: // Level 6+
            patternWeights = [.single: 0.3, .cluster: 0.3, .wave: 0.25, .pattern: 0.15]
        }
    }

    private func createPattern(of type: ObstaclePatternType) -> ObstacleGenerationPattern {
        switch type {
        case .single:
            return createSinglePattern()
        case .cluster:
            return createClusterPattern()
        case .wave:
            return createWavePattern()
        case .pattern:
            return createComplexPattern()
        }
    }

    private func createSinglePattern() -> ObstacleGenerationPattern {
        let speedMultiplier = Double.random(in: 0.8 ... 1.5) * currentDifficulty.obstacleSpeed
        let sizeMultiplier = Double.random(in: 0.8 ... 1.3)
        let shouldRotate = Bool.random()

        return ObstacleGenerationPattern(
            type: .single,
            obstacleType: selectWeightedObstacleType(),
            speedMultiplier: speedMultiplier,
            sizeMultiplier: sizeMultiplier,
            shouldRotate: shouldRotate,
            colorVariation: generateColorVariation()
        )
    }

    private func createClusterPattern() -> ObstacleGenerationPattern {
        let clusterSize = Int.random(in: 2 ... 5)
        let speedMultiplier = Double.random(in: 0.9 ... 1.2) * currentDifficulty.obstacleSpeed
        let sizeMultiplier = Double.random(in: 0.7 ... 1.0)

        return ObstacleGenerationPattern(
            type: .cluster,
            obstacleType: selectWeightedObstacleType(),
            speedMultiplier: speedMultiplier,
            sizeMultiplier: sizeMultiplier,
            shouldRotate: false,
            clusterSize: clusterSize,
            clusterSpacing: Double.random(in: 20 ... 50)
        )
    }

    private func createWavePattern() -> ObstacleGenerationPattern {
        let waveSize = Int.random(in: 3 ... 7)
        let waveDelay = Double.random(in: 0.15 ... 0.4)
        let speedMultiplier = Double.random(in: 1.0 ... 1.3) * currentDifficulty.obstacleSpeed

        return ObstacleGenerationPattern(
            type: .wave,
            obstacleType: selectWeightedObstacleType(),
            speedMultiplier: speedMultiplier,
            shouldRotate: Bool.random(),
            waveSize: waveSize,
            waveDelay: waveDelay
        )
    }

    private func createComplexPattern() -> ObstacleGenerationPattern {
        let patternType = ObstaclePatternType.allCases.filter { $0 != .single }.randomElement() ?? .cluster

        return ObstacleGenerationPattern(
            type: .pattern,
            obstacleType: selectWeightedObstacleType(),
            patternType: patternType,
            speedMultiplier: Double.random(in: 0.8 ... 1.2) * currentDifficulty.obstacleSpeed,
            sizeMultiplier: Double.random(in: 0.9 ... 1.1),
            shouldRotate: false
        )
    }

    private func selectWeightedObstacleType() -> Obstacle.ObstacleType {
        let level = GameDifficulty.getDifficultyLevel(for: Int(currentDifficulty.scoreMultiplier * 10))

        if level >= 8 {
            let types: [Obstacle.ObstacleType] = [.spike, .block, .moving, .pulsing, .rotating, .bouncing, .teleporting, .splitting, .laser]
            return types.randomElement() ?? .block
        } else if level >= 6 {
            let types: [Obstacle.ObstacleType] = [.spike, .block, .moving, .pulsing, .rotating, .bouncing, .teleporting]
            return types.randomElement() ?? .block
        } else if level >= 4 {
            let types: [Obstacle.ObstacleType] = [.spike, .block, .moving, .pulsing, .rotating, .bouncing]
            return types.randomElement() ?? .block
        } else if level >= 3 {
            let types: [Obstacle.ObstacleType] = [.block, .moving, .pulsing, .rotating]
            return types.randomElement() ?? .block
        } else if level >= 2 {
            let types: [Obstacle.ObstacleType] = [.block, .moving, .pulsing]
            return types.randomElement() ?? .block
        } else {
            return .block
        }
    }

    private func generateColorVariation() -> SKColor? {
        let shouldVary = Double.random(in: 0 ..< 1) < 0.3 // 30% chance
        if shouldVary {
            let hue = Double.random(in: 0 ..< 1)
            return SKColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1.0)
        }
        return nil
    }

    // MARK: - Position Calculation Methods

    @MainActor
    func calculateDynamicPosition(for obstacle: Obstacle, in frame: CGRect, pattern: ObstacleGenerationPattern) -> CGPoint {
        let margin: CGFloat = 20
        let minY = frame.minY - obstacle.node.frame.height
        let maxY = frame.maxY + obstacle.node.frame.height

        // Add some randomness to Y position
        let yPosition = CGFloat.random(in: minY ... maxY)

        // X position from right side
        let xPosition = frame.maxX + obstacle.node.frame.width / 2

        return CGPoint(x: xPosition, y: yPosition)
    }

    func calculateClusterBasePosition(in frame: CGRect, pattern: ObstacleGenerationPattern) -> CGPoint {
        let margin: CGFloat = 30
        let minY = frame.minY + margin
        let maxY = frame.maxY - margin

        let yPosition = CGFloat.random(in: minY ... maxY)
        let xPosition = frame.maxX + 50 // Start further right for cluster

        return CGPoint(x: xPosition, y: yPosition)
    }

    func calculateClusterPosition(basePosition: CGPoint, index: Int, total: Int, pattern: ObstacleGenerationPattern) -> CGPoint {
        let spacing = pattern.clusterSpacing ?? 40
        let verticalSpread: CGFloat = 60

        let xOffset = CGFloat(index) * spacing
        let yOffset = CGFloat(index - total / 2) * (verticalSpread / CGFloat(total))

        return CGPoint(
            x: basePosition.x + xOffset,
            y: basePosition.y + yOffset
        )
    }

    func calculateWavePosition(index: Int, total: Int, in frame: CGRect, pattern: ObstacleGenerationPattern) -> CGPoint {
        let margin: CGFloat = 20
        let minY = frame.minY + margin
        let maxY = frame.maxY - margin

        // Create a wave-like Y distribution
        let waveAmplitude = (maxY - minY) * 0.3
        let waveFrequency = Double.pi * 2 / Double(total)
        let yOffset = sin(Double(index) * waveFrequency) * waveAmplitude

        let yPosition = (minY + maxY) / 2 + yOffset
        let xPosition = frame.maxX + 30 + CGFloat(index) * 10

        return CGPoint(x: xPosition, y: yPosition)
    }

    func calculatePatternPositions(type: ObstaclePatternType, in frame: CGRect, pattern: ObstacleGenerationPattern) -> [CGPoint] {
        // For now, implement a simple zigzag pattern
        let positions: [CGPoint] = [
            CGPoint(x: frame.maxX + 50, y: frame.midY - 50),
            CGPoint(x: frame.maxX + 100, y: frame.midY + 50),
            CGPoint(x: frame.maxX + 150, y: frame.midY - 50),
            CGPoint(x: frame.maxX + 200, y: frame.midY + 50),
        ]
        return positions
    }

    // MARK: - Movement Creation Methods

    @MainActor
    func createDynamicMovement(for obstacle: Obstacle, pattern: ObstacleGenerationPattern) -> SKAction {
        let fallDuration = 3.0 / (pattern.speedMultiplier ?? currentDifficulty.obstacleSpeed)
        let moveAction = SKAction.moveTo(y: -obstacle.node.frame.height, duration: fallDuration)
        return moveAction
    }

    @MainActor
    func createClusterMovement(for obstacle: Obstacle, pattern: ObstacleGenerationPattern, index: Int) -> SKAction {
        let fallDuration = 3.5 / (pattern.speedMultiplier ?? currentDifficulty.obstacleSpeed)
        let moveAction = SKAction.moveTo(y: -obstacle.node.frame.height, duration: fallDuration)
        return moveAction
    }

    @MainActor
    func createWaveMovement(for obstacle: Obstacle, pattern: ObstacleGenerationPattern) -> SKAction {
        let fallDuration = 2.8 / (pattern.speedMultiplier ?? currentDifficulty.obstacleSpeed)
        let moveAction = SKAction.moveTo(y: -obstacle.node.frame.height, duration: fallDuration)
        return moveAction
    }

    @MainActor
    func createPatternMovement(for obstacle: Obstacle, pattern: ObstacleGenerationPattern) -> SKAction {
        let fallDuration = 3.2 / (pattern.speedMultiplier ?? currentDifficulty.obstacleSpeed)
        let moveAction = SKAction.moveTo(y: -obstacle.node.frame.height, duration: fallDuration)
        return moveAction
    }
}

/// Obstacle metrics for analytics dashboard
struct ObstacleMetrics {
    let spawnRate: Double
    let dynamicPatternUsage: Double
}
