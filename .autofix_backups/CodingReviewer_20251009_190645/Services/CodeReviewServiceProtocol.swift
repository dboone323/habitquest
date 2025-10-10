//
//  CodeReviewServiceProtocol.swift
//  CodingReviewer
//
//  Protocol definition for code review service functionality
//

import Foundation

/// Protocol defining the interface for code review services
public protocol CodeReviewServiceProtocol: ServiceProtocol {
    /// Analyze code for issues and provide suggestions
    func analyzeCode(_ code: String, language: String, analysisType: AnalysisType) async throws -> CodeAnalysisResult

    /// Generate documentation for the provided code
    func generateDocumentation(_ code: String, language: String, includeExamples: Bool) async throws -> DocumentationResult

    /// Generate tests for the provided code
    func generateTests(_ code: String, language: String, testFramework: String) async throws -> TestGenerationResult

    /// Track progress of a code review session
    func trackReviewProgress(_ reviewId: UUID) async throws
}

/// Base service protocol that all services should conform to
public protocol ServiceProtocol {
    var serviceId: String { get }
    var version: String { get }
    func initialize() async throws
    func cleanup() async
    func healthCheck() async -> ServiceHealthStatus
}

/// Health status of a service
public enum ServiceHealthStatus: Sendable {
    case healthy
    case degraded(reason: String)
    case unhealthy(errorMessage: String)
}

/// Types of analysis that can be performed
public enum AnalysisType: String, Codable, CaseIterable, Sendable {
    case bugs = "Bugs"
    case performance = "Performance"
    case security = "Security"
    case style = "Style"
    case comprehensive = "Comprehensive"
}

/// Severity levels for code issues
public enum IssueSeverity: String, Codable, CaseIterable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

/// Categories of code issues
public enum IssueCategory: String, Codable, CaseIterable, Sendable {
    case bug = "Bug"
    case security = "Security"
    case performance = "Performance"
    case style = "Style"
    case maintainability = "Maintainability"
    case general = "General"
}

/// Represents a single code issue found during analysis
public struct CodeIssue: Codable, Identifiable, Sendable {
    public let id: UUID
    public let description: String
    public let severity: IssueSeverity
    public let line: Int?
    public let category: IssueCategory

    public init(description: String, severity: IssueSeverity, line: Int? = nil, category: IssueCategory) {
        self.id = UUID()
        self.description = description
        self.severity = severity
        self.line = line
        self.category = category
    }
}

/// Result of code analysis
public struct CodeAnalysisResult: Codable, Identifiable, Sendable {
    public let id: UUID
    public let analysis: String
    public let issues: [CodeIssue]
    public let suggestions: [String]
    public let language: String
    public let analysisType: AnalysisType

    public init(analysis: String, issues: [CodeIssue], suggestions: [String], language: String, analysisType: AnalysisType) {
        self.id = UUID()
        self.analysis = analysis
        self.issues = issues
        self.suggestions = suggestions
        self.language = language
        self.analysisType = analysisType
    }
}

/// Result of documentation generation
public struct DocumentationResult: Codable, Identifiable, Sendable {
    public let id: UUID
    public let documentation: String
    public let language: String
    public let includesExamples: Bool

    public init(documentation: String, language: String, includesExamples: Bool) {
        self.id = UUID()
        self.documentation = documentation
        self.language = language
        self.includesExamples = includesExamples
    }
}

/// Result of test generation
public struct TestGenerationResult: Codable, Identifiable, Sendable {
    public let id: UUID
    public let testCode: String
    public let language: String
    public let testFramework: String
    public let estimatedCoverage: Double

    public init(testCode: String, language: String, testFramework: String, estimatedCoverage: Double) {
        self.id = UUID()
        self.testCode = testCode
        self.language = language
        self.testFramework = testFramework
        self.estimatedCoverage = estimatedCoverage
    }
}
