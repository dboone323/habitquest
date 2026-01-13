//
// ParticleEffects.swift
// HabitQuest
//
// Step 29: Particle effects for habit streak milestones.
//

import SwiftUI
import SpriteKit

/// SpriteKit scene for particle effects.
class ParticleScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
    }
    
    /// Spawns confetti particles for celebration.
    func emitConfetti(at position: CGPoint) {
        guard let emitter = createConfettiEmitter() else { return }
        emitter.position = position
        emitter.zPosition = 1
        addChild(emitter)
        
        // Remove after animation
        let wait = SKAction.wait(forDuration: 3)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
    
    /// Spawns fire particles for streak celebrations.
    func emitFlame(at position: CGPoint) {
        guard let emitter = createFlameEmitter() else { return }
        emitter.position = position
        emitter.zPosition = 1
        addChild(emitter)
        
        let wait = SKAction.wait(forDuration: 2)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
    
    /// Spawns star burst for achievements.
    func emitStarBurst(at position: CGPoint) {
        guard let emitter = createStarEmitter() else { return }
        emitter.position = position
        emitter.zPosition = 1
        addChild(emitter)
        
        let wait = SKAction.wait(forDuration: 2)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
    
    // MARK: - Emitter Creation
    
    private func createConfettiEmitter() -> SKEmitterNode? {
        let emitter = SKEmitterNode()
        emitter.particleLifetime = 3
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 200
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 100
        emitter.yAcceleration = -200
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 4
        emitter.particleSize = CGSize(width: 8, height: 8)
        emitter.particleColor = .systemYellow
        emitter.particleColorBlendFactor = 1
        emitter.particleColorSequence = colorSequence()
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = 2
        emitter.particleAlpha = 1
        emitter.particleAlphaSpeed = -0.3
        return emitter
    }
    
    private func createFlameEmitter() -> SKEmitterNode? {
        let emitter = SKEmitterNode()
        emitter.particleLifetime = 1
        emitter.particleBirthRate = 50
        emitter.numParticlesToEmit = 100
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.yAcceleration = 100
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 6
        emitter.particleSize = CGSize(width: 20, height: 20)
        emitter.particleColor = .orange
        emitter.particleColorBlendFactor = 1
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -0.8
        emitter.particleScale = 0.5
        emitter.particleScaleSpeed = -0.3
        return emitter
    }
    
    private func createStarEmitter() -> SKEmitterNode? {
        let emitter = SKEmitterNode()
        emitter.particleLifetime = 1.5
        emitter.particleBirthRate = 30
        emitter.numParticlesToEmit = 50
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 50
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSize = CGSize(width: 15, height: 15)
        emitter.particleColor = .yellow
        emitter.particleColorBlendFactor = 1
        emitter.particleAlpha = 1
        emitter.particleAlphaSpeed = -0.7
        emitter.particleScale = 0.8
        emitter.particleScaleSpeed = -0.3
        return emitter
    }
    
    private func colorSequence() -> SKKeyframeSequence {
        let colors: [SKColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple]
        let times: [NSNumber] = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }
}

/// SwiftUI wrapper for particle effects.
struct ParticleEffectView: View {
    let effectType: EffectType
    let trigger: Bool
    
    enum EffectType {
        case confetti
        case flame
        case stars
    }
    
    @State private var scene = ParticleScene()
    
    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    let center = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
                    switch effectType {
                    case .confetti:
                        scene.emitConfetti(at: center)
                    case .flame:
                        scene.emitFlame(at: center)
                    case .stars:
                        scene.emitStarBurst(at: center)
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
