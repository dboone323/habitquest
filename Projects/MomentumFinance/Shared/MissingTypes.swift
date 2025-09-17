//
//  MissingTypes.swift
//  MomentumFinance
//
//  Temporary file to resolve missing type definitions
//  These should eventually be moved to proper module files
//

import Foundation
import OSLog
import SwiftData
import SwiftUI
import UserNotifications

// MARK: - Platform-specific helpers

/// Get the appropriate background color for the current platform
private func platformBackgroundColor() -> Color {
    #if os(iOS)
    return Color(.systemBackground)
    #elseif os(macOS)
    return Color(nsColor: .windowBackgroundColor)
    #else
    return Color.white
    #endif
}

/// Get the appropriate gray color for the current platform
private func platformGrayColor() -> Color {
    #if os(iOS)
    return Color(.systemGray6)
    #elseif os(macOS)
    return Color.gray.opacity(0.2)
    #else
    return Color.gray.opacity(0.2)
    #endif
}

/// Get the appropriate secondary gray color for the current platform
private func platformSecondaryGrayColor() -> Color {
    #if os(iOS)
    return Color(.systemGray5)
    #elseif os(macOS)
    return Color.gray.opacity(0.15)
    #else
    return Color.gray.opacity(0.15)
    #endif
}

// MARK: - Theme Types

/// Represents the app's theme mode
public enum ThemeMode: String, CaseIterable, Identifiable, Hashable {
    case light
    case dark
    case system

    public var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light:
            "Light"
        case .dark:
            "Dark"
        case .system:
            "System"
        }
    }

    var icon: String {
        switch self {
        case .light:
            "sun.max.fill"
        case .dark:
            "moon.fill"
        case .system:
            "gearshape.fill"
        }
    }
}

/// Dark mode preference for settings
public enum DarkModePreference: String, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

/// Theme scheme (light/dark)
public enum ThemeScheme {
    case light
    case dark
}

/// Text emphasis levels
public enum TextLevel {
    case primary
    case secondary
    case tertiary
}

/// Accent color levels
public enum AccentLevel {
    case primary
    case secondary
}

/// Financial color types
public enum FinancialType {
    case income
    case expense
    case savings
    case warning
    case critical
}

/// Budget status colors
public enum BudgetStatus {
    case under
    case near
    case over
}

/// Static color definitions for light and dark theme schemes
enum ColorDefinitions {
    // MARK: - Text Colors

    static func text(_ level: TextLevel, _ mode: ThemeScheme) -> Color {
        switch (level, mode) {
        case (.primary, .light):
            Color(hex: "000000").opacity(0.87)
        case (.primary, .dark):
            Color(hex: "FFFFFF").opacity(0.87)
        case (.secondary, .light):
            Color(hex: "000000").opacity(0.60)
        case (.secondary, .dark):
            Color(hex: "FFFFFF").opacity(0.60)
        case (.tertiary, .light):
            Color(hex: "000000").opacity(0.38)
        case (.tertiary, .dark):
            Color(hex: "FFFFFF").opacity(0.38)
        }
    }

    // MARK: - Accent Colors

    static func accent(_ level: AccentLevel, _ mode: ThemeScheme) -> Color {
        switch (level, mode) {
        case (.primary, .light), (.primary, .dark):
            Color(hex: "0073E6")
        case (.secondary, .light):
            Color(hex: "5E35B1")
        case (.secondary, .dark):
            Color(hex: "9575CD")
        }
    }

    // MARK: - Financial Colors

    static func financial(_ type: FinancialType, _ mode: ThemeScheme) -> Color {
        switch (type, mode) {
        case (.income, .light):
            Color(hex: "4CAF50")
        case (.income, .dark):
            Color(hex: "81C784")
        case (.expense, .light):
            Color(hex: "F44336")
        case (.expense, .dark):
            Color(hex: "E57373")
        case (.savings, .light):
            Color(hex: "2196F3")
        case (.savings, .dark):
            Color(hex: "64B5F6")
        case (.warning, .light):
            Color(hex: "FF9800")
        case (.warning, .dark):
            Color(hex: "FFB74D")
        case (.critical, .light):
            Color(hex: "D32F2F")
        case (.critical, .dark):
            Color(hex: "EF5350")
        }
    }

