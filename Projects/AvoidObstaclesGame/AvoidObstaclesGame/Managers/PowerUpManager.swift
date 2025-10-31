//
// PowerUpManager.swift
// AvoidObstaclesGame
//
// Manages adaptive power-up spawning and management based on player skill level
// and game context using AI-powered decision making.
//

import Combine
import Foundation
import SpriteKit

/// Protocol for power-up related events
@MainActor
protocol PowerUpDelegate: AnyObject {
    func powerUpDidSpawn(_ powerUp: PowerUp)
    func powerUpDidCollect(_ powerUp: PowerUp, by player: Player)
    func powerUpDidExpire(_ powerUp: PowerUp)
}

/// AI-powered adaptive power-up manager
@MainActor
final class PowerUpManager {
    // MARK: - Properties

    /// Delegate for power-up events
    weak var delegate: PowerUpDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// AI difficulty manager for adaptive spawning
    private let aiDifficultyManager: AIAdaptiveDifficultyManager

    /// Currently active power-ups
    private var activePowerUps: Set<PowerUp> = []

    /// Power-up spawn timer
    private var spawnTimer: Timer?

    /// Current game difficulty
    private var currentDifficulty: GameDifficulty

    /// Player skill assessment
    private var currentPlayerSkill: PlayerSkillLevel = .beginner

    /// Adaptive spawning configuration
    private var spawningConfig: AdaptiveSpawningConfig

    /// Spawn interval range (seconds)
    private let spawnIntervalRange: ClosedRange<Double> = 3.0 ... 8.0

    /// Maximum active power-ups
    private let maxActivePowerUps = 3

    /// Publisher for power-up metrics
    let powerUpMetricsPublisher = PassthroughSubject<PowerUpMetrics, Never>()

    // MARK: - Initialization

    init(scene: SKScene, aiDifficultyManager: AIAdaptiveDifficultyManager) {
        self.scene = scene
        self.aiDifficultyManager = aiDifficultyManager
        self.currentDifficulty = GameDifficulty.getDifficulty(for: 0)
        self.spawningConfig = AdaptiveSpawningConfig()

        setupAIDelegates()
        updateSpawningConfig()
    }

    /// Updates the scene reference
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    /// Updates the power-up manager with delta time
    /// - Parameter deltaTime: Time elapsed since last update
    func update(_ deltaTime: TimeInterval) {
        // Update power-up-specific logic here
        // For now, this is mainly for future expansion
    }

    // MARK: - Public Interface

