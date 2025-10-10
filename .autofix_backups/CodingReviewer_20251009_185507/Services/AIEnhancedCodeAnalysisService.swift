import Foundation
import OSLog
import SwiftUI

/// AI-Enhanced Code Analysis Service
/// Integrates Ollama models for intelligent code review and analysis
/// Part of the CodingReviewer AI Enhancement Suite

@MainActor
public class AIEnhancedCodeAnalysisService: ObservableObject {
    private let logger = Logger(subsystem: "CodingReviewer", category: "AIAnalysis")
    private let fileManager = FileManager.default

    @Published public var isAnalyzing = false
    @Published public var currentAnalysisTask = ""
    @Published public var analysisResults: [AIAnalysisResult] = []
    @Published public var aiSuggestions: [AISuggestion] = []

    public init() {
        self.logger.info("AI-Enhanced Code Analysis Service initialized")
    }

    // MARK: - AI-Powered Code Analysis

    public func analyzeCodeWithAI(_ code: String, language: String = "swift", context: String? = nil) async throws -> AICodeAnalysisResult {
        self.isAnalyzing = true
        self.currentAnalysisTask = "Analyzing code with AI models..."

        defer {
            Task { @MainActor in
                isAnalyzing = false
                currentAnalysisTask = ""
            }
        }

        // Use cloud models for comprehensive analysis
        let analysisPrompt = """
        Perform comprehensive code analysis for this \(language) code:

        Code:
        \(code)

        \(context != nil ? "Context: \(context!)" : "")

        Provide detailed analysis including:
        1. Code quality assessment (1-10 rating)
        2. Security vulnerabilities
        3. Performance issues
        4. Best practice violations
        5. Maintainability concerns
        6. Specific improvement recommendations
        7. Estimated technical debt

        Format response as structured analysis with priorities and actionable items.
        """

        let analysisResponse = try await callOllamaModel(
            model: "deepseek-v3.1:671b-cloud",
            prompt: analysisPrompt,
            temperature: 0.3
        )

        // Generate code suggestions
        let suggestionsResponse = try await generateCodeSuggestions(code, language: language, analysis: analysisResponse)

        // Parse results
        let result = AICodeAnalysisResult(
            originalCode: code,
            language: language,
            qualityScore: extractQualityScore(from: analysisResponse),
            securityIssues: extractSecurityIssues(from: analysisResponse),
            performanceIssues: extractPerformanceIssues(from: analysisResponse),
            bestPracticeViolations: extractBestPracticeViolations(from: analysisResponse),
            recommendations: extractRecommendations(from: analysisResponse),
            suggestedImprovements: suggestionsResponse,
            technicalDebtEstimate: extractTechnicalDebt(from: analysisResponse),
            analysisTimestamp: Date()
        )

        await MainActor.run {
            self.analysisResults.append(AIAnalysisResult(
                id: UUID(),
                type: .codeAnalysis,
                result: result,
                timestamp: Date()
            ))
        }

        self.logger.info("AI code analysis completed with \(result.recommendations.count) recommendations")
        return result
    }

    // MARK: - AI-Powered Code Generation

    public func generateCodeWithAI(
        prompt: String,
        language: String = "swift",
        style: CodeStyle = .production
    ) async throws -> AICodeGenerationResult {
        self.currentAnalysisTask = "Generating code with AI..."

        let codeGenPrompt = """
        Generate high-quality \(language) code for the following requirement:

        Requirement: \(prompt)

        Code style: \(style.description)
        Context: CodingReviewer macOS application

        Requirements:
        1. Follow \(language) best practices and conventions
        2. Include proper error handling
        3. Add comprehensive documentation
        4. Consider thread safety where applicable
        5. Use appropriate design patterns
        6. Include basic unit test suggestions

        Generate only the code with minimal explanation.
        """

        let generatedCode = try await callOllamaModel(
            model: "qwen3-coder:480b-cloud",
            prompt: codeGenPrompt,
            temperature: 0.2
        )

        // Analyze the generated code for quality
        let qualityAnalysis = try await analyzeCodeWithAI(generatedCode, language: language, context: "Generated code for: \(prompt)")

        let result = AICodeGenerationResult(
            originalPrompt: prompt,
            generatedCode: generatedCode,
            language: language,
            style: style,
            qualityAnalysis: qualityAnalysis,
            generationTimestamp: Date()
        )

        await MainActor.run {
            self.analysisResults.append(AIAnalysisResult(
                id: UUID(),
                type: .codeGeneration,
                result: result,
                timestamp: Date()
            ))
        }

        self.logger.info("AI code generation completed for prompt: \(prompt.prefix(50))...")
        return result
    }

