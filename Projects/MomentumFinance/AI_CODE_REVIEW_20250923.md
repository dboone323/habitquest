# AI Code Review for MomentumFinance

Generated: Tue Sep 23 20:19:58 CDT 2025

## EnhancedAccountDetailView.swift

# Code Review: EnhancedAccountDetailView.swift

## 1. Code Quality Issues

### Missing Imports

```swift
// Missing import for Foundation (Date handling)
import Foundation
```

### Incomplete Implementation

The code cuts off mid-implementation. The `HStack` at the end is incomplete and the view body doesn't show the complete structure.

### Type Safety Issues

```swift
// accountId should be UUID type, not String
let accountId: String  // Change to: let accountId: UUID
```

### Optional Handling

```swift
// Force unwrapping account in filteredTransactions
private var filteredTransactions: [FinancialTransaction] {
    guard let account else { return [] }

    return self.transactions
        .filter { $0.account?.id == self.accountId && self.isTransactionInSelectedTimeFrame($0.date) }
        .sorted { $0.date > $1.date }
}
```

**Fix:** Add proper error handling or empty state UI for when account is nil.

## 2. Performance Problems

### Inefficient Filtering

```swift
// This creates multiple filters and sorts on every view refresh
.filter { $0.account?.id == self.accountId && self.isTransactionInSelectedTimeFrame($0.date) }
.sorted { $0.date > $1.date }
```

**Fix:** Use `@Query` with predicates or implement caching:

```swift
@Query(filter: #Predicate<FinancialTransaction> { transaction in
    transaction.account?.id == accountId
}, sort: \.date, order: .reverse)
private var transactions: [FinancialTransaction]
```

### State Management

```swift
@State private var selectedTransactionIds: Set<String> = []
```

**Fix:** Use `Set<UUID>` instead of `Set<String>` for better performance with UUID comparison.

## 3. Security Vulnerabilities

### No Input Validation

```swift
let accountId: String
```

**Fix:** Add validation to ensure the accountId is a valid UUID format.

### Potential Injection

If accountId comes from user input, ensure it's properly sanitized before use in queries.

## 4. Swift Best Practices Violations

### Missing Access Control

```swift
private var account: FinancialAccount? {
    self.accounts.first(where: { $0.id == self.accountId })
}
```

**Good:** This is properly marked as private.

### Inconsistent Self Usage

```swift
// Mix of self. and without self
self.accounts.first(where: { $0.id == self.accountId })
```

**Fix:** Be consistent - either use `self.` throughout or omit it where possible.

### Enum Naming

```swift
enum TimeFrame: String, CaseIterable, Identifiable {
    case last30Days = "Last 30 Days"
    // Consider camelCase for raw values to match Swift conventions
}
```

## 5. Architectural Concerns

### View Doing Too Much

The view handles:

- Data fetching
- Filtering logic
- Business logic (time frame calculations)
- State management for editing

**Fix:** Extract business logic to a ViewModel:

```swift
@Observable
class AccountDetailViewModel {
    private let accountId: UUID
    private let dataService: FinancialDataService

    var transactions: [FinancialTransaction] = []
    var selectedTimeFrame: TimeFrame = .last30Days

    // Business logic methods here
}
```

### Tight Coupling

The view is tightly coupled to SwiftData models. Consider using protocol abstraction:

```swift
protocol FinancialAccountProtocol {
    var id: UUID { get }
    // other properties
}
```

## 6. Documentation Needs

### Missing Documentation

```swift
// Add documentation for the main struct
/// Displays detailed information about a financial account
/// - Parameter accountId: The unique identifier of the account to display
struct EnhancedAccountDetailView: View {
    let accountId: String
```

### Method Documentation

```swift
// Document the computed properties and methods
private var filteredTransactions: [FinancialTransaction] {
    /// Filters transactions based on selected time frame and account
    /// - Returns: Array of filtered and sorted transactions
}
```

### Time Frame Enum Documentation

```swift
enum TimeFrame: String, CaseIterable, Identifiable {
    /// Last 30 days from current date
    case last30Days = "Last 30 Days"
    /// Last 90 days from current date
    case last90Days = "Last 90 Days"
    // etc.
}
```

## Additional Recommendations

### Error Handling

Add proper error handling for when account is not found:

```swift
private var account: FinancialAccount? {
    guard let account = accounts.first(where: { $0.id == accountId }) else {
        // Log error or show error state
        return nil
    }
    return account
}
```

### Testing

Add unit tests for:

- Time frame filtering logic
- Transaction sorting
- Account retrieval

### Localization

Hardcoded strings should be localized:

```swift
case last30Days = "Last 30 Days"  // Use NSLocalizedString
```

### Accessibility

Add accessibility identifiers for UI testing:

```swift
HStack {
    // Add accessibility identifiers
    .accessibilityIdentifier("accountDetailToolbar")
}
```

## Summary of Critical Actions

1. **Complete the implementation** - The view is incomplete
2. **Extract business logic** to a ViewModel
3. **Fix performance issues** with efficient data filtering
4. **Add proper error handling** and empty states
5. **Implement proper documentation**
6. **Add accessibility support**
7. **Consider localization** for hardcoded strings

The foundation is good, but needs architectural improvements and completion of the implementation.

## MacOSUIIntegration.swift

# Code Review: MacOSUIIntegration.swift

## 1. Code Quality Issues

### 🔴 Critical Issues

- **Incomplete Switch Statement**: The `switch` statement doesn't have a `default` case or handle all possible enum values, which could lead to runtime crashes if new cases are added.
- **Incomplete Implementation**: The transaction case has a comment about missing implementation but no actual code.

### 🟡 Moderate Issues

- **Magic Numbers**: Hardcoded tab indices (1, 2, 3, 4) instead of using named constants or enums.
- **Force Unwrapping**: Using `if let id = item.id` pattern is good, but consider using `guard let` for early returns to reduce nesting.

## 2. Performance Problems

### 🟢 Minor Issues

- **Navigation Path Management**: Appending to navigation paths without checking if the item is already in the path could lead to duplicate navigation states.

## 3. Security Vulnerabilities

### 🟢 No Critical Security Issues Found

- The code appears to handle navigation only, with no sensitive data processing.

## 4. Swift Best Practices Violations

### 🔴 Major Violations

- **Missing Documentation**: The function and parameters lack proper documentation.
- **Incomplete Error Handling**: No handling for cases where `item.id` might be nil or invalid.

