// Momentum Finance - Subscription Detail View for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
extension Features.Subscriptions {
    /// Subscription detail view optimized for macOS screen real estate
    struct SubscriptionDetailView: View {
        let subscriptionId: String

        @Environment(\.modelContext) private var modelContext
        @Query private var subscriptions: [Subscription]
        @Query private var accounts: [FinancialAccount]
        @Query private var transactions: [FinancialTransaction]
        @State private var isEditing = false
        @State private var editedSubscription: SubscriptionEditModel?
        @State private var selectedTransactionIds: Set<String> = []
        @State private var selectedTimespan: Timespan = .sixMonths
        @State private var showingDeleteConfirmation = false
        @State private var showingCancelFlow = false
        @State private var showingShoppingAlternatives = false
        @State private var validationErrors: [String: String] = [:]
        @State private var showingValidationAlert = false

        private var subscription: Subscription? {
            self.subscriptions.first(where: { $0.id == self.subscriptionId })
        }

        private var relatedTransactions: [FinancialTransaction] {
            guard let subscription, let subscriptionId = subscription.id else { return [] }

            return self.transactions.filter { transaction in
                // Match transactions by subscription ID or by name pattern
                if let relatedSubscriptionId = transaction.subscriptionId, relatedSubscriptionId == subscriptionId {
                    return true
                }

                if transaction.name.lowercased().contains(subscription.name.lowercased()) {
                    return true
                }

                return false
            }.sorted { $0.date > $1.date }
        }

        enum Timespan: String, CaseIterable, Identifiable {
            case threeMonths = "3 Months"
            case sixMonths = "6 Months"
            case oneYear = "1 Year"
            case twoYears = "2 Years"
            case allTime = "All Time"

            var id: String { rawValue }
        }

