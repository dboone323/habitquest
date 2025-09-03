<<<<<<< HEAD
import UIKit
import Foundation
import SwiftData
import SwiftUI
import UIKit
=======
import SwiftData
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif
>>>>>>> 1cf3938 (Create working state for recovery)

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

<<<<<<< HEAD
#if os(macOS)
#endif
#if os(iOS)
#endif
// Import InsightsSummaryWidget from the same module
/*
 struct DashboardView: View {
 @Environment(\.modelContext)
 private var modelContext
 @Query private var accounts: [FinancialAccount]
 @Query private var subscriptions: [Subscription]
 @Query private var budgets: [Budget]

 @State private var viewModel = DashboardViewModel()
 // @State private var colorTheme = ColorTheme.shared
 // @State private var themeComponents = ThemeComponents()

 // Navigation state using navigation path
 @State private var navigationPath = NavigationPath()

 // Enum for dashboard destinations
 enum DashboardDestination: Hashable {
 case transactions
 case subscriptions
 case budgets
 case accountDetail(String)
 }

 var body: some View {
 NavigationStack(path: $navigationPath) {
 ScrollView {
 LazyVStack(spacing: 24) {
 // Welcome Header
 welcomeHeader

 // Account Balances Summary
 accountsSummary
 .transition(.asymmetric(
 insertion: .move(edge: .leading).combined(with: .opacity),
 removal: .move(edge: .trailing).combined(with: .opacity)
 ))

 // Upcoming Subscriptions
 upcomingSubscriptionsSection
 .transition(.asymmetric(
 insertion: .move(edge: .trailing).combined(with: .opacity),
 removal: .move(edge: .leading).combined(with: .opacity)
 ))

 // Budget Progress
 budgetProgressSection
 .transition(.asymmetric(
 insertion: .move(edge: .bottom).combined(with: .opacity),
 removal: .move(edge: .top).combined(with: .opacity)
 ))
 }
 .padding(.horizontal, 20)
 .padding(.vertical, 16)
 }
 .background(Color.secondary.opacity(0.05))
 .navigationTitle("Dashboard")
 #if os(iOS)
 .navigationBarTitleDisplayMode(.large)
 #endif
 .onAppear {
 viewModel.setModelContext(modelContext)
 withAnimation(.easeInOut(duration: 0.6)) {
 // Trigger animations
 }
 }
 .task {
 // Process overdue subscriptions asynchronously
 await viewModel.processOverdueSubscriptions(subscriptions)
 }
 .navigationDestination(for: DashboardDestination.self) { destination in
 switch destination {
 case .transactions:
 Features.Transactions.TransactionsView()
 case .subscriptions:
 Features.Subscriptions.SubscriptionsView()
 case .budgets:
 Features.Budgets.BudgetsView()
 case .accountDetail(let accountId):
 // Navigate to account detail (placeholder for now)
 Text("Account Detail: \(accountId)")
 .navigationTitle("Account Details")
 }
 }
 }
 }

 // MARK: - Welcome Header
 private var welcomeHeader: some View {
 VStack(alignment: .leading, spacing: 8) {
 HStack {
 Text("Good \(timeOfDayGreeting)")
 .font(.title2)
 .fontWeight(.semibold)
 .foregroundStyle(.primary)
 Spacer()

 Menu {
 Button(action: {
 // Refresh action
 }) {
 Label("Refresh", systemImage: "arrow.clockwise")
 }
 } label: {
 Image(systemName: "ellipsis.circle")
 .font(.title3)
 .foregroundStyle(.blue)
 }
 }

 Text("Here's a summary of your finances")
 .font(.subheadline)
 .foregroundStyle(colorTheme.secondaryText)
 .padding(.bottom, 8)

 // Financial Wellness Score
 HStack(spacing: 16) {
 Text("Financial Wellness")
 .font(.caption)
 .foregroundStyle(colorTheme.secondaryText)

 Spacer()

 ZStack(alignment: .leading) {
 RoundedRectangle(cornerRadius: 10)
 .fill(colorTheme.secondaryBackground)
 .frame(width: 170, height: 8)

 RoundedRectangle(cornerRadius: 10)
 .fill(colorTheme.savings)
 .frame(width: 170 * Double(70) / 100, height: 8)
 }

 Text("\(Int(Double(70)))%")
 .font(.caption)
 .fontWeight(.medium)
 .foregroundStyle(colorTheme.primaryText)
 }
 .padding(.vertical, 2)
 }
 .themedCardWithHeader(title: "Welcome")
 }

 // MARK: - Accounts Summary
 private var accountsSummary: some View {
 VStack(alignment: .leading, spacing: 12) {
 Text("Account Balances")
 .font(.headline)
 .padding(.horizontal)

 VStack(spacing: 12) {
 HStack {
 Text("Total Balance")
 .font(.headline)
 .foregroundStyle(colorTheme.primaryText)

 Spacer()

 themeComponents.currencyDisplay(
 amount: Decimal(0),
 font: .headline.weight(.semibold)
 )
 }

 Divider()
 .background(colorTheme.secondaryText.opacity(0.3))

 ForEach(accounts.prefix(3)) { account in
 HStack {
 Image(systemName: account.icon)
 .font(.subheadline)
 .foregroundStyle(colorTheme.accentPrimary)
 .frame(width: 24, height: 24)

 Text(account.name)
 .font(.subheadline)
 .foregroundStyle(colorTheme.primaryText)
 .lineLimit(1)

 Spacer()

 themeComponents.currencyDisplay(
 amount: account.balance,
 font: .subheadline.weight(.medium)
 )
 }
 .contentShape(Rectangle())
 .onTapGesture {
 navigationPath.append(DashboardDestination.accountDetail(account.id))
 }

 if account != accounts.prefix(3).last {
 Divider()
 .padding(.leading, 32)
 }
 }

 if accounts.count > 3 {
 Button(action: {
 navigationPath.append(DashboardDestination.transactions)
 }) {
 Text("View All \(accounts.count) Accounts")
 .font(.caption)
 .fontWeight(.medium)
 .foregroundStyle(colorTheme.accentPrimary)
 }
 .padding(.top, 8)
 }
 }
 }
 }

 // MARK: - Upcoming Subscriptions
 private var upcomingSubscriptionsSection: some View {
 themeComponents.cardWithHeader(title: "Upcoming Subscriptions") {
 VStack(spacing: 16) {
 if !subscriptions.isEmpty {
 ForEach(Array(subscriptions.prefix(3)), id: \.element.id) { index, subscription in
 HStack {
 // Icon with colorful background
 ZStack {
 RoundedRectangle(cornerRadius: 8)
 .fill(colorTheme.categoryColors[index % colorTheme.categoryColors.count])
 .frame(width: 36, height: 36)

 Image(systemName: subscription.icon)
 .font(.caption)
 .foregroundStyle(.white)
 }

 VStack(alignment: .leading, spacing: 2) {
 Text(subscription.name)
 .font(.subheadline)
 .foregroundStyle(colorTheme.primaryText)

 Text(formattedDateString(subscription.nextBillingDate))
 .font(.caption)
 .foregroundStyle(colorTheme.secondaryText)
 }

 Spacer()

 themeComponents.currencyDisplay(
 amount: subscription.amount,
 showSign: true,
 font: .subheadline.weight(.medium)
 )
 }
 .contentShape(Rectangle())
 .onTapGesture {
 // Navigate to subscription detail
 }

 if index < min(2, viewModel.upcomingSubscriptions.count - 1) {
 Divider()
 .background(colorTheme.secondaryText.opacity(0.3))
 }
 }

 // View all subscriptions button
 if subscriptions.count > 3 {
 Button(action: {
 navigationPath.append(DashboardDestination.subscriptions)
 }) {
 Text("View All \(subscriptions.count) Subscriptions")
 .font(.caption)
 .fontWeight(.medium)
 .foregroundStyle(colorTheme.accentPrimary)
 }
 .padding(.top, 8)
 }
 } else {
 VStack(spacing: 12) {
 Image(systemName: "repeat.circle")
 .font(.largeTitle)
 .foregroundStyle(colorTheme.secondaryText)

 Text("No active subscriptions")
 .font(.callout)
 .foregroundStyle(colorTheme.secondaryText)

 themeComponents.primaryButton {
 Text("Add Subscription")
 .padding(.vertical, 4)
 }
 .frame(maxWidth: 180)
 }
 .frame(maxWidth: .infinity)
 .padding(.vertical, 20)
 }
 }
 }
 }

 // MARK: - Budget Progress
 private var budgetProgressSection: some View {
 themeComponents.section(title: "Budget Progress") {
 VStack(spacing: 16) {
 if !budgets.isEmpty {
 ForEach(budgets.prefix(3)) { budget in
 VStack(alignment: .leading, spacing: 8) {
 HStack {
 Text(budget.name)
 .font(.subheadline)
 .foregroundStyle(colorTheme.primaryText)

 Spacer()

 themeComponents.currencyDisplay(
 amount: budget.spent,
 isPositive: false,
 font: .subheadline.weight(.medium)
 )

 Text("/")
 .font(.subheadline)
 .foregroundStyle(colorTheme.secondaryText)

 themeComponents.currencyDisplay(
 amount: budget.limit,
 font: .subheadline
 )
 }

 themeComponents.budgetProgressBar(spent: budget.spent, total: budget.limit)
 }
 .contentShape(Rectangle())
 .onTapGesture {
 // Navigate to budget detail
 navigationPath.append(DashboardDestination.budgets)
 }

 if budget != budgets.prefix(3).last {
 Divider()
 .background(colorTheme.secondaryText.opacity(0.3))
 .padding(.vertical, 4)
 }
 }

 if budgets.count > 3 {
 Button(action: {
 navigationPath.append(DashboardDestination.budgets)
 }) {
 Text("View All \(budgets.count) Budgets")
 .font(.caption)
 .fontWeight(.medium)
 .foregroundStyle(colorTheme.accentPrimary)
 }
 .padding(.top, 8)
 }
 } else {
 VStack(spacing: 12) {
 Image(systemName: "chart.pie")
 .font(.largeTitle)
 .foregroundStyle(colorTheme.secondaryText)

 Text("No budgets set up")
 .font(.callout)
 .foregroundStyle(colorTheme.secondaryText)

 themeComponents.primaryButton {
 Text("Create Budget")
 .padding(.vertical, 4)
 }
 .frame(maxWidth: 180)
 }
 .frame(maxWidth: .infinity)
 .padding(.vertical, 20)
 }
 }
 }
 }

 // MARK: - Helper Methods

 private var timeOfDayGreeting: String {
 let hour = Calendar.current.component(.hour, from: Date())
 switch hour {
 case 0..<12: return "morning"
 case 12..<17: return "afternoon"
 default: return "evening"
 }
 }

 private var platformBackgroundGroupedColor: Color {
 colorTheme.groupedBackground
 }

 private func formattedDateString(_ date: Date) -> String {
 let formatter = DateFormatter()
 formatter.dateStyle = .medium
 formatter.timeStyle = .none
 return formatter.string(from: date)
 }
 }
 */

