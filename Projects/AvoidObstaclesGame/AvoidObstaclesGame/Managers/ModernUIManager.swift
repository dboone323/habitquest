//
// ModernUIManager.swift
// AvoidObstaclesGame
//
// Modern UI/UX redesign with improved information hierarchy, clean design,
// and enhanced user experience. Consolidates all UI elements into a cohesive,
// modern interface system.
//

import SpriteKit

/// Protocol for modern UI events
@MainActor
protocol ModernUIManagerDelegate: AnyObject {
    func restartButtonTapped()
    func pauseButtonTapped()
    func settingsButtonTapped()
    func statisticsButtonTapped()
}

/// Modern UI design system colors and constants
@MainActor
enum ModernUITheme {
    // Use ThemeManager for dynamic theming
    static var primaryColor: SKColor { ThemeManager.shared.currentTheme.colors.primaryColor }
    static var secondaryColor: SKColor { ThemeManager.shared.currentTheme.colors.secondaryColor }
    static var accentColor: SKColor { ThemeManager.shared.currentTheme.colors.accentColor }
    static var warningColor: SKColor { ThemeManager.shared.currentTheme.colors.warningColor }
    static var dangerColor: SKColor { ThemeManager.shared.currentTheme.colors.dangerColor }
    static var successColor: SKColor { ThemeManager.shared.currentTheme.colors.successColor }
    static var backgroundColor: SKColor { ThemeManager.shared.currentTheme.colors.backgroundPrimary }
    static var surfaceColor: SKColor { ThemeManager.shared.currentTheme.colors.backgroundSurface }
    static var textPrimaryColor: SKColor { ThemeManager.shared.currentTheme.colors.textPrimary }
    static var textSecondaryColor: SKColor { ThemeManager.shared.currentTheme.colors.textSecondary }
    static var textMutedColor: SKColor { ThemeManager.shared.currentTheme.colors.textMuted }

    static var cornerRadius: CGFloat { ThemeManager.shared.currentTheme.cornerRadius }
    static var borderWidth: CGFloat { ThemeManager.shared.currentTheme.borderWidth }
    static var shadowOpacity: Float { ThemeManager.shared.currentTheme.shadowOpacity }
    static var shadowRadius: CGFloat { ThemeManager.shared.currentTheme.shadowRadius }

    static var fontName: String { ThemeManager.shared.currentTheme.fontName }
    static var fontBoldName: String { ThemeManager.shared.currentTheme.fontBoldName }
}

/// Modern UI component for displaying information cards
@MainActor
class ModernUICard: SKNode {
    private let background: SKShapeNode
    private let titleLabel: SKLabelNode?
    private let valueLabel: SKLabelNode
    private let iconNode: SKSpriteNode?

    init(title: String?, value: String, iconName: String? = nil, size: CGSize, position: CGPoint) {
        // Create background with rounded corners
        self.background = SKShapeNode(rectOf: size, cornerRadius: ModernUITheme.cornerRadius)
        self.background.fillColor = ModernUITheme.surfaceColor
        self.background.strokeColor = ModernUITheme.primaryColor.withAlphaComponent(0.3)
        self.background.lineWidth = ModernUITheme.borderWidth
        self.background.position = .zero

        // Title label
        if let title {
            self.titleLabel = SKLabelNode(fontNamed: ModernUITheme.fontName)
            self.titleLabel?.text = title.uppercased()
            self.titleLabel?.fontSize = 12
            self.titleLabel?.fontColor = ModernUITheme.textSecondaryColor
            self.titleLabel?.position = CGPoint(x: 0, y: size.height / 2 - 20)
            self.titleLabel?.verticalAlignmentMode = .top
        } else {
            self.titleLabel = nil
        }

        // Value label
        self.valueLabel = SKLabelNode(fontNamed: ModernUITheme.fontBoldName)
        self.valueLabel.text = value
        self.valueLabel.fontSize = 18
        self.valueLabel.fontColor = ModernUITheme.textPrimaryColor
        self.valueLabel.position = CGPoint(x: 0, y: titleLabel != nil ? -5 : 0)
        self.valueLabel.verticalAlignmentMode = .center

        // Icon (if provided)
        if let iconName {
            self.iconNode = SKSpriteNode(imageNamed: iconName)
            self.iconNode?.size = CGSize(width: 24, height: 24)
            self.iconNode?.position = CGPoint(x: -size.width / 2 + 20, y: 0)
            self.iconNode?.color = ModernUITheme.accentColor
            self.iconNode?.colorBlendFactor = 1.0
        } else {
            self.iconNode = nil
        }

        super.init()

        self.position = position
        self.zPosition = 100

        self.addChild(background)
        if let titleLabel { self.addChild(titleLabel) }
        self.addChild(valueLabel)
        if let iconNode { self.addChild(iconNode) }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the card's value
    func updateValue(_ value: String) {
        self.valueLabel.text = value
    }

    /// Updates the card's color theme
    func updateTheme(color: SKColor) {
        self.background.strokeColor = color.withAlphaComponent(0.5)
        self.valueLabel.fontColor = color
        if let iconNode {
            iconNode.color = color
        }
    }
}

/// Modern progress bar component
@MainActor
class ModernUIProgressBar: SKNode {
    private let background: SKShapeNode
    private let fill: SKShapeNode
    private let label: SKLabelNode
    private let size: CGSize

