//
//  GameModeManager.swift
//  AvoidObstaclesGame
//
//  Manages different game modes, their UI, and transitions between modes.
//

import Foundation
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Protocol for game mode manager delegate
protocol GameModeManagerDelegate: AnyObject {
    func gameModeDidChange(to mode: GameMode) async
    func gameModeWinConditionMet(result: GameResult) async
    func showGameModeStartScreen(for mode: GameMode) async
    func showGameModeCompleteScreen(result: GameResult) async
}

/// Manages game modes and their presentation
@MainActor
class GameModeManager {
    // MARK: - Properties

    /// Delegate for game mode events
    weak var delegate: GameModeManagerDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Current game mode
    private(set) var currentMode: GameMode = .classic

    /// Game mode UI elements
    private var modeSelectionMenu: SKNode?
    private var modeStartScreen: SKNode?
    private var modeCompleteScreen: SKNode?

    /// Available game modes
    let availableModes: [GameMode] = [
        .classic,
        .timeTrial(duration: 60.0),
        .timeTrial(duration: 120.0),
        .survival,
        .puzzle,
        .challenge(level: 1),
    ]

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
    }

    /// Updates the scene reference
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Game Mode Management

    /// Sets the current game mode
    func setGameMode(_ mode: GameMode) {
        self.currentMode = mode
        Task {
            await self.delegate?.gameModeDidChange(to: mode)
        }
    }

    /// Shows the game mode selection menu
    @MainActor
    func showModeSelectionMenu() {
        guard let scene = self.scene else { return }

        self.hideModeSelectionMenu()

        // Create menu background
        let menuBackground = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.8), size: scene.size)
        menuBackground.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        menuBackground.zPosition = 100
        menuBackground.name = "modeMenuBackground"

        // Create title
        let titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel.text = "Select Game Mode"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: scene.size.height / 2 - 100)
        titleLabel.zPosition = 101
        menuBackground.addChild(titleLabel)

        // Create mode buttons
        for (index, mode) in self.availableModes.enumerated() {
            let button = self.createModeButton(for: mode, at: index)
            menuBackground.addChild(button)
        }

        // Create back button
        let backButton = SKLabelNode(fontNamed: "Chalkduster")
        backButton.text = "Back to Game"
        backButton.fontSize = 24
        backButton.fontColor = .yellow
        backButton.position = CGPoint(x: 0, y: -scene.size.height / 2 + 60)
        backButton.zPosition = 101
        backButton.name = "backButton"
        menuBackground.addChild(backButton)

        scene.addChild(menuBackground)
        self.modeSelectionMenu = menuBackground

        // Animate menu appearance
        menuBackground.alpha = 0
        menuBackground.run(SKAction.fadeIn(withDuration: 0.3))
    }

    /// Hides the game mode selection menu
    @MainActor
    func hideModeSelectionMenu() {
        self.modeSelectionMenu?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent(),
        ]))
        self.modeSelectionMenu = nil
    }

    /// Shows the start screen for a game mode
    @MainActor
    func showModeStartScreen(for mode: GameMode) {
        guard let scene = self.scene else { return }

        self.hideModeStartScreen()

        // Create start screen background
        let startBackground = SKSpriteNode(color: SKColor.blue.withAlphaComponent(0.9), size: CGSize(width: 300, height: 200))
        startBackground.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        startBackground.zPosition = 150
        startBackground.name = "modeStartBackground"

        // Create mode title
        let titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel.text = mode.displayName
        titleLabel.fontSize = 28
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 60)
        titleLabel.zPosition = 151
        startBackground.addChild(titleLabel)

        // Create description
        let descLabel = SKLabelNode(fontNamed: "Chalkduster")
        descLabel.text = mode.description
        descLabel.fontSize = 16
        descLabel.fontColor = .white
        descLabel.position = CGPoint(x: 0, y: 20)
        descLabel.zPosition = 151
        descLabel.numberOfLines = 0
        descLabel.preferredMaxLayoutWidth = 280
        startBackground.addChild(descLabel)

        // Create start button
        let startButton = SKLabelNode(fontNamed: "Chalkduster")
        startButton.text = "Start Game"
        startButton.fontSize = 20
        startButton.fontColor = .yellow
        startButton.position = CGPoint(x: 0, y: -40)
        startButton.zPosition = 151
        startButton.name = "startModeButton"
        startBackground.addChild(startButton)

        scene.addChild(startBackground)
        self.modeStartScreen = startBackground

        // Animate appearance
        startBackground.alpha = 0
        startBackground.run(SKAction.fadeIn(withDuration: 0.3))
    }

    /// Hides the mode start screen
    @MainActor
    func hideModeStartScreen() {
        self.modeStartScreen?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent(),
        ]))
        self.modeStartScreen = nil
    }

    /// Shows the completion screen for a game mode
    @MainActor
    func showModeCompleteScreen(result: GameResult) {
        guard let scene = self.scene else { return }

        self.hideModeCompleteScreen()

        // Create completion background
        let completeBackground = SKSpriteNode(color: result.completed ? SKColor.green.withAlphaComponent(0.9) : SKColor.red.withAlphaComponent(0.9), size: CGSize(width: 350, height: 250))
        completeBackground.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        completeBackground.zPosition = 150
        completeBackground.name = "modeCompleteBackground"

        // Create result title
        let titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel.text = result.completed ? "Mode Completed!" : "Mode Failed"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 80)
        titleLabel.zPosition = 151
        completeBackground.addChild(titleLabel)

        // Create score display
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(result.finalScore)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: 30)
        scoreLabel.zPosition = 151
        completeBackground.addChild(scoreLabel)

        // Create time display
        let timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel.text = String(format: "Time: %.1fs", result.survivalTime)
        timeLabel.fontSize = 20
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: 0, y: 0)
        timeLabel.zPosition = 151
        completeBackground.addChild(timeLabel)

        // Create continue button
        let continueButton = SKLabelNode(fontNamed: "Chalkduster")
        continueButton.text = "Continue"
        continueButton.fontSize = 22
        continueButton.fontColor = .yellow
        continueButton.position = CGPoint(x: 0, y: -60)
        continueButton.zPosition = 151
        continueButton.name = "continueModeButton"
        completeBackground.addChild(continueButton)

        scene.addChild(completeBackground)
        self.modeCompleteScreen = completeBackground

        // Animate appearance
        completeBackground.alpha = 0
        completeBackground.run(SKAction.fadeIn(withDuration: 0.3))
    }

    /// Hides the mode complete screen
    @MainActor
    func hideModeCompleteScreen() {
        self.modeCompleteScreen?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent(),
        ]))
        self.modeCompleteScreen = nil
    }

    // MARK: - UI Creation Helpers

    /// Creates a mode selection button
    @MainActor
    private func createModeButton(for mode: GameMode, at index: Int) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.name = "modeButton_\(index)"

        // Button background
        let buttonBg = SKSpriteNode(color: .systemBlue, size: CGSize(width: 200, height: 50))
        buttonBg.position = CGPoint(x: 0, y: 0)
        buttonBg.zPosition = 1
        buttonNode.addChild(buttonBg)

        // Mode name label
        let nameLabel = SKLabelNode(fontNamed: "Chalkduster")
        nameLabel.text = mode.displayName
        nameLabel.fontSize = 18
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 0)
        nameLabel.zPosition = 2
        buttonNode.addChild(nameLabel)

        // Position the button
        let yPosition = 200 - (index * 70)
        buttonNode.position = CGPoint(x: 0, y: yPosition)

        return buttonNode
    }

    // MARK: - Touch Handling

    /// Handles touch events for game mode UI
    @MainActor
    func handleTouch(at location: CGPoint) -> Bool {
        // Check mode selection menu
        if let menu = self.modeSelectionMenu {
            if let touchedNode = self.scene?.nodes(at: location).first(where: { node in
                node.name?.starts(with: "modeButton_") ?? false
            }) {
                if let name = touchedNode.name,
                   let indexStr = name.split(separator: "_").last,
                   let index = Int(indexStr),
                   index < self.availableModes.count
                {
                    let selectedMode = self.availableModes[index]
                    self.setGameMode(selectedMode)
                    self.hideModeSelectionMenu()
                    self.showModeStartScreen(for: selectedMode)
                    return true
                }
            }

            if let backButton = menu.childNode(withName: "backButton") as? SKLabelNode {
                // Calculate the button's position in scene coordinates
                let buttonScenePosition = menu.convert(backButton.position, to: self.scene!)
                // Check if touch is within a reasonable distance of the button (50 points)
                let distance = hypot(location.x - buttonScenePosition.x, location.y - buttonScenePosition.y)
                if distance <= 50 {
                    self.hideModeSelectionMenu()
                    return true
                }
            }
        }

        // Check mode start screen
        if let startScreen = self.modeStartScreen {
            if let startButton = startScreen.childNode(withName: "startModeButton") as? SKLabelNode {
                // Calculate the button's position in scene coordinates
                let buttonScenePosition = startScreen.convert(startButton.position, to: self.scene!)
                // Check if touch is within a reasonable distance of the button (50 points)
                let distance = hypot(location.x - buttonScenePosition.x, location.y - buttonScenePosition.y)
                if distance <= 50 {
                    self.hideModeStartScreen()
                    Task { @MainActor in
                        await self.delegate?.showGameModeStartScreen(for: self.currentMode)
                    }
                    return true
                }
            }
        }

        // Check mode complete screen
        if let completeScreen = self.modeCompleteScreen {
            if let continueButton = completeScreen.childNode(withName: "continueModeButton") as? SKLabelNode {
                // Calculate the button's position in scene coordinates
                let buttonScenePosition = completeScreen.convert(continueButton.position, to: self.scene!)
                // Check if touch is within a reasonable distance of the button (50 points)
                let distance = hypot(location.x - buttonScenePosition.x, location.y - buttonScenePosition.y)
                if distance <= 50 {
                    self.hideModeCompleteScreen()
                    return true
                }
            }
        }

        return false
    }
}
