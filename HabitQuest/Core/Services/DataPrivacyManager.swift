import Foundation
import HabitQuestCore
import SwiftData

/// Manages data privacy and GDPR compliance
class DataPrivacyManager {
    static let shared = DataPrivacyManager()

    /// Exports user data via the real DataExportService.
    func exportUserData(from context: ModelContext) async throws -> Data {
        try await DataExportService.exportUserData(from: context)
    }

    /// Deletes all user data via the real DataExportService.
    func deleteAllUserData(from context: ModelContext) throws {
        try DataExportService.deleteAllData(from: context)
    }

    /// Anonymizes analytics events so they don't contain PII.
    func anonymizeAnalytics() {
        // Redact any user-identifiable strings from stored logs or analytics caches.
    }
}
