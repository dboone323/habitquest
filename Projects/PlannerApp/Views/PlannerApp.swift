// PlannerApp/MainApp/PlannerApp.swift (Updated)
import Foundation
import SwiftUI

@main
public struct PlannerApp: App {
    // Create and keep alive a single instance of ThemeManager for the entire app.
    // @StateObject ensures it persists throughout the app's lifecycle.
    // Only initialize ThemeManager when not running tests to avoid UserDefaults issues during testing
    @StateObject private var themeManager: ThemeManager = {
        // Check for test mode first - be more defensive
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        if isTesting {
            print("ThemeManager: Detected test mode, using testing initialization")
            return ThemeManager(testing: true)
        }
        print("ThemeManager: Normal initialization")
        return ThemeManager()
    }()

    // State variable to hold the tag of the currently selected tab.
    // This is needed to programmatically set the initial tab based on user settings.
    @State private var selectedTabTag: String

    // Custom initializer to read the default view setting from UserDefaults
    // *before* the main body view is created. This ensures the correct tab
    // is selected right from the start.
    public init() {
        // Check for test mode first - be more defensive
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        if isTesting {
            // Use Dashboard as default during testing
            _selectedTabTag = State(initialValue: MainTabView.TabTags.dashboard)
            print("App init: Test mode detected, using dashboard tab") // Debugging log
            return
        }

        // Read the saved default view identifier from UserDefaults.
        let initialTab = UserDefaults.standard.string(forKey: AppSettingKeys.defaultView)
            // Use the Dashboard tag as a fallback if nothing is saved.
            ?? MainTabView.TabTags.dashboard
        // Initialize the @State variable with the value read from UserDefaults.
        // The underscore syntax is used here because we are initializing the State wrapper itself.
        _selectedTabTag = State(initialValue: initialTab)
        print("App init: Normal mode, initial tab set to: \(initialTab)") // Debugging log
    }

    public var body: some Scene {
        // Check for test mode and return empty scene to prevent UI initialization during testing
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

        return WindowGroup {
            if isTesting {
                // Return empty view during testing to prevent crashes
                EmptyView()
            } else {
                // Apply the primary background color from the current theme to the entire window group.
                self.themeManager.currentTheme.primaryBackgroundColor
                    .ignoresSafeArea()
                    .overlay(
                        // Use enhanced navigation for better cross-platform UX
                        MainTabView(selectedTabTag: self.$selectedTabTag)
                    )
                    .environmentObject(self.themeManager)
            }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
}
