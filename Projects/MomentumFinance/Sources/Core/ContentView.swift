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

public struct ContentView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator.shared
    @State private var isGlobalSearchPresented = false

    public var body: some View {
        TabView(
            selection: Binding(
                get: { self.navigationCoordinator.selectedTab },
                set: { self.navigationCoordinator.selectedTab = $0 },
            )
        ) {
            NavigationStack(
                path: Binding(
                    get: { self.navigationCoordinator.dashboardNavPath },
                    set: { self.navigationCoordinator.dashboardNavPath = $0 },
                )
            ) {
                DashboardView()
            }
            .tabItem {
                Image(systemName: self.navigationCoordinator.selectedTab == 0 ? "house.fill" : "house")
                Text("Dashboard")
            }
            .tag(0)

            NavigationStack(
                path: Binding(
                    get: { self.navigationCoordinator.transactionsNavPath },
                    set: { self.navigationCoordinator.transactionsNavPath = $0 },
                )
            ) {
                Features.Transactions.TransactionsView()
            }
            .tabItem {
                Image(
                    systemName: self.navigationCoordinator.selectedTab == 1
                        ? "creditcard.fill" : "creditcard"
                )
                Text("Transactions")
            }
            .tag(1)

            NavigationStack(
                path: Binding(
                    get: { self.navigationCoordinator.budgetsNavPath },
                    set: { self.navigationCoordinator.budgetsNavPath = $0 },
                )
            ) {
                Features.Budgets.BudgetsView()
            }
            .tabItem {
                Image(
                    systemName: self.navigationCoordinator.selectedTab == 2
                        ? "chart.pie.fill" : "chart.pie"
                )
                Text("Budgets")
            }
            .tag(2)

            NavigationStack(
                path: Binding(
                    get: { self.navigationCoordinator.subscriptionsNavPath },
                    set: { self.navigationCoordinator.subscriptionsNavPath = $0 },
                )
            ) {
                Features.Subscriptions.SubscriptionsView()
            }
            .tabItem {
                Image(
                    systemName: self.navigationCoordinator.selectedTab == 3
                        ? "calendar.badge.clock.fill" : "calendar.badge.clock"
                )
                Text("Subscriptions")
            }
            .tag(3)

            NavigationStack(
                path: Binding(
                    get: { self.navigationCoordinator.goalsAndReportsNavPath },
                    set: { self.navigationCoordinator.goalsAndReportsNavPath = $0 },
                )
            ) {
                Features.GoalsAndReports.GoalsAndReportsView()
            }
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
        platformOptimizations() // Now uses shared implementation
    }
}

#elseif os(macOS)
extension View {
    /// <#Description#>
    /// - Returns: <#description#>
    func macOSOptimizations() -> some View {
        platformOptimizations() // Now uses shared implementation
    }
}
#endif