    // MARK: - AI-Powered Code Refactoring

    public func refactorCodeWithAI(
        _ code: String,
        refactoringGoal: RefactoringGoal,
        language: String = "swift"
    ) async throws -> AIRefactoringResult {
        self.currentAnalysisTask = "Refactoring code with AI..."

        let refactoringPrompt = """
        Refactor this \(language) code to achieve: \(refactoringGoal.description)

        Original code:
        \(code)

        Refactoring objectives:
        \(refactoringGoal.objectives.joined(separator: "\n- "))

        Requirements:
        1. Maintain existing functionality
        2. Improve code structure and readability
        3. Follow SOLID principles
        4. Add appropriate comments for changes
        5. Preserve public API compatibility where possible

        Provide:
        1. Refactored code
        2. Explanation of changes made
        3. Benefits of the refactoring
        4. Any potential breaking changes
        """

        let refactoredCode = try await callOllamaModel(
            model: "qwen3-coder:480b-cloud",
            prompt: refactoringPrompt,
            temperature: 0.3
        )

        // Compare original vs refactored
        let comparison = try await compareCodeVersions(original: code, refactored: refactoredCode)

        let result = AIRefactoringResult(
            originalCode: code,
            refactoredCode: refactoredCode,
            refactoringGoal: refactoringGoal,
            changesExplanation: extractChangesExplanation(from: refactoredCode),
            benefits: extractBenefits(from: refactoredCode),
            potentialIssues: extractPotentialIssues(from: refactoredCode),
            codeComparison: comparison,
            refactoringTimestamp: Date()
        )

        await MainActor.run {
            self.analysisResults.append(AIAnalysisResult(
                id: UUID(),
                type: .refactoring,
                result: result,
                timestamp: Date()
            ))
        }

        self.logger.info("AI code refactoring completed for goal: \(refactoringGoal.description)")
        return result
    }

    // MARK: - AI-Powered Documentation Generation

    public func generateDocumentationWithAI(
        _ code: String,
        documentationType: DocumentationType = .comprehensive
    ) async throws -> AIDocumentationResult {
        self.currentAnalysisTask = "Generating documentation with AI..."

        let docPrompt = """
        Generate \(documentationType.description) documentation for this Swift code:

        Code:
        \(code)

        Include:
        1. Overview and purpose
        2. Parameter descriptions
        3. Return value documentation
        4. Usage examples
        5. Error handling information
        6. Performance considerations
        7. Thread safety notes

        Use Swift documentation comments (///) format.
        Make it comprehensive but concise.
        """

        let documentation = try await callOllamaModel(
            model: "gpt-oss:120b-cloud",
            prompt: docPrompt,
            temperature: 0.4
        )

        let result = AIDocumentationResult(
            originalCode: code,
            generatedDocumentation: documentation,
            documentationType: documentationType,
            generationTimestamp: Date()
        )

        await MainActor.run {
            self.analysisResults.append(AIAnalysisResult(
                id: UUID(),
                type: .documentation,
                result: result,
                timestamp: Date()
            ))
        }

        self.logger.info("AI documentation generation completed")
        return result
    }

    // MARK: - AI-Powered Test Generation