### 🟡 Moderate Violations

- **Type Safety**: Using raw integers for tab selection instead of type-safe enums.
- **Protocol Conformance**: Consider making `ListableItem` conform to `Identifiable` if it doesn't already.

## 5. Architectural Concerns

### 🔴 Critical Concerns

- **Tight Coupling**: The function knows about specific tab indices and navigation paths, violating separation of concerns.
- **Platform-Specific Logic in Shared Code**: This extension might be used across platforms but contains macOS-specific assumptions.

### 🟡 Moderate Concerns

- **Navigation Coordination**: The function handles both selection state and navigation path updates, which might belong to different responsibilities.

## 6. Documentation Needs

### 🔴 Critical Documentation Missing

- Function purpose and parameters undocumented
- No documentation for the navigation behavior
- Missing documentation for the cross-platform compatibility mechanism

## Actionable Recommendations

### 1. Immediate Fixes

```swift
// Replace magic numbers with enum
enum AppTab: Int {
    case dashboard = 0
    case transactions = 1
    case budgets = 2
    case subscriptions = 3
    case goals = 4
}

// Add default case to switch statement
switch item.type {
// existing cases...
default:
    // Handle unknown types or log error
    assertionFailure("Unhandled ListableItem type: \(item.type)")
    return
}
```

### 2. Architectural Improvements

```swift
// Consider creating a dedicated macOS navigation handler
protocol MacOSNavigationHandler {
    func handleItemSelection(_ item: ListableItem?)
}

// Extract navigation path management to separate methods
private func navigateToAccountDetail(_ id: UUID) {
    selectedTab = .transactions
    transactionsNavPath.append(TransactionsDestination.accountDetail(id))
}
```

### 3. Documentation Enhancement

```swift
/// Handles navigation to detail views for selected items in macOS three-column layout
/// - Parameter item: The selected ListableItem to navigate to, or nil to clear selection
/// - Note: This method maintains cross-platform navigation state compatibility
func navigateToDetail(item: ListableItem?) {
    // implementation
}
```

### 4. Complete the Implementation

```swift
case .transaction:
    if let id = item.id {
        selectedTab = .transactions
        // Implement proper transaction navigation or remove this case
        // until the navigation destination is defined
        transactionsNavPath.append(TransactionsDestination.transactionDetail(id))
    }
```

### 5. Error Handling Improvement

```swift
guard let item else {
    // Clear selection and navigation state if needed
    clearSelection()
    return
}

guard let id = item.id else {
    // Handle missing ID appropriately
    return
}
```

## Summary

The code shows good intention but requires significant refactoring for production use. The most critical issues are the incomplete switch statement, magic numbers, and lack of documentation. The architectural coupling between platform-specific UI and navigation coordination is concerning and should be addressed through better separation of concerns.

**Priority**: Medium-High - Requires refactoring before further development to prevent technical debt accumulation.

## EnhancedSubscriptionDetailView.swift

# Code Review: EnhancedSubscriptionDetailView.swift

## 1. Code Quality Issues

### 🚨 Critical Issues

- **Incomplete Enum Definition**: The `Timespan` enum is cut off mid-definition (missing closing brace and `id` property)
- **Potential Force Unwrapping**: Line `guard let subscription, let subscriptionId = subscription.id else { return [] }` could crash if `subscription.id` exists but is nil

### ⚠️ Moderate Issues

- **Magic Strings**: Raw strings used for transaction filtering logic could be error-prone
- **Complex Filter Logic**: The transaction filtering combines ID matching and name pattern matching which might produce unexpected results

## 2. Performance Problems

- **Inefficient Filtering**: `transactions.filter` runs on every view refresh and could be expensive for large datasets
- **Multiple Queries**: Three separate `@Query` properties may cause unnecessary database operations
- **String Operations**: `lowercased()` calls in filter could be expensive for large transaction lists

## 3. Security Vulnerabilities

- **No Input Sanitization**: The name pattern matching (`contains`) could potentially be exploited if transaction names contain malicious content
- **Direct ID Exposure**: Using raw subscriptionId in queries might be vulnerable to injection if not properly validated

## 4. Swift Best Practices Violations

- **Missing Access Control**: Properties like `subscription` computed property should be private
- **Force Unwrapping Pattern**: Using `!` for subscription.id access is anti-pattern
- **State Management**: Multiple @State properties for related functionality should be grouped
- **Stringly-Typed**: Using String for subscriptionId instead of a stronger type

## 5. Architectural Concerns

- **View Doing Too Much**: This view handles data fetching, filtering, editing, and UI rendering
- **Tight Coupling**: Direct dependency on database models in view layer
- **Business Logic in View**: Transaction filtering logic belongs in a service layer
- **Model-View Mixing**: Using `SubscriptionEditModel` alongside `Subscription` model

## 6. Documentation Needs

- **Missing Documentation**: No comments explaining complex filtering logic
- **No Purpose Documentation**: The view's overall purpose and responsibilities aren't documented
- **Incomplete Copyright**: Only has copyright but no license information

## 🔧 Specific Actionable Recommendations

### 1. Fix Critical Syntax Issues

```swift
enum Timespan: String, CaseIterable, Identifiable {
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case oneYear = "1 Year"

    var id: String { rawValue }
} // Add missing closing brace
```

### 2. Improve Data Access Pattern

```swift
// Replace with a dedicated service
private var relatedTransactions: [FinancialTransaction] {
    SubscriptionService.shared.getTransactionsForSubscription(
        subscriptionId: subscriptionId,
        transactions: transactions
    )
}
```

### 3. Enhance Safety

```swift
// Instead of force unwrapping
guard let subscription = subscription,
      let subscriptionId = subscription.id.uuidString else { return [] }
```

### 4. Add Proper Access Control

```swift
private let subscriptionId: String
@State private var isEditing = false
// Make all state properties private
```

### 5. Implement Performance Optimizations

```swift
// Use lazy filtering or pre-compute
@Query private var transactions: [FinancialTransaction]
    .filter(#Predicate<FinancialTransaction> { transaction in
        // Use SwiftData predicates for better performance
    })
```

### 6. Security Improvements

```swift
// Add input validation
guard isValidSubscriptionId(subscriptionId) else { return nil }
```

### 7. Architectural Refactoring

Consider extracting:

- `SubscriptionDataService` for data operations
- `SubscriptionEditViewModel` for state management
- `TransactionFilterService` for filtering logic

