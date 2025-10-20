//
// SkillTreeManager.swift
// AvoidObstaclesGame
//
// Manages player skill trees, ability unlocks, and progression systems.
//

import Combine
import SpriteKit

/// Represents a skill in the skill tree
@MainActor
struct Skill: Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let cost: Int // Skill points required
    let prerequisites: [String] // IDs of required skills
    let category: SkillCategory
    let effects: [SkillEffect]

    enum SkillCategory: String, Codable {
        case movement, defense, offense, utility, special
    }

    struct SkillEffect: Codable {
        let type: EffectType
        let value: Float
        let description: String

        enum EffectType: String, Codable {
            case speedMultiplier, shieldDuration, damageMultiplier, coinMultiplier, magnetRadius, slowMotionDuration, extraLife, scoreMultiplier
        }
    }

    var isUnlocked: Bool = false
    var isAvailable: Bool = false

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated static func == (lhs: Skill, rhs: Skill) -> Bool {
        lhs.id == rhs.id
    }
}

/// Manages the player's skill tree and progression
@MainActor
class SkillTreeManager: GameComponent {
    private weak var scene: SKScene?
    private var skillPoints: Int = 0
    private var unlockedSkills: Set<String> = []
    private var skillTree: [Skill] = []

    // Publishers for reactive updates
    let skillUnlockedPublisher = PassthroughSubject<Skill, Never>()
    let skillPointsChangedPublisher = PassthroughSubject<Int, Never>()

    init(scene: SKScene) {
        self.scene = scene
        setupSkillTree()
        loadProgress()
    }

    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    /// Sets up the complete skill tree
    private func setupSkillTree() {
        skillTree = [
            // Movement Skills
            Skill(
                id: "speed_boost_1",
                name: "Speed Boost I",
                description: "Increase movement speed by 10%",
                iconName: "speed_icon",
                cost: 1,
                prerequisites: [],
                category: .movement,
                effects: [Skill.SkillEffect(type: .speedMultiplier, value: 0.1, description: "+10% Speed")]
            ),
            Skill(
                id: "speed_boost_2",
                name: "Speed Boost II",
                description: "Increase movement speed by 20%",
                iconName: "speed_icon_2",
                cost: 2,
                prerequisites: ["speed_boost_1"],
                category: .movement,
                effects: [Skill.SkillEffect(type: .speedMultiplier, value: 0.2, description: "+20% Speed")]
            ),
            Skill(
                id: "agile_movement",
                name: "Agile Movement",
                description: "Improved responsiveness and tighter controls",
                iconName: "agile_icon",
                cost: 3,
                prerequisites: ["speed_boost_1"],
                category: .movement,
                effects: [Skill.SkillEffect(type: .speedMultiplier, value: 0.15, description: "+15% Speed + Better Control")]
            ),

            // Defense Skills
            Skill(
                id: "shield_basic",
                name: "Basic Shield",
                description: "Temporary invincibility after taking damage",
                iconName: "shield_icon",
                cost: 2,
                prerequisites: [],
                category: .defense,
                effects: [Skill.SkillEffect(type: .shieldDuration, value: 1.0, description: "1s Invincibility")]
            ),
            Skill(
                id: "shield_extended",
                name: "Extended Shield",
                description: "Longer invincibility duration",
                iconName: "shield_icon_2",
                cost: 3,
                prerequisites: ["shield_basic"],
                category: .defense,
                effects: [Skill.SkillEffect(type: .shieldDuration, value: 2.0, description: "2s Invincibility")]
            ),

            // Offense Skills
            Skill(
                id: "damage_boost",
                name: "Damage Boost",
                description: "Deal more damage to obstacles",
                iconName: "damage_icon",
                cost: 2,
                prerequisites: [],
                category: .offense,
                effects: [Skill.SkillEffect(type: .damageMultiplier, value: 0.25, description: "+25% Damage")]
            ),

            // Utility Skills
            Skill(
                id: "coin_magnet",
                name: "Coin Magnet",
                description: "Automatically collect nearby coins",
                iconName: "magnet_icon",
                cost: 3,
                prerequisites: [],
                category: .utility,
                effects: [Skill.SkillEffect(type: .magnetRadius, value: 50, description: "50px Magnet Radius")]
            ),
            Skill(
                id: "slow_motion",
                name: "Slow Motion",
                description: "Briefly slow down time in critical moments",
                iconName: "slowmo_icon",
                cost: 4,
                prerequisites: ["speed_boost_1"],
                category: .utility,
                effects: [Skill.SkillEffect(type: .slowMotionDuration, value: 2.0, description: "2s Slow Motion")]
            ),

            // Special Skills
            Skill(
                id: "extra_life",
                name: "Extra Life",
                description: "Start with an additional life",
                iconName: "life_icon",
                cost: 5,
                prerequisites: ["shield_basic"],
                category: .special,
                effects: [Skill.SkillEffect(type: .extraLife, value: 1, description: "+1 Extra Life")]
            ),
            Skill(
                id: "score_multiplier",
                name: "Score Multiplier",
                description: "Earn bonus points for everything",
                iconName: "multiplier_icon",
                cost: 4,
                prerequisites: ["coin_magnet"],
                category: .special,
                effects: [Skill.SkillEffect(type: .scoreMultiplier, value: 0.5, description: "+50% Score")]
            ),
        ]

        updateAvailableSkills()
    }