        var body: some View {
            VStack(spacing: 0) {
                // Top toolbar with actions
                HStack {
                    if let subscription {
                        Text(subscription.name)
                            .font(.title)
                            .bold()
                    }

                    Spacer()

                    Picker("Time Span", selection: self.$selectedTimespan) {
                        ForEach(Timespan.allCases) { timespan in
                            Text(timespan.rawValue).tag(timespan)
                        }
                    }
                    .frame(width: 150)

                    Button(action: { self.isEditing.toggle().accessibilityLabel("Button").accessibilityLabel("Button") }) {
                        Text(self.isEditing ? "Done" : "Edit")
                    }
                    .keyboardShortcut("e", modifiers: .command)

                    Menu {
                        Button("Mark as Paid", action: self.markAsPaid).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Skip Next Payment", action: self.skipNextPayment).accessibilityLabel("Button").accessibilityLabel("Button")
                        Divider()
                        Button("Pause Subscription", action: self.pauseSubscription).accessibilityLabel("Button")
                            .accessibilityLabel("Button")
                        Button("Cancel Subscription...", action: { self.showingCancelFlow = true }).accessibilityLabel("Button")
                            .accessibilityLabel("Button")
                        Divider()
                        Button("Find Alternatives...", action: { self.showingShoppingAlternatives = true }).accessibilityLabel("Button")
                            .accessibilityLabel("Button")
                        Divider()
                        Button("Export as PDF", action: self.exportAsPDF).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Print", action: self.printSubscription).accessibilityLabel("Button").accessibilityLabel("Button")
                        Divider()
                        Button("Delete", role: .destructive).accessibilityLabel("Button").accessibilityLabel("Button") {
                            self.showingDeleteConfirmation = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor))

                Divider()

                if self.isEditing, let subscription {
                    self.editView(for: subscription)
                        .padding()
                        .transition(.opacity)
                } else {
                    self.detailView()
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert("Delete Subscription", isPresented: self.$showingDeleteConfirmation) {
                Button("Cancel", role: .cancel).accessibilityLabel("Button").accessibilityLabel("Button") {}
                Button("Delete", role: .destructive).accessibilityLabel("Button").accessibilityLabel("Button") {
                    self.deleteSubscription()
                }
            } message: {
                Text("Are you sure you want to delete this subscription? This action cannot be undone.")
            }
            .sheet(isPresented: self.$showingCancelFlow) {
                CancellationAssistantView(subscription: self.subscription)
                    .frame(width: 600, height: 500)
            }
            .sheet(isPresented: self.$showingShoppingAlternatives) {
                AlternativesView(subscription: self.subscription)
                    .frame(width: 700, height: 600)
            }
            .onAppear {
                // Initialize edit model if needed
                if let subscription, editedSubscription == nil {
                    self.editedSubscription = SubscriptionEditModel(from: subscription)
                }
            }
        }

        // MARK: - Detail View

        private func detailView() -> some View {
            guard let subscription else {
                return AnyView(
                    ContentUnavailableView(
                        "Subscription Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The subscription you're looking for could not be found.")
                    ),
                )
            }

            return AnyView(
                HStack(spacing: 0) {
                    // Left panel - subscription details and analytics
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Subscription overview
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            SubscriptionLogo(provider: subscription.provider)
                                                .frame(width: 40, height: 40)
                                                .padding(6)
                                                .background(Color(.windowBackgroundColor).opacity(0.5))
                                                .cornerRadius(8)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(subscription.provider)
                                                    .font(.headline)

                                                Text(subscription.category ?? "Subscription")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }

                                        PaymentStatusBadge(status: subscription.nextPaymentDate != nil ? "Active" : "Inactive")
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(subscription.amount.formatted(.currency(code: subscription.currencyCode)))
                                            .font(.system(size: 28, weight: .bold))

                                        Text(self.formatBillingCycle(subscription.billingCycle))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Divider()

                                // Cost breakdown
                                Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 12) {
                                    GridRow {
                                        DetailField(
                                            label: "Monthly Cost",
                                            value: self.calculateMonthlyCost(subscription)
                                                .formatted(.currency(code: subscription.currencyCode))
                                        )

                                        DetailField(
                                            label: "Annual Cost",
                                            value: self.calculateAnnualCost(subscription)
                                                .formatted(.currency(code: subscription.currencyCode))
                                        )
                                    }

                                    GridRow {
                                        if let nextPayment = subscription.nextPaymentDate {
                                            DetailField(
                                                label: "Next Payment",
                                                value: nextPayment.formatted(date: .abbreviated, time: .omitted)
                                            )
                                        } else {
                                            DetailField(label: "Next Payment", value: "Not scheduled")
                                        }

                                        if let startDate = subscription.startDate {
                                            DetailField(label: "Started On", value: startDate.formatted(date: .abbreviated, time: .omitted))
                                        }
                                    }

                                    if let paymentMethod = subscription.paymentMethod {
                                        GridRow {
                                            DetailField(label: "Payment Method", value: paymentMethod)
                                                .gridCellColumns(2)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)

                            // Cost analysis
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Cost Analysis")
                                    .font(.headline)

                                SubscriptionCostChart(subscription: subscription, timespan: self.selectedTimespan)
                                    .frame(height: 220)

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Total Spent")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(self.calculateTotalSpent(subscription).formatted(.currency(code: subscription.currencyCode)))
                                            .font(.headline)
                                    }

                                    Spacer()

                                    VStack(alignment: .center) {
                                        Text("Average Monthly")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(self.calculateMonthlyCost(subscription).formatted(.currency(code: subscription.currencyCode)))
                                            .font(.headline)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text("% of Monthly Budget")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("3.2%")
                                            .font(.headline)
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)

                            // Value assessment
                            ValueAssessmentView(subscription: subscription)

                            // Notes
                            if !subscription.notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.headline)

                                    Text(subscription.notes)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.windowBackgroundColor).opacity(0.2))
                                        .cornerRadius(8)
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)
                            }

