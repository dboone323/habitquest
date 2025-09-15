<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Momentum Finance - SwiftUI Personal Finance App

This is a comprehensive personal finance application built with SwiftUI and SwiftData for iOS and macOS platforms. Part of the larger Quantum Workspace ecosystem with shared patterns and automation.

## Architecture Guidelines

### MVVM Pattern Implementation
```swift
// Standard ViewModel structure
@MainActor
@Observable
final class TransactionsViewModel {
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // Business logic methods
    func filterTransactions(_ transactions: [FinancialTransaction], by type: TransactionType?)
    -> [FinancialTransaction] {
        guard let type else { return transactions }
        return transactions.filter { $0.transactionType == type }
    }
}
```

### SwiftData Model Patterns
```swift
@Model
final class FinancialTransaction {
    var title: String
    var amount: Double
    var date: Date
    var transactionType: TransactionType

    // Relationships
    var category: ExpenseCategory?
    var account: FinancialAccount?

    init(title: String, amount: Double, date: Date, transactionType: TransactionType) {
        // Standard initialization
    }
}
```

### Feature Module Organization
```
Shared/Features/Transactions/
├── TransactionsView.swift          # Main view
├── TransactionsViewModel.swift     # Business logic
├── TransactionRowView.swift        # Row component
├── AddTransactionView.swift        # Add transaction form
└── TransactionDetailView.swift     # Detail view
```

## Development Workflows

### Universal Development Script
```bash
# Build project (auto-detects Swift/XCode/Node/Python)
./dev.sh build

# Run comprehensive checks (lint + test + build)
./dev.sh check

# Format code with SwiftFormat
./dev.sh format

# Run tests
./dev.sh test
```

### Master Automation System
```bash
# From workspace root - run automation for all projects
./Tools/Automation/master_automation.sh all

# Run automation for specific project
./Tools/Automation/master_automation.sh run MomentumFinance

# Format code across all projects
./Tools/Automation/master_automation.sh format
```

## Code Conventions & Patterns

### Commit Message Standards
**Conventional Commits (enforced via commitlint):**
```bash
# Valid formats
feat: add new transaction filtering feature
fix: resolve crash in budget calculation
docs: update API documentation
refactor: simplify view model logic
test: add unit tests for expense categorization

# Invalid (will be rejected)
"fixed bug"
"updated code"
"changes"
```

### Naming Conventions
```swift
// View extensions
extension Features.Transactions {
    struct TransactionsView: View { /* ... */ }
}

// Observable ViewModels
@MainActor
@Observable
final class TransactionsViewModel { /* ... */ }

// SwiftData Models
@Model
final class FinancialTransaction { /* ... */ }
```

### Error Handling Patterns
```swift
func performAsyncOperation() async throws -> Result {
    do {
        let result = try await networkService.fetchData()
        return result
    } catch {
        Logger.logError(error, context: "Data fetching failed")
        throw error
    }
}
```

## AI Integration Patterns

### Financial Intelligence Engine
```swift
@MainActor
class AdvancedFinancialIntelligence: ObservableObject {
    @Published var insights: [FinancialInsight] = []
    @Published var predictions: [FinancialPrediction] = []

    func analyzeFinancialData() async {
        async let spendingAnalysis = analyzeSpendingPatterns()
        async let budgetAnalysis = analyzeBudgetPerformance()
        async let investmentAnalysis = analyzeInvestmentPortfolio()

        let results = await [spendingAnalysis, budgetAnalysis, investmentAnalysis]
        await processAnalysisResults(results)
    }
}
```

## Testing Patterns

### Unit Test Structure
```swift
class TransactionsViewModelTests: XCTestCase {
    var viewModel: TransactionsViewModel!
    var mockContext: ModelContext!

    override func setUp() {
        mockContext = createMockModelContext()
        viewModel = TransactionsViewModel()
        viewModel.setModelContext(mockContext)
    }

    func testTransactionFiltering() async {
        // Given
        let transactions = createMockTransactions()

        // When
        let filtered = viewModel.filterTransactions(transactions, by: .income)

        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.transactionType == .income })
    }
}
```

## Data Flow Patterns

### SwiftData Context Management
```swift
struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ContentView()
            .environment(\.modelContext, modelContext)
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
    }
}
```

