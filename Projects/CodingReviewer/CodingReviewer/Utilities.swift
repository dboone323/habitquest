//
//  Utilities.swift
//  CodingReviewer
//
//  Created by Quantum Automation on 2025-08-29.
//

import Foundation

class Utilities {

    // MARK: - File Operations

    static func readFile(at path: String) -> String? {
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            print("Error reading file at \(path): \(error)")
            return nil
        }
    }

    static func writeFile(content: String, to path: String) -> Bool {
        do {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Error writing file to \(path): \(error)")
            return false
        }
    }

    // MARK: - String Operations

    static func formatCodeReviewSummary(_ items: [CodeReviewItem]) -> String {
        let completed = items.count(where: { $0.status == .completed })
        let inProgress = items.count(where: { $0.status == .inProgress })
        let pending = items.count(where: { $0.status == .pending })

        return """
        Code Review Summary:
        - Total Items: \(items.count)
        - Completed: \(completed)
        - In Progress: \(inProgress)
        - Pending: \(pending)
        - Completion Rate: \(String(format: "%.1f%%", Double(completed) / Double(items.count) * 100))
        """
    }

    // MARK: - Date Operations

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func getCurrentTimestamp() -> String {
        formatDate(Date())
    }
}
