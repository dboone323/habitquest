//
//  CodeReviewManager.swift
//  CodingReviewer
//
//  Created by Quantum Automation on 2025-08-29.
//

import Combine
import Foundation

// MARK: - Code Review Manager

/// Manages code review items using SharedArchitecture patterns
@MainActor
class CodeReviewManager: BaseListViewModel<CodeReviewItem> {

    // MARK: - Properties

    @Published private(set) var currentReviewIndex: Int = 0
    @Published private(set) var reviewStatistics: ReviewStatistics = .init()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init() {
        super.init()
        setupBindings()
        Task {
            await loadItems()
        }
    }

    // MARK: - Public Methods

    func getCurrentReviewItem() -> CodeReviewItem? {
        guard currentReviewIndex < items.count else { return nil }
        return items[currentReviewIndex]
    }

    func moveToNextItem() -> Bool {
        guard currentReviewIndex + 1 < items.count else { return false }
        currentReviewIndex += 1
        return true
    }

    func moveToPreviousItem() -> Bool {
        guard currentReviewIndex > 0 else { return false }
        currentReviewIndex -= 1
        return true
    }

    func getReviewProgress() -> (current: Int, total: Int) {
        (currentReviewIndex + 1, items.count)
    }

    func addReviewItem(_ item: CodeReviewItem) async throws {
        do {
            items.append(item)
            await updateStatistics()
        } catch {
            throw AppError.dataError("Failed to add review item: \(error.localizedDescription)")
        }
    }

    func updateReviewItem(_ item: CodeReviewItem) async throws {
        do {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
                await updateStatistics()
            } else {
                throw AppError.dataError("Review item not found")
            }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.dataError("Failed to update review item: \(error.localizedDescription)")
        }
    }

    func deleteReviewItem(withId id: String) async throws {
        do {
            items.removeAll { $0.id == id }
            await updateStatistics()
        } catch {
            throw AppError.dataError("Failed to delete review item: \(error.localizedDescription)")
        }
    }

    // MARK: - BaseListViewModel Overrides

    override var filteredItems: [CodeReviewItem] {
        if searchText.isEmpty {
            items
        } else {
            items.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                    item.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    override func loadItems() async {
        isLoading = true
        errorMessage = nil

        do {
            // Simulate async loading (replace with actual data service)
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            if items.isEmpty {
                items = loadSampleData()
            }

            await updateStatistics()
        } catch {
            errorMessage = AppError.dataError("Failed to load review items").errorDescription
        }

        isLoading = false
    }

    // MARK: - Private Methods

    private func setupBindings() {
        $items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.updateStatistics()
                }
            }
            .store(in: &cancellables)
    }

    private func loadSampleData() -> [CodeReviewItem] {
        [
            CodeReviewItem(
                id: UUID().uuidString,
                title: "Implement User Authentication",
                description: "Add secure user login functionality with biometric support",
                priority: .high,
                status: .pending,
                createdDate: Date(),
                updatedDate: Date()
            ),
            CodeReviewItem(
                id: UUID().uuidString,
                title: "Optimize Database Queries",
                description: "Improve performance of slow database operations",
                priority: .medium,
                status: .inProgress,
                createdDate: Date().addingTimeInterval(-86400),
                updatedDate: Date()
            ),
            CodeReviewItem(
                id: UUID().uuidString,
                title: "Update UI Components",
                description: "Modernize the user interface with new design system",
                priority: .low,
                status: .completed,
                createdDate: Date().addingTimeInterval(-172_800),
                updatedDate: Date().addingTimeInterval(-86400)
            ),
            CodeReviewItem(
                id: UUID().uuidString,
                title: "Add Unit Tests",
                description: "Implement comprehensive unit test coverage for business logic",
                priority: .high,
                status: .pending,
                createdDate: Date().addingTimeInterval(-259_200),
                updatedDate: Date().addingTimeInterval(-172_800)
            ),
            CodeReviewItem(
                id: UUID().uuidString,
                title: "Security Audit",
                description: "Perform security audit and fix identified vulnerabilities",
                priority: .high,
                status: .inProgress,
                createdDate: Date().addingTimeInterval(-345_600),
                updatedDate: Date()
            ),
        ]
    }

    private func updateStatistics() async {
        let completed = items.count(where: { $0.status == .completed })
        let inProgress = items.count(where: { $0.status == .inProgress })
        let pending = items.count(where: { $0.status == .pending })
        let blocked = items.count(where: { $0.status == .blocked })

        let highPriority = items.count(where: { $0.priority == .high })
        let mediumPriority = items.count(where: { $0.priority == .medium })
        let lowPriority = items.count(where: { $0.priority == .low })

        let totalItems = items.count
        let completionRate = totalItems > 0 ? Double(completed) / Double(totalItems) : 0.0

        reviewStatistics = ReviewStatistics(
            totalItems: totalItems,
            completedItems: completed,
            inProgressItems: inProgress,
            pendingItems: pending,
            blockedItems: blocked,
            highPriorityItems: highPriority,
            mediumPriorityItems: mediumPriority,
            lowPriorityItems: lowPriority,
            completionRate: completionRate
        )
    }
}

// MARK: - Supporting Types

struct CodeReviewItem: Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var priority: Priority
    var status: ReviewStatus
    var createdDate: Date
    var updatedDate: Date
    var assignedTo: String?
    var tags: [String] = []

    init(
        id: String,
        title: String,
        description: String,
        priority: Priority,
        status: ReviewStatus,
        createdDate: Date = Date(),
        updatedDate: Date = Date(),
        assignedTo: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.assignedTo = assignedTo
        self.tags = tags
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CodeReviewItem, rhs: CodeReviewItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum Priority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var color: String {
        switch self {
        case .low: "green"
        case .medium: "orange"
        case .high: "red"
        }
    }

    var sortOrder: Int {
        switch self {
        case .low: 0
        case .medium: 1
        case .high: 2
        }
    }
}

enum ReviewStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case blocked = "Blocked"

    var displayName: String {
        rawValue
    }

    var isActive: Bool {
        self == .inProgress
    }

    var isCompleted: Bool {
        self == .completed
    }
}

struct ReviewStatistics {
    let totalItems: Int
    let completedItems: Int
    let inProgressItems: Int
    let pendingItems: Int
    let blockedItems: Int
    let highPriorityItems: Int
    let mediumPriorityItems: Int
    let lowPriorityItems: Int
    let completionRate: Double

    var completionPercentage: String {
        String(format: "%.1f%%", completionRate * 100)
    }

    var summaryDescription: String {
        """
        Code Review Summary:
        • Total Items: \(totalItems)
        • Completed: \(completedItems) (\(completionPercentage))
        • In Progress: \(inProgressItems)
        • Pending: \(pendingItems)
        • Blocked: \(blockedItems)

        Priority Breakdown:
        • High: \(highPriorityItems)
        • Medium: \(mediumPriorityItems)
        • Low: \(lowPriorityItems)
        """
    }
}
