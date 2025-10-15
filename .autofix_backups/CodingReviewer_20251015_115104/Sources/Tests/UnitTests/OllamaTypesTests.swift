import XCTest
@testable import CodingReviewer

final class OllamaTypesTests: XCTestCase {

    func testOllamaConfigDefaultInitialization() {
        let config = OllamaConfig()

        XCTAssertEqual(config.baseURL, "http://localhost:11434")
        XCTAssertEqual(config.defaultModel, "llama2")
        XCTAssertEqual(config.timeout, 60.0)
        XCTAssertEqual(config.maxRetries, 3)
        XCTAssertEqual(config.temperature, 0.7)
        XCTAssertEqual(config.maxTokens, 2048)
        XCTAssertTrue(config.enableCaching)
        XCTAssertEqual(config.cacheExpiryTime, 3600)
        XCTAssertTrue(config.enableMetrics)
        XCTAssertTrue(config.enableAutoModelDownload)
        XCTAssertEqual(config.fallbackModels, ["llama2", "phi3"])
        XCTAssertEqual(config.requestThrottleDelay, 0.1)
        XCTAssertTrue(config.enableCloudModels)
        XCTAssertEqual(config.cloudEndpoint, "https://ollama.com")
        XCTAssertFalse(config.preferCloudModels)
    }

    func testOllamaConfigCustomInitialization() {
        let config = OllamaConfig(
            baseURL: "http://custom:8080",
            defaultModel: "custom-model",
            timeout: 30.0,
            maxRetries: 5,
            temperature: 0.5,
            maxTokens: 1024,
            enableCaching: false,
            cacheExpiryTime: 1800,
            enableMetrics: false,
            enableAutoModelDownload: false,
            fallbackModels: ["model1", "model2"],
            requestThrottleDelay: 0.2,
            enableCloudModels: false,
            cloudEndpoint: "https://custom.com",
            preferCloudModels: true
        )

        XCTAssertEqual(config.baseURL, "http://custom:8080")
        XCTAssertEqual(config.defaultModel, "custom-model")
        XCTAssertEqual(config.timeout, 30.0)
        XCTAssertEqual(config.maxRetries, 5)
        XCTAssertEqual(config.temperature, 0.5)
        XCTAssertEqual(config.maxTokens, 1024)
        XCTAssertFalse(config.enableCaching)
        XCTAssertEqual(config.cacheExpiryTime, 1800)
        XCTAssertFalse(config.enableMetrics)
        XCTAssertFalse(config.enableAutoModelDownload)
        XCTAssertEqual(config.fallbackModels, ["model1", "model2"])
        XCTAssertEqual(config.requestThrottleDelay, 0.2)
        XCTAssertFalse(config.enableCloudModels)
        XCTAssertEqual(config.cloudEndpoint, "https://custom.com")
        XCTAssertTrue(config.preferCloudModels)
    }

    func testOllamaConfigStaticPresets() {
        let codeGeneration = OllamaConfig.codeGeneration
        XCTAssertEqual(codeGeneration.defaultModel, "codellama")
        XCTAssertEqual(codeGeneration.temperature, 0.2)
        XCTAssertEqual(codeGeneration.maxTokens, 4096)

        let analysis = OllamaConfig.analysis
        XCTAssertEqual(analysis.defaultModel, "llama2")
        XCTAssertEqual(analysis.temperature, 0.3)
        XCTAssertEqual(analysis.maxTokens, 2048)

        let creative = OllamaConfig.creative
        XCTAssertEqual(creative.defaultModel, "llama2")
        XCTAssertEqual(creative.temperature, 0.8)
        XCTAssertEqual(creative.maxTokens, 1024)
    }

    func testOllamaMessageInitialization() {
        let message = OllamaMessage(role: "user", content: "Hello, world!")

        XCTAssertEqual(message.role, "user")
        XCTAssertEqual(message.content, "Hello, world!")
    }

    func testOllamaServerStatus() {
        let status = OllamaServerStatus(running: true, modelCount: 5, models: ["llama2", "phi3"])

        XCTAssertTrue(status.running)
        XCTAssertEqual(status.modelCount, 5)
        XCTAssertEqual(status.models, ["llama2", "phi3"])
    }

    func testAutomationTaskInitialization() {
        let task = AutomationTask(
            id: "test-id",
            type: .codeGeneration,
            description: "Generate test code",
            language: "swift",
            code: "print('hello')"
        )

        XCTAssertEqual(task.id, "test-id")
        XCTAssertEqual(task.type, .codeGeneration)
        XCTAssertEqual(task.description, "Generate test code")
        XCTAssertEqual(task.language, "swift")
        XCTAssertEqual(task.code, "print('hello')")
    }

    func testTaskResultInitialization() {
        let task = AutomationTask(id: "test", type: .codeGeneration, description: "test")
        let result = TaskResult(task: task, success: true)

        XCTAssertEqual(result.task.id, "test")
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
        XCTAssertNil(result.codeGenerationResult)
        XCTAssertNil(result.analysisResult)
        XCTAssertNil(result.documentationResult)
        XCTAssertNil(result.testResult)
    }

    func testHealthStatsInitialization() {
        let stats = HealthStats(
            ollamaUptime: 99.5,
            huggingFaceUptime: 98.2,
            lastOllamaCheck: Date(),
            lastHuggingFaceCheck: Date()
        )

        XCTAssertEqual(stats.ollamaUptime, 99.5)
        XCTAssertEqual(stats.huggingFaceUptime, 98.2)
        XCTAssertNotNil(stats.lastOllamaCheck)
        XCTAssertNotNil(stats.lastHuggingFaceCheck)
    }

    func testCurrentHealthInitialization() {
        let health = CurrentHealth(
            ollamaHealthy: true,
            huggingFaceHealthy: false,
            anyServiceAvailable: true
        )

        XCTAssertTrue(health.ollamaHealthy)
        XCTAssertFalse(health.huggingFaceHealthy)
        XCTAssertTrue(health.anyServiceAvailable)
    }
}