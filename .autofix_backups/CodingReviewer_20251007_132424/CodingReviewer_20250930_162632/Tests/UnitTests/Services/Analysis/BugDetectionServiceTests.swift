@testable import CodingReviewer
import XCTest

final class BugDetectionServiceAdditionalBehaviorTests: XCTestCase {
    private var sut: BugDetectionService!

    override func setUp() {
        super.setUp()
        self.sut = BugDetectionService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDetectBasicBugsFlagsTodoAndDebugPrintIndependently() {
        let code = """
        // TODO: refactor
        print("debug")
        """

        let issues = self.sut.detectBasicBugs(code: code, language: "Swift")

        XCTAssertTrue(issues.contains { $0.description.contains("TODO") })
        XCTAssertTrue(issues.contains { $0.description.contains("Debug print") })
    }

    func testNonSwiftLanguageSkipsTodoInspection() {
        let code = """
        # TODO: fix shell script
        echo "debug"
        """

        let issues = self.sut.detectBasicBugs(code: code, language: "Bash")

        XCTAssertTrue(issues.isEmpty)
    }
}
