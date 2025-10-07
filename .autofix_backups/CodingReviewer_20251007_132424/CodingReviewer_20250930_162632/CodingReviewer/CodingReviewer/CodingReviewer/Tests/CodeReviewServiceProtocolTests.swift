//
// CodeReviewServiceProtocolTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

final class CodeReviewServiceProtocolTests: XCTestCase {
    func testAnalysisTypeAllCasesMatchExpectedOrder() {
        XCTAssertEqual(AnalysisType.allCases, [.bugs, .performance, .security, .style, .comprehensive])
    }

    func testIssueSeverityRawValuesMatchDisplayNames() {
        XCTAssertEqual(IssueSeverity.low.rawValue, "Low")
        XCTAssertEqual(IssueSeverity.medium.rawValue, "Medium")
        XCTAssertEqual(IssueSeverity.high.rawValue, "High")
        XCTAssertEqual(IssueSeverity.critical.rawValue, "Critical")
    }

    func testServiceHealthStatusCarriesAssociatedValues() {
        let degraded = ServiceHealthStatus.degraded(reason: "Latency")
        let unhealthy = ServiceHealthStatus.unhealthy(errorMessage: "Unavailable")

        if case let .degraded(reason) = degraded {
            XCTAssertEqual(reason, "Latency")
        } else {
            XCTFail("Expected degraded status")
        }

        if case let .unhealthy(message) = unhealthy {
            XCTAssertEqual(message, "Unavailable")
        } else {
            XCTFail("Expected unhealthy status")
        }
    }

    func testCodeIssueInitializationGeneratesUniqueIdentifiers() {
        let issueA = CodeIssue(description: "Force unwrap", severity: .high, line: 10, category: .bug)
        let issueB = CodeIssue(description: "Force unwrap", severity: .high, line: 10, category: .bug)

        XCTAssertNotEqual(issueA.id, issueB.id)
    }

    func testCodeAnalysisResultHoldsPassedValues() {
        let issues = [CodeIssue(description: "Force unwrap", severity: .high, line: 10, category: .bug)]
        let suggestions = ["Use optional binding"]
        let result = CodeAnalysisResult(
            analysis: "Summary",
            issues: issues,
            suggestions: suggestions,
            language: "Swift",
            analysisType: .comprehensive
        )

        XCTAssertEqual(result.analysis, "Summary")
        XCTAssertEqual(result.issues.count, 1)
        XCTAssertEqual(result.issues.first?.description, "Force unwrap")
        XCTAssertEqual(result.suggestions, suggestions)
        XCTAssertEqual(result.language, "Swift")
        XCTAssertEqual(result.analysisType, .comprehensive)
    }
}
