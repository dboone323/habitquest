@testable import CodingReviewer
import XCTest

final class AnalysisTypeMetadataTests: XCTestCase {
    func testRawValuesMatchUserFacingLabels() {
        XCTAssertEqual(AnalysisType.bugs.rawValue, "Bugs")
        XCTAssertEqual(AnalysisType.performance.rawValue, "Performance")
        XCTAssertEqual(AnalysisType.security.rawValue, "Security")
        XCTAssertEqual(AnalysisType.style.rawValue, "Style")
        XCTAssertEqual(AnalysisType.comprehensive.rawValue, "Comprehensive")
    }

    func testCaseIterableContainsAllExpectedTypes() {
        let expected: Set<AnalysisType> = [.bugs, .performance, .security, .style, .comprehensive]
        XCTAssertEqual(Set(AnalysisType.allCases), expected)
    }
}

final class IssueMetadataTests: XCTestCase {
    func testIssueSeverityRawValuesProvidePriorityLabels() {
        XCTAssertEqual(IssueSeverity.low.rawValue, "Low")
        XCTAssertEqual(IssueSeverity.medium.rawValue, "Medium")
        XCTAssertEqual(IssueSeverity.high.rawValue, "High")
        XCTAssertEqual(IssueSeverity.critical.rawValue, "Critical")
    }

    func testIssueCategoryIncludesMaintainabilityAndGeneral() {
        let categories = IssueCategory.allCases
        XCTAssertTrue(categories.contains(.maintainability))
        XCTAssertTrue(categories.contains(.general))
    }

    func testCodeIssueInitializerGeneratesUniqueIdentifiers() {
        let first = CodeIssue(description: "Test", severity: .low, line: 1, category: .bug)
        let second = CodeIssue(description: "Test", severity: .low, line: 1, category: .bug)

        XCTAssertNotEqual(first.id, second.id)
    }
}
