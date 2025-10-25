import Foundation
import SwiftData

/// Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.
@ModelActor
actor DataExporter {
    private var engine: ExportEngineService?

    /// Initialize engine asynchronously when a ModelContext is available
    func configure(with modelContext: ModelContext) async {
        self.engine = ExportEngineService(modelContext: modelContext)
    }

    nonisolated func export(with settings: ExportSettings) async throws -> URL {
        // TODO: Implement actual export functionality
        throw ExportError.invalidSettings
    }
}

// - PDFExporter.swift: PDF document creation and layout
// - JSONExporter.swift: JSON serialization and formatting
// - DataFetcher.swift: SwiftData queries and data retrieval
// - ExportHelpers.swift: File operations and utility functions
// - ExportTypes.swift: Settings, formats, and error definitions
