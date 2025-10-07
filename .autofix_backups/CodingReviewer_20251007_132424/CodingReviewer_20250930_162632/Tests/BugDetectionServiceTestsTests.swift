@testable import CodingReviewer
import XCTest

final class BugDetectionServiceAdditionalTests: XCTestCase {
    private var sut: BugDetectionService!

    override func setUp() {
        super.setUp()
        self.sut = BugDetectionService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDetectsFixmeCommentsWithLineNumbers() {
        let code = """
        // FIXME: address bug
        let value = compute()
        """

        let issues = self.sut.detectBasicBugs(code: code, language: "Swift")

        XCTAssertTrue(issues.contains { $0.description.contains("FIXME") && $0.line == 1 })
    }

    func testDebugPrintIsReportedOnceEvenIfMultipleOccur() {
        let code = """
        print("debug 1")
        print("debug 2")
        """

        let issues = self.sut.detectBasicBugs(code: code, language: "Swift")

        let debugIssues = issues.filter { $0.description.contains("Debug print") }
        XCTAssertEqual(debugIssues.count, 1)
    }

    func testForceUnwrapReportedOnceAcrossMultipleLines() {
        let code = """
        let value = optional!
        let another = other!
        """

        let issues = self.sut.detectBasicBugs(code: code, language: "Swift")

        let forceUnwrapIssues = issues.filter { $0.description.contains("Force unwrapping") }
        XCTAssertEqual(forceUnwrapIssues.count, 1)
    }
}
