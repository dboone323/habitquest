import XCTest
@testable import CodingReviewer

final class AIServiceProtocolsTests: XCTestCase {

    func testServiceHealthInitialization() {
        let health = ServiceHealth(
            serviceName: "TestService",
            isRunning: true,
            modelsAvailable: true,
            responseTime: 1.5,
            errorRate: 0.02,
            lastChecked: Date(),
            recommendations: ["Check logs"]
        )

        XCTAssertEqual(health.serviceName, "TestService")
        XCTAssertTrue(health.isRunning)
        XCTAssertTrue(health.modelsAvailable)
        XCTAssertEqual(health.responseTime, 1.5)
        XCTAssertEqual(health.errorRate, 0.02)
        XCTAssertNotNil(health.lastChecked)
        XCTAssertEqual(health.recommendations, ["Check logs"])
    }

    func testServiceHealthDefaultInitialization() {
        let health = ServiceHealth()

        XCTAssertEqual(health.serviceName, "")
        XCTAssertFalse(health.isRunning)
        XCTAssertFalse(health.modelsAvailable)
        XCTAssertNil(health.responseTime)
        XCTAssertEqual(health.errorRate, 0.0)
        XCTAssertNotNil(health.lastChecked)
        XCTAssertEqual(health.recommendations, [])
    }

    func testCodeIssueInitialization() {
        let issue = CodeIssue(
            description: "Test issue",
            severity: .medium,
            lineNumber: 42,
            category: "style"
        )

        XCTAssertEqual(issue.description, "Test issue")
        XCTAssertEqual(issue.severity, .medium)
        XCTAssertEqual(issue.lineNumber, 42)
        XCTAssertEqual(issue.category, "style")
    }

    func testCodeIssueDefaultInitialization() {
        let issue = CodeIssue(description: "Test issue")

        XCTAssertEqual(issue.description, "Test issue")
        XCTAssertEqual(issue.severity, .medium)
        XCTAssertNil(issue.lineNumber)
        XCTAssertEqual(issue.category, "general")
    }

    func testIssueSeverityRawValues() {
        XCTAssertEqual(IssueSeverity.low.rawValue, "low")
        XCTAssertEqual(IssueSeverity.medium.rawValue, "medium")
        XCTAssertEqual(IssueSeverity.high.rawValue, "high")
        XCTAssertEqual(IssueSeverity.critical.rawValue, "critical")
    }

    func testAnalysisTypeRawValues() {
        XCTAssertEqual(AnalysisType.bugs.rawValue, "bugs")
        XCTAssertEqual(AnalysisType.performance.rawValue, "performance")
        XCTAssertEqual(AnalysisType.security.rawValue, "security")
        XCTAssertEqual(AnalysisType.comprehensive.rawValue, "comprehensive")
    }

    func testCodeComplexityRawValues() {
        XCTAssertEqual(CodeComplexity.simple.rawValue, "simple")
        XCTAssertEqual(CodeComplexity.standard.rawValue, "standard")
        XCTAssertEqual(CodeComplexity.advanced.rawValue, "advanced")
    }

    func testCodeComplexityTemperature() {
        XCTAssertEqual(CodeComplexity.simple.temperature, 0.1)
        XCTAssertEqual(CodeComplexity.standard.temperature, 0.3)
        XCTAssertEqual(CodeComplexity.advanced.temperature, 0.5)
    }

    func testCodeComplexityMaxTokens() {
        XCTAssertEqual(CodeComplexity.simple.maxTokens, 1000)
        XCTAssertEqual(CodeComplexity.standard.maxTokens, 2000)
        XCTAssertEqual(CodeComplexity.advanced.maxTokens, 4000)
    }

    func testCodeGenerationResultInitialization() {
        let result = CodeGenerationResult(
            code: "print('hello')",
            analysis: "Simple print statement",
            language: "swift",
            complexity: .simple
        )

        XCTAssertEqual(result.code, "print('hello')")
        XCTAssertEqual(result.analysis, "Simple print statement")
        XCTAssertEqual(result.language, "swift")
        XCTAssertEqual(result.complexity, .simple)
        // Note: timestamp comparison omitted due to Date precision
    }

    func testCodeGenerationResultDefaultInitialization() {
        let result = CodeGenerationResult(code: "test", language: "swift")

        XCTAssertEqual(result.code, "test")
        XCTAssertEqual(result.analysis, "")
        XCTAssertEqual(result.language, "swift")
        XCTAssertEqual(result.complexity, .standard)
        // Note: timestamp comparison omitted due to Date precision
    }

    func testCodeAnalysisResultInitialization() {
        let issues = [CodeIssue(description: "Test issue")]
        let result = CodeAnalysisResult(
            analysis: "Test analysis",
            issues: issues,
            suggestions: ["Fix issue"],
            language: "swift",
            analysisType: .bugs
        )

        XCTAssertEqual(result.analysis, "Test analysis")
        XCTAssertEqual(result.issues.count, 1)
        XCTAssertEqual(result.issues.first?.description, "Test issue")
        XCTAssertEqual(result.suggestions, ["Fix issue"])
        XCTAssertEqual(result.language, "swift")
        XCTAssertEqual(result.analysisType, .bugs)
        // Note: timestamp comparison omitted due to Date precision
    }

    func testCodeAnalysisResultDefaultInitialization() {
        let result = CodeAnalysisResult(analysis: "test", language: "swift", analysisType: .bugs)

        XCTAssertEqual(result.analysis, "test")
        XCTAssertEqual(result.issues, [])
        XCTAssertEqual(result.suggestions, [])
        XCTAssertEqual(result.language, "swift")
        XCTAssertEqual(result.analysisType, .bugs)
        // Note: timestamp comparison omitted due to Date precision
    }

    func testDocumentationResultInitialization() {
        let result = DocumentationResult(
            overview: "Test overview",
            documentedCode: "documented code",
            examples: ["example1"],
            notes: ["note1"],
            language: "swift"
        )

        XCTAssertEqual(result.overview, "Test overview")
        XCTAssertEqual(result.documentedCode, "documented code")
        XCTAssertEqual(result.examples, ["example1"])
        XCTAssertEqual(result.notes, ["note1"])
        XCTAssertEqual(result.language, "swift")
        // Note: timestamp comparison omitted due to Date precision
    }

    func testDocumentationResultDefaultInitialization() {
        let result = DocumentationResult(overview: "test", documentedCode: "code", language: "swift")

        XCTAssertEqual(result.overview, "test")
        XCTAssertEqual(result.documentedCode, "code")
        XCTAssertEqual(result.examples, [])
        XCTAssertEqual(result.notes, [])
        XCTAssertEqual(result.language, "swift")
        // Note: timestamp comparison omitted due to Date precision
    }
}