### Observable State Management
```swift
@MainActor
@Observable
final class DashboardViewModel {
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: Error?

    func refreshData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            accounts = try await dataService.fetchAccounts()
            transactions = try await dataService.fetchTransactions()
        } catch {
            self.error = error
        }
    }
}
```

## UI/UX Patterns

### SwiftUI Navigation
```swift
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }
                .tag(0)

            TransactionsView()
                .tabItem { Label("Transactions", systemImage: "creditcard.fill") }
                .tag(1)
        }
    }
}
```

### Responsive Layout Patterns
```swift
struct AdaptiveGrid<Content: View>: View {
    let content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            #if os(iOS)
            LazyVGrid(columns: adaptiveColumns(for: geometry.size.width)) {
                content()
            }
            #elseif os(macOS)
            LazyHGrid(rows: adaptiveRows(for: geometry.size.height)) {
                content()
            }
            #endif
        }
    }

    private func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let count = max(1, Int(width / 300))
        return Array(repeating: GridItem(.flexible()), count: count)
    }
}
```

## Performance Optimization Patterns

### Lazy Loading
```swift
struct TransactionListView: View {
    @State private var transactions: [Transaction] = []
    @State private var loadedPages = 0
    private let pageSize = 50

    var body: some View {
        List {
            ForEach(transactions) { transaction in
                TransactionRowView(transaction: transaction)
                    .onAppear {
                        if transaction == transactions.last {
                            loadMoreTransactions()
                        }
                    }
            }
        }
        .onAppear { loadInitialTransactions() }
    }

    private func loadMoreTransactions() {
        Task {
            let nextPage = await dataManager.loadTransactions(
                page: loadedPages + 1,
                size: pageSize
            )
            await MainActor.run {
                transactions.append(contentsOf: nextPage)
                loadedPages += 1
            }
        }
    }
}
```

## Key Project Patterns

### Financial Calculation Methods
```swift
extension TransactionsViewModel {
    func spendingByCategory(_ transactions: [FinancialTransaction]) -> [String: Double] {
        var spending: [String: Double] = [:]
        for transaction in transactions where transaction.transactionType == .expense {
            let categoryName = transaction.category?.name ?? "Uncategorized"
            spending[categoryName, default: 0] += transaction.amount
        }
        return spending
    }

    func totalIncome(_ transactions: [FinancialTransaction], for period: DateInterval? = nil) -> Double {
        let filtered = period.map { transactions.filter { $0.contains($1) } } ?? transactions
        return filtered.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
    }
}
```

### Cross-Platform Adaptations
```swift
struct AdaptiveTransactionView: View {
    var body: some View {
        #if os(iOS)
        iOSTransactionView()
        #elseif os(macOS)
        macOSTransactionView()
        #endif
    }
}
```

## Quality Assurance

### Pre-commit Hooks
```yaml
repos:
  - repo: https://github.com/realm/SwiftLint
    rev: 0.54.0
    hooks:
      - id: swiftlint
        args: [--strict]

  - repo: https://github.com/nicklockwood/SwiftFormat
    rev: 0.52.0
    hooks:
      - id: swiftformat
```

### CI Pipeline
```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with: { xcode-version: '15.0' }
      - name: Run Tests
        run: xcodebuild test -project MomentumFinance.xcodeproj -scheme MomentumFinance
      - name: Run SwiftLint
        run: swiftlint
```

## Best Practices Summary

1. **Always use MVVM pattern** with Observable ViewModels
2. **Follow SwiftData conventions** for data persistence and relationships
3. **Implement proper error handling** with Logger integration
4. **Use platform-specific adaptations** with conditional compilation
5. **Follow commit message conventions** (feat:, fix:, docs:, etc.)
6. **Run quality checks** before committing (`./dev.sh check`)
7. **Document complex financial logic** with comprehensive comments
8. **Use SwiftUI best practices** for responsive layouts
9. **Implement proper testing** for business logic
10. **Follow the established file organization** patterns in Shared/Features/

---

*Momentum Finance AI Guidelines - Updated: September 15, 2025*
*Framework: SwiftUI 5.0, SwiftData, iOS 17+/macOS 14+*
*Architecture: MVVM, Modular Design, Cross-Platform*
