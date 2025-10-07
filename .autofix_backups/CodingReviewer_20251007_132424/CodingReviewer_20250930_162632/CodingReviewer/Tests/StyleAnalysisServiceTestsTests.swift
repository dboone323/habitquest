@testable import CodingReviewer
import XCTest

final class StyleAnalysisServiceAdditionalTests: XCTestCase {
    private var sut: StyleAnalysisService!

    override func setUp() {
        super.setUp()
        self.sut = StyleAnalysisService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDoesNotFlagDocumentedFunction() {
        let code = """
        /// Greets the user by name
        func greet(name: String) -> String {
            "Hello, \(name)"
        }
        """

        let issues = self.sut.detectStyleIssues(code: code, language: "Swift")

        XCTAssertFalse(issues.contains { $0.description.contains("documentation") })
    }

    func testDetectsMultipleLongLines() {
        let longLine = String(repeating: "a", count: 140)
        let code = """
        \(longLine)
        \(longLine)
        """

        let issues = self.sut.detectStyleIssues(code: code, language: "Swift")

        let longLineIssues = issues.filter { $0.description.contains("Line") }
        XCTAssertEqual(longLineIssues.count, 2)
    }
}
