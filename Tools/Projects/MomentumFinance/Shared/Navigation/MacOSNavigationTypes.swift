// Momentum Finance - macOS Navigation Types
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

#if os(macOS)
<<<<<<< HEAD
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
        "\(type)_\(id ?? "unknown")"
    }

    // Identifiable conformance
    public var identifierId: String { identifier }

    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
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
=======
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
            "\(type)_\(id ?? "unknown")"
        }

        // Identifiable conformance
        public var identifierId: String { identifier }

        // Hashable conformance
        public func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
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
>>>>>>> 1cf3938 (Create working state for recovery)
#endif