### 8. Documentation Additions

```swift
/// Displays detailed information about a subscription including related transactions
/// and provides editing capabilities. Optimized for macOS screen layout.
///
/// - Parameter subscriptionId: The unique identifier for the subscription to display
/// - Precondition: subscriptionId must correspond to an existing subscription
struct EnhancedSubscriptionDetailView: View {
```

## Priority Implementation Order:

1. **Fix syntax errors** (incomplete enum)
2. **Remove force unwrapping** and add safety checks
3. **Extract filtering logic** to a service class
4. **Add proper access control** to all properties
5. **Implement performance optimizations** for large datasets
6. **Add comprehensive documentation**

The view shows good structure but needs immediate attention to the critical issues and substantial refactoring for long-term maintainability.

## MacOS_UI_Enhancements.swift

# Code Review: MacOS_UI_Enhancements.swift

## 1. Code Quality Issues

**🔴 Critical Issues:**

- **Incomplete Code**: The file appears to be truncated mid-implementation (cuts off at `Text(transaction.name)`). This is a major issue that prevents compilation.
- **Missing Imports**: No import for `Foundation` which is needed for currency formatting and other basic types.

**🟡 Moderate Issues:**

- **Mixed Abstraction Levels**: The extension contains both view components and what appears to be a main app structure. Consider separating concerns.
- **Hardcoded Currency**: `"USD"` is hardcoded instead of using locale-aware formatting.

## 2. Performance Problems

**🟡 Potential Issues:**

- **Query Optimization**: The `@Query` properties may benefit from predicates or sorting to limit data loading, especially for `recentTransactions.prefix(5)` which loads all transactions then takes only 5.
- **Inefficient List Rendering**: No explicit `id` parameter for `ForEach` with `recentTransactions`, which could cause performance issues with large datasets.

## 3. Security Vulnerabilities

**🟡 Moderate Concerns:**

- **No Access Control**: No `private` access modifiers on properties that should be encapsulated.
- **Potential Data Exposure**: Financial data displayed without consideration for privacy/security states (e.g., when app is in background).

## 4. Swift Best Practices Violations

**🔴 Critical Violations:**

- **Incomplete Implementation**: The code is truncated, violating basic completeness requirements.

**🟡 Moderate Violations:**

- **Naming Convention**: `ContentView_macOS` doesn't follow Swift's camelCase convention (should be `ContentViewMacOS`).
- **Force Unwrapping**: `ListableItem` initialization suggests potential force-unwrapping of optional values.
- **Stringly-Typed Values**: Using strings for section headers instead of localized string keys.

## 5. Architectural Concerns

**🔴 Critical Issues:**

- **Tight Coupling**: The view is tightly coupled to specific model types (`FinancialAccount`, `FinancialTransaction`).
- **Mixed Responsibilities**: The view handles both presentation and data querying directly.

**🟡 Moderate Issues:**

- **Navigation Pattern**: Using `NavigationLink` in a macOS context may not be the optimal navigation pattern for a three-column layout.
- **Type Safety**: `ListableItem` appears to be a generic type-erasure pattern that might be losing type safety.

## 6. Documentation Needs

**🔴 Critical Missing Documentation:**

- No documentation for `ListableItem` type and its purpose
- No comments explaining the three-column layout architecture
- Missing parameter documentation for custom types

**🟡 Moderate Documentation Gaps:**

- Incomplete documentation for the extension's purpose
- No documentation for the selection handling mechanism

## Actionable Recommendations

### Immediate Fixes (Critical):

```swift
// 1. Complete the truncated code
Text(transaction.name)
    .font(.headline)
Text(transaction.amount.formatted(.currency(code: "USD")))
    .font(.subheadline)
}
}
.padding(.vertical, 4)
}
.tag(ListableItem(id: transaction.id, name: transaction.name, type: .transaction))
}
}
}
}

// 2. Add necessary imports
import Foundation
```

### Architectural Improvements:

```swift
// 1. Use a ViewModel to decouple data access
@Observable
class DashboardListViewModel {
    private let dataService: FinancialDataService
    var accounts: [FinancialAccount] = []
    var recentTransactions: [FinancialTransaction] = []

    init(dataService: FinancialDataService) {
        self.dataService = dataService
    }

    func loadData() async {
        // Load data asynchronously
    }
}

// 2. Use @FetchRequest with predicates for better performance
@FetchRequest(
    sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
    predicate: NSPredicate(format: "date >= %@", Date().addingTimeInterval(-30*24*60*60) as CVarArg),
    animation: .default)
private var recentTransactions: [FinancialTransaction]
```

### Swift Best Practices Implementation:

```swift
// 1. Add proper access control
private var selectedItem: ListableItem?

// 2. Use locale-aware currency formatting
Text(account.balance.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))

// 3. Add explicit identifiers for ForEach
ForEach(self.recentTransactions.prefix(5), id: \.id) { transaction in
```

### Security Enhancements:

```swift
// 1. Add privacy protection
.environment(\.redactionReasons, .privacy) // When appropriate

// 2. Use secure coding practices for financial data
```

### Documentation Additions:

```swift
/// A list view component for displaying financial accounts and recent transactions
/// in a macOS three-column layout architecture.
///
/// - Note: This view is designed specifically for macOS and uses NavigationSplitView
/// - Important: Requires SwiftData model context to be available in environment
struct DashboardListView: View {
    // ... existing code ...
}
```

### Performance Optimization:

```swift
// Optimize the recent transactions query to only fetch needed records
@Query(sort: \FinancialTransaction.date, order: .reverse, limit: 5)
private var recentTransactions: [FinancialTransaction]
```

## Additional Recommendations

1. **Implement Error Handling**: Add error handling for data loading failures
2. **Add Unit Tests**: Create tests for the view model and data processing
3. **Localization Support**: Use `LocalizedStringKey` for user-facing text
4. **Accessibility**: Add accessibility identifiers and labels for UI testing
5. **Dark Mode Support**: Ensure proper color contrast in both light and dark modes

The code shows good potential for a macOS-optimized interface but requires completion and significant architectural refinement to meet production quality standards.

## UpdatedMomentumFinanceApp.swift

# Code Review: MomentumFinanceApp.swift

## 1. Code Quality Issues

### **Critical Issue: Incomplete Scene Declaration**

