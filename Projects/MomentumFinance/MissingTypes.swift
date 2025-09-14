import Foundation
import SwiftData
import SwiftUI
import UserNotifications

// Import InsightType from FinancialIntelligenceAnalysis
// NOTE: InsightType is defined in Shared/Intelligence/FinancialIntelligenceAnalysis.swift

// Temporary definition of InsightType to resolve compilation issues
public enum InsightType: Sendable {
    case spendingPattern, anomaly, budgetAlert, forecast, optimization, budgetRecommendation,
        positiveSpendingTrend

    public var displayName: String {
        switch self {
        case .spendingPattern: "Spending Pattern"
        case .anomaly: "Anomaly"
        case .budgetAlert: "Budget Alert"
        case .forecast: "Forecast"
        case .optimization: "Optimization"
        case .budgetRecommendation: "Budget Recommendation"
        case .positiveSpendingTrend: "Positive Spending Trend"
        }
    }

    public var icon: String {
        switch self {
        case .spendingPattern: "chart.line.uptrend.xyaxis"
        case .anomaly: "exclamationmark.triangle"
        case .budgetAlert: "bell"
        case .forecast: "chart.xyaxis.line"
        case .optimization: "arrow.up.right.circle"
        case .budgetRecommendation: "lightbulb"
        case .positiveSpendingTrend: "arrow.down.circle"
        }
    }
}

// MARK: - Missing Type Definitions

/// - TODO: Remove when proper DataImportModels.swift is included in Xcode project

/// Represents a data validation error during import (temporary bridge)
public struct ValidationError: Identifiable, Codable, Sendable {
    public let id: UUID
    public let field: String
    public let message: String
    public let severity: Severity

    public init(
        id: UUID = UUID(),
        field: String,
        message: String,
        severity: Severity = .error
    ) {
        self.id = id
        self.field = field
        self.message = message
        self.severity = severity
    }

    public enum Severity: String, Codable, Sendable {
        case warning
        case error

        public var displayName: String {
            switch self {
            case .warning:
                "Warning"
            case .error:
                "Error"
            }
        }
    }
}

/// Represents the result of a data import operation (temporary bridge)
public struct ImportResult: Codable, Sendable {
    public let success: Bool
    public let transactionsImported: Int
    public let accountsImported: Int
    public let categoriesImported: Int
    public let duplicatesSkipped: Int
    public let errors: [ValidationError]
    public let warnings: [ValidationError]

    public init(
        success: Bool,
        transactionsImported: Int,
        accountsImported: Int = 0,
        categoriesImported: Int = 0,
        duplicatesSkipped: Int = 0,
        errors: [ValidationError] = [],
        warnings: [ValidationError] = []
    ) {
        self.success = success
        self.transactionsImported = transactionsImported
        self.accountsImported = accountsImported
        self.categoriesImported = categoriesImported
        self.duplicatesSkipped = duplicatesSkipped
        self.errors = errors
        self.warnings = warnings
    }
}

// MARK: - ModelContext for compatibility

#if !canImport(SwiftData)
    public struct ModelContext: Sendable {
        public init() {}
    }
#endif

// MARK: - Theme Types

public enum ThemeMode: String, CaseIterable, Sendable {
    case light
    case dark
    case system

    public var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "System"
        }
    }

    public var icon: String {
        switch self {
        case .light: "sun.max"
        case .dark: "moon"
        case .system: "gearshape"
        }
    }
}

public struct ColorDefinitions: Sendable {
    public static let primary = Color.blue
    public static let secondary = Color.gray
    public static let accent = Color.orange
    public static let error = Color.red
    public static let warning = Color.orange
    public static let success = Color.green
    public static let info = Color.blue

