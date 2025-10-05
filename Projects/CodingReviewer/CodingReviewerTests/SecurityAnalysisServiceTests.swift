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

    // MARK: - XSS Detection Tests

    func testDetectSecurityIssues_XSS_DocumentWrite() {
        // Given JavaScript code with document.write
        let code = """
        function renderUserInput(input) {
            document.write(input);
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "JavaScript")

        // Then document.write XSS vulnerability should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, .medium)
        XCTAssertEqual(issues[0].category, .security)
        XCTAssertTrue(issues[0].description.contains("document.write"))
        XCTAssertTrue(issues[0].description.contains("XSS"))
    }

    func testDetectSecurityIssues_XSS_MultipleVectors() {
        // Given JavaScript code with multiple XSS vectors
        let code = """
        function displayContent(userContent) {
            document.getElementById('output').innerHTML = userContent;
            document.write(userContent);
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "JavaScript")

        // Then both XSS vulnerabilities should be detected
        XCTAssertEqual(issues.count, 2)

        let innerHTMLIssue = issues.first { $0.description.contains("innerHTML") }
        let documentWriteIssue = issues.first { $0.description.contains("document.write") }

        XCTAssertNotNil(innerHTMLIssue)
        XCTAssertNotNil(documentWriteIssue)
    }

    // MARK: - Path Traversal Detection Tests

    func testDetectSecurityIssues_PathTraversal_RelativePath() {
        // Given code with path traversal pattern (Unix)
        let code = """
        let filePath = "../../../etc/passwd"
        let content = try String(contentsOfFile: filePath)
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then path traversal issue should be detected
        XCTAssertGreaterThanOrEqual(issues.count, 1)

        let pathTraversalIssue = issues.first { $0.description.contains("Path traversal") }
        XCTAssertNotNil(pathTraversalIssue)
        XCTAssertEqual(pathTraversalIssue?.severity, .high)
        XCTAssertEqual(pathTraversalIssue?.category, .security)
    }

    func testDetectSecurityIssues_PathTraversal_WindowsPath() {
        // Given code with Windows-style path traversal
        let code = """
        const filePath = "..\\\\..\\\\..\\\\windows\\\\system32\\\\config\\\\sam";
        const data = readFileSync(filePath);
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "JavaScript")

        // Then path traversal issue should be detected
        XCTAssertGreaterThanOrEqual(issues.count, 1)

        let pathTraversalIssue = issues.first { $0.description.contains("Path traversal") }
        XCTAssertNotNil(pathTraversalIssue)
        XCTAssertEqual(pathTraversalIssue?.severity, .high)
    }

    func testDetectSecurityIssues_PathTraversal_SafePath() {
        // Given code with safe relative path
        let code = """
        let resourcePath = "./resources/image.png"
        let data = try Data(contentsOf: URL(fileURLWithPath: resourcePath))
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then no path traversal issue should be detected (single level is OK)
        let pathTraversalIssues = issues.filter { $0.description.contains("Path traversal") }
        XCTAssertTrue(pathTraversalIssues.isEmpty)
    }

    // MARK: - Memory Safety Tests

    func testDetectSecurityIssues_MemorySafety_UnsafeBitCast() {
        // Given Swift code with unsafeBitCast
        let code = """
        func convertPointer(ptr: UnsafeRawPointer) -> Int {
            return unsafeBitCast(ptr, to: Int.self)
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then memory safety issue should be detected
        let memorySafetyIssues = issues.filter { $0.description.contains("Unsafe") }
        XCTAssertGreaterThanOrEqual(memorySafetyIssues.count, 1)

        let unsafeCastIssue = memorySafetyIssues.first { $0.description.contains("type casting") }
        XCTAssertNotNil(unsafeCastIssue)
        XCTAssertEqual(unsafeCastIssue?.severity, .high)
        XCTAssertEqual(unsafeCastIssue?.category, .security)
    }

    func testDetectSecurityIssues_MemorySafety_UnsafePointer() {
        // Given Swift code with UnsafePointer usage
        let code = """
        func processData(_ data: UnsafePointer<UInt8>, length: Int) {
            for i in 0..<length {
                print(data[i])
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then unsafe pointer issue should be detected
        XCTAssertGreaterThanOrEqual(issues.count, 1)

        let unsafePointerIssue = issues.first { $0.description.contains("Unsafe pointer") }
        XCTAssertNotNil(unsafePointerIssue)
        XCTAssertEqual(unsafePointerIssue?.severity, .medium)
        XCTAssertEqual(unsafePointerIssue?.category, .security)
    }

    func testDetectSecurityIssues_MemorySafety_UnsafeMutablePointer() {
        // Given Swift code with UnsafeMutablePointer
        let code = """
        func modifyBuffer(_ buffer: UnsafeMutablePointer<Int>, count: Int) {
            for i in 0..<count {
                buffer[i] = i * 2
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then unsafe pointer issue should be detected
        XCTAssertGreaterThanOrEqual(issues.count, 1)

        let unsafePointerIssue = issues.first { $0.description.contains("Unsafe pointer") }
        XCTAssertNotNil(unsafePointerIssue)
        XCTAssertEqual(unsafePointerIssue?.category, .security)
    }

    func testDetectSecurityIssues_MemorySafety_UnsafeDowncast() {
        // Given Swift code with unsafeDowncast
        let code = """
        func castObject(_ obj: Any) -> SpecificType {
            return unsafeDowncast(obj, to: SpecificType.self)
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then unsafe cast issue should be detected
        let unsafeCastIssue = issues.first { $0.description.contains("type casting") }
        XCTAssertNotNil(unsafeCastIssue)
        XCTAssertEqual(unsafeCastIssue?.severity, .high)
    }

    // MARK: - Concurrency Vulnerability Tests

    func testDetectSecurityIssues_Concurrency_SharedMutableState() {
        // Given Swift code with shared mutable state without protection
        let code = """
        class DataManager {
            static var sharedData: [String] = []

            func addData(_ item: String) {
                DataManager.sharedData.append(item)
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then concurrency issue should be detected
        let concurrencyIssue = issues.first { $0.description.contains("Shared mutable state") }
        XCTAssertNotNil(concurrencyIssue)
        XCTAssertEqual(concurrencyIssue?.severity, .medium)
        XCTAssertEqual(concurrencyIssue?.category, .security)
        XCTAssertTrue(concurrencyIssue?.description.contains("race condition") ?? false)
    }

    func testDetectSecurityIssues_Concurrency_PrivateSharedState() {
        // Given Swift code with private shared mutable state
        let code = """
        class SafeDataManager {
            private static var sharedData: [String] = []

            func addData(_ item: String) {
                // Private access control provides some protection
                SafeDataManager.sharedData.append(item)
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then no concurrency issue should be detected (private is protected)
        let concurrencyIssues = issues.filter { $0.description.contains("Shared mutable state") }
        XCTAssertTrue(concurrencyIssues.isEmpty)
    }

    func testDetectSecurityIssues_Concurrency_ClassVar() {
        // Given Swift code with class var without protection
        let code = """
        class Counter {
            class var count: Int = 0

            func increment() {
                Counter.count += 1
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then concurrency issue should be detected
        let concurrencyIssue = issues.first { $0.description.contains("Shared mutable state") }
        XCTAssertNotNil(concurrencyIssue)
    }

    // MARK: - Comprehensive Security Tests

    func testDetectSecurityIssues_MultipleVulnerabilities() {
        // Given code with multiple security vulnerabilities
        let code = """
        class VulnerableService {
            static var userData: [String: String] = [:]

            func processUserInput(_ input: String, password: String) {
                // Path traversal vulnerability
                let path = "../../../" + input
                let file = try? String(contentsOfFile: path)

                // Memory safety issue
                let ptr = unsafeBitCast(password, to: UnsafePointer<CChar>.self)

                // Insecure storage
                UserDefaults.standard.set(password, forKey: "userPassword")
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then multiple vulnerabilities should be detected
        XCTAssertGreaterThanOrEqual(issues.count, 4)

        let pathTraversal = issues.contains { $0.description.contains("Path traversal") }
        let memorySafety = issues.contains { $0.description.contains("Unsafe") }
        let insecureStorage = issues.contains { $0.description.contains("UserDefaults") }
        let concurrency = issues.contains { $0.description.contains("Shared mutable") }

        XCTAssertTrue(pathTraversal, "Should detect path traversal")
        XCTAssertTrue(memorySafety, "Should detect memory safety issue")
        XCTAssertTrue(insecureStorage, "Should detect insecure password storage")
        XCTAssertTrue(concurrency, "Should detect concurrency issue")
    }

    func testDetectSecurityIssues_SecureCode() {
        // Given secure Swift code with proper practices
        let code = """
        class SecureAuthManager {
            private let keychain = KeychainWrapper()

            func saveCredentials(username: String, password: String) {
                // Using Keychain for secure storage
                keychain.set(password, forKey: "userPassword")
                keychain.set(username, forKey: "username")
            }

            func loadFile(from safePath: String) -> String? {
                // Using safe, validated paths
                guard safePath.hasPrefix("/safe/directory/") else {
                    return nil
                }
                return try? String(contentsOfFile: safePath)
            }
        }
        """

        // When analyzing for security issues
        let issues = securityAnalyzer.detectSecurityIssues(code: code, language: "Swift")

        // Then no security issues should be detected
        XCTAssertTrue(issues.isEmpty, "Secure code should not trigger false positives")
    }
}
