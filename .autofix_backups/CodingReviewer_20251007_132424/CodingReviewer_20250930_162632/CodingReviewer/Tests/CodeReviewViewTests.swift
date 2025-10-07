@testable import CodingReviewer
import XCTest

final class ResultsPanelPresenterTests: XCTestCase {
    func testTitleMatchesSelectedView() {
        let analysisPresenter = ResultsPanelPresenter(currentView: .analysis, isAnalyzing: false)
        let documentationPresenter = ResultsPanelPresenter(currentView: .documentation, isAnalyzing: false)
        let testsPresenter = ResultsPanelPresenter(currentView: .tests, isAnalyzing: false)

        XCTAssertEqual(analysisPresenter.title, "Analysis Results")
        XCTAssertEqual(documentationPresenter.title, "Documentation")
        XCTAssertEqual(testsPresenter.title, "Generated Tests")
    }

    func testEmptyStateMessageRespectsCurrentView() {
        let presenter = ResultsPanelPresenter(currentView: .analysis, isAnalyzing: false)

        XCTAssertEqual(presenter.emptyStateMessage(hasResult: false), "Click Analyze to start code analysis")
        XCTAssertNil(presenter.emptyStateMessage(hasResult: true))
    }

    func testEmptyStateMessageSuppressesWhileAnalyzing() {
        let presenter = ResultsPanelPresenter(currentView: .tests, isAnalyzing: true)

        XCTAssertNil(presenter.emptyStateMessage(hasResult: false))
    }
}
