import LocalAuthentication
import SwiftUI

// MARK: - Settings View Coordinator

public struct SettingsView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("authenticationTimeout") private var authenticationTimeoutRaw: String = "300"

    private var authenticationTimeout: Binding<Int> {
        Binding(
            get: {
                Int(self.authenticationTimeoutRaw) ?? 300
            },
            set: { newVal in
                self.authenticationTimeoutRaw = String(newVal)
            }
        )
    }

    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("reducedMotion") private var reducedMotion = false
    @AppStorage("highContrastMode") private var highContrastMode = false
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("darkModePreference") private var darkModePreferenceRaw: String = "system"
    @AppStorage("dataRetentionDays") private var dataRetentionDays: Double = 365.0

    @State private var deleteAllProgress = false
    @State private var showDeleteAlert = false
    @State private var showDeleteAllAlert = false
    @State private var showingDeleteConfirmation = false

    private var darkModePreference: Binding<DarkModePreference> {
        Binding(
            get: {
                DarkModePreference(rawValue: self.darkModePreferenceRaw) ?? .system
            },
            set: { newVal in
                self.darkModePreferenceRaw = newVal.rawValue
            }
        )
    }

    public var body: some View {
        NavigationView {
            List {
                // Security Settings Section
                Section(header: Text("Security")) {
                    Toggle("Biometric Authentication", isOn: self.$biometricEnabled)
                    Picker("Authentication Timeout", selection: self.authenticationTimeout) {
                        Text("1 minute").tag(60)
                        Text("5 minutes").tag(300)
                        Text("15 minutes").tag(900)
                        Text("1 hour").tag(3600)
                    }
                }

                // Accessibility Settings Section
                Section(header: Text("Accessibility")) {
                    Toggle("Haptic Feedback", isOn: self.$hapticFeedbackEnabled)
                    Toggle("Reduced Motion", isOn: self.$reducedMotion)
                }

                // Appearance Settings Section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: self.darkModePreference) {
                        Text("System").tag(DarkModePreference.system)
                        Text("Light").tag(DarkModePreference.light)
                        Text("Dark").tag(DarkModePreference.dark)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Data Management Section
                Section(header: Text("Data Management")) {
                    Picker("Data Retention", selection: self.$dataRetentionDays) {
                        Text("30 days").tag(30.0)
                        Text("90 days").tag(90.0)
                        Text("1 year").tag(365.0)
                        Text("Forever").tag(0.0)
                    }

                    Button("Delete All Data", role: .destructive) {
                        self.showingDeleteConfirmation = true
                    }
                    .accessibilityLabel("Delete All Data")
                }

                // Import/Export Section
                Section(header: Text("Import & Export")) {
                    Button("Export Data") {
                        // Export functionality would go here
                    }
                    .accessibilityLabel("Export Data")

                    Button("Import Data") {
                        // Import functionality would go here
                    }
                    .accessibilityLabel("Import Data")
                }

                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2024.1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Delete Transaction", isPresented: self.$showDeleteAlert) {
                Button("Cancel", role: .cancel) { /* dismiss automatically */ }
                    .accessibilityLabel("Cancel")
                Button("Delete", role: .destructive) { /* perform delete */ }
                    .accessibilityLabel("Delete Transaction")
            } message: {
                Text("This action cannot be undone.")
            }
            .alert("Delete All Data", isPresented: self.$showDeleteAllAlert) {
                Button("Cancel", role: .cancel) { /* dismiss automatically */ }
                    .accessibilityLabel("Cancel Delete All")
                Button("Delete All", role: .destructive) { self.deleteAllData() }
                    .accessibilityLabel("Confirm Delete All Data")
            } message: {
                Text(
                    "This will permanently delete all your financial data. This action cannot be undone."
                )
            }
        }
    }

    private func deleteAllData() {
        Task {
            await MainActor.run {
                self.deleteAllProgress = true
            }

            // Simulate deletion process
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            await MainActor.run {
                self.deleteAllProgress = false
                self.showDeleteAllAlert = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(NavigationCoordinator())
}
