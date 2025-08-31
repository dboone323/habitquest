import Foundation

// MARK: - Export Helper Methods

extension DataExporter {

    /// Escape CSV field to handle commas, quotes, and newlines
    func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    /// Save string content to file
    func saveToFile(content: String, filename: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ]
        let fileURL = documentsPath.appendingPathComponent(filename)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    /// Save data to file
    func saveToFile(data: Data, filename: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ]
        let fileURL = documentsPath.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }
}
