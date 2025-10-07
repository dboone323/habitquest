@testable import CodingReviewer
import XCTest

final class DocumentationResultsPresenterTests: XCTestCase {
    private var presenter: DocumentationResultsPresenter!
    private var result: DocumentationResult!

    override func setUp() {
        super.setUp()
        self.result = DocumentationResult(
            documentation: "# Summary\nDetails",
            language: "Swift",
            includesExamples: true
        )
        self.presenter = DocumentationResultsPresenter(result: self.result)
    }

    override func tearDown() {
        self.presenter = nil
        self.result = nil
        super.tearDown()
    }

    func testLanguageLabelReflectsResultLanguage() {
        XCTAssertEqual(self.presenter.languageLabel, "Language: Swift")
    }

    func testExamplesBadgePresentWhenExamplesIncluded() {
        XCTAssertEqual(self.presenter.examplesBadge, "Includes examples")
    }

    func testExamplesBadgeOmittedWhenNotAvailable() {
        let otherResult = DocumentationResult(documentation: "Doc", language: "Swift", includesExamples: false)
        let presenter = DocumentationResultsPresenter(result: otherResult)

        XCTAssertNil(presenter.examplesBadge)
    }
}
