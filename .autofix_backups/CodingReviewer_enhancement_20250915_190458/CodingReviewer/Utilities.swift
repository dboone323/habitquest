//
//  Utilities.swift
//  CodingReviewer
//
//  Created by Quantum Automation on 2025-08-29.
//

import Foundation

/// Enhanced utilities class using SharedArchitecture patterns
class Utilities {

    // MARK: - File Operations

    static func readFile(at path: String) -> Result<String, Error> {
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return .success(content)
        } catch {
            return .failure(error)
        }
    }

    static func writeFile(content: String, to path: String) -> Result<Void, Error> {
        do {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Code Review Operations

    static func formatCodeReviewSummary(_ items: [CodeReviewItem]) -> String {
        let completed = items.count(where: { $0.status == .completed })
        let inProgress = items.count(where: { $0.status == .inProgress })
        let pending = items.count(where: { $0.status == .pending })
        let blocked = items.count(where: { $0.status == .blocked })

        let totalItems = items.count
        let completionRate = totalItems > 0 ? Double(completed) / Double(totalItems) : 0.0

        return """
        📊 Code Review Summary:
        • Total Items: \(totalItems)
        • ✅ Completed: \(completed)
        • 🔄 In Progress: \(inProgress)
        • ⏳ Pending: \(pending)
        • 🚫 Blocked: \(blocked)
        • 📈 Completion Rate: \(String(format: "%.1f%%", completionRate * 100))
        """
    }

    static func generateReviewReport(_ items: [CodeReviewItem]) -> ReviewReport {
        let completed = items.count(where: { $0.status == .completed })
        let inProgress = items.count(where: { $0.status == .inProgress })
        let pending = items.count(where: { $0.status == .pending })
        let blocked = items.count(where: { $0.status == .blocked })

        let highPriority = items.count(where: { $0.priority == .high })
        let mediumPriority = items.count(where: { $0.priority == .medium })
        let lowPriority = items.count(where: { $0.priority == .low })

        let totalItems = items.count
        let completionRate = totalItems > 0 ? Double(completed) / Double(totalItems) : 0.0

        let averageCompletionTime = calculateAverageCompletionTime(items)
        let oldestPendingItem = findOldestPendingItem(items)

        return ReviewReport(
            totalItems: totalItems,
            completedItems: completed,
            inProgressItems: inProgress,
            pendingItems: pending,
            blockedItems: blocked,
            highPriorityItems: highPriority,
            mediumPriorityItems: mediumPriority,
            lowPriorityItems: lowPriority,
            completionRate: completionRate,
            averageCompletionTime: averageCompletionTime,
            oldestPendingItem: oldestPendingItem
        )
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

    static func formatRelativeDate(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.day], from: date, to: now)

        guard let days = components.day else { return formatDate(date) }

        switch days {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        case 2 ... 7:
            return "\(days) days ago"
        case 8 ... 30:
            let weeks = days / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        default:
            return formatDate(date)
        }
    }

    // MARK: - Validation Operations

    static func validateReviewItem(_ item: CodeReviewItem) -> Result<Void, ValidationError> {
        if item.title.trimmed.isEmpty {
            return .failure(.emptyTitle)
        }

        if item.description.trimmed.isEmpty {
            return .failure(.emptyDescription)
        }

        if item.title.count > 100 {
            return .failure(.titleTooLong)
        }

        if item.description.count > 500 {
            return .failure(.descriptionTooLong)
        }

        return .success(())
    }

    // MARK: - Private Helper Methods

    private static func calculateAverageCompletionTime(_ items: [CodeReviewItem]) -> TimeInterval? {
        let completedItems = items.filter { $0.status == .completed }

        guard !completedItems.isEmpty else { return nil }

        let completionTimes = completedItems.compactMap { item -> TimeInterval? in
            guard item.status == .completed else { return nil }
            return item.updatedDate.timeIntervalSince(item.createdDate)
        }

        guard !completionTimes.isEmpty else { return nil }

        return completionTimes.reduce(0, +) / Double(completionTimes.count)
    }

    private static func findOldestPendingItem(_ items: [CodeReviewItem]) -> CodeReviewItem? {
        let pendingItems = items.filter { $0.status == .pending }
        return pendingItems.min(by: { $0.createdDate < $1.createdDate })
    }
}

// MARK: - Supporting Types

struct ReviewReport {
    let totalItems: Int
    let completedItems: Int
    let inProgressItems: Int
    let pendingItems: Int
    let blockedItems: Int
    let highPriorityItems: Int
    let mediumPriorityItems: Int
    let lowPriorityItems: Int
    let completionRate: Double
    let averageCompletionTime: TimeInterval?
    let oldestPendingItem: CodeReviewItem?

    var completionPercentage: String {
        String(format: "%.1f%%", completionRate * 100)
    }

    var formattedAverageCompletionTime: String {
        guard let time = averageCompletionTime else { return "N/A" }

        let days = Int(time / 86400)
        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        }

        let hours = Int(time / 3600)
        if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }

        let minutes = Int(time / 60)
        return "\(minutes) minute\(minutes == 1 ? "" : "s")"
    }

    var summaryText: String {
        """
        📈 Review Analytics Report

        📊 Overall Progress:
        • Total Items: \(totalItems)
        • Completion Rate: \(completionPercentage)
        • Average Completion Time: \(formattedAverageCompletionTime)

        🔄 Status Breakdown:
        • ✅ Completed: \(completedItems)
        • 🔄 In Progress: \(inProgressItems)
        • ⏳ Pending: \(pendingItems)
        • 🚫 Blocked: \(blockedItems)

        🎯 Priority Distribution:
        • 🔴 High: \(highPriorityItems)
        • 🟡 Medium: \(mediumPriorityItems)
        • 🟢 Low: \(lowPriorityItems)

        \(oldestPendingItem != nil ? "⏰ Oldest Pending: \(oldestPendingItem!.title)" : "")
        """
    }
}

enum ValidationError: Error, LocalizedError {
    case emptyTitle
    case emptyDescription
    case titleTooLong
    case descriptionTooLong

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            "Title cannot be empty"
        case .emptyDescription:
            "Description cannot be empty"
        case .titleTooLong:
            "Title must be 100 characters or less"
        case .descriptionTooLong:
            "Description must be 500 characters or less"
        }
    }
}
