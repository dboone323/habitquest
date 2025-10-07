@testable import CodingReviewer
import XCTest

final class CodeStyleDescriptionTests: XCTestCase {
    func testDescriptionsMatchDocumentation() {
        XCTAssertEqual(CodeStyle.production.description, "production-ready with full error handling and documentation")
        XCTAssertEqual(CodeStyle.prototype.description, "prototype/experimental with basic structure")
        XCTAssertEqual(CodeStyle.educational.description, "educational with detailed comments and explanations")
    }
}

final class AITaskDescriptionTests: XCTestCase {
    func testDocumentationTypeDescriptions() {
        XCTAssertEqual(DocumentationType.comprehensive.description, "comprehensive")
        XCTAssertEqual(DocumentationType.api.description, "API-focused")
        XCTAssertEqual(DocumentationType.inline.description, "inline")
    }

    func testTestTypeDescriptions() {
        XCTAssertEqual(TestType.unit.description, "unit")
        XCTAssertEqual(TestType.integration.description, "integration")
        XCTAssertEqual(TestType.performance.description, "performance")
    }

    func testReviewTypeDescriptions() {
        XCTAssertEqual(ReviewType.comprehensive.description, "comprehensive")
        XCTAssertEqual(ReviewType.security.description, "security-focused")
        XCTAssertEqual(ReviewType.performance.description, "performance-focused")
        XCTAssertEqual(ReviewType.style.description, "style and convention")
    }
}
