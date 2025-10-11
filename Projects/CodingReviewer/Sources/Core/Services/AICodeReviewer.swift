//  AICodeReviewer.swift
//  CodingReviewer
//
//  Created by AI Enhancement System
//  Generated: October 10, 2025

import Foundation

/// AI-powered code reviewer that provides natural language processing capabilities
/// for code style analysis, code smell detection, and test case generation
struct AICodeReviewer {
    private let ollamaClient: OllamaClientProtocol

    init(ollamaClient: OllamaClientProtocol = OllamaClient.shared) {
        self.ollamaClient = ollamaClient
    }

    /// Analyzes code style and provides recommendations
    /// - Parameter code: The source code to analyze
    /// - Returns: Style review with suggestions and ratings
    func reviewCodeStyle(_ code: String) async throws -> StyleReview {
        let prompt = """
        Analyze the following code for style issues and provide recommendations:

        Code:
        \(code)

        Please provide:
        1. Overall style rating (1-10)
        2. Specific style violations found
        3. Recommended improvements
        4. Code examples for fixes

        Format your response as JSON with keys: rating, violations, recommendations, examples
        """

        let response = try await ollamaClient.generateResponse(for: prompt, model: "codellama")

        // Parse the JSON response
        guard let data = response.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        return try StyleReview(from: json)
    }

    /// Detects code smells and anti-patterns
    /// - Parameter code: The source code to analyze
    /// - Returns: Array of detected code smells with severity levels
    func detectCodeSmells(_ code: String) async throws -> [CodeSmell] {
        let prompt = """
        Analyze the following code for code smells and anti-patterns:

        Code:
        \(code)

        Common code smells to look for:
        - Long methods/functions
        - Large classes
        - Duplicate code
        - Long parameter lists
        - Complex conditionals
        - Missing error handling
        - Poor naming conventions
        - Tight coupling
        - Feature envy
        - Data clumps

        For each smell found, provide:
        - Type of smell
        - Severity (low, medium, high)
        - Location (line numbers if possible)
        - Description of the problem
        - Suggested refactoring

        Format as JSON array of objects with keys: type, severity, location, description, refactoring
        """

        let response = try await ollamaClient.generateResponse(for: prompt, model: "codellama")

        guard let data = response.data(using: .utf8),
              let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        return try jsonArray.map { try CodeSmell(from: $0) }
    }

    /// Generates test cases for the given function
    /// - Parameter function: The function signature and body to generate tests for
    /// - Returns: Array of generated test cases
    func generateTestCases(for function: String) async throws -> [TestCase] {
        let prompt = """
        Generate comprehensive unit test cases for the following function:

        Function:
        \(function)

        Please generate test cases covering:
        1. Happy path scenarios
        2. Edge cases
        3. Error conditions
        4. Boundary values
        5. Invalid inputs

        For each test case, provide:
        - Test name (descriptive)
        - Input parameters
        - Expected output or behavior
        - Test setup if needed

        Format as JSON array of objects with keys: name, inputs, expectedOutput, setup
        """

        let response = try await ollamaClient.generateResponse(for: prompt, model: "codellama")

        guard let data = response.data(using: .utf8),
              let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        return try jsonArray.map { try TestCase(from: $0) }
    }

    /// Analyzes code performance and suggests optimizations
    /// - Parameter code: The source code to analyze
    /// - Returns: Performance analysis with optimization suggestions
    func analyzePerformance(_ code: String) async throws -> PerformanceAnalysis {
        let prompt = """
        Analyze the following code for performance issues and optimization opportunities:

        Code:
        \(code)

        Look for:
        1. Inefficient algorithms (O(n²) or worse)
        2. Unnecessary object creation
        3. Memory leaks or retain cycles
        4. Blocking operations on main thread
        5. Large data structures that could be optimized
        6. Missing caching opportunities
        7. Inefficient string operations
        8. Unnecessary computations in loops

        Provide specific optimization suggestions with expected performance improvements.

        Format as JSON with keys: issues, optimizations, expectedImprovements
        """

        let response = try await ollamaClient.generateResponse(for: prompt, model: "codellama")

        guard let data = response.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        return try PerformanceAnalysis(from: json)
    }

