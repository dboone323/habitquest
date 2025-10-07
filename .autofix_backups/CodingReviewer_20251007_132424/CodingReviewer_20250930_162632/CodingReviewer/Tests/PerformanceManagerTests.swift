@testable import CodingReviewer
import XCTest

final class PerformanceManagerTests: XCTestCase {
    private var sut: PerformanceManager!

    override func setUp() {
        super.setUp()
        self.sut = PerformanceManager.shared
    }

    func testGetCurrentFPSWithoutFramesReturnsZero() {
        XCTAssertEqual(self.sut.getCurrentFPS(), 0)
    }

    func testRecordingFramesProducesPositiveFPS() {
        for _ in 0 ..< 12 {
            self.sut.recordFrame()
            usleep(10000) // roughly 100 FPS
        }

        let fps = self.sut.getCurrentFPS()

        XCTAssertGreaterThan(fps, 0)
    }

    func testAsyncFPSMatchesSynchronousResult() {
        let expectation = expectation(description: "Async FPS callback")

        for _ in 0 ..< 12 {
            self.sut.recordFrame()
            usleep(8000)
        }

        let synchronous = self.sut.getCurrentFPS()

        self.sut.getCurrentFPS { asyncValue in
            XCTAssertEqual(asyncValue, synchronous, accuracy: 0.5)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMemoryUsageAccessIsNonNegative() {
        XCTAssertGreaterThanOrEqual(self.sut.getMemoryUsage(), 0)

        let expectation = expectation(description: "Async memory usage")

        self.sut.getMemoryUsage { value in
            XCTAssertGreaterThanOrEqual(value, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