    /// Updates which skills are available for unlocking
    private func updateAvailableSkills() {
        for i in 0 ..< skillTree.count {
            let skill = skillTree[i]
            let prerequisitesMet = skill.prerequisites.allSatisfy { unlockedSkills.contains($0) }
            skillTree[i].isAvailable = prerequisitesMet && !skill.isUnlocked
        }
    }

    /// Awards skill points to the player
    func awardSkillPoints(_ points: Int) {
        skillPoints += points
        skillPointsChangedPublisher.send(skillPoints)
        updateAvailableSkills()
        saveProgress()
    }

    /// Attempts to unlock a skill
    func unlockSkill(_ skillId: String) -> Bool {
        guard let skillIndex = skillTree.firstIndex(where: { $0.id == skillId }),
              skillTree[skillIndex].isAvailable,
              skillPoints >= skillTree[skillIndex].cost
        else {
            return false
        }

        skillPoints -= skillTree[skillIndex].cost
        unlockedSkills.insert(skillId)
        skillTree[skillIndex].isUnlocked = true

        skillUnlockedPublisher.send(skillTree[skillIndex])
        skillPointsChangedPublisher.send(skillPoints)
        updateAvailableSkills()
        saveProgress()

        return true
    }

    /// Gets all skills in a category
    func getSkills(in category: Skill.SkillCategory) -> [Skill] {
        skillTree.filter { $0.category == category }
    }

    /// Gets all available skills
    func getAvailableSkills() -> [Skill] {
        skillTree.filter(\.isAvailable)
    }

    /// Gets all unlocked skills
    func getUnlockedSkills() -> [Skill] {
        skillTree.filter(\.isUnlocked)
    }

    /// Calculates total effects of unlocked skills
    func getTotalEffects() -> [Skill.SkillEffect.EffectType: Float] {
        var totalEffects: [Skill.SkillEffect.EffectType: Float] = [:]

        for skill in getUnlockedSkills() {
            for effect in skill.effects {
                totalEffects[effect.type, default: 0] += effect.value
            }
        }

        return totalEffects
    }

    /// Applies skill effects to a player
    func applySkillEffects(to player: Player) {
        let effects = getTotalEffects()

        if let speedMultiplier = effects[.speedMultiplier] {
            let currentSpeed = player.getCurrentSpeed()
            player.setSpeed(currentSpeed * (1.0 + CGFloat(speedMultiplier)))
        }
    }

    /// Shows the skill tree UI
    func showSkillTreeUI() {
        guard let scene else { return }

        // Create skill tree overlay
        let overlay = SKShapeNode(rectOf: scene.frame.size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.8)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        overlay.name = "skillTreeOverlay"
        overlay.zPosition = 1000
        scene.addChild(overlay)

        // Add skill tree title
        let titleLabel = SKLabelNode(text: "Skill Tree")
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: scene.frame.height / 2 - 60)
        overlay.addChild(titleLabel)

        // Add skill points display
        let pointsLabel = SKLabelNode(text: "Skill Points: \(skillPoints)")
        pointsLabel.fontSize = 20
        pointsLabel.fontColor = .yellow
        pointsLabel.position = CGPoint(x: 0, y: scene.frame.height / 2 - 100)
        overlay.addChild(pointsLabel)

        // Add skill nodes
        addSkillNodes(to: overlay)