    // Functions to match the expected interface
    public static func background(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color.white
        case .dark:
            Color.black
        case .system:
            Color.primary.opacity(0.05)
        }
    }

    public static func surface(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color.gray.opacity(0.1)
        case .dark:
            Color.gray.opacity(0.2)
        case .system:
            Color.primary.opacity(0.1)
        }
    }

    public static func secondaryBackground(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color.gray.opacity(0.05)
        case .dark:
            Color.gray.opacity(0.15)
        case .system:
            Color.secondary.opacity(0.05)
        }
    }

    public static func groupedBackground(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color(red: 0.95, green: 0.95, blue: 0.97)
        case .dark:
            Color(red: 0.11, green: 0.11, blue: 0.12)
        case .system:
            Color.gray.opacity(0.03)
        }
    }

    public static func cardBackground(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color.white
        case .dark:
            Color(red: 0.17, green: 0.17, blue: 0.18)
        case .system:
            Color.primary.opacity(0.02)
        }
    }

    public static let categoryColors: [Color] = [
        Color.orange,  // food
        Color.blue,  // transport
        Color.purple,  // entertainment
        Color.green,  // shopping
        Color.red,  // bills
        Color.mint,  // income
        Color.teal,  // savings
        Color.gray,  // other
    ]

    // Additional methods for complex color system
    public static func text(_ type: TextType, _ mode: ThemeMode) -> Color {
        switch (type, mode) {
        case (.primary, .light):
            Color.black
        case (.primary, .dark):
            Color.white
        case (.secondary, _):
            Color.gray
        case (.tertiary, _):
            Color.gray.opacity(0.6)
        default:
            Color.primary
        }
    }

    public static func accent(_ type: AccentType, _ mode: ThemeMode) -> Color {
        switch type {
        case .primary:
            Color.blue
        case .secondary:
            Color.orange
        }
    }

    public static func financial(_ type: FinancialType, _ mode: ThemeMode) -> Color {
        switch type {
        case .income:
            Color.green
        case .expense:
            Color.red
        case .savings:
            Color.blue
        case .warning:
            Color.orange
        case .critical:
            Color.red
        }
    }

    public static func budget(_ type: BudgetType, _ mode: ThemeMode) -> Color {
        switch type {
        case .under:
            Color.green
        case .near:
            Color.orange
        case .over:
            Color.red
        }
    }

    public init() {}
}

// Supporting enums for ColorDefinitions
public enum TextType: Sendable {
    case primary, secondary, tertiary
}

public enum AccentType: Sendable {
    case primary, secondary
}

public enum FinancialType: Sendable {
    case income, expense, savings, warning, critical
}

public enum BudgetType: Sendable {
    case under, near, over
}

// MARK: - ColorTheme Extension for Demo Components (Removed - ColorTheme not available in this context)

// extension ColorTheme {
//     var primary: Color { accentPrimary }
//     var success: Color { income }
//     var error: Color { expense }
// }

public enum DarkModePreference: String, CaseIterable, Sendable {
    case light
    case dark
    case system

    public var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "System"
        }
    }
}

// MARK: - Transaction Types

public enum TransactionFilter: String, CaseIterable, Sendable {
    case all
    case income
    case expense

    public var displayName: String {
        switch self {
        case .all: "All"
        case .income: "Income"
        case .expense: "Expense"
        }
    }
}

// MARK: - Financial Insight Types

public struct FinancialInsight: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let type: InsightType
    public let priority: InsightPriority
    public let confidence: Double
    public let value: Double?
    public let category: String?
    public let dateGenerated: Date
    public let actionable: Bool

    public init(
        title: String,
        description: String,
        type: InsightType,
        priority: InsightPriority,
        confidence: Double = 0.8,
        value: Double? = nil,
        category: String? = nil,
        dateGenerated: Date = Date(),
        actionable: Bool = false
    ) {
        self.title = title
        self.description = description
        self.type = type
        self.priority = priority
        self.confidence = confidence
        self.value = value
        self.category = category
        self.dateGenerated = dateGenerated
        self.actionable = actionable
    }
}

public enum InsightPriority: Int, CaseIterable, Sendable, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3

    public static func < (lhs: InsightPriority, rhs: InsightPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var color: Color {
        switch self {
        case .low: .gray
        case .medium: .yellow
        case .high: .orange
        case .urgent: .red
        }
    }
}

// MARK: - Services Protocols (Next Section)

// MARK: - Import Bridge Types (to resolve compilation order issues)

// NOTE: ImportResult moved to proper location: Shared/Models/DataImportModels.swift

// MARK: - Core Data Types

public struct CSVColumnMapping: Sendable {
    public let dateColumn: String
    public let amountColumn: String
    public let descriptionColumn: String
    public let categoryColumn: String?
    public let accountColumn: String?

