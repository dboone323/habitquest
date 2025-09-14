import LocalAuthentication
import SwiftUI

// MARK: - Settings View Coordinator
struct SettingsView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("authenticationTimeout") private var authenticationTimeoutRaw: String = "300"

    private var authenticationTimeout: Binding<Int> {
        Binding(
            get: {
                Int(authenticationTimeoutRaw) ?? 300
            },
            set: { newVal in
                authenticationTimeoutRaw = String(newVal)
            })
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
                DarkModePreference(rawValue: darkModePreferenceRaw) ?? .system
            },
            set: { newVal in
                darkModePreferenceRaw = newVal.rawValue
            })
    }

    var body: some View {
        NavigationView {
            List {
                // Security Settings Section
                Section(header: Text("Security")) {
                    Toggle("Biometric Authentication", isOn: $biometricEnabled)
                    Picker("Authentication Timeout", selection: authenticationTimeout) {
                        Text("1 minute").tag(60)
                        Text("5 minutes").tag(300)
                        Text("15 minutes").tag(900)
                        Text("1 hour").tag(3_600)
                    }
                }

                // Accessibility Settings Section
                Section(header: Text("Accessibility")) {
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                    Toggle("Reduced Motion", isOn: $reducedMotion)
                }

                // Appearance Settings Section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: darkModePreference) {
                        Text("System").tag(DarkModePreference.system)
                        Text("Light").tag(DarkModePreference.light)
                        Text("Dark").tag(DarkModePreference.dark)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Data Management Section
                Section(header: Text("Data Management")) {
                    Picker("Data Retention", selection: $dataRetentionDays) {
                        Text("30 days").tag(30.0)
                        Text("90 days").tag(90.0)
                        Text("1 year").tag(365.0)
                        Text("Forever").tag(0.0)
                    }

                    Button("Delete All Data", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }

                // Import/Export Section
                Section(header: Text("Import & Export")) {
                    Button("Export Data") {
                        // Export functionality would go here
                    }

                    Button("Import Data") {
                        // Import functionality would go here
                    }
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
            .alert("Delete Transaction", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                    .accessibilityLabel("Cancel button")
                Button("Delete", role: .destructive) {}
                    .accessibilityLabel("Delete button")
            } message: {
                Text("This action cannot be undone.")
            }
            .alert("Delete All Data", isPresented: $showDeleteAllAlert) {
                Button("Cancel", role: .cancel) {}
                    .accessibilityLabel("Cancel delete all button")
                Button("Delete All", role: .destructive) {
                    deleteAllData()
                }
                .accessibilityLabel("Confirm delete all button")
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
                deleteAllProgress = true
            }

            // Simulate deletion process
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            await MainActor.run {
                deleteAllProgress = false
                showDeleteAllAlert = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(NavigationCoordinator())
}
