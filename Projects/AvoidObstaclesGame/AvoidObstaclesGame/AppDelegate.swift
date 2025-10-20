//
//  AppDelegate.swift
//  AvoidObstaclesGame
//
//  Created by Daniel Stevens on 5/16/25.
//

#if os(iOS) || os(tvOS)
    import UIKit

    @main
    public class AppDelegate: UIResponder, UIApplicationDelegate {
        public var window: UIWindow?

        public func application(
            _: UIApplication,
            didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            // Override point for customization after application launch.
            true
        }

        public func applicationWillResignActive(_: UIApplication) {
            // Sent when the application is about to move from active to inactive state.
            // This can occur for certain types of temporary interruptions (such as an
            // incoming phone call or SMS message) or when the user quits the application
            // and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate
            // graphics rendering callbacks. Games should use this method to pause the game.
        }

        public func applicationDidEnterBackground(_: UIApplication) {
            // Use this method to release shared resources, save user data, invalidate timers,
            // and store enough application state information to restore your application to its
            // current state in case it is terminated later.
        }

        public func applicationWillEnterForeground(_: UIApplication) {
            // Called as part of the transition from the background to the active state;
            // here you can undo many of the changes made on entering the background.
        }

        public func applicationDidBecomeActive(_: UIApplication) {
            // Restart any tasks that were paused (or not yet started) while the application
            // was inactive. If the application was previously in the background, optionally
            // refresh the user interface.
        }
    }

#elseif os(macOS)
    import Cocoa
    import SpriteKit

    @main
    public class AppDelegate: NSObject, NSApplicationDelegate {
        public var window: NSWindow?
        public var gameViewController: GameViewController?

        public func applicationDidFinishLaunching(_ aNotification: Notification) {
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

        public func applicationWillTerminate(_ aNotification: Notification) {
            // Insert code here to tear down your application
        }

        public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            true
        }
    }
#endif
