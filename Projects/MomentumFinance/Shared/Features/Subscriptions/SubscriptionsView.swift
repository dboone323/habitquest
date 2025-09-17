import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(AppKit)
#endif

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
        // Use simple stored arrays for now to keep builds stable across toolchains.
        private var subscriptions: [Subscription] = []
        private var categories: [ExpenseCategory] = []
        private var accounts: [FinancialAccount] = []

        @State private var showingAddSubscription = false
        @State private var selectedSubscription: Subscription?
        @State private var selectedFilter: SubscriptionFilter = .all

        // Search functionality
        @State private var showingSearch = false
        @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

        // Cross-platform color support
        private var backgroundColor: Color {
            #if canImport(UIKit)
            return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.white
            #endif
        }

        private var secondaryBackgroundColor: Color {
            #if canImport(UIKit)
            return Color(UIColor.systemGroupedBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.gray.opacity(0.1)
            #endif
        }

        private var toolbarPlacement: ToolbarItemPlacement {
            #if canImport(UIKit)
            return .navigationBarTrailing
            #else
            return .primaryAction
            #endif
        }

        private var filteredSubscriptions: [Subscription] {
            switch self.selectedFilter {
            case .all:
                return self.subscriptions
            case .active:
                return self.subscriptions.filter(\.isActive)
            case .inactive:
                return self.subscriptions.filter { !$0.isActive }
            case .dueSoon:
                let sevenDaysFromNow =
                    Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                return self.subscriptions.filter { $0.isActive && $0.nextDueDate <= sevenDaysFromNow }
            }
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Header Section
                    SubscriptionHeaderView(
                        subscriptions: self.subscriptions,
                        selectedFilter: self.$selectedFilter,
                        showingAddSubscription: self.$showingAddSubscription,
                    )

                    // Content Section
                    SubscriptionContentView(
                        filteredSubscriptions: self.filteredSubscriptions,
                        selectedSubscription: self.$selectedSubscription,
                    )
                }
                .navigationTitle("Subscriptions")
                .toolbar {
                    ToolbarItem(placement: self.toolbarPlacement) {
                        HStack(spacing: 12) {
                            // Search Button
                            Button {
                                self.showingSearch = true
                                NavigationCoordinator.shared.activateSearch()
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }

                            // Add Subscription Button
                            Button(
                                action: { self.showingAddSubscription = true },
                                label: {
                                    Image(systemName: "plus")
                                }
                            )
                        }
                    }
                }
                .sheet(isPresented: self.$showingAddSubscription) {
                    AddSubscriptionView(categories: self.categories, accounts: self.accounts)
                }
                .sheet(isPresented: self.$showingSearch) {
                    Features.GlobalSearch.GlobalSearchView()
                }
                .sheet(item: self.$selectedSubscription) { subscription in
                    SubscriptionDetailView(subscription: subscription)
                }
                .onAppear {
                    self.viewModel.setModelContext(self.modelContext)
                }
                .background(self.backgroundColor)
            }
        }

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
                    Text("\(self.subscriptions.count) active subscriptions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Filter Picker
                Picker("Filter", selection: self.$selectedFilter) {
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
            if self.filteredSubscriptions.isEmpty {
                EmptySubscriptionsView()
            } else {
                self.subscriptionsList
            }
        }

        private var subscriptionsList: some View {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(self.filteredSubscriptions, id: \.id) { subscription in
                        SubscriptionRowPlaceholder(subscription: subscription)
                            .onTapGesture {
                                self.selectedSubscription = subscription
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
                    Text(self.subscription.name)
                        .font(.headline)
                    Text(
                        "$\(self.subscription.amount, specifier: "%.2f") / \(self.subscription.billingCycle.rawValue)"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                Spacer()
                Text(self.subscription.nextDueDate, style: .date)
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

// MARK: - Add Subscription View

struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amount = ""
    @State private var billingCycle: BillingCycle = .monthly
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedAccount: FinancialAccount?
    @State private var startDate = Date()
    @State private var notes = ""

    let categories: [ExpenseCategory]
    let accounts: [FinancialAccount]

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription Details") {
                    TextField("Name", text: self.$name)
                    TextField("Amount", text: self.$amount)
                    #if canImport(UIKit)
                        .keyboardType(.decimalPad)
                    #endif

                    Picker("Billing Cycle", selection: self.$billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                }

                Section("Category & Account") {
                    Picker("Category", selection: self.$selectedCategory) {
                        Text("None").tag(ExpenseCategory?.none)
                        ForEach(self.categories, id: \.id) { category in
                            Text(category.name).tag(category as ExpenseCategory?)
                        }
                    }

                    Picker("Account", selection: self.$selectedAccount) {
                        Text("None").tag(FinancialAccount?.none)
                        ForEach(self.accounts, id: \.id) { account in
                            Text(account.name).tag(account as FinancialAccount?)
                        }
                    }
                }

                Section("Additional Info") {
                    DatePicker("Start Date", selection: self.$startDate, displayedComponents: .date)
                    TextField("Notes (Optional)", text: self.$notes)
                }
            }
            .navigationTitle("Add Subscription")
            #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            self.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            self.saveSubscription()
                        }
                        .disabled(self.name.isEmpty || self.amount.isEmpty)
                    }
                }
        }
    }

    private func saveSubscription() {
        guard let amountValue = Double(amount) else { return }

        let subscription = Subscription(
            name: name,
            amount: amountValue,
            billingCycle: billingCycle,
            nextDueDate: startDate
        )

        // Set optional properties
        subscription.category = self.selectedCategory
        subscription.account = self.selectedAccount
        if !self.notes.isEmpty {
            subscription.notes = self.notes
        }

        self.modelContext.insert(subscription)
        self.dismiss()
    }
}
