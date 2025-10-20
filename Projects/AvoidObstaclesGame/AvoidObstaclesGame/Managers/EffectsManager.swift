//
// EffectsManager.swift
// AvoidObstaclesGame
//
// Manages particle effects, explosions, visual feedback, and animations.
//

import SpriteKit
#if os(iOS) || os(tvOS)
import UIKit
#endif

/// Types of weather conditions
enum WeatherType {
    case clear
    case rain
    case snow
    case fog
    case wind
    case storm
}

/// Types of lighting conditions
enum LightingType {
    case day
    case dusk
    case night
    case stormy
}

/// Environmental hazard types
enum EnvironmentalHazard {
    case lightning
    case tornado
    case earthquake
    case meteor
}

/// Manages visual effects and animations
@MainActor
class EffectsManager {
    // MARK: - Properties

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Pre-loaded particle effects
    private var explosionEmitter: SKEmitterNode?
    private var trailEmitter: SKEmitterNode?
    private var sparkleEmitter: SKEmitterNode?

    /// Environmental effect emitters
    private var rainEmitter: SKEmitterNode?
    private var snowEmitter: SKEmitterNode?
    private var fogEmitter: SKEmitterNode?
    private var windEmitter: SKEmitterNode?
    private var lightningEmitter: SKEmitterNode?

    /// Environmental overlay nodes
    private var weatherOverlay: SKSpriteNode?
    private var lightingOverlay: SKSpriteNode?
    private var fogOverlay: SKSpriteNode?

    /// Current environmental state
    private var currentWeather: WeatherType = .clear
    private var currentLighting: LightingType = .day
    private var weatherIntensity: Float = 0.0
    private var lightingIntensity: Float = 1.0