    /// Starts adaptive power-up spawning
    func startSpawning() {
        stopSpawning() // Clean up any existing timer

        let initialInterval = calculateSpawnInterval()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: initialInterval, repeats: false) { [weak self] _ in
            self?.spawnAdaptivePowerUp()
            self?.scheduleNextSpawn()
        }
    }

    /// Stops power-up spawning
    func stopSpawning() {
        spawnTimer?.invalidate()
        spawnTimer = nil
    }

    /// Updates current difficulty and adjusts spawning
    func updateDifficulty(_ difficulty: GameDifficulty) {
        self.currentDifficulty = difficulty
        updateSpawningConfig()
    }

    /// Updates player skill level for adaptive spawning
    func updatePlayerSkill(_ skillLevel: PlayerSkillLevel) {
        self.currentPlayerSkill = skillLevel
        updateSpawningConfig()
    }

    /// Records power-up collection for learning
    func recordPowerUpCollection(_ powerUp: PowerUp, success: Bool) {
        spawningConfig.recordCollection(powerUp.type, success: success)
        updateSpawningConfig()
    }

    /// Gets all active power-ups
    func getActivePowerUps() -> [SKNode] {
        activePowerUps.map(\.node)
    }

    /// Gets the PowerUp object for a given SKNode
    func getPowerUp(for node: SKNode) -> PowerUp? {
        activePowerUps.first { $0.node === node }
    }

    /// Removes all active power-ups
    func removeAllPowerUps() {
        for powerUp in activePowerUps {
            powerUp.node.removeFromParent()
            delegate?.powerUpDidExpire(powerUp)
        }
        activePowerUps.removeAll()
    }

    /// Gets spawning statistics
    func getSpawningStats() -> PowerUpSpawningStats {
        spawningConfig.getStats()
    }

    // MARK: - Private Methods

    private func setupAIDelegates() {
        aiDifficultyManager.delegate = self
    }

    private func updateSpawningConfig() {
        spawningConfig.updateConfig(
            difficulty: currentDifficulty,
            playerSkill: currentPlayerSkill,
            scene: scene
        )
    }

    private func calculateSpawnInterval() -> Double {
        let baseInterval = spawningConfig.calculateBaseSpawnInterval()
        let randomVariation = Double.random(in: -1.0 ... 1.0)
        return max(spawnIntervalRange.lowerBound,
                   min(spawnIntervalRange.upperBound, baseInterval + randomVariation))
    }

    private func scheduleNextSpawn() {
        let nextInterval = calculateSpawnInterval()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: nextInterval, repeats: false) { [weak self] _ in
            self?.spawnAdaptivePowerUp()
            self?.scheduleNextSpawn()
        }
    }

    private func spawnAdaptivePowerUp() {
        guard let scene, activePowerUps.count < maxActivePowerUps else { return }

        // Select power-up type based on AI analysis
        let powerUpType = spawningConfig.selectPowerUpType()

        // Calculate optimal spawn position
        let spawnPosition = spawningConfig.calculateSpawnPosition(for: powerUpType, in: scene.frame)

        // Create and configure power-up
        let powerUp = createPowerUp(ofType: powerUpType, at: spawnPosition)

        // Add to scene and tracking
        scene.addChild(powerUp.node)
        activePowerUps.insert(powerUp)

        // Set up expiration timer
        setupPowerUpExpiration(for: powerUp)

        delegate?.powerUpDidSpawn(powerUp)
    }

    private func createPowerUp(ofType type: PowerUpType, at position: CGPoint) -> PowerUp {
        let powerUp = PowerUp(type: type)
        powerUp.node.position = position

        // Configure physics
        powerUp.node.physicsBody = SKPhysicsBody(rectangleOf: powerUp.node.size)
        powerUp.node.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUp.node.physicsBody?.contactTestBitMask = PhysicsCategory.player
        powerUp.node.physicsBody?.collisionBitMask = PhysicsCategory.none
        powerUp.node.physicsBody?.affectedByGravity = false
        powerUp.node.physicsBody?.isDynamic = true

        // Add visual effects
        addPowerUpEffects(to: powerUp)

        return powerUp
    }

    private func addPowerUpEffects(to powerUp: PowerUp) {
        // Add glow effect based on rarity
        let glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        let glowFilter = CIFilter(name: "CIGaussianBlur")
        glowFilter?.setValue(powerUp.type.rarity.glowIntensity * 3.0, forKey: kCIInputRadiusKey)
        glowEffect.filter = glowFilter

        let glowNode = SKSpriteNode(color: powerUp.type.color.withAlphaComponent(0.6),
                                    size: CGSize(width: 35, height: 35))
        glowEffect.addChild(glowNode)
        glowEffect.zPosition = -1
        powerUp.node.addChild(glowEffect)

        // Add pulsing animation with rarity-based speed
        let pulseSpeed = 0.6 / Double(powerUp.type.rarity.glowIntensity + 0.5)
        let scaleUp = SKAction.scale(to: 1.3, duration: pulseSpeed)
        let scaleDown = SKAction.scale(to: 1.0, duration: pulseSpeed)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        powerUp.node.run(repeatPulse)

        // Add particle effect for rare and above power-ups
        if powerUp.type.rarity != .common && powerUp.type.rarity != .uncommon {
            addParticleEffect(to: powerUp)
        }

        // Add special effects for legendary power-ups
        if powerUp.type.rarity == .legendary {
            addLegendaryEffect(to: powerUp)
        }
    }

    private func addLegendaryEffect(to powerUp: PowerUp) {
        // Add rotating star field effect
        let starField = SKEmitterNode()
        starField.particleTexture = SKTexture(imageNamed: "star") // Assuming a star texture exists
        starField.particleBirthRate = 15
        starField.particleLifetime = 2.0
        starField.particlePositionRange = CGVector(dx: 40, dy: 40)
        starField.particleSpeed = 30
        starField.particleSpeedRange = 15
        starField.particleColor = .white
        starField.particleColorBlendFactor = 1.0
        starField.particleAlpha = 0.9
        starField.particleAlphaSpeed = -0.3

        // Rotate the emitter
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
        starField.run(SKAction.repeatForever(rotateAction))

        powerUp.node.addChild(starField)
    }

    private func addParticleEffect(to powerUp: PowerUp) {
        let particleEmitter = SKEmitterNode()
        particleEmitter.particleTexture = SKTexture(imageNamed: "spark") // Assuming a spark texture exists
        particleEmitter.particleBirthRate = 20
        particleEmitter.particleLifetime = 1.0
        particleEmitter.particlePositionRange = CGVector(dx: 15, dy: 15)
        particleEmitter.particleSpeed = 50
        particleEmitter.particleSpeedRange = 25
        particleEmitter.particleColor = powerUp.type.color
        particleEmitter.particleColorBlendFactor = 1.0
        particleEmitter.particleAlpha = 0.8
        particleEmitter.particleAlphaSpeed = -0.5

        powerUp.node.addChild(particleEmitter)
    }

    private func setupPowerUpExpiration(for powerUp: PowerUp) {
        let expirationTime = spawningConfig.getExpirationTime(for: powerUp.type)

        Timer.scheduledTimer(withTimeInterval: expirationTime, repeats: false) { [weak self] _ in
            self?.expirePowerUp(powerUp)
        }
    }

    private func expirePowerUp(_ powerUp: PowerUp) {
        guard activePowerUps.contains(powerUp) else { return }

        activePowerUps.remove(powerUp)
        powerUp.node.removeFromParent()
        delegate?.powerUpDidExpire(powerUp)
    }

    /// Called when a power-up is collected by the player
    func powerUpCollected(_ powerUp: PowerUp, by player: Player) {
        guard activePowerUps.contains(powerUp) else { return }

        activePowerUps.remove(powerUp)
        powerUp.node.removeFromParent()

        // Record successful collection
        recordPowerUpCollection(powerUp, success: true)

        delegate?.powerUpDidCollect(powerUp, by: player)
    }
}

