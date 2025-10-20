//
// BossManager.swift
// AvoidObstaclesGame
//
// Manages boss battles, including boss spawning, attacks, and battle progression.
//

import Combine
import SpriteKit

/// Manages boss battles and their lifecycle
@MainActor
class BossManager: GameComponent {
    private weak var scene: SKScene?
    private var currentBoss: Boss?
    private var bossAttacks: [BossAttackNode] = []
    private var isBossBattleActive: Bool = false
    private var battleTimer: TimeInterval = 0
    private var attackCooldown: TimeInterval = 0

    // Delegate for boss battle events
    weak var delegate: BossManagerDelegate?

    // Publishers for reactive updates
    let bossSpawnedPublisher = PassthroughSubject<Boss, Never>()
    let bossDefeatedPublisher = PassthroughSubject<Boss.BossType, Never>()
    let bossHealthChangedPublisher = PassthroughSubject<(CGFloat, CGFloat), Never>() // (current, max)

    init(scene: SKScene) {
        self.scene = scene
    }

    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    /// Starts a boss battle with the specified boss type
    func startBossBattle(type: Boss.BossType) {
        guard !isBossBattleActive else { return }

        // Create and position boss
        let boss = Boss(type: type)
        boss.position = CGPoint(x: (scene?.frame.maxX ?? 400) - 100, y: (scene?.frame.midY ?? 300))

        currentBoss = boss
        isBossBattleActive = true
        battleTimer = 0
        attackCooldown = 0

        // Add boss to scene
        scene?.addChild(boss.node)

        // Notify listeners
        bossSpawnedPublisher.send(boss)

        // Notify delegate
        Task {
            await delegate?.bossBattleStarted(boss: boss)
        }

        // Setup boss battle UI and effects
        setupBossBattleEnvironment()
    }

    private func setupBossBattleEnvironment() {
        // Dim background
        let dimOverlay = SKShapeNode(rectOf: scene?.frame.size ?? CGSize(width: 800, height: 600))
        dimOverlay.fillColor = .black
        dimOverlay.alpha = 0.3
        dimOverlay.position = CGPoint(x: scene?.frame.midX ?? 400, y: scene?.frame.midY ?? 300)
        dimOverlay.name = "bossBattleOverlay"
        scene?.addChild(dimOverlay)

        // Add battle music or sound effects
        // (Would integrate with AudioManager)

        // Add screen shake effect for dramatic entrance
        addScreenShake(intensity: 10, duration: 1.0)
    }

    /// Ends the current boss battle
    func endBossBattle() {
        guard isBossBattleActive else { return }

        // Remove boss
        currentBoss?.node.removeFromParent()
        currentBoss = nil

        // Clean up attacks
        bossAttacks.forEach { $0.node.removeFromParent() }
        bossAttacks.removeAll()

        // Remove battle environment
        scene?.childNode(withName: "bossBattleOverlay")?.removeFromParent()

        isBossBattleActive = false

        // Notify defeat if boss was defeated
        if let boss = currentBoss, boss.currentPhase == .defeated {
            bossDefeatedPublisher.send(boss.bossType)
            Task {
                await delegate?.bossBattleEnded(bossType: boss.bossType, defeated: true)
            }
        } else if let boss = currentBoss {
            // Battle ended without defeat (escaped)
            Task {
                await delegate?.bossBattleEnded(bossType: boss.bossType, defeated: false)
            }
        }
    }

    /// Deals damage to the current boss
    func damageBoss(_ damage: CGFloat) {
        guard let boss = currentBoss else { return }

        let oldHealth = boss.health
        boss.takeDamage(damage)

        // Notify health change
        bossHealthChangedPublisher.send((boss.health, boss.bossType.maxHealth))

        // Notify delegate
        Task {
            await delegate?.bossHealthChanged(current: boss.health, max: boss.bossType.maxHealth)
        }

        // Check for defeat
        if boss.currentPhase == .defeated {
            endBossBattle()
        }
    }

    func update(deltaTime: TimeInterval) {
        guard isBossBattleActive else {
            // Check if we should spawn a boss
            checkForBossSpawn(deltaTime)
            return
        }

        battleTimer += deltaTime
        attackCooldown -= deltaTime

        // Update boss
        currentBoss?.update(deltaTime: deltaTime)

        // Update attacks
        bossAttacks.forEach { $0.update(deltaTime: deltaTime) }
        bossAttacks.removeAll { attack in
            if attack.isFinished {
                attack.node.removeFromParent()
                return true
            }
            return false
        }

        // Perform attacks
        if attackCooldown <= 0, let boss = currentBoss, let attack = boss.performAttack() {
            performBossAttack(attack)
            attackCooldown = boss.currentPhase.attackSpeed
        }
    }

