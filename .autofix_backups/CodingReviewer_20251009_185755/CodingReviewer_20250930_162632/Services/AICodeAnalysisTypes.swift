import Foundation

// MARK: - Core Analysis Types

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

// MARK: - Configuration Enums

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

// MARK: - Issue and Improvement Types

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

// MARK: - Severity and Impact Enums

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
