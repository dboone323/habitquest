// filepath: /Users/danielstevens/Desktop/PlannerApp/Views/Settings/SettingsView.swift
// PlannerApp/Views/Settings/SettingsView.swift

import LocalAuthentication
import SwiftUI
import UserNotifications
#if os(macOS)
import AppKit
#endif
import Foundation

public struct SettingsView: View {
    // Import ThemeManager properly
    @EnvironmentObject var themeManager: ThemeManager

    // State properties with AppStorage keys - avoid during testing
    @State private var userName: String = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? "" :
        UserDefaults.standard.string(forKey: AppSettingKeys.userName) ?? ""
    @State private var dashboardItemLimit: Int = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? 3 :
        UserDefaults.standard.integer(forKey: AppSettingKeys.dashboardItemLimit)
    @State private var notificationsEnabled: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? true :
        UserDefaults.standard.bool(forKey: AppSettingKeys.notificationsEnabled)
    @State private var use24HourTime: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? false :
        UserDefaults.standard.bool(forKey: AppSettingKeys.use24HourTime)
    @State private var autoDeleteCompleted: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? false :
        UserDefaults.standard.bool(forKey: AppSettingKeys.autoDeleteCompleted)
    @State private var journalBiometricsEnabled: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? false :
        UserDefaults.standard.bool(forKey: AppSettingKeys.journalBiometricsEnabled)
    @State private var autoSyncEnabled: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? true :
        UserDefaults.standard.bool(forKey: AppSettingKeys.autoSyncEnabled)
    @State private var enableHapticFeedback: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? true :
        UserDefaults.standard.bool(forKey: AppSettingKeys.enableHapticFeedback)
    @State private var enableAnalytics: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? false :
        UserDefaults.standard.bool(forKey: AppSettingKeys.enableAnalytics)
    @State private var firstDayOfWeek: Int = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? Calendar.current.firstWeekday :
        UserDefaults.standard.integer(forKey: AppSettingKeys.firstDayOfWeek)
    @State private var defaultReminderTime: Int = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? 900 :
        UserDefaults.standard.integer(forKey: AppSettingKeys.defaultReminderTime)
    @State private var defaultView: String = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? "Dashboard" :
        UserDefaults.standard.string(forKey: AppSettingKeys.defaultView) ?? "Dashboard"
    @State private var autoDeleteDays: Int = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? 7 :
        UserDefaults.standard.integer(forKey: AppSettingKeys.autoDeleteDays)
    @State private var syncFrequency: String = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? "hourly" :
        UserDefaults.standard.string(forKey: AppSettingKeys.syncFrequency) ?? "hourly"

    // State for managing UI elements
    @State private var showingNotificationAlert = false
    @State private var showingClearDataConfirmation = false
    @State private var showingExportShareSheet = false
    @State private var exportURL: URL?
    @State private var showingCloudKitSheet = false
    @State private var showingThemePreview = false

    // Computed properties
    private var canUseBiometrics: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    private let reminderTimeOptions: [String: Int] = [
        "5 minutes": 300,
        "15 minutes": 900,
        "30 minutes": 1800,
        "1 hour": 3600,
        "1 day": 86400,
    ]

    private var sortedReminderKeys: [String] {
        self.reminderTimeOptions.keys.sorted { self.reminderTimeOptions[$0]! < self.reminderTimeOptions[$1]! }
    }

    private let defaultViewOptions = ["Dashboard", "Tasks", "Calendar", "Goals", "Journal"]