// MARK: - AIAdaptiveDifficultyDelegate

@MainActor
extension PowerUpManager: AIAdaptiveDifficultyDelegate {
    func difficultyDidAdjust(to newDifficulty: AIAdaptiveDifficulty, reason: DifficultyAdjustmentReason) {
        // Update spawning based on difficulty changes
        let gameDifficulty = newDifficulty.toGameDifficulty()
        updateDifficulty(gameDifficulty)
    }

    func playerSkillAssessed(skillLevel: PlayerSkillLevel, confidence: Double) {
        // Update spawning based on skill assessment
        if confidence > 0.7 {
            updatePlayerSkill(skillLevel)
        }
    }
}

// MARK: - Supporting Classes

/// Configuration for adaptive power-up spawning
class AdaptiveSpawningConfig {
    private var collectionHistory: [PowerUpType: (successes: Int, attempts: Int)] = [:]
    private var spawnHistory: [PowerUpType: Date] = [:]
    private var difficulty: GameDifficulty = .getDifficulty(for: 0)
    private var playerSkill: PlayerSkillLevel = .beginner
    private weak var scene: SKScene?

    // Base spawn rates by skill level
    private let baseSpawnRates: [PlayerSkillLevel: [PowerUpType: Double]] = [
        .beginner: [.shield: 0.4, .speed: 0.3, .magnet: 0.2, .slowMotion: 0.1],
        .novice: [.shield: 0.3, .speed: 0.3, .magnet: 0.2, .slowMotion: 0.15, .multiBall: 0.05],
        .intermediate: [.shield: 0.25, .speed: 0.25, .magnet: 0.2, .slowMotion: 0.15, .multiBall: 0.1, .laser: 0.05],
        .advanced: [.shield: 0.2, .speed: 0.25, .magnet: 0.2, .slowMotion: 0.15, .multiBall: 0.1, .laser: 0.07, .freeze: 0.03],
        .expert: [.shield: 0.15, .speed: 0.2, .magnet: 0.25, .slowMotion: 0.15, .multiBall: 0.1, .laser: 0.08, .freeze: 0.05, .teleport: 0.02],
        .master: [.shield: 0.1, .speed: 0.15, .magnet: 0.25, .slowMotion: 0.15, .multiBall: 0.1, .laser: 0.08, .freeze: 0.05, .teleport: 0.03, .scoreMultiplier: 0.02, .timeBonus: 0.02],
    ]