    /// Checks if a boss should spawn based on game conditions
    private func checkForBossSpawn(_ deltaTime: TimeInterval) {
        // For now, spawn a boss every 60 seconds (this could be based on score, difficulty, etc.)
        battleTimer += deltaTime
        if battleTimer >= 60.0 { // Spawn boss every minute
            let bossTypes: [Boss.BossType] = [.guardian, .destroyer, .overlord]
            let randomType = bossTypes.randomElement() ?? .guardian
            startBossBattle(type: randomType)
            battleTimer = 0 // Reset timer
        }
    }

    private func performBossAttack(_ attack: BossAttack) {
        guard let scene, let boss = currentBoss else { return }

        // Notify delegate of attack
        Task {
            await delegate?.bossAttackPerformed(attack: attack)
        }

        switch attack {
        case .laserBeam:
            performLaserBeamAttack(from: boss.position, in: scene)
        case .spikeWave:
            performSpikeWaveAttack(from: boss.position, in: scene)
        case .projectileBarrage:
            performProjectileBarrage(from: boss.position, in: scene)
        case .shockwave:
            performShockwaveAttack(from: boss.position, in: scene)
        case .minionSpawn:
            performMinionSpawn(from: boss.position, in: scene)
        case .teleportStrike:
            performTeleportStrike(from: boss.position, in: scene)
        case .ultimateAttack:
            performUltimateAttack(from: boss.position, in: scene)
        }
    }

    private func performLaserBeamAttack(from position: CGPoint, in scene: SKScene) {
        let laserBeam = BossAttackNode.laserBeam(at: position)
        scene.addChild(laserBeam.node)
        bossAttacks.append(laserBeam)

        // Add screen shake
        addScreenShake(intensity: 5, duration: 0.5)
    }

    private func performSpikeWaveAttack(from position: CGPoint, in scene: SKScene) {
        // Create multiple spikes in a wave pattern
        for i in 0 ..< 5 {
            let spikePosition = CGPoint(x: position.x - 50 + CGFloat(i * 25), y: 50 + CGFloat(i * 50))
            let spike = BossAttackNode.spike(at: spikePosition)
            scene.addChild(spike.node)
            bossAttacks.append(spike)
        }
    }

    private func performProjectileBarrage(from position: CGPoint, in scene: SKScene) {
        // Create multiple projectiles in different directions
        for angle in stride(from: 0, to: 360, by: 45) {
            let projectile = BossAttackNode.projectile(from: position, angle: CGFloat(angle) * .pi / 180)
            scene.addChild(projectile.node)
            bossAttacks.append(projectile)
        }
    }

    private func performShockwaveAttack(from position: CGPoint, in scene: SKScene) {
        let shockwave = BossAttackNode.shockwave(at: position)
        scene.addChild(shockwave.node)
        bossAttacks.append(shockwave)

        // Strong screen shake
        addScreenShake(intensity: 15, duration: 1.0)
    }

    private func performMinionSpawn(from position: CGPoint, in scene: SKScene) {
        // Spawn smaller enemy minions
        for i in 0 ..< 3 {
            let minionPosition = CGPoint(x: position.x + CGFloat(i - 1) * 60, y: position.y - 80)
            let minion = BossAttackNode.minion(at: minionPosition)
            scene.addChild(minion.node)
            bossAttacks.append(minion)
        }
    }

    private func performTeleportStrike(from position: CGPoint, in scene: SKScene) {
        // Boss teleports and strikes
        let strike = BossAttackNode.teleportStrike(at: position)
        scene.addChild(strike.node)
        bossAttacks.append(strike)

        // Teleport boss to new position
        if let boss = currentBoss {
            boss.position = CGPoint(x: CGFloat.random(in: 200 ... 600), y: CGFloat.random(in: 100 ... 500))
        }
    }

    private func performUltimateAttack(from position: CGPoint, in scene: SKScene) {
        // Combination of multiple attacks
        performLaserBeamAttack(from: position, in: scene)
        performProjectileBarrage(from: position, in: scene)
        performShockwaveAttack(from: position, in: scene)

        // Maximum screen shake
        addScreenShake(intensity: 20, duration: 2.0)
    }

    private func addScreenShake(intensity: CGFloat, duration: TimeInterval) {
        guard let scene else { return }

        let shakeAction = SKAction.sequence([
            SKAction.run {
                let shakeVector = CGVector(dx: CGFloat.random(in: -intensity ... intensity),
                                           dy: CGFloat.random(in: -intensity ... intensity))
                scene.position = CGPoint(x: shakeVector.dx, y: shakeVector.dy)
            },
            SKAction.wait(forDuration: 0.05),
        ])

        let shakeSequence = SKAction.sequence([
            SKAction.repeat(shakeAction, count: Int(duration / 0.05)),
            SKAction.run { scene.position = .zero },
        ])

        scene.run(shakeSequence)
    }

    func reset() {
        endBossBattle()
        battleTimer = 0
        attackCooldown = 0
    }

    var isActive: Bool {
        isBossBattleActive
    }

    var currentBossHealth: (current: CGFloat, max: CGFloat)? {
        guard let boss = currentBoss else { return nil }
        return (boss.health, boss.bossType.maxHealth)
    }
}