```swift
var body: some Scene {
    WindowGroup {
        #if os(iOS)
        ContentView()
            .environment(NavigationCoordinator.shared)
        #elseif os(macOS)
        // Use the enhanced macOS UI that better utilizes screen space
        IntegratedMacOSContentView()
            .environment(NavigationCoordinator.shared)
        #endif
    }
```

**Missing closing brace for the `body` computed property and the `App` protocol implementation.** This code is incomplete and won't compile.

### **Model Configuration**

```swift
let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
```

**Actionable:** Consider making `isStoredInMemoryOnly` configurable based on build configuration (e.g., `.debug` vs `.release`).

## 2. Performance Problems

### **Model Container Initialization**

```swift
var sharedModelContainer: ModelContainer = {
    // Initialization code
}()
```

**Actionable:** This creates the container at app startup. Consider lazy initialization if the container is heavy:

```swift
lazy var sharedModelContainer: ModelContainer = {
    // Initialization code
}()
```

## 3. Security Vulnerabilities

### **Fatal Error Handling**

```swift
fatalError("Could not create ModelContainer: \(error)")
```

**Critical Security Issue:** Never use `fatalError` in production code. This crashes the app and provides error details to users.

**Actionable:** Replace with graceful error handling:

```swift
do {
    return try ModelContainer(for: schema, configurations: [modelConfiguration])
} catch {
    // Log error securely and show user-friendly message
    NSLog("Database initialization failed: \(error.localizedDescription)")
    return try! ModelContainer(for: Schema([]), configurations: []) // Fallback empty container
}
```

## 4. Swift Best Practices Violations

### **Access Control**

```swift
public struct MomentumFinanceApp: App {
```

**Unnecessary `public` access level.** The main app struct doesn't need to be public.

### **String Interpolation in Errors**

```swift
fatalError("Could not create ModelContainer: \(error)")
```

**Violates privacy best practices.** Don't expose raw error objects to users.

### **Enum Naming**

```swift
enum ModelReferences {
```

**Poor naming.** "References" is vague. Better names: `ModelTypes` or `SchemaModels`.

## 5. Architectural Concerns

### **Tight Coupling**

```swift
.environment(NavigationCoordinator.shared)
```

**Architectural Smell:** Hardcoded singleton dependency injection. Consider proper dependency injection pattern.

**Actionable:** Make dependencies injectable:

```swift
@Environment(\.navigationCoordinator) var navigationCoordinator
```

### **Platform-Specific Code**

```swift
#if os(iOS)
// iOS code
#elseif os(macOS)
// macOS code
#endif
```

**Maintenance Concern:** This approach can lead to code duplication. Consider using a unified view with platform-specific modifiers.

## 6. Documentation Needs

### **Missing Documentation**

**No documentation for:**

- The purpose of `ModelReferences`
- The shared model container
- Platform-specific content views
- NavigationCoordinator usage

**Actionable:** Add documentation:

```swift
/// Main application entry point conforming to SwiftUI App protocol
/// Handles model container setup and platform-specific UI configuration
struct MomentumFinanceApp: App {

    /// Shared model container for SwiftData persistence
    /// Contains all financial data models: accounts, transactions, etc.
    var sharedModelContainer: ModelContainer = {
        // ... initialization
    }()
}
```

## **Recommended Refactored Code:**

```swift
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData
import SwiftUI

// MARK: - Model Schema
private extension MomentumFinanceApp {
    enum ModelTypes {
        static let accounts = FinancialAccount.self
        static let transactions = FinancialTransaction.self
        static let subscriptions = Subscription.self
        static let budgets = Budget.self
        static let categories = ExpenseCategory.self
        static let goals = SavingsGoal.self
    }
}

/// Main application entry point handling data persistence and UI configuration
struct MomentumFinanceApp: App {
    @State private var appState = AppState()

    // Lazy initialization for better performance
    lazy var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ModelTypes.accounts,
            ModelTypes.transactions,
            ModelTypes.subscriptions,
            ModelTypes.budgets,
            ModelTypes.categories,
            ModelTypes.goals
        ])

        #if DEBUG
        let inMemory = true // Use in-memory storage for debugging
        #else
        let inMemory = false
        #endif

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Graceful error handling for production
            Logger.database.error("Failed to initialize model container: \(error)")
            // Provide fallback empty container
            return try! ModelContainer(for: Schema([]), configurations: [])
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppContentView()
                .environment(appState)
                .environment(\.modelContainer, sharedModelContainer)
        }
    }
}

// Unified content view handling platform differences internally
struct AppContentView: View {
    @Environment(\.modelContainer) private var modelContainer

    var body: some View {
        #if os(iOS)
        iOSContentView()
        #elseif os(macOS)
        macOSContentView()
        #endif
    }
}
```

## **Summary of Action Items:**

1. **Fix incomplete code structure** - Add missing braces and complete App protocol implementation
2. **Replace fatalError** with proper error handling and logging
3. **Implement lazy initialization** for model container
4. **Improve naming conventions** (ModelReferences → ModelTypes)
5. **Add comprehensive documentation** for all public APIs
6. **Refactor platform-specific code** to reduce duplication
7. **Consider proper dependency injection** instead of global singletons
8. **Add proper logging** instead of print statements
9. **Implement different storage strategies** for debug vs release builds

## EnhancedBudgetDetailView.swift

# Code Review: EnhancedBudgetDetailView.swift

## 1. Code Quality Issues

### 🔍 **Missing Imports**

```swift
// Add these imports for missing types
import Foundation
import Combine // For future state management
```

### 🔍 **Unsafe Force Unwrapping**

```swift
private var budget: Budget? {
    self.budgets.first(where: { $0.id == self.budgetId })
}
// ✅ Good - properly using optional here
```

### 🔍 **Magic Numbers in Time Calculations**

```swift
// Replace hardcoded time calculations with proper Date extensions
private func isTransactionInSelectedTimeFrame(_ date: Date) -> Bool {
    // Current implementation likely uses magic numbers - extract to constants
}
```

### 🔍 **Inconsistent Naming**

```swift
// BudgetEditModel should follow Swift naming convention (BudgetEditModel → BudgetEditViewModel)
@State private var editedBudget: BudgetEditModel?
```

## 2. Performance Problems

### ⚡ **Inefficient Filtering Operations**

```swift
private var relatedTransactions: [FinancialTransaction] {
    guard let budget, let categoryId = budget.category?.id else { return [] }

    // This filters ALL transactions every time - inefficient for large datasets
    let relevantTransactions = self.transactions.filter {
        $0.category?.id == categoryId &&
        $0.amount < 0 &&
        self.isTransactionInSelectedTimeFrame($0.date)
    }

    return relevantTransactions.sorted { $0.date > $1.date }
}
```

