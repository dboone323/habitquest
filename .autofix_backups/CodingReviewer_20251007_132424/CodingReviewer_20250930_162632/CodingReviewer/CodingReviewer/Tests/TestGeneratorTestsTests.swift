@testable import CodingReviewer
import XCTest

final class TestGeneratorAdditionalTests: XCTestCase {
    private var sut: TestGenerator!

    override func setUp() {
        super.setUp()
        self.sut = TestGenerator()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testGenerateBasicTestsReturnsEmptyForUnsupportedLanguage() {
        let code = "class Example {}"

        let testCode = self.sut.generateBasicTests(code: code, language: "Kotlin", testFramework: "JUnit")

        XCTAssertTrue(testCode.isEmpty)
    }

    func testCoverageIsCappedAtEightyFivePercentEvenWithHighRatio() {
        let code = String(repeating: "line\n", count: 5)
        let generatedTests = String(repeating: "test\n", count: 20)

        let coverage = self.sut.estimateTestCoverage(code: code, testCode: generatedTests)

        XCTAssertEqual(coverage, 85.0)
    }
}
