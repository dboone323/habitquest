//
// EffectsManager.swift
// AvoidObstaclesGame
//
// Manages particle effects, explosions, visual feedback, and animations.
//

import SpriteKit
import UIKit

/// Manages visual effects and animations
class EffectsManager {
    // MARK: - Properties

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Pre-loaded particle effects
    private var explosionEmitter: SKEmitterNode?
    private var trailEmitter: SKEmitterNode?
    private var sparkleEmitter: SKEmitterNode?

    /// Effect pools for performance
    private var explosionPool: [SKEmitterNode] = []
    private var trailPool: [SKEmitterNode] = []

    /// Maximum pool sizes
    private let maxExplosionPoolSize = 5
    private let maxTrailPoolSize = 10

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        self.preloadEffects()
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Effect Preloading

    /// Preloads particle effects for better performance
    private func preloadEffects() {
        self.createExplosionEffect()
        self.createTrailEffect()
        self.createSparkleEffect()
    }

    /// Creates the explosion particle effect
    private func createExplosionEffect() {
        self.explosionEmitter = SKEmitterNode()
        guard let explosion = explosionEmitter else { return }

        // Create particle texture programmatically
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        let sparkImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 8, height: 8)))
        }

        // Configure explosion particles
        explosion.particleTexture = SKTexture(image: sparkImage)
        explosion.particleBirthRate = 300
        explosion.numParticlesToEmit = 100
        explosion.particleLifetime = 1.0
        explosion.particleLifetimeRange = 0.5

        // Particle appearance
        explosion.particleScale = 0.1
        explosion.particleScaleRange = 0.05
        explosion.particleScaleSpeed = -0.1
        explosion.particleAlpha = 1.0
        explosion.particleAlphaSpeed = -1.0
        explosion.particleColor = .orange
        explosion.particleColorBlendFactor = 1.0

        // Particle movement
        explosion.emissionAngle = 0
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 100
        explosion.xAcceleration = 0
        explosion.yAcceleration = -100

        // Blend mode for better visual effect
        explosion.particleBlendMode = .add
        explosion.zPosition = 50
    }

    /// Creates the trail particle effect
    private func createTrailEffect() {
        self.trailEmitter = SKEmitterNode()
        guard let trail = trailEmitter else { return }

        // Create particle texture
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        let particleImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.cyan.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
        }

        // Configure trail particles
        trail.particleTexture = SKTexture(image: particleImage)
        trail.particleBirthRate = 20
        trail.numParticlesToEmit = 50
        trail.particleLifetime = 0.5
        trail.particleLifetimeRange = 0.2
        trail.particleScale = 0.5
        trail.particleScaleRange = 0.2
        trail.particleAlpha = 0.6
        trail.particleAlphaSpeed = -1.0
        trail.particleSpeed = 50
        trail.emissionAngle = .pi
        trail.emissionAngleRange = .pi / 4
        trail.particleColor = .cyan
        trail.particleBlendMode = .add
        trail.zPosition = -2
    }

    /// Creates the sparkle particle effect
    private func createSparkleEffect() {
        self.sparkleEmitter = SKEmitterNode()
        guard let sparkle = sparkleEmitter else { return }

        // Create particle texture
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 6, height: 6))
        let sparkleImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.yellow.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 6, height: 6)))
        }

        // Configure sparkle particles
        sparkle.particleTexture = SKTexture(image: sparkleImage)
        sparkle.particleBirthRate = 50
        sparkle.numParticlesToEmit = 30
        sparkle.particleLifetime = 0.8
        sparkle.particleLifetimeRange = 0.3
        sparkle.particleScale = 0.3
        sparkle.particleScaleRange = 0.1
        sparkle.particleAlpha = 0.8
        sparkle.particleAlphaSpeed = -0.8
        sparkle.particleSpeed = 80
        sparkle.emissionAngle = 0
        sparkle.emissionAngleRange = CGFloat.pi * 2
        sparkle.particleColor = .yellow
        sparkle.particleBlendMode = .add
        sparkle.zPosition = 40
    }

    // MARK: - Explosion Effects

    /// Creates an explosion effect at the specified position
    /// - Parameter position: Where to create the explosion
    func createExplosion(at position: CGPoint) {
        guard let scene else { return }

        let explosion = self.getExplosionFromPool()
        explosion.position = position
        scene.addChild(explosion)

        // Auto-remove after animation
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent(),
        ])

        explosion.run(removeAction)
    }

    /// Gets an explosion effect from the pool or creates a new one
    private func getExplosionFromPool() -> SKEmitterNode {
        if let explosion = explosionPool.popLast() {
            // Reset the emitter
            explosion.resetSimulation()
            return explosion
        } else {
            // Create new explosion
            let explosion = self.explosionEmitter?.copy() as? SKEmitterNode ?? SKEmitterNode()
            return explosion
        }
    }

    /// Returns an explosion effect to the pool
    private func returnExplosionToPool(_ explosion: SKEmitterNode) {
        explosion.removeFromParent()
        if self.explosionPool.count < self.maxExplosionPoolSize {
            self.explosionPool.append(explosion)
        }
    }

    // MARK: - Trail Effects

    /// Creates a trail effect attached to a node
    /// - Parameter node: The node to attach the trail to
    /// - Returns: The trail emitter node
    func createTrail(for node: SKNode) -> SKEmitterNode? {
        guard let trail = trailEmitter?.copy() as? SKEmitterNode else { return nil }
        node.addChild(trail)
        return trail
    }

    // MARK: - Screen Effects

    /// Creates a screen flash effect
    /// - Parameter color: The color of the flash
    /// - Parameter duration: How long the flash lasts
    func createScreenFlash(color: UIColor = .white, duration: TimeInterval = 0.1) {
        guard let scene else { return }

        let flashNode = SKSpriteNode(color: color, size: scene.size)
        flashNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        flashNode.alpha = 0.3
        flashNode.zPosition = 1000

        scene.addChild(flashNode)

        let fadeAction = SKAction.sequence([
            SKAction.fadeOut(withDuration: duration),
            SKAction.removeFromParent(),
        ])

        flashNode.run(fadeAction)
    }

    /// Creates a level up celebration effect
    func createLevelUpCelebration() {
        guard let scene else { return }

        // Create multiple sparkle effects around the screen
        let center = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)

        for i in 0 ..< 8 {
            let angle = (CGFloat.pi * 2 / 8) * CGFloat(i)
            let distance: CGFloat = 100
            let position = CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )

            self.createSparkleBurst(at: position)
        }

        // Screen flash
        self.createScreenFlash(color: .yellow, duration: 0.2)
    }

    /// Creates a sparkle burst at a position
    /// - Parameter position: Where to create the sparkle burst
    func createSparkleBurst(at position: CGPoint) {
        guard let scene, let sparkle = sparkleEmitter?.copy() as? SKEmitterNode else { return }

        sparkle.position = position
        scene.addChild(sparkle)

        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent(),
        ])

        sparkle.run(removeAction)
    }

    // MARK: - Score Effects

    /// Creates a floating score popup
    /// - Parameters:
    ///   - score: The score value to display
    ///   - position: Where to show the popup
    ///   - color: The color of the text
    func createScorePopup(score: Int, at position: CGPoint, color: UIColor = .yellow) {
        guard let scene else { return }

        let scoreLabel = SKLabelNode(fontNamed: "Arial-Bold")
        scoreLabel.text = "+\(score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = color
        scoreLabel.position = position
        scoreLabel.zPosition = 50

        scene.addChild(scoreLabel)

        // Animate popup
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        let animation = SKAction.group([moveUp, fadeOut])
        let sequence = SKAction.sequence([animation, remove])

        scoreLabel.run(sequence)
    }

    // MARK: - Background Effects

    /// Updates background effects based on game state
    /// - Parameter difficulty: Current game difficulty
    func updateBackgroundEffects(for difficulty: GameDifficulty) {
        // Adjust background animation speed based on difficulty
        let speedMultiplier = difficulty.obstacleSpeed / 3.5

        // Update cloud movement speed
        self.enumerateClouds { cloud in
            if cloud.action(forKey: "move") != nil {
                cloud.removeAction(forKey: "move")

                let newDuration = 20.0 / speedMultiplier // Slower clouds at higher difficulty
                if let spriteCloud = cloud as? SKSpriteNode {
                    let moveAction = SKAction.moveBy(x: -spriteCloud.size.width - 60, y: 0, duration: newDuration)
                    let resetAction = SKAction.moveTo(x: spriteCloud.size.width + 60, duration: 0)
                    let sequence = SKAction.sequence([moveAction, resetAction])
                    cloud.run(SKAction.repeatForever(sequence), withKey: "move")
                }
            }
        }
    }

    /// Enumerates all cloud nodes in the scene
    private func enumerateClouds(action: @escaping (SKNode) -> Void) {
        self.scene?.enumerateChildNodes(withName: "cloud") { node, _ in
            action(node)
        }
    }

    // MARK: - Power-up Effects

    /// Creates a power-up collection effect
    /// - Parameter position: Where the power-up was collected
    func createPowerUpCollectionEffect(at position: CGPoint) {
        // Sparkle burst
        self.createSparkleBurst(at: position)

        // Screen flash
        self.createScreenFlash(color: .green, duration: 0.15)

        // Sound effect would be triggered here (when audio is implemented)
    }

    /// Creates a shield activation effect
    /// - Parameter position: Where the shield is activated
    func createShieldActivationEffect(at position: CGPoint) {
        guard let scene else { return }

        // Create expanding circle effect
        let circle = SKShapeNode(circleOfRadius: 10)
        circle.fillColor = .clear
        circle.strokeColor = .green
        circle.lineWidth = 3
        circle.glowWidth = 2
        circle.position = position
        circle.zPosition = 45

        scene.addChild(circle)

        let expand = SKAction.scale(to: 3.0, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        let animation = SKAction.group([expand, fade])
        circle.run(SKAction.sequence([animation, remove]))
    }

    // MARK: - Performance Optimization

    /// Cleans up unused effects
    func cleanupUnusedEffects() {
        // Return explosions to pool if they're done
        self.scene?.enumerateChildNodes(withName: "explosion") { node, _ in
            if let emitter = node as? SKEmitterNode, emitter.numParticlesToEmit == 0 {
                self.returnExplosionToPool(emitter)
            }
        }
    }

    // MARK: - Utility Methods

    /// Creates a simple particle texture of specified color and size
    /// - Parameters:
    ///   - color: The color of the particle
    ///   - size: The size of the particle texture
    /// - Returns: A UIImage for use as particle texture
    func createParticleTexture(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Cleanup

    /// Cleans up all effects and pools
    func cleanup() {
        self.explosionPool.removeAll()
        self.trailPool.removeAll()
        self.explosionEmitter = nil
        self.trailEmitter = nil
        self.sparkleEmitter = nil
    }

    // MARK: - Async Effects

    /// Creates an explosion effect at the specified position asynchronously
    /// - Parameter position: Where to create the explosion
    func createExplosionAsync(at position: CGPoint) async {
        await Task.detached {
            self.createExplosion(at: position)
        }.value
    }

    /// Creates a trail effect attached to a node asynchronously
    /// - Parameter node: The node to attach the trail to
    /// - Returns: The trail emitter node
    func createTrailAsync(for node: SKNode) async -> SKEmitterNode? {
        await Task.detached {
            self.createTrail(for: node)
        }.value
    }

    /// Creates a screen flash effect asynchronously
    /// - Parameter color: The color of the flash
    /// - Parameter duration: How long the flash lasts
    func createScreenFlashAsync(color: UIColor = .white, duration: TimeInterval = 0.1) async {
        await Task.detached {
            self.createScreenFlash(color: color, duration: duration)
        }.value
    }

    /// Creates a level up celebration effect asynchronously
    func createLevelUpCelebrationAsync() async {
        await Task.detached {
            self.createLevelUpCelebration()
        }.value
    }

    /// Creates a sparkle burst at a position asynchronously
    /// - Parameter position: Where to create the sparkle burst
    func createSparkleBurstAsync(at position: CGPoint) async {
        await Task.detached {
            self.createSparkleBurst(at: position)
        }.value
    }

    /// Creates a floating score popup asynchronously
    /// - Parameters:
    ///   - score: The score value to display
    ///   - position: Where to show the popup
    ///   - color: The color of the text
    func createScorePopupAsync(score: Int, at position: CGPoint, color: UIColor = .yellow) async {
        await Task.detached {
            self.createScorePopup(score: score, at: position, color: color)
        }.value
    }

    /// Updates background effects based on game state asynchronously
    /// - Parameter difficulty: Current game difficulty
    func updateBackgroundEffectsAsync(for difficulty: GameDifficulty) async {
        await Task.detached {
            self.updateBackgroundEffects(for: difficulty)
        }.value
    }

    /// Creates a power-up collection effect asynchronously
    /// - Parameter position: Where the power-up was collected
    func createPowerUpCollectionEffectAsync(at position: CGPoint) async {
        await Task.detached {
            self.createPowerUpCollectionEffect(at: position)
        }.value
    }

    /// Creates a shield activation effect asynchronously
    /// - Parameter position: Where the shield is activated
    func createShieldActivationEffectAsync(at position: CGPoint) async {
        await Task.detached {
            self.createShieldActivationEffect(at: position)
        }.value
    }

    /// Cleans up unused effects asynchronously
    func cleanupUnusedEffectsAsync() async {
        await Task.detached {
            self.cleanupUnusedEffects()
        }.value
    }

    /// Cleans up all effects and pools asynchronously
    func cleanupAsync() async {
        await Task.detached {
            self.cleanup()
        }.value
    }
}