// MARK: - Helper Views

// Temporary Simple Dashboard View
// This is a simplified version to get the build working
struct SimpleDashboardComponentView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query private var accounts: [FinancialAccount]
    @Query private var subscriptions: [Subscription]
    @Query private var budgets: [Budget]
    @AppStorage("selectedTheme")
    private var selectedTheme: String = "system"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    welcomeSection
                    accountsSection
                    subscriptionsSection
                    budgetsSection
                    // Temporarily use a placeholder for InsightsSummaryWidget
                    insightsPlaceholderView
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            #if os(iOS)
            .background(Color(UIColor.systemGroupedBackground))
            #else
            .background(Color.secondary.opacity(0.1))
            #endif
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good \(timeOfDayGreeting)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("Here's a summary of your finances")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Financial wellness indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Wellness")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Text("85%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.mint)

                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                            .foregroundStyle(.mint)
                    }
                }
            }

            // Quick stats
            HStack(spacing: 16) {
                StatCard(title: "Balance", value: totalBalance, color: .mint)
                StatCard(title: "Income", value: monthlyIncome, color: .green)
                StatCard(title: "Expenses", value: monthlyExpenses, color: .red)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Account Balances", icon: "creditcard")

            if !accounts.isEmpty {
                VStack(spacing: 8) {
                    ForEach(accounts, id: \.persistentModelID) { account in
                        AccountRow(account: account)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                EmptyStateView(
                    icon: "creditcard",
                    title: "No accounts",
                    subtitle: "Add your first account to get started",
                    )
            }
        }
    }

    private var subscriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming Subscriptions", icon: "repeat.circle")

            if !subscriptions.isEmpty {
                VStack(spacing: 8) {
                    ForEach(subscriptions.prefix(3), id: \.persistentModelID) { subscription in
                        SubscriptionRow(subscription: subscription)
                    }

                    if subscriptions.count > 3 {
                        Button("View All \(subscriptions.count) Subscriptions") {
                            // Navigate to subscriptions view
                        }
                        .font(.caption)
                        .foregroundStyle(.mint)
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                EmptyStateView(
                    icon: "repeat.circle",
                    title: "No subscriptions",
                    subtitle: "Track your recurring payments",
                    )
            }
        }
    }

    private var budgetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Budget Progress", icon: "chart.pie")

            if !budgets.isEmpty {
                VStack(spacing: 12) {
                    ForEach(budgets.prefix(3), id: \.persistentModelID) { budget in
                        BudgetRow(budget: budget)
                    }

                    if budgets.count > 3 {
                        Button("View All \(budgets.count) Budgets") {
                            // Navigate to budgets view
                        }
                        .font(.caption)
                        .foregroundStyle(.mint)
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                EmptyStateView(
                    icon: "chart.pie",
                    title: "No budgets",
                    subtitle: "Create budgets to track spending",
                    )
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick Actions", icon: "bolt")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    title: "Add Transaction",
                    icon: "plus.circle.fill",
                    color: .mint,
                    ) {
                    // Add transaction action
                }

                QuickActionButton(
                    title: "Pay Bills",
                    icon: "creditcard.fill",
                    color: .blue,
                    ) {
                    // Pay bills action
                }

                QuickActionButton(
                    title: "View Reports",
                    icon: "chart.bar.fill",
                    color: .orange,
                    ) {
                    // View reports action
                }

                QuickActionButton(
                    title: "Set Goals",
                    icon: "target",
                    color: .purple,
                    ) {
                    // Set goals action
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0 ..< 12: return "Morning"
        case 12 ..< 17: return "Afternoon"
        default: return "Evening"
        }
    }

    private var totalBalance: String {
        let total = accounts.reduce(0) { $0 + $1.balance }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
    }

    private var monthlyIncome: String {
        // Calculate monthly income from transactions
        "$2,450"
    }

    private var monthlyExpenses: String {
        // Calculate monthly expenses from transactions
        "$1,890"
    }

    private var insightsPlaceholderView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)

                Spacer()

                Button("Details") {
                    // Action will be implemented later
                }
                .font(.subheadline)
                .foregroundColor(.accentColor)
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                    Text("Monthly spending is 15% lower than last month")
                        .font(.subheadline)
                }

                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    Text("Savings increased by 8% this month")
                        .font(.subheadline)
                }

                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                    Text("3 subscriptions will renew next week")
                        .font(.subheadline)
                }
            }
            .padding(.top, 5)
        }
        .padding(15)
        #if os(iOS)
        .background(Color(UIColor.secondarySystemBackground))
        #else
        .background(Color.secondary.opacity(0.1))
        #endif
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.mint)

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct AccountRow: View {
    let account: FinancialAccount

    var body: some View {
        HStack {
            Image(systemName: account.iconName)
                .foregroundStyle(.mint)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text(account.accountType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("$\(account.balance, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.mint.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: "repeat.circle")
                    .font(.caption)
                    .foregroundStyle(.mint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text("Next: \(subscription.nextDueDate, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("$\(subscription.amount, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.red)
        }
        .padding(.vertical, 4)
    }
}

struct BudgetRow: View {
    let budget: Budget

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("$\(budget.spentAmount, specifier: "%.0f") / $\(budget.limitAmount, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.secondary.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor(for: budget))
                        .frame(width: progressWidth(for: budget, in: geometry.size.width), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }

    private func progressColor(for budget: Budget) -> Color {
        let percentage = budget.progressPercentage
        if percentage > 0.9 { return .red }
        if percentage > 0.7 { return .orange }
        return .mint
    }

    private func progressWidth(for budget: Budget, in totalWidth: CGFloat) -> CGFloat {
        let percentage = min(budget.progressPercentage, 1.0)
        return totalWidth * percentage
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// Connect to Features.Dashboard namespace
extension Features.Dashboard {
    typealias DashboardComponentView = SimpleDashboardComponentView
}
=======
extension Features.Dashboard {
    // Enum for dashboard destinations
    enum DashboardDestination: Hashable {
        case transactions
        case subscriptions
        case budgets
        case accountDetail(String)
    }

    struct DashboardView: View {
        @Environment(\.modelContext) private var modelContext

        #if canImport(SwiftData)
            @Query private var accounts: [FinancialAccount]
            @Query private var subscriptions: [Subscription]
            @Query private var budgets: [Budget]
        #else
            // Fallback arrays when SwiftData Query macro is not available in this build
            private var accounts: [FinancialAccount] = []
            private var subscriptions: [Subscription] = []
            private var budgets: [Budget] = []
        #endif

        @State private var viewModel = DashboardViewModel()
        @State private var navigationPath = NavigationPath()

        private let colorTheme = ColorTheme.shared
        private let themeComponents = ThemeComponents()

        var body: some View {
            NavigationStack(path: $navigationPath) {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Welcome Header
                        DashboardWelcomeHeader(
                            greeting: timeOfDayGreeting,
                            wellnessPercentage: 70,
                            totalBalance: totalBalance,
                            monthlyIncome: monthlyIncome,
                            monthlyExpenses: monthlyExpenses
                        )

                        // Account Balances Summary
                        DashboardAccountsSummary(
                            accounts: accounts,
                            colorTheme: colorTheme,
                            themeComponents: themeComponents,
                            onAccountTap: { accountId in
                                navigationPath.append(DashboardDestination.accountDetail(accountId))
                            },
                            onViewAllTap: {
                                navigationPath.append(DashboardDestination.transactions)
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))

                        // Upcoming Subscriptions
                        DashboardSubscriptionsSection(
                            subscriptions: subscriptions,
                            onSubscriptionTapped: { subscription in
                                // Navigate to subscription detail
                            },
                            onViewAllTapped: {
                                navigationPath.append(DashboardDestination.subscriptions)
                            },
                            onAddTapped: {
                                // Navigate to add subscription
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))

                        // Budget Progress
                        DashboardBudgetProgress(
                            budgets: budgets,
                            onBudgetTapped: { budget in
                                navigationPath.append(DashboardDestination.budgets)
                            },
                            onViewAllTapped: {
                                navigationPath.append(DashboardDestination.budgets)
                            },
                            onCreateTapped: {
                                navigationPath.append(DashboardDestination.budgets)
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))

                        // Insights Section
                        DashboardInsights(
                            insights: [],
                            onDetailsTapped: {
                                // Navigate to insights detail
                            }
                        )

                        // Quick Actions
                        DashboardQuickActions(
                            onAddTransaction: {
                                // Add transaction action
                            },
                            onPayBills: {
                                // Pay bills action  
                            },
                            onViewReports: {
                                // View reports action
                            },
                            onSetGoals: {
                                // Set goals action
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color.secondary.opacity(0.05))
                .navigationTitle("Dashboard")
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.large)
                #endif
                .onAppear {
                    viewModel.setModelContext(modelContext)
                }
                .task {
                    // Process overdue subscriptions asynchronously
                    await viewModel.processOverdueSubscriptions(subscriptions)
                }
                .navigationDestination(for: DashboardDestination.self) { destination in
                    switch destination {
                    case .transactions:
                        Features.Transactions.TransactionsView()
                    case .subscriptions:
                        #if canImport(SwiftData)
                            Features.Subscriptions.SubscriptionsView()
                        #else
                            Text("Subscriptions View - SwiftData not available")
                        #endif
                    case .budgets:
                        Features.Budgets.BudgetsView()
                    case .accountDetail(let accountId):
                        Text("Account Detail: \(accountId)")
                    }
                }
            }
        }

        // MARK: - Computed Properties

        private var timeOfDayGreeting: String {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 0..<12: return "Morning"
            case 12..<17: return "Afternoon"
            default: return "Evening"
            }
        }

        private var totalBalance: String {
            let total = accounts.reduce(0) { $0 + $1.balance }
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
        }

        private var monthlyIncome: String {
            // Calculate monthly income from transactions
            "$2,450"
        }

        private var monthlyExpenses: String {
            // Calculate monthly expenses from transactions  
            "$1,890"
        }
    }
}

#Preview {
    Features.Dashboard.DashboardView()
        .modelContainer(for: [FinancialAccount.self, Subscription.self, Budget.self])
}

>>>>>>> 1cf3938 (Create working state for recovery)