    init(label: String, size: CGSize, position: CGPoint) {
        self.size = size

        // Background bar
        self.background = SKShapeNode(rectOf: size)
        self.background.fillColor = ModernUITheme.secondaryColor.withAlphaComponent(0.3)
        self.background.strokeColor = ModernUITheme.secondaryColor.withAlphaComponent(0.5)
        self.background.lineWidth = 1
        self.background.position = .zero

        // Fill bar
        self.fill = SKShapeNode(rectOf: CGSize(width: 0, height: size.height))
        self.fill.fillColor = ModernUITheme.accentColor
        self.fill.strokeColor = .clear
        self.fill.position = CGPoint(x: -size.width / 2, y: 0)

        // Label
        self.label = SKLabelNode(fontNamed: ModernUITheme.fontName)
        self.label.text = label
        self.label.fontSize = 12
        self.label.fontColor = ModernUITheme.textPrimaryColor
        self.label.position = CGPoint(x: 0, y: -size.height / 2 - 15)
        self.label.verticalAlignmentMode = .top

        super.init()

        self.position = position
        self.zPosition = 100

        self.addChild(background)
        self.addChild(fill)
        self.addChild(self.label)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the progress (0.0 to 1.0)
    func updateProgress(_ progress: CGFloat) {
        let clampedProgress = max(0, min(1, progress))
        let fillWidth = self.size.width * clampedProgress

        self.fill.run(SKAction.resize(toWidth: fillWidth, duration: 0.3))
    }

    /// Updates the label text
    func updateLabel(_ text: String) {
        self.label.text = text
    }

    /// Updates the progress bar's theme
    func updateTheme(color: SKColor) {
        self.fill.fillColor = color
        self.label.fontColor = ModernUITheme.textPrimaryColor
    }
}

/// Modern button component
@MainActor
class ModernUIButton: SKNode {
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let iconNode: SKSpriteNode?
    private let size: CGSize
    private var isPressed = false
    private var action: (() -> Void)?

