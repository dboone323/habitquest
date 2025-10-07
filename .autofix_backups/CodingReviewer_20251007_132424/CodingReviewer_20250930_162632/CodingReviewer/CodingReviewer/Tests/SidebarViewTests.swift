@testable import CodingReviewer
import SwiftUI
import XCTest

final class SidebarViewPresenterTests: XCTestCase {
    private var presenter: SidebarViewPresenter!

    override func setUp() {
        super.setUp()
        self.presenter = SidebarViewPresenter()
    }

    override func tearDown() {
        self.presenter = nil
        super.tearDown()
    }

    func testOpenFileActionUpdatesBinding() {
        var showFilePicker = false
        let binding = Binding(get: { showFilePicker }, set: { showFilePicker = $0 })

        let action = self.presenter.openFileAction(binding: binding)
        action()

        XCTAssertTrue(showFilePicker)
    }

    func testSetViewActionChangesCurrentView() {
        var currentView: ContentViewType = .analysis
        let binding = Binding(get: { currentView }, set: { currentView = $0 })

        let action = self.presenter.setViewAction(binding: binding, target: .documentation)
        action()

        XCTAssertEqual(currentView, .documentation)
    }

    func testPreferencesActionIsSafeToInvoke() {
        let action = self.presenter.preferencesAction()

        XCTAssertNoThrow(action())
    }
}
