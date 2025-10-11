import Foundation
import SwiftData

/// Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.
actor DataExporter {
    private var engine: ExportEngineService?

    init() {}

    /// Initialize engine asynchronously when a ModelContext is available
    func configure(with modelContext: ModelContext) async {
        self.engine = ExportEngineService(modelContext: modelContext)
    }

    func export(with settings: ExportSettings) async throws -> URL {
        guard let engine else { throw ExportError.invalidSettings }
        return try await engine.export(settings: settings)
    }
}
