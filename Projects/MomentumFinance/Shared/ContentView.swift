// filepath: /Users/danielstevens/Desktop/MomentumFinaceApp/Shared/ContentView.swift
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

// Temporary placeholder views until namespace issues are resolved
public struct DashboardView: View {
    public var body: some View {
        Features.FinancialDashboard.DashboardView()
    }
}

// MARK: - Tab Content Views

private struct DashboardTabView: View {
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    var body: some View {
        NavigationStack(
            path: Binding(
                get: { self.navigationCoordinator.dashboardNavPath },
                set: { self.navigationCoordinator.dashboardNavPath = $0 }
            )
        ) {
            DashboardView()
        }
    }
}

private struct TransactionsTabView: View {
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    var body: some View {
        NavigationStack(
            path: Binding(
                get: { self.navigationCoordinator.transactionsNavPath },
                set: { self.navigationCoordinator.transactionsNavPath = $0 }
            )
        ) {
            Features.Transactions.TransactionsView()
        }
    }
}

private struct BudgetsTabView: View {
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    var body: some View {
        NavigationStack(
            path: Binding(
                get: { self.navigationCoordinator.budgetsNavPath },
                set: { self.navigationCoordinator.budgetsNavPath = $0 }
            )
        ) {
            Features.Budgets.BudgetsView()
        }
    }
}

private struct SubscriptionsTabView: View {
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    var body: some View {
        NavigationStack(
            path: Binding(
                get: { self.navigationCoordinator.subscriptionsNavPath },
                set: { self.navigationCoordinator.subscriptionsNavPath = $0 }
            )
        ) {
            Features.Subscriptions.SubscriptionsView()
        }
    }
}

private struct GoalsAndReportsTabView: View {
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    var body: some View {
        NavigationStack(
            path: Binding(
                get: { self.navigationCoordinator.goalsAndReportsNavPath },
                set: { self.navigationCoordinator.goalsAndReportsNavPath = $0 }
            )
        ) {
            Features.GoalsAndReports.GoalsAndReportsView()
        }
    }
}

public struct ContentView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator.shared
    @State private var isGlobalSearchPresented = false

    public var body: some View {
        TabView(
            selection: Binding(
                get: { self.navigationCoordinator.selectedTab },
                set: { self.navigationCoordinator.selectedTab = $0 }
            )
        ) {
            DashboardTabView()
                .tabItem {
                    Image(systemName: self.navigationCoordinator.selectedTab == 0 ? "house.fill" : "house")
                    Text("Dashboard")
                }
                .tag(0)

            TransactionsTabView()
                .tabItem {
                    Image(
                        systemName: self.navigationCoordinator.selectedTab == 1
                            ? "creditcard.fill" : "creditcard"
                    )
                    Text("Transactions")
                }
                .tag(1)

            BudgetsTabView()
                .tabItem {
                    Image(
                        systemName: self.navigationCoordinator.selectedTab == 2
                            ? "chart.pie.fill" : "chart.pie"
                    )
                    Text("Budgets")
                }
                .tag(2)

            SubscriptionsTabView()
                .tabItem {
                    Image(
                        systemName: self.navigationCoordinator.selectedTab == 3
                            ? "calendar.badge.clock.fill" : "calendar.badge.clock"
                    )
                    Text("Subscriptions")
                }
                .tag(3)

            GoalsAndReportsTabView()
                .tabItem {
                    Image(
                        systemName: self.navigationCoordinator.selectedTab == 4
                            ? "chart.bar.fill" : "chart.bar"
                    )
                    Text("Goals & Reports")
                }
                .tag(4)
        }
        .sheet(isPresented: self.$isGlobalSearchPresented) {
            Features.GlobalSearch.GlobalSearchView()
        }
        .environmentObject(self.navigationCoordinator)
        .onChange(of: self.navigationCoordinator.isSearchActive) { _, newValue in
            self.isGlobalSearchPresented = newValue
        }
        #if os(iOS)
        .onAppear {
            // Configure navigation bar appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .iOSOptimizations()
        #elseif os(macOS)
        .macOSOptimizations()
        #endif
    }
}

#if os(iOS)
    extension View {
        /// <#Description#>
        /// - Returns: <#description#>
        func iOSOptimizations() -> some View {
            tint(.blue)
        }
    }

#elseif os(macOS)
    extension View {
        /// <#Description#>
        /// - Returns: <#description#>
        func macOSOptimizations() -> some View {
            preferredColorScheme(.light)
                .tint(.indigo)
        }
    }
#endif
