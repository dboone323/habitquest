@testable import CodingReviewer
import XCTest

final class CodeAnalysisEngineIntegrationTests: XCTestCase {
    private var sut: CodeAnalysisEngine!

    override func setUp() {
        super.setUp()
        self.sut = CodeAnalysisEngine()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testAnalyzeCodeAggregatesIssuesFromSelectedServices() {
        let code = """
        // TODO: cleanup
        let values = [1,2,3]
        let mapped = values.filter { $0 > 1 }.map { $0 * 2 }
        """

        let result = self.sut.analyzeCode(code: code, language: "Swift", analysisTypes: [.bugs, .performance])

        XCTAssertEqual(result.analysisType, .comprehensive)
        XCTAssertEqual(result.language, "Swift")
        XCTAssertTrue(result.issues.contains { $0.category == .bug })
        XCTAssertTrue(result.issues.contains { $0.category == .performance })
        XCTAssertTrue(result.analysis.contains("Code Analysis Summary"))
    }

    func testAnalyzeCodeWithSingleServiceLimitsIssueCategories() {
        let code = """
        let password = "secret"
        UserDefaults.standard.set(password, forKey: "password")
        """

        let result = self.sut.analyzeCode(code: code, language: "Swift", analysisTypes: [.security])

        XCTAssertTrue(result.issues.allSatisfy { $0.category == .security })
        XCTAssertEqual(result.language, "Swift")
    }
}
