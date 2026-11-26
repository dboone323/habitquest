import HabitQuestCore
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// View for managing data export and import functionality
/// Allows users to backup their progress and restore from backups
public struct DataManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = DataManagementViewModel()
    @ObservedObject private var healthKitService = HealthKitService.shared
    @State private var isRequestingHealthAuth = false

    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $themeManager.appearanceMode) {
                        ForEach(ThemeAppearanceMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Appearance Theme Picker")
                }

                Section(header: Text("Apple Health")) {
                    HStack {
                        Label("Movement & Sleep Sync", systemImage: "heart.text.square")
                        Spacer()
                        Text(healthKitService.isHealthDataAvailable ? (healthKitService.isAuthorized ? "Connected" : "Not Connected") : "Unavailable")
                            .foregroundColor(.secondary)
                    }

                    Button {
                        isRequestingHealthAuth = true
                        Task {
                            do {
                                try await healthKitService.requestAuthorization()
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                                viewModel.showingError = true
                            }
                            isRequestingHealthAuth = false
                        }
                    } label: {
                        if isRequestingHealthAuth {
                            ProgressView()
                                .padding(.trailing, 8)
                        }
                        Label(
                            healthKitService.isAuthorized ? "Refresh Apple Health Data" : "Connect Apple Health",
                            systemImage: "figure.walk"
                        )
                    }
                    .disabled(isRequestingHealthAuth)
                    .accessibilityLabel("Connect Apple Health")

                    if let statusMessage = healthKitService.statusMessage {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Reads steps, active energy, and sleep hours locally to auto-complete linked habits.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Backup Your Progress")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export your habits, achievements, and progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(
                            action: {
                                viewModel.exportData()
                            },
                            label: {
                                if viewModel.isExporting {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                }
                                Label("Export Data", systemImage: "square.and.arrow.up")
                            }
                        )
                        .disabled(viewModel.isExporting)
                        .accessibilityLabel("Export Data Button")
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Restore from Backup")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Import data from a previous backup")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(
                            action: {
                                viewModel.importData()
                            },
                            label: {
                                if viewModel.isImporting {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                }
                                Label("Import Data", systemImage: "square.and.arrow.down")
                            }
                        )
                        .disabled(viewModel.isImporting)
                        .accessibilityLabel("Import Data Button")
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Data Information")) {
                    DataInfoRow(title: "Total Habits", value: "\(viewModel.totalHabits)")
                    DataInfoRow(title: "Total Completions", value: "\(viewModel.totalCompletions)")
                    DataInfoRow(
                        title: "Achievements Unlocked", value: "\(viewModel.unlockedAchievements)"
                    )
                    DataInfoRow(title: "Current Level", value: "\(viewModel.currentLevel)")
                    DataInfoRow(title: "Last Backup", value: viewModel.lastBackupDate)
                }

                Section(header: Text("Streak Forgiveness & Gamification")) {
                    Stepper("Grace Period: \(viewModel.forgivenessThreshold) days", value: $viewModel.forgivenessThreshold, in: 1...14)
                        .accessibilityLabel("Streak forgiveness threshold")
                    Text("Missed days will not reset your streak unless you miss more than \(viewModel.forgivenessThreshold) days.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Label("Streak Freezes", systemImage: "snowflake")
                        Spacer()
                        Text("\(viewModel.streakFreezes) available")
                            .foregroundColor(.secondary)
                    }
                    Text("Earned upon each level-up. Automatically protects your streak.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Advanced")) {
                    Button("Clear All Data") {
                        viewModel.showingClearDataAlert = true
                    }
                    .accessibilityLabel("Clear All Data Button")
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Data Management")
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
            .fileExporter(
                isPresented: $viewModel.showingFileExporter,
                document: viewModel.exportDocument,
                contentType: .json,
                defaultFilename: viewModel.exportFilename
            ) { result in
                viewModel.handleExportResult(result)
            }
            .fileImporter(
                isPresented: $viewModel.showingFileImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                viewModel.handleImportResult(result)
            }
            .alert("Export Successful", isPresented: $viewModel.showingExportSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your data has been securely encrypted and exported.")
            }
            .alert("Import Successful", isPresented: $viewModel.showingImportSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your data has been restored and verified.")
            }
            .alert("Clear Data", isPresented: $viewModel.showingClearDataAlert) {
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(
                    "Are you sure you want to delete all habits and progress? This action cannot be undone."
                )
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

public struct AlertModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
    }
}

public struct FileHandlerModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
    }
}

/// Individual data information row
private struct DataInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

/// Document type for file export
public struct HabitQuestBackupDocument: FileDocument {
    public nonisolated static var readableContentTypes: [UTType] {
        [.json]
    }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    public nonisolated init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    /// Returns a file wrapper representation of the JSON data.
    public nonisolated func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    DataManagementView()
        .environmentObject(ThemeManager())
}
