@testable import CodingReviewer
import XCTest

final class TestResultsPresenterTests: XCTestCase {
    private var result: TestGenerationResult!
    private var presenter: TestResultsPresenter!

    override func setUp() {
        super.setUp()
        self.result = TestGenerationResult(
            testCode: "func testExample() { }",
            language: "Swift",
            testFramework: "XCTest",
            estimatedCoverage: 74.5
        )
        self.presenter = TestResultsPresenter(result: self.result)
    }

    override func tearDown() {
        self.presenter = nil
        self.result = nil
        super.tearDown()
    }

    func testCoverageDisplayRoundsDownToNearestInteger() {
        XCTAssertEqual(self.presenter.coverageDisplay, "Est. Coverage: 74%")
    }

    func testFrameworkAndLanguageLabelsReflectResultMetadata() {
        XCTAssertEqual(self.presenter.frameworkLabel, "Framework: XCTest")
        XCTAssertEqual(self.presenter.languageLabel, "Language: Swift")
    }

    func testCodeSnippetReturnsGeneratedTestCode() {
        XCTAssertEqual(self.presenter.codeSnippet, "func testExample() { }")
    }
}
