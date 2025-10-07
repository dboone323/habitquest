//
// StyleAnalysisServiceTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

class StyleAnalysisServiceTests: XCTestCase {
    private var sut: StyleAnalysisService!

    override func setUp() {
        super.setUp()
        self.sut = StyleAnalysisService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDetectsLongLineInSwiftSource() {
        let longLine = String(repeating: "a", count: 130)
        let code = longLine + "\n"

        let issues = self.sut.detectStyleIssues(code: code, language: "Swift")

        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.category, .style)
        XCTAssertEqual(issues.first?.line, 1)
    }

    func testDetectsMissingDocumentationForFunction() {
        let code = """
        struct Greeter {
            func greet() {}
        }
        """

        let issues = self.sut.detectStyleIssues(code: code, language: "Swift")

        XCTAssertTrue(issues.contains { $0.description.contains("documentation comments") })
    }

    func testReturnsNoIssuesForNonSwiftLanguage() {
        let code = "function greet() {}"

        let issues = self.sut.detectStyleIssues(code: code, language: "JavaScript")

        XCTAssertTrue(issues.isEmpty)
    }
}