**Recommendation:**

```swift
// Use @Query with predicates for better performance
@Query(filter: #Predicate<FinancialTransaction> { transaction in
    // Add predicate logic here
})
private var filteredTransactions: [FinancialTransaction]
```

### ⚡ **Repeated Computations**

```swift
// relatedTransactions is computed repeatedly - consider caching or memoization
private var relatedTransactions: [FinancialTransaction] {
    // Add caching mechanism for time frame changes
}
```

## 3. Security Vulnerabilities

### 🔒 **Injection Risks**

```swift
let budgetId: String
// Ensure budgetId is validated/sanitized if coming from user input
```

### 🔒 **Data Exposure**

```swift
// No apparent security issues, but ensure:
// - Financial data is properly protected
// - User authorization checks are implemented elsewhere
```

## 4. Swift Best Practices Violations

### 🎯 **Missing Access Control**

```swift
// Add proper access control
private var budget: Budget? {
    budgets.first(where: { $0.id == budgetId })
}

// TimeFrame should be private if not used externally
private enum TimeFrame: String, CaseIterable, Identifiable {
    // ...
}
```

### 🎯 **Strong Reference Cycles**

```swift
// Check for potential retain cycles in closures
self.isTransactionInSelectedTimeFrame($0.date) // ✅ No obvious cycles
```

### 🎯 **Stringly Typed Identifiers**

```swift
@State private var selectedTransactions: Set<String> = []
// Consider using typed identifiers: Set<FinancialTransaction.ID>
```

## 5. Architectural Concerns

### 🏗️ **Tight Coupling**

```swift
// View knows too much about data filtering logic
// Extract filtering and business logic to a ViewModel or Service
```

**Recommendation:**

```swift
// Create a BudgetDetailViewModel
@Observable
class BudgetDetailViewModel {
    private let budgetId: String
    private let transactionService: TransactionServiceProtocol

    var filteredTransactions: [FinancialTransaction] = []
    var selectedTimeFrame: TimeFrame = .currentMonth

    func loadTransactions() async {
        // Move filtering logic here
    }
}
```

### 🏗️ **Violation of Single Responsibility**

```swift
// View handles data filtering, sorting, and presentation
// Break into smaller components:
// - TransactionListComponent
// - BudgetChartComponent
// - TimeFrameSelectorComponent
```

## 6. Documentation Needs

### 📚 **Add Documentation**

```swift
// MARK: - Computed Properties

/// The budget being displayed, if found in the database
private var budget: Budget? {
    budgets.first(where: { $0.id == budgetId })
}

/// Transactions related to this budget's category within the selected time frame
private var relatedTransactions: [FinancialTransaction] {
    // Add doc comment explaining filtering logic
}

// MARK: - Helper Methods

/// Determines if a transaction falls within the currently selected time frame
/// - Parameter date: The transaction date to check
/// - Returns: Boolean indicating if transaction is in selected range
private func isTransactionInSelectedTimeFrame(_ date: Date) -> Bool {
    // Implementation
}
```

### 📚 **Add Usage Examples**

```swift
// Add examples for complex calculations or business rules
```

## 🔧 **Actionable Recommendations**

1. **Extract Business Logic**: Create `BudgetDetailViewModel` to handle data processing
2. **Optimize Data Fetching**: Use `@Query` with predicates instead of manual filtering
3. **Add Error Handling**: Handle cases where budget isn't found or data is incomplete
4. **Implement Loading States**: Add loading indicators for large data operations
5. **Add Unit Tests**: Test filtering logic, time frame calculations, and edge cases
6. **Improve Accessibility**: Add accessibility identifiers for UI testing
7. **Implement Pagination**: For large transaction lists, add pagination or virtualization

## ✅ **Code Quality Score**: 7/10

The code is functional but could benefit from architectural improvements and performance optimizations. The use of SwiftData and SwiftUI is appropriate, but business logic should be separated from the view layer.

Would you like me to provide sample implementations for any of these recommendations?

## KeyboardShortcutManager.swift

# Code Review: KeyboardShortcutManager.swift

## 1. Code Quality Issues

### **Critical Issue: Incomplete Implementation**

```swift
appMenu.addItem(NSMenuItem(
```

The code is incomplete and won't compile. The `createMainMenu()` method is unfinished and missing the closing parentheses and the rest of the menu structure.

### **Naming Inconsistencies**

```swift
let goalsReportsShortcut = KeyboardShortcut("5", modifiers: [.command])
```

- "goalsReportsShortcut" uses camelCase inconsistently (should be `goalsReportsShortcut` or better yet, split into separate shortcuts)
- Some shortcuts use abbreviations (`budgetsShortcut`) while others are more verbose

### **Magic Numbers/Characters**

```swift
let dashboardShortcut = KeyboardShortcut("1", modifiers: [.command])
```

The shortcut keys ("1", "2", etc.) are hardcoded without explanation. These should be defined as constants.

## 2. Performance Problems

**No significant performance issues** in this class as it's primarily a configuration class. However, the incomplete menu creation could cause runtime crashes.

## 3. Security Vulnerabilities

**No obvious security vulnerabilities** in this keyboard shortcut manager.

## 4. Swift Best Practices Violations

### **Missing Access Control**

```swift
let dashboardShortcut = KeyboardShortcut("1", modifiers: [.command])
```

All properties should have explicit access control modifiers. Most should be `private` or `internal` depending on usage.

### **Incomplete Documentation**

```swift
/// <#Description#>
/// - Returns: <#description#>
```

Placeholder documentation should be completed with actual descriptions.

### **Singleton Pattern Implementation**

```swift
static let shared = KeyboardShortcutManager()
private init() {}
```

This is correctly implemented as a singleton.

## 5. Architectural Concerns

### **Separation of Concerns Violation**

```swift
func createMainMenu() -> NSMenu
```

The class is responsible for both defining shortcuts AND creating the application menu. These should be separate responsibilities.

### **Hardcoded UI Strings**

```swift
NSMenuItem(title: "Momentum Finance", action: nil, keyEquivalent: "")
```

All menu titles and labels should be localized and potentially extracted to a strings file.

### **Missing Error Handling**

No mechanism to handle shortcut conflicts or invalid key combinations.

