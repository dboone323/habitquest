@testable import CodingReviewer
import SwiftUI
import XCTest

final class WelcomeViewPresenterTests: XCTestCase {
    private var presenter: WelcomeViewPresenter!

    override func setUp() {
        super.setUp()
        self.presenter = WelcomeViewPresenter()
    }

    override func tearDown() {
        self.presenter = nil
        super.tearDown()
    }

    func testOpenFileActionSetsBindingToTrue() {
        var value = false
        let binding = Binding(get: { value }, set: { value = $0 })

        let action = self.presenter.openFileAction(binding: binding)
        action()

        XCTAssertTrue(value)
    }

    func testOpenFileActionIsIdempotent() {
        var value = false
        let binding = Binding(get: { value }, set: { value = $0 })

        let action = self.presenter.openFileAction(binding: binding)
        action()
        action()

        XCTAssertTrue(value, "Value should remain true after repeated invocations")
    }
}