/// Represents a boss attack that can be spawned and managed
@MainActor
class BossAttackNode: GameComponent {
    let node: SKNode
    var isFinished: Bool = false
    private var lifetime: TimeInterval = 0
    private let maxLifetime: TimeInterval

    init(node: SKNode, lifetime: TimeInterval) {
        self.node = node
        self.maxLifetime = lifetime
    }

    func update(deltaTime: TimeInterval) {
        lifetime += deltaTime

        if lifetime >= maxLifetime {
            isFinished = true
        }

        // Update specific attack behavior
        updateAttackBehavior(deltaTime)
    }

    func reset() {
        lifetime = 0
        isFinished = false
        node.alpha = 1.0
        node.removeAllActions()
    }

    private func updateAttackBehavior(_ deltaTime: TimeInterval) {
        // Move attacks based on their type
        if node.name == "laserBeam" {
            // Laser beam extends and fades
            if let shapeNode = node as? SKShapeNode {
                let progress = lifetime / maxLifetime
                shapeNode.alpha = 1.0 - progress
            }
        } else if node.name == "projectile" {
            // Projectiles move in their direction
            node.position.x -= 200 * deltaTime // Move left
        } else if node.name == "spike" {
            // Spikes fall down
            node.position.y -= 150 * deltaTime
        }
    }

    // Factory methods for different attack types
    static func laserBeam(at position: CGPoint) -> BossAttackNode {
        let laserNode = SKShapeNode(rectOf: CGSize(width: 400, height: 10))
        laserNode.fillColor = .red
        laserNode.strokeColor = .yellow
        laserNode.glowWidth = 5
        laserNode.position = position
        laserNode.name = "laserBeam"

        return BossAttackNode(node: laserNode, lifetime: 2.0)
    }

    static func spike(at position: CGPoint) -> BossAttackNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -10, y: -20))
        path.addLine(to: CGPoint(x: 0, y: 20))
        path.addLine(to: CGPoint(x: 10, y: -20))
        path.closeSubpath()

        let spikeNode = SKShapeNode(path: path)
        spikeNode.fillColor = .red
        spikeNode.strokeColor = .white
        spikeNode.position = position
        spikeNode.name = "spike"

        return BossAttackNode(node: spikeNode, lifetime: 5.0)
    }

    static func projectile(from position: CGPoint, angle: CGFloat) -> BossAttackNode {
        let projectileNode = SKShapeNode(circleOfRadius: 8)
        projectileNode.fillColor = .orange
        projectileNode.strokeColor = .yellow
        projectileNode.glowWidth = 3
        projectileNode.position = position
        projectileNode.name = "projectile"

        // Set physics for projectile
        let physicsBody = SKPhysicsBody(circleOfRadius: 8)
        physicsBody.categoryBitMask = PhysicsCategory.obstacle
        physicsBody.contactTestBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.isDynamic = true
        physicsBody.velocity = CGVector(dx: cos(angle) * 200, dy: sin(angle) * 200)
        projectileNode.physicsBody = physicsBody

        return BossAttackNode(node: projectileNode, lifetime: 3.0)
    }

    static func shockwave(at position: CGPoint) -> BossAttackNode {
        let shockwaveNode = SKShapeNode(circleOfRadius: 50)
        shockwaveNode.fillColor = .clear
        shockwaveNode.strokeColor = .cyan
        shockwaveNode.lineWidth = 5
        shockwaveNode.glowWidth = 10
        shockwaveNode.position = position
        shockwaveNode.name = "shockwave"

        // Animate expansion
        let expandAction = SKAction.scale(to: 3.0, duration: 1.0)
        let fadeAction = SKAction.fadeOut(withDuration: 1.0)
        let groupAction = SKAction.group([expandAction, fadeAction])
        shockwaveNode.run(groupAction)

        return BossAttackNode(node: shockwaveNode, lifetime: 1.0)
    }

    static func minion(at position: CGPoint) -> BossAttackNode {
        let minionNode = SKShapeNode(circleOfRadius: 15)
        minionNode.fillColor = .purple
        minionNode.strokeColor = .white
        minionNode.position = position
        minionNode.name = "minion"

        // Add simple AI movement
        let moveAction = SKAction.sequence([
            SKAction.moveBy(x: -100, y: 0, duration: 1.0),
            SKAction.moveBy(x: 100, y: 0, duration: 1.0),
        ])
        minionNode.run(SKAction.repeatForever(moveAction))

        return BossAttackNode(node: minionNode, lifetime: 10.0)
    }

    static func teleportStrike(at position: CGPoint) -> BossAttackNode {
        let strikeNode = SKShapeNode(circleOfRadius: 30)
        strikeNode.fillColor = .magenta
        strikeNode.strokeColor = .white
        strikeNode.glowWidth = 8
        strikeNode.position = position
        strikeNode.name = "teleportStrike"

        // Flash effect
        let flashAction = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.fadeOut(withDuration: 0.5),
        ])
        strikeNode.run(flashAction)

        return BossAttackNode(node: strikeNode, lifetime: 0.6)
    }
}
