import Foundation
import SwiftData

@ModelActor
actor DataExporter {
    func export(with settings: ExportSettings) async throws -> URL {
        let engine = ExportEngineService(modelContext: self.modelContext)
        return try await engine.export(settings: settings)
    }
}

// - PDFExporter.swift: PDF document creation and layout
// - JSONExporter.swift: JSON serialization and formatting
// - DataFetcher.swift: SwiftData queries and data retrieval
// - ExportHelpers.swift: File operations and utility functions
// - ExportTypes.swift: Settings, formats, and error definitions
