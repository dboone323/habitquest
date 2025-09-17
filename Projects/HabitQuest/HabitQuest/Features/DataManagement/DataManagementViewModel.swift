import Combine
import SwiftData
import SwiftUI

/// ViewModel for DataManagementView handling export/import operations
@MainActor
class DataManagementViewModel: ObservableObject {
    @Published var isExporting = false
    @Published var isImporting = false
    @Published var showingFileExporter = false
    @Published var showingFileImporter = false
    @Published var showingExportSuccess = false
    @Published var showingImportSuccess = false
    @Published var showingClearDataAlert = false
    @Published var showingError = false
    @Published var errorMessage = ""

    @Published var totalHabits = 0
    @Published var totalCompletions = 0
    @Published var unlockedAchievements = 0
    @Published var currentLevel = 1
    @Published var lastBackupDate = "Never"

    var exportDocument: HabitQuestBackupDocument?
    var exportFilename: String {
        DataExportService.generateExportFilename()
    }

    private var modelContext: ModelContext?
    private let logger = Logger(category: .dataModel)

    /// Set the model context and load data statistics
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        self.loadDataStatistics()
    }

    /// Export user data to JSON file
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func exportData() {
        guard let modelContext else { return }

        self.isExporting = true

        Task {
            do {
                let jsonData = try DataExportService.exportUserData(from: modelContext)

                await MainActor.run {
                    self.exportDocument = HabitQuestBackupDocument(data: jsonData)
                    self.showingFileExporter = true
                    self.isExporting = false

                    // Update last backup date
                    self.updateLastBackupDate()
                }

                self.logger.info("Data export prepared successfully")

            } catch {
                await MainActor.run {
                    self.isExporting = false
                    self.handleError(error)
                }
            }
        }
    }

    /// Import user data from JSON file
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func importData() {
        self.showingFileImporter = true
    }

    /// Handle the result of file export
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case let .success(url):
            self.logger.info("Data exported successfully to: \(url.path)")
            self.showingExportSuccess = true
            self.updateLastBackupDate()

        case let .failure(error):
            self.logger.error("Export failed: \(error.localizedDescription)")
            self.handleError(error)
        }
    }

    /// Handle the result of file import
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            guard let url = urls.first else { return }

            self.isImporting = true

            Task {
                do {
                    let data = try Data(contentsOf: url)

                    guard let modelContext = self.modelContext else {
                        throw DataExportError.importFailed("Model context not available")
                    }

                    try DataExportService.importUserData(
                        from: data,
                        into: modelContext,
                        replaceExisting: true
                    )

                    await MainActor.run {
                        self.isImporting = false
                        self.showingImportSuccess = true
                        self.loadDataStatistics() // Refresh stats after import
                    }

                    self.logger.info("Data imported successfully from: \(url.path)")

                } catch {
                    await MainActor.run {
                        self.isImporting = false
                        self.handleError(error)
                    }
                }
            }

        case let .failure(error):
            self.logger.error("Import selection failed: \(error.localizedDescription)")
            self.handleError(error)
        }
    }

    /// Clear all user data
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func clearAllData() {
        guard let modelContext else { return }

        Task {
            do {
                // Delete all data using the service
                try await self.clearAllDataFromService(modelContext)

                await MainActor.run {
                    self.loadDataStatistics() // Refresh stats
                    self.lastBackupDate = "Never"
                }

                self.logger.info("All data cleared successfully")

            } catch {
                await MainActor.run {
                    self.handleError(error)
                }
            }
        }
    }

    /// Load current data statistics
    private func loadDataStatistics() {
        guard let modelContext else { return }

        do {
            // Load habits
            let habitsDescriptor = FetchDescriptor<Habit>()
            let habits = try modelContext.fetch(habitsDescriptor)
            self.totalHabits = habits.count

            // Load completions
            let logsDescriptor = FetchDescriptor<HabitLog>()
            let logs = try modelContext.fetch(logsDescriptor)
            self.totalCompletions = logs.count

            // Load achievements
            let achievementsDescriptor = FetchDescriptor<Achievement>()
            let achievements = try modelContext.fetch(achievementsDescriptor)
            self.unlockedAchievements = achievements.filter(\.isUnlocked).count

            // Load player profile
            let profileDescriptor = FetchDescriptor<PlayerProfile>()
            let profiles = try modelContext.fetch(profileDescriptor)
            self.currentLevel = profiles.first?.level ?? 1

            self.logger.info("Loaded data statistics: \(self.totalHabits) habits, \(self.totalCompletions) completions")

        } catch {
            self.logger.error("Failed to load data statistics: \(error.localizedDescription)")
            self.handleError(error)
        }
    }

    /// Update the last backup date
    private func updateLastBackupDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        self.lastBackupDate = formatter.string(from: Date())

        // Store in UserDefaults for persistence
        UserDefaults.standard.set(Date(), forKey: "lastBackupDate")
    }

    /// Load the last backup date from UserDefaults
    private func loadLastBackupDate() {
        if let date = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            self.lastBackupDate = formatter.string(from: date)
        } else {
            self.lastBackupDate = "Never"
        }
    }

    /// Handle errors and show user-friendly messages
    private func handleError(_ error: Error) {
        if let dataError = error as? DataExportError {
            self.errorMessage = dataError.localizedDescription
        } else {
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        self.showingError = true
    }

    /// Clear all data using a background task
    private func clearAllDataFromService(_ modelContext: ModelContext) async throws {
        // Delete all existing data
        let profileDescriptor = FetchDescriptor<PlayerProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        profiles.forEach { modelContext.delete($0) }

        let habitsDescriptor = FetchDescriptor<Habit>()
        let habits = try modelContext.fetch(habitsDescriptor)
        habits.forEach { modelContext.delete($0) }

        let logsDescriptor = FetchDescriptor<HabitLog>()
        let logs = try modelContext.fetch(logsDescriptor)
        logs.forEach { modelContext.delete($0) }

        let achievementsDescriptor = FetchDescriptor<Achievement>()
        let achievements = try modelContext.fetch(achievementsDescriptor)
        achievements.forEach { modelContext.delete($0) }

        try modelContext.save()
    }
}
