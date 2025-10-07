@testable import CodingReviewer
import XCTest

final class CodeAnalysisEngineBehaviorTests: XCTestCase {
    private var sut: CodeAnalysisEngine!

    override func setUp() {
        super.setUp()
        self.sut = CodeAnalysisEngine()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testComprehensiveAnalysisSurfacedIssuesAcrossServices() {
        let code = """
        // Intentional TODO to verify bug detection
        let result = values.filter { $0 > 0 }.map { $0 * 2 }
        let password = "superSecret"
        UserDefaults.standard.set(password, forKey: "userPassword")
        func greet() {
            print("debug message")
        }
        """

        let issues = self.sut.performBasicAnalysis(code: code, language: "Swift", analysisType: .comprehensive)

        let categories = Set(issues.map(\.$category))

        XCTAssertTrue(categories.contains(.bug), "Expected bug detection for TODO or print usage")
        XCTAssertTrue(categories.contains(.performance), "Expected performance detection for filter+map chain")
        XCTAssertTrue(categories.contains(.security), "Expected security detection for password in UserDefaults")
        XCTAssertTrue(categories.contains(.style), "Expected style detection for undocumented function")
    }

    func testGenerateAnalysisSummaryIncludesSeverityAndCategoryBreakdown() {
        let issues: [CodeIssue] = [
            CodeIssue(description: "Critical bug", severity: .critical, line: 3, category: .bug),
            CodeIssue(description: "Security concern", severity: .high, line: 5, category: .security),
            CodeIssue(description: "Performance note", severity: .medium, line: 7, category: .performance),
            CodeIssue(description: "Style suggestion", severity: .low, line: 9, category: .style),
        ]
        let suggestions = ["Address critical bug", "Harden security", "Optimize loop", "Document public API"]

        let summary = self.sut.generateAnalysisSummary(
            issues: issues,
            suggestions: suggestions,
            analysisType: .comprehensive,
            language: "Swift"
        )

        XCTAssertTrue(summary.contains("# Code Analysis Summary"))
        XCTAssertTrue(summary.contains("Critical Priority: 1"), "Expected critical count")
        XCTAssertTrue(summary.contains("Security Issues: 1"), "Expected security category count")
        XCTAssertTrue(summary.contains("## Detailed Issues"), "Expected detailed issues section")
    }
}

@MainActor
final class CodeReviewServiceBehaviorTests: XCTestCase {
    private var sut: CodeReviewService!

    override func setUp() {
        super.setUp()
        self.sut = CodeReviewService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testAnalyzeCodeDeliversComprehensiveResults() async throws {
        let code = """
        // Known issue: temporary logging left in place to exercise analysis
        print("temporary logging")
        """

        let result = try await sut.analyzeCode(code, language: "Swift", analysisType: .comprehensive)

        XCTAssertEqual(result.language, "Swift")
        XCTAssertEqual(result.analysisType, .comprehensive)
        XCTAssertFalse(result.analysis.isEmpty, "Expected analysis summary")
        XCTAssertFalse(result.issues.isEmpty, "Expected at least one surfaced issue")
        XCTAssertFalse(result.suggestions.isEmpty, "Expected improvement suggestions")
    }
}

final class DocumentationGeneratorBehaviorTests: XCTestCase {
    private var sut: DocumentationGenerator!

    override func setUp() {
        super.setUp()
        self.sut = DocumentationGenerator()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testGenerateBasicDocumentationListsFunctionsAndExamples() {
        let code = """
        func greet(name: String) -> String {
            "Hello, \(name)"
        }
        """

        let documentation = self.sut.generateBasicDocumentation(code: code, language: "Swift", includeExamples: true)

        XCTAssertTrue(documentation.contains("## Functions"), "Expected functions section in docs")
        XCTAssertTrue(documentation.contains("greet"), "Expected function signature")
        XCTAssertTrue(documentation.contains("## Usage Examples"), "Expected usage examples when requested")
    }
}