                            // Upcoming dates
                            if let nextDate = subscription.nextPaymentDate {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Upcoming Payments")
                                        .font(.headline)

                                    VStack(spacing: 10) {
                                        ForEach(0 ..< 4) { i in
                                            HStack {
                                                if i == 0 {
                                                    Text(nextDate.formatted(date: .abbreviated, time: .omitted))
                                                        .foregroundStyle(.primary)
                                                } else {
                                                    Text(self.calculateFuturePaymentDate(
                                                        from: nextDate,
                                                        offset: i,
                                                        cycle: subscription.billingCycle
                                                    ).formatted(date: .abbreviated, time: .omitted))
                                                        .foregroundStyle(.secondary)
                                                }

                                                Spacer()

                                                Text(subscription.amount.formatted(.currency(code: subscription.currencyCode)))
                                                    .foregroundStyle(i == 0 ? .primary : .secondary)
                                            }
                                            .padding(.vertical, 4)

                                            if i < 3 {
                                                Divider()
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(.windowBackgroundColor).opacity(0.2))
                                    .cornerRadius(8)
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // Right panel - payment history
                    VStack(spacing: 0) {
                        // Transactions header
                        HStack {
                            Text("Payment History")
                                .font(.headline)

                            Spacer()

                            Button(action: self.addTransaction).accessibilityLabel("Button").accessibilityLabel("Button") {
                                Label("Add", systemImage: "plus")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor).opacity(0.5))

                        Divider()

                        // Transactions list
                        if self.relatedTransactions.isEmpty {
                            ContentUnavailableView {
                                Label("No Payment History", systemImage: "creditcard")
                            } description: {
                                Text("No payment records found for this subscription.")
                            } actions: {
                                Button("Add Payment Record").accessibilityLabel("Button").accessibilityLabel("Button") {
                                    self.addTransaction()
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxHeight: .infinity)
                        } else {
                            List(self.relatedTransactions, selection: self.$selectedTransactionIds) {
                                self.paymentRow(for: $0)
                            }
                            .listStyle(.inset)
                        }
                    }
                    .frame(width: 350)
                },
            )
        }

        // MARK: - Edit View

        private func editView(for subscription: Subscription) -> some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Edit Subscription")
                    .font(.title2)

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    // Name field
                    GridRow {
                        Text("Name:")
                            .gridColumnAlignment(.trailing)

                        TextField("Subscription name", text: Binding(
                            get: { self.editedSubscription?.name ?? subscription.name },
                            set: { self.editedSubscription?.name = $0 },
                        ))
                        .textFieldStyle(.roundedBorder)
                    }

                    // Provider field
                    GridRow {
                        Text("Provider:")
                            .gridColumnAlignment(.trailing)

                        TextField("Service provider", text: Binding(
                            get: { self.editedSubscription?.provider ?? subscription.provider },
                            set: { self.editedSubscription?.provider = $0 },
                        ))
                        .textFieldStyle(.roundedBorder)
                    }

                    // Amount field
                    GridRow {
                        Text("Amount:")
                            .gridColumnAlignment(.trailing)

                        HStack {
                            TextField("Amount", value: Binding(
                                get: { self.editedSubscription?.amount ?? subscription.amount },
                                set: { self.editedSubscription?.amount = $0 },
                            ), format: .currency(code: subscription.currencyCode))
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 150)

                            Picker("Currency", selection: Binding(
                                get: { self.editedSubscription?.currencyCode ?? subscription.currencyCode },
                                set: { self.editedSubscription?.currencyCode = $0 },
                            )) {
                                Text("USD").tag("USD")
                                Text("EUR").tag("EUR")
                                Text("GBP").tag("GBP")
                                Text("CAD").tag("CAD")
                            }
                        }
                    }

                    // Billing cycle field
                    GridRow {
                        Text("Billing Cycle:")
                            .gridColumnAlignment(.trailing)

                        Picker("Billing Cycle", selection: Binding(
                            get: { self.editedSubscription?.billingCycle ?? subscription.billingCycle },
                            set: { self.editedSubscription?.billingCycle = $0 },
                        )) {
                            Text("Monthly").tag("monthly")
                            Text("Quarterly").tag("quarterly")
                            Text("Annual").tag("annual")
                            Text("Weekly").tag("weekly")
                            Text("Biweekly").tag("biweekly")
                            Text("Custom").tag("custom")
                        }
                    }

