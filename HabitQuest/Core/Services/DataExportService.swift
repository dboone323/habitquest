import Foundation
import HabitQuestCore
import SwiftData

/// Legacy bridge for DataExportService to maintain compatibility with the DataManagement feature.
/// Delegates logic to HabitDataService in HabitQuestCore.
enum DataExportService {

    static func generateExportFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmm"
        return "HabitQuest_Backup_\(formatter.string(from: Date())).json"
    }

    @MainActor
    static func exportUserData(from context: ModelContext) async throws -> Data {
        let service = HabitDataService(modelContext: context)
        return try service.exportData()
    }

    @MainActor
    static func importUserData(from data: Data, into context: ModelContext, replaceExisting: Bool) async throws {
        let service = HabitDataService(modelContext: context)
        try service.importData(data)
    }

    @MainActor
    static func deleteAllData(from context: ModelContext) throws {
        try context.delete(model: HabitLog.self)
        try context.delete(model: Habit.self)
        try context.delete(model: PlayerProfile.self)
        try context.delete(model: Achievement.self)
        try context.save()
    }
}

enum DataExportError: LocalizedError {
    case importFailed(String)
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case let .importFailed(msg): "Import failed: \(msg)"
        case let .exportFailed(msg): "Export failed: \(msg)"
        }
    }
}
