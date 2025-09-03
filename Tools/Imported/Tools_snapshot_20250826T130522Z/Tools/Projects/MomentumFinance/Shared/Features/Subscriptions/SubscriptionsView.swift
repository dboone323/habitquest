<<<<<<< HEAD
import UIKit
import SwiftData
import SwiftUI
import UIKit
=======
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif
>>>>>>> 1cf3938 (Create working state for recovery)

//
//  SubscriptionsView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

extension Features.Subscriptions {
    // MARK: - Subscription Filter Enum

    enum SubscriptionFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case inactive = "Inactive"
        case dueSoon = "Due Soon"
    }

    // MARK: - Main Subscriptions View

    struct SubscriptionsView: View {
        @State private var viewModel = SubscriptionsViewModel()
        @Environment(\.modelContext)
        private var modelContext
<<<<<<< HEAD
        @Query(sort: \Subscription.nextDueDate, order: .forward)
        private var subscriptions: [Subscription]
        @Query private var categories: [ExpenseCategory]
        @Query private var accounts: [FinancialAccount]
=======
        // Use simple stored arrays for now to keep builds stable across toolchains.
        private var subscriptions: [Subscription] = []
        private var categories: [ExpenseCategory] = []
        private var accounts: [FinancialAccount] = []
>>>>>>> 1cf3938 (Create working state for recovery)

        @State private var showingAddSubscription = false
        @State private var selectedSubscription: Subscription?
        @State private var selectedFilter: SubscriptionFilter = .all

        // Search functionality
        @State private var showingSearch = false
<<<<<<< HEAD
        @State private var navigationCoordinator = NavigationCoordinator.shared
=======
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
>>>>>>> 1cf3938 (Create working state for recovery)

        // Cross-platform color support
        private var backgroundColor: Color {
            #if canImport(UIKit)
<<<<<<< HEAD
            return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.white
=======
                return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
                return Color(NSColor.controlBackgroundColor)
            #else
                return Color.white
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        private var secondaryBackgroundColor: Color {
            #if canImport(UIKit)
<<<<<<< HEAD
            return Color(UIColor.systemGroupedBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.gray.opacity(0.1)
=======
                return Color(UIColor.systemGroupedBackground)
            #elseif canImport(AppKit)
                return Color(NSColor.controlBackgroundColor)
            #else
                return Color.gray.opacity(0.1)
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        private var toolbarPlacement: ToolbarItemPlacement {
            #if canImport(UIKit)
<<<<<<< HEAD
            return .navigationBarTrailing
            #else
            return .primaryAction
=======
                return .navigationBarTrailing
            #else
                return .primaryAction
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        private var filteredSubscriptions: [Subscription] {
            switch selectedFilter {
            case .all:
                return subscriptions
            case .active:
                return subscriptions.filter(\.isActive)
            case .inactive:
                return subscriptions.filter { !$0.isActive }
            case .dueSoon:
<<<<<<< HEAD
                let sevenDaysFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
=======
                let sevenDaysFromNow =
                    Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
>>>>>>> 1cf3938 (Create working state for recovery)
                return subscriptions.filter { $0.isActive && $0.nextDueDate <= sevenDaysFromNow }
            }
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Header Section
                    SubscriptionHeaderView(
                        subscriptions: subscriptions,
                        selectedFilter: $selectedFilter,
                        showingAddSubscription: $showingAddSubscription,
<<<<<<< HEAD
                        )
=======
                    )
>>>>>>> 1cf3938 (Create working state for recovery)

                    // Content Section
                    SubscriptionContentView(
                        filteredSubscriptions: filteredSubscriptions,
                        selectedSubscription: $selectedSubscription,
<<<<<<< HEAD
                        )
=======
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
                }
                .navigationTitle("Subscriptions")
                .toolbar {
                    ToolbarItem(placement: toolbarPlacement) {
                        HStack(spacing: 12) {
                            // Search Button
                            Button {
                                showingSearch = true
<<<<<<< HEAD
                                navigationCoordinator.activateSearch()
=======
                                NavigationCoordinator.shared.activateSearch()
>>>>>>> 1cf3938 (Create working state for recovery)
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }

                            // Add Subscription Button
<<<<<<< HEAD
                            Button(action: { showingAddSubscription = true }, label: {
                                Image(systemName: "plus")
                            })
=======
                            Button(
                                action: { showingAddSubscription = true },
                                label: {
                                    Image(systemName: "plus")
                                })
>>>>>>> 1cf3938 (Create working state for recovery)
                        }
                    }
                }
                .sheet(isPresented: $showingAddSubscription) {
                    // MARK: - Add Subscription Feature (Implementation pending)

                    Text("Add Subscription - Coming Soon")
                        .padding()
                }
                .sheet(isPresented: $showingSearch) {
                    Features.GlobalSearchView()
                }
                .sheet(item: $selectedSubscription) { subscription in
                    SubscriptionDetailView(subscription: subscription)
                }
                .onAppear {
                    viewModel.setModelContext(modelContext)
                }
                .background(backgroundColor)
            }
        }
<<<<<<< HEAD
=======

        // Provide an explicit initializer so call sites can use `SubscriptionsView()`
        // When SwiftData is available the @Query wrappers manage data; otherwise use provided defaults.
        init(
            subscriptions: [Subscription] = [], categories: [ExpenseCategory] = [],
            accounts: [FinancialAccount] = []
        ) {
            #if !canImport(SwiftData)
                self.subscriptions = subscriptions
                self.categories = categories
                self.accounts = accounts
            #endif
        }
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // MARK: - Header View

    private struct SubscriptionHeaderView: View {
        let subscriptions: [Subscription]
        @Binding var selectedFilter: SubscriptionFilter
        @Binding var showingAddSubscription: Bool

        var body: some View {
            VStack(spacing: 16) {
                // Summary Section

                // MARK: - Enhanced Summary View (Implementation pending)

                VStack {
                    Text("Subscriptions Summary")
                        .font(.headline)
                    Text("\(subscriptions.count) active subscriptions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(SubscriptionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
            .padding()
        }
    }

    // MARK: - Content View

    private struct SubscriptionContentView: View {
        let filteredSubscriptions: [Subscription]
        @Binding var selectedSubscription: Subscription?

        var body: some View {
            if filteredSubscriptions.isEmpty {
                EmptySubscriptionsView()
            } else {
                subscriptionsList
            }
        }

        private var subscriptionsList: some View {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredSubscriptions, id: \.id) { subscription in
                        SubscriptionRowPlaceholder(subscription: subscription)
                            .onTapGesture {
                                selectedSubscription = subscription
                            }
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Placeholder Row View

    private struct SubscriptionRowPlaceholder: View {
        let subscription: Subscription

        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(subscription.name)
                        .font(.headline)
<<<<<<< HEAD
                    Text("$\(subscription.amount, specifier: "%.2f") / \(subscription.billingCycle.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
=======
                    Text(
                        "$\(subscription.amount, specifier: "%.2f") / \(subscription.billingCycle.rawValue)"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
>>>>>>> 1cf3938 (Create working state for recovery)
                }
                Spacer()
                Text(subscription.nextDueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }

    // MARK: - Empty State View

    private struct EmptySubscriptionsView: View {
        var body: some View {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "repeat.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)

                VStack(spacing: 8) {
                    Text("No Subscriptions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Add your first subscription to start tracking recurring payments")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    Features.Subscriptions.SubscriptionsView()
        .modelContainer(for: [Subscription.self, ExpenseCategory.self, FinancialAccount.self])
}