    var body: some View {
        NavigationStack {
            Form {
                // Profile Section
                Section("Profile") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your Name", text: self.$userName).accessibilityLabel("Text Field").accessibilityLabel("Text Field")
                            .multilineTextAlignment(.trailing)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Appearance Section
                Section("Appearance") {
                    Picker("Theme", selection: self.$themeManager.currentThemeName) {
                        ForEach(Theme.availableThemes, id: \.name) { theme in
                            Text(theme.name).tag(theme.name)
                        }
                    }
                    .pickerStyle(.menu)

                    Button(action: { self.showingThemePreview = true }).accessibilityLabel("Button").accessibilityLabel("Button") {
                        HStack {
                            Text("Theme Preview")
                                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                            Spacer()
                            Circle()
                                .fill(self.themeManager.currentTheme.primaryAccentColor)
                                .frame(width: 20, height: 20)
                            Image(systemName: "chevron.right")
                                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Dashboard Section
                Section("Dashboard") {
                    Stepper("Items per section: \(self.dashboardItemLimit)", value: self.$dashboardItemLimit, in: 1 ... 10)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Reminders", isOn: self.$notificationsEnabled)
                        .onChange(of: self.notificationsEnabled) { _, newValue in
                            self.handleNotificationToggle(enabled: newValue)
                        }

                    Picker("Default Reminder", selection: self.$defaultReminderTime) {
                        ForEach(self.sortedReminderKeys, id: \.self) { key in
                            Text(key).tag(self.reminderTimeOptions[key]!)
                        }
                    }
                    .disabled(!self.notificationsEnabled)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Date & Time Section
                Section("Date & Time") {
                    Picker("First Day of Week", selection: self.$firstDayOfWeek) {
                        Text("System Default").tag(Calendar.current.firstWeekday)
                        Text("Sunday").tag(1)
                        Text("Monday").tag(2)
                    }

                    Toggle("Use 24-Hour Time", isOn: self.$use24HourTime)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // App Behavior Section
                Section("App Behavior") {
                    Picker("Default View on Launch", selection: self.$defaultView) {
                        ForEach(self.defaultViewOptions, id: \.self) { viewName in
                            Text(viewName).tag(viewName)
                        }
                    }

                    Toggle("Auto-Delete Completed Tasks", isOn: self.$autoDeleteCompleted)

                    if self.autoDeleteCompleted {
                        Stepper("Delete after: \(self.autoDeleteDays) days", value: self.$autoDeleteDays, in: 1 ... 90)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Security Section
                Section("Security") {
                    if self.canUseBiometrics {
                        Toggle("Protect Journal with Biometrics", isOn: self.$journalBiometricsEnabled)
                    } else {
                        Text("Biometric authentication not available on this device.")
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Sync & Cloud Section
                Section("Sync & Cloud") {
                    Button(action: { self.showingCloudKitSheet = true }).accessibilityLabel("Button").accessibilityLabel("Button") {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.blue)
                            Text("iCloud Sync")
                                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                        }
                    }

                    Toggle("Auto Sync", isOn: self.$autoSyncEnabled)

                    Picker("Sync Frequency", selection: self.$syncFrequency) {
                        Text("Every 15 minutes").tag("15min")
                        Text("Hourly").tag("hourly")
                        Text("Daily").tag("daily")
                        Text("Manual only").tag("manual")
                    }
                    .disabled(!self.autoSyncEnabled)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Enhanced Features Section
                Section("Enhanced Features") {
                    Toggle("Haptic Feedback", isOn: self.$enableHapticFeedback)
                    Toggle("Enable Analytics", isOn: self.$enableAnalytics)

                    if self.enableAnalytics {
                        Text("Help improve PlannerApp by sharing anonymous usage data.")
                            .font(.caption)
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Data Management Section
                Section("Data Management") {
                    Button("Export Data", action: self.exportData).accessibilityLabel("Button").accessibilityLabel("Button")
                        .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)

                    Button("Clear Old Completed Tasks...", action: { self.showingClearDataConfirmation = true })
                        .accessibilityLabel("Button")
                        .accessibilityLabel("Button")
                        .foregroundColor(self.themeManager.currentTheme.destructiveColor)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // About Section
                Section("About") {
                    HStack {
                        Text("App Version")
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                        Spacer()
                        Text(Bundle.main.appVersion ?? "N/A")
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
            }
            .navigationTitle("Settings")
            .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
            .accentColor(self.themeManager.currentTheme.primaryAccentColor)
            .sheet(isPresented: self.$showingCloudKitSheet) {
                CloudKitSettingsView()
            }
            .sheet(isPresented: self.$showingThemePreview) {
                ThemePreviewSheet()
                    .environmentObject(self.themeManager)
            }
            .alert("Notification Permissions", isPresented: self.$showingNotificationAlert) {
                Button("Open Settings", action: self.openAppSettings).accessibilityLabel("Button").accessibilityLabel("Button")
                Button("Cancel", role: .cancel).accessibilityLabel("Button").accessibilityLabel("Button") {}
            } message: {
                Text("Enable notifications in Settings to receive reminders.")
            }
            .alert("Confirm Deletion", isPresented: self.$showingClearDataConfirmation) {
                Button("Delete", role: .destructive, action: self.performClearOldData).accessibilityLabel("Button")
                    .accessibilityLabel("Button")
                Button("Cancel", role: .cancel).accessibilityLabel("Button").accessibilityLabel("Button") {}
            } message: {
                Text(
                    "Are you sure you want to permanently delete completed tasks older than \(self.autoDeleteDays) days? This cannot be undone."
                )
            }
        }
        .accentColor(self.themeManager.currentTheme.primaryAccentColor)
    }

    // MARK: - Action Handlers

    func handleNotificationToggle(enabled: Bool) {
        if enabled {
            self.requestNotificationPermission()
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    self.showingNotificationAlert = true
                    self.notificationsEnabled = false
                }
                if error != nil {
                    self.notificationsEnabled = false
                }
            }
        }
    }

    func openAppSettings() {
        #if os(iOS)
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!)
        #endif
    }

    func exportData() {
        let csvString = "Type,ID,Title\nSample,1,Test Data\n"
        guard let data = csvString.data(using: .utf8) else { return }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PlannerExport.csv")
        do {
            try data.write(to: tempURL, options: .atomic)
            self.exportURL = tempURL
            self.showingExportShareSheet = true
        } catch {
            print("Failed to write export file: \(error)")
        }
    }

    func performClearOldData() {
        // Implementation for clearing old data
        print("Clearing old data...")
    }
}

// MARK: - CloudKit Settings View

public struct CloudKitSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("CloudKit Sync")
                    .font(.title)
                    .padding()
                Text("CloudKit integration coming soon...")
                    .foregroundColor(.secondary)
                Button("Done").accessibilityLabel("Button").accessibilityLabel("Button") {
                    self.dismiss()
                }
                .padding()
            }
            .frame(minWidth: 400, minHeight: 300)
        }
    }
}

// MARK: - Theme Preview Sheet

public struct ThemePreviewSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Theme.availableThemes, id: \.name) { theme in
                        ThemeCard(theme: theme, isSelected: theme.name == self.themeManager.currentTheme.name) {
                            self.themeManager.setTheme(theme)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Theme Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.dismiss()
                    }
                }
            }
            .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
        }
    }
}

// MARK: - Theme Card

public struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: self.onTap).accessibilityLabel("Button").accessibilityLabel("Button") {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(self.theme.primaryAccentColor)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(self.theme.secondaryAccentColor)
                        .frame(width: 16, height: 16)
                    Spacer()
                }

                Text(self.theme.name)
                    .font(.headline)
                    .foregroundColor(self.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Sample text")
                    .font(.caption)
                    .foregroundColor(self.theme.secondaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(self.theme.secondaryBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(self.isSelected ? self.theme.primaryAccentColor : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

// MARK: - Preview

public struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager())
    }
}
