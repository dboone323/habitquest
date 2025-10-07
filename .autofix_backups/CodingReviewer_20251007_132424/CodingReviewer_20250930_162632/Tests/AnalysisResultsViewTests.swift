//
// AnalysisResultsViewTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

final class AnalysisResultsViewModelTests: XCTestCase {
    func testEmptyStateIsVisibleWhenNoIssues() {
        let result = CodeAnalysisResult(
            analysis: "Summary",
            issues: [],
            suggestions: [],
            language: "Swift",
            analysisType: .comprehensive
        )

        let viewModel = AnalysisResultsViewModel(result: result)

        XCTAssertTrue(viewModel.shouldShowEmptyState)
        XCTAssertEqual(viewModel.emptyStateMessage, "No issues found")
    }

    func testIssuesAreExposedWhenPresent() {
        let issues = [
            CodeIssue(description: "Force unwrap", severity: .high, line: 10, category: .bug),
            CodeIssue(description: "Long line", severity: .low, line: 20, category: .style),
        ]

        let result = CodeAnalysisResult(
            analysis: "Summary",
            issues: issues,
            suggestions: [],
            language: "Swift",
            analysisType: .comprehensive
        )

        let viewModel = AnalysisResultsViewModel(result: result)

        XCTAssertFalse(viewModel.shouldShowEmptyState)
        XCTAssertEqual(viewModel.issues.count, 2)
        XCTAssertEqual(viewModel.issues[0].description, "Force unwrap")
    }
}
