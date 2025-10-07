@testable import CodingReviewer
import XCTest

@MainActor
final class CodeReviewServiceDocumentationTests: XCTestCase {
    private var sut: CodeReviewService!

    override func setUp() {
        super.setUp()
        self.sut = CodeReviewService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testGenerateDocumentationReturnsRequestedLanguageAndExamples() async throws {
        let result = try await sut.generateDocumentation("struct A {}", language: "Swift", includeExamples: true)

        XCTAssertEqual(result.language, "Swift")
        XCTAssertTrue(result.includesExamples)
        XCTAssertFalse(result.documentation.isEmpty)
    }

    func testGenerateTestsProducesCoverageEstimate() async throws {
        let result = try await sut.generateTests("struct B { func run() {} }", language: "Swift", testFramework: "XCTest")

        XCTAssertEqual(result.language, "Swift")
        XCTAssertEqual(result.testFramework, "XCTest")
        XCTAssertGreaterThanOrEqual(result.estimatedCoverage, 0)
        XCTAssertLessThanOrEqual(result.estimatedCoverage, 100)
    }
}
