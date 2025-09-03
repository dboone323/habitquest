// Momentum Finance - macOS-specific ContentView enhancements
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
    // macOS-specific content view implementation using NavigationSplitView
    struct ContentView_macOS: View {
        @State private var navigationCoordinator = NavigationCoordinator.shared
        @State private var selectedSidebarItem: SidebarItem? = .dashboard
        @State private var selectedListItem: ListableItem?
        @State private var columnVisibility = NavigationSplitViewVisibility.all

        var body: some View {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                // Sidebar column
                List(selection: $selectedSidebarItem) {
                    Section("Main") {
                        sidebarItem(title: "Dashboard", icon: "house", item: .dashboard)
                        sidebarItem(title: "Transactions", icon: "creditcard", item: .transactions)
                        sidebarItem(title: "Budgets", icon: "chart.pie", item: .budgets)
                    }

                    Section("Planning") {
                        sidebarItem(title: "Subscriptions", icon: "calendar.badge.clock", item: .subscriptions)
                        sidebarItem(title: "Goals & Reports", icon: "chart.bar", item: .goalsAndReports)
                    }
                }
                .listStyle(.sidebar)
                .frame(minWidth: 220)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: toggleSidebar) {
                            Image(systemName: "sidebar.left")
                        }
                        .help("Toggle Sidebar")
                    }
                }
            } content: {
                // Middle column content (context-sensitive list)
                Group {
                    switch selectedSidebarItem {
                    case .dashboard:
                        Features.Dashboard.DashboardListView()
                    case .transactions:
                        Features.Transactions.TransactionsListView()
                    case .budgets:
                        Features.Budgets.BudgetListView()
                    case .subscriptions:
                        Features.Subscriptions.SubscriptionListView()
                    case .goalsAndReports:
                        Features.GoalsAndReports.GoalsListView()
                    case .none:
                        EmptyView()
                    }
                }
                .frame(minWidth: 300)
            } detail: {
                // Detail column
                Group {
                    if let listItem = selectedListItem {
                        switch listItem.type {
                        case .account:
                            if let id = listItem.id {
                                Features.Transactions.AccountDetailView(accountId: id)
                            }
                        case .transaction:
                            if let id = listItem.id {
                                Features.Transactions.TransactionDetailView(transactionId: id)
                            }
                        case .budget:
                            if let id = listItem.id {
                                Features.Budgets.BudgetDetailView(budgetId: id)
                            }
                        case .subscription:
                            if let id = listItem.id {
                                Features.Subscriptions.SubscriptionDetailView(subscriptionId: id)
                            }
                        case .goal:
                            if let id = listItem.id {
                                Features.GoalsAndReports.SavingsGoalDetailView(goalId: id)
                            }
                        case .report:
                            Features.GoalsAndReports.ReportDetailView(reportType: listItem.id ?? "spending")
                        }
                    } else {
                        // Default view when no item is selected
                        switch selectedSidebarItem {
                        case .dashboard:
                            Features.Dashboard.DashboardView()
                        case .transactions:
                            Text("Select a transaction or account")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        case .budgets:
                            Text("Select a budget")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        case .subscriptions:
                            Text("Select a subscription")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        case .goalsAndReports:
                            Text("Select a goal or report")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        case .none:
                            Text("Select a category")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(minWidth: 450)
            }
            .navigationSplitViewStyle(.balanced)
            .frame(minWidth: 1000, minHeight: 700)
            .macOSOptimizations()
            .onAppear {
                macOSSpecificViews.configureWindow()
            }
        }

        // Helper method to create consistent sidebar items
        private func sidebarItem(title: String, icon: String, item: SidebarItem) -> some View {
            Label(title, systemImage: selectedSidebarItem == item ? "\(icon).fill" : icon)
                .tag(item)
        }

        // Toggle the macOS sidebar
        private func toggleSidebar() {
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }
    }

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

        // Hashable conformance
        /// <#Description#>
        /// - Returns: <#description#>
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(type)
        }

        static func == (lhs: ListableItem, rhs: ListableItem) -> Bool {
            lhs.id == rhs.id && lhs.type == rhs.type
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
        /// <#Description#>
        /// - Returns: <#description#>
        func macOSKeyboardShortcuts() -> some View {
            self
                .keyboardShortcut("n", modifiers: .command)
                .keyboardShortcut("w", modifiers: .command)
        }

        /// macOS optimizations
        /// <#Description#>
        /// - Returns: <#description#>
        func macOSOptimizations() -> some View {
            self
                .preferredColorScheme(.light)
                .tint(.indigo)
        }
    }
#endif
