import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// View for managing data export and import functionality
/// Allows users to backup their progress and restore from backups
struct DataManagementView: View {
    @StateObject private var viewModel = DataManagementViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            List {
                Section("Backup Your Progress") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export your habits, achievements, and progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(action: viewModel.exportData) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Data")
                                Spacer()
                                if viewModel.isExporting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                        .disabled(viewModel.isExporting)
                    }
                    .padding(.vertical, 4)
                }

                Section("Restore from Backup") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Import data from a previous backup")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(action: viewModel.importData) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Import Data")
                                Spacer()
                                if viewModel.isImporting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                        .disabled(viewModel.isImporting)
                    }
                    .padding(.vertical, 4)
                }

                Section("Data Information") {
                    DataInfoRow(title: "Total Habits", value: "\(viewModel.totalHabits)")
                    DataInfoRow(title: "Total Completions", value: "\(viewModel.totalCompletions)")
                    DataInfoRow(title: "Achievements Unlocked", value: "\(viewModel.unlockedAchievements)")
                    DataInfoRow(title: "Current Level", value: "\(viewModel.currentLevel)")
                    DataInfoRow(title: "Last Backup", value: viewModel.lastBackupDate)
                }

                Section("Advanced") {
                    Button("Clear All Data") {
                        viewModel.showingClearDataAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Data Management")
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
            .alert("Export Successful", isPresented: $viewModel.showingExportSuccess) {
                Button("OK") { }
            } message: {
                Text("Your data has been exported successfully. Check your Files app for the backup file.")
            }
            .alert("Import Successful", isPresented: $viewModel.showingImportSuccess) {
                Button("OK") { }
            } message: {
                Text("Your data has been imported successfully. The app will refresh to show your restored progress.")
            }
            .alert("Clear All Data", isPresented: $viewModel.showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("This will permanently delete all your habits, progress, and achievements. This action cannot be undone.")
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
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
        }
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
struct HabitQuestBackupDocument: FileDocument {
    nonisolated static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    nonisolated init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    nonisolated func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    DataManagementView()
}