    // MARK: - Budget Colors

    static func budget(_ status: BudgetStatus, _ mode: ThemeScheme) -> Color {
        switch (status, mode) {
        case (.under, .light):
            Color(hex: "43A047")
        case (.under, .dark):
            Color(hex: "66BB6A")
        case (.near, .light):
            Color(hex: "FB8C00")
        case (.near, .dark):
            Color(hex: "FFA726")
        case (.over, .light):
            Color(hex: "E53935")
        case (.over, .dark):
            Color(hex: "EF5350")
        }
    }

    // MARK: - Category Colors

    static var categoryColors: [Color] {
        [
            Color(hex: "4285F4"),
            Color(hex: "EA4335"),
            Color(hex: "FBBC05"),
            Color(hex: "34A853"),
            Color(hex: "AA46BE"),
            Color(hex: "26C6DA"),
            Color(hex: "FB8C00"),
            Color(hex: "8D6E63"),
            Color(hex: "D81B60"),
            Color(hex: "5C6BC0"),
            Color(hex: "607D8B"),
            Color(hex: "C5E1A5")
        ]
    }
}

// MARK: - Transaction Filter Types

public enum TransactionFilter: String, CaseIterable {
    case all
    case income
    case expense
    case transfer
    case thisWeek
    case thisMonth
    case lastMonth
    case thisYear
    case custom

    var displayName: String {
        switch self {
        case .all: "All"
        case .income: "Income"
        case .expense: "Expenses"
        case .transfer: "Transfers"
        case .thisWeek: "This Week"
        case .thisMonth: "This Month"
        case .lastMonth: "Last Month"
        case .thisYear: "This Year"
        case .custom: "Custom"
        }
    }
}

// MARK: - Financial Insight Types

public struct FinancialInsight: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let priority: InsightPriority
    public let type: InsightType
    public let createdAt: Date
    public let actionUrl: String?

    public init(
        title: String, description: String, priority: InsightPriority, type: InsightType,
        actionUrl: String? = nil
    ) {
        self.title = title
        self.description = description
        self.priority = priority
        self.type = type
        self.createdAt = Date()
        self.actionUrl = actionUrl
    }
}

public enum InsightPriority: String, CaseIterable {
    case low, medium, high, critical

    var displayName: String {
        rawValue.capitalized
    }
}

public enum InsightType: String, CaseIterable {
    case spending, budgeting, savings, investment, debt, general

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Notification Types

// NOTE: ScheduledNotification is now defined in NotificationTypes.swift
// This duplicate definition has been removed to avoid conflicts

// MARK: - Import Error Types

/// Errors that can occur during data import
public enum ImportError: Error {
    case missingRequiredField(String)
    case invalidDateFormat(String)
    case invalidAmountFormat(String)
    case emptyFile
    case invalidFormat(String)
    case duplicateTransaction
    case invalidTransactionType(String)
    case parsingError(String)
}

/// Validates imported data and checks for duplicates
public class ImportValidator {
    /// Checks if a transaction is a duplicate of existing data
    /// - Parameter transaction: The transaction to check
    /// - Returns: True if the transaction is a duplicate
    public static func isDuplicate(_ transaction: FinancialTransaction) -> Bool {
        // For now, always return false (no duplicates)
        // In a real implementation, this would check against existing data
        false
    }

    /// Validates that required fields are present in CSV data
    /// - Parameters:
    /// - fields: The parsed CSV fields for a row
    /// - columnMapping: The mapping of columns to field types
    public static func validateRequiredFields(fields: [String], columnMapping: CSVColumnMapping)
        throws {
        guard let dateIndex = columnMapping.dateIndex, dateIndex < fields.count else {
            throw ImportError.missingRequiredField("date")
        }
        guard let titleIndex = columnMapping.titleIndex, titleIndex < fields.count else {
            throw ImportError.missingRequiredField("title")
        }
        guard let amountIndex = columnMapping.amountIndex, amountIndex < fields.count else {
            throw ImportError.missingRequiredField("amount")
        }
    }