    public init(
        dateColumn: String,
        amountColumn: String,
        descriptionColumn: String,
        categoryColumn: String? = nil,
        accountColumn: String? = nil
    ) {
        self.dateColumn = dateColumn
        self.amountColumn = amountColumn
        self.descriptionColumn = descriptionColumn
        self.categoryColumn = categoryColumn
        self.accountColumn = accountColumn
    }
}

// MARK: - Navigation Types

public struct BreadcrumbItem: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let destination: String?

    public init(title: String, destination: String? = nil) {
        self.title = title
        self.destination = destination
    }
}

public struct DeepLink: Sendable {
    public let path: String
    public let parameters: [String: String]

    public init(path: String, parameters: [String: String] = [:]) {
        self.path = path
        self.parameters = parameters
    }
}

// MARK: - Search Types

// MARK: - Search Types

// NOTE: SearchFilter, SearchResult and SearchResultType moved to proper location: Shared/Features/GlobalSearch/SearchTypes.swift

// MARK: - Service Types (Simplified)

public protocol EntityManager: Sendable {
    func save() async throws
    func delete<T>(_ entity: T) async throws
    func fetch<T>(_ type: T.Type) async throws -> [T]
    func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping) async throws
        -> FinancialAccount?
    func getOrCreateCategory(
        from fields: [String], columnMapping: CSVColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory?
}

public final class DefaultEntityManager: EntityManager {
    public init() {}

    public func save() async throws {}
    public func delete(_ entity: some Any) async throws {}
    public func fetch<T>(_ type: T.Type) async throws -> [T] { [] }

    public func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)
        async throws -> FinancialAccount?
    {
        // Mock implementation - return a default account
        return FinancialAccount(name: "Default Account", type: .checking)
    }

    public func getOrCreateCategory(
        from fields: [String], columnMapping: CSVColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory? {
        // Mock implementation - return a default category
        return ExpenseCategory(name: "General")
    }
}

public final class ExportEngineService: Sendable {
    public init() {}

    public init(modelContext: Any) {
        // Accept any context type for compatibility
    }

    public func exportToCSV() async throws -> URL {
        // Simplified implementation
        URL(fileURLWithPath: "/tmp/export.csv")
    }

    public func export(settings: Any) async throws -> URL {
        // Simplified export implementation
        try await exportToCSV()
    }

    private func exportToJSON() async throws -> URL {
        URL(fileURLWithPath: "/tmp/export.json")
    }

    private func exportToPDF() async throws -> URL {
        URL(fileURLWithPath: "/tmp/export.pdf")
    }
}

// MARK: - Financial ML and Analysis Types

public final class FinancialMLModels: Sendable {
    public static let shared = FinancialMLModels()
    private init() {}

    public func predictSpending() async -> Double {
        0.0
    }
}

public final class TransactionPatternAnalyzer: Sendable {
    public static let shared = TransactionPatternAnalyzer()
    private init() {}

    public func analyzePatterns() async -> [String] {
        []
    }
}

// MARK: - Animation Component Types

public enum AnimatedCardComponent {
    public struct AnimatedCard: View {
        public var body: some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        }

        public init() {}
    }
}

public enum AnimatedButtonComponent {
    public struct AnimatedButton: View {
        let action: () -> Void
        let label: String

        public var body: some View {
            Button(action: action) {
                Text(label)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .accessibilityLabel("Button")
        }

        public init(label: String, action: @escaping () -> Void) {
            self.label = label
            self.action = action
        }
    }
}

public enum AnimatedTransactionComponent {
    public struct AnimatedTransactionItem: View {
        public var body: some View {
            HStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("Transaction")
                        .font(.headline)
                    Text("Details")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("$0.00")
                    .font(.headline)
            }
            .padding()
        }

        public init() {}
    }
}

public enum AnimatedProgressComponents {
    public struct AnimatedBudgetProgress: View {
        let progress: Double

        public var body: some View {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
        }

        public init(progress: Double) {
            self.progress = progress
        }
    }

    public struct AnimatedCounter: View {
        let value: Double

        public var body: some View {
            Text("\(value, specifier: "%.2f")")
                .font(.title)
                .fontWeight(.bold)
        }

