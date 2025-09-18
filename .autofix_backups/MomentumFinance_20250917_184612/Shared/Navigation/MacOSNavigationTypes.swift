// Momentum Finance - macOS Navigation Types
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

#if os(macOS)
// Sidebar navigation items
public enum SidebarItem: Hashable {
    case dashboard
    case transactions
    case budgets
    case subscriptions
    case goalsAndReports
}

// Listable items for the content column
public struct ListableItem: Identifiable, Hashable {
    public let id: String?
    public let name: String
    public let type: ListItemType

    public var identifier: String {
        "\(self.type)_\(self.id ?? "unknown")"
    }

    // Identifiable conformance
    public var identifierId: String { self.identifier }

    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }

    public static func == (lhs: ListableItem, rhs: ListableItem) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public init(id: String?, name: String, type: ListItemType) {
        self.id = id
        self.name = name
        self.type = type
    }
}

// Types of items that can be displayed in the content column
public enum ListItemType: Hashable {
    case account
    case transaction
    case budget
    case subscription
    case goal
    case report
}
#endif
