@testable import CodingReviewer
import XCTest

final class LineLengthBoundaryTests: XCTestCase {
    private var sut: StyleAnalysisService!

    override func setUp() {
        super.setUp()
        self.sut = StyleAnalysisService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testLineExactlyAtLimitIsAccepted() {
        let exact = String(repeating: "a", count: 120)
        let code = exact + "\n"

        let issues = self.sut.detectStyleIssues(code: code, language: "Swift")

        XCTAssertTrue(issues.isEmpty)
    }

    func testLineExceedingLimitIsFlagged() {
        let exceeding = String(repeating: "b", count: 121)
        let code = exceeding + "\n"

        let issues = self.sut.detectStyleIssues(code: code, language: "Swift")

        XCTAssertTrue(issues.contains { $0.description.contains("Line 1") })
    }
}
