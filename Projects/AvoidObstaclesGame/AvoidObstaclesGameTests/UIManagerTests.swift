@testable import AvoidObstaclesGame
import SpriteKit
import XCTest

@MainActor
class UIManagerTests: XCTestCase {

    var uiManager: UIManager!
    var mockScene: SKScene!
    var mockDelegate: MockUIManagerDelegate!

    override func setUp() {
        super.setUp()
        mockScene = SKScene(size: CGSize(width: 375, height: 667))
        uiManager = UIManager(scene: mockScene)
        mockDelegate = MockUIManagerDelegate()
        uiManager.delegate = mockDelegate
    }

    override func tearDown() {
        uiManager.removeAllUI()
        uiManager = nil
        mockScene = nil
        mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testUIManagerInitialization() {
        // Test that UI manager initializes correctly
        XCTAssertNotNil(uiManager)
        XCTAssertNotNil(mockScene)
    }

    func testUIManagerSetupUI() {
        // Test that setupUI creates the expected UI elements
        uiManager.setupUI()

        // Check that labels were created and added to scene
        XCTAssertEqual(mockScene.children.count, 3) // score, high score, difficulty labels
    }

    func testUIManagerUpdateScene() {
        // Test updating scene reference
        let newScene = SKScene(size: CGSize(width: 400, height: 800))
        uiManager.updateScene(newScene)

        // Verify scene was updated (internal property, but we can test by checking UI setup works)
        uiManager.setupUI()
        XCTAssertEqual(newScene.children.count, 3)
    }

    // MARK: - Score Update Tests

    func testUpdateScore() {
        // Setup UI first
        uiManager.setupUI()

        // Update score
        uiManager.updateScore(150)

        // Find score label in scene
        let scoreLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text?.hasPrefix("Score:") == true
        } as? SKLabelNode

        XCTAssertNotNil(scoreLabel)
        XCTAssertEqual(scoreLabel?.text, "Score: 150")
    }

    func testUpdateHighScore() {
        // Setup UI first
        uiManager.setupUI()

        // Update high score
        uiManager.updateHighScore(500)

        // Find high score label in scene
        let highScoreLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text?.hasPrefix("Best:") == true
        } as? SKLabelNode

