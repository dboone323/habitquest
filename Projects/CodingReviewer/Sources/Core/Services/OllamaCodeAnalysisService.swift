//  OllamaCodeAnalysisService.swift
//  CodingReviewer
//
//  Created by AI Enhancement System
//  Generated: October 10, 2025

import Foundation

/// Concrete implementation of CodeAnalysisService using Ollama AI models
@MainActor
class OllamaCodeAnalysisService: CodeAnalysisService {
    private let aiReviewer: AICodeReviewer
    private let performanceManager: PerformanceManager

    init(aiReviewer: AICodeReviewer = AICodeReviewer(),
         performanceManager: PerformanceManager = PerformanceManager()) {
        self.aiReviewer = aiReviewer
        self.performanceManager = performanceManager
    }

    /// Analyzes code for a given programming language using AI
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language of the code
    /// - Returns: AnalysisResult containing findings and metrics
    func analyzeCode(_ code: String, language: String) async throws -> AnalysisResult {
        // Perform parallel analysis for better performance
        async let styleReview = aiReviewer.reviewCodeStyle(code)
        async let codeSmells = aiReviewer.detectCodeSmells(code)
        async let performanceAnalysis = aiReviewer.analyzePerformance(code)
        async let refactoringSuggestions = aiReviewer.generateRefactoringSuggestions(code)

        // Wait for all analyses to complete
        let (style, smells, performance, refactoring) = try await (styleReview, codeSmells, performanceAnalysis, refactoringSuggestions)

        // Convert AI results to unified format
        let issues = convertToIssues(smells: smells)
        let suggestions = convertToSuggestions(style: style, refactoring: refactoring, performance: performance)
        let metrics = calculateMetrics(code: code, language: language)

        return AnalysisResult(
            complexityScore: calculateComplexityScore(metrics: metrics, issues: issues),
            maintainabilityIndex: calculateMaintainabilityIndex(metrics: metrics, issues: issues),
            issues: issues,
            metrics: metrics,
            suggestions: suggestions
        )
    }

    /// Generates improvement suggestions based on identified issues
    /// - Parameter issues: Array of code issues found during analysis
    /// - Returns: Array of actionable suggestions
    func suggestImprovements(for issues: [CodeIssue]) async throws -> [Suggestion] {
        // Group issues by type for more targeted suggestions
        let issuesByType = Dictionary(grouping: issues) { $0.type }

        var suggestions: [Suggestion] = []

        // Generate suggestions for each issue type
        for (type, typeIssues) in issuesByType {
            let typeSuggestions = try await generateSuggestionsForIssueType(type, issues: typeIssues)
            suggestions.append(contentsOf: typeSuggestions)
        }

        // Sort by impact and effort
        return suggestions.sorted { (lhs, rhs) in
            if lhs.impact != rhs.impact {
                return lhs.impact > rhs.impact // Higher impact first
            }
            return lhs.effort < rhs.effort // Lower effort first
        }
    }

    /// Generates documentation for the provided code
    /// - Parameter code: The source code to document
    /// - Returns: Generated documentation string
    func generateDocumentation(for code: String) async throws -> String {
        let documentation = try await aiReviewer.generateDocumentation(code)
        return formatDocumentation(documentation)
    }

    // MARK: - Private Methods

    private func convertToIssues(smells: [CodeSmell]) -> [CodeIssue] {
        return smells.map { smell in
            let severity: CodeIssue.Severity
            switch smell.severity.lowercased() {
            case "high", "critical": severity = .critical
            case "medium": severity = .warning
            case "low": severity = .info
            default: severity = .warning
            }

            let type: CodeIssue.IssueType
            let smellTypeLower = smell.type.lowercased()
            if smellTypeLower.contains("performance") {
                type = .performance
            } else if smellTypeLower.contains("security") {
                type = .security
            } else if smellTypeLower.contains("style") {
                type = .style
            } else if smellTypeLower.contains("documentation") {
                type = .documentation
            } else {
                type = .maintainability
            }

            return CodeIssue(
                type: type,
                severity: severity,
                message: smell.description,
                lineNumber: nil, // Would need parsing to extract line numbers
                columnNumber: nil,
                ruleId: smell.type.replacingOccurrences(of: " ", with: "_").lowercased()
            )
        }
    }

