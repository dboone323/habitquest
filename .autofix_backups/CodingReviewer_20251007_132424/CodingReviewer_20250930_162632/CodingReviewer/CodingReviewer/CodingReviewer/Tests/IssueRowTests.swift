@testable import CodingReviewer
import XCTest

final class IssueRowPresenterTests: XCTestCase {
    func testPresenterMapsSeverityToExpectedIconAndColor() {
        let expectations: [(IssueSeverity, String, String)] = [
            (.low, "info.circle.fill", "blue"),
            (.medium, "exclamationmark.triangle.fill", "orange"),
            (.high, "exclamationmark.triangle.fill", "red"),
            (.critical, "xmark.circle.fill", "red"),
        ]

        for (severity, expectedIcon, expectedColorIdentifier) in expectations {
            let issue = CodeIssue(description: "Sample", severity: severity, line: 10, category: .bug)
            let presenter = IssueRowPresenter(issue: issue)

            XCTAssertEqual(presenter.iconName, expectedIcon, "Unexpected icon for severity: \(severity)")

            let diagnostics = presenter.diagnostics
            XCTAssertEqual(diagnostics.iconColorIdentifier, expectedColorIdentifier, "Unexpected icon color for severity: \(severity)")
            XCTAssertEqual(
                diagnostics.severityColorIdentifier,
                expectedColorIdentifier,
                "Unexpected severity color for severity: \(severity)"
            )
        }
    }

    func testDiagnosticsEchoIconName() {
        let issue = CodeIssue(description: "Force unwrap", severity: .high, line: 42, category: .bug)
        let presenter = IssueRowPresenter(issue: issue)

        XCTAssertEqual(presenter.iconName, presenter.diagnostics.iconName)
    }
}