        public init(value: Double) {
            self.value = value
        }
    }
}

public enum FloatingActionButtonComponent {
    public struct FloatingActionButton: View {
        let action: () -> Void
        let icon: String

        public var body: some View {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .accessibilityLabel("Button")
        }

        public init(icon: String, action: @escaping () -> Void) {
            self.icon = icon
            self.action = action
        }
    }
}

// MARK: - Import UI Components

public struct DataImportHeaderComponent: View {
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Import Financial Data")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Import transactions from CSV files")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    public init() {}
}

public struct FileSelectionComponent: View {
    @Binding public var showingFilePicker: Bool
    public let onFileSelected: () -> Void

    public var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingFilePicker = true
                onFileSelected()
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 32))
                    Text("Select CSV File")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(12)
            }
        }
        .padding()
    }

    public init(showingFilePicker: Binding<Bool>, onFileSelected: @escaping () -> Void) {
        self._showingFilePicker = showingFilePicker
        self.onFileSelected = onFileSelected
    }
}

public struct ImportProgressComponent: View {
    public let progress: Double

    public var body: some View {
        VStack(spacing: 8) {
            Text("Importing...")
                .font(.headline)

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())

            Text("\(Int(progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    public init(progress: Double) {
        self.progress = progress
    }
}

public struct ImportButtonComponent: View {
    public let isImporting: Bool
    public let action: () -> Void

    public var body: some View {
        Button(action: action) {
            HStack {
                if isImporting {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Text(isImporting ? "Importing..." : "Import Data")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isImporting ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isImporting)
        .accessibilityLabel("Button")
    }

    public init(isImporting: Bool, action: @escaping () -> Void) {
        self.isImporting = isImporting
        self.action = action
    }
}

public struct ImportInstructionsComponent: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Instructions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                instructionRow("1.", "Prepare a CSV file with your transaction data")
                instructionRow("2.", "Include columns: Date, Amount, Description")
                instructionRow("3.", "Optional: Category, Account columns")
                instructionRow("4.", "Select your file and click Import")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func instructionRow(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            Text(text)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    public init() {}
}

// MARK: - Import Result View

// NOTE: ImportResultView moved to proper location: Shared/Components/Import/ImportResultComponent.swift

// MARK: - Theme Demo Components

public struct ThemeSelectorCard: View {
    @Binding public var selectedThemeMode: ThemeMode
    public let theme: Any?

    public init(selectedThemeMode: Binding<ThemeMode>, theme: Any? = nil) {
        self._selectedThemeMode = selectedThemeMode
        self.theme = theme
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme Selection")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Button(action: {
                        selectedThemeMode = mode
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: themeIcon(for: mode))
                                .font(.title2)
                            Text(mode.displayName)
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            selectedThemeMode == mode ? Color.blue : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(selectedThemeMode == mode ? .white : .primary)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func themeIcon(for mode: ThemeMode) -> String {
        switch mode {
        case .light: "sun.max"
        case .dark: "moon"
        case .system: "gearshape"
        }
    }

    public init(selectedThemeMode: Binding<ThemeMode>) {
        self._selectedThemeMode = selectedThemeMode
        self.theme = nil
    }
}

public struct ThemeFinancialSummaryCard: View {

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Financial Summary")
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                VStack(alignment: .leading) {
                    Text("Total Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$12,345.67")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("+$1,234.56")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }

            Divider()

            HStack {
                Text("Spending")
                    .foregroundColor(.secondary)
                Spacer()
                Text("$2,345.89")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    public init(theme: Any = ()) {
        // Accept any theme parameter for compatibility but use static colors
    }
}

public struct ThemeAccountsList: View {

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accounts")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                accountRow("Checking", "$3,456.78")
                accountRow("Savings", "$8,888.89")
                accountRow("Credit Card", "-$567.12")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func accountRow(_ name: String, _ balance: String) -> some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Account")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(balance)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(balance.hasPrefix("-") ? .red : .blue)
        }
        .padding(.vertical, 4)
    }

    public init(theme: Any = ()) {
        // Accept any theme parameter for compatibility but use static colors
    }
}

// MARK: - Insights Views

public struct InsightsLoadingView: View {
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading insights...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    public init() {}
}

public struct InsightsEmptyStateView: View {
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text("No Insights Available")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Add some transactions to see personalized insights about your spending patterns.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    public init() {}
}

public struct InsightRowView: View {
    public let insight: FinancialInsight
    public let action: () -> Void