    public func generateTestsWithAI(_ code: String, testType: TestType = .unit) async throws -> AITestGenerationResult {
        self.currentAnalysisTask = "Generating tests with AI..."

        let testPrompt = """
        Generate \(testType.description) tests for this Swift code:

        Code to test:
        \(code)

        Generate comprehensive XCTest-based tests including:
        1. Happy path scenarios
        2. Edge cases
        3. Error conditions
        4. Performance tests (if applicable)
        5. Mock objects where needed
        6. Proper setup and teardown

        Use XCTest framework and follow Swift testing best practices.
        Include descriptive test names and clear assertions.
        """

        let generatedTests = try await callOllamaModel(
            model: "qwen3-coder:480b-cloud",
            prompt: testPrompt,
            temperature: 0.2
        )

        let result = AITestGenerationResult(
            originalCode: code,
            generatedTests: generatedTests,
            testType: testType,
            estimatedCoverage: estimateTestCoverage(generatedTests),
            generationTimestamp: Date()
        )

        await MainActor.run {
            self.analysisResults.append(AIAnalysisResult(
                id: UUID(),
                type: .testGeneration,
                result: result,
                timestamp: Date()
            ))
        }

        self.logger.info("AI test generation completed with estimated coverage: \(result.estimatedCoverage)%")
        return result
    }

    // MARK: - AI-Powered Code Review

    public func performAICodeReview(_ files: [String], reviewType: ReviewType = .comprehensive) async throws -> AICodeReviewResult {
        self.currentAnalysisTask = "Performing AI code review..."

        var fileAnalyses: [FileReviewAnalysis] = []

        for filePath in files.prefix(10) { // Limit to avoid overwhelming the AI
            if self.fileManager.fileExists(atPath: filePath) {
                do {
                    let content = try String(contentsOfFile: filePath, encoding: .utf8)
                    let fileName = URL(fileURLWithPath: filePath).lastPathComponent

                    let reviewPrompt = """
                    Perform a \(reviewType.description) code review for this Swift file:

                    File: \(fileName)
                    Code:
                    \(String(content.prefix(2000))) // First 2000 chars

                    Review criteria:
                    1. Code quality and style
                    2. Architecture and design patterns
                    3. Performance considerations
                    4. Security implications
                    5. Error handling
                    6. Testing needs
                    7. Documentation quality

                    Provide specific, actionable feedback with line-level suggestions where possible.
                    Rate the overall file quality (1-10) and highlight top 3 improvements.
                    """

                    let reviewResponse = try await callOllamaModel(
                        model: "deepseek-v3.1:671b-cloud",
                        prompt: reviewPrompt,
                        temperature: 0.3
                    )

                    fileAnalyses.append(FileReviewAnalysis(
                        fileName: fileName,
                        filePath: filePath,
                        reviewComments: reviewResponse,
                        qualityRating: self.extractQualityRating(from: reviewResponse),
                        topImprovements: self.extractTopImprovements(from: reviewResponse),
                        reviewTimestamp: Date()
                    ))

                } catch {
                    self.logger.error("Failed to review file \(filePath): \(error.localizedDescription)")
                }
            }
        }

        // Generate overall summary
        let summaryPrompt = """
        Generate an overall code review summary based on these file analyses:

        Files reviewed: \(fileAnalyses.count)
        Average quality: \(fileAnalyses.map(\.qualityRating).reduce(0, +) / fileAnalyses.count)

        Individual file summaries:
        \(fileAnalyses.map { "\($0.fileName): Rating \($0.qualityRating)/10" }.joined(separator: "\n"))

        Provide:
        1. Overall code health assessment
        2. Common patterns and issues
        3. Architectural recommendations
        4. Priority action items
        5. Team development suggestions
        """

        let overallSummary = try await callOllamaModel(
            model: "gpt-oss:120b-cloud",
            prompt: summaryPrompt,
            temperature: 0.4
        )

        let result = AICodeReviewResult(
            reviewedFiles: files,
            fileAnalyses: fileAnalyses,
            overallSummary: overallSummary,
            reviewType: reviewType,
            overallQualityScore: fileAnalyses.map(\.qualityRating).reduce(0, +) / fileAnalyses.count,
            reviewTimestamp: Date()
        )

        await MainActor.run {
            self.analysisResults.append(AIAnalysisResult(
                id: UUID(),
                type: .codeReview,
                result: result,
                timestamp: Date()
            ))
        }

        self.logger.info("AI code review completed for \(files.count) files")
        return result
    }

