<<<<<<< HEAD
// Momentum Finance - Advanced Settings View
// Copyright © 2025 Momentum Finance. All rights reserved.

import LocalAuthentication
import SwiftUI

/// Comprehensive settings view with advanced UX features
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @State private var showingDataExport = false
    @State private var showingDataImport = false
    @State private var showingDeleteConfirmation = false
    @State private var biometricStatus: BiometricStatus = .unknown

    // Settings Properties
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("authenticationTimeout") private var authenticationTimeout = 300.0 // 5 minutes
    @AppStorage("darkModePreference") private var darkModePreference = DarkModePreference.system as DarkModePreference
    @AppStorage("reducedMotion") private var reducedMotion = false
    @AppStorage("highContrastMode") private var highContrastMode = false
    @AppStorage("dataRetentionDays") private var dataRetentionDays = 365.0

    var body: some View {
        NavigationView {
            List {
                securitySection
                accessibilitySection
                appearanceSection
                dataManagementSection
                exportImportSection
                aboutSection
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close Settings")
                }
                #else
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close Settings")
                }
                #endif
            }
        }
        .onAppear {
            checkBiometricStatus()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
        .sheet(isPresented: $showingDataImport) {
            DataImportView()
        }
        .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await deleteAllData()
                }
            }
        } message: {
            Text("This action cannot be undone. All your financial data will be permanently deleted.")
        }
    }

    private var securitySection: some View {
        Section {
            HStack {
                Label("Biometric Authentication", systemImage: biometricIcon)
                    .foregroundColor(.primary)

                Spacer()

                Toggle("", isOn: $biometricEnabled)
                    .disabled(!biometricStatus.isAvailable)
                    .onChange(of: biometricEnabled) { _, newValue in
                        if newValue {
                            Task {
                                await enableBiometricAuthentication()
                            }
                        } else {
                            coordinator.requiresAuthentication = false
                        }
                    }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Biometric Authentication")
            .accessibilityValue(biometricEnabled ? "Enabled" : "Disabled")

            if !biometricStatus.isAvailable {
                Text(biometricStatus.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if biometricEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Authentication Timeout")
                        .font(.subheadline)

                    HStack {
                        Text("5 min")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Slider(value: $authenticationTimeout, in: 60 ... 1_800, step: 60) {
                            Text("Timeout")
                        }
                        .onChange(of: authenticationTimeout) { _, newValue in
                            coordinator.authenticationTimeoutInterval = newValue
                            #if os(iOS)
                            HapticManager.shared.impact(.light)
                            #endif
                        }

                        Text("30 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("Auto-lock after \(Int(authenticationTimeout / 60)) minutes of inactivity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        } header: {
            Text("Security & Privacy")
        } footer: {
            if biometricEnabled {
                Text("Your financial data is protected with \(biometricStatus.name) authentication.")
            }
        }
    }

    private var accessibilitySection: some View {
        Section {
            Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                .accessibilityHint("Enables vibration feedback for interactions")
                .onChange(of: hapticFeedbackEnabled) { _, _ in
                    HapticManager.shared.isEnabled = hapticFeedbackEnabled
                    if hapticFeedbackEnabled {
                        HapticManager.shared.success()
                    }
                }

            Toggle("Reduce Motion", isOn: $reducedMotion)
                .accessibilityHint("Reduces animations throughout the app")
                .onChange(of: reducedMotion) { _, _ in
                    if hapticFeedbackEnabled {
                        #if os(iOS)
                        HapticManager.shared.impact(.light)
                        #endif
                    }
                }

            Toggle("High Contrast Mode", isOn: $highContrastMode)
                .accessibilityHint("Increases contrast for better visibility")
                .onChange(of: highContrastMode) { _, _ in
                    if hapticFeedbackEnabled {
                        #if os(iOS)
                        HapticManager.shared.impact(.light)
                        #endif
                    }
                }

            Toggle("Enhanced Animations", isOn: $animationsEnabled)
                .disabled(reducedMotion)
                .accessibilityHint("Enables smooth transitions and animations")
                .onChange(of: animationsEnabled) { _, _ in
                    if hapticFeedbackEnabled {
                        #if os(iOS)
                        HapticManager.shared.impact(.light)
                        #endif
                    }
                }
        } header: {
            Text("Accessibility")
        } footer: {
            Text("These settings help make the app more accessible and comfortable to use.")
        }
    }

    private var appearanceSection: some View {
        Section {
            HStack {
                Label("Appearance", systemImage: "paintbrush")

                Spacer()

                Picker("Dark Mode", selection: $darkModePreference) {
                    ForEach(DarkModePreference.allCases, id: \.self) { preference in
                        Text(preference.displayName)
                            .tag(preference)
                    }
                }
                .pickerStyle(.menu)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Appearance Setting")
            .accessibilityValue(darkModePreference.displayName)
        } header: {
            Text("Appearance")
        }
    }

    private var dataManagementSection: some View {
        Section {
            HStack {
                Label("Data Retention", systemImage: "clock.arrow.circlepath")

                Spacer()

                Picker("Retention Period", selection: $dataRetentionDays) {
                    Text("3 months").tag(90.0)
                    Text("6 months").tag(180.0)
                    Text("1 year").tag(365.0)
                    Text("2 years").tag(730.0)
                    Text("Forever").tag(0.0)
                }
                .pickerStyle(.menu)
            }

            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete All Data", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .accessibilityLabel("Delete All Financial Data")
            .accessibilityHint("Permanently removes all your financial data")
        } header: {
            Text("Data Management")
        } footer: {
            if dataRetentionDays > 0 {
                Text("Data older than \(Int(dataRetentionDays)) days will be automatically deleted.")
            } else {
                Text("Your data will be kept indefinitely.")
            }
        }
    }

    private var exportImportSection: some View {
        Section {
            Button(action: {
                showingDataExport = true
                if hapticFeedbackEnabled {
                    #if os(iOS)
                    HapticManager.shared.impact(.medium)
                    #endif
                }
            }) {
                Label("Export Data", systemImage: "square.and.arrow.up")
            }
            .accessibilityLabel("Export Financial Data")
            .accessibilityHint("Export your data to CSV or PDF format")

            Button(action: {
                showingDataImport = true
                if hapticFeedbackEnabled {
                    #if os(iOS)
                    HapticManager.shared.impact(.medium)
                    #endif
                }
            }) {
                Label("Import Data", systemImage: "square.and.arrow.down")
            }
            .accessibilityLabel("Import Financial Data")
            .accessibilityHint("Import data from CSV files")
        } header: {
            Text("Data Import & Export")
        } footer: {
            Text("Backup your data or import from other financial apps.")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            Link(destination: URL(string: "https://momentum-finance.com/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            Link(destination: URL(string: "https://momentum-finance.com/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }

            Link(destination: URL(string: "https://momentum-finance.com/support")!) {
                Label("Support", systemImage: "questionmark.circle")
            }
        } header: {
            Text("About")
        }
    }

    // MARK: - Computed Properties

    private var biometricIcon: String {
        switch biometricStatus {
        case .faceID:
            "faceid"
        case .touchID:
            "touchid"
        case .unknown, .notAvailable, .notEnrolled:
            "lock.shield"
        }
    }

    // MARK: - Methods

    private func checkBiometricStatus() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricStatus = .faceID
            case .touchID:
                biometricStatus = .touchID
            default:
                biometricStatus = .unknown
            }
        } else {
            if let error = error as? LAError {
                switch error.code {
                case .biometryNotEnrolled:
                    biometricStatus = .notEnrolled
                default:
                    biometricStatus = .notAvailable
                }
            } else {
                biometricStatus = .notAvailable
            }
        }
    }

    private func enableBiometricAuthentication() async {
        let success = await coordinator.authenticateWithBiometrics()
        if success {
            coordinator.requiresAuthentication = true
            if hapticFeedbackEnabled {
                HapticManager.shared.success()
            }
        } else {
            biometricEnabled = false
            if hapticFeedbackEnabled {
                HapticManager.shared.error()
            }
        }
    }

    private func deleteAllData() async {
        // This would integrate with the data manager to delete all data
        // Implementation would depend on the specific data architecture
        if hapticFeedbackEnabled {
            HapticManager.shared.success()
        }
    }
}

// MARK: - Supporting Types

enum BiometricStatus {
    case faceID
    case touchID
    case unknown
    case notAvailable
    case notEnrolled

    var isAvailable: Bool {
        switch self {
        case .faceID, .touchID:
            true
        case .unknown, .notAvailable, .notEnrolled:
            false
        }
    }

    var name: String {
        switch self {
        case .faceID:
            "Face ID"
        case .touchID:
            "Touch ID"
        case .unknown:
            "Biometric"
        case .notAvailable, .notEnrolled:
            "Biometric"
        }
    }

    var statusMessage: String {
        switch self {
        case .faceID, .touchID:
            ""
        case .unknown:
            "Biometric authentication is available but type is unknown"
        case .notAvailable:
            "Biometric authentication is not available on this device"
        case .notEnrolled:
            "No biometric authentication is set up. Please set up Face ID or Touch ID in Settings."
        }
    }
}

enum DarkModePreference: String, CaseIterable {
    case light
    case dark
    case system

    var displayName: String {
        switch self {
        case .light:
            "Light"
        case .dark:
            "Dark"
        case .system:
            "System"
=======
import SwiftUI
import LocalAuthentication

// MARK: - Settings View Coordinator
struct SettingsView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("authenticationTimeout") private var authenticationTimeout: Double = 300
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("reducedMotion") private var reducedMotion = false
    @AppStorage("highContrastMode") private var highContrastMode = false
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("darkModePreference") private var darkModePreferenceRaw: String = DarkModePreference.system.rawValue
    @AppStorage("dataRetentionDays") private var dataRetentionDays: Double = 365.0

    @State private var deleteAllProgress = false
    @State private var showDeleteAlert = false
    @State private var showDeleteAllAlert = false
    @State private var showingDeleteConfirmation = false

    private var darkModePreference: Binding<DarkModePreference> {
        Binding(get: {
            DarkModePreference(rawValue: darkModePreferenceRaw) ?? .system
        }, set: { newVal in
            darkModePreferenceRaw = newVal.rawValue
        })
    }
    
    var body: some View {
        NavigationView {
            List {
                SecuritySettingsSection(
                    biometricEnabled: $biometricEnabled,
                    authenticationTimeout: $authenticationTimeout,
                    hapticFeedbackEnabled: $hapticFeedbackEnabled
                )

                AccessibilitySettingsSection(
                    hapticFeedbackEnabled: $hapticFeedbackEnabled,
                    reducedMotion: $reducedMotion,
                    highContrastMode: $highContrastMode,
                    animationsEnabled: $animationsEnabled
                )

                AppearanceSettingsSection(darkModePreference: darkModePreference)

                DataManagementSection(
                    dataRetentionDays: $dataRetentionDays,
                    showingDeleteConfirmation: $showingDeleteConfirmation,
                    hapticFeedbackEnabled: $hapticFeedbackEnabled
                )

                ImportExportSection()

                AboutSection()
            }
            .navigationTitle("Settings")
            .alert("Delete Transaction", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { }
            } message: {
                Text("This action cannot be undone.")
            }
            .alert("Delete All Data", isPresented: $showDeleteAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your financial data. This action cannot be undone.")
            }
        }
    }
    
    private func deleteAllData() {
        Task {
            await MainActor.run {
                deleteAllProgress = true
            }
            
            // Simulate deletion process
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                deleteAllProgress = false
                showDeleteAllAlert = false
            }
>>>>>>> 1cf3938 (Create working state for recovery)
        }
    }
}

<<<<<<< HEAD
=======
// MARK: - Preview
>>>>>>> 1cf3938 (Create working state for recovery)
#Preview {
    SettingsView()
        .environmentObject(NavigationCoordinator())
}
