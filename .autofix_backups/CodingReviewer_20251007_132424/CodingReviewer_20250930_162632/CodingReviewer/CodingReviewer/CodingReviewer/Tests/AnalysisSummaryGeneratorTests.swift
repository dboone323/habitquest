//
// AnalysisSummaryGeneratorTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

class AnalysisSummaryGeneratorTests: XCTestCase {
    private var generator: AnalysisSummaryGenerator!

    override func setUp() {
        super.setUp()
        self.generator = AnalysisSummaryGenerator()
    }

    override func tearDown() {
        self.generator = nil
        super.tearDown()
    }

    func testGenerateSuggestionsForPerformanceAnalysis() {
        let suggestions = self.generator.generateSuggestions(code: "", language: "Swift", analysisType: .performance)

        XCTAssertEqual(suggestions.count, 2)
        XCTAssertTrue(suggestions.contains("Consider using lazy loading for large datasets"))
        XCTAssertTrue(suggestions.contains("Profile code performance with Instruments"))
    }

    func testGenerateAnalysisSummaryForPerformanceWithoutIssues() {
        let summary = self.generator.generateAnalysisSummary(
            issues: [],
            suggestions: ["Add profiling"],
            analysisType: .performance,
            language: "Swift"
        )

        XCTAssertTrue(summary.contains("Analysis completed for Performance review."))
        XCTAssertTrue(summary.contains("No issues found in this category."))
        XCTAssertTrue(summary.contains("Suggestions for improvement:"))
    }

    func testGenerateComprehensiveSummaryIncludesStatisticsAndDetailedIssues() {
        let issues = [
            CodeIssue(description: "Issue 1", severity: .critical, line: 10, category: .bug),
            CodeIssue(description: "Issue 2", severity: .high, line: 20, category: .performance),
            CodeIssue(description: "Issue 3", severity: .medium, line: 30, category: .security),
        ]

        let suggestions = [
            "Fix critical bug",
            "Optimize performance",
            "Address security finding",
        ]

        let summary = self.generator.generateAnalysisSummary(
            issues: issues,
            suggestions: suggestions,
            analysisType: .comprehensive,
            language: "Swift"
        )

        XCTAssertTrue(summary.contains("# Code Analysis Summary"))
        XCTAssertTrue(summary.contains("Swift code analysis"))
        XCTAssertTrue(summary.contains("Critical Priority: 1"))
        XCTAssertTrue(summary.contains("Bug Issues: 1"))
        XCTAssertTrue(summary.contains("Security Issues: 1"))
        XCTAssertTrue(summary.contains("FileA.swift: 2 issues"))
        XCTAssertTrue(summary.contains("FileB.js: 1 issue"))
        XCTAssertTrue(summary.contains("**Suggestion:** Fix critical bug"))
    }
}