    // MARK: - Private Helpers

    private func callOllamaModel(model: String, prompt: String, temperature _: Double = 0.5) async throws -> String {
        // This would use the actual OllamaClient - for now, simulating the call
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ollama")
        process.arguments = ["run", model]

        let inputPipe = Pipe()
        let outputPipe = Pipe()

        process.standardInput = inputPipe
        process.standardOutput = outputPipe

        try process.run()

        // Send prompt
        let inputData = prompt.data(using: .utf8)!
        inputPipe.fileHandleForWriting.write(inputData)
        inputPipe.fileHandleForWriting.closeFile()

        // Read response
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let response = String(data: outputData, encoding: .utf8) ?? "No response"

        process.waitUntilExit()

        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func generateCodeSuggestions(_: String, language _: String, analysis: String) async throws -> [CodeImprovement] {
        let suggestionsPrompt = """
        Based on this code analysis, generate specific code improvement suggestions:

        Analysis: \(String(analysis.prefix(1000)))

        For each suggestion, provide:
        1. Specific issue or improvement area
        2. Current code example
        3. Improved code example
        4. Explanation of benefits

        Limit to top 5 most impactful suggestions.
        """

        let suggestions = try await callOllamaModel(
            model: "qwen3-coder:480b-cloud",
            prompt: suggestionsPrompt,
            temperature: 0.3
        )

        // Parse suggestions (simplified)
        let lines = suggestions.components(separatedBy: .newlines)
        return lines.enumerated().compactMap { index, line in
            if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return CodeImprovement(
                    title: "Improvement \(index + 1)",
                    description: line,
                    currentCode: "",
                    improvedCode: "",
                    benefits: [],
                    priority: .medium
                )
            }
            return nil
        }
    }

    private func compareCodeVersions(original: String, refactored: String) async throws -> CodeComparison {
        let comparisonPrompt = """
        Compare these two versions of Swift code:

        Original:
        \(String(original.prefix(1000)))

        Refactored:
        \(String(refactored.prefix(1000)))

        Analyze:
        1. Lines of code change
        2. Complexity reduction
        3. Performance impact
        4. Maintainability improvement
        5. Readability enhancement
        """

        let comparison = try await callOllamaModel(
            model: "deepseek-v3.1:671b-cloud",
            prompt: comparisonPrompt,
            temperature: 0.2
        )

        return CodeComparison(
            originalLinesOfCode: original.components(separatedBy: .newlines).count,
            refactoredLinesOfCode: refactored.components(separatedBy: .newlines).count,
            complexityReduction: 0.0, // Would be calculated
            performanceImpact: comparison.contains("performance") ? .positive : .neutral,
            maintainabilityScore: 0.0, // Would be calculated
            readabilityImprovement: comparison.contains("readable") || comparison.contains("clear")
        )
    }

    private func estimateTestCoverage(_ tests: String) -> Int {
        // Simple heuristic based on test method count
        let testMethods = tests.components(separatedBy: "func test").count - 1
        return min(testMethods * 15, 95) // Rough estimate
    }

    // MARK: - Parsing Helpers

    private func extractQualityScore(from analysis: String) -> Int {
        // Extract quality score from analysis text
        let numbers = analysis.matches(of: /(\d+)\/10|\b(\d)\s*out\s*of\s*10/).compactMap { match in
            Int(match.output.1 ?? match.output.2 ?? "0")
        }
        return numbers.first ?? 7
    }

