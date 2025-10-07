@testable import CodingReviewer
import XCTest

final class CodeReviewServiceIntegrationTests: XCTestCase {
    private var sut: CodeReviewService!

    override func setUp() {
        super.setUp()
        self.sut = CodeReviewService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testAnalyzeBugsOnlyReturnsBugIssues() async throws {
        let code = """
        // TODO: fix this logic
        print("debug")
        """

        let result = try await sut.analyzeCode(code, language: "Swift", analysisType: .bugs)

        XCTAssertTrue(result.issues.allSatisfy { $0.category == .bug })
        XCTAssertEqual(result.analysisType, .bugs)
    }

    func testPerformanceAnalysisSkipsBugFindings() async throws {
        let code = """
        let values = [1,2,3]
        let doubled = values.filter { $0 > 0 }.map { $0 * 2 }
        """

        let result = try await sut.analyzeCode(code, language: "Swift", analysisType: .performance)

        XCTAssertTrue(result.issues.allSatisfy { $0.category == .performance })
        XCTAssertEqual(result.analysisType, .performance)
    }
}