    func updateConfig(difficulty: GameDifficulty, playerSkill: PlayerSkillLevel, scene: SKScene?) {
        self.difficulty = difficulty
        self.playerSkill = playerSkill
        self.scene = scene
    }

    func calculateBaseSpawnInterval() -> Double {
        // Base interval decreases with difficulty and increases with skill
        let difficultyMultiplier = 1.0 / (difficulty.scoreMultiplier + 0.5)
        let skillMultiplier = skillSpawnMultiplier()

        let baseInterval = 5.0 * difficultyMultiplier * skillMultiplier
        return max(2.0, min(10.0, baseInterval))
    }

    private func skillSpawnMultiplier() -> Double {
        switch playerSkill {
        case .beginner: return 1.5
        case .novice: return 1.3
        case .intermediate: return 1.0
        case .advanced: return 0.8
        case .expert: return 0.6
        case .master: return 0.5
        }
    }

    func selectPowerUpType() -> PowerUpType {
        let availableRates = baseSpawnRates[playerSkill] ?? baseSpawnRates[.beginner]!

        // Apply rarity-based weighting
        var weightedRates: [PowerUpType: Double] = [:]
        for (type, baseRate) in availableRates {
            let rarityMultiplier = type.rarity.spawnWeight
            weightedRates[type] = baseRate * rarityMultiplier
        }

        // Adjust rates based on collection history
        for (type, history) in collectionHistory {
            if history.attempts > 0 {
                let successRate = Double(history.successes) / Double(history.attempts)
                // Boost power-ups that player struggles with
                if successRate < 0.3 {
                    weightedRates[type] = (weightedRates[type] ?? 0.1) * 1.5
                }
                // Reduce power-ups that player collects frequently
                else if successRate > 0.8 {
                    weightedRates[type] = (weightedRates[type] ?? 0.1) * 0.7
                }
            }
        }

        // Normalize rates
        let total = weightedRates.values.reduce(0, +)
        if total > 0 {
            for (type, rate) in weightedRates {
                weightedRates[type] = rate / total
            }
        }

        // Select based on weighted random
        let randomValue = Double.random(in: 0 ..< 1)
        var cumulative = 0.0

        for (type, rate) in weightedRates.sorted(by: { $0.value > $1.value }) {
            cumulative += rate
            if randomValue <= cumulative {
                return type
            }
        }

        return .shield // Fallback
    }

    func calculateSpawnPosition(for powerUpType: PowerUpType, in frame: CGRect) -> CGPoint {
        let margin: CGFloat = 30
        let minY = frame.minY + margin
        let maxY = frame.maxY - margin

        // Strategic positioning based on power-up type
        var yPosition: CGFloat

        switch powerUpType {
        case .shield:
            // Place shields in more dangerous areas (middle)
            yPosition = CGFloat.random(in: minY + (maxY - minY) * 0.3 ... minY + (maxY - minY) * 0.7)
        case .speed:
            // Place speed boosts in open areas
            yPosition = CGFloat.random(in: minY ... maxY)
        case .magnet:
            // Place magnets near edges where coins might be
            let edgeBias = Bool.random() ? 0.1 : 0.9
            yPosition = minY + (maxY - minY) * edgeBias + CGFloat.random(in: -20 ... 20)
        case .slowMotion:
            // Place slow motion power-ups in areas with high obstacle density
            yPosition = CGFloat.random(in: minY + (maxY - minY) * 0.2 ... maxY - margin)
        case .multiBall:
            // Place multi-ball power-ups in open areas, avoiding edges
            yPosition = CGFloat.random(in: minY + margin ... maxY - margin)
        case .laser:
            // Place laser power-ups near the player's path
            yPosition = CGFloat.random(in: minY ... maxY)
        case .freeze:
            // Place freeze power-ups in strategic locations to block paths
            yPosition = CGFloat.random(in: minY + (maxY - minY) * 0.4 ... minY + (maxY - minY) * 0.6)
        case .teleport:
            // Place teleport power-ups at the edges, leading to unknown areas
            yPosition = CGFloat.random(in: minY ... maxY)
        case .scoreMultiplier, .timeBonus:
            // Place score multipliers and time bonuses in less accessible areas
            yPosition = CGFloat.random(in: minY + (maxY - minY) * 0.5 ... maxY - margin)
        }

        let xPosition = frame.maxX + 40 // Spawn from right side

        return CGPoint(x: xPosition, y: yPosition)
    }

