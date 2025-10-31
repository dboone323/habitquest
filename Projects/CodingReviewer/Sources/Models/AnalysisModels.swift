import Foundation

// MARK: - Analysis Types

enum AnalysisType: String, Codable, Sendable {
    case codeQuality = "code_quality"
    case performance
    case security
    case documentation
    case complexity
    case maintainability

    var displayName: String {
        switch self {
        case .codeQuality: return "Code Quality"
        case .performance: return "Performance"
        case .security: return "Security"
        case .documentation: return "Documentation"
        case .complexity: return "Complexity"
        case .maintainability: return "Maintainability"
        }
    }

    var iconName: String {
        switch self {
        case .codeQuality: return "checkmark.circle"
        case .performance: return "speedometer"
        case .security: return "lock.shield"
        case .documentation: return "book"
        case .complexity: return "brain"
        case .maintainability: return "wrench.and.screwdriver"
        }
    }
}

// MARK: - Code Analysis Result

struct CodeAnalysisResult: Codable, Sendable {
    let fileURL: URL
    let issues: [CodeIssue]
    let metrics: CodeMetrics
    let analysisType: AnalysisType
    let timestamp: Date
    let language: ProgrammingLanguage?

    init(
        fileURL: URL,
        issues: [CodeIssue] = [],
        metrics: CodeMetrics = CodeMetrics(),
        analysisType: AnalysisType = .codeQuality,
        timestamp: Date = Date(),
        language: ProgrammingLanguage? = nil
    ) {
        self.fileURL = fileURL
        self.issues = issues
        self.metrics = metrics
        self.analysisType = analysisType
        self.timestamp = timestamp
        self.language = language
    }
}

// MARK: - Documentation Result

struct DocumentationResult: Codable, Sendable {
    let fileURL: URL
    let hasDocumentation: Bool
    let coverage: Double
    let issues: [DocumentationIssue]
    let timestamp: Date

    init(
        fileURL: URL,
        hasDocumentation: Bool = false,
        coverage: Double = 0.0,
        issues: [DocumentationIssue] = [],
        timestamp: Date = Date()
    ) {
        self.fileURL = fileURL
        self.hasDocumentation = hasDocumentation
        self.coverage = coverage
        self.issues = issues
        self.timestamp = timestamp
    }
}

// MARK: - Code Issue

struct CodeIssue: Identifiable, Codable, Sendable {
    let id: String
    let message: String
    let severity: IssueSeverity
    let line: Int
    let column: Int?
    let rule: String?
    let suggestion: String?
    let category: IssueCategory

    init(
        id: String,
        message: String,
        severity: IssueSeverity,
        line: Int,
        column: Int? = nil,
        rule: String? = nil,
        suggestion: String? = nil,
        category: IssueCategory = .general
    ) {
        self.id = id
        self.message = message
        self.severity = severity
        self.line = line
        self.column = column
        self.rule = rule
        self.suggestion = suggestion
        self.category = category
    }
}

// MARK: - Documentation Issue

struct DocumentationIssue: Identifiable, Codable, Sendable {
    let id: String
    let message: String
    let severity: IssueSeverity
    let line: Int
    let suggestion: String?

    init(
        id: String,
        message: String,
        severity: IssueSeverity,
        line: Int,
        suggestion: String? = nil
    ) {
        self.id = id
        self.message = message
        self.severity = severity
        self.line = line
        self.suggestion = suggestion
    }
}

// MARK: - Code Metrics

struct CodeMetrics: Codable, Sendable {
    let linesOfCode: Int
    let functionCount: Int
    let classCount: Int
    let complexity: Int
    let commentLines: Int
    let blankLines: Int

    init(
        linesOfCode: Int = 0,
        functionCount: Int = 0,
        classCount: Int = 0,
        complexity: Int = 0,
        commentLines: Int = 0,
        blankLines: Int = 0
    ) {
        self.linesOfCode = linesOfCode
        self.functionCount = functionCount
        self.classCount = classCount
        self.complexity = complexity
        self.commentLines = commentLines
        self.blankLines = blankLines
    }

    var commentRatio: Double {
        guard linesOfCode > 0 else { return 0 }
        return Double(commentLines) / Double(linesOfCode)
    }

    var codeDensity: Double {
        guard linesOfCode > 0 else { return 0 }
        return Double(linesOfCode - blankLines) / Double(linesOfCode)
    }
}

// MARK: - Enums

enum IssueSeverity: String, Codable, Sendable {
    case error
    case warning
    case info

    var priority: Int {
        switch self {
        case .error: return 3
        case .warning: return 2
        case .info: return 1
        }
    }
}

enum IssueCategory: String, Codable, Sendable {
    case general
    case performance
    case security
    case style
    case complexity
    case documentation
    case naming
    case structure
}