    init(title: String, iconName: String? = nil, size: CGSize, position: CGPoint, action: (() -> Void)? = nil) {
        self.size = size
        self.action = action

        // Background with rounded corners
        self.background = SKShapeNode(rectOf: size, cornerRadius: ModernUITheme.cornerRadius)
        self.background.fillColor = ModernUITheme.primaryColor
        self.background.strokeColor = ModernUITheme.primaryColor.withAlphaComponent(0.8)
        self.background.lineWidth = ModernUITheme.borderWidth

        // Label
        self.label = SKLabelNode(fontNamed: ModernUITheme.fontBoldName)
        self.label.text = title
        self.label.fontSize = 16
        self.label.fontColor = .white
        self.label.verticalAlignmentMode = .center

        // Icon (if provided)
        if let iconName {
            self.iconNode = SKSpriteNode(imageNamed: iconName)
            self.iconNode?.size = CGSize(width: 20, height: 20)
            self.iconNode?.position = CGPoint(x: -size.width / 2 + 25, y: 0)
            self.label.position = CGPoint(x: 10, y: 0) // Shift text to make room for icon
        } else {
            self.iconNode = nil
            self.label.position = .zero
        }

        super.init()

        self.position = position
        self.zPosition = 100

        self.addChild(background)
        self.addChild(label)
        if let iconNode { self.addChild(iconNode) }

        // Enable user interaction
        self.isUserInteractionEnabled = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the button's theme
    func updateTheme() {
        self.background.fillColor = ModernUITheme.primaryColor
        self.background.strokeColor = ModernUITheme.primaryColor.withAlphaComponent(0.8)
        self.label.fontColor = .white
    }
}

/// Modern UI manager with theme support
@MainActor
class ModernUIManager: ThemeDelegate {
    // MARK: - Properties

    /// Delegate for modern UI events
    weak var delegate: ModernUIManagerDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Theme manager for dynamic theming
    private let themeManager = ThemeManager.shared

    /// Main UI container
    private var mainUIContainer: SKNode?

    /// HUD Elements
    private var scoreCard: ModernUICard?
    private var highScoreCard: ModernUICard?
    private var levelCard: ModernUICard?
    private var healthBar: ModernUIProgressBar?
    private var experienceBar: ModernUIProgressBar?

    /// Control buttons
    private var pauseButton: ModernUIButton?
    private var settingsButton: ModernUIButton?
    private var statisticsButton: ModernUIButton?

    /// Game state UI
    private var gameStateContainer: SKNode?
    private var gameOverCard: ModernUICard?
    private var restartButton: ModernUIButton?

    /// Notifications and effects
    private var notificationQueue: [SKNode] = []
    private var activeNotifications: [SKNode] = []

    /// Performance monitoring (compact)
    private var performanceCard: ModernUICard?

    /// Animation actions
    private let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
    private let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
    private let slideInAction = SKAction.moveBy(x: 0, y: -20, duration: 0.3)
    private let slideOutAction = SKAction.moveBy(x: 0, y: 20, duration: 0.3)

    /// Layout constants
    private let cardWidth: CGFloat = 120
    private let cardHeight: CGFloat = 60
    private let cardSpacing: CGFloat = 10
    private let topMargin: CGFloat = 40
    private let sideMargin: CGFloat = 20

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        self.setupModernUI()
        self.themeManager.delegate = self
    }

    /// Sets up the complete modern UI system
    private func setupModernUI() {
        guard let scene else { return }

        // Create main UI container
        self.mainUIContainer = SKNode()
        self.mainUIContainer?.zPosition = 100
        scene.addChild(self.mainUIContainer!)

        // Setup HUD cards
        self.setupHUDCards()

        // Setup control buttons
        self.setupControlButtons()

        // Setup game state UI
        self.setupGameStateUI()

        // Setup performance monitoring
        self.setupPerformanceMonitoring()
    }

    /// Sets up the main HUD cards
    private func setupHUDCards() {
        guard let container = mainUIContainer, let scene else { return }

        let sceneWidth = scene.size.width
        let startX = -sceneWidth / 2 + sideMargin + cardWidth / 2

        // Score card
        self.scoreCard = ModernUICard(
            title: "SCORE",
            value: "0",
            iconName: nil,
            size: CGSize(width: cardWidth, height: cardHeight),
            position: CGPoint(x: startX, y: scene.size.height / 2 - topMargin - cardHeight / 2)
        )
        container.addChild(self.scoreCard!)

        // High score card
        self.highScoreCard = ModernUICard(
            title: "BEST",
            value: "0",
            iconName: nil,
            size: CGSize(width: cardWidth, height: cardHeight),
            position: CGPoint(x: startX + cardWidth + cardSpacing, y: scene.size.height / 2 - topMargin - cardHeight / 2)
        )
        container.addChild(self.highScoreCard!)

        // Level card
        self.levelCard = ModernUICard(
            title: "LEVEL",
            value: "1",
            iconName: nil,
            size: CGSize(width: cardWidth, height: cardHeight),
            position: CGPoint(x: sceneWidth / 2 - sideMargin - cardWidth / 2, y: scene.size.height / 2 - topMargin - cardHeight / 2)
        )
        container.addChild(self.levelCard!)

        // Health bar (if applicable)
        self.healthBar = ModernUIProgressBar(
            label: "HEALTH",
            size: CGSize(width: cardWidth * 2 + cardSpacing, height: 8),
            position: CGPoint(x: startX + cardWidth + cardSpacing / 2, y: scene.size.height / 2 - topMargin - cardHeight - 25)
        )
        container.addChild(self.healthBar!)
        self.healthBar?.updateProgress(1.0) // Full health initially
    }

