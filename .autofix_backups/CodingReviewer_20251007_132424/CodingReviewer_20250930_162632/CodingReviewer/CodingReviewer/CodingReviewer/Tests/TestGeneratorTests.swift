//
// TestGeneratorTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

class TestGeneratorTests: XCTestCase {
    private var sut: TestGenerator!

    override func setUp() {
        super.setUp()
        self.sut = TestGenerator()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testGeneratesSwiftXCTestTemplate() {
        let code = "struct Example {}"

        let testCode = self.sut.generateBasicTests(code: code, language: "Swift", testFramework: "XCTest")

        XCTAssertFalse(testCode.isEmpty)
        XCTAssertTrue(testCode.contains("class CodeTests"))
    }

    func testReturnsEmptyStringForUnsupportedFramework() {
        let code = "struct Example {}"

        let testCode = self.sut.generateBasicTests(code: code, language: "Swift", testFramework: "Quick")

        XCTAssertTrue(testCode.isEmpty)
    }

    func testCoverageCalculationCapsAtEightyFivePercent() {
        let code = """
        struct Example {
            func run() {}
        }
        """
        let generatedTests = String(repeating: "line\n", count: 20)

        let coverage = self.sut.estimateTestCoverage(code: code, testCode: generatedTests)

        XCTAssertEqual(coverage, 85.0)
    }

    func testCoverageIsZeroWhenNoTests() {
        let code = "struct Example { func run() {} }"

        let coverage = self.sut.estimateTestCoverage(code: code, testCode: "")

        XCTAssertEqual(coverage, 0.0)
    }
}
