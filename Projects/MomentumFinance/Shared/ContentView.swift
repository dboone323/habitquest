// filepath: /Users/danielstevens/Desktop/MomentumFinaceApp/Shared/ContentView.swift
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

struct ContentView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator.shared
    @State private var isGlobalSearchPresented = false

    var body: some View {
        TabView(selection: Binding(
            get: { navigationCoordinator.selectedTab },
            set: { navigationCoordinator.selectedTab = $0 },
        )) {
            NavigationStack(path: Binding(
                get: { navigationCoordinator.dashboardNavPath },
                set: { navigationCoordinator.dashboardNavPath = $0 },
            )) {
                Features.Dashboard.DashboardView()
            }
            .tabItem {
                Image(systemName: navigationCoordinator.selectedTab == 0 ? "house.fill" : "house")
                Text("Dashboard")
            }
            .tag(0)

            NavigationStack(path: Binding(
                get: { navigationCoordinator.transactionsNavPath },
                set: { navigationCoordinator.transactionsNavPath = $0 },
            )) {
                Features.Transactions.TransactionsView()
            }
            .tabItem {
                Image(systemName: navigationCoordinator.selectedTab == 1 ? "creditcard.fill" : "creditcard")
                Text("Transactions")
            }
            .tag(1)

            NavigationStack(path: Binding(
                get: { navigationCoordinator.budgetsNavPath },
                set: { navigationCoordinator.budgetsNavPath = $0 },
            )) {
                Features.Budgets.BudgetsView()
            }
            .tabItem {
                Image(systemName: navigationCoordinator.selectedTab == 2 ? "chart.pie.fill" : "chart.pie")
                Text("Budgets")
            }
            .tag(2)

            NavigationStack(path: Binding(
                get: { navigationCoordinator.subscriptionsNavPath },
                set: { navigationCoordinator.subscriptionsNavPath = $0 },
            )) {
                Features.Subscriptions.SubscriptionsView()
            }
            .tabItem {
                Image(systemName: navigationCoordinator.selectedTab == 3 ? "calendar.badge.clock.fill" : "calendar.badge.clock")
                Text("Subscriptions")
            }
            .tag(3)

            NavigationStack(path: Binding(
                get: { navigationCoordinator.goalsAndReportsNavPath },
                set: { navigationCoordinator.goalsAndReportsNavPath = $0 },
            )) {
                Features.GoalsAndReports.GoalsAndReportsView()
            }
            .tabItem {
                Image(systemName: navigationCoordinator.selectedTab == 4 ? "chart.bar.fill" : "chart.bar")
                Text("Goals & Reports")
            }
            .tag(4)
        }
        .sheet(isPresented: $isGlobalSearchPresented) {
            Features.GlobalSearchView()
        }
        .environmentObject(navigationCoordinator)
        .onChange(of: navigationCoordinator.isSearchActive) { _, newValue in
            isGlobalSearchPresented = newValue
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
            self
                .tint(.blue)
        }
    }

#elseif os(macOS)
    extension View {
        /// <#Description#>
        /// - Returns: <#description#>
        func macOSOptimizations() -> some View {
            self
                .preferredColorScheme(.light)
                .tint(.indigo)
        }
    }
#endif