    public var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            Circle()
                .fill(priorityColor(insight.priority))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            Spacer()

            // Show confidence as percentage
            Text("\(Int(insight.confidence * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }

    private func priorityColor(_ priority: InsightPriority) -> Color {
        switch priority {
        case .low:
            .gray
        case .medium:
            .yellow
        case .high:
            .orange
        case .urgent:
            .red
        }
    }

    public init(insight: FinancialInsight, action: @escaping () -> Void) {
        self.insight = insight
        self.action = action
    }
}

// MARK: - Insight Data Model

public struct Insight: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let value: String?
    public let priority: InsightPriority
    public let category: String?
    public let dateCreated: Date

    public init(
        title: String,
        description: String,
        value: String? = nil,
        priority: InsightPriority = .medium,
        category: String? = nil,
        dateCreated: Date = Date()
    ) {
        self.title = title
        self.description = description
        self.value = value
        self.priority = priority
        self.category = category
        self.dateCreated = dateCreated
    }
}

// MARK: - Additional Insights Views

public struct InsightsFilterBar: View {
    @Binding public var filterPriority: InsightPriority?
    @Binding public var filterType: InsightType?

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "All", isSelected: filterPriority == nil && filterType == nil) {
                    filterPriority = nil
                    filterType = nil
                }

                FilterChip(title: "High Priority", isSelected: filterPriority == .high) {
                    filterPriority = filterPriority == .high ? nil : .high
                }

                FilterChip(title: "Urgent", isSelected: filterPriority == .urgent) {
                    filterPriority = filterPriority == .urgent ? nil : .urgent
                }

                FilterChip(title: "Spending", isSelected: filterType == .spendingPattern) {
                    filterType = filterType == .spendingPattern ? nil : .spendingPattern
                }

                FilterChip(title: "Budget", isSelected: filterType == .budgetAlert) {
                    filterType = filterType == .budgetAlert ? nil : .budgetAlert
                }
            }
            .padding(.horizontal)
        }
    }

    public init(filterPriority: Binding<InsightPriority?>, filterType: Binding<InsightType?>) {
        self._filterPriority = filterPriority
        self._filterType = filterType
    }
}

public struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .accessibilityLabel("Button")
    }

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
}

public struct InsightDetailView: View {
    public let insight: FinancialInsight
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(priorityColor(insight.priority))
                                .frame(width: 12, height: 12)

                            Text(priorityText(insight.priority))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }

                        Text(insight.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    // Confidence
                    Text("Confidence: \(Int(insight.confidence * 100))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    // Description
                    Text(insight.description)
                        .font(.body)
                        .foregroundColor(.secondary)

                    // Type info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Insight Type")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Text(insight.type.displayName)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Insight Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Button")
                }
            }
        }
    }

    private func priorityColor(_ priority: InsightPriority) -> Color {
        switch priority {
        case .low: .gray
        case .medium: .yellow
        case .high: .orange
        case .urgent: .red
        }
    }

    private func priorityText(_ priority: InsightPriority) -> String {
        switch priority {
        case .low: "Low Priority"
        case .medium: "Medium Priority"
        case .high: "High Priority"
        case .urgent: "Urgent"
        }
    }

    public init(insight: FinancialInsight) {
        self.insight = insight
    }
}

// MARK: - Data Import Support

extension CSVColumnMapping {
    public var notesIndex: Int? {
        // Return a default notes column index or nil
        nil
    }
}

// MARK: - Financial Intelligence Functions

