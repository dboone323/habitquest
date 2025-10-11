import Foundation

// MARK: - Ollama Configuration

/// Configuration for Ollama integration
public struct OllamaConfig: Sendable {
    public let baseURL: String
    public let defaultModel: String
    public let temperature: Double
    public let maxTokens: Int
    public let timeout: TimeInterval
    public let maxRetries: Int
    public let requestThrottleDelay: TimeInterval
    public let enableCaching: Bool
    public let cacheExpiryTime: TimeInterval
    public let enableMetrics: Bool
    public let enableCloudModels: Bool
    public let preferCloudModels: Bool
    public let fallbackModels: [String]

    public static let `default` = OllamaConfig(
        baseURL: "http://localhost:11434",
        defaultModel: "llama2",
        temperature: 0.7,
        maxTokens: 500,
        timeout: 30.0,
        maxRetries: 3,
        requestThrottleDelay: 0.1,
        enableCaching: true,
        cacheExpiryTime: 1800, // 30 minutes
        enableMetrics: true,
        enableCloudModels: false,
        preferCloudModels: false,
        fallbackModels: ["codellama", "mistral"]
    )

    public init(
        baseURL: String = "http://localhost:11434",
        defaultModel: String = "llama2",
        temperature: Double = 0.7,
        maxTokens: Int = 500,
        timeout: TimeInterval = 30.0,
        maxRetries: Int = 3,
        requestThrottleDelay: TimeInterval = 0.1,
        enableCaching: Bool = true,
        cacheExpiryTime: TimeInterval = 1800,
        enableMetrics: Bool = true,
        enableCloudModels: Bool = false,
        preferCloudModels: Bool = false,
        fallbackModels: [String] = ["codellama", "mistral"]
    ) {
        self.baseURL = baseURL
        self.defaultModel = defaultModel
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.timeout = timeout
        self.maxRetries = maxRetries
        self.requestThrottleDelay = requestThrottleDelay
        self.enableCaching = enableCaching
        self.cacheExpiryTime = cacheExpiryTime
        self.enableMetrics = enableMetrics
        self.enableCloudModels = enableCloudModels
        self.preferCloudModels = preferCloudModels
        self.fallbackModels = fallbackModels
    }
}

// MARK: - Ollama Message Types

/// Message for chat interactions
public struct OllamaMessage: Codable, Sendable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

/// Response from generate endpoint
public struct OllamaGenerateResponse: Codable, Sendable {
    public let model: String
    public let createdAt: String
    public let response: String
    public let done: Bool
    public let context: [Int]?
    public let totalDuration: Int64?
    public let loadDuration: Int64?
    public let promptEvalCount: Int?
    public let promptEvalDuration: Int64?
    public let evalCount: Int?
    public let evalDuration: Int64?

    public init(
        model: String,
        createdAt: String,
        response: String,
        done: Bool,
        context: [Int]? = nil,
        totalDuration: Int64? = nil,
        loadDuration: Int64? = nil,
        promptEvalCount: Int? = nil,
        promptEvalDuration: Int64? = nil,
        evalCount: Int? = nil,
        evalDuration: Int64? = nil
    ) {
        self.model = model
        self.createdAt = createdAt
        self.response = response
        self.done = done
        self.context = context
        self.totalDuration = totalDuration
        self.loadDuration = loadDuration
        self.promptEvalCount = promptEvalCount
        self.promptEvalDuration = promptEvalDuration
        self.evalCount = evalCount
        self.evalDuration = evalDuration
    }
}

/// Server status information
public struct OllamaServerStatus: Codable, Sendable {
    public let running: Bool
    public let modelCount: Int
    public let models: [String]

    public init(running: Bool, modelCount: Int = 0, models: [String] = []) {
        self.running = running
        self.modelCount = modelCount
        self.models = models
    }
}

// MARK: - Ollama-Specific Result Types

/// Documentation generation result
public struct DocumentationResult: Codable, Sendable {
    public let documentation: String
    public let language: String
    public let includesExamples: Bool
    public let timestamp: Date

