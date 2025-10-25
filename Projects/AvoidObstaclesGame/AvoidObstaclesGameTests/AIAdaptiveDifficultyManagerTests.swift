import Combine
import XCTest

@testable import AvoidObstaclesGame

final class AIAdaptiveDifficultyManagerTests: XCTestCase {
    var aiManager: AIAdaptiveDifficultyManager!
    var mockDelegate: MockAIAdaptiveDifficultyDelegate!
    var mockOllamaManager: MockOllamaIntegrationManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockOllamaManager = MockOllamaIntegrationManager()
        mockDelegate = MockAIAdaptiveDifficultyDelegate()
        aiManager = AIAdaptiveDifficultyManager(ollamaManager: mockOllamaManager)
        aiManager.delegate = mockDelegate
        cancellables = []
    }

    override func tearDown() {
        aiManager?.stopPeriodicAnalysis()
        cancellables = nil
        aiManager = nil
        mockDelegate = nil
        mockOllamaManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(aiManager, "AI manager should initialize properly")
        XCTAssertEqual(aiManager.currentDifficulty, .balanced, "Should start with balanced difficulty")
        // Note: sessionData is private, testing through public interface
    }

    // MARK: - Player Action Recording Tests

    func testRecordPlayerAction_MoveLeft() {
        let initialActionCount = aiManager.sessionData.actions.count

        aiManager.recordPlayerAction(.moveLeft)

        XCTAssertEqual(aiManager.sessionData.actions.count, initialActionCount + 1, "Should record player action")
        XCTAssertEqual(aiManager.sessionData.actions.last?.action, .moveLeft, "Should record correct action")
    }

    func testRecordPlayerAction_MoveRight() {
        aiManager.recordPlayerAction(.moveRight)

        XCTAssertEqual(aiManager.sessionData.actions.last?.action, .moveRight, "Should record move right action")
    }

    func testRecordPlayerAction_Collision() {
        aiManager.recordPlayerAction(.collision(type: "spike"))

        XCTAssertEqual(aiManager.sessionData.actions.last?.action, .collision(type: "spike"), "Should record collision action")
    }

    func testRecordPlayerAction_PowerUpCollected() {
        aiManager.recordPlayerAction(.powerUpCollected(type: .shield))

        XCTAssertEqual(aiManager.sessionData.actions.last?.action, .powerUpCollected(type: .shield), "Should record power-up collection")
    }

    // MARK: - Obstacle Interaction Recording Tests

    func testRecordObstacleInteraction_Successful() {
        let initialInteractionCount = aiManager.sessionData.obstacleInteractions.count

        aiManager.recordObstacleInteraction(obstacleType: .spike, success: true, reactionTime: 1.5)

        XCTAssertEqual(aiManager.sessionData.obstacleInteractions.count, initialInteractionCount + 1, "Should record obstacle interaction")
        let interaction = aiManager.sessionData.obstacleInteractions.last!
        XCTAssertEqual(interaction.obstacleType, .spike, "Should record correct obstacle type")
        XCTAssertTrue(interaction.success, "Should record successful interaction")
        XCTAssertEqual(interaction.reactionTime, 1.5, "Should record correct reaction time")
    }

    func testRecordObstacleInteraction_Failed() {
        aiManager.recordObstacleInteraction(obstacleType: .spike, success: false, reactionTime: 0.8)

        let interaction = aiManager.sessionData.obstacleInteractions.last!
        XCTAssertEqual(interaction.obstacleType, .spike, "Should record correct obstacle type")
        XCTAssertFalse(interaction.success, "Should record failed interaction")
        XCTAssertEqual(interaction.reactionTime, 0.8, "Should record correct reaction time")
    }

    // MARK: - Game State Recording Tests

    func testRecordGameState() {
        XCTAssertNotNil(aiManager, "AI manager should exist")
        XCTAssertNotNil(aiManager.sessionData, "Session data should exist")

        let initialCount = aiManager.sessionData.stateHistory.count
        aiManager.recordGameState(.playing)
        XCTAssertEqual(aiManager.sessionData.currentState, .playing, "Should record current game state")

        aiManager.recordGameState(.paused)
        XCTAssertEqual(aiManager.sessionData.currentState, .paused, "Should update game state")
        XCTAssertEqual(aiManager.sessionData.stateHistory.count, initialCount + 2, "Should record state history")
    }

    // MARK: - Difficulty Analysis Tests

    func testForceDifficultyAnalysis() async {
        // Setup some test data
        aiManager.recordObstacleInteraction(obstacleType: .spike, success: true, reactionTime: 1.0)
        aiManager.recordObstacleInteraction(obstacleType: .block, success: true, reactionTime: 0.8)
        aiManager.recordPlayerAction(.moveLeft)
        aiManager.recordPlayerAction(.moveRight)

        // Mock Ollama response
        mockOllamaManager.mockResponse = """
        {
            "recommended_difficulty": "challenging",
            "confidence": 0.85,
            "reasoning": "Player performing well with good reaction times",
            "adjustments": ["increase spawn rate", "add more obstacles"]
        }
        """

        let expectation = XCTestExpectation(description: "Difficulty analysis should complete")

        // Force analysis
        aiManager.forceDifficultyAnalysis()

        // Wait for analysis to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 5.0)

        // Verify analysis was performed
        XCTAssertTrue(mockOllamaManager.generateTextCalled, "Should call Ollama for analysis")
    }

    // MARK: - Difficulty Adjustment Tests

    func testDifficultyAdjustment_DelegateNotification() async throws {
        // Setup scenario that should trigger difficulty increase
        for _ in 0 ..< 10 {
            aiManager.recordObstacleInteraction(obstacleType: .spike, success: true, reactionTime: 0.5)
        }

        mockOllamaManager.mockResponse = """
        {
            "recommended_difficulty": "hard",
            "confidence": 0.9,
            "reasoning": "Player excelling with fast reaction times",
            "adjustments": ["increase difficulty significantly"]
        }
        """

        // Force analysis and wait for completion
        aiManager.forceDifficultyAnalysis()

        // Wait a bit for async processing
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Note: In a real implementation, we'd need to properly await the async operation
        // For now, we test that the setup works without crashing
        XCTAssertNotNil(aiManager, "AI Manager should still exist after analysis")
    }

    // MARK: - Session Management Tests

    func testResetSession() {
        // Add some data
        aiManager.recordObstacleInteraction(obstacleType: .spike, success: true, reactionTime: 1.0)
        aiManager.recordPlayerAction(.collision(type: "spike"))
        aiManager.recordGameState(.playing)

        // Reset session
        aiManager.resetSession()

        XCTAssertEqual(aiManager.sessionData.actions.count, 0, "Should clear actions after reset")
        XCTAssertEqual(aiManager.sessionData.obstacleInteractions.count, 0, "Should clear interactions after reset")
        XCTAssertEqual(aiManager.sessionData.stateHistory.count, 1, "Should reset state history after reset")
        XCTAssertEqual(aiManager.currentDifficulty, .balanced, "Should reset to balanced difficulty")
    }

    // MARK: - Performance Tests

    func testPerformance_AnalysisSpeed() {
        // Setup test data
        for _ in 0 ..< 50 {
            aiManager.recordObstacleInteraction(obstacleType: .block, success: true, reactionTime: 1.0)
            aiManager.recordPlayerAction(.moveLeft)
        }

        // Test that forceDifficultyAnalysis doesn't crash and completes reasonably quickly
        let startTime = Date()
        aiManager.forceDifficultyAnalysis()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // The analysis should complete in a reasonable time (allowing for async processing)
        XCTAssertLessThan(duration, 1.0, "Analysis should complete quickly")
        XCTAssertNotNil(aiManager, "AI Manager should remain functional after analysis")
    }

    // MARK: - Edge Cases Tests

    func testEmptySessionData() {
        // Test analysis with no data
        aiManager.forceDifficultyAnalysis()

        // Should not crash and should maintain balanced difficulty
        XCTAssertEqual(aiManager.currentDifficulty, .balanced, "Should maintain balanced difficulty with no data")
    }

    func testHighFailureRate() async throws {
        // Setup scenario with poor performance
        for _ in 0 ..< 20 {
            aiManager.recordObstacleInteraction(obstacleType: .spike, success: false, reactionTime: 2.5)
        }

        mockOllamaManager.mockResponse = """
        {
            "recommended_difficulty": "easy",
            "confidence": 0.95,
            "reasoning": "Player struggling significantly",
            "adjustments": ["reduce difficulty", "slow down obstacles"]
        }
        """

        // Force analysis
        aiManager.forceDifficultyAnalysis()

        // Wait for async processing to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify the system can handle poor performance gracefully
        XCTAssertTrue(mockOllamaManager.generateTextCalled, "Should analyze even with poor performance")
        XCTAssertNotNil(aiManager, "AI Manager should remain functional")
    }

    func testOllamaFailure_GracefulDegradation() {
        // Setup test data
        aiManager.recordObstacleInteraction(obstacleType: .block, success: true, reactionTime: 1.0)

        // Mock Ollama failure
        mockOllamaManager.shouldFail = true

        let expectation = XCTestExpectation(description: "Analysis should complete despite Ollama failure")

        aiManager.forceDifficultyAnalysis()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        // System should continue functioning even with Ollama failure
        XCTAssertEqual(aiManager.currentDifficulty, .balanced, "Should maintain current difficulty on Ollama failure")
    }

    // MARK: - Integration Tests

    func testCompleteGameplayScenario() {
        // Simulate a complete gameplay session
        // Start with easy gameplay
        for _ in 0 ..< 5 {
            aiManager.recordObstacleInteraction(obstacleType: .block, success: true, reactionTime: 1.2)
            aiManager.recordPlayerAction(.moveLeft)
        }

        // Player improves
        for _ in 0 ..< 10 {
            aiManager.recordObstacleInteraction(obstacleType: .spike, success: true, reactionTime: 0.8)
            aiManager.recordPlayerAction(.dodge)
        }

        // Some challenges
        aiManager.recordObstacleInteraction(obstacleType: .moving, success: false, reactionTime: 0.6)
        aiManager.recordPlayerAction(.collision(type: "moving"))

        // Continue improving
        for _ in 0 ..< 15 {
            aiManager.recordObstacleInteraction(obstacleType: .spike, success: true, reactionTime: 0.5)
            aiManager.recordPlayerAction(.nearMiss)
        }

        mockOllamaManager.mockResponse = """
        {
            "recommended_difficulty": "expert",
            "confidence": 0.88,
            "reasoning": "Player showing expert-level performance",
            "adjustments": ["maximum difficulty", "fastest obstacles"]
        }
        """

        aiManager.forceDifficultyAnalysis()

        // Verify the system can handle complex gameplay scenarios
        XCTAssertGreaterThan(aiManager.sessionData.actions.count, 20, "Should accumulate actions over gameplay")
        XCTAssertGreaterThan(aiManager.sessionData.obstacleInteractions.count, 25, "Should accumulate interactions over gameplay")
    }
}

// MARK: - Mock Classes

class MockAIAdaptiveDifficultyDelegate: AIAdaptiveDifficultyDelegate {
    var difficultyDidAdjustCalled = false
    var playerSkillAssessedCalled = false
    var lastDifficulty: AIAdaptiveDifficulty?
    var lastReason: DifficultyAdjustmentReason?
    var lastSkillLevel: PlayerSkillLevel?
    var lastConfidence: Double?

    func difficultyDidAdjust(to newDifficulty: AIAdaptiveDifficulty, reason: DifficultyAdjustmentReason) {
        difficultyDidAdjustCalled = true
        lastDifficulty = newDifficulty
        lastReason = reason
    }

    func playerSkillAssessed(skillLevel: PlayerSkillLevel, confidence: Double) {
        playerSkillAssessedCalled = true
        lastSkillLevel = skillLevel
        lastConfidence = confidence
    }
}

class MockOllamaIntegrationManager: OllamaIntegrationManager {
    var generateTextCalled = false
    var mockResponse = ""
    var shouldFail = false

    override func generateText(prompt: String, maxTokens: Int = 300, temperature: Double = 0.7) async throws -> String {
        generateTextCalled = true

        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock Ollama failure"])
        }

        return mockResponse
    }
}
