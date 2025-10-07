//
// AppDelegateTests.swift
// AI-generated test template
//

import AppKit
@testable import CodingReviewer
import XCTest

class AppDelegateTests: XCTestCase {
    private var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        self.appDelegate = AppDelegate()
    }

    override func tearDown() {
        self.appDelegate = nil
        super.tearDown()
    }

    func testApplicationSupportsSecureRestorableState() {
        let supportsRestoration = self.appDelegate.applicationSupportsSecureRestorableState(NSApplication.shared)
        XCTAssertTrue(supportsRestoration)
    }

    func testLifecycleCallbacksDoNotCrash() {
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        XCTAssertNoThrow(self.appDelegate.applicationDidFinishLaunching(notification))
        XCTAssertNoThrow(self.appDelegate.applicationWillTerminate(notification))
    }
}
