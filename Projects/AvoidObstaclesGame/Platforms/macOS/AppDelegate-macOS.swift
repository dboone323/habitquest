//
//  AppDelegate-macOS.swift
//  AvoidObstaclesGame-macOS
//
//  Created by Daniel on 2025-01-19.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Cocoa
import SpriteKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?
    var gameViewController: GameViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the main window
        let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        window = NSWindow(contentRect: screenRect,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: false)

        window?.title = "Avoid Obstacles Game"
        window?.center()

        // Create the game view controller
        gameViewController = GameViewController()

        // Set up the SKView
        if let gameVC = gameViewController {
            window?.contentViewController = gameVC
        }

        window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
