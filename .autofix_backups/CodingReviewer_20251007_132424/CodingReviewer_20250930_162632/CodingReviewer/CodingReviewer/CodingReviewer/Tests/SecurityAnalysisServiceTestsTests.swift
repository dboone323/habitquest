@testable import CodingReviewer
import XCTest

final class SecurityAnalysisServiceAdditionalTests: XCTestCase {
    private var sut: SecurityAnalysisService!

    override func setUp() {
        super.setUp()
        self.sut = SecurityAnalysisService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDetectsInnerHTMLAssignmentInJavaScript() {
        let code = "document.getElementById('output').innerHTML = input;"

        let issues = self.sut.detectSecurityIssues(code: code, language: "JavaScript")

        XCTAssertTrue(issues.contains { $0.description.contains("innerHTML") })
    }

    func testIgnoresUserDefaultsWhenPasswordKeywordAbsent() {
        let code = "UserDefaults.standard.set(token, forKey: \"userToken\")"

        let issues = self.sut.detectSecurityIssues(code: code, language: "Swift")

        XCTAssertTrue(issues.isEmpty)
    }
}