## 6. Documentation Needs

**Severely lacking documentation**. Each shortcut should document:

- What functionality it triggers
- Why this specific key combination was chosen
- Any potential conflicts with system shortcuts

## **Actionable Recommendations**

### 1. **Complete the Implementation**

```swift
private func createMainMenu() -> NSMenu {
    let mainMenu = NSMenu()

    // App menu
    let appMenu = NSMenu()
    let appMenuItem = NSMenuItem(title: "Momentum Finance", action: nil, keyEquivalent: "")
    appMenuItem.submenu = appMenu

    // Add standard menu items (About, Preferences, Quit, etc.)
    appMenu.addItem(NSMenuItem(title: "About Momentum Finance", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(NSMenuItem(title: "Preferences...", action: #selector(NSApplication.activateIgnoringOtherApps(_:)), keyEquivalent: ","))
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(NSMenuItem(title: "Quit Momentum Finance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

    mainMenu.addItem(appMenuItem)

    // Add other menus (File, Edit, View, etc.) with their respective shortcuts
    // ...

    return mainMenu
}
```

### 2. **Refactor with Constants**

```swift
private enum ShortcutKeys {
    static let dashboard = "1"
    static let transactions = "2"
    static let budgets = "3"
    static let subscriptions = "4"
    static let goalsReports = "5"
    static let newTransaction = "n"
    static let newBudget = "b"
    // ... etc.
}

private enum ShortcutModifiers {
    static let command: EventModifiers = [.command]
    static let commandShift: EventModifiers = [.command, .shift]
}

// Usage:
let dashboardShortcut = KeyboardShortcut(ShortcutKeys.dashboard, modifiers: ShortcutModifiers.command)
```

### 3. **Improve Access Control**

```swift
private(set) var dashboardShortcut: KeyboardShortcut
private(set) var transactionsShortcut: KeyboardShortcut
// ... etc.
```

### 4. **Add Comprehensive Documentation**

```swift
/// Keyboard shortcut for navigating to Dashboard view
/// - Key: Command + 1
/// - Rationale: Consistent with many macOS apps using number keys for navigation
/// - System Conflict: None known
let dashboardShortcut = KeyboardShortcut("1", modifiers: [.command])
```

### 5. **Consider Architectural Refactoring**

```swift
// Separate menu creation into its own class
class AppMenuFactory {
    static func createMainMenu(shortcutManager: KeyboardShortcutManager) -> NSMenu {
        // Implementation
    }
}

// In KeyboardShortcutManager:
func registerGlobalShortcuts() {
    NSApp.mainMenu = AppMenuFactory.createMainMenu(shortcutManager: self)
}
```

### 6. **Add Validation Method**

```swift
func validateShortcuts() throws {
    // Check for system shortcut conflicts
    // Validate all key combinations are valid
    // Ensure no duplicate shortcuts
}
```

### 7. **Implement Localization Ready**

```swift
private func localizedString(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

// Usage:
NSMenuItem(title: localizedString("MENU_APP_NAME"), action: nil, keyEquivalent: "")
```

## **Summary**

This class needs significant work to be production-ready. The most critical issue is the incomplete implementation, followed by architectural concerns about mixing shortcut definition with menu creation. The code shows good intention but requires completion, proper documentation, and better separation of concerns.

**Priority Fixes:**

1. Complete the `createMainMenu()` implementation
2. Add proper access control modifiers
3. Implement comprehensive documentation
4. Extract hardcoded strings for localization
5. Consider separating menu creation responsibilities

## ContentView_macOS.swift

# Code Review: ContentView_macOS.swift

## 1. Code Quality Issues

### **Critical Issues:**

- **Incomplete Extension**: The `macOSKeyboardShortcuts()` extension method is incomplete and missing closing braces
- **Unused Code**: `macOSSpecificViews.configureWindow()` and `configureToolbar()` are defined but never called/used
- **Empty Actions**: Toolbar buttons have empty action closures (`{}`)

### **Recommendations:**

```swift
// Fix incomplete extension
extension View {
    func macOSKeyboardShortcuts() -> some View {
        self
            .keyboardShortcut("n", modifiers: .command)
            .keyboardShortcut("w", modifiers: .command)
    } // Missing closing brace added
}

// Implement proper action handlers
Button(action: handleSettings, label: {
    Image(systemName: "gear")
})
```

## 2. Performance Problems

- **Window Configuration Timing**: `configureWindow()` should be called at appropriate application lifecycle points rather than being defined but unused
- **Toolbar Re-rendering**: The toolbar configuration creates new instances each time; consider caching or proper state management

## 3. Security Vulnerabilities

- **No Critical Issues Found**: No apparent security vulnerabilities in this UI code
- **Recommendation**: Ensure exported data handling (when implemented) includes proper sandboxing and user permission checks

## 4. Swift Best Practices Violations

### **Naming Conventions:**

- **❌ Violation**: `macOSSpecificViews` should follow camelCase: `macOSSpecificViews` → `macOSSpecificViews`
- **❌ Violation**: Enums should be capitalized: `macOSSpecificViews` → `MacOSSpecificViews`

### **Type Safety:**

- **❌ Violation**: `configureToolbar()` returns `some ToolbarContent` but the actual return type is specific

```swift
// Recommended fix
static func configureToolbar() -> ToolbarItemGroup<some View> {
    // implementation
}
```

### **Code Organization:**

- **❌ Violation**: macOS-specific code should be properly guarded with `#if os(macOS)` throughout

## 5. Architectural Concerns

### **Separation of Concerns:**

- **Mixing Responsibilities**: The extension mixes view modifiers with window configuration utilities
- **Global State Manipulation**: `configureWindow()` directly modifies `NSApp.appearance` which affects the entire application

### **Recommended Refactor:**

```swift
// Separate into distinct components
struct macOSViewModifiers: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 800, minHeight: 600)
            .preferredColorScheme(.automatic)
            .tint(.blue)
    }
}

struct MacOSToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            // Toolbar content
        }
    }
}
```

## 6. Documentation Needs

### **Missing Documentation:**

- **❌ Missing**: `configureWindow()` lacks documentation about when/where to call it
- **❌ Missing**: `macOSKeyboardShortcuts()` has placeholder documentation (`<#Description#>`)
- **❌ Missing**: Purpose of specific keyboard shortcuts not documented

### **Recommended Documentation:**

