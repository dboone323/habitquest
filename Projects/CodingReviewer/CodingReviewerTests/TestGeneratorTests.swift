//
//  TestGeneratorTests.swift
//  CodingReviewerTests
//
//  Unit tests for TestGenerator
//

@testable import CodingReviewer
import XCTest

final class TestGeneratorTests: XCTestCase {
    var testGenerator: TestGenerator!

    override func setUp() {
        super.setUp()
        testGenerator = TestGenerator()
    }

    override func tearDown() {
        testGenerator = nil
        super.tearDown()
    }

    // MARK: - Test Generation Tests

    func testGenerateBasicTests_Swift_XCTest() {
        // Given Swift code and XCTest framework
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When generating basic tests
        let testCode = testGenerator.generateBasicTests(code: code, language: "Swift", testFramework: "XCTest")

        // Then test code should be generated
        XCTAssertFalse(testCode.isEmpty)
        XCTAssertTrue(testCode.contains("import XCTest"))
        XCTAssertTrue(testCode.contains("@testable import YourApp"))
        XCTAssertTrue(testCode.contains("class CodeTests: XCTestCase"))
        XCTAssertTrue(testCode.contains("func testExample()"))
        XCTAssertTrue(testCode.contains("XCTAssertTrue"))
    }

    func testGenerateBasicTests_UnsupportedLanguage() {
        // Given code in unsupported language
        let code = """
        function add(a, b) {
            return a + b;
        }
        """

        // When generating tests for unsupported language
        let testCode = testGenerator.generateBasicTests(code: code, language: "JavaScript", testFramework: "Jest")

        // Then empty test code should be returned
        XCTAssertTrue(testCode.isEmpty)
    }

    func testGenerateBasicTests_UnsupportedFramework() {
        // Given Swift code but unsupported framework
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When generating tests for unsupported framework
        let testCode = testGenerator.generateBasicTests(code: code, language: "Swift", testFramework: "Quick")

        // Then empty test code should be returned
        XCTAssertTrue(testCode.isEmpty)
    }

    func testGenerateBasicTests_EmptyCode() {
        // Given empty code
        let code = ""

        // When generating tests
        let testCode = testGenerator.generateBasicTests(code: code, language: "Swift", testFramework: "XCTest")

        // Then test code should still be generated (template)
        XCTAssertFalse(testCode.isEmpty)
        XCTAssertTrue(testCode.contains("XCTest"))
    }

    // MARK: - Coverage Estimation Tests

    func testEstimateTestCoverage_BasicEstimation() {
        // Given code and test code
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }

            func multiply(_ a: Int, _ b: Int) -> Int {
                return a * b
            }
        }
        """

        let testCode = """
        import XCTest
        @testable import YourApp

        class CalculatorTests: XCTestCase {
            func testAdd() {
                let calc = Calculator()
                XCTAssertEqual(calc.add(2, 3), 5)
            }

            func testMultiply() {
                let calc = Calculator()
                XCTAssertEqual(calc.multiply(2, 3), 6)
            }
        }
        """

        // When estimating coverage
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then coverage should be calculated
        XCTAssertGreaterThan(coverage, 0.0)
        XCTAssertLessThanOrEqual(coverage, 85.0) // Capped at 85%
    }

    func testEstimateTestCoverage_EmptyCode() {
        // Given empty code and some test code
        let code = ""
        let testCode = "import XCTest\nclass Test: XCTestCase {}"

        // When estimating coverage
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then coverage should be 85% (capped)
        XCTAssertEqual(coverage, 85.0)
    }

    func testEstimateTestCoverage_EmptyTestCode() {
        // Given code and empty test code
        let code = "class Test {}\nclass Test2 {}"
        let testCode = ""

        // When estimating coverage
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then coverage should be 0%
        XCTAssertEqual(coverage, 0.0)
    }

    func testEstimateTestCoverage_HighRatio() {
        // Given small code and large test code
        let code = "class Test {}"
        let testCode = String(repeating: "line\n", count: 100)

        // When estimating coverage
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then coverage should be capped at 85%
        XCTAssertEqual(coverage, 85.0)
    }

    func testEstimateTestCoverage_EqualLines() {
        // Given code and test code with equal line counts
        let code = "line1\nline2\nline3"
        let testCode = "test1\ntest2\ntest3"

        // When estimating coverage
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then coverage should be 100% (3/3 * 100, but capped at 85)
        XCTAssertEqual(coverage, 85.0)
    }

    func testEstimateTestCoverage_LowRatio() {
        // Given large code and small test code
        let code = String(repeating: "line\n", count: 100)
        let testCode = "test1\ntest2\ntest3"

        // When estimating coverage
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then coverage should be 3% (3/100 * 100)
        XCTAssertEqual(coverage, 3.0)
    }

    // MARK: - Integration Tests

    func testGenerateAndEstimateCoverage() {
        // Given code to test
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When generating tests and estimating coverage
        let testCode = testGenerator.generateBasicTests(code: code, language: "Swift", testFramework: "XCTest")
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then both operations should succeed
        XCTAssertFalse(testCode.isEmpty)
        XCTAssertGreaterThanOrEqual(coverage, 0.0)
        XCTAssertLessThanOrEqual(coverage, 85.0)
    }

    // MARK: - Edge Cases

    func testEstimateTestCoverage_NewlinesOnly() {
        // Given code with only newlines
        let code = "\n\n\n"
        let testCode = "test"

        // When estimating coverage
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then coverage should be calculated based on line count
        XCTAssertEqual(coverage, 33.0) // 1/3 * 100 = 33.33, rounded to 33
    }

    func testEstimateTestCoverage_SingleLine() {
        // Given single line code and test
        let code = "class Test {}"
        let testCode = "class TestCase: XCTestCase {}"

        // When estimating coverage
        let coverage = testGenerator.estimateTestCoverage(code: code, testCode: testCode)

        // Then coverage should be 100% (capped at 85)
        XCTAssertEqual(coverage, 85.0)
    }

    // MARK: - Test Code Content Validation

    func testGeneratedTestCode_Structure() {
        // Given any Swift code
        let code = "func test() {}"

        // When generating test code
        let testCode = testGenerator.generateBasicTests(code: code, language: "Swift", testFramework: "XCTest")

        // Then it should contain essential test structure elements
        XCTAssertTrue(testCode.contains("import XCTest"))
        XCTAssertTrue(testCode.contains("@testable import YourApp"))
        XCTAssertTrue(testCode.contains("class CodeTests: XCTestCase"))
        XCTAssertTrue(testCode.contains("func testExample()"))
        XCTAssertTrue(testCode.contains("XCTAssertTrue"))
        XCTAssertTrue(testCode.contains("placeholder test"))
    }

    func testGeneratedTestCode_IsValidSwift() {
        // Given any Swift code
        let code = "let x = 1"

        // When generating test code
        let testCode = testGenerator.generateBasicTests(code: code, language: "Swift", testFramework: "XCTest")

        // Then the generated code should be valid Swift (basic check)
        XCTAssertTrue(testCode.hasPrefix("import XCTest"))
        XCTAssertTrue(testCode.contains("XCTestCase"))

        // Should not contain syntax errors (basic validation)
        XCTAssertFalse(testCode.contains("}{"))
        XCTAssertFalse(testCode.contains(";;"))
    }
}