    private func extractSecurityIssues(from analysis: String) -> [SecurityIssue] {
        // Parse security issues from analysis
        let securityKeywords = ["security", "vulnerability", "exploit", "injection", "authentication"]
        let lines = analysis.components(separatedBy: .newlines)

        return lines.compactMap { line in
            for keyword in securityKeywords {
                if line.lowercased().contains(keyword) {
                    return SecurityIssue(
                        type: keyword.capitalized,
                        severity: line.lowercased().contains("critical") || line.lowercased().contains("high") ? .high : .medium,
                        description: line,
                        recommendation: "Address security concern"
                    )
                }
            }
            return nil
        }
    }

    private func extractPerformanceIssues(from analysis: String) -> [PerformanceIssue] {
        let performanceKeywords = ["performance", "slow", "inefficient", "optimization", "bottleneck"]
        let lines = analysis.components(separatedBy: .newlines)

        return lines.compactMap { line in
            for keyword in performanceKeywords {
                if line.lowercased().contains(keyword) {
                    return PerformanceIssue(
                        type: "Performance Concern",
                        impact: line.lowercased().contains("critical") ? .high : .medium,
                        description: line,
                        suggestion: "Optimize for better performance"
                    )
                }
            }
            return nil
        }
    }

    private func extractBestPracticeViolations(from analysis: String) -> [BestPracticeViolation] {
        let practiceKeywords = ["best practice", "convention", "style", "pattern", "anti-pattern"]
        let lines = analysis.components(separatedBy: .newlines)

        return lines.compactMap { line in
            for keyword in practiceKeywords {
                if line.lowercased().contains(keyword) {
                    return BestPracticeViolation(
                        rule: "Code Convention",
                        violation: line,
                        suggestion: "Follow Swift best practices"
                    )
                }
            }
            return nil
        }
    }

