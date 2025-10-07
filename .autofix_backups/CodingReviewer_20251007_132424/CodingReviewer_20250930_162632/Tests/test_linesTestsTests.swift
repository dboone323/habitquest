//
// test_linesTestsTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

final class LineLengthAnalysisTests: XCTestCase {
    private var sut: StyleAnalysisService!

    override func setUp() {
        super.setUp()
        self.sut = StyleAnalysisService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testLongLineReportsCorrectLineNumber() {
        let longLine = String(repeating: "x", count: 150)
        let code = "short\n\(longLine)"

        let issues = self.sut.detectStyleIssues(code: code, language: "Swift")

        let longLineIssue = issues.first { $0.description.contains("Line 2") }
        XCTAssertNotNil(longLineIssue)
        XCTAssertEqual(longLineIssue?.line, 2)
    }
}
