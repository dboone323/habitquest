import AppKit
import SwiftData
import SwiftUI

#if canImport(AppKit)
#endif

// Temporary ColorTheme stub for macOS compatibility
@Observable
@MainActor
final class ColorTheme {
    static let shared = ColorTheme()

    var background: Color { Color.gray.opacity(0.1) }
    var secondaryBackground: Color { Color.gray.opacity(0.05) }
    var primaryText: Color { Color.primary }
    var secondaryText: Color { Color.secondary }
    var accentPrimary: Color { Color.blue }
    var cardBackground: Color { Color.white }
    var isDarkMode: Bool { false }
}

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

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

        @State private var accounts: [FinancialAccount] = []
        @State private var subscriptions: [Subscription] = []
        @State private var budgets: [Budget] = []

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
                            totalBalance: totalBalanceDouble,
                            monthlyIncome: monthlyIncomeDouble,
                            monthlyExpenses: monthlyExpensesDouble
                        )

                        // Account Balances Summary
                        DashboardAccountsSummary(
                            accounts: accounts,
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
                            onSubscriptionTapped: { _ in
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
                            onBudgetTap: { _ in
                                navigationPath.append(DashboardDestination.budgets)
                            },
                            onViewAllTap: {
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
                    loadData()
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

        private var totalBalanceDouble: Double {
            accounts.reduce(0) { $0 + $1.balance }
        }

        private var monthlyIncomeDouble: Double {
            // Calculate monthly income from transactions
            2_450.0
        }

        private var monthlyExpensesDouble: Double {
            // Calculate monthly expenses from transactions
            1_890.0
        }

        // MARK: - Data Loading

        private func loadData() {
            do {
                let accountDescriptor = FetchDescriptor<FinancialAccount>()
                accounts = try modelContext.fetch(accountDescriptor)

                let subscriptionDescriptor = FetchDescriptor<Subscription>()
                subscriptions = try modelContext.fetch(subscriptionDescriptor)

                let budgetDescriptor = FetchDescriptor<Budget>()
                budgets = try modelContext.fetch(budgetDescriptor)
            } catch {
                print("Error loading dashboard data: \(error)")
            }
        }
    }
}

#Preview {
    Features.Dashboard.DashboardView()
        .modelContainer(for: [FinancialAccount.self, Subscription.self, Budget.self])
}
