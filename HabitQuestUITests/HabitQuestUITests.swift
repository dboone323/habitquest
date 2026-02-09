import XCTest

final class HabitQuestUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        // Take a screenshot
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)

        XCTAssertNotNil(screenshot)
    }
}
