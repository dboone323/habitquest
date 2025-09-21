import Cocoa
import os

class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger(subsystem: "com.quantum.codingreviewer", category: "AppDelegate")

    func applicationDidFinishLaunching(_: Notification) {
        self.logger.info("CodingReviewer application did finish launching")
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_: Notification) {
        self.logger.info("CodingReviewer application will terminate")
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        true
    }
}
