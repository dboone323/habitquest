import Foundation
import SwiftData
import HabitQuestCore

/// Legacy bridge for DataExportService to maintain compatibility with the DataManagement feature.
/// Delegates logic to HabitDataService in HabitQuestCore.
struct DataExportService {
    
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
}

enum DataExportError: LocalizedError {
    case importFailed(String)
    case exportFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .importFailed(let msg): return "Import failed: \(msg)"
        case .exportFailed(let msg): return "Export failed: \(msg)"
        }
    }
}
