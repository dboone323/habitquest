//
//  SecurityAnalysisServiceTests.swift
//  CodingReviewerTests
//
//  Unit tests for SecurityAnalysisService
//

@testable import CodingReviewer
import XCTest

final class SecurityAnalysisServiceTests: XCTestCase {
    var securityAnalyzer: SecurityAnalysisService!

    override func setUp() {
        super.setUp()
        securityAnalyzer = SecurityAnalysisService()
    }

    override func tearDown() {
        securityAnalyzer = nil
        super.tearDown()
    }

    // MARK: - JavaScript Security Tests

    func testDetectSecurityIssues_JavaScript_Eval() {
        // Given JavaScript code with eval
        let code = """
        function executeCode(code) {
            return eval(code);
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "JavaScript")

        // Then eval issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, .high)
        XCTAssertEqual(issues[0].category, .security)
        XCTAssertTrue(issues[0].description.contains("eval()"))
    }

    func testDetectSecurityIssues_JavaScript_InnerHTML() {
        // Given JavaScript code with innerHTML
        let code = """
        function updateContent(content) {
            document.getElementById('content').innerHTML = content;
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "JavaScript")

        // Then innerHTML issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, IssueSeverity.medium)
        XCTAssertEqual(issues[0].category, IssueCategory.security)
        XCTAssertTrue(issues[0].description.contains("innerHTML"))
    }

    func testDetectSecurityIssues_JavaScript_MultipleVulnerabilities() {
        // Given JavaScript code with both eval and innerHTML
        let code = """
        function dangerousFunction(code, content) {
            document.getElementById('content').innerHTML = content;
            return eval(code);
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "JavaScript")

        // Then both issues should be detected
        XCTAssertEqual(issues.count, 2)

        let evalIssue = issues.first { $0.description.contains("eval") }
        let htmlIssue = issues.first { $0.description.contains("innerHTML") }

        XCTAssertNotNil(evalIssue)
        XCTAssertNotNil(htmlIssue)
        XCTAssertEqual(evalIssue?.severity, .high)
        XCTAssertEqual(htmlIssue?.severity, IssueSeverity.medium)
    }

    // MARK: - Swift Security Tests

    func testDetectSecurityIssues_Swift_UserDefaults_Password() {
        // Given Swift code storing password in UserDefaults
        let code = """
        class AuthManager {
            func savePassword(_ password: String) {
                UserDefaults.standard.set(password, forKey: "userPassword")
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then UserDefaults password issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, .high)
        XCTAssertEqual(issues[0].category, .security)
        XCTAssertTrue(issues[0].description.contains("UserDefaults"))
        XCTAssertTrue(issues[0].description.contains("password"))
    }

    func testDetectSecurityIssues_Swift_UserDefaults_NoPassword() {
        // Given Swift code using UserDefaults but not for passwords
        let code = """
        class SettingsManager {
            func saveTheme(_ theme: String) {
                UserDefaults.standard.set(theme, forKey: "appTheme")
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then no issues should be detected
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectSecurityIssues_Swift_Password_NoUserDefaults() {
        // Given Swift code with password but not using UserDefaults
        let code = """
        class AuthManager {
            func savePassword(_ password: String) {
                KeychainHelper.shared.setString(password, forKey: "userPassword")
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then no issues should be detected (using Keychain is secure)
        XCTAssertTrue(issues.isEmpty)
    }

    // MARK: - Language-Specific Tests

    func testDetectSecurityIssues_NonJavaScript_NoIssues() {
        // Given JavaScript security issues in non-JavaScript code
        let code = """
        function executeCode(code) {
            return eval(code);
        }
        """

        // When analyzing as Swift
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then no issues should be detected
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectSecurityIssues_NonSwift_NoIssues() {
        // Given Swift security issues in non-Swift code
        let code = """
        class AuthManager {
            func savePassword(_ password: String) {
                UserDefaults.standard.set(password, forKey: "userPassword")
            }
        }
        """

        // When analyzing as JavaScript
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "JavaScript")

        // Then no issues should be detected
        XCTAssertTrue(issues.isEmpty)
    }

    // MARK: - Edge Cases

    func testDetectSecurityIssues_EmptyCode() {
        // Given empty code
        let code = ""

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectSecurityIssues_WhitespaceOnly() {
        // Given whitespace-only code
        let code = "   \n\t   \n  "

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectSecurityIssues_CaseSensitivity() {
        // Given code with different cases
        let code1 = "eval('code')" // lowercase
        let code2 = "EVAL('code')" // uppercase
        let code3 = "innerHTML = content" // camelCase
        let code4 = "INNERHTML = content" // uppercase

        // When analyzing for security issues
        let issues1 = securityAnalyzer.detectSecurityIssues(code: code1, language: "JavaScript")
        let issues2 = securityAnalyzer.detectSecurityIssues(code: code2, language: "JavaScript")
        let issues3 = securityAnalyzer.detectSecurityIssues(code: code3, language: "JavaScript")
        let issues4 = securityAnalyzer.detectSecurityIssues(code: code4, language: "JavaScript")

        // Then issues should be detected regardless of case
        XCTAssertEqual(issues1.count, 1) // eval detected
        XCTAssertEqual(issues2.count, 0) // EVAL not detected (case sensitive)
        XCTAssertEqual(issues3.count, 1) // innerHTML detected
        XCTAssertEqual(issues4.count, 0) // INNERHTML not detected (case sensitive)
    }

    // MARK: - Complex Scenarios

    func testDetectSecurityIssues_ComplexJavaScript() {
        // Given complex JavaScript with multiple security issues
        let code = """
        class DynamicCodeExecutor {
            execute(code) {
                // Dangerous eval usage
                const result = eval(code);

                // XSS vulnerability
                this.element.innerHTML = result;

                return result;
            }

            saveCredentials(user, pass) {
                // This would be flagged if it used UserDefaults
                localStorage.setItem('user', user);
                localStorage.setItem('pass', pass);
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "JavaScript")

        // Then both eval and innerHTML issues should be detected
        XCTAssertEqual(issues.count, 2)

        let evalIssue = issues.first { $0.description.contains("eval") }
        let htmlIssue = issues.first { $0.description.contains("innerHTML") }

        XCTAssertNotNil(evalIssue)
        XCTAssertNotNil(htmlIssue)
    }

    func testDetectSecurityIssues_ComplexSwift() {
        // Given complex Swift with security issues
        let code = """
        class AuthService {
            private let defaults = UserDefaults.standard

            func storePassword(_ password: String) {
                // Security vulnerability: storing password in UserDefaults
                defaults.set(password, forKey: "user_password")
                defaults.set(password, forKey: "backup_password")
            }

            func storeToken(_ token: String) {
                // This is OK - not a password
                defaults.set(token, forKey: "auth_token")
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then password storage issues should be detected
        XCTAssertEqual(issues.count, 2) // Two instances of password + UserDefaults

        for issue in issues {
            XCTAssertEqual(issue.severity, .high)
            XCTAssertEqual(issue.category, .security)
            XCTAssertTrue(issue.description.contains("UserDefaults"))
            XCTAssertTrue(issue.description.contains("password"))
        }
    }
}
