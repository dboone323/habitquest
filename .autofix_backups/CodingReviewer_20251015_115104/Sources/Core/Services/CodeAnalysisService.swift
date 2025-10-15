//  CodeAnalysisService.swift
//  CodingReviewer
//
//  Created by AI Enhancement System
//  Generated: October 10, 2025

import Foundation

/// Protocol defining the interface for AI-powered code analysis services
protocol CodeAnalysisService {
    /// Analyzes code for a given programming language
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language of the code
    /// - Returns: AnalysisResult containing findings and metrics
    func analyzeCode(_ code: String, language: String) async throws -> AnalysisResult

    /// Generates improvement suggestions based on identified issues
    /// - Parameter issues: Array of code issues found during analysis
    /// - Returns: Array of actionable suggestions
    func suggestImprovements(for issues: [CodeIssue]) async throws -> [Suggestion]

    /// Generates documentation for the provided code
    /// - Parameter code: The source code to document
    /// - Returns: Generated documentation string
    func generateDocumentation(for code: String) async throws -> String
}

/// Result of code analysis containing various metrics and findings
struct AnalysisResult {
    let complexityScore: Double
    let maintainabilityIndex: Double
    let issues: [CodeIssue]  // Using CodeIssue from AIServiceProtocols (imported implicitly)
    let metrics: CodeMetrics
    let suggestions: [Suggestion]

    struct CodeMetrics {
        let linesOfCode: Int
        let cyclomaticComplexity: Int
        let cognitiveComplexity: Int
        let duplicationPercentage: Double
    }
}

// Note: CodeIssue is now defined in AIServiceProtocols.swift with proper Codable/Sendable conformance
// Using qualified name AIServiceProtocols.CodeIssue to reference it

/// Represents a suggestion for code improvement
struct Suggestion {
    let title: String
    let description: String
    let codeExample: String?
    let impact: Impact
    let effort: Effort

    enum Impact {
        case low
        case medium
        case high
        case critical
    }

    enum Effort {
        case trivial
        case low
        case medium
        case high
    }
}