    public init(
        documentation: String,
        language: String,
        includesExamples: Bool = false,
        timestamp: Date = Date()
    ) {
        self.documentation = documentation
        self.language = language
        self.includesExamples = includesExamples
        self.timestamp = timestamp
    }
}

/// Test generation result
public struct TestGenerationResult: Codable, Sendable {
    public let testCode: String
    public let language: String
    public let testFramework: String
    public let coverage: Double
    public let timestamp: Date

    public init(
        testCode: String,
        language: String,
        testFramework: String = "XCTest",
        coverage: Double = 0.0,
        timestamp: Date = Date()
    ) {
        self.testCode = testCode
        self.language = language
        self.testFramework = testFramework
        self.coverage = coverage
        self.timestamp = timestamp
    }
}

/// Automation task definition
public struct AutomationTask: Codable, Sendable {
    public let id: String
    public let type: TaskType
    public let description: String
    public let language: String?
    public let code: String?
    public let priority: TaskPriority
    public let metadata: [String: String]

    public init(
        id: String = UUID().uuidString,
        type: TaskType,
        description: String,
        language: String? = nil,
        code: String? = nil,
        priority: TaskPriority = .normal,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.description = description
        self.language = language
        self.code = code
        self.priority = priority
        self.metadata = metadata
    }
}

/// Task types for automation
public enum TaskType: String, Codable, Sendable {
    case codeGeneration
    case codeAnalysis
    case documentation
    case testing
}

/// Task priority levels
public enum TaskPriority: String, Codable, Sendable {
    case low
    case normal
    case high
    case critical
}

/// Task execution result
public struct TaskResult: Sendable {
    public let task: AutomationTask
    public let success: Bool
    public let error: Error?
    public let codeGenerationResult: CodeGenerationResult?
    public let analysisResult: CodeAnalysisResult?
    public let documentationResult: DocumentationResult?
    public let testResult: TestGenerationResult?
    public let executionTime: TimeInterval
    public let timestamp: Date

    public init(
        task: AutomationTask,
        success: Bool,
        error: Error? = nil,
        codeGenerationResult: CodeGenerationResult? = nil,
        analysisResult: CodeAnalysisResult? = nil,
        documentationResult: DocumentationResult? = nil,
        testResult: TestGenerationResult? = nil,
        executionTime: TimeInterval = 0.0,
        timestamp: Date = Date()
    ) {
        self.task = task
        self.success = success
        self.error = error
        self.codeGenerationResult = codeGenerationResult
        self.analysisResult = analysisResult
        self.documentationResult = documentationResult
        self.testResult = testResult
        self.executionTime = executionTime
        self.timestamp = timestamp
    }
}

// MARK: - Error Types

/// Errors specific to Ollama integration
public enum OllamaError: Error, LocalizedError {
    case invalidConfiguration(String)
    case serverNotRunning
    case modelNotAvailable(String)
    case invalidResponse
    case invalidResponseFormat
    case httpError(Int)
    case timeout
    case networkError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let details):
            "Invalid Ollama configuration: \(details)"
        case .serverNotRunning:
            "Ollama server is not running"
        case .modelNotAvailable(let model):
            "Model '\(model)' is not available"
        case .invalidResponse:
            "Invalid response from Ollama server"
        case .invalidResponseFormat:
            "Invalid response format from Ollama server"
        case .httpError(let code):
            "HTTP error: \(code)"
        case .timeout:
            "Request timed out"
        case .networkError(let details):
            "Network error: \(details)"
        }
    }
}

/// Integration-specific errors
public enum IntegrationError: Error, LocalizedError {
    case missingRequiredData(String)
    case invalidTaskType(String)
    case serviceNotAvailable(String)
    case operationTimeout(String)
    case configurationError(String)

    public var errorDescription: String? {
        switch self {
        case .missingRequiredData(let data):
            "Missing required data: \(data)"
        case .invalidTaskType(let type):
            "Invalid task type: \(type)"
        case .serviceNotAvailable(let service):
            "Service not available: \(service)"
        case .operationTimeout(let operation):
            "Operation timed out: \(operation)"
        case .configurationError(let details):
            "Configuration error: \(details)"
        }
    }
}