```swift
/// Configures macOS window appearance settings
/// Call this method during application startup in AppDelegate
static func configureWindow() {
    NSApp.appearance = NSAppearance(named: .aqua)
}

/// Adds macOS-specific keyboard shortcuts
/// - Adds Command+N for new items
/// - Adds Command+W for closing windows
func macOSKeyboardShortcuts() -> some View {
    self
        .keyboardShortcut("n", modifiers: .command) // New item
        .keyboardShortcut("w", modifiers: .command) // Close window
}
```

## **Actionable Summary:**

1. **Fix Syntax Errors**: Complete the incomplete extension with proper closing braces
2. **Implement Proper Actions**: Replace empty closures with actual handler functions
3. **Follow Naming Conventions**: Correct enum and type naming
4. **Add Comprehensive Documentation**: Document all methods with purpose and usage instructions
5. **Improve Architecture**: Separate view modifiers from utility functions
6. **Remove Dead Code**: Either implement or remove unused configuration methods
7. **Add OS Guarding**: Ensure all macOS-specific code is properly wrapped in `#if os(macOS)`

## **Priority Fixes:**

- **HIGH**: Fix incomplete extension (syntax error)
- **HIGH**: Implement actual button actions
- **MEDIUM**: Fix naming conventions and documentation
- **LOW**: Architectural refactoring

## EnhancedContentView_macOS.swift

# Code Review: EnhancedContentView_macOS.swift

## 1. Code Quality Issues

**Critical Issues:**

- **Incomplete Code**: The file appears to be truncated mid-implementation. The `ContentView_macOS` struct is missing its closing brace and the `detail:` parameter for the `NavigationSplitView`.
- **Accessibility Issue**: Duplicate `accessibilityLabel("Button")` modifier on the toolbar button.

**Other Quality Concerns:**

- **Magic Strings**: Hardcoded strings for titles, icons, and help text should be centralized for localization and maintainability.
- **State Management**: Multiple `@State` properties might be better organized into a dedicated view model.

## 2. Performance Problems

- **NavigationSplitView Configuration**: Using `.all` for `columnVisibility` might not be optimal for all screen sizes. Consider making this adaptive based on available space.
- **View Construction**: The `switch` statement in the content column might cause unnecessary view recreation when switching tabs.

## 3. Security Vulnerabilities

- No apparent security vulnerabilities in the shown code, but the incomplete nature prevents a full assessment.

## 4. Swift Best Practices Violations

**Architectural Issues:**

- **Tight Coupling**: Direct dependency on `NavigationCoordinator.shared` creates tight coupling and makes testing difficult.
- **View Logic**: Navigation logic should be abstracted away from the view for better testability.

**SwiftUI Best Practices:**

- **Missing `.navigationTitle`**: Each content view should have appropriate navigation titles.
- **Inconsistent Self Usage**: Mix of `self.` and implicit self references.

## 5. Architectural Concerns

- **Navigation Pattern**: The dual navigation system (both `NavigationCoordinator` and local `@State` properties) creates complexity and potential conflicts.
- **Separation of Concerns**: Navigation logic, view hierarchy, and business logic are intertwined.
- **Testing Difficulty**: The current structure makes unit testing challenging due to direct dependencies.

## 6. Documentation Needs

- **Missing Documentation**: No documentation for the `ContentView_macOS` struct or its properties.
- **Incomplete Comments**: The file appears to be missing its closing implementation.

## Actionable Recommendations

### 1. Fix Critical Issues

```swift
// Complete the NavigationSplitView implementation
} detail: {
    if let selectedListItem = selectedListItem {
        // Detail view for selected list item
        selectedListItem.detailView()
    } else {
        // Default detail view or empty state
        Text("Select an item")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
// Add missing closing brace for the struct
```

### 2. Improve Architecture

```swift
// Create a dedicated view model
@Observable
class ContentViewModel {
    var selectedSidebarItem: SidebarItem? = .dashboard
    var selectedListItem: ListableItem?
    var columnVisibility = NavigationSplitViewVisibility.all

    private let navigationCoordinator: NavigationCoordinator

    init(navigationCoordinator: NavigationCoordinator = .shared) {
        self.navigationCoordinator = navigationCoordinator
    }

    func toggleSidebar() {
        // Implementation
    }
}

// Use dependency injection
struct ContentView_macOS: View {
    @State private var viewModel: ContentViewModel

    init(viewModel: ContentViewModel = ContentViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
}
```

### 3. Enhance Code Quality

```swift
// Create constants for strings and icons
enum AppStrings {
    static let dashboard = "Dashboard"
    static let transactions = "Transactions"
    // ... other strings
}

enum AppIcons {
    static let house = "house"
    static let creditCard = "creditcard"
    // ... other icons
}

// Fix accessibility issue
Button(action: viewModel.toggleSidebar) {
    Image(systemName: "sidebar.left")
}
.accessibilityLabel("Toggle Sidebar")
.help("Toggle Sidebar")
```

### 4. Improve Performance

```swift
// Use lazy navigation or view builders to avoid unnecessary recreation
.contentColumn {
    contentViewForSelectedItem()
}

@ViewBuilder
private func contentViewForSelectedItem() -> some View {
    switch selectedSidebarItem {
    case .dashboard: Features.Dashboard.DashboardListView()
    case .transactions: Features.Transactions.TransactionsListView()
    case .budgets: Features.Budgets.BudgetListView()
    case nil: EmptyView()
    }
}
```

### 5. Add Documentation

```swift
/// macOS-specific content view implementation using NavigationSplitView
/// Handles sidebar navigation and detail views for the Momentum Finance app
struct ContentView_macOS: View {
    /// Manages navigation state and sidebar visibility
    @State private var viewModel: ContentViewModel

    /// Tracks the currently selected sidebar item for main navigation
    @State private var selectedSidebarItem: SidebarItem? = .dashboard

    /// Tracks the currently selected list item for detail view navigation
    @State private var selectedListItem: ListableItem?

    /// Controls the visibility of navigation split view columns
    @State private var columnVisibility = NavigationSplitViewVisibility.all
}
```

### 6. Testing Recommendations

```swift
// Make the view model injectable for testing
struct ContentView_macOS: View {
    @State private var viewModel: ContentViewModel

    init(viewModel: ContentViewModel = ContentViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
}

// Create testable view model
class MockNavigationCoordinator: NavigationCoordinator {
    // Mock implementation for testing
}
```

**Priority Fixes:**