func fi_generateForecasts(transactions: [Any], accounts: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_analyzeSpendingPatterns(transactions: [Any], categories: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_detectAnomalies(transactions: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_analyzeBudgets(transactions: [Any], budgets: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_suggestIdleCashInsights(transactions: [Any], accounts: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_suggestCreditUtilizationInsights(accounts: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

func fi_suggestDuplicatePaymentInsights(transactions: [Any]) -> [FinancialInsight] {
    // Placeholder implementation
    []
}

// MARK: - Financial ML Models Extension

extension FinancialMLModels {
    func suggestCategoryForTransaction(_ transaction: Any) -> ExpenseCategory? {
        // Placeholder implementation
        nil
    }
}

// MARK: - Forecast Data Model

public struct ForecastData: Identifiable, Sendable {
    public let id = UUID()
    public let date: Date
    public let predictedBalance: Double
    public let confidence: Double

    public init(date: Date, predictedBalance: Double, confidence: Double) {
        self.date = date
        self.predictedBalance = predictedBalance
        self.confidence = confidence
    }
}

// MARK: - Search Components

// NOTE: SearchFilter, SearchResult and SearchResultType moved to proper location: Shared/SearchTypes.swift
// NOTE: SearchHeaderComponent moved to proper location: Shared/Features/GlobalSearch/SearchResultsComponent.swift

// MARK: - Search Components

// NOTE: SearchResultsComponent and SearchResultRow moved to proper location: Shared/Features/GlobalSearch/SearchResultsComponent.swift

// MARK: - Transaction View Components

public struct TransactionEmptyStateView: View {
    public let searchText: String
    public let onAddTransaction: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text(searchText.isEmpty ? "No Transactions" : "No Results")
                .font(.title2)
                .fontWeight(.semibold)

            Text(
                searchText.isEmpty
                    ? "Start tracking your finances by adding your first transaction"
                    : "No transactions match your search criteria"
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            if searchText.isEmpty {
                Button("Add Transaction") {
                    onAddTransaction()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Add Transaction")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    public init(searchText: String, onAddTransaction: @escaping () -> Void) {
        self.searchText = searchText
        self.onAddTransaction = onAddTransaction
    }
}

public struct TransactionListView: View {
    public let transactions: [FinancialTransaction]
    public let onTransactionTapped: (FinancialTransaction) -> Void
    public let onDeleteTransaction: (FinancialTransaction) -> Void

    public var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(0..<transactions.count, id: \.self) { index in
                TransactionRowView(
                    transaction: transactions[index],
                    onTap: { onTransactionTapped(transactions[index]) },
                    onDelete: { onDeleteTransaction(transactions[index]) }
                )
            }
        }
        .padding(.horizontal)
    }

    public init(
        transactions: [FinancialTransaction],
        onTransactionTapped: @escaping (FinancialTransaction) -> Void,
        onDeleteTransaction: @escaping (FinancialTransaction) -> Void
    ) {
        self.transactions = transactions
        self.onTransactionTapped = onTransactionTapped
        self.onDeleteTransaction = onDeleteTransaction
    }
}

public struct TransactionRowView: View {
    public let transaction: FinancialTransaction
    public let onTap: () -> Void
    public let onDelete: (() -> Void)?

    public var body: some View {
        HStack(spacing: 12) {
            // Transaction icon
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "creditcard")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(transaction.category?.name ?? "Category") • Today")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("$\(transaction.amount, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .onTapGesture(perform: onTap)
        .swipeActions(edge: .trailing) {
            if let onDelete {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
                .accessibilityLabel("Delete")
            }
        }
    }

    public init(
        transaction: FinancialTransaction, onTap: @escaping () -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.transaction = transaction
        self.onTap = onTap
        self.onDelete = onDelete
    }
}

public struct AddTransactionView: View {
    public let categories: [Any]
    public let accounts: [Any]
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Transaction")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Categories: \(categories.count), Accounts: \(accounts.count)")
                    .foregroundColor(.secondary)

                Text("Transaction form would go here")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel")
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .accessibilityLabel("Save")
                }
            }
        }
    }

    public init(categories: [Any], accounts: [Any]) {
        self.categories = categories
        self.accounts = accounts
    }
}

public struct TransactionDetailView: View {
    public let transaction: Any
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Transaction header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Transaction Details")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("$0.00")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    // Transaction info
                    VStack(alignment: .leading, spacing: 12) {
                        detailRow("Category", "General")
                        detailRow("Date", "Today")
                        detailRow("Account", "Checking")
                        detailRow("Description", "Transaction details")
                    }

                    Spacer()
                }
                .padding()
            }
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                }
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }

    public init(transaction: Any) {
        self.transaction = transaction
    }
}

