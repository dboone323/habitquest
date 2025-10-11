// Momentum Finance - macOS Shared Types
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
// Sidebar navigation items
enum SidebarItem: Hashable {
    case dashboard
    case transactions
    case budgets
    case subscriptions
    case goalsAndReports
}

// Listable items for the content column
struct ListableItem: Identifiable, Hashable {
    let id: String?
    let name: String
    let type: ListItemType

    var identifier: String {
        "\(self.type)_\(self.id ?? "unknown")"
    }

    // Identifiable conformance
    var identifierId: String { self.identifier }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }

    static func == (lhs: ListableItem, rhs: ListableItem) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

// Types of items that can be displayed in the content column
enum ListItemType: Hashable {
    case account
    case transaction
    case budget
    case subscription
    case goal
    case report
}

enum SortOrder {
    case dateDescending
    case dateAscending
    case amountDescending
    case amountAscending
}

// macOS-specific UI components and helpers
enum macOSSpecificViews {
    /// macOS window configuration
    static func configureWindow() {
        // Configure macOS-specific window settings
        NSApp.appearance = NSAppearance(named: .aqua)
    }

    /// macOS toolbar configuration
    static func configureToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {}, label: {
                Image(systemName: "gear")
            })
            .help("Settings")

            Button(action: {}, label: {
                Image(systemName: "square.and.arrow.up")
            })
            .help("Export Data")
        }
    }
}

// macOS-specific view extensions
extension View {
    /// Add macOS-specific keyboard shortcuts
    func macOSKeyboardShortcuts() -> some View {
        keyboardShortcut("n", modifiers: .command)
            .keyboardShortcut("w", modifiers: .command)
    }

    /// macOS optimizations
    func macOSOptimizations() -> some View {
        preferredColorScheme(.light)
            .tint(.indigo)
    }
}
#endif
