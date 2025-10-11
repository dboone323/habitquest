// PlannerApp/Views/Settings/SettingsView.swift

import Foundation
import LocalAuthentication
import SwiftUI
import UserNotifications

#if os(macOS)
import AppKit
#endif

public struct SettingsView: View {
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
    @State private var autoSyncEnabled: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? true :
        UserDefaults.standard.bool(forKey: AppSettingKeys.autoSyncEnabled)

    // State for managing UI elements
    @State private var showingNotificationAlert = false
    @State private var showingThemePreview = false

    public var body: some View {
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
                    .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                    Button {
                        self.showingThemePreview = true
                    } label: {
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
                    .accessibilityLabel("Theme Preview Button")
                    .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
                }

                // Dashboard Section
                Section("Dashboard") {
                    Stepper(
                        "Items per section: \(self.dashboardItemLimit)", value: self.$dashboardItemLimit,
                        in: 1 ... 10
                    )
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: self.$notificationsEnabled)
                        .modifier(
                            NotificationToggleModifier(notificationsEnabled: self.$notificationsEnabled)
                        )
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)

                // General Settings Section
                Section("General") {
                    Toggle("24-Hour Time", isOn: self.$use24HourTime)
                    Toggle("Auto-delete Completed Tasks", isOn: self.$autoDeleteCompleted)
                    Toggle("Auto Sync", isOn: self.$autoSyncEnabled)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
            }
            .navigationTitle("Settings")
            .background(self.themeManager.currentTheme.primaryBackgroundColor)
            .scrollContentBackground(.hidden)
            .sheet(isPresented: self.$showingThemePreview) {
                ThemePreviewSheet()
                    .environmentObject(self.themeManager)
            }
            .alert("Notification Permissions", isPresented: self.$showingNotificationAlert) {
                Button("Open Settings", action: self.openAppSettings).accessibilityLabel("Button")
                    .accessibilityLabel("Open Settings Button")
                Button("Cancel", role: .cancel, action: {}).accessibilityLabel("Button")
                    .accessibilityLabel("Cancel Button")
            } message: {
                Text("Enable notifications in Settings to receive reminders.")
            }
        }
    }

    // MARK: - Helper Methods

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    self.showingNotificationAlert = true
                }
            }
        }
    }

    private func openAppSettings() {
        #if os(macOS)
        NSWorkspace.shared.open(
            URL(
                string:
                "x-apple.systempreferences:com.apple.preference.security?Privacy_Notifications"
            )!
        )
        #else
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        #endif
    }
}

// MARK: - Theme Preview Sheet

public struct ThemePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 150)),
                    ], spacing: 16
                ) {
                    ForEach(Theme.availableThemes, id: \.name) { theme in
                        ThemeCard(theme: theme)
                            .environmentObject(self.themeManager)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Theme")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            self.dismiss()
                        }
                        .accessibilityLabel("Done Button")
                    }
                }
        }
        .background(self.themeManager.currentTheme.primaryBackgroundColor)
    }
}

// MARK: - Theme Card

public struct ThemeCard: View {
    let theme: Theme
    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        VStack(spacing: 12) {
            // Theme preview
            RoundedRectangle(cornerRadius: 12)
                .fill(self.theme.primaryBackgroundColor)
                .overlay(
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(self.theme.secondaryBackgroundColor)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(self.theme.primaryAccentColor)
                                    .frame(width: 60, height: 20)
                            )

                        HStack(spacing: 4) {
                            Circle()
                                .fill(self.theme.primaryAccentColor)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(self.theme.secondaryTextColor)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(self.theme.primaryTextColor.opacity(0.3))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(12)
                )
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            self.themeManager.currentTheme.name == self.theme.name
                                ? self.theme.primaryAccentColor : Color.clear,
                            lineWidth: 2
                        )
                )

            // Theme name
            Text(self.theme.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
        }
        .onTapGesture {
            self.themeManager.currentThemeName = self.theme.name
        }
    }
}

public struct SettingsView_Previews: PreviewProvider {
    public static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager())
    }
}

// MARK: - Notification Toggle Modifier

public struct NotificationToggleModifier: ViewModifier {
    @Binding var notificationsEnabled: Bool

    public func body(content: Content) -> some View {
        if #available(macOS 14.0, iOS 17.0, *) {
            content.onChange(of: notificationsEnabled) { _, newValue in
                if newValue {
                    requestNotificationPermission()
                }
            }
        } else {
            content
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    // Could show alert here, but since we're in a modifier, we'll skip for now
                }
            }
        }
    }
}