    /// Sets up control buttons
    private func setupControlButtons() {
        guard let container = mainUIContainer, let scene else { return }

        let buttonSize = CGSize(width: 50, height: 50)
        let buttonY = scene.size.height / 2 - topMargin - cardHeight - 80

        // Pause button
        self.pauseButton = ModernUIButton(
            title: "⏸",
            size: buttonSize,
            position: CGPoint(x: -scene.size.width / 2 + sideMargin + buttonSize.width / 2, y: buttonY)
        ) { [weak self] in
            self?.delegate?.pauseButtonTapped()
        }
        container.addChild(self.pauseButton!)

        // Settings button
        self.settingsButton = ModernUIButton(
            title: "⚙",
            size: buttonSize,
            position: CGPoint(x: -scene.size.width / 2 + sideMargin + buttonSize.width * 1.5 + cardSpacing, y: buttonY)
        ) { [weak self] in
            self?.delegate?.settingsButtonTapped()
        }
        container.addChild(self.settingsButton!)

        // Statistics button
        self.statisticsButton = ModernUIButton(
            title: "📊",
            size: buttonSize,
            position: CGPoint(x: -scene.size.width / 2 + sideMargin + buttonSize.width * 2.5 + cardSpacing * 2, y: buttonY)
        ) { [weak self] in
            self?.delegate?.statisticsButtonTapped()
        }
        container.addChild(self.statisticsButton!)
    }

    /// Sets up game state UI (game over, etc.)
    private func setupGameStateUI() {
        guard let scene else { return }

        self.gameStateContainer = SKNode()
        self.gameStateContainer?.zPosition = 200
        self.gameStateContainer?.alpha = 0 // Initially hidden
        scene.addChild(self.gameStateContainer!)
    }

    /// Sets up compact performance monitoring
    private func setupPerformanceMonitoring() {
        guard let container = mainUIContainer, let scene else { return }

        self.performanceCard = ModernUICard(
            title: "FPS",
            value: "60",
            iconName: nil,
            size: CGSize(width: 80, height: 40),
            position: CGPoint(x: scene.size.width / 2 - sideMargin - 40, y: -scene.size.height / 2 + 30)
        )
        self.performanceCard?.updateTheme(color: ModernUITheme.accentColor)
        container.addChild(self.performanceCard!)
    }

    // MARK: - HUD Updates

    /// Updates the score display
    func updateScore(_ score: Int) {
        self.scoreCard?.updateValue("\(score)")
    }

    /// Updates the high score display
    func updateHighScore(_ highScore: Int) {
        self.highScoreCard?.updateValue("\(highScore)")
    }

    /// Updates the level display
    func updateLevel(_ level: Int) {
        self.levelCard?.updateValue("\(level)")
    }

    /// Updates the health bar
    func updateHealth(_ health: CGFloat) {
        self.healthBar?.updateProgress(health)
        self.healthBar?.updateLabel("HEALTH: \(Int(health * 100))%")
    }