                    // Payment dates
                    GridRow {
                        Text("Start Date:")
                            .gridColumnAlignment(.trailing)

                        DatePicker("Start Date", selection: Binding(
                            get: { self.editedSubscription?.startDate ?? subscription.startDate ?? Date() },
                            set: { self.editedSubscription?.startDate = $0 },
                        ), displayedComponents: .date)
                            .labelsHidden()
                    }

                    GridRow {
                        Text("Next Payment:")
                            .gridColumnAlignment(.trailing)

                        DatePicker("Next Payment", selection: Binding(
                            get: { self.editedSubscription?.nextPaymentDate ?? subscription.nextPaymentDate ?? Date() },
                            set: { self.editedSubscription?.nextPaymentDate = $0 },
                        ), displayedComponents: .date)
                            .labelsHidden()
                    }

                    // Payment method field
                    GridRow {
                        Text("Payment Method:")
                            .gridColumnAlignment(.trailing)

                        Picker("Payment Method", selection: Binding(
                            get: { self.editedSubscription?.paymentMethod ?? subscription.paymentMethod ?? "" },
                            set: { self.editedSubscription?.paymentMethod = $0 },
                        )) {
                            Text("None").tag("")
                            Text("Credit Card").tag("Credit Card")
                            Text("Bank Account").tag("Bank Account")
                            Text("PayPal").tag("PayPal")
                            Text("Apple Pay").tag("Apple Pay")
                        }
                    }

                    // Category field
                    GridRow {
                        Text("Category:")
                            .gridColumnAlignment(.trailing)

                        Picker("Category", selection: Binding(
                            get: { self.editedSubscription?.category ?? subscription.category ?? "" },
                            set: { self.editedSubscription?.category = $0 },
                        )) {
                            Text("None").tag("")
                            Text("Entertainment").tag("Entertainment")
                            Text("Software").tag("Software")
                            Text("Streaming").tag("Streaming")
                            Text("Utilities").tag("Utilities")
                            Text("Other").tag("Other")
                        }
                    }