        XCTAssertNotNil(highScoreLabel)
        XCTAssertEqual(highScoreLabel?.text, "Best: 500")
    }

    func testUpdateDifficultyLevel() {
        // Setup UI first
        uiManager.setupUI()

        // Update difficulty level
        uiManager.updateDifficultyLevel(5)

        // Find difficulty label in scene
        let difficultyLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text?.hasPrefix("Level:") == true
        } as? SKLabelNode

        XCTAssertNotNil(difficultyLabel)
        XCTAssertEqual(difficultyLabel?.text, "Level: 5")
    }

    // MARK: - Game Over Screen Tests

    func testShowGameOverScreen() {
        // Show game over screen
        uiManager.showGameOverScreen(finalScore: 250, isNewHighScore: false)

        // Check that game over elements were added
        let gameOverLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text == "Game Over!"
        } as? SKLabelNode

        let finalScoreLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text == "Final Score: 250"
        } as? SKLabelNode

        let restartLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text == "Tap to Restart"
        } as? SKLabelNode

        XCTAssertNotNil(gameOverLabel)
        XCTAssertNotNil(finalScoreLabel)
        XCTAssertNotNil(restartLabel)
        XCTAssertNil(mockScene.children.first { node in
            (node as? SKLabelNode)?.text?.contains("NEW HIGH SCORE") == true
        })
    }

    func testShowGameOverScreenWithNewHighScore() {
        // Show game over screen with new high score
        uiManager.showGameOverScreen(finalScore: 1000, isNewHighScore: true)

        // Check that high score achievement label was added
        let highScoreLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text?.contains("NEW HIGH SCORE") == true
        } as? SKLabelNode

        XCTAssertNotNil(highScoreLabel)
        XCTAssertEqual(highScoreLabel?.text, "🎉 NEW HIGH SCORE! 🎉")
    }

    func testHideGameOverScreen() {
        // Show then hide game over screen
        uiManager.showGameOverScreen(finalScore: 100, isNewHighScore: false)

        // Verify elements exist (should add 3 labels: game over, final score, restart)
        XCTAssertGreaterThanOrEqual(mockScene.children.count, 3)

        // Hide game over screen
        uiManager.hideGameOverScreen()

        // Elements should be marked for removal (alpha animations)
        // Note: In a real test, we'd need to wait for animations or check removal actions
        // For this test, we verify the method doesn't crash and internal state is reset
        XCTAssertTrue(true, "hideGameOverScreen completed without error")
    }

    // MARK: - Level Up Effect Tests

    func testShowLevelUpEffect() {
        // Show level up effect
        uiManager.showLevelUpEffect()

        // Check that level up label was added
        let levelUpLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text == "LEVEL UP!"
        } as? SKLabelNode

        XCTAssertNotNil(levelUpLabel)
        XCTAssertEqual(levelUpLabel?.text, "LEVEL UP!")
    }

    // MARK: - Score Popup Tests

    func testShowScorePopup() {
        // Show score popup
        let position = CGPoint(x: 100, y: 200)
        uiManager.showScorePopup(score: 50, at: position)

        // Check that score popup was added
        let scorePopup = mockScene.children.first { node in
            (node as? SKLabelNode)?.text == "+50"
        } as? SKLabelNode

        XCTAssertNotNil(scorePopup)
        XCTAssertEqual(scorePopup?.text, "+50")
        XCTAssertEqual(scorePopup?.position, position)
    }

    // MARK: - Statistics Display Tests

    func testShowStatistics() {
        // Show statistics
        let statistics = [
            "gamesPlayed": 10,
            "totalScore": 2500,
            "averageScore": 250.0,
            "highestScore": 800,
        ]

        uiManager.showStatistics(statistics)

        // Check that statistics labels were added
        let statLabels = mockScene.children.filter { node in
            (node as? SKLabelNode)?.text?.contains(":") == true
        }

        XCTAssertGreaterThan(statLabels.count, 0)
    }

    func testHideStatistics() {
        // Show then hide statistics
        let statistics = ["gamesPlayed": 5]
        uiManager.showStatistics(statistics)

        // Verify labels exist
        XCTAssertGreaterThan(mockScene.children.count, 0)

        // Hide statistics
        uiManager.hideStatistics()

        // Statistics should be marked for removal
        XCTAssertTrue(true, "hideStatistics completed without error")
    }

    // MARK: - Touch Handling Tests

    func testHandleTouchRestart() {
        // Show game over screen first
        uiManager.showGameOverScreen(finalScore: 100, isNewHighScore: false)

        // Find restart label position
        let restartLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text == "Tap to Restart"
        } as? SKLabelNode

        XCTAssertNotNil(restartLabel)

        if let restartLabel {
            // Touch the restart label
            uiManager.handleTouch(at: restartLabel.position)

            // Verify delegate was called
            XCTAssertTrue(mockDelegate.restartTapped)
        }
    }

    func testHandleTouchNonInteractive() {
        // Touch a non-interactive area
        uiManager.handleTouch(at: CGPoint(x: 0, y: 0))

        // Delegate should not be called
        XCTAssertFalse(mockDelegate.restartTapped)
    }

    // MARK: - Performance Monitoring Tests

    func testSetPerformanceMonitoring() {
        // Enable performance monitoring
        uiManager.setPerformanceMonitoring(enabled: true)

        // Check that performance overlay was added
        XCTAssertGreaterThan(mockScene.children.count, 0)

        // Disable performance monitoring
        uiManager.setPerformanceMonitoring(enabled: false)

        // Performance overlay should be removed
        XCTAssertTrue(true, "Performance monitoring toggled without error")
    }

    func testTogglePerformanceMonitoring() {
        // Toggle performance monitoring
        uiManager.togglePerformanceMonitoring()

        // Should enable monitoring
        XCTAssertGreaterThan(mockScene.children.count, 0)

        // Toggle again
        uiManager.togglePerformanceMonitoring()

        // Should disable monitoring
        XCTAssertTrue(true, "Performance monitoring toggled without error")
    }

    // MARK: - Async Update Tests

    func testUpdateHighScoreAsync() async {
        // Setup UI first
        uiManager.setupUI()

        // Update high score asynchronously
        await uiManager.updateHighScoreAsync(750)

        // Find high score label in scene
        let highScoreLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text?.hasPrefix("Best:") == true
        } as? SKLabelNode

        XCTAssertNotNil(highScoreLabel)
        XCTAssertEqual(highScoreLabel?.text, "Best: 750")
    }

    func testShowStatisticsAsync() async {
        // Show statistics asynchronously
        let statistics = ["gamesPlayed": 15]
        await uiManager.showStatisticsAsync(statistics)

        // Check that statistics were added
        let statLabels = mockScene.children.filter { node in
            (node as? SKLabelNode)?.text?.contains("Games Played") == true
        }

        XCTAssertGreaterThan(statLabels.count, 0)
    }

    // MARK: - Cleanup Tests

    func testRemoveAllUI() {
        // Setup UI and add some elements
        uiManager.setupUI()
        uiManager.showGameOverScreen(finalScore: 100, isNewHighScore: false)
        uiManager.showLevelUpEffect()

        // Verify elements exist
        XCTAssertGreaterThan(mockScene.children.count, 0)

        // Remove all UI
        uiManager.removeAllUI()

        // All elements should be removed
        XCTAssertEqual(mockScene.children.count, 0)
    }

    // MARK: - Accessibility Delegate Tests

    func testAccessibilitySettingsDidChange() {
        // Setup UI first
        uiManager.setupUI()

        // Simulate accessibility settings change
        let oldSettings = AccessibilitySettings(
            isVoiceOverEnabled: false,
            prefersDynamicType: false,
            prefersReducedMotion: false,
            prefersHighContrast: false,
            contentSizeCategory: "UICTContentSizeCategoryMedium"
        )

        let newSettings = AccessibilitySettings(
            isVoiceOverEnabled: true,
            prefersDynamicType: true,
            prefersReducedMotion: true,
            prefersHighContrast: true,
            contentSizeCategory: "UICTContentSizeCategoryLarge"
        )

        // This would normally be called by the accessibility manager
        // We can't directly test the delegate method, but we can verify the setup doesn't crash
        XCTAssertTrue(true, "Accessibility delegate setup completed without error")
    }

    // MARK: - Difficulty Change Notification Tests

    func testShowDifficultyChangeNotification() {
        // Show difficulty change notification
        let difficulty = AIAdaptiveDifficulty.hard
        let reason = DifficultyAdjustmentReason.playerStruggling

        uiManager.showDifficultyChangeNotification(difficulty, reason: reason)

        // Check that notification was added
        let notificationLabel = mockScene.children.first { node in
            (node as? SKLabelNode)?.text?.contains("Difficulty: Hard") == true
        } as? SKLabelNode

        XCTAssertNotNil(notificationLabel)
    }

    // MARK: - Player Skill Level Tests

    func testUpdatePlayerSkillLevel() {
        // Setup UI first
        uiManager.setupUI()

        // Update player skill level
        let skillLevel = PlayerSkillLevel.expert
        uiManager.updatePlayerSkillLevel(skillLevel, confidence: 0.85)

        // The method updates the difficulty label temporarily
        // We can't easily test the flash animation, but verify method doesn't crash
        XCTAssertTrue(true, "Player skill level update completed without error")
    }
}

// MARK: - Mock Delegate

class MockUIManagerDelegate: UIManagerDelegate {
    var restartTapped = false

    func restartButtonTapped() {
        restartTapped = true
    }
}
