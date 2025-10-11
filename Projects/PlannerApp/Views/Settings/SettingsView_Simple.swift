// PlannerApp/Views/Settings/SettingsView.swift
// Simplified version for compilation

import LocalAuthentication
import SwiftUI
import UserNotifications
#if os(macOS)
import AppKit
#endif
import Foundation

public struct SettingsView: View {
    // Environment Object to access the shared ThemeManager instance
    @EnvironmentObject var themeManager: ThemeManager

    // Avoid @AppStorage during testing to prevent UserDefaults access crashes
    @State private var userName: String = ""
    @State private var dashboardItemLimit: Int = 3
    @State private var selectedThemeName: String = Theme.defaultTheme.name
    @State private var notificationsEnabled: Bool = true
    @State private var defaultReminderTime: Double = 3600
    @State private var firstDayOfWeek: Int = Calendar.current.firstWeekday
    @State private var use24HourTime: Bool = false
    @State private var autoDeleteCompleted: Bool = false
    @State private var autoDeleteDays: Int = 30
    @State private var defaultView: String = "Dashboard"
    @State private var journalBiometricsEnabled: Bool = false
    @State private var autoSyncEnabled: Bool = true
    @State private var syncFrequency: String = "hourly"
    @State private var enableHapticFeedback: Bool = true
    @State private var enableAnalytics: Bool = false

    // Initialize settings from UserDefaults, but skip during testing
    private func initializeSettings() {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

        if !isTesting {
            userName = UserDefaults.standard.string(forKey: AppSettingKeys.userName) ?? ""
            dashboardItemLimit = UserDefaults.standard.integer(forKey: AppSettingKeys.dashboardItemLimit)
            if dashboardItemLimit == 0 { dashboardItemLimit = 3 }
            selectedThemeName = UserDefaults.standard.string(forKey: AppSettingKeys.themeColorName) ?? Theme.defaultTheme.name
            notificationsEnabled = UserDefaults.standard.bool(forKey: AppSettingKeys.notificationsEnabled)
            if !UserDefaults.standard.bool(forKey: "notificationsEnabled_set") { notificationsEnabled = true }
            defaultReminderTime = UserDefaults.standard.double(forKey: AppSettingKeys.defaultReminderTime)
            if defaultReminderTime == 0 { defaultReminderTime = 3600 }
            firstDayOfWeek = UserDefaults.standard.integer(forKey: AppSettingKeys.firstDayOfWeek)
            if firstDayOfWeek == 0 { firstDayOfWeek = Calendar.current.firstWeekday }
            use24HourTime = UserDefaults.standard.bool(forKey: AppSettingKeys.use24HourTime)
            autoDeleteCompleted = UserDefaults.standard.bool(forKey: AppSettingKeys.autoDeleteCompleted)
            autoDeleteDays = UserDefaults.standard.integer(forKey: AppSettingKeys.autoDeleteDays)
            if autoDeleteDays == 0 { autoDeleteDays = 30 }
            defaultView = UserDefaults.standard.string(forKey: AppSettingKeys.defaultView) ?? "Dashboard"
            journalBiometricsEnabled = UserDefaults.standard.bool(forKey: AppSettingKeys.journalBiometricsEnabled)
            autoSyncEnabled = UserDefaults.standard.bool(forKey: AppSettingKeys.autoSyncEnabled)
            if !UserDefaults.standard.bool(forKey: "autoSyncEnabled_set") { autoSyncEnabled = true }
            syncFrequency = UserDefaults.standard.string(forKey: AppSettingKeys.syncFrequency) ?? "hourly"
            enableHapticFeedback = UserDefaults.standard.bool(forKey: AppSettingKeys.enableHapticFeedback)
            if !UserDefaults.standard.bool(forKey: "enableHapticFeedback_set") { enableHapticFeedback = true }
            enableAnalytics = UserDefaults.standard.bool(forKey: AppSettingKeys.enableAnalytics)
        }
    }

    // --- State for managing UI elements ---
    @State private var showingNotificationAlert = false
    @State private var showingClearDataConfirmation = false
    @State private var showingExportShareSheet = false
    @State private var exportURL: URL?
    @State private var showingCloudKitSheet = false
    @State private var showingThemePreview = false

    // --- Options for Pickers ---
    let reminderTimeOptions: [String: Double] = [
        "None": 0, "At time of event": 1, "5 minutes before": 300,
        "15 minutes before": 900, "30 minutes before": 1800, "1 hour before": 3600,
        "1 day before": 86400,
    ]

    var sortedReminderKeys: [String] {
        self.reminderTimeOptions.keys.sorted { self.reminderTimeOptions[$0]! < self.reminderTimeOptions[$1]! }
    }

    let defaultViewOptions = ["Dashboard", "Tasks", "Calendar", "Goals", "Journal"]

    // --- Biometric Check ---
    var canUseBiometrics: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