    private func convertToSuggestions(style: StyleReview, refactoring: [RefactoringSuggestion], performance: PerformanceAnalysis) -> [Suggestion] {
        var suggestions: [Suggestion] = []

        // Style suggestions
        for (index, recommendation) in style.recommendations.enumerated() {
            suggestions.append(Suggestion(
                title: "Style Improvement \(index + 1)",
                description: recommendation,
                codeExample: style.examples["example_\(index + 1)"],
                impact: .low,
                effort: .low
            ))
        }

        // Refactoring suggestions
        for refactor in refactoring {
            let impact: Suggestion.Impact
            switch refactor.type.lowercased() {
            case "extract method", "extract class": impact = .high
            case "rename variable", "rename method": impact = .medium
            default: impact = .medium
            }

            let effort: Suggestion.Effort
            switch refactor.type.lowercased() {
            case "rename variable", "rename method": effort = .trivial
            case "extract method": effort = .low
            default: effort = .medium
            }

            suggestions.append(Suggestion(
                title: refactor.type,
                description: refactor.problem,
                codeExample: refactor.afterCode,
                impact: impact,
                effort: effort
            ))
        }

        // Performance suggestions
        for optimization in performance.optimizations {
            suggestions.append(Suggestion(
                title: "Performance Optimization",
                description: optimization.suggestion,
                codeExample: optimization.codeExample,
                impact: .high,
                effort: .medium
            ))
        }

        return suggestions
    }

    private func calculateMetrics(code: String, language: String) -> AnalysisResult.CodeMetrics {
        let lines = code.components(separatedBy: .newlines)
        let linesOfCode = lines.count

        // Simple cyclomatic complexity calculation (placeholder)
        let cyclomaticComplexity = countControlStructures(in: code)

        // Cognitive complexity estimation (placeholder)
        let cognitiveComplexity = estimateCognitiveComplexity(lines: lines)

        // Duplication percentage (placeholder - would need more sophisticated analysis)
        let duplicationPercentage = estimateDuplication(in: lines)

        return AnalysisResult.CodeMetrics(
            linesOfCode: linesOfCode,
            cyclomaticComplexity: cyclomaticComplexity,
            cognitiveComplexity: cognitiveComplexity,
            duplicationPercentage: duplicationPercentage
        )
    }

