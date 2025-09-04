import SwiftUI
import LocalAuthentication

// MARK: - Settings View Coordinator
struct SettingsView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("authenticationTimeout") private var authenticationTimeoutRaw: String = "300"
    
    private var authenticationTimeout: Binding<Int> {
        Binding(get: {
            Int(authenticationTimeoutRaw) ?? 300
        }, set: { newVal in
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
                    authenticationTimeout: authenticationTimeout
                )

                AccessibilitySettingsSection(
                    hapticFeedbackEnabled: $hapticFeedbackEnabled,
                    reducedMotion: $reducedMotion
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
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(NavigationCoordinator())
}
