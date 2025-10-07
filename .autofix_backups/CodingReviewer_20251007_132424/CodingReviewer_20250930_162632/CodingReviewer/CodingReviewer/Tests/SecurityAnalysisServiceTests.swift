//
// SecurityAnalysisServiceTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

class SecurityAnalysisServiceTests: XCTestCase {
    private var sut: SecurityAnalysisService!

    override func setUp() {
        super.setUp()
        self.sut = SecurityAnalysisService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDetectsEvalUsageInJavaScript() {
        let code = "const result = eval(userInput);"

        let issues = self.sut.detectSecurityIssues(code: code, language: "JavaScript")

        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.category, .security)
        XCTAssertEqual(issues.first?.severity, .high)
        XCTAssertEqual(issues.first?.description, "Use of eval() detected - security risk")
    }

    func testDetectsPasswordStoredInUserDefaults() {
        let code = """
        let password = "secret"
        UserDefaults.standard.set(password, forKey: "user_password")
        """

        let issues = self.sut.detectSecurityIssues(code: code, language: "Swift")

        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.severity, .high)
        XCTAssertEqual(issues.first?.line, 3)
        XCTAssertEqual(issues.first?.category, .security)
    }

    func testIgnoresPasswordMentionInComment() {
        let code = """
        // Password is stored securely elsewhere
        let storage = SecureStore()
        storage.save(password: input)
        """

        let issues = self.sut.detectSecurityIssues(code: code, language: "Swift")

        XCTAssertTrue(issues.isEmpty)
    }
}