    private func extractRecommendations(from analysis: String) -> [String] {
        let lines = analysis.components(separatedBy: .newlines)
        return lines.compactMap { line in
            if line.contains("recommend") || line.contains("suggest") || line.contains("should") {
                return line.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return nil
        }
    }

    private func extractTechnicalDebt(from analysis: String) -> TechnicalDebtLevel {
        if analysis.lowercased().contains("high debt") || analysis.lowercased().contains("significant debt") {
            .high
        } else if analysis.lowercased().contains("medium debt") || analysis.lowercased().contains("moderate debt") {
            .medium
        } else {
            .low
        }
    }

    private func extractChangesExplanation(from response: String) -> String {
        // Extract explanation section from refactoring response
        let lines = response.components(separatedBy: .newlines)
        return lines.first { $0.contains("explanation") || $0.contains("changes") } ?? "Refactoring completed"
    }

    private func extractBenefits(from response: String) -> [String] {
        let lines = response.components(separatedBy: .newlines)
        return lines.compactMap { line in
            if line.contains("benefit") || line.contains("improvement") {
                return line.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return nil
        }
    }

    private func extractPotentialIssues(from response: String) -> [String] {
        let lines = response.components(separatedBy: .newlines)
        return lines.compactMap { line in
            if line.contains("issue") || line.contains("concern") || line.contains("breaking") {
                return line.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return nil
        }
    }

    private func extractQualityRating(from response: String) -> Int {
        let numbers = response.matches(of: /(\d+)\/10/).compactMap { match in
            Int(match.output.1 ?? "0")
        }
        return numbers.first ?? 7
    }

    private func extractTopImprovements(from response: String) -> [String] {
        let lines = response.components(separatedBy: .newlines)
        return lines.prefix(3).compactMap { line in
            if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return line
            }
            return nil
        }
    }
}

// MARK: - Supporting Data Types

public struct AIAnalysisResult {
    let id: UUID
    let type: AIAnalysisType
    let result: Any
    let timestamp: Date
}

public enum AIAnalysisType {
    case codeAnalysis
    case codeGeneration
    case refactoring
    case documentation
    case testGeneration
    case codeReview
}

public struct AICodeAnalysisResult {
    let originalCode: String
    let language: String
    let qualityScore: Int
    let securityIssues: [SecurityIssue]
    let performanceIssues: [PerformanceIssue]
    let bestPracticeViolations: [BestPracticeViolation]
    let recommendations: [String]
    let suggestedImprovements: [CodeImprovement]
    let technicalDebtEstimate: TechnicalDebtLevel
    let analysisTimestamp: Date
}

public struct AICodeGenerationResult {
    let originalPrompt: String
    let generatedCode: String
    let language: String
    let style: CodeStyle
    let qualityAnalysis: AICodeAnalysisResult
    let generationTimestamp: Date
}

public struct AIRefactoringResult {
    let originalCode: String
    let refactoredCode: String
    let refactoringGoal: RefactoringGoal
    let changesExplanation: String
    let benefits: [String]
    let potentialIssues: [String]
    let codeComparison: CodeComparison
    let refactoringTimestamp: Date
}

public struct AIDocumentationResult {
    let originalCode: String
    let generatedDocumentation: String
    let documentationType: DocumentationType
    let generationTimestamp: Date
}

public struct AITestGenerationResult {
    let originalCode: String
    let generatedTests: String
    let testType: TestType
    let estimatedCoverage: Int
    let generationTimestamp: Date
}

public struct AICodeReviewResult {
    let reviewedFiles: [String]
    let fileAnalyses: [FileReviewAnalysis]
    let overallSummary: String
    let reviewType: ReviewType
    let overallQualityScore: Int
    let reviewTimestamp: Date
}

public struct FileReviewAnalysis {
    let fileName: String
    let filePath: String
    let reviewComments: String
    let qualityRating: Int
    let topImprovements: [String]
    let reviewTimestamp: Date
}

public enum CodeStyle {
    case production
    case prototype
    case educational

    var description: String {
        switch self {
        case .production: "production-ready with full error handling and documentation"
        case .prototype: "prototype/experimental with basic structure"
        case .educational: "educational with detailed comments and explanations"
        }
    }
}

public struct RefactoringGoal {
    let description: String
    let objectives: [String]
}

public enum DocumentationType {
    case comprehensive
    case api
    case inline

    var description: String {
        switch self {
        case .comprehensive: "comprehensive"
        case .api: "API-focused"
        case .inline: "inline"
        }
    }
}

public enum TestType {
    case unit
    case integration
    case performance

    var description: String {
        switch self {
        case .unit: "unit"
        case .integration: "integration"
        case .performance: "performance"
        }
    }
}

public enum ReviewType {
    case comprehensive
    case security
    case performance
    case style

    var description: String {
        switch self {
        case .comprehensive: "comprehensive"
        case .security: "security-focused"
        case .performance: "performance-focused"
        case .style: "style and convention"
        }
    }
}

public struct SecurityIssue {
    let type: String
    let severity: Severity
    let description: String
    let recommendation: String
}

public struct PerformanceIssue {
    let type: String
    let impact: Impact
    let description: String
    let suggestion: String
}

public struct BestPracticeViolation {
    let rule: String
    let violation: String
    let suggestion: String
}

public struct CodeImprovement {
    let title: String
    let description: String
    let currentCode: String
    let improvedCode: String
    let benefits: [String]
    let priority: Priority
}

public struct CodeComparison {
    let originalLinesOfCode: Int
    let refactoredLinesOfCode: Int
    let complexityReduction: Double
    let performanceImpact: PerformanceImpact
    let maintainabilityScore: Double
    let readabilityImprovement: Bool
}

public enum Severity {
    case low, medium, high
}

public enum Impact {
    case low, medium, high
}

public enum Priority {
    case low, medium, high
}

public enum PerformanceImpact {
    case positive, neutral, negative
}

public enum TechnicalDebtLevel {
    case low, medium, high
}

public struct AISuggestion {
    let title: String
    let description: String
    let priority: Priority
    let estimatedEffort: String
    let category: String
}
