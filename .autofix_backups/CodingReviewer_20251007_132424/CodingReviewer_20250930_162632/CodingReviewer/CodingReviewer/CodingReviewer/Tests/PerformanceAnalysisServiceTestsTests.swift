@testable import CodingReviewer
import XCTest

final class PerformanceAnalysisServiceAdditionalTests: XCTestCase {
    private var sut: PerformanceAnalysisService!

    override func setUp() {
        super.setUp()
        self.sut = PerformanceAnalysisService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testFilterFollowedByMapOnSingleLineIsDetected() {
        let code = "let result = values.filter { $0 > 0 }.map { $0 * 2 }"

        let issues = self.sut.detectPerformanceIssues(in: code, language: "Swift")

        XCTAssertTrue(issues.contains { $0.description.contains("filter followed by map") })
    }

    func testFlatMapSuggestionTriggeredForChainedOperations() {
        let code = """
        let result = values
            .filter { $0 > 0 }
            .map { $0 * 2 }
        """

        let issues = self.sut.detectPerformanceIssues(in: code, language: "Swift")

        XCTAssertTrue(issues.contains { $0.description.contains("flatMap") })
    }
}
