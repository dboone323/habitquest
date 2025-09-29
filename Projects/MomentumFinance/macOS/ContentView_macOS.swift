// Momentum Finance - macOS-specific ContentView enhancements
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

extension ContentView {
    /// macOS-specific view modifiers and optimizations
    var macOSOptimizations: some View {
        frame(minWidth: 800, minHeight: 600)
            .preferredColorScheme(.automatic)
            .tint(.blue)
    }
}

#if os(macOS)
// macOS-specific UI components and helpers
enum macOSSpecificViews {
    /// macOS window configuration
    static func configureWindow() {
        // Configure macOS-specific window settings
        NSApp.appearance = NSAppearance(named: .aqua)
    }

    /// macOS toolbar configuration
    static func configureToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {}, label: {
                Image(systemName: "gear")
            })
            .help("Settings")

            Button(action: {}, label: {
                Image(systemName: "square.and.arrow.up")
            })
            .help("Export Data")
        }
    }
}

// macOS-specific view extensions
extension View {
    /// Add macOS-specific keyboard shortcuts
    /// <#Description#>
    /// - Returns: <#description#>
    func macOSKeyboardShortcuts() -> some View {
        keyboardShortcut("n", modifiers: .command)
            .keyboardShortcut("w", modifiers: .command)
    }

    /// macOS-specific sheet presentation
    /// <#Description#>
    /// - Returns: <#description#>
    func macOSSheetPresentation() -> some View {
        frame(width: 600, height: 400)
    }
}

// Settings view for macOS
struct SettingsView: View {
    @AppStorage("defaultCurrency")
    private var defaultCurrency = "USD"
    @AppStorage("enableNotifications")
    private var enableNotifications = true
    @AppStorage("autoBackup")
    private var autoBackup = false

    var body: some View {
        TabView {
            GeneralSettingsView(
                defaultCurrency: self.$defaultCurrency,
                enableNotifications: self.$enableNotifications,
                autoBackup: self.$autoBackup,
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }

            DataSettingsView()
                .tabItem {
                    Label("Data", systemImage: "externaldrive")
                }

            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 500, height: 300)
    }
}

struct GeneralSettingsView: View {
    @Binding var defaultCurrency: String
    @Binding var enableNotifications: Bool
    @Binding var autoBackup: Bool

    let currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD"]

    var body: some View {
        Form {
            Section("Currency") {
                Picker("Default Currency", selection: self.$defaultCurrency) {
                    ForEach(self.currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section("Notifications") {
                Toggle("Enable Notifications", isOn: self.$enableNotifications)
                    .help("Show notifications for upcoming subscriptions and budget alerts")
            }

            Section("Backup") {
                Toggle("Automatic Backup", isOn: self.$autoBackup)
                    .help("Automatically backup your data to iCloud")
            }
        }
        .padding()
    }
}

struct DataSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.headline)

            GroupBox("Export") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export your financial data to CSV or JSON format")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Button("Export to CSV").accessibilityLabel("Button").accessibilityLabel("Button") {
                            // Export functionality
                        }

                        Button("Export to JSON").accessibilityLabel("Button").accessibilityLabel("Button") {
                            // Export functionality
                        }
                    }
                }
            }

            GroupBox("Import") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Import transactions from bank statements or other apps")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Import Data").accessibilityLabel("Button").accessibilityLabel("Button") {
                        // Import functionality
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct AdvancedSettingsView: View {
    @AppStorage("enableDebugMode")
    private var enableDebugMode = false
    @AppStorage("logLevel")
    private var logLevel = "Info"

    let logLevels = ["Debug", "Info", "Warning", "Error"]

    var body: some View {
        Form {
            Section("Developer Options") {
                Toggle("Enable Debug Mode", isOn: self.$enableDebugMode)
                    .help("Enable debug logging and additional developer features")

                Picker("Log Level", selection: self.$logLevel) {
                    ForEach(self.logLevels, id: \.self) { level in
                        Text(level).tag(level)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .disabled(!self.enableDebugMode)
            }

            Section("Performance") {
                Button("Clear Cache").accessibilityLabel("Button").accessibilityLabel("Button") {
                    // Clear cache functionality
                }

                Button("Reset All Settings").accessibilityLabel("Button").accessibilityLabel("Button") {
                    // Reset settings functionality
                }
                .foregroundColor(.red)
            }
        }
        .padding()
    }
}
#endif