    private func countControlStructures(in code: String) -> Int {
        let controlKeywords = ["if", "else", "for", "while", "switch", "case", "catch", "guard"]
        var count = 1 // Base complexity

        for keyword in controlKeywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let nsString = code as NSString
                let range = NSRange(location: 0, length: nsString.length)
                count += regex.numberOfMatches(in: code, range: range)
            }
        }

        return count
    }

    private func estimateCognitiveComplexity(lines: [String]) -> Int {
        var complexity = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("if") || trimmed.hasPrefix("else if") ||
                trimmed.hasPrefix("for") || trimmed.hasPrefix("while") ||
                trimmed.hasPrefix("switch") || trimmed.hasPrefix("catch") {
                complexity += 1
            }
            // Add nesting complexity (simplified)
            let indentLevel = line.prefix(while: { $0 == " " }).count / 4
            complexity += indentLevel
        }

        return complexity
    }

    private func estimateDuplication(in lines: [String]) -> Double {
        // Simplified duplication estimation
        var uniqueLines = Set<String>()
        var totalLines = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                uniqueLines.insert(trimmed)
                totalLines += 1
            }
        }

        guard totalLines > 0 else { return 0.0 }
        return Double(totalLines - uniqueLines.count) / Double(totalLines) * 100.0
    }

    private func calculateComplexityScore(metrics: AnalysisResult.CodeMetrics, issues: [CodeIssue]) -> Double {
        var score = 0.0

        // Base score from metrics
        score += Double(metrics.cyclomaticComplexity) * 0.3
        score += Double(metrics.cognitiveComplexity) * 0.2
        score += metrics.duplicationPercentage * 0.2

        // Adjust for issues
        let criticalIssues = issues.filter { $0.severity == .critical }.count
        let warningIssues = issues.filter { $0.severity == .warning }.count

        score += Double(criticalIssues) * 2.0
        score += Double(warningIssues) * 1.0

        // Normalize to 0-10 scale
        return min(max(score, 0.0), 10.0)
    }

    private func calculateMaintainabilityIndex(metrics: AnalysisResult.CodeMetrics, issues: [CodeIssue]) -> Double {
        // Simplified maintainability index calculation
        let volume = Double(metrics.linesOfCode)
        let complexity = Double(metrics.cyclomaticComplexity)
        let issuePenalty = Double(issues.count)

        // Higher is better (0-100 scale)
        let index = 100.0 - (volume * 0.1) - (complexity * 2.0) - (issuePenalty * 5.0)
        return max(index, 0.0)
    }

    private func generateSuggestionsForIssueType(_ type: CodeIssue.IssueType, issues: [CodeIssue]) async throws -> [Suggestion] {
        // Generate targeted suggestions based on issue type
        switch type {
        case .performance:
            return try await generatePerformanceSuggestions(for: issues)
        case .security:
            return try await generateSecuritySuggestions(for: issues)
        case .style:
            return try await generateStyleSuggestions(for: issues)
        case .maintainability:
            return try await generateMaintainabilitySuggestions(for: issues)
        case .bug:
            return try await generateBugFixSuggestions(for: issues)
        case .documentation:
            return try await generateDocumentationSuggestions(for: issues)
        }
    }

    private func generatePerformanceSuggestions(for issues: [CodeIssue]) async throws -> [Suggestion] {
        // Generate performance-specific suggestions
        return issues.map { issue in
            let title = "Performance: \(String(issue.message.prefix(50)))"
            Suggestion(
                title: title,
                description: "Address performance issue: \(issue.message)",
                codeExample: nil, // Would need more context
                impact: .high,
                effort: .medium
            )
        }
    }

    private func generateSecuritySuggestions(for issues: [CodeIssue]) async throws -> [Suggestion] {
        return issues.map { issue in
            let title = "Security: \(String(issue.message.prefix(50)))"
            Suggestion(
                title: title,
                description: "Address security vulnerability: \(issue.message)",
                codeExample: nil,
                impact: .critical,
                effort: .high
            )
        }
    }

    private func generateStyleSuggestions(for issues: [CodeIssue]) async throws -> [Suggestion] {
        return issues.map { issue in
            let title = "Style: \(String(issue.message.prefix(50)))"
            Suggestion(
                title: title,
                description: "Improve code style: \(issue.message)",
                codeExample: nil,
                impact: .low,
                effort: .low
            )
        }
    }

    private func generateMaintainabilitySuggestions(for issues: [CodeIssue]) async throws -> [Suggestion] {
        return issues.map { issue in
            let title = "Maintainability: \(String(issue.message.prefix(50)))"
            Suggestion(
                title: title,
                description: "Improve maintainability: \(issue.message)",
                codeExample: nil,
                impact: .medium,
                effort: .medium
            )
        }
    }

    private func generateBugFixSuggestions(for issues: [CodeIssue]) async throws -> [Suggestion] {
        return issues.map { issue in
            let title = "Bug Fix: \(String(issue.message.prefix(50)))"
            Suggestion(
                title: title,
                description: "Fix potential bug: \(issue.message)",
                codeExample: nil,
                impact: .high,
                effort: .medium
            )
        }
    }

    private func generateDocumentationSuggestions(for issues: [CodeIssue]) async throws -> [Suggestion] {
        return issues.map { issue in
            let title = "Documentation: \(String(issue.message.prefix(50)))"
            Suggestion(
                title: title,
                description: "Improve documentation: \(issue.message)",
                codeExample: nil,
                impact: .low,
                effort: .low
            )
        }
    }

    private func formatDocumentation(_ result: DocumentationResult) -> String {
        var formatted = ""

        // Add overview
        formatted += "/// " + result.overview + "\n\n"

        // Add documented code
        formatted += result.documentedCode + "\n\n"

        // Add examples
        if !result.examples.isEmpty {
            formatted += "/// Examples:\n"
            for example in result.examples {
                formatted += "/// " + example + "\n"
            }
            formatted += "\n"
        }

        // Add notes
        if !result.notes.isEmpty {
            formatted += "/// Notes:\n"
            for note in result.notes {
                formatted += "/// - " + note + "\n"
            }
        }

        return formatted
    }
}