    /// Validates CSV format and extracts headers
    /// - Parameter content: The CSV file content
    /// - Returns: Array of header strings
    public static func validateCSVFormat(content: String) throws -> [String] {
        let lines = content.components(separatedBy: .newlines)
        guard !lines.isEmpty else {
            throw ImportError.emptyFile
        }

        let headers = CSVParser.parseCSVRow(lines[0])
        guard !headers.isEmpty else {
            throw ImportError.invalidFormat("No headers found")
        }

        return headers
    }
}

// MARK: - CSV Parser

/// Parses CSV data
public class CSVParser {
    /// Parses a CSV row into fields
    /// - Parameter row: The CSV row string
    /// - Returns: Array of field strings
    public static func parseCSVRow(_ row: String) -> [String] {
        // Simple CSV parsing - in a real implementation, use a proper CSV library
        row.components(separatedBy: ",")
    }

    /// Maps CSV headers to column indices
    /// - Parameter headers: Array of header strings
    /// - Returns: Column mapping
    public static func mapColumns(headers: [String]) -> CSVColumnMapping {
        var mapping = CSVColumnMapping()

        for (index, header) in headers.enumerated() {
            let lowerHeader = header.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

            switch lowerHeader {
            case "date", "transaction date":
                mapping.dateIndex = index
            case "title", "description", "memo":
                mapping.titleIndex = index
            case "amount", "value":
                mapping.amountIndex = index
            case "type", "transaction type":
                mapping.typeIndex = index
            case "notes", "comments":
                mapping.notesIndex = index
            case "account", "account name":
                mapping.accountIndex = index
            case "category", "category name":
                mapping.categoryIndex = index
            default:
                break
            }
        }

        return mapping
    }
}

// MARK: - CSV Column Mapping

/// Maps CSV columns to field indices
public struct CSVColumnMapping {
    public var dateIndex: Int?
    public var titleIndex: Int?
    public var amountIndex: Int?
    public var typeIndex: Int?
    public var notesIndex: Int?
    public var accountIndex: Int?
    public var categoryIndex: Int?

    public init() {}
}

// MARK: - Data Parser

/// Parses various data types from strings
public class DataParser {
    /// Parses a date from a string
    /// - Parameter dateString: The date string
    /// - Returns: Parsed Date
    public static func parseDate(_ dateString: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else {
            throw ImportError.invalidDateFormat(dateString)
        }
        return date
    }

    /// Parses an amount from a string
    /// - Parameter amountString: The amount string
    /// - Returns: Parsed Double
    public static func parseAmount(_ amountString: String) throws -> Double {
        let cleanedString =
            amountString
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let amount = Double(cleanedString) else {
            throw ImportError.invalidAmountFormat(amountString)
        }
        return amount
    }

    /// Parses transaction type from a string
    /// - Parameters:
    /// - typeString: The type string
    /// - amount: The transaction amount (used as fallback)
    /// - Returns: Parsed TransactionType
    public static func parseTransactionType(_ typeString: String, amount: Double) -> TransactionType {
        switch typeString {
        case "income", "credit", "deposit":
            .income
        case "expense", "debit", "withdrawal":
            .expense
        default:
            amount >= 0 ? .income : .expense
        }
    }
}

// MARK: - Entity Manager

/// Protocol for managing entities during import
public protocol EntityManager {
    /// Gets or creates an account from CSV fields
    func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping) async throws
        -> FinancialAccount

    /// Gets or creates a category from CSV fields
    func getOrCreateCategory(
        from fields: [String], columnMapping: CSVColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory
}

/// Default implementation of EntityManager
public class DefaultEntityManager: EntityManager {
    public init() {}

    public func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)
        async throws -> FinancialAccount {
        // For now, create a default account
        // In a real implementation, this would search existing accounts or create new ones
        FinancialAccount(
            name: "Imported Account",
            balance: 0.0,
            iconName: "creditcard"
        )
    }