    /// Weather and lighting timers
    private var weatherChangeTimer: Timer?
    private var lightingChangeTimer: Timer?
    private var hazardTimer: Timer?
    private var stormTimer: Timer?

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
        self.createRainEffect()
        self.createSnowEffect()
        self.createFogEffect()
        self.createWindEffect()
        self.createLightningEffect()
        self.createWeatherOverlay()
        self.createLightingOverlay()
        self.createFogOverlay()
    }

    /// Creates the explosion particle effect
    private func createExplosionEffect() {
        self.explosionEmitter = SKEmitterNode()
        guard let explosion = explosionEmitter else { return }

        // Create particle texture programmatically
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        let sparkImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 8, height: 8)))
        }
        #else
        // For macOS, create a simple colored rectangle texture
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIConstantColorGenerator")!
        filter.setValue(CIColor(color: SKColor.white), forKey: kCIInputColorKey)
        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: CGSize(width: 8, height: 8))), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        let sparkImage = NSImage(cgImage: cgImage, size: CGSize(width: 8, height: 8))
        #endif

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
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        let particleImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.cyan.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
        }
        #else
        // For macOS, create a simple colored rectangle texture
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIConstantColorGenerator")!
        filter.setValue(CIColor(color: SKColor.cyan), forKey: kCIInputColorKey)
        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: CGSize(width: 4, height: 4))), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        let particleImage = NSImage(cgImage: cgImage, size: CGSize(width: 4, height: 4))
        #endif

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
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 6, height: 6))
        let sparkleImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.yellow.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 6, height: 6)))
        }
        #else
        // For macOS, create a simple colored rectangle texture
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIConstantColorGenerator")!
        filter.setValue(CIColor(color: SKColor.yellow), forKey: kCIInputColorKey)
        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: CGSize(width: 6, height: 6))), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        let sparkleImage = NSImage(cgImage: cgImage, size: CGSize(width: 6, height: 6))
        #endif

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

    /// Creates the rain particle effect
    private func createRainEffect() {
        self.rainEmitter = SKEmitterNode()
        guard let rain = rainEmitter else { return }

        // Create raindrop texture
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 8))
        let rainImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.blue.withAlphaComponent(0.6).cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 2, height: 8)))
        }
        #else
        // For macOS, create a simple colored rectangle texture
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIConstantColorGenerator")!
        filter.setValue(CIColor(color: SKColor.blue.withAlphaComponent(0.6)), forKey: kCIInputColorKey)
        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: CGSize(width: 2, height: 8))), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        let rainImage = NSImage(cgImage: cgImage, size: CGSize(width: 2, height: 8))
        #endif

        // Configure rain particles
        rain.particleTexture = SKTexture(image: rainImage)
        rain.particleBirthRate = 200
        rain.numParticlesToEmit = -1 // Continuous emission
        rain.particleLifetime = 2.0
        rain.particleLifetimeRange = 0.5
        rain.particleScale = 1.0
        rain.particleAlpha = 0.7
        rain.particleAlphaSpeed = -0.3
        rain.particleSpeed = 400
        rain.particleSpeedRange = 100
        rain.emissionAngle = .pi * 1.5 // Downward
        rain.emissionAngleRange = .pi / 6
        rain.particleColor = .blue
        rain.particleBlendMode = .alpha
        rain.zPosition = 30
    }

    /// Creates the snow particle effect
    private func createSnowEffect() {
        self.snowEmitter = SKEmitterNode()
        guard let snow = snowEmitter else { return }

        // Create snowflake texture
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 6, height: 6))
        let snowImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 6, height: 6)))
        }
        #else
        // For macOS, create a simple colored rectangle texture
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIConstantColorGenerator")!
        filter.setValue(CIColor(color: SKColor.white), forKey: kCIInputColorKey)
        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: CGSize(width: 6, height: 6))), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        let snowImage = NSImage(cgImage: cgImage, size: CGSize(width: 6, height: 6))
        #endif

        // Configure snow particles
        snow.particleTexture = SKTexture(image: snowImage)
        snow.particleBirthRate = 50
        snow.numParticlesToEmit = -1
        snow.particleLifetime = 8.0
        snow.particleLifetimeRange = 2.0
        snow.particleScale = 0.5
        snow.particleScaleRange = 0.3
        snow.particleAlpha = 0.8
        snow.particleAlphaSpeed = -0.1
        snow.particleSpeed = 50
        snow.particleSpeedRange = 20
        snow.emissionAngle = .pi * 1.5
        snow.emissionAngleRange = .pi / 3
        snow.xAcceleration = 10 // Slight wind effect
        snow.yAcceleration = -30
        snow.particleColor = .white
        snow.particleBlendMode = .alpha
        snow.zPosition = 25
    }

    /// Creates the fog particle effect
    private func createFogEffect() {
        self.fogEmitter = SKEmitterNode()
        guard let fog = fogEmitter else { return }

        // Create fog texture
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        let fogImage = renderer.image { context in
            let colors = [UIColor.gray.withAlphaComponent(0.1), UIColor.white.withAlphaComponent(0.3)]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: colors as CFArray,
                                      locations: [0.0, 1.0])!
            context.cgContext.drawRadialGradient(gradient,
                                                 startCenter: CGPoint(x: 20, y: 20),
                                                 startRadius: 0,
                                                 endCenter: CGPoint(x: 20, y: 20),
                                                 endRadius: 20,
                                                 options: [])
        }
        #else
        // For macOS, create a simple colored rectangle texture with gradient effect
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIRadialGradient")!
        filter.setValue(CIVector(x: 20, y: 20), forKey: "inputCenter")
        filter.setValue(CIColor(color: SKColor.gray.withAlphaComponent(0.1)), forKey: "inputColor0")
        filter.setValue(CIColor(color: SKColor.white.withAlphaComponent(0.3)), forKey: "inputColor1")
        filter.setValue(0.0, forKey: "inputRadius0")
        filter.setValue(20.0, forKey: "inputRadius1")

        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: CGSize(width: 40, height: 40))), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        let fogImage = NSImage(cgImage: cgImage, size: CGSize(width: 40, height: 40))
        #endif

        // Configure fog particles
        fog.particleTexture = SKTexture(image: fogImage)
        fog.particleBirthRate = 10
        fog.numParticlesToEmit = -1
        fog.particleLifetime = 15.0
        fog.particleLifetimeRange = 5.0
        fog.particleScale = 2.0
        fog.particleScaleRange = 1.0
        fog.particleAlpha = 0.3
        fog.particleAlphaSpeed = -0.01
        fog.particleSpeed = 20
        fog.particleSpeedRange = 10
        fog.emissionAngle = 0
        fog.emissionAngleRange = .pi * 2
        fog.particleColor = .gray
        fog.particleBlendMode = .alpha
        fog.zPosition = 20
    }

    /// Creates the wind particle effect
    private func createWindEffect() {
        self.windEmitter = SKEmitterNode()
        guard let wind = windEmitter else { return }

        // Create wind particle texture
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 20))
        let windImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 1, height: 20)))
        }
        #else
        // For macOS, create a simple colored rectangle texture
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIConstantColorGenerator")!
        filter.setValue(CIColor(color: SKColor.white.withAlphaComponent(0.2)), forKey: kCIInputColorKey)
        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: CGSize(width: 1, height: 20))), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        let windImage = NSImage(cgImage: cgImage, size: CGSize(width: 1, height: 20))
        #endif

        // Configure wind particles
        wind.particleTexture = SKTexture(image: windImage)
        wind.particleBirthRate = 100
        wind.numParticlesToEmit = -1
        wind.particleLifetime = 3.0
        wind.particleLifetimeRange = 1.0
        wind.particleScale = 1.0
        wind.particleAlpha = 0.4
        wind.particleAlphaSpeed = -0.5
        wind.particleSpeed = 300
        wind.particleSpeedRange = 100
        wind.emissionAngle = 0 // Horizontal
        wind.emissionAngleRange = .pi / 4
        wind.particleColor = .white
        wind.particleBlendMode = .alpha
        wind.zPosition = 15
    }

    /// Creates the lightning particle effect
    private func createLightningEffect() {
        self.lightningEmitter = SKEmitterNode()
        guard let lightning = lightningEmitter else { return }

        // Create lightning spark texture
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        let lightningImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
        }
        #else
        // For macOS, create a simple colored rectangle texture
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIConstantColorGenerator")!
        filter.setValue(CIColor(color: SKColor.white), forKey: kCIInputColorKey)
        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: CGSize(width: 4, height: 4))), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        let lightningImage = NSImage(cgImage: cgImage, size: CGSize(width: 4, height: 4))
        #endif

        // Configure lightning particles
        lightning.particleTexture = SKTexture(image: lightningImage)
        lightning.particleBirthRate = 500
        lightning.numParticlesToEmit = 200
        lightning.particleLifetime = 0.3
        lightning.particleLifetimeRange = 0.1
        lightning.particleScale = 0.2
        lightning.particleScaleRange = 0.1
        lightning.particleAlpha = 1.0
        lightning.particleAlphaSpeed = -3.0
        lightning.particleSpeed = 150
        lightning.particleSpeedRange = 50
        lightning.emissionAngle = 0
        lightning.emissionAngleRange = .pi * 2
        lightning.particleColor = .white
        lightning.particleBlendMode = .add
        lightning.zPosition = 80
    }

    /// Creates the weather overlay node
    private func createWeatherOverlay() {
        guard let scene else { return }
        self.weatherOverlay = SKSpriteNode(color: .clear, size: scene.size)
        self.weatherOverlay?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        self.weatherOverlay?.zPosition = 35
    }

    /// Creates the lighting overlay node
    private func createLightingOverlay() {
        guard let scene else { return }
        self.lightingOverlay = SKSpriteNode(color: .clear, size: scene.size)
        self.lightingOverlay?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        self.lightingOverlay?.zPosition = 90
    }

    /// Creates the fog overlay node
    private func createFogOverlay() {
        guard let scene else { return }
        self.fogOverlay = SKSpriteNode(color: .gray.withAlphaComponent(0.1), size: scene.size)
        self.fogOverlay?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        self.fogOverlay?.zPosition = 85
    }

    // MARK: - Explosion Effects

    /// Creates an explosion effect at the specified position
    /// - Parameter position: Where to create the explosion
    func createExplosion(at position: CGPoint) {
        guard let scene else { return }

        let explosion = self.getExplosionEffect()
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
    private func getExplosionEffect() -> SKEmitterNode {
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

    /// Gets a trail effect from the pool or creates a new one
    private func getTrailEffect() -> SKEmitterNode {
        if let trail = trailPool.popLast() {
            // Reset the emitter
            trail.resetSimulation()
            return trail
        } else {
            // Create new trail
            let trail = self.trailEmitter?.copy() as? SKEmitterNode ?? SKEmitterNode()
            return trail
        }
    }

    /// Returns a trail effect to the pool
    private func returnTrailToPool(_ trail: SKEmitterNode) {
        trail.removeFromParent()
        if self.trailPool.count < self.maxTrailPoolSize {
            self.trailPool.append(trail)
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
    func createScreenFlash(color: SKColor = .white, duration: TimeInterval = 0.1) {
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
    func createScorePopup(score: Int, at position: CGPoint, color: SKColor = .yellow) {
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
    /// - Parameter obstacleSpeed: Current obstacle speed (used as difficulty multiplier)
    func updateBackgroundEffects(for obstacleSpeed: Float) {
        // Adjust background animation speed based on difficulty
        let speedMultiplier = obstacleSpeed / 3.5

        // Update cloud movement speed
        self.enumerateClouds { cloud in
            if cloud.action(forKey: "move") != nil {
                cloud.removeAction(forKey: "move")

                let newDuration = TimeInterval(20.0 / speedMultiplier) // Slower clouds at higher difficulty
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

    // MARK: - Environmental Effects

    /// Sets the current weather condition
    /// - Parameters:
    ///   - weather: The weather type to set
    ///   - intensity: Intensity of the weather effect (0.0 to 1.0)
    func setWeather(_ weather: WeatherType, intensity: Float = 1.0) {
        guard let scene else { return }

        // Remove current weather effects
        self.clearWeather()

        self.currentWeather = weather
        self.weatherIntensity = intensity

        switch weather {
        case .clear:
            // No weather effects
            break
        case .rain:
            if let rain = self.rainEmitter?.copy() as? SKEmitterNode {
                rain.particleBirthRate *= CGFloat(intensity)
                rain.position = CGPoint(x: scene.size.width / 2, y: scene.size.height + 50)
                scene.addChild(rain)
            }
        case .snow:
            if let snow = self.snowEmitter?.copy() as? SKEmitterNode {
                snow.particleBirthRate *= CGFloat(intensity)
                snow.position = CGPoint(x: scene.size.width / 2, y: scene.size.height + 50)
                scene.addChild(snow)
            }
        case .fog:
            if let fogOverlay = self.fogOverlay {
                fogOverlay.alpha = CGFloat(intensity) * 0.3
                scene.addChild(fogOverlay)
            }
            if let fog = self.fogEmitter?.copy() as? SKEmitterNode {
                fog.particleBirthRate *= CGFloat(intensity)
                fog.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
                scene.addChild(fog)
            }
        case .wind:
            if let wind = self.windEmitter?.copy() as? SKEmitterNode {
                wind.particleBirthRate *= CGFloat(intensity)
                wind.position = CGPoint(x: -50, y: scene.size.height / 2)
                scene.addChild(wind)
            }
        case .storm:
            // Combine rain and lightning
            self.setWeather(.rain, intensity: intensity)
            self.startStormHazards()
        }
    }

    /// Sets the current lighting condition
    /// - Parameters:
    ///   - lighting: The lighting type to set
    ///   - intensity: Intensity of the lighting effect (0.0 to 1.0)
    func setLighting(_ lighting: LightingType, intensity: Float = 1.0) {
        guard let scene, let lightingOverlay = self.lightingOverlay else { return }

        self.currentLighting = lighting
        self.lightingIntensity = intensity

        // Remove existing lighting overlay
        lightingOverlay.removeFromParent()

        switch lighting {
        case .day:
            lightingOverlay.color = .clear
            lightingOverlay.alpha = 0.0
        case .dusk:
            lightingOverlay.color = .orange.withAlphaComponent(0.2)
            lightingOverlay.alpha = CGFloat(intensity) * 0.3
        case .night:
            lightingOverlay.color = .black.withAlphaComponent(0.4)
            lightingOverlay.alpha = CGFloat(intensity) * 0.6
        case .stormy:
            lightingOverlay.color = .gray.withAlphaComponent(0.3)
            lightingOverlay.alpha = CGFloat(intensity) * 0.5
        }

        if lighting != .day {
            scene.addChild(lightingOverlay)
        }
    }

    /// Creates an environmental hazard
    /// - Parameter hazard: The type of hazard to create
    func createEnvironmentalHazard(_ hazard: EnvironmentalHazard) {
        guard let scene else { return }

        switch hazard {
        case .lightning:
            self.createLightningStrike()
        case .tornado:
            self.createTornado()
        case .earthquake:
            self.createEarthquake()
        case .meteor:
            self.createMeteor()
        }
    }

    /// Starts automatic weather changes
    /// - Parameter interval: Time interval between weather changes
    func startWeatherCycle(interval: TimeInterval = 30.0) {
        self.weatherChangeTimer?.invalidate()
        self.weatherChangeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.changeWeatherRandomly()
            }
        }
    }

    /// Starts automatic lighting changes (day/night cycle)
    /// - Parameter cycleDuration: Duration of a complete day/night cycle in seconds
    func startLightingCycle(cycleDuration: TimeInterval = 120.0) {
        self.lightingChangeTimer?.invalidate()
        self.lightingChangeTimer = Timer.scheduledTimer(withTimeInterval: cycleDuration / 4, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceLightingCycle()
            }
        }
    }

    /// Starts random environmental hazards
    /// - Parameter interval: Average time between hazards
    func startEnvironmentalHazards(interval: TimeInterval = 45.0) {
        self.hazardTimer?.invalidate()
        self.hazardTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.triggerRandomHazard()
            }
        }
    }

    /// Stops all environmental effects
    func stopEnvironmentalEffects() {
        self.weatherChangeTimer?.invalidate()
        self.lightingChangeTimer?.invalidate()
        self.hazardTimer?.invalidate()
        self.stormTimer?.invalidate()
        self.clearWeather()
        self.setLighting(.day)
    }

    /// Clears current weather effects
    private func clearWeather() {
        guard let scene else { return }

        // Remove weather emitters
        scene.enumerateChildNodes(withName: "weather_*") { node, _ in
            node.removeFromParent()
        }

        // Remove overlays
        self.weatherOverlay?.removeFromParent()
        self.fogOverlay?.removeFromParent()
    }

    /// Changes weather to a random type
    private func changeWeatherRandomly() {
        let weatherTypes: [WeatherType] = [.clear, .rain, .snow, .fog, .wind]
        let randomWeather = weatherTypes.randomElement() ?? .clear
        let randomIntensity = Float.random(in: 0.3 ... 1.0)
        self.setWeather(randomWeather, intensity: randomIntensity)
    }

    /// Advances the lighting cycle
    private func advanceLightingCycle() {
        let lightingSequence: [LightingType] = [.day, .dusk, .night, .dusk]
        if let currentIndex = lightingSequence.firstIndex(of: self.currentLighting) {
            let nextIndex = (currentIndex + 1) % lightingSequence.count
            self.setLighting(lightingSequence[nextIndex])
        } else {
            self.setLighting(.day)
        }
    }

    /// Triggers a random environmental hazard
    private func triggerRandomHazard() {
        let hazards: [EnvironmentalHazard] = [.lightning, .tornado, .earthquake, .meteor]
        let randomHazard = hazards.randomElement() ?? .lightning
        self.createEnvironmentalHazard(randomHazard)
    }

    /// Creates a lightning strike effect
    private func createLightningStrike() {
        guard let scene, let lightning = self.lightningEmitter?.copy() as? SKEmitterNode else { return }

        // Random position across the top of screen
        let x = CGFloat.random(in: 50 ... (scene.size.width - 50))
        lightning.position = CGPoint(x: x, y: scene.size.height + 20)
        lightning.name = "weather_lightning"
        scene.addChild(lightning)

        // Screen flash for lightning
        self.createScreenFlash(color: .white, duration: 0.1)

        // Remove after effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            lightning.removeFromParent()
        }
    }

    /// Creates a tornado effect
    private func createTornado() {
        guard let scene else { return }

        // Create tornado sprite
        let tornado = SKSpriteNode(color: .gray, size: CGSize(width: 40, height: 200))
        tornado.position = CGPoint(x: scene.size.width + 50, y: scene.size.height / 2)
        tornado.name = "weather_tornado"
        scene.addChild(tornado)

        // Animate tornado movement and rotation
        let moveAction = SKAction.moveBy(x: -scene.size.width - 100, y: 0, duration: 8.0)
        let rotateAction = SKAction.rotate(byAngle: .pi * 4, duration: 8.0)
        let fadeAction = SKAction.fadeOut(withDuration: 8.0)
        let removeAction = SKAction.removeFromParent()

        let animation = SKAction.group([moveAction, rotateAction, fadeAction])
        tornado.run(SKAction.sequence([animation, removeAction]))
    }

    /// Creates an earthquake effect
    private func createEarthquake() {
        guard let scene else { return }

        // Shake the camera/screen
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 0, y: 5, duration: 0.05),
            SKAction.moveBy(x: 0, y: -10, duration: 0.05),
            SKAction.moveBy(x: 0, y: 5, duration: 0.05),
        ])

        scene.run(shakeAction)

        // Create dust particles
        for _ in 0 ..< 10 {
            let dustX = CGFloat.random(in: 0 ... scene.size.width)
            let dustY = CGFloat.random(in: 0 ... scene.size.height / 4)
            self.createExplosion(at: CGPoint(x: dustX, y: dustY))
        }
    }

    /// Creates a meteor effect
    private func createMeteor() {
        guard let scene else { return }

        // Create meteor sprite
        let meteor = SKSpriteNode(color: .orange, size: CGSize(width: 20, height: 60))
        meteor.position = CGPoint(x: CGFloat.random(in: 0 ... scene.size.width), y: scene.size.height + 50)
        meteor.name = "weather_meteor"
        scene.addChild(meteor)

        // Animate meteor falling
        let fallAction = SKAction.moveBy(x: 100, y: -scene.size.height - 100, duration: 2.0)
        let rotateAction = SKAction.rotate(byAngle: .pi / 2, duration: 2.0)
        let scaleAction = SKAction.scale(to: 0.1, duration: 2.0)
        let removeAction = SKAction.removeFromParent()

        let animation = SKAction.group([fallAction, rotateAction, scaleAction])
        meteor.run(SKAction.sequence([animation, removeAction]))

        // Create trail effect
        if let trail = self.createTrail(for: meteor) {
            trail.particleColor = .orange
            trail.particleLifetime = 1.0
        }

        // Explosion on impact
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let impactPosition = CGPoint(x: meteor.position.x + 100, y: meteor.position.y - scene.size.height - 100)
            self.createExplosion(at: impactPosition)
        }
    }

    /// Starts storm hazard effects
    private func startStormHazards() {
        self.stormTimer?.invalidate()
        self.stormTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                if self?.currentWeather == .storm {
                    self?.createLightningStrike()
                }
            }
        }
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
    /// - Returns: A platform-appropriate image for use as particle texture
    func createParticleTexture(color: SKColor, size: CGSize) -> SKTexture {
        #if os(iOS) || os(tvOS)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
        #else
        // For macOS, create a simple colored rectangle texture
        let coreImageContext = CIContext()
        let filter = CIFilter(name: "CIConstantColorGenerator")!
        filter.setValue(CIColor(color: color), forKey: kCIInputColorKey)
        let ciImage = filter.outputImage!

        // Create a crop filter to get the desired size
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: size)), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!

        let cgImage = coreImageContext.createCGImage(croppedImage, from: croppedImage.extent)!
        return SKTexture(cgImage: cgImage)
        #endif
    }

    // MARK: - Cleanup

    /// Cleans up all effects and pools
    func cleanup() {
        self.explosionPool.removeAll()
        self.trailPool.removeAll()
        self.explosionEmitter = nil
        self.trailEmitter = nil
        self.sparkleEmitter = nil
        self.rainEmitter = nil
        self.snowEmitter = nil
        self.fogEmitter = nil
        self.windEmitter = nil
        self.lightningEmitter = nil
        self.weatherOverlay = nil
        self.lightingOverlay = nil
        self.fogOverlay = nil

        // Stop timers
        self.weatherChangeTimer?.invalidate()
        self.lightingChangeTimer?.invalidate()
        self.hazardTimer?.invalidate()
        self.stormTimer?.invalidate()
    }

    // MARK: - Async Effects

    /// Creates an explosion effect at the specified position asynchronously
    /// - Parameter position: Where to create the explosion
    func createExplosionAsync(at position: CGPoint) async {
        self.createExplosion(at: position)
    }

    /// Creates a trail effect attached to a node asynchronously
    /// - Parameter node: The node to attach the trail to
    /// - Returns: The trail emitter node
    func createTrailAsync(for node: SKNode) async -> SKEmitterNode? {
        self.createTrail(for: node)
    }

    /// Creates a screen flash effect asynchronously
    /// - Parameter color: The color of the flash
    /// - Parameter duration: How long the flash lasts
    func createScreenFlashAsync(color: SKColor = .white, duration: TimeInterval = 0.1) async {
        self.createScreenFlash(color: color, duration: duration)
    }

    /// Creates a level up celebration effect asynchronously
    func createLevelUpCelebrationAsync() async {
        self.createLevelUpCelebration()
    }

    /// Creates a sparkle burst at a position asynchronously
    /// - Parameter position: Where to create the sparkle burst
    func createSparkleBurstAsync(at position: CGPoint) async {
        self.createSparkleBurst(at: position)
    }

    /// Creates a floating score popup asynchronously
    /// - Parameters:
    ///   - score: The score value to display
    ///   - position: Where to show the popup
    ///   - color: The color of the text
    func createScorePopupAsync(score: Int, at position: CGPoint, color: SKColor = .yellow) async {
        self.createScorePopup(score: score, at: position, color: color)
    }

    /// Updates background effects based on game state asynchronously
    /// - Parameter difficulty: Current game difficulty (placeholder - not implemented)
    func updateBackgroundEffectsAsync(for difficulty: Float) async {
        // Placeholder - GameDifficulty type not defined
        // self.updateBackgroundEffects(for: difficulty)
    }

    /// Creates a power-up collection effect asynchronously
    /// - Parameter position: Where the power-up was collected
    func createPowerUpCollectionEffectAsync(at position: CGPoint) async {
        self.createPowerUpCollectionEffect(at: position)
    }

    /// Creates a shield activation effect asynchronously
    /// - Parameter position: Where the shield is activated
    func createShieldActivationEffectAsync(at position: CGPoint) async {
        self.createShieldActivationEffect(at: position)
    }

    /// Cleans up unused effects asynchronously
    func cleanupUnusedEffectsAsync() async {
        self.cleanupUnusedEffects()
    }

    /// Cleans up all effects and pools asynchronously
    func cleanupAsync() async {
        self.cleanup()
    }

    // MARK: - Environmental Effects (Async)

    /// Sets the current weather condition asynchronously
    /// - Parameters:
    ///   - weather: The weather type to set
    ///   - intensity: Intensity of the weather effect (0.0 to 1.0)
    func setWeatherAsync(_ weather: WeatherType, intensity: Float = 1.0) async {
        self.setWeather(weather, intensity: intensity)
    }

    /// Sets the current lighting condition asynchronously
    /// - Parameters:
    ///   - lighting: The lighting type to set
    ///   - intensity: Intensity of the lighting effect (0.0 to 1.0)
    func setLightingAsync(_ lighting: LightingType, intensity: Float = 1.0) async {
        self.setLighting(lighting, intensity: intensity)
    }

    /// Creates an environmental hazard asynchronously
    /// - Parameter hazard: The type of hazard to create
    func createEnvironmentalHazardAsync(_ hazard: EnvironmentalHazard) async {
        self.createEnvironmentalHazard(hazard)
    }

    /// Starts automatic weather changes asynchronously
    /// - Parameter interval: Time interval between weather changes
    func startWeatherCycleAsync(interval: TimeInterval = 30.0) async {
        self.startWeatherCycle(interval: interval)
    }

    /// Starts automatic lighting changes asynchronously
    /// - Parameter cycleDuration: Duration of a complete day/night cycle in seconds
    func startLightingCycleAsync(cycleDuration: TimeInterval = 120.0) async {
        self.startLightingCycle(cycleDuration: cycleDuration)
    }

    /// Starts random environmental hazards asynchronously
    /// - Parameter interval: Average time between hazards
    func startEnvironmentalHazardsAsync(interval: TimeInterval = 45.0) async {
        self.startEnvironmentalHazards(interval: interval)
    }

    /// Stops all environmental effects asynchronously
    func stopEnvironmentalEffectsAsync() async {
        self.stopEnvironmentalEffects()
    }

    // MARK: - Game Loop Updates

    /// Updates environmental effects in the game loop
    /// - Parameter deltaTime: Time elapsed since last update
    func update(deltaTime: TimeInterval) {
        // Update weather cycle timers
        self.updateWeatherCycle(deltaTime)

        // Update lighting cycle timers
        self.updateLightingCycle(deltaTime)

        // Update hazard timers
        self.updateHazardTimers(deltaTime)

        // Update background effects based on current state
        self.updateBackgroundAnimations(deltaTime)

        // Cleanup unused effects periodically
        self.periodicCleanup(deltaTime)
    }

    /// Updates weather cycle timing
    private func updateWeatherCycle(_ deltaTime: TimeInterval) {
        // This would be used if we implement manual weather cycle timing
        // instead of Timer.scheduledTimer
    }

    /// Updates lighting cycle timing
    private func updateLightingCycle(_ deltaTime: TimeInterval) {
        // This would be used if we implement manual lighting cycle timing
        // instead of Timer.scheduledTimer
    }

    /// Updates environmental hazard timing
    private func updateHazardTimers(_ deltaTime: TimeInterval) {
        // This would be used if we implement manual hazard timing
        // instead of Timer.scheduledTimer
    }

    /// Updates background animations and effects
    private func updateBackgroundAnimations(_ deltaTime: TimeInterval) {
        // Update any animated background elements
        // This could include cloud movement, particle effects, etc.
    }

    /// Performs periodic cleanup of unused effects
    private func periodicCleanup(_ deltaTime: TimeInterval) {
        // Simple time-based cleanup - could be made more sophisticated
        self.cleanupUnusedEffects()
    }

    // MARK: - Advanced Gesture Effects

    /// Creates an explosion burst effect for super jump
    /// - Parameter position: Position to create the effect at
    func createExplosionBurst(at position: CGPoint) {
        guard let scene else { return }

        // Create multiple explosion particles
        for _ in 0..<8 {
            let explosion = self.getExplosionEffect()
            explosion.position = position
            explosion.particleBirthRate = 200
            explosion.numParticlesToEmit = 20

            scene.addChild(explosion)

            // Remove after effect completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                explosion.removeFromParent()
                self.returnExplosionToPool(explosion)
            }
        }
    }

    /// Creates a trail burst effect for directional dash
    /// - Parameter position: Position to create the effect at
    func createTrailBurst(at position: CGPoint) {
        guard let scene else { return }

        let trail = self.getTrailEffect()
        trail.position = position
        trail.particleBirthRate = 100
        trail.numParticlesToEmit = 30
        trail.particleSpeed = 200
        trail.emissionAngle = Double.pi
        trail.emissionAngleRange = Double.pi / 2

        scene.addChild(trail)

        // Remove after effect completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            trail.removeFromParent()
            self.returnTrailToPool(trail)
        }
    }

    /// Creates a shield effect for defensive ability
    /// - Parameter position: Position to create the effect at
    func createShieldEffect(at position: CGPoint) {
        guard let scene else { return }

        let shield = SKShapeNode(circleOfRadius: 60)
        shield.position = position
        shield.fillColor = .clear
        shield.strokeColor = .blue
        shield.lineWidth = 4
        shield.glowWidth = 3
        shield.zPosition = 50

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.4),
            SKAction.scale(to: 1.0, duration: 0.4),
        ])
        let fade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.4),
            SKAction.fadeAlpha(to: 0.3, duration: 0.4),
        ])
        let group = SKAction.group([pulse, fade])
        shield.run(SKAction.repeat(group, count: 3))

        scene.addChild(shield)

        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            shield.removeFromParent()
        }
    }

    /// Creates an energy wave effect for offensive ability
    /// - Parameter position: Position to create the effect at
    func createEnergyWave(at position: CGPoint) {
        guard let scene else { return }

        let wave = SKShapeNode(circleOfRadius: 10)
        wave.position = position
        wave.fillColor = .clear
        wave.strokeColor = .red
        wave.lineWidth = 3
        wave.glowWidth = 2
        wave.zPosition = 40

        // Expanding wave animation
        let expand = SKAction.scale(to: 8.0, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.6)
        let group = SKAction.group([expand, fade])

        wave.run(group)

        scene.addChild(wave)

        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            wave.removeFromParent()
        }
    }

    /// Creates an ultimate effect combining multiple abilities
    /// - Parameter position: Position to create the effect at
    func createUltimateEffect(at position: CGPoint) {
        // Combine multiple effects for ultimate ability
        self.createExplosionBurst(at: position)
        self.createShieldEffect(at: position)
        self.createEnergyWave(at: position)

        // Add additional visual effects
        guard let scene else { return }

        let ultimateGlow = SKShapeNode(circleOfRadius: 80)
        ultimateGlow.position = position
        ultimateGlow.fillColor = .clear
        ultimateGlow.strokeColor = .purple
        ultimateGlow.lineWidth = 6
        ultimateGlow.glowWidth = 4
        ultimateGlow.zPosition = 60

        // Dramatic pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3),
        ])
        let colorShift = SKAction.sequence([
            SKAction.colorize(with: .magenta, colorBlendFactor: 0.5, duration: 0.3),
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.5, duration: 0.3),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.3),
        ])
        let group = SKAction.group([SKAction.repeat(pulse, count: 4), colorShift])

        ultimateGlow.run(group)

        scene.addChild(ultimateGlow)

        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            ultimateGlow.removeFromParent()
        }
    }

    /// Creates a shockwave effect for powerful attacks
    /// - Parameter position: Position to create the effect at
    func createShockwave(at position: CGPoint) {
        guard let scene else { return }

        // Create multiple concentric shockwaves
        for i in 0..<3 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let shockwave = SKShapeNode(circleOfRadius: 5)
                shockwave.position = position
                shockwave.fillColor = .clear
                shockwave.strokeColor = .yellow
                shockwave.lineWidth = 2
                shockwave.glowWidth = 1
                shockwave.zPosition = 30

                // Rapid expansion
                let expand = SKAction.scale(to: 12.0, duration: 0.4)
                let fade = SKAction.fadeOut(withDuration: 0.4)
                let group = SKAction.group([expand, fade])

                shockwave.run(group)

                scene.addChild(shockwave)

                // Remove after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    shockwave.removeFromParent()
                }
            }
        }
    }
}