    /// Generates smart refactoring suggestions for code improvements
    /// - Parameter code: The source code to analyze for refactoring opportunities
    /// - Returns: Array of refactoring suggestions with code examples
    func generateRefactoringSuggestions(_ code: String) async throws -> [RefactoringSuggestion] {
        let prompt = """
        Analyze the following code and suggest specific refactoring improvements:

        Code:
        \(code)

        Provide refactoring suggestions for:
        1. Extract Method - Long methods that should be broken down
        2. Rename Variable/Method - Poor naming that should be improved
        3. Introduce Parameter Object - Methods with too many parameters
        4. Replace Conditional with Polymorphism - Complex conditionals
        5. Extract Class - Classes with too many responsibilities
        6. Move Method/Field - Better encapsulation opportunities
        7. Replace Magic Number with Constant - Hard-coded values
        8. Simplify Conditional - Complex boolean expressions

        For each suggestion, provide:
        - Type of refactoring
        - Description of the problem
        - Specific code location (if possible)
        - Before and after code examples
        - Benefits of the refactoring

        Format as JSON array of objects with keys: type, problem, location, beforeCode, afterCode, benefits
        """

        let response = try await ollamaClient.generateResponse(for: prompt, model: "codellama")

        guard let data = response.data(using: .utf8),
              let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw AICodeReviewerError.invalidResponse
        }

        return try jsonArray.map { try RefactoringSuggestion(from: $0) }
    }

    /// Generates comprehensive documentation for code
    /// - Parameter code: The source code to document
    /// - Returns: Generated documentation with docstrings and comments
    func generateDocumentation(_ code: String) async throws -> DocumentationResult {
        let prompt = """
        Generate comprehensive documentation for the following code:

        Code:
        \(code)

        Please provide:
        1. Class/struct documentation - Purpose, responsibilities, usage
        2. Method/function documentation - Parameters, return values, behavior, side effects
        3. Property documentation - Purpose and usage
        4. Inline comments - Complex logic explanations
        5. Usage examples - How to use the code
        6. Important notes - Edge cases, limitations, dependencies

        Format the documentation using standard Swift documentation syntax (/// for top-level, /// for parameters, etc.)

        Return as JSON with keys: overview, documentedCode, examples, notes
        """

        let response = try await ollamaClient.generateResponse(for: prompt, model: "codellama")

        guard let data = response.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AICodeReviewerError.invalidResponse
        }

        return try DocumentationResult(from: json)
    }

    /// Analyzes code patterns and suggests architectural improvements
    /// - Parameter code: The source code to analyze
    /// - Returns: Architectural suggestions and design pattern recommendations
    func suggestArchitecturalImprovements(_ code: String) async throws -> [ArchitecturalSuggestion] {
        let prompt = """
        Analyze the following code for architectural improvements and design pattern opportunities:

        Code:
        \(code)

        Look for opportunities to apply:
        1. Design Patterns (Factory, Builder, Strategy, Observer, etc.)
        2. SOLID principles violations and fixes
        3. Dependency injection opportunities
        4. Protocol-oriented programming improvements
        5. Better separation of concerns
        6. Improved testability
        7. Performance optimizations
        8. Memory management improvements

        For each suggestion, provide:
        - Pattern or principle to apply
        - Current problem in the code
        - Proposed solution with code examples
        - Benefits and trade-offs

        Format as JSON array with keys: pattern, problem, solution, benefits, tradeoffs
        """

        let response = try await ollamaClient.generateResponse(for: prompt, model: "codellama")

        guard let data = response.data(using: .utf8),
              let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw AICodeReviewerError.invalidResponse
        }

        return try jsonArray.map { try ArchitecturalSuggestion(from: $0) }
    }
}

// MARK: - Supporting Types

struct StyleReview {
    let rating: Int
    let violations: [String]
    let recommendations: [String]
    let examples: [String: String]

    init(from json: [String: Any]) throws {
        guard let rating = json["rating"] as? Int,
              let violations = json["violations"] as? [String],
              let recommendations = json["recommendations"] as? [String],
              let examples = json["examples"] as? [String: String]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        self.rating = rating
        self.violations = violations
        self.recommendations = recommendations
        self.examples = examples
    }
}

struct CodeSmell {
    let type: String
    let severity: String
    let location: String?
    let description: String
    let refactoring: String