    public func getOrCreateCategory(
        from fields: [String], columnMapping: CSVColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory {
        // For now, create a default category
        // In a real implementation, this would search existing categories or create new ones
        ExpenseCategory(
            name: "Imported Category",
            iconName: "tag"
        )
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Navigation Types

/// Represents a breadcrumb item in navigation history
public struct BreadcrumbItem: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let destination: AnyHashable?
    public let timestamp: Date

    public init(title: String, destination: AnyHashable? = nil) {
        self.title = title
        self.destination = destination
        self.timestamp = Date()
    }
}

/// Represents a deep link for navigation
public enum DeepLink {
    case dashboard
    case transactions
    case budgets
    case subscriptions
    case goals
    case settings
    case search(query: String)
    case transaction(id: UUID)
    case account(id: UUID)
    case subscription(id: UUID)
    case budget(id: UUID)
    case goal(id: UUID)

    public var path: String {
        switch self {
        case .dashboard: "/dashboard"
        case .transactions: "/transactions"
        case .budgets: "/budgets"
        case .subscriptions: "/subscriptions"
        case .goals: "/goals"
        case .settings: "/settings"
        case .search: "/search"
        case let .transaction(id): "/transaction/\(id)"
        case let .account(id): "/account/\(id)"
        case let .subscription(id): "/subscription/\(id)"
        case let .budget(id): "/budget/\(id)"
        case let .goal(id): "/goal/\(id)"
        }
    }
}

// MARK: - Animation Component Types

// MARK: - UI Components

/// Theme-related UI components
public struct ThemeComponents {
    // Placeholder for theme components
    // This should be expanded with actual theme component implementations
}

// MARK: - Insight Type Extensions

public extension InsightType {
    /// Icon name for the insight type
    var icon: String {
        switch self {
        case .spending:
            "creditcard.fill"
        case .budgeting:
            "chart.pie.fill"
        case .savings:
            "banknote.fill"
        case .investment:
            "chart.line.uptrend.xyaxis"
        case .debt:
            "exclamationmark.triangle.fill"
        case .general:
            "info.circle.fill"
        }
    }
}

/// A view component for displaying individual transaction rows
public struct TransactionRowView: View {
    let transaction: FinancialTransaction
    let onTap: () -> Void

    public init(transaction: FinancialTransaction, onTap: @escaping () -> Void = {}) {
        self.transaction = transaction
        self.onTap = onTap
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Transaction icon
            ZStack {
                Circle()
                    .fill(
                        self.transaction.amount >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1)
                    )
                    .frame(width: 40, height: 40)

                Image(
                    systemName: self.transaction.amount >= 0
                        ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
                )
                .foregroundColor(self.transaction.amount >= 0 ? .green : .red)
                .font(.system(size: 16))
            }

            VStack(alignment: .leading, spacing: 4) {
                // Transaction description
                Text(self.transaction.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                // Transaction date
                Text(self.transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Transaction amount
            Text(self.transaction.amount.formatted(.currency(code: "USD")))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(self.transaction.amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(platformBackgroundColor())
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            self.onTap()
        }
    }
}

// MARK: - Dashboard Components

/// Welcome header for the dashboard
public struct DashboardWelcomeHeader: View {
    let greeting: String
    let wellnessPercentage: Int
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpenses: Double

    public init(
        greeting: String, wellnessPercentage: Int, totalBalance: Double, monthlyIncome: Double,
        monthlyExpenses: Double
    ) {
        self.greeting = greeting
        self.wellnessPercentage = wellnessPercentage
        self.totalBalance = totalBalance
        self.monthlyIncome = monthlyIncome
        self.monthlyExpenses = monthlyExpenses
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Good \(self.greeting.lowercased())!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("Your financial wellness is at \(self.wellnessPercentage)%")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(self.totalBalance.formatted(.currency(code: "USD")))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                VStack(alignment: .leading) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text((self.monthlyIncome - self.monthlyExpenses).formatted(.currency(code: "USD")))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor((self.monthlyIncome - self.monthlyExpenses) >= 0 ? .green : .red)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Accounts summary widget for the dashboard
public struct DashboardAccountsSummary: View {
    let accounts: [FinancialAccount]
    let onAccountTap: (String) -> Void
    let onViewAllTap: () -> Void

    public init(
        accounts: [FinancialAccount], onAccountTap: @escaping (String) -> Void,
        onViewAllTap: @escaping () -> Void
    ) {
        self.accounts = accounts
        self.onAccountTap = onAccountTap
        self.onViewAllTap = onViewAllTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") {
                    self.onViewAllTap()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            let prefixAccounts = Array(accounts.prefix(3))
            ForEach(Array(prefixAccounts.enumerated()), id: \.offset) { _, account in
                HStack {
                    VStack(alignment: .leading) {
                        Text(account.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Text(account.accountType.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(account.balance.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.onAccountTap(String(describing: account.persistentModelID))
                }
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Subscriptions section for the dashboard
public struct DashboardSubscriptionsSection: View {
    let subscriptions: [Subscription]
    let onSubscriptionTapped: (Subscription) -> Void
    let onViewAllTapped: () -> Void
    let onAddTapped: () -> Void

    public init(
        subscriptions: [Subscription], onSubscriptionTapped: @escaping (Subscription) -> Void,
        onViewAllTapped: @escaping () -> Void, onAddTapped: @escaping () -> Void
    ) {
        self.subscriptions = subscriptions
        self.onSubscriptionTapped = onSubscriptionTapped
        self.onViewAllTapped = onViewAllTapped
        self.onAddTapped = onAddTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Subscriptions")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") {
                    self.onViewAllTapped()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            ForEach(self.subscriptions.prefix(3)) { subscription in
                HStack {
                    Text(subscription.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(subscription.amount.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.onSubscriptionTapped(subscription)
                }
            }

            Button(action: self.onAddTapped) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Add Subscription")
                        .foregroundColor(.blue)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Budget progress widget for the dashboard
public struct DashboardBudgetProgress: View {
    let budgets: [Budget]
    let onBudgetTap: (Budget) -> Void
    let onViewAllTap: () -> Void

    public init(
        budgets: [Budget], onBudgetTap: @escaping (Budget) -> Void,
        onViewAllTap: @escaping () -> Void
    ) {
        self.budgets = budgets
        self.onBudgetTap = onBudgetTap
        self.onViewAllTap = onViewAllTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Budgets")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") {
                    self.onViewAllTap()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            ForEach(self.budgets.prefix(2)) { budget in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(budget.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(Int(budget.spentAmount / budget.limitAmount * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: budget.spentAmount / budget.limitAmount)
                        .progressViewStyle(
                            LinearProgressViewStyle(
                                tint: budget.spentAmount > budget.limitAmount ? .red : .green
                            )
                        )
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.onBudgetTap(budget)
                }
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Insights widget for the dashboard
public struct DashboardInsights: View {
    let insights: [FinancialInsight]
    let onDetailsTapped: () -> Void

    public init(insights: [FinancialInsight], onDetailsTapped: @escaping () -> Void) {
        self.insights = insights
        self.onDetailsTapped = onDetailsTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Insights")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") {
                    self.onDetailsTapped()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            if self.insights.isEmpty {
                Text("No insights available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(self.insights.prefix(2)) { insight in
                    HStack(spacing: 12) {
                        Image(systemName: insight.type.icon)
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading) {
                            Text(insight.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text(insight.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Quick actions widget for the dashboard
public struct DashboardQuickActions: View {
    let onAddTransaction: () -> Void
    let onPayBills: () -> Void
    let onViewReports: () -> Void
    let onSetGoals: () -> Void

    public init(
        onAddTransaction: @escaping () -> Void, onPayBills: @escaping () -> Void,
        onViewReports: @escaping () -> Void, onSetGoals: @escaping () -> Void
    ) {
        self.onAddTransaction = onAddTransaction
        self.onPayBills = onPayBills
        self.onViewReports = onViewReports
        self.onSetGoals = onSetGoals
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 16) {
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 50, height: 50)

                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }

                    Text("Add Transaction")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .onTapGesture(perform: self.onAddTransaction)

                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 50, height: 50)

                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                    }

                    Text("Pay Bills")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .onTapGesture(perform: self.onPayBills)

                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 50, height: 50)

                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.purple)
                            .font(.system(size: 24))
                    }

                    Text("View Reports")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .onTapGesture(perform: self.onViewReports)

                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 50, height: 50)

                        Image(systemName: "target")
                            .foregroundColor(.orange)
                            .font(.system(size: 24))
                    }

                    Text("Set Goals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .onTapGesture(perform: self.onSetGoals)
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Transaction View Components

/// Empty state view for transactions
public struct TransactionEmptyStateView: View {
    let searchText: String
    let onAddTransaction: () -> Void

    public init(searchText: String, onAddTransaction: @escaping () -> Void) {
        self.searchText = searchText
        self.onAddTransaction = onAddTransaction
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: self.searchText.isEmpty ? "doc.text.magnifyingglass" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(self.searchText.isEmpty ? "No transactions yet" : "No transactions found")
                .font(.title2)
                .foregroundColor(.primary)

            Text(
                self.searchText.isEmpty
                    ? "Add your first transaction to get started"
                    : "Try adjusting your search or filter"
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

            if self.searchText.isEmpty {
                Button(action: self.onAddTransaction) {
                    Label("Add Transaction", systemImage: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// List view for displaying transactions
public struct TransactionListView: View {
    let transactions: [FinancialTransaction]
    let onTransactionTapped: (FinancialTransaction) -> Void
    let onDeleteTransaction: (FinancialTransaction) -> Void

    public init(
        transactions: [FinancialTransaction],
        onTransactionTapped: @escaping (FinancialTransaction) -> Void,
        onDeleteTransaction: @escaping (FinancialTransaction) -> Void
    ) {
        self.transactions = transactions
        self.onTransactionTapped = onTransactionTapped
        self.onDeleteTransaction = onDeleteTransaction
    }

    public var body: some View {
        List {
            ForEach(self.transactions) { transaction in
                TransactionRowView(transaction: transaction) {
                    self.onTransactionTapped(transaction)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        self.onDeleteTransaction(transaction)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

/// Add transaction view
public struct AddTransactionView: View {
    let categories: [ExpenseCategory]
    let accounts: [FinancialAccount]

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedAccount: FinancialAccount?
    @State private var date = Date()
    @State private var transactionType: TransactionType = .expense

    public init(categories: [ExpenseCategory], accounts: [FinancialAccount]) {
        self.categories = categories
        self.accounts = accounts
    }

    public var body: some View {
        NavigationView {
            Form {
                Section("Transaction Details") {
                    TextField("Title", text: self.$title)
                    TextField("Amount", text: self.$amount)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif

                    Picker("Type", selection: self.$transactionType) {
                        Text("Income").tag(TransactionType.income)
                        Text("Expense").tag(TransactionType.expense)
                        Text("Transfer").tag(TransactionType.transfer)
                    }
                }

                Section("Category & Account") {
                    Picker("Category", selection: self.$selectedCategory) {
                        Text("None").tag(ExpenseCategory?.none)
                        ForEach(self.categories) { category in
                            Text(category.name).tag(category as ExpenseCategory?)
                        }
                    }

                    Picker("Account", selection: self.$selectedAccount) {
                        Text("None").tag(FinancialAccount?.none)
                        ForEach(self.accounts) { account in
                            Text(account.name).tag(account as FinancialAccount?)
                        }
                    }
                }

                Section("Date") {
                    DatePicker("Transaction Date", selection: self.$date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Transaction")
            #if os(iOS)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        self.dismiss()
                    },
                    trailing: Button("Save") {
                        self.saveTransaction()
                    }
                    .disabled(self.title.isEmpty || self.amount.isEmpty)
                )
            #elseif os(macOS)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            self.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            self.saveTransaction()
                        }
                        .disabled(self.title.isEmpty || self.amount.isEmpty)
                    }
                }
            #endif
        }
    }

    private func saveTransaction() {
        // Implementation would save the transaction
        self.dismiss()
    }
}

/// Transaction detail view
public struct TransactionDetailView: View {
    let transaction: FinancialTransaction

    public init(transaction: FinancialTransaction) {
        self.transaction = transaction
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Transaction header
                VStack(alignment: .leading, spacing: 8) {
                    Text(self.transaction.title)
                        .font(.title)
                        .foregroundColor(.primary)

                    Text(self.transaction.amount.formatted(.currency(code: "USD")))
                        .font(.title2)
                        .foregroundColor(self.transaction.amount >= 0 ? .green : .red)
                }

                // Transaction details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(
                        label: "Date",
                        value: self.transaction.date.formatted(date: .long, time: .omitted)
                    )
                    DetailRow(
                        label: "Type", value: self.transaction.transactionType.rawValue.capitalized
                    )
                    if let category = transaction.category {
                        DetailRow(label: "Category", value: category.name)
                    }
                    if let account = transaction.account {
                        DetailRow(label: "Account", value: account.name)
                    }
                    if let notes = transaction.notes {
                        DetailRow(label: "Notes", value: notes)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Transaction Details")
    }
}

/// Transaction stats card
public struct TransactionStatsCard: View {
    let transactions: [FinancialTransaction]

    public init(transactions: [FinancialTransaction]) {
        self.transactions = transactions
    }

    private var totalIncome: Double {
        self.transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalExpenses: Double {
        self.transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + abs($1.amount) }
    }

    public var body: some View {
        HStack(spacing: 20) {
            StatItem(
                title: "Income",
                amount: self.totalIncome,
                color: .green,
                icon: "arrow.down.circle.fill"
            )

            StatItem(
                title: "Expenses",
                amount: self.totalExpenses,
                color: .red,
                icon: "arrow.up.circle.fill"
            )

            StatItem(
                title: "Net",
                amount: self.totalIncome - self.totalExpenses,
                color: (self.totalIncome - self.totalExpenses) >= 0 ? .green : .red,
                icon: "equal.circle.fill"
            )
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Search and filter section
public struct SearchAndFilterSection: View {
    @Binding var searchText: String
    @Binding var selectedFilter: TransactionFilter
    @Binding var showingSearch: Bool

    public init(
        searchText: Binding<String>, selectedFilter: Binding<TransactionFilter>,
        showingSearch: Binding<Bool>
    ) {
        self._searchText = searchText
        self._selectedFilter = selectedFilter
        self._showingSearch = showingSearch
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search transactions", text: self.$searchText)
                    .textFieldStyle(.plain)
                if !self.searchText.isEmpty {
                    Button(action: { self.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(platformGrayColor())
            .cornerRadius(8)

            // Filter picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.displayName,
                            isSelected: self.selectedFilter == filter
                        ) {
                            self.selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Helper Views

/// Detail row for transaction details
private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(self.label)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(self.value)
                .foregroundColor(.primary)
        }
    }
}

/// Stat item for transaction stats
private struct StatItem: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: self.icon)
                .foregroundColor(self.color)
                .font(.system(size: 20))

            Text(self.title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(self.amount.formatted(.currency(code: "USD")))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(self.color)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Filter button for transaction filters
private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(self.isSelected ? Color.blue : platformSecondaryGrayColor())
                .foregroundColor(self.isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Export/Import Types

/// Export format options
public enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case pdf = "PDF"
    case json = "JSON"

    var displayName: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .csv: "tablecells"
        case .pdf: "doc.richtext"
        case .json: "curlybraces"
        }
    }
}

/// Date range options for export
public enum DateRange: String, CaseIterable {
    case lastWeek = "Last Week"
    case lastMonth = "Last Month"
    case lastThreeMonths = "Last 3 Months"
    case lastSixMonths = "Last 6 Months"
    case lastYear = "Last Year"
    case allTime = "All Time"
    case custom = "Custom"

    var displayName: String {
        rawValue
    }
}

/// Result of a data import operation
public struct ImportResult {
    public let success: Bool
    public let itemsImported: Int
    public let errors: [String]
    public let warnings: [String]

    public init(success: Bool, itemsImported: Int, errors: [String] = [], warnings: [String] = []) {
        self.success = success
        self.itemsImported = itemsImported
        self.errors = errors
        self.warnings = warnings
    }
}

/// Settings for data export
public struct ExportSettings {
    public let format: ExportFormat
    public let dateRange: DateRange
    public let includeCategories: Bool
    public let includeAccounts: Bool
    public let includeBudgets: Bool

    public init(
        format: ExportFormat,
        dateRange: DateRange,
        includeCategories: Bool = true,
        includeAccounts: Bool = true,
        includeBudgets: Bool = true
    ) {
        self.format = format
        self.dateRange = dateRange
        self.includeCategories = includeCategories
        self.includeAccounts = includeAccounts
        self.includeBudgets = includeBudgets
    }
}

/// Data exporter for exporting financial data
@MainActor
public class DataExporter {
    private let modelContainer: ModelContainer

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    /// Export data based on settings
    public func exportData(settings: ExportSettings) async throws -> URL {
        // Placeholder implementation - create a temporary file with sample data
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "export.\(settings.format.displayName.lowercased())"
        let fileURL = tempDir.appendingPathComponent(fileName)

        // Sample CSV data
        let sampleData = "date,title,amount,type\n2024-01-01,Sample Transaction,100.00,income\n"
        let data = sampleData.data(using: .utf8)!

        try data.write(to: fileURL)
        return fileURL
    }
}

// MARK: - Data Import Components

/// Header component for data import
public struct DataImportHeaderComponent: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Import Financial Data")
                .font(.title2)
                .fontWeight(.bold)

            Text("Import your financial data from CSV files")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/// File selection component for data import
public struct FileSelectionComponent: View {
    @Binding var showingFilePicker: Bool

    public init(showingFilePicker: Binding<Bool>) {
        self._showingFilePicker = showingFilePicker
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Select CSV File")
                .font(.headline)

            Text("Choose a CSV file containing your financial data")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: { self.showingFilePicker = true }) {
                Label("Choose File", systemImage: "folder")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

/// Import progress component
public struct ImportProgressComponent: View {
    let progress: Double

    public init(progress: Double) {
        self.progress = progress
    }

    public var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: self.progress, total: 1.0)
                .progressViewStyle(CircularProgressViewStyle())

            Text("Importing data...")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("\(Int(self.progress * 100))% complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/// Import button component
public struct ImportButtonComponent: View {
    let isImporting: Bool
    let action: () -> Void

    public init(isImporting: Bool, action: @escaping () -> Void) {
        self.isImporting = isImporting
        self.action = action
    }

    public var body: some View {
        Button(action: self.action) {
            if self.isImporting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Label("Import Data", systemImage: "square.and.arrow.down")
            }
        }
        .padding()
        .background(self.isImporting ? Color.gray : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .disabled(self.isImporting)
    }
}

/// Import instructions component
public struct ImportInstructionsComponent: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Instructions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("• CSV file should contain columns: date, title, amount")
                Text("• Date format: YYYY-MM-DD")
                Text("• Amount format: positive for income, negative for expenses")
                Text("• Optional columns: notes, category, account")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(platformGrayColor())
        .cornerRadius(8)
    }
}

/// Import result view
public struct ImportResultView: View {
    let result: ImportResult
    let onDismiss: () -> Void

    public init(result: ImportResult, onDismiss: @escaping () -> Void) {
        self.result = result
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: self.result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(self.result.success ? .green : .red)

            Text(self.result.success ? "Import Successful" : "Import Failed")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Items imported: \(self.result.itemsImported)")
                    .font(.body)

                if !self.result.errors.isEmpty {
                    Text("Errors:")
                        .font(.headline)
                        .foregroundColor(.red)

                    ForEach(self.result.errors, id: \.self) { error in
                        Text("• \(error)")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }

                if !self.result.warnings.isEmpty {
                    Text("Warnings:")
                        .font(.headline)
                        .foregroundColor(.orange)

                    ForEach(self.result.warnings, id: \.self) { warning in
                        Text("• \(warning)")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
            }

            Button("Done", action: self.onDismiss)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}

/// Data importer for importing financial data
public class DataImporter {
    private let modelContainer: ModelContainer

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    /// Import data from CSV content
    public func importFromCSV(_ content: String) async throws -> ImportResult {
        // Placeholder implementation
        ImportResult(success: true, itemsImported: 0)
    }
}