        NavigationStack {
            Form {
                // --- Profile Section ---
                Section("Profile") {
                    HStack {
                        Text("Name")
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                        TextField("Enter your name", text: self.$userName).accessibilityLabel("Text Field").accessibilityLabel("Text Field")
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // --- Appearance Section ---
                Section("Appearance") {
                    Picker("Theme", selection: self.$selectedThemeName) {
                        ForEach(ThemeManager.availableThemeNames, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }

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
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // --- Dashboard Section ---
                Section("Dashboard") {
                    Stepper("Items per section: \\(dashboardItemLimit)", value: self.$dashboardItemLimit, in: 1 ... 10)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // --- Notifications Section ---
                Section("Notifications") {
                    Toggle("Enable Reminders", isOn: self.$notificationsEnabled)
                        .onChange(of: self.notificationsEnabled) { _, newValue in
                            self.handleNotificationToggle(enabled: newValue)
                        }
                        .alert(
                            "Notification Permissions",
                            isPresented: self.$showingNotificationAlert,
                            actions: self.notificationAlertActions
                        )

                    Picker("Default Reminder", selection: self.$defaultReminderTime) {
                        ForEach(self.sortedReminderKeys, id: \.self) { key in
                            Text(key).tag(self.reminderTimeOptions[key]!)
                        }
                    }
                    .disabled(!self.notificationsEnabled)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // --- Date & Time Section ---
                Section("Date & Time") {
                    Picker("First Day of Week", selection: self.$firstDayOfWeek) {
                        Text("System Default").tag(Calendar.current.firstWeekday)
                        Text("Sunday").tag(1)
                        Text("Monday").tag(2)
                    }

                    Toggle("Use 24-Hour Time", isOn: self.$use24HourTime)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // --- App Behavior Section ---
                Section("App Behavior") {
                    Picker("Default View on Launch", selection: self.$defaultView) {
                        ForEach(self.defaultViewOptions, id: \.self) { viewName in
                            Text(viewName).tag(viewName)
                        }
                    }

                    Toggle("Auto-Delete Completed Tasks", isOn: self.$autoDeleteCompleted)

                    if self.autoDeleteCompleted {
                        Stepper("Delete after: \\(autoDeleteDays) days", value: self.$autoDeleteDays, in: 1 ... 90)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // --- Security Section ---
                Section("Security") {
                    if self.canUseBiometrics {
                        Toggle("Protect Journal with Biometrics", isOn: self.$journalBiometricsEnabled)
                    } else {
                        Text("Biometric authentication not available on this device.")
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // --- Sync & Cloud Section ---
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

                // --- Enhanced Features Section ---
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

                // --- Data Management Section ---
                Section("Data Management") {
                    Button("Export Data", action: self.exportData).accessibilityLabel("Button").accessibilityLabel("Button")
                        .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)

                    Button("Clear Old Completed Tasks...", action: { self.showingClearDataConfirmation = true })
                        .accessibilityLabel("Button")
                        .accessibilityLabel("Button")
                        .foregroundColor(self.themeManager.currentTheme.destructiveColor)
                        .alert("Confirm Deletion", isPresented: self.$showingClearDataConfirmation) {
                            Button("Delete", role: .destructive, action: self.performClearOldData).accessibilityLabel("Button")
                                .accessibilityLabel("Button")
                            Button("Cancel", role: .cancel).accessibilityLabel("Button").accessibilityLabel("Button") {}
                        } message: {
                            Text(
                                "Are you sure you want to permanently delete completed tasks older than \\(autoDeleteDays) days? This cannot be undone."
                            )
                        }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // --- About Section ---
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
            .onAppear(perform: self.initializeSettings)
            // Simplified sheet presentations
            .sheet(isPresented: self.$showingCloudKitSheet) {
                // Placeholder for CloudKit sync view
                VStack {
                    Text("CloudKit Sync")
                        .font(.title)
                        .padding()
                    Text("CloudKit integration coming soon...")
                        .foregroundColor(.secondary)
                    Button("Done").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.showingCloudKitSheet = false
                    }
                    .padding()
                }
                .frame(minWidth: 400, minHeight: 300)
            }
            .sheet(isPresented: self.$showingThemePreview) {
                // Placeholder for theme preview
                VStack {
                    Text("Theme Preview")
                        .font(.title)
                        .padding()
                    Text("Theme preview coming soon...")
                        .foregroundColor(.secondary)
                    Button("Done").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.showingThemePreview = false
                    }
                    .padding()
                }
                .frame(minWidth: 400, minHeight: 300)
            }
        }
        .accentColor(self.themeManager.currentTheme.primaryAccentColor)
    }

    // --- Action Handlers ---
    func handleNotificationToggle(enabled: Bool) {
        if enabled {
            self.requestNotificationPermission()
        }
        print("Notification toggle changed: \\(enabled)")
    }

    @ViewBuilder
    func notificationAlertActions() -> some View {
        Button("Open Settings", action: self.openAppSettings).accessibilityLabel("Button").accessibilityLabel("Button")
        Button("Cancel", role: .cancel).accessibilityLabel("Button").accessibilityLabel("Button") {}
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    self.showingNotificationAlert = true
                    self.notificationsEnabled = false
                }
                if let error {
                    print("Notification permission error: \\(error.localizedDescription)")
                    self.notificationsEnabled = false
                }
            }
        }
    }

    func openAppSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Notifications") else {
            print("Cannot open system preferences URL.")
            return
        }
        NSWorkspace.shared.open(url)
    }

    func exportData() {
        print("Export Data action triggered")
        // Simplified export for now
        let csvString = "Type,ID,Title\\nSample,1,Test Data\\n"
        guard let data = csvString.data(using: .utf8) else {
            print("Failed to generate export data")
            return
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PlannerExport.csv")
        do {
            try data.write(to: tempURL, options: .atomic)
            self.exportURL = tempURL
            self.showingExportShareSheet = true
            print("Export file created at: \\(tempURL)")
        } catch {
            print("Failed to write export file: \\(error)")
        }
    }

    func performClearOldData() {
        print("Performing clear old data...")
        // Simplified clear function for now
        print("Clear old data functionality needs TaskDataManager integration")
    }
}

// --- Helper extension for getting App Version ---
extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}