    init(from json: [String: Any]) throws {
        guard let type = json["type"] as? String,
              let severity = json["severity"] as? String,
              let description = json["description"] as? String,
              let refactoring = json["refactoring"] as? String
        else {
            throw AICodeReviewerError.invalidResponse
        }

        self.type = type
        self.severity = severity
        location = json["location"] as? String
        self.description = description
        self.refactoring = refactoring
    }
}

struct TestCase {
    let name: String
    let inputs: [String: Any]
    let expectedOutput: String
    let setup: String?

    init(from json: [String: Any]) throws {
        guard let name = json["name"] as? String,
              let inputs = json["inputs"] as? [String: Any],
              let expectedOutput = json["expectedOutput"] as? String
        else {
            throw AICodeReviewerError.invalidResponse
        }

        self.name = name
        self.inputs = inputs
        self.expectedOutput = expectedOutput
        setup = json["setup"] as? String
    }
}

struct PerformanceAnalysis {
    let issues: [PerformanceIssue]
    let optimizations: [Optimization]
    let expectedImprovements: [String]

    init(from json: [String: Any]) throws {
        guard let issuesJson = json["issues"] as? [[String: Any]],
              let optimizationsJson = json["optimizations"] as? [[String: Any]],
              let expectedImprovements = json["expectedImprovements"] as? [String]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        issues = try issuesJson.map { try PerformanceIssue(from: $0) }
        optimizations = try optimizationsJson.map { try Optimization(from: $0) }
        self.expectedImprovements = expectedImprovements
    }
}

struct PerformanceIssue {
    let type: String
    let description: String
    let impact: String

    init(from json: [String: Any]) throws {
        guard let type = json["type"] as? String,
              let description = json["description"] as? String,
              let impact = json["impact"] as? String
        else {
            throw AICodeReviewerError.invalidResponse
        }

        self.type = type
        self.description = description
        self.impact = impact
    }
}

struct Optimization {
    let suggestion: String
    let codeExample: String?
    let benefit: String

    init(from json: [String: Any]) throws {
        guard let suggestion = json["suggestion"] as? String,
              let benefit = json["benefit"] as? String
        else {
            throw AICodeReviewerError.invalidResponse
        }

        self.suggestion = suggestion
        codeExample = json["codeExample"] as? String
        self.benefit = benefit
    }
}

struct RefactoringSuggestion {
    let type: String
    let problem: String
    let location: String?
    let beforeCode: String
    let afterCode: String
    let benefits: [String]

    init(from json: [String: Any]) throws {
        guard let type = json["type"] as? String,
              let problem = json["problem"] as? String,
              let beforeCode = json["beforeCode"] as? String,
              let afterCode = json["afterCode"] as? String,
              let benefits = json["benefits"] as? [String]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        self.type = type
        self.problem = problem
        self.location = json["location"] as? String
        self.beforeCode = beforeCode
        self.afterCode = afterCode
        self.benefits = benefits
    }
}

struct DocumentationResult {
    let overview: String
    let documentedCode: String
    let examples: [String]
    let notes: [String]

    init(from json: [String: Any]) throws {
        guard let overview = json["overview"] as? String,
              let documentedCode = json["documentedCode"] as? String,
              let examples = json["examples"] as? [String],
              let notes = json["notes"] as? [String]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        self.overview = overview
        self.documentedCode = documentedCode
        self.examples = examples
        self.notes = notes
    }
}

struct ArchitecturalSuggestion {
    let pattern: String
    let problem: String
    let solution: String
    let benefits: [String]
    let tradeoffs: [String]

    init(from json: [String: Any]) throws {
        guard let pattern = json["pattern"] as? String,
              let problem = json["problem"] as? String,
              let solution = json["solution"] as? String,
              let benefits = json["benefits"] as? [String],
              let tradeoffs = json["tradeoffs"] as? [String]
        else {
            throw AICodeReviewerError.invalidResponse
        }

        self.pattern = pattern
        self.problem = problem
        self.solution = solution
        self.benefits = benefits
        self.tradeoffs = tradeoffs
    }
}

// MARK: - Errors

enum AICodeReviewerError: Error {
    case invalidResponse
    case networkError
    case modelUnavailable
}
