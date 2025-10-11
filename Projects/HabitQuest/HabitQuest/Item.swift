//
//  Item.swift
//  HabitQuest
//
//  Created by Daniel Stevens on 6/27/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID
    var timestamp: Date
    var title: String
    var notes: String?
    var isCompleted: Bool
    var priority: Priority
    var category: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        title: String = "",
        notes: String? = nil,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        category: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
    }

    // MARK: - Priority Enum

    enum Priority: String, Codable, CaseIterable {
        case low, medium, high, urgent
    }
}