1. Complete the truncated code implementation
2. Fix the duplicate accessibility modifier
3. Implement proper dependency injection
4. Add comprehensive documentation
5. Centralize string and icon constants

The architecture should be refactored to better separate concerns and improve testability in a subsequent iteration.

## EnhancedDetailViews.swift

# Code Review: EnhancedDetailViews.swift

## 1. Code Quality Issues

**🚨 Critical Issues:**

```swift
// Memory leak risk - Query properties are not filtered
@Query private var transactions: [FinancialTransaction]
@Query private var categories: [ExpenseCategory]

// This loads ALL transactions and categories, which is extremely inefficient
private var transaction: FinancialTransaction? {
    self.transactions.first(where: { $0.id == self.transactionId })
}
```

**Fix:**

```swift
@Query(filter: #Predicate<FinancialTransaction> { $0.id == transactionId })
private var transactions: [FinancialTransaction]

@Query private var categories: [ExpenseCategory] // Still problematic - see performance section
```

**🔧 Other Issues:**

- **Stringly-typed tabs**: Using strings for tab selection is error-prone
- **Inconsistent spacing**: Mix of `HStack(spacing: 12)` and `HStack(spacing: 0)`
- **Missing error handling**: No handling for when transaction is not found
- **Force unwrapping risk**: `if let transaction` pattern is good, but consider what happens when it's nil

## 2. Performance Problems

**🚨 Critical Performance Issues:**

1. **Massive Data Loading**: Loading ALL transactions and categories for a single transaction view is catastrophic for performance
2. **Inefficient Filtering**: Using `.first(where:)` on potentially thousands of records

**Fix:**

```swift
// Use filtered queries
@Query(filter: #Predicate<FinancialTransaction> { $0.id == transactionId })
private var transactions: [FinancialTransaction]

// Only load categories if actually needed
@Query(sort: xpenseCategory.name)
private var categories: [ExpenseCategory]
```

## 3. Security Vulnerabilities

**🔐 Security Concerns:**

- **No access control**: No checks if user should see this transaction
- **Direct ID access**: Exposing internal transaction IDs without validation
- **Potential data leakage**: Loading all categories might expose admin-only categories

**Recommendations:**

```swift
// Add authentication/authorization checks
@Environment(\.userSession) private var userSession

// Validate user has access to this transaction
private var canAccessTransaction: Bool {
    guard let transaction else { return false }
    return userSession.canView(transaction: transaction)
}
```

## 4. Swift Best Practices Violations

**📝 Best Practice Issues:**

1. **Violates Single Responsibility**: This view handles too much (display, edit, delete, export, analysis)
2. **Massive View Problem**: This will become an unmaintainable mega-view
3. **String literals**: Hardcoded strings for tabs should be constants
4. **Missing access control**: Properties should have explicit access levels

**Fix:**

```swift
// Extract to constants
private enum Tab: String, CaseIterable {
    case details, analysis, series, notes
}

// Use proper access control
@State private var selectedTab: Tab = .details
private let transactionId: String
```

## 5. Architectural Concerns

**🏗️ Architectural Issues:**

1. **Tight Coupling**: Direct dependency on SwiftData models in view layer
2. **No ViewModel**: Business logic mixed with UI code
3. **God Object Pattern**: This view does everything
4. **Poor Testability**: Hard to unit test due to direct SwiftData dependencies

**Recommendations:**

```swift
// Create a proper ViewModel
@Observable
class TransactionDetailViewModel {
    private let dataService: TransactionDataService
    let transactionId: String

    var transaction: FinancialTransaction?
    var isLoading = false

    init(transactionId: String, dataService: TransactionDataService) {
        self.transactionId = transactionId
        self.dataService = dataService
    }

    func loadTransaction() async {
        // Async loading with proper error handling
    }
}

// Use dependency injection
struct EnhancedTransactionDetailView: View {
    @State private var viewModel: TransactionDetailViewModel

    init(transactionId: String, dataService: TransactionDataService) {
        self.viewModel = TransactionDetailViewModel(
            transactionId: transactionId,
            dataService: dataService
        )
    }
}
```

## 6. Documentation Needs

**📚 Documentation Gaps:**

1. **No parameter documentation**: `transactionId` parameter needs explanation
2. **Missing purpose documentation**: What makes this "enhanced"?
3. **No usage examples**: How should this view be used?
4. **Undocumented assumptions**: Assumes transaction exists and user has access

**Recommended Documentation:**

```swift
/// Enhanced transaction detail view optimized for macOS screen space
/// - Provides detailed transaction information, analysis, and management tools
/// - Requires: Transaction ID must be valid and user must have access rights
/// - Note: This view is macOS-only and uses SwiftData for persistence
/// - Parameter transactionId: The unique identifier of the transaction to display
/// - Warning: Ensure proper authorization before displaying this view
struct EnhancedTransactionDetailView: View {
    // ... implementation
}
```

## 🔧 Actionable Recommendations

### Immediate Fixes (Critical):

1. **Fix Query Performance**: Use filtered predicates immediately
2. **Add Error Handling**: Handle nil transaction case
3. **Implement Access Control**: Add authorization checks

### Short-term Improvements:

1. **Extract Constants**: Replace string literals with enum cases
2. **Break Up View**: Extract tabs into separate views/modules
3. **Add Documentation**: Document parameters and usage

### Long-term Refactoring:

1. **Implement MVVM**: Separate business logic from UI
2. **Add Dependency Injection**: Make testing possible
3. **Create Data Service Layer**: Abstract SwiftData dependencies
4. **Implement Proper Error Handling**: Add user-friendly error states

### Example Refactored Structure:

```swift
struct EnhancedTransactionDetailView: View {
    @State private var viewModel: ViewModel
    @State private var selectedTab: Tab = .details

    enum Tab: String, CaseIterable {
        case details, analysis, series, notes
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .loaded(let transaction):
                buildContentView(transaction: transaction)
            case .error(let error):
                ErrorView(error: error, onRetry: viewModel.loadTransaction)
            case .unauthorized:
                AccessDeniedView()
            }
        }
        .task { await viewModel.loadTransaction() }
    }

    // Extract each tab to its own method or view
    @ViewBuilder
    private func buildContentView(transaction: FinancialTransaction) -> some View {
        // ... implementation
    }
}
```

**Priority: High** - The performance issues alone could make the app unusable with large datasets. The architectural issues will cause maintenance problems as the codebase grows.
