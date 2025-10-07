@testable import CodingReviewer
import XCTest

final class CodeAnalysisEngineUnitTests: XCTestCase {
    private var sut: CodeAnalysisEngine!

    override func setUp() {
        super.setUp()
        self.sut = CodeAnalysisEngine()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testBugAnalysisReturnsBugIssuesOnly() {
        let code = """
        // TODO: refine logic
        print("debug")
        """

        let issues = self.sut.performBasicAnalysis(code: code, language: "Swift", analysisType: .bugs)

        XCTAssertFalse(issues.isEmpty)
        XCTAssertTrue(issues.allSatisfy { $0.category == .bug })
    }

    func testStyleAnalysisFlagsUndocumentedFunctions() {
        let code = """
        func run() {}
        """

        let issues = self.sut.performBasicAnalysis(code: code, language: "Swift", analysisType: .style)

        XCTAssertTrue(issues.contains { $0.category == .style })
    }

    func testSecurityAnalysisDetectsUserDefaultsPassword() {
        let code = """
        func store(password: String) {
            UserDefaults.standard.set(password, forKey: "userPassword")
        }
        """

        let issues = self.sut.performBasicAnalysis(code: code, language: "Swift", analysisType: .security)

        XCTAssertTrue(issues.contains { $0.category == .security })
    }
}