    func getExpirationTime(for powerUpType: PowerUpType) -> TimeInterval {
        // Base time from power-up type, adjusted by difficulty and rarity
        let baseTime = powerUpType.duration

        // Legendary power-ups last longer
        let rarityMultiplier = powerUpType.rarity == .legendary ? 1.5 :
            powerUpType.rarity == .epic ? 1.2 : 1.0

        // Difficulty adjustment - harder difficulties have shorter times
        let difficultyMultiplier = 1.0 / (difficulty.scoreMultiplier + 0.5)

        return baseTime * difficultyMultiplier * rarityMultiplier
    }

    func isRarePowerUp(_ type: PowerUpType) -> Bool {
        // Consider rare, epic, and legendary as "rare" for special effects
        type.rarity == .rare || type.rarity == .epic || type.rarity == .legendary
    }

    func recordCollection(_ type: PowerUpType, success: Bool) {
        let current = collectionHistory[type] ?? (successes: 0, attempts: 0)
        collectionHistory[type] = (
            successes: current.successes + (success ? 1 : 0),
            attempts: current.attempts + 1
        )
        spawnHistory[type] = Date()
    }

    func getStats() -> PowerUpSpawningStats {
        let totalSpawned = collectionHistory.values.reduce(0) { $0 + $1.attempts }
        let totalCollected = collectionHistory.values.reduce(0) { $0 + $1.successes }

        return PowerUpSpawningStats(
            totalSpawned: totalSpawned,
            totalCollected: totalCollected,
            collectionRate: totalSpawned > 0 ? Double(totalCollected) / Double(totalSpawned) : 0.0,
            typeStats: collectionHistory.map { type, stats in
                (type, Double(stats.successes) / Double(max(stats.attempts, 1)))
            }
        )
    }
}

/// Statistics for power-up spawning
struct PowerUpSpawningStats: Equatable {
    let totalSpawned: Int
    let totalCollected: Int
    let collectionRate: Double
    let typeStats: [(PowerUpType, Double)]

    static func == (lhs: PowerUpSpawningStats, rhs: PowerUpSpawningStats) -> Bool {
        lhs.totalSpawned == rhs.totalSpawned &&
            lhs.totalCollected == rhs.totalCollected &&
            lhs.collectionRate == rhs.collectionRate &&
            lhs.typeStats.elementsEqual(rhs.typeStats) { $0.0 == $1.0 && $0.1 == $1.1 }
    }
}

/// Represents a power-up in the game
class PowerUp {
    let type: PowerUpType
    let node: SKSpriteNode
    let spawnTime: Date

    init(type: PowerUpType) {
        self.type = type
        self.node = SKSpriteNode(color: type.color, size: CGSize(width: 25, height: 25))
        self.spawnTime = Date()

        node.name = "powerUp"
    }
}

// MARK: - Hashable

extension PowerUp: Hashable {
    static func == (lhs: PowerUp, rhs: PowerUp) -> Bool {
        lhs.type == rhs.type && lhs.spawnTime == rhs.spawnTime
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(spawnTime)
    }
}
