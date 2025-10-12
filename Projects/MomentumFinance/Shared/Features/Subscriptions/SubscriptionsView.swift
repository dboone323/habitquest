import UIKit
import SwiftUI

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

    public enum SubscriptionFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case inactive = "Inactive"
        case dueSoon = "Due Soon"
    }

    // MARK: - Header View

    public struct SubscriptionHeaderView: View {
        let subscriptions: [Subscription]
        @Binding var selectedFilter: SubscriptionFilter
        @Binding var showingAddSubscription: Bool

        private var viewModel = SubscriptionsViewModel()

        public init(subscriptions: [Subscription], selectedFilter: Binding<SubscriptionFilter>, showingAddSubscription: Binding<Bool>) {
            self.subscriptions = subscriptions
            _selectedFilter = selectedFilter
            _showingAddSubscription = showingAddSubscription
        }

        public var body: some View {
            VStack(spacing: 16) {
                // Enhanced Summary Section
                SubscriptionSummaryCard(subscriptions: self.subscriptions)

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

    // MARK: - Subscription Summary Card

    public struct SubscriptionSummaryCard: View {
        let subscriptions: [Subscription]

        private var viewModel = SubscriptionsViewModel()

        private var activeSubscriptions: [Subscription] {
            self.subscriptions.filter(\.isActive)
        }

        private var totalMonthlyCost: Double {
            self.viewModel.totalMonthlyAmount(self.activeSubscriptions)
        }

        private var subscriptionsDueThisWeek: [Subscription] {
            self.viewModel.subscriptionsDueThisWeek(self.activeSubscriptions)
        }

        private var overdueSubscriptions: [Subscription] {
            self.viewModel.overdueSubscriptions(self.activeSubscriptions)
        }

        public init(subscriptions: [Subscription]) {
            self.subscriptions = subscriptions
        }

        public var body: some View {
            VStack(spacing: 16) {
                // Total Monthly Cost
                HStack {
                    VStack(alignment: .leading) {
                        Text("Monthly Total")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(self.totalMonthlyCost.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Image(systemName: "creditcard.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }

                // Quick Stats
                HStack(spacing: 20) {
                    StatItem(
                        title: "Active",
                        value: "\(self.activeSubscriptions.count)",
                        color: .green
                    )

                    StatItem(
                        title: "Due Soon",
                        value: "\(self.subscriptionsDueThisWeek.count)",
                        color: self.subscriptionsDueThisWeek.isEmpty ? .secondary : .orange
                    )

                    StatItem(
                        title: "Overdue",
                        value: "\(self.overdueSubscriptions.count)",
                        color: self.overdueSubscriptions.isEmpty ? .secondary : .red
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }

    // MARK: - Stat Item View

    private struct StatItem: View {
        let title: String
        let value: String
        let color: Color

        var body: some View {
            VStack(spacing: 4) {
                Text(self.value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.color)
                Text(self.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
                        SubscriptionRowView(subscription: subscription)
                            .onTapGesture {
                                self.selectedSubscription = subscription
                            }
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Subscription Row View

    private struct SubscriptionRowView: View {
        let subscription: Subscription

        private var dueStatusColor: Color {
            if self.subscription.daysUntilDue < 0 {
                .red // Overdue
            } else if self.subscription.daysUntilDue <= 3 {
                .orange // Due soon
            } else if self.subscription.daysUntilDue <= 7 {
                .yellow.opacity(0.7) // Due this week
            } else {
                .green // Not due soon
            }
        }

        private var dueStatusText: String {
            if self.subscription.daysUntilDue < 0 {
                "Overdue"
            } else if self.subscription.daysUntilDue == 0 {
                "Due Today"
            } else if self.subscription.daysUntilDue == 1 {
                "Due Tomorrow"
            } else {
                "Due in \(self.subscription.daysUntilDue) days"
            }
        }

        var body: some View {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(self.dueStatusColor.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: self.subscription.icon)
                        .foregroundColor(self.dueStatusColor)
                        .font(.system(size: 18))
                }

                // Subscription Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.subscription.name)
                        .font(.headline)
                        .foregroundColor(self.subscription.isActive ? .primary : .secondary)

                    HStack(spacing: 8) {
                        Text(self.subscription.formattedAmount)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Text(self.subscription.billingCycle.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Due status
                    Text(self.dueStatusText)
                        .font(.caption)
                        .foregroundColor(self.dueStatusColor)
                        .fontWeight(.medium)
                }

                Spacer()

                // Next due date
                VStack(alignment: .trailing, spacing: 2) {
                    Text(self.subscription.nextDueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if !self.subscription.isActive {
                        Text("Inactive")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(self.dueStatusColor.opacity(self.subscription.daysUntilDue <= 3 ? 0.3 : 0), lineWidth: 1)
            )
        }
    }

    // MARK: - Empty Subscriptions View

    private struct EmptySubscriptionsView: View {
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "creditcard")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary.opacity(0.5))

                Text("No Subscriptions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Text("Add your first subscription to start tracking recurring payments.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 60)
        }
    }

    // MARK: - Add Subscription View

    public struct AddSubscriptionView: View {
        @Environment(\.dismiss)
        private var dismiss
        @Environment(\.modelContext)
        private var modelContext

        // Temporarily use stored-array fallbacks (no SwiftData @Query) to avoid
        // 'unknown attribute Query' compile errors on the current toolchain.
        private var categories: [ExpenseCategory] = []
        private var accounts: [FinancialAccount] = []

        @State private var name = ""
        @State private var amount = ""
        @State private var frequency = BillingCycle.monthly
        @State private var nextDueDate = Date()
        @State private var selectedCategory: ExpenseCategory?
        @State private var selectedAccount: FinancialAccount?
        @State private var notes = ""
        @State private var isActive = true

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

        private var isValidForm: Bool {
            !self.name.isEmpty && !self.amount.isEmpty && Double(self.amount) != nil
                && Double(self.amount)! > 0
        }

        public var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Subscription Details")) {
                        TextField("Subscription Name", text: self.$name).accessibilityLabel("Text Field").accessibilityLabel(
                            "Text Field"
                        )

                        HStack {
                            Text("$")
                            TextField("Amount", text: self.$amount).accessibilityLabel("Text Field").accessibilityLabel("Text Field")
                            #if canImport(UIKit)
                                .keyboardType(.decimalPad)
                            #endif
                        }

                        Picker("Frequency", selection: self.$frequency) {
                            ForEach(BillingCycle.allCases, id: \.self) { freq in
                                Text(freq.rawValue.capitalized).tag(freq)
                            }
                        }

                        DatePicker(
                            "Next Due Date", selection: self.$nextDueDate,
                            displayedComponents: .date
                        )

                        Toggle("Active", isOn: self.$isActive)
                    }

                    Section(header: Text("Organization")) {
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

                    Section(header: Text("Notes")) {
                        TextField("Notes (optional)", text: self.$notes, axis: .vertical)
                            .lineLimit(3 ... 6)
                            .accessibilityLabel("Text Field")
                    }
                }
                .navigationTitle("Add Subscription")
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                    .toolbar(content: {
                        #if os(iOS)
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                self.dismiss()
                            }
                            .accessibilityLabel("Cancel Button")
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                self.saveSubscription()
                            }
                            .disabled(!self.isValidForm)
                            .accessibilityLabel("Save Button")
                        }
                        #else
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                self.dismiss()
                            }
                            .accessibilityLabel("Cancel Button")
                        }

                        ToolbarItem(placement: .primaryAction) {
                            Button("Save") {
                                self.saveSubscription()
                            }
                            .disabled(!self.isValidForm)
                            .accessibilityLabel("Save Button")
                        }
                        #endif
                    })
                    .background(self.backgroundColor)
            }
        }

        private func saveSubscription() {
            guard let amountValue = Double(amount) else { return }

            let subscription = Subscription(
                name: name,
                amount: amountValue,
                billingCycle: frequency,
                nextDueDate: nextDueDate,
                notes: notes.isEmpty ? nil : self.notes,
            )

            subscription.category = self.selectedCategory
            subscription.account = self.selectedAccount
            subscription.isActive = self.isActive

            self.modelContext.insert(subscription)

            do {
                try self.modelContext.save()
                self.dismiss()
            } catch {
                Logger.logError(error, context: "Failed to save subscription")
            }
        }
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
                return self.subscriptions.filter {
                    $0.isActive && $0.nextDueDate <= sevenDaysFromNow
                }
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
                .toolbar(content: {
                    ToolbarItem(placement: self.toolbarPlacement) {
                        HStack(spacing: 12) {
                            Button {
                                self.showingSearch = true
                                NavigationCoordinator.shared.activateSearch()
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            .accessibilityLabel("Search Subscriptions")

                            Button(action: { self.showingAddSubscription = true }) {
                                Image(systemName: "plus")
                            }
                            .accessibilityLabel("Add Subscription")
                        }
                    }
                })
                .sheet(isPresented: self.$showingAddSubscription) {
                    AddSubscriptionView()
                }
                .sheet(isPresented: self.$showingSearch) {
                    Features.GlobalSearch.GlobalSearchView()
                }
                .sheet(item: self.$selectedSubscription) { subscription in
                    SubscriptionDetailView(subscription: subscription)
                }
                .onAppear {
                    self.viewModel.setModelContext(self.modelContext)
                    // Schedule renewal notifications for active subscriptions
                    let activeSubscriptions = self.subscriptions.filter(\.isActive)
                    self.viewModel.scheduleSubscriptionNotifications(for: activeSubscriptions)
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
}
