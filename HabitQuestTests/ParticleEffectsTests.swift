import HabitQuestCore
import SpriteKit
import SwiftUI
import XCTest
@testable import HabitQuest

final class ParticleEffectsTests: XCTestCase {
    // MARK: - Scene and Emitter Tests

    @MainActor
    func testParticleSceneInitialization() {
        let scene = ParticleScene()
        XCTAssertEqual(scene.children.count, 0)
        let view = SKView()
        scene.didMove(to: view)
        XCTAssertEqual(scene.backgroundColor.cgColor.alpha, 0.0)
    }

    @MainActor
    func testConfettiEmitterCreationAndEmission() {
        let scene = ParticleScene(size: CGSize(width: 400, height: 800))
        let center = CGPoint(x: 200, y: 400)

        scene.emitConfetti(at: center)

        XCTAssertEqual(scene.children.count, 1)
        guard let emitter = scene.children.first as? SKEmitterNode else {
            XCTFail("Expected SKEmitterNode child")
            return
        }

        XCTAssertEqual(emitter.position, center)
        XCTAssertEqual(emitter.numParticlesToEmit, 200)
        XCTAssertEqual(emitter.particleLifetime, 3)
        XCTAssertEqual(emitter.particleBirthRate, 100)
        XCTAssertEqual(emitter.particleSpeed, 200)
        XCTAssertNotNil(emitter.particleColorSequence)
    }

    @MainActor
    func testFlameEmitterCreationAndEmission() {
        let scene = ParticleScene(size: CGSize(width: 400, height: 800))
        let center = CGPoint(x: 200, y: 400)

        scene.emitFlame(at: center)

        XCTAssertEqual(scene.children.count, 1)
        guard let emitter = scene.children.first as? SKEmitterNode else {
            XCTFail("Expected SKEmitterNode child")
            return
        }

        XCTAssertEqual(emitter.position, center)
        XCTAssertEqual(emitter.numParticlesToEmit, 100)
        XCTAssertEqual(emitter.particleLifetime, 1)
        XCTAssertEqual(emitter.particleBirthRate, 50)
        XCTAssertEqual(emitter.particleColor, .orange)
    }

    @MainActor
    func testStarBurstEmitterCreationAndEmission() {
        let scene = ParticleScene(size: CGSize(width: 400, height: 800))
        let center = CGPoint(x: 200, y: 400)

        scene.emitStarBurst(at: center)

        XCTAssertEqual(scene.children.count, 1)
        guard let emitter = scene.children.first as? SKEmitterNode else {
            XCTFail("Expected SKEmitterNode child")
            return
        }

        XCTAssertEqual(emitter.position, center)
        XCTAssertEqual(emitter.numParticlesToEmit, 50)
        XCTAssertEqual(emitter.particleLifetime, 1.5)
        XCTAssertEqual(emitter.particleColor, .yellow)
    }

    @MainActor
    func testParticleEffectViewInstantiates() {
        let view = ParticleEffectView(effectType: .confetti, trigger: false)
        XCTAssertNotNil(view.body)

        let triggeredView = ParticleEffectView(effectType: .confetti, trigger: true)
        XCTAssertNotNil(triggeredView.body)
    }
}
