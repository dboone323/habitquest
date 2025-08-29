//
//  CodeReviewManager.swift
//  CodingReviewer
//
//  Created by Quantum Automation on 2025-08-29.
//

import Foundation

class CodeReviewManager {

    // MARK: - Properties

    private var reviewItems: [CodeReviewItem] = []
    private var currentReviewIndex: Int = 0

    // MARK: - Initialization

    init() {
        loadSampleData()
    }

    // MARK: - Public Methods

    func getCurrentReviewItem() -> CodeReviewItem? {
        guard currentReviewIndex < reviewItems.count else { return nil }
        return reviewItems[currentReviewIndex]
    }

    func moveToNextItem() -> Bool {
        guard currentReviewIndex + 1 < reviewItems.count else { return false }
        currentReviewIndex += 1
        return true
    }

    func moveToPreviousItem() -> Bool {
        guard currentReviewIndex > 0 else { return false }
        currentReviewIndex -= 1
        return true
    }

    func getReviewProgress() -> (current: Int, total: Int) {
        (currentReviewIndex + 1, reviewItems.count)
    }

    // MARK: - Private Methods

    private func loadSampleData() {
        // Load sample code review items for demonstration
        reviewItems = [
            CodeReviewItem(
                id: "1",
                title: "Implement User Authentication",
                description: "Add secure user login functionality with biometric support",
                priority: .high,
                status: .pending
            ),
            CodeReviewItem(
                id: "2",
                title: "Optimize Database Queries",
                description: "Improve performance of slow database operations",
                priority: .medium,
                status: .inProgress
            ),
            CodeReviewItem(
                id: "3",
                title: "Update UI Components",
                description: "Modernize the user interface with new design system",
                priority: .low,
                status: .completed
            ),
        ]
    }
}

// MARK: - Supporting Types

struct CodeReviewItem {
    let id: String
    let title: String
    let description: String
    let priority: Priority
    var status: ReviewStatus
}

enum Priority: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum ReviewStatus: String {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case blocked = "Blocked"
}