    /// Updates performance metrics
    func updatePerformance(fps: Double, memoryMB: Double) {
        let fpsText = String(format: "%.0f", fps)
        self.performanceCard?.updateValue(fpsText)

        // Color code based on performance
        let color: SKColor
        if fps >= 55 {
            color = ModernUITheme.successColor
        } else if fps >= 30 {
            color = ModernUITheme.warningColor
        } else {
            color = ModernUITheme.dangerColor
        }
        self.performanceCard?.updateTheme(color: color)
    }

    // MARK: - Game State Management

    /// Shows the game over screen
    func showGameOverScreen(finalScore: Int, isNewHighScore: Bool) {
        guard let container = gameStateContainer, let _ = scene else { return }

        // Create game over card
        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 200

        self.gameOverCard = ModernUICard(
            title: isNewHighScore ? "NEW HIGH SCORE!" : "GAME OVER",
            value: "Score: \(finalScore)",
            iconName: isNewHighScore ? "trophy" : "gameover",
            size: CGSize(width: cardWidth, height: cardHeight),
            position: CGPoint(x: 0, y: 50)
        )

        if isNewHighScore {
            self.gameOverCard?.updateTheme(color: ModernUITheme.successColor)
        } else {
            self.gameOverCard?.updateTheme(color: ModernUITheme.dangerColor)
        }

        container.addChild(self.gameOverCard!)

        // Create restart button
        self.restartButton = ModernUIButton(
            title: "RESTART",
            iconName: "restart",
            size: CGSize(width: 150, height: 50),
            position: CGPoint(x: 0, y: -50)
        ) { [weak self] in
            self?.delegate?.restartButtonTapped()
        }
        container.addChild(self.restartButton!)

        // Animate in
        container.run(self.fadeInAction)
        self.gameOverCard?.run(self.slideInAction)
        self.restartButton?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            self.slideInAction,
        ]))
    }

    /// Hides the game over screen
    func hideGameOverScreen() {
        guard let container = gameStateContainer else { return }

        container.run(SKAction.sequence([
            self.fadeOutAction,
            SKAction.run { [weak self] in
                self?.gameOverCard?.removeFromParent()
                self?.restartButton?.removeFromParent()
                self?.gameOverCard = nil
                self?.restartButton = nil
            },
        ]))
    }

    // MARK: - Notifications

    /// Shows a notification
    func showNotification(title: String, message: String, type: NotificationType = .info, duration: TimeInterval = 3.0) {
        guard let scene else { return }

        let notificationWidth: CGFloat = 280
        let notificationHeight: CGFloat = 80

        let notification = ModernUICard(
            title: title,
            value: message,
            iconName: type.iconName,
            size: CGSize(width: notificationWidth, height: notificationHeight),
            position: CGPoint(x: 0, y: scene.size.height / 2 - 100)
        )

        notification.updateTheme(color: type.color)
        notification.alpha = 0

        // Position based on existing notifications
        let yOffset = CGFloat(self.activeNotifications.count) * (notificationHeight + 10)
        notification.position.y -= yOffset

        scene.addChild(notification)
        self.activeNotifications.append(notification)

        // Animate in
        notification.run(SKAction.sequence([
            self.fadeInAction,
            SKAction.wait(forDuration: duration),
            SKAction.group([
                self.fadeOutAction,
                SKAction.moveBy(x: 300, y: 0, duration: 0.5),
            ]),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                if let index = self?.activeNotifications.firstIndex(of: notification) {
                    self?.activeNotifications.remove(at: index)
                    // Reposition remaining notifications
                    self?.repositionNotifications()
                }
            },
        ]))
    }

    /// Repositions active notifications
    private func repositionNotifications() {
        guard let scene else { return }

        let notificationHeight: CGFloat = 80
        for (index, notification) in self.activeNotifications.enumerated() {
            let targetY = scene.size.height / 2 - 100 - CGFloat(index) * (notificationHeight + 10)
            notification.run(SKAction.moveTo(y: targetY, duration: 0.3))
        }
    }

    // MARK: - Effects and Animations

    /// Shows a score popup
    func showScorePopup(score: Int, position: CGPoint) {
        guard let scene else { return }

        let popup = SKLabelNode(fontNamed: ModernUITheme.fontBoldName)
        popup.text = "+\(score)"
        popup.fontSize = 24
        popup.fontColor = ModernUITheme.successColor
        popup.position = position
        popup.zPosition = 150

        scene.addChild(popup)

        // Animate popup
        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.3)

        popup.run(SKAction.group([
            moveUp,
            fadeOut,
            SKAction.sequence([
                scaleUp,
                SKAction.scale(to: 1.0, duration: 0.7),
            ]),
        ])) {
            popup.removeFromParent()
        }
    }

    /// Shows a level up effect
    func showLevelUpEffect() {
        guard let scene else { return }

        let effect = SKLabelNode(fontNamed: ModernUITheme.fontBoldName)
        effect.text = "LEVEL UP!"
        effect.fontSize = 36
        effect.fontColor = ModernUITheme.accentColor
        effect.position = CGPoint(x: 0, y: 0)
        effect.zPosition = 300

        scene.addChild(effect)

        // Animate level up
        let scaleSequence = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.3),
        ])

        let fadeSequence = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.5),
        ])

        effect.run(SKAction.group([
            scaleSequence,
            fadeSequence,
            SKAction.rotate(byAngle: .pi * 2, duration: 1.0),
        ])) {
            effect.removeFromParent()
        }

        // Show notification
        self.showNotification(
            title: "LEVEL UP",
            message: "Difficulty increased!",
            type: .success,
            duration: 2.0
        )
    }

    // MARK: - Touch Handling

    /// Handles touch events
    func handleTouch(at location: CGPoint) -> Bool {
        // Check if any UI element was touched
        if let pauseButton, pauseButton.contains(location) {
            return true
        }
        if let settingsButton, settingsButton.contains(location) {
            return true
        }
        if let statisticsButton, statisticsButton.contains(location) {
            return true
        }
        if let restartButton, restartButton.contains(location) {
            return true
        }

        return false
    }

    // MARK: - Cleanup

    /// Removes all UI elements
    func removeAllUI() {
        self.mainUIContainer?.removeFromParent()
        self.gameStateContainer?.removeFromParent()
        self.activeNotifications.forEach { $0.removeFromParent() }

        self.mainUIContainer = nil
        self.gameStateContainer = nil
        self.activeNotifications.removeAll()
    }

    // MARK: - ThemeDelegate

    func themeDidChange(to theme: Theme) {
        // Update all UI elements to reflect the new theme
        updateAllUIForTheme()
    }

    /// Updates all UI elements when theme changes
    private func updateAllUIForTheme() {
        // Update HUD cards
        scoreCard?.updateTheme(color: ModernUITheme.primaryColor)
        highScoreCard?.updateTheme(color: ModernUITheme.secondaryColor)
        levelCard?.updateTheme(color: ModernUITheme.accentColor)
        performanceCard?.updateTheme(color: ModernUITheme.accentColor)

        // Update progress bars
        healthBar?.updateTheme(color: ModernUITheme.successColor)

        // Update buttons
        pauseButton?.updateTheme()
        settingsButton?.updateTheme()
        statisticsButton?.updateTheme()
        restartButton?.updateTheme()

        // Update game over card
        gameOverCard?.updateTheme(color: ModernUITheme.primaryColor)

        // Update active notifications
        for notification in activeNotifications {
            if let card = notification as? ModernUICard {
                card.updateTheme(color: ModernUITheme.primaryColor)
            }
        }
    }
}

/// Notification types for the modern UI
enum NotificationType {
    case info
    case success
    case warning
    case error

    @MainActor
    var color: SKColor {
        switch self {
        case .info: return ThemeManager.shared.currentTheme.colors.primaryColor
        case .success: return ThemeManager.shared.currentTheme.colors.successColor
        case .warning: return ThemeManager.shared.currentTheme.colors.warningColor
        case .error: return ThemeManager.shared.currentTheme.colors.dangerColor
        }
    }

    var iconName: String? {
        switch self {
        case .info: return "info"
        case .success: return "checkmark"
        case .warning: return "warning"
        case .error: return "error"
        }
    }
}