        // Add close button
        let closeButton = SKLabelNode(text: "✕")
        closeButton.fontSize = 24
        closeButton.fontColor = .white
        closeButton.position = CGPoint(x: scene.frame.width / 2 - 40, y: scene.frame.height / 2 - 40)
        closeButton.name = "closeSkillTree"
        overlay.addChild(closeButton)
    }

    private func addSkillNodes(to overlay: SKNode) {
        let categories: [Skill.SkillCategory] = [.movement, .defense, .offense, .utility, .special]
        let categorySpacing: CGFloat = 120
        let skillSpacing: CGFloat = 80

        for (categoryIndex, category) in categories.enumerated() {
            let categorySkills = getSkills(in: category)
            let startY = 100 - CGFloat(categoryIndex) * categorySpacing

            for (skillIndex, skill) in categorySkills.enumerated() {
                let skillNode = createSkillNode(for: skill)
                skillNode.position = CGPoint(x: -200 + CGFloat(skillIndex) * skillSpacing, y: startY)
                overlay.addChild(skillNode)
            }
        }
    }

    private func createSkillNode(for skill: Skill) -> SKNode {
        let container = SKNode()
        container.name = "skill_\(skill.id)"

        // Skill icon background
        let background = SKShapeNode(circleOfRadius: 25)
        background.fillColor = skill.isUnlocked ? .green : skill.isAvailable ? .blue : .gray
        background.strokeColor = .white
        background.lineWidth = 2
        container.addChild(background)

        // Skill icon (placeholder)
        let icon = SKLabelNode(text: skill.iconName.prefix(1).uppercased())
        icon.fontSize = 16
        icon.fontColor = .white
        container.addChild(icon)

        // Skill name
        let nameLabel = SKLabelNode(text: skill.name)
        nameLabel.fontSize = 12
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -40)
        container.addChild(nameLabel)

        // Cost display
        if !skill.isUnlocked {
            let costLabel = SKLabelNode(text: "\(skill.cost) SP")
            costLabel.fontSize = 10
            costLabel.fontColor = skillPoints >= skill.cost ? .yellow : .red
            costLabel.position = CGPoint(x: 0, y: -55)
            container.addChild(costLabel)
        }

        return container
    }

    /// Hides the skill tree UI
    func hideSkillTreeUI() {
        scene?.childNode(withName: "skillTreeOverlay")?.removeFromParent()
    }

    /// Handles touch input on skill tree UI
    func handleSkillTreeTouch(at location: CGPoint) -> Bool {
        guard let overlay = scene?.childNode(withName: "skillTreeOverlay") else { return false }

        let localLocation = overlay.convert(location, from: scene!)

        // Check for close button
        if let closeButton = overlay.childNode(withName: "closeSkillTree"),
           closeButton.contains(localLocation)
        {
            hideSkillTreeUI()
            return true
        }

        // Check for skill nodes
        for skill in skillTree {
            if let skillNode = overlay.childNode(withName: "skill_\(skill.id)"),
               skillNode.contains(localLocation)
            {
                if skill.isAvailable && skillPoints >= skill.cost {
                    _ = unlockSkill(skill.id)
                    // Refresh UI
                    hideSkillTreeUI()
                    showSkillTreeUI()
                }
                return true
            }
        }

        return false
    }

    /// Saves skill tree progress
    private func saveProgress() {
        let progress = SkillTreeProgress(skillPoints: skillPoints, unlockedSkills: Array(unlockedSkills))
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: "skillTreeProgress")
        }
    }

    /// Loads skill tree progress
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "skillTreeProgress"),
           let progress = try? JSONDecoder().decode(SkillTreeProgress.self, from: data)
        {
            skillPoints = progress.skillPoints
            unlockedSkills = Set(progress.unlockedSkills)

            // Update skill tree state
            for i in 0 ..< skillTree.count {
                skillTree[i].isUnlocked = unlockedSkills.contains(skillTree[i].id)
            }
            updateAvailableSkills()
        }
    }

    func update(deltaTime: TimeInterval) {
        // Skill tree doesn't need continuous updates
    }

    func reset() {
        // Reset doesn't affect skill progress
    }
}

/// Data structure for saving skill tree progress
struct SkillTreeProgress: Codable {
    let skillPoints: Int
    let unlockedSkills: [String]
}

// Extension to Player for skill integration
extension Player {
    func getCurrentSpeed() -> CGFloat {
        // This would need to be implemented in the Player class
        // For now, return a default value
        200.0
    }
}