                    // Auto-renew field
                    GridRow {
                        Text("Auto-renew:")
                            .gridColumnAlignment(.trailing)

                        Toggle("This subscription auto-renews", isOn: Binding(
                            get: { self.editedSubscription?.autoRenews ?? subscription.autoRenews },
                            set: { self.editedSubscription?.autoRenews = $0 },
                        ))
                    }
                }
                .padding(.bottom, 20)

                Text("Notes:")
                    .padding(.top, 10)

                TextEditor(text: Binding(
                    get: { self.editedSubscription?.notes ?? subscription.notes },
                    set: { self.editedSubscription?.notes = $0 },
                ))
                .font(.body)
                .frame(minHeight: 100)
                .padding(4)
                .background(Color(.textBackgroundColor))
                .cornerRadius(4)

                HStack {
                    Spacer()

                    Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.isEditing = false
                        // Reset edited subscription to original
                        if let subscription {
                            self.editedSubscription = SubscriptionEditModel(from: subscription)
                        }
                    }
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.escape, modifiers: [])

                    Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                }
                .padding(.top)
            }
        }

        // MARK: - Supporting Views

        private func paymentRow(for transaction: FinancialTransaction) -> some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)

                    Text(transaction.isReconciled ? "Paid" : "Pending")
                        .font(.caption)
                        .foregroundStyle(transaction.isReconciled ? .green : .orange)
                }

                Spacer()

                Text(transaction.amount.formatted(.currency(code: "USD")))
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }
            .padding(.vertical, 4)
            .contextMenu {
                Button("View Details").accessibilityLabel("Button").accessibilityLabel("Button") {
                    // Navigate to transaction detail
                }

                Button("Edit").accessibilityLabel("Button").accessibilityLabel("Button") {
                    // Edit transaction
                }

                Divider()

                Button("Mark as \(transaction.isReconciled ? "Unpaid" : "Paid").accessibilityLabel("Button").accessibilityLabel("Button")") {
                    self.toggleTransactionStatus(transaction)
                }
            }
        }

        private struct DetailField: View {
            let label: String
            let value: String

            var body: some View {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(self.value)
                        .font(.body)
                }
            }
        }

        private struct SubscriptionLogo: View {
            let provider: String

            // Map common providers to system images
            private var iconName: String {
                switch self.provider.lowercased() {
                case "netflix": "play.tv"
                case "spotify": "music.note"
                case "apple": "apple.logo"
                case "disney": "play.tv.fill"
                case "amazon": "cart"
                case "youtube": "play.rectangle"
                default: "creditcard"
                }
            }

            var body: some View {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))

                    Image(systemName: self.iconName)
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
            }
        }

        private struct PaymentStatusBadge: View {
            let status: String

            private var color: Color {
                switch self.status.lowercased() {
                case "active": .green
                case "inactive": .red
                case "paused": .orange
                default: .gray
                }
            }

            var body: some View {
                Text(self.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(self.color.opacity(0.1))
                    .foregroundColor(self.color)
                    .cornerRadius(4)
            }
        }

        private struct SubscriptionCostChart: View {
            let subscription: Subscription
            let timespan: Timespan

            // Sample data - would be real data in actual implementation
            /// <#Description#>
            /// - Returns: <#description#>
            func generateSampleData() -> [(month: String, amount: Double)] {
                [
                    (month: "Jun", amount: self.subscription.amount),
                    (month: "Jul", amount: self.subscription.amount),
                    (month: "Aug", amount: self.subscription.amount),
                    (month: "Sep", amount: self.subscription.amount),
                    (month: "Oct", amount: self.subscription.amount),
                    (month: "Nov", amount: self.subscription.amount),
                ]
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Chart {
                        ForEach(self.generateSampleData(), id: \.month) { item in
                            BarMark(
                                x: .value("Month", item.month),
                                y: .value("Amount", item.amount),
                            )
                            .foregroundStyle(Color.blue.gradient)
                        }

                        RuleMark(y: .value("Average", self.subscription.amount))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("Monthly: \(self.subscription.amount.formatted(.currency(code: self.subscription.currencyCode)))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
        }

        private struct ValueAssessmentView: View {
            let subscription: Subscription

            // Sample usage data - in a real app, this would be tracked
            @State private var usageRating: Double = 0.7 // 0-1 scale

            // Calculate cost per use
            private var costPerUse: Double {
                // Assuming monthly billing and usage 5 times per month
                self.subscription.amount / 5.0
            }

            private var valueAssessment: String {
                if self.usageRating > 0.8 {
                    "Excellent Value"
                } else if self.usageRating > 0.5 {
                    "Good Value"
                } else if self.usageRating > 0.3 {
                    "Fair Value"
                } else {
                    "Poor Value"
                }
            }

            private var valueColor: Color {
                if self.usageRating > 0.8 {
                    .green
                } else if self.usageRating > 0.5 {
                    .blue
                } else if self.usageRating > 0.3 {
                    .orange
                } else {
                    .red
                }
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Value Assessment")
                        .font(.headline)

                    HStack {
                        VStack(alignment: .center, spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                    .frame(width: 100, height: 100)

                                Circle()
                                    .trim(from: 0, to: self.usageRating)
                                    .stroke(self.valueColor, lineWidth: 10)
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))

                                VStack {
                                    Text(self.valueAssessment)
                                        .font(.headline)
                                        .foregroundStyle(self.valueColor)

                                    Text("\(Int(self.usageRating * 100))%")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Text("Usage Rating")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 20)

                        Divider()
                            .padding(.horizontal, 10)

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Monthly Cost")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(self.subscription.amount.formatted(.currency(code: self.subscription.currencyCode)))
                                    .font(.title2)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Estimated Cost Per Use")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(self.costPerUse.formatted(.currency(code: self.subscription.currencyCode)))
                                    .font(.title3)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Similar Subscriptions Average")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(
                                    "\((self.subscription.amount * 0.9).formatted(.currency(code: self.subscription.currencyCode))) - \((self.subscription.amount * 1.1).formatted(.currency(code: self.subscription.currencyCode)))"
                                )
                                .font(.body)
                            }
                        }
                    }

                    Divider()
                        .padding(.vertical, 4)

                    // Value improvement suggestions
                    Text("Value Improvement Suggestions")
                        .font(.subheadline)
                        .bold()

                    VStack(alignment: .leading, spacing: 6) {
                        BulletPoint(text: "Consider switching to annual billing to save 16%")
                        BulletPoint(text: "3 similar services found with lower monthly costs")
                        BulletPoint(text: "Usage has decreased by 30% in the last 2 months")
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(8)
            }
        }

        private struct BulletPoint: View {
            let text: String

            var body: some View {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .padding(.top, 6)

                    Text(self.text)
                }
            }
        }

        private struct CancellationAssistantView: View {
            let subscription: Subscription?
            @Environment(\.dismiss) private var dismiss

            var body: some View {
                VStack(spacing: 20) {
                    Text("Subscription Cancellation Assistant")
                        .font(.title2)
                        .padding(.top)

                    Text("Let us help you cancel your \(self.subscription?.name ?? "subscription")")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 16) {
                            Image(systemName: "1.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Visit the provider's website")
                                    .font(.headline)

                                if let provider = subscription?.provider {
                                    Button("\(provider).accessibilityLabel("Button").accessibilityLabel("Button") Account Page") {
                                        // Open the website
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }

                        HStack(spacing: 16) {
                            Image(systemName: "2.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Navigate to account settings")
                                    .font(.headline)

                                Text("Look for 'Subscription', 'Membership', or 'Billing' section")
                                    .font(.body)
                            }
                        }

                        HStack(spacing: 16) {
                            Image(systemName: "3.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Find cancellation option")
                                    .font(.headline)

                                Text("Look for 'Cancel', 'End subscription', or 'Manage plan'")
                                    .font(.body)
                            }
                        }

                        HStack(spacing: 16) {
                            Image(systemName: "4.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Confirm cancellation")
                                    .font(.headline)

                                Text("Complete any final steps and get confirmation email")
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    Text("Need to contact customer support?")
                        .font(.headline)

                    if let provider = subscription?.provider {
                        HStack(spacing: 20) {
                            Button("Call \(provider).accessibilityLabel("Button").accessibilityLabel("Button")") {
                                // Call action
                            }
                            .buttonStyle(.bordered)

                            Button("Email Support").accessibilityLabel("Button").accessibilityLabel("Button") {
                                // Email action
                            }
                            .buttonStyle(.bordered)

                            Button("Live Chat").accessibilityLabel("Button").accessibilityLabel("Button") {
                                // Chat action
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Spacer()

                    Button("Close").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.dismiss()
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                }
                .padding()
            }
        }

        private struct AlternativesView: View {
            let subscription: Subscription?
            @Environment(\.dismiss) private var dismiss

            // Sample alternatives data
            let alternatives = [
                (name: "CompetitorA", price: 7.99, features: ["HD Streaming", "2 devices", "Limited library"]),
                (name: "CompetitorB", price: 9.99, features: ["4K Streaming", "4 devices", "Full library", "Downloads"]),
                (
                    name: "CompetitorC",
                    price: 12.99,
                    features: ["4K Streaming", "Unlimited devices", "Full library", "Downloads", "Live TV"]
                ),
            ]

            var body: some View {
                VStack(spacing: 20) {
                    Text("Alternative Services")
                        .font(.title2)
                        .padding(.top)

                    Text("Compare alternatives to \(self.subscription?.name ?? "this service")")
                        .font(.headline)

                    HStack(alignment: .top, spacing: 0) {
                        // Current subscription column
                        VStack(spacing: 0) {
                            Text("Your Subscription")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))

                            Divider()

                            Text(self.subscription?.name ?? "Current")
                                .font(.title3)
                                .padding()

                            Divider()

                            Text(self.subscription?.amount.formatted(.currency(code: self.subscription?.currencyCode ?? "USD")) ?? "$0.00")
                                .font(.title3)
                                .bold()
                                .padding()

                            Divider()

                            VStack(alignment: .leading, spacing: 12) {
                                Feature(text: "Basic Feature", isIncluded: true)
                                Feature(text: "Premium Feature", isIncluded: true)
                                Feature(text: "Advanced Feature", isIncluded: false)
                                Feature(text: "Extra Feature", isIncluded: false)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()

                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)

                        // Alternatives columns
                        ForEach(self.alternatives, id: \.name) { alternative in
                            VStack(spacing: 0) {
                                Text("Alternative")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.secondary.opacity(0.1))

                                Divider()

                                Text(alternative.name)
                                    .font(.title3)
                                    .padding()

                                Divider()

                                Text(alternative.price.formatted(.currency(code: "USD")))
                                    .font(.title3)
                                    .bold()
                                    .padding()

                                Divider()

                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(alternative.features, id: \.self) { feature in
                                        Feature(text: feature, isIncluded: true)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()

                                Spacer()

                                Button("Visit Website").accessibilityLabel("Button").accessibilityLabel("Button") {
                                    // Open website
                                }
                                .buttonStyle(.bordered)
                                .padding(.bottom)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.secondary.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }

                    Button("Close").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.dismiss()
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                    .padding(.top)
                }
                .padding()
            }
        }

        private struct Feature: View {
            let text: String
            let isIncluded: Bool

            var body: some View {
                HStack {
                    Image(systemName: self.isIncluded ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundStyle(self.isIncluded ? .green : .secondary)

                    Text(self.text)
                }
            }
        }

        // MARK: - Supporting Models

        private struct SubscriptionEditModel {
            var name: String
            var provider: String
            var amount: Double
            var billingCycle: String
            var startDate: Date?
            var nextPaymentDate: Date?
            var notes: String
            var currencyCode: String
            var category: String?
            var paymentMethod: String?
            var autoRenews: Bool

            init(from subscription: Subscription) {
                self.name = subscription.name
                self.provider = subscription.provider
                self.amount = subscription.amount
                self.billingCycle = subscription.billingCycle
                self.startDate = subscription.startDate
                self.nextPaymentDate = subscription.nextPaymentDate
                self.notes = subscription.notes
                self.currencyCode = subscription.currencyCode
                self.category = subscription.category
                self.paymentMethod = subscription.paymentMethod
                self.autoRenews = subscription.autoRenews
            }
        }

        // MARK: - Helper Methods

        private func formatBillingCycle(_ cycle: String) -> String {
            switch cycle {
            case "monthly": "Billed Monthly"
            case "annual": "Billed Annually"
            case "quarterly": "Billed Quarterly"
            case "weekly": "Billed Weekly"
            case "biweekly": "Billed Biweekly"
            default: "Custom Billing"
            }
        }

        private func calculateMonthlyCost(_ subscription: Subscription) -> Double {
            switch subscription.billingCycle {
            case "monthly": subscription.amount
            case "annual": subscription.amount / 12
            case "quarterly": subscription.amount / 3
            case "weekly": subscription.amount * 4.33 // Average weeks in a month
            case "biweekly": subscription.amount * 2.17 // Average bi-weeks in a month
            default: subscription.amount
            }
        }

        private func calculateAnnualCost(_ subscription: Subscription) -> Double {
            switch subscription.billingCycle {
            case "monthly": subscription.amount * 12
            case "annual": subscription.amount
            case "quarterly": subscription.amount * 4
            case "weekly": subscription.amount * 52
            case "biweekly": subscription.amount * 26
            default: subscription.amount * 12
            }
        }

        private func calculateTotalSpent(_ subscription: Subscription) -> Double {
            // In a real app, this would sum up actual transactions
            guard let startDate = subscription.startDate else { return 0 }

            let monthsSinceStart = Calendar.current.dateComponents([.month], from: startDate, to: Date()).month ?? 0
            return self.calculateMonthlyCost(subscription) * Double(monthsSinceStart)
        }

        private func calculateFuturePaymentDate(from date: Date, offset: Int, cycle: String) -> Date {
            let calendar = Calendar.current

            switch cycle {
            case "monthly":
                return calendar.date(byAdding: .month, value: offset, to: date) ?? date
            case "annual":
                return calendar.date(byAdding: .year, value: offset, to: date) ?? date
            case "quarterly":
                return calendar.date(byAdding: .month, value: offset * 3, to: date) ?? date
            case "weekly":
                return calendar.date(byAdding: .weekOfYear, value: offset, to: date) ?? date
            case "biweekly":
                return calendar.date(byAdding: .weekOfYear, value: offset * 2, to: date) ?? date
            default:
                return calendar.date(byAdding: .month, value: offset, to: date) ?? date
            }
        }

        // MARK: - Action Methods

        private func saveChanges() {
            guard let subscription, let editData = editedSubscription else {
                self.isEditing = false
                return
            }

            // Update subscription with edited values
            subscription.name = editData.name
            subscription.provider = editData.provider
            subscription.amount = editData.amount
            subscription.billingCycle = editData.billingCycle
            subscription.startDate = editData.startDate
            subscription.nextPaymentDate = editData.nextPaymentDate
            subscription.notes = editData.notes
            subscription.currencyCode = editData.currencyCode
            subscription.category = editData.category
            subscription.paymentMethod = editData.paymentMethod
            subscription.autoRenews = editData.autoRenews

            // Save changes to the model context
            try? self.modelContext.save()

            self.isEditing = false
        }

        private func deleteSubscription() {
            guard let subscription else { return }

            // Delete the subscription from the model context
            self.modelContext.delete(subscription)
            try? self.modelContext.save()

            // Navigate back would happen here
        }

        private func addTransaction() {
            // Logic to add a new transaction for this subscription
        }

        private func toggleTransactionStatus(_ transaction: FinancialTransaction) {
            transaction.isReconciled.toggle()
            try? self.modelContext.save()
        }

        private func markAsPaid() {
            guard let subscription, let nextDate = subscription.nextPaymentDate else { return }

            // Create a new transaction for this payment
            let transaction = FinancialTransaction(
                name: "\(subscription.provider) - \(subscription.name)",
                amount: -subscription.amount,
                date: nextDate,
                notes: "Automatic payment for subscription",
                isReconciled: true,
            )

            transaction.subscriptionId = subscription.id

            // Calculate next payment date based on billing cycle
            if let newNextDate = calculateFuturePaymentDate(from: nextDate, offset: 1, cycle: subscription.billingCycle) {
                subscription.nextPaymentDate = newNextDate
            }

            // Add transaction to the model context
            self.modelContext.insert(transaction)
            try? self.modelContext.save()
        }

        private func skipNextPayment() {
            guard let subscription, let nextDate = subscription.nextPaymentDate else { return }

            // Calculate next payment date based on billing cycle and skip one period
            if let newNextDate = calculateFuturePaymentDate(from: nextDate, offset: 1, cycle: subscription.billingCycle) {
                subscription.nextPaymentDate = newNextDate
                try? self.modelContext.save()
            }
        }

        private func pauseSubscription() {
            guard let subscription else { return }

            // Store the current next payment date for later resumption
            // In a real app, you'd store this in the model
            let savedNextDate = subscription.nextPaymentDate

            // Clear the next payment date to indicate paused status
            subscription.nextPaymentDate = nil
            try? self.modelContext.save()
        }

        private func exportAsPDF() {
            // Implementation for PDF export
        }

        private func printSubscription() {
            // Implementation for printing
        }
    }
}
#endif
