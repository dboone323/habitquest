import Foundation
import OSLog
import SwiftUI

// Import extracted types and helpers
import "./AICodeAnalysisTypes.swift"

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
                        qualityRating: extractQualityRating(from: reviewResponse),
                        topImprovements: extractTopImprovements(from: reviewResponse),
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
}
