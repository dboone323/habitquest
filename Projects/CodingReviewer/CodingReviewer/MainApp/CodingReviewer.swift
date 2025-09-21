//
//  CodingReviewer.swift
//  CodingReviewer
//
//  Main SwiftUI application for CodingReviewer
//

import SwiftUI
import os

@main
struct CodingReviewer: App {
    private let logger = Logger(subsystem: "com.quantum.codingreviewer", category: "CodingReviewerApp")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            // Add standard menu commands
            CommandGroup(replacing: .newItem) {
                Button("New Review") {
                    // TODO: Implement new review action
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandGroup(replacing: .saveItem) {
                Button("Save Review") {
                    // TODO: Implement save review action
                }
                .keyboardShortcut("s", modifiers: .command)
            }

            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About CodingReviewer") {
                    // TODO: Show about window
                }
            }
        }
    }

    init() {
        logger.info("CodingReviewer application initialized")
    }
}