public struct TransactionStatsCard: View {
    public let transactions: [Any]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction Stats")
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                VStack(alignment: .leading) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$0.00")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(transactions.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    public init(transactions: [Any]) {
        self.transactions = transactions
    }
}

public struct SearchAndFilterSection: View {
    @Binding public var searchText: String
    @Binding public var selectedFilter: TransactionFilter
    @Binding public var showingSearch: Bool

    public var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search transactions...", text: $searchText).accessibilityLabel(
                    "Text Field"
                )
                .textFieldStyle(PlainTextFieldStyle())

                Button(action: { showingSearch = true }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Filter")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        filterChip(filter.displayName, selectedFilter == filter, filter)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func filterChip(_ title: String, _ isSelected: Bool, _ filter: TransactionFilter)
        -> some View
    {
        Button(action: {
            selectedFilter = filter
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }

    public init(
        searchText: Binding<String>,
        selectedFilter: Binding<TransactionFilter>,
        showingSearch: Binding<Bool>
    ) {
        self._searchText = searchText
        self._selectedFilter = selectedFilter
        self._showingSearch = showingSearch
    }
}

// MARK: - Data Import Support Types

// ImportValidator moved to Shared/MissingTypes.swift to avoid conflicts

// CSVParser and DataParser moved to Shared/MissingTypes.swift to avoid conflicts

// CSVColumnMapping extensions moved to Shared/MissingTypes.swift to avoid conflicts

// MARK: - Entity Manager Extensions (Removed - causing conflicts)

// extension EntityManager {
//     public func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)
//         async throws -> FinancialAccount?
//     {
//         // Mock implementation
//         nil
//     }
//
//     public func getOrCreateCategory(
//         from fields: [String], columnMapping: CSVColumnMapping, transactionType: Any
//     ) async throws -> ExpenseCategory? {
//         // Mock implementation
//         nil
//     }
// }

// MARK: - Missing Theme Components

public struct ThemeBudgetProgress: View {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public var body: some View {
        Text("Budget Progress")
    }
}

public struct ThemeSubscriptionsList: View {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public var body: some View {
        Text("Subscriptions List")
    }
}

public struct ThemeTypographyShowcase: View {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public var body: some View {
        Text("Typography Showcase")
    }
}

public struct ThemeButtonStylesShowcase: View {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public var body: some View {
        Text("Button Styles Showcase")
    }
}

public struct ThemeSettingsSheet: View {
    @Binding public var selectedThemeMode: ThemeMode
    @Binding public var sliderValue: Double
    @Binding public var showSheet: Bool
    public let theme: Any?

    public init(
        selectedThemeMode: Binding<ThemeMode>, sliderValue: Binding<Double>,
        showSheet: Binding<Bool>, theme: Any? = nil
    ) {
        self._selectedThemeMode = selectedThemeMode
        self._sliderValue = sliderValue
        self._showSheet = showSheet
        self.theme = theme
    }

    public var body: some View {
        NavigationView {
            VStack {
                Text("Theme Settings")
                Slider(value: $sliderValue, in: 0...1)
                Button("Close") {
                    showSheet = false
                }
                .accessibilityLabel("Close")
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Missing Button Styles

public struct PrimaryButtonStyle: ButtonStyle {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

public struct TextButtonStyle: ButtonStyle {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal)
            .foregroundColor(.blue)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

public struct DestructiveButtonStyle: ButtonStyle {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Missing Utility Functions

public func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
}

// MARK: - Features Namespace Extensions (Removed - causing conflicts)

// extension Features.Transactions {
//     struct AddTransactionView: View {
//         public let categories: [ExpenseCategory]
//         public let accounts: [FinancialAccount]
//
//         public init(categories: [ExpenseCategory], accounts: [FinancialAccount]) {
//             self.categories = categories
//             self.accounts = accounts
//         }
//
//         public var body: some View {
//             VStack {
//                 Text("Add Transaction")
//                     .font(.title)
//
//                 Text("Categories: \(categories.count)")
//                 Text("Accounts: \(accounts.count)")
//
//                 Button("Save Transaction") {
//                     // Save logic
//                 }
//                 .buttonStyle(.borderedProminent)
//                 .accessibilityLabel("Save Transaction")
//             }
//             .padding()
//         }
//     }
// }

// public struct SecuritySettingsSection: View {
//     @Binding public var biometricEnabled: Bool
//     public let authenticationTimeout: Any
//
//     public init(biometricEnabled: Binding<Bool>, authenticationTimeout: Any) {
//         self._biometricEnabled = biometricEnabled
//         self.authenticationTimeout = authenticationTimeout
//     }
//
//     public var body: some View {
//         Section("Security") {
//             Text("Security settings placeholder")
//         }
//     }
// }
//
// public struct AccessibilitySettingsSection: View {
//     @Binding public var hapticFeedbackEnabled: Bool
//     @Binding public var reducedMotion: Bool
//
//     public init(hapticFeedbackEnabled: Binding<Bool>, reducedMotion: Binding<Bool>) {
//         self._hapticFeedbackEnabled = hapticFeedbackEnabled
//         self._reducedMotion = reducedMotion
//     }
//
//     public var body: some View {
//         Section("Accessibility") {
//             Text("Accessibility settings placeholder")
//         }
//     }
// }
//
// public struct AppearanceSettingsSection: View {
//     public let darkModePreference: Any
//
//     public init(darkModePreference: Any) {
//         self.darkModePreference = darkModePreference
//     }
//
//     public var body: some View {
//         Section("Appearance") {
//             Text("Appearance settings placeholder")
//         }
//     }
// }
//
// public struct DataManagementSection: View {
//     @Binding public var dataRetentionDays: Double
//     @Binding public var showingDeleteConfirmation: Bool
//     @Binding public var hapticFeedbackEnabled: Bool
//
//     public init(
//         dataRetentionDays: Binding<Double>, showingDeleteConfirmation: Binding<Bool>,
//         hapticFeedbackEnabled: Binding<Bool>
//     ) {
//         self._dataRetentionDays = dataRetentionDays
//         self._showingDeleteConfirmation = showingDeleteConfirmation
//         self._hapticFeedbackEnabled = hapticFeedbackEnabled
//     }
//
//     public var body: some View {
//         Section("Data Management") {
//             Text("Data management placeholder")
//         }
//     }
// }
//
// public struct ImportExportSection: View {
//     public let importManager: Any?
//     public let modelContext: Any?
//
//     public init(importManager: Any? = nil, modelContext: Any? = nil) {
//         self.importManager = importManager
//         self.modelContext = modelContext
//     }
//
//     public var body: some View {
//         Section("Import/Export") {
//             Text("Import/Export placeholder")
//         }
//     }
// }
//
// public struct AboutSection: View {
//     public init() {}
//
//     public var body: some View {
//         Section("About") {
//             Text("About placeholder")
//         }
//     }
// }

// MARK: - Features Namespace Extensions (Removed - causing conflicts)

// extension Features.Transactions {
//     struct TransactionRowView: View {
//         public let transaction: FinancialTransaction
//         public let onTapped: () -> Void
//
//         public init(transaction: FinancialTransaction, onTapped: @escaping () -> Void) {
//             self.transaction = transaction
//             self.onTapped = onTapped
//         }
//
//         public var body: some View {
//             HStack(spacing: 12) {
//                 // Transaction icon
//                 Circle()
//                     .fill(Color.blue)
//                     .frame(width: 40, height: 40)
//                     .overlay(
//                         Image(systemName: "creditcard")
//                             .font(.system(size: 16))
//                             .foregroundColor(.white)
//                     )
//
//                 VStack(alignment: .leading, spacing: 2) {
//                     Text(transaction.title)
//                         .font(.subheadline)
//                         .fontWeight(.medium)
//
//                     Text("\(transaction.category?.name ?? "Category") • Today")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                 }
//
//                 Spacer()
//
//                 Text("$\(transaction.amount, specifier: "%.2f")")
//                     .font(.subheadline)
//                     .fontWeight(.semibold)
//             }
//             .padding(.vertical, 8)
//             .padding(.horizontal, 12)
//             .background(Color.gray.opacity(0.05))
//             .cornerRadius(8)
//             .onTapGesture(perform: onTapped)
//         }
//     }
// }
