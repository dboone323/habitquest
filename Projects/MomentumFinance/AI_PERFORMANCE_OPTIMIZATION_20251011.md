# Performance Optimization Report for MomentumFinance
Generated: Sat Oct 11 15:27:58 CDT 2025


## AccountModelTests.swift
Looking at this Swift test code, I'll analyze it for performance optimizations:

## Performance Analysis

### 1. Algorithm Complexity Issues
**No significant algorithmic issues** - The tests are simple assertions with O(1) operations. However, the test structure could be optimized.

### 2. Memory Usage Problems
**High object allocation in loops** - Creating multiple `FinancialTransaction` objects and `Date()` instances repeatedly.

### 3. Unnecessary Computations
**Redundant Date creation** - Creating `Date()` objects when the actual date value isn't being tested.

### 4. Collection Operation Optimizations
**Sequential processing** - The transaction processing loop could be optimized.

### 5. Threading Opportunities
**Test parallelization** - Tests could run in parallel for better performance.

### 6. Caching Possibilities
**Reusable test data** - Common test objects could be cached.

## Optimization Suggestions

### 1. **Cache Reusable Test Data**
```swift
// Create shared test data
private let sharedDate = Date() // Cache Date instance
private let sharedCheckingAccount = FinancialAccount(
    name: "Main",
    balance: 100.0,
    iconName: "wallet",
    accountType: .checking
)

func runAccountModelTests() {
    runTest("testAccountCreation") {
        let account = FinancialAccount(
            name: "Checking",
            balance: 1000.0,
            iconName: "bank",
            accountType: .checking
        )
        
        assert(account.name == "Checking")
        assert(account.balance == 1000.0)
        assert(account.accountType == .checking)
    }
    
    // ... other tests
}
```

### 2. **Optimize Transaction Creation**
```swift
func testAccountBalanceCalculations() {
    var account = FinancialAccount(
        name: "Test Account",
        balance: 1000.0,
        iconName: "test",
        accountType: .checking
    )
    
    // Pre-create transactions to reduce allocation overhead
    let baseDate = Date() // Single Date creation
    let transactions = [
        FinancialTransaction(title: "Income", amount: 500.0, date: baseDate, transactionType: .income),
        FinancialTransaction(title: "Expense 1", amount: 100.0, date: baseDate, transactionType: .expense),
        FinancialTransaction(title: "Expense 2", amount: 50.0, date: baseDate, transactionType: .expense)
    ]
    
    // Use forEach instead of for-in for slight performance gain
    transactions.forEach { transaction in
        account.updateBalance(for: transaction)
    }
    
    assert(account.balance == 1350.0)
}
```

### 3. **Batch Transaction Processing**
```swift
// If FinancialAccount supports batch processing, add this method:
extension FinancialAccount {
    mutating func updateBalance(for transactions: [FinancialTransaction]) {
        // Batch processing reduces method call overhead
        for transaction in transactions {
            updateBalance(for: transaction)
        }
    }
}

// Then use it in tests:
func testAccountBalanceCalculations() {
    var account = FinancialAccount(
        name: "Test Account",
        balance: 1000.0,
        iconName: "test",
        accountType: .checking
    )
    
    let transactions = [
        FinancialTransaction(title: "Income", amount: 500.0, date: Date(), transactionType: .income),
        FinancialTransaction(title: "Expense 1", amount: 100.0, date: Date(), transactionType: .expense),
        FinancialTransaction(title: "Expense 2", amount: 50.0, date: Date(), transactionType: .expense)
    ]
    
    // Single method call instead of multiple
    account.updateBalance(for: transactions)
    assert(account.balance == 1350.0)
}
```

### 4. **Parallel Test Execution**
```swift
import Dispatch

func runAccountModelTestsInParallel() {
    let testQueue = DispatchQueue(label: "testQueue", attributes: .concurrent)
    let group = DispatchGroup()
    
    let tests = [
        ("testAccountCreation", testAccountCreation),
        ("testAccountPersistence", testAccountPersistence),
        // ... other tests
    ]
    
    for (name, test) in tests {
        group.enter()
        testQueue.async {
            runTest(name) {
                test()
            }
            group.leave()
        }
    }
    
    group.wait() // Wait for all tests to complete
}

// Individual test functions for better organization
private func testAccountCreation() {
    let account = FinancialAccount(
        name: "Checking",
        balance: 1000.0,
        iconName: "bank",
        accountType: .checking
    )
    
    assert(account.name == "Checking")
    assert(account.balance == 1000.0)
    assert(account.accountType == .checking)
}
```

### 5. **Reusable Test Object Factory**
```swift
struct TestAccountFactory {
    static let baseDate = Date()
    
    static func createCheckingAccount(balance: Double = 100.0) -> FinancialAccount {
        return FinancialAccount(
            name: "Main",
            balance: balance,
            iconName: "wallet",
            accountType: .checking
        )
    }
    
    static func createTransaction(title: String, amount: Double, type: TransactionType) -> FinancialTransaction {
        return FinancialTransaction(
            title: title,
            amount: amount,
            date: baseDate,
            transactionType: type
        )
    }
}

// Usage in tests:
func testUpdateBalanceForIncomeTransaction() {
    var account = TestAccountFactory.createCheckingAccount()
    let transaction = TestAccountFactory.createTransaction(title: "Paycheck", amount: 500.0, type: .income)
    
    account.updateBalance(for: transaction)
    assert(account.balance == 600.0)
}
```

### 6. **Performance Measurement Wrapper**
```swift
func runTestWithTiming(_ name: String, test: () -> Void) {
    let startTime = CFAbsoluteTimeGetCurrent()
    test()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("\(name) completed in \(timeElapsed * 1000)ms")
}

// Usage:
runTestWithTiming("testAccountBalanceCalculations") {
    // test implementation
}
```

## Summary of Key Optimizations:

1. **Reduced object allocation** by caching `Date()` instances
2. **Improved test organization** with factory patterns
3. **Enabled parallel execution** potential
4. **Minimized redundant computations** 
5. **Better memory locality** through batch processing
6. **Enhanced maintainability** with reusable components

These optimizations would provide measurable performance improvements, especially when running large test suites or when tests are executed frequently during development.

## Dependencies.swift
Here's a detailed performance analysis of the provided Swift code, followed by **specific optimization suggestions** with code examples.

---

## 🔍 **1. Algorithm Complexity Issues**

### ✅ **No significant algorithmic complexity issues**
- The `Logger` and `Dependencies` are simple DI container and logging utility, so no complex algorithms are used.
- The `log` method uses `async` dispatch, which is appropriate.

---

## 🧠 **2. Memory Usage Problems**

### 🔴 **Problem: Logger retains output handler strongly**
- The `outputHandler` closure is stored in the `Logger` class, and if it captures `self` or other large objects, it can cause retain cycles or memory bloat.

### ✅ **Fix: Use weak references or escape-only capture**
If `outputHandler` is set to a closure that captures `self`, it could lead to retain cycles.

```swift
// Instead of:
self.setOutputHandler { message in
    self.handleLog(message) // retain cycle if self is not weak
}

// Use:
self.setOutputHandler { [weak self] message in
    self?.handleLog(message)
}
```

---

## ⚙️ **3. Unnecessary Computations**

### 🔴 **Problem: `formattedMessage` is called on every log, even if log level is filtered**
- Currently, the message is formatted before being passed to the output handler, even if the output handler is a no-op or filters out certain log levels.

### ✅ **Fix: Defer formatting until needed**
Introduce a log level filter in `Logger` and skip formatting if below threshold.

```swift
public final class Logger {
    private var minimumLogLevel: LogLevel = .info

    public func setMinimumLogLevel(_ level: LogLevel) {
        self.queue.sync {
            self.minimumLogLevel = level
        }
    }

    private func shouldLog(level: LogLevel) -> Bool {
        return level.priority >= self.minimumLogLevel.priority
    }

    public func log(_ message: String, level: LogLevel = .info) {
        self.queue.async {
            guard self.shouldLog(level: level) else { return }
            self.outputHandler(self.formattedMessage(message, level: level))
        }
    }
}

extension LogLevel {
    var priority: Int {
        switch self {
        case .debug: 0
        case .info: 1
        case .warning: 2
        case .error: 3
        }
    }
}
```

---

## 🧹 **4. Collection Operation Optimizations**

### ✅ **No collection operations used**
- No arrays, dictionaries, or sets are used in the current implementation, so no optimizations here.

---

## 🧵 **5. Threading Opportunities**

### 🔴 **Problem: `queue.sync` used in `setOutputHandler` and `logSync`**
- Using `sync` can block the calling thread unnecessarily, especially on the main thread.

### ✅ **Fix: Prefer async where possible**
- Use `async` for `log` and avoid `sync` unless absolutely necessary.

```swift
public func logSync(_ message: String, level: LogLevel = .info) {
    // Only use sync if the caller requires immediate execution
    // Otherwise, prefer async
    self.queue.sync {
        self.outputHandler(self.formattedMessage(message, level: level))
    }
}
```

If `logSync` is used rarely, consider removing it or deprecating it.

---

## 🧊 **6. Caching Possibilities**

### 🔴 **Problem: `Date()` is called every time a log is made**
- `Date()` is relatively cheap, but calling `ISO8601DateFormatter.string(from:)` every time can be optimized.

### ✅ **Fix: Cache the timestamp if high-frequency logging is expected**
Use a cached timestamp with a timer or reuse the formatter.

However, `ISO8601DateFormatter` is already reused via a static lazy var, which is good.

### ✅ **Further Optimization: Avoid redundant `Date()` call if not needed**
If logs are batched or grouped, consider caching the timestamp for a short duration.

```swift
private static let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()
```

✅ Already optimized.

---

## 🛠️ **Other Minor Optimizations**

### 🧼 **Remove unnecessary `@inlinable`**
- `@inlinable` should only be used when the function is part of a generic or performance-critical public API.
- For simple wrappers like `error`, `warning`, etc., it's unnecessary.

```swift
// Remove @inlinable unless proven beneficial
public func error(_ message: String) {
    self.log(message, level: .error)
}
```

---

## ✅ **Summary of Optimizations**

| Area | Issue | Fix |
|------|-------|-----|
| Memory | Potential retain cycles in `outputHandler` | Use `[weak self]` in closures |
| CPU | Unnecessary formatting for filtered logs | Add log level filtering |
| Threading | Use of `sync` can block threads | Prefer `async` unless sync is required |
| Caching | `Date()` and formatting are repeated | Already optimized with static formatter |
| Inlining | Overuse of `@inlinable` | Remove unless needed |
| API | `logSync` can block thread | Consider deprecating or limiting use |

---

## 🧪 **Final Optimized Snippet (Logger)**

```swift
public final class Logger {
    public static let shared = Logger()

    private static let defaultOutputHandler: @Sendable (String) -> Void = { message in
        print(message)
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private let queue = DispatchQueue(label: "com.quantumworkspace.logger", qos: .utility)
    private var outputHandler: @Sendable (String) -> Void = Logger.defaultOutputHandler
    private var minimumLogLevel: LogLevel = .info

    private init() {}

    public func setMinimumLogLevel(_ level: LogLevel) {
        self.queue.sync {
            self.minimumLogLevel = level
        }
    }

    private func shouldLog(level: LogLevel) -> Bool {
        level.priority >= self.minimumLogLevel.priority
    }

    public func log(_ message: String, level: LogLevel = .info) {
        self.queue.async {
            guard self.shouldLog(level: level) else { return }
            self.outputHandler(self.formattedMessage(message, level: level))
        }
    }

    public func logSync(_ message: String, level: LogLevel = .info) {
        self.queue.sync {
            guard self.shouldLog(level: level) else { return }
            self.outputHandler(self.formattedMessage(message, level: level))
        }
    }

    public func error(_ message: String) {
        self.log(message, level: .error)
    }

    public func warning(_ message: String) {
        self.log(message, level: .warning)
    }

    public func info(_ message: String) {
        self.log(message, level: .info)
    }

    public func setOutputHandler(_ handler: @escaping @Sendable (String) -> Void) {
        self.queue.sync {
            self.outputHandler = handler
        }
    }

    public func resetOutputHandler() {
        self.setOutputHandler(Logger.defaultOutputHandler)
    }

    private func formattedMessage(_ message: String, level: LogLevel) -> String {
        let timestamp = Self.isoFormatter.string(from: Date())
        return "[\(timestamp)] [\(level.uppercasedValue)] \(message)"
    }
}

public enum LogLevel: String {
    case debug, info, warning, error

    public var uppercasedValue: String {
        switch self {
        case .debug: "DEBUG"
        case .info: "INFO"
        case .warning: "WARNING"
        case .error: "ERROR"
        }
    }

    var priority: Int {
        switch self {
        case .debug: 0
        case .info: 1
        case .warning: 2
        case .error: 3
        }
    }
}
```

Let me know if you'd like to apply similar analysis to other files or modules!

## FinancialTransactionTests.swift
Let's analyze the Swift test code for **performance optimizations** and identify areas for improvement.

---

## 🔍 **Code Overview**

This file contains unit tests for a `FinancialTransaction` model. It covers:

- Object creation
- Formatted amount logic
- Date formatting
- Persistence (basic assertions)
- Filtering by transaction type

While it's primarily test code, performance considerations still apply, especially if these tests are run repeatedly or with large datasets.

---

## 🚨 Identified Issues and Optimizations

---

### 1. **Algorithm Complexity Issues**

#### ⚠️ Issue:
In `testTransactionTypeFiltering`, the same array is filtered twice:

```swift
let incomeTransactions = [incomeTransaction, expenseTransaction1, expenseTransaction2].filter {
    $0.transactionType == .income
}
let expenseTransactions = [incomeTransaction, expenseTransaction1, expenseTransaction2].filter {
    $0.transactionType == .expense
}
```

This results in **O(n)** for each filter — total **O(2n)**.

#### ✅ Optimization:
Filter once and split the results:

```swift
let transactions = [incomeTransaction, expenseTransaction1, expenseTransaction2]
let grouped = Dictionary(grouping: transactions, by: \.transactionType)

let incomeTransactions = grouped[.income] ?? []
let expenseTransactions = grouped[.expense] ?? []
```

- **Complexity reduced** from **O(2n)** to **O(n)**.
- Also avoids duplicate iteration.

---

### 2. **Memory Usage Problems**

#### ⚠️ Issue:
New `FinancialTransaction` instances are created for every test. While not a big issue in tests, if reused, they could be cached or reused in performance-sensitive code.

#### ✅ Optimization:
If this were part of a larger app (not just tests), consider:

- Reusing `Date()` objects if time precision isn't critical.
- Using structs (which are value types) efficiently.

In test context, this is acceptable.

---

### 3. **Unnecessary Computations**

#### ⚠️ Issue:
In `testTransactionFormattedAmountIncome` and `testTransactionFormattedAmountExpense`, `formattedAmount` is computed twice (once for prefix check, once for content check).

If `formattedAmount` is computed from scratch each time, this is redundant.

#### ✅ Optimization:
Cache the formatted value:

```swift
let formatted = transaction.formattedAmount
assert(formatted.hasPrefix("+"))
assert(formatted.contains("$2000.00"))
```

This avoids recomputation (assuming `formattedAmount` is a computed property).

---

### 4. **Collection Operation Optimizations**

#### ⚠️ Issue:
In `testTransactionTypeFiltering`, `expenseTransactions.map(\.amount).reduce(0, +)` is used to sum amounts.

This is fine but can be optimized slightly.

#### ✅ Optimization:
Use `reduce` directly without intermediate `map`:

```swift
let totalExpense = expenseTransactions.reduce(0) { $0 + $1.amount }
assert(totalExpense == 950.0)
```

- Avoids creating an intermediate array.
- Slightly more efficient in terms of memory and speed.

---

### 5. **Threading Opportunities**

#### ⚠️ Issue:
There are no threading issues in the test code itself.

#### ✅ Optimization:
If tests are part of a large suite and performance matters, consider:

- Running tests in **parallel** (XCTest supports this).
- Offloading heavy operations to background queues (if applicable in the app logic).

In test code, this is usually not needed unless simulating async behavior.

---

### 6. **Caching Possibilities**

#### ⚠️ Issue:
If `formattedAmount` or `formattedDate` are computed properties, and used multiple times, they should be cached if expensive.

#### ✅ Optimization:
If `formattedAmount` involves currency formatting or locale-sensitive operations, cache it:

```swift
private var _formattedAmount: String?
var formattedAmount: String {
    if let cached = _formattedAmount {
        return cached
    }
    let value = computeFormattedAmount() // expensive operation
    _formattedAmount = value
    return value
}
```

This avoids recomputation, especially useful if accessed multiple times.

---

## ✅ Final Optimized Snippets

### Optimized `testTransactionTypeFiltering`

```swift
runTest("testTransactionTypeFiltering") {
    let incomeTransaction = FinancialTransaction(
        title: "Paycheck",
        amount: 2000.0,
        date: Date(),
        transactionType: .income
    )
    let expenseTransaction1 = FinancialTransaction(
        title: "Rent",
        amount: 800.0,
        date: Date(),
        transactionType: .expense
    )
    let expenseTransaction2 = FinancialTransaction(
        title: "Utilities",
        amount: 150.0,
        date: Date(),
        transactionType: .expense
    )

    let transactions = [incomeTransaction, expenseTransaction1, expenseTransaction2]
    let grouped = Dictionary(grouping: transactions, by: \.transactionType)

    let incomeTransactions = grouped[.income] ?? []
    let expenseTransactions = grouped[.expense] ?? []

    assert(incomeTransactions.count == 1)
    assert(expenseTransactions.count == 2)

    let totalExpense = expenseTransactions.reduce(0) { $0 + $1.amount }
    assert(totalExpense == 950.0)
}
```

---

## ✅ Summary of Key Optimizations

| Area | Optimization | Benefit |
|------|--------------|---------|
| Filtering | Single-pass grouping | O(n) instead of O(2n) |
| Redundant Computation | Cache formatted values | Avoids recomputation |
| Collection Ops | Use `reduce` directly | Avoids intermediate array |
| Memory | Avoid unnecessary object creation | Lower memory footprint |
| Caching | Cache computed properties | Performance boost if reused |
| Threading | Parallel test execution | Faster test runs (optional) |

Let me know if you'd like a version of `FinancialTransaction` with caching or optimized computed properties!

## IntegrationTests.swift
# Performance Analysis of IntegrationTests.swift

## 1. Algorithm Complexity Issues

### Issue: Repeated Calculations
The `calculatedBalance` property and `totalExpenses` are computed every time they're accessed, which can be inefficient if accessed multiple times.

**Current Pattern:**
```swift
// Each access recalculates the entire balance
let balance1 = account.calculatedBalance
let balance2 = account.calculatedBalance  // Recalculated again
```

**Optimization - Caching with Lazy Evaluation:**
```swift
class FinancialAccount {
    private var _cachedBalance: Double?
    private var balanceDirty = true
    
    var calculatedBalance: Double {
        if balanceDirty || _cachedBalance == nil {
            _cachedBalance = calculateBalance()
            balanceDirty = false
        }
        return _cachedBalance!
    }
    
    private func calculateBalance() -> Double {
        return balance + transactions.reduce(0) { sum, transaction in
            sum + (transaction.transactionType == .income ? transaction.amount : -transaction.amount)
        }
    }
    
    // Mark as dirty when transactions change
    func addTransaction(_ transaction: FinancialTransaction) {
        transactions.append(transaction)
        balanceDirty = true
    }
}
```

## 2. Memory Usage Problems

### Issue: Unnecessary Object Creation
Objects are created for each test but not reused, leading to increased memory allocation.

**Optimization - Object Reuse:**
```swift
// Create shared test data
private let testDate = Date(timeIntervalSince1970: 1640995200)

// Reusable transaction factory
private func createTransaction(title: String, amount: Double, type: TransactionType) -> FinancialTransaction {
    return FinancialTransaction(
        title: title,
        amount: amount,
        date: testDate,
        transactionType: type
    )
}
```

## 3. Unnecessary Computations

### Issue: Redundant Assertions
Multiple assertions that could be combined and redundant calculations.

**Current Code:**
```swift
assert(account.calculatedBalance == 1000.0 + 3000.0 - 1200.0 - 300.0)
assert(account.calculatedBalance == 2500.0)  // This is the same value as above
```

**Optimization:**
```swift
runTest("testAccountTransactionIntegration") {
    let transaction1 = createTransaction(title: "Salary", amount: 3000.0, type: .income)
    let transaction2 = createTransaction(title: "Rent", amount: 1200.0, type: .expense)
    let transaction3 = createTransaction(title: "Groceries", amount: 300.0, type: .expense)

    let account = FinancialAccount(
        name: "Integration Test Account",
        type: .checking,
        balance: 1000.0,
        transactions: [transaction1, transaction2, transaction3]
    )

    // Combine assertions and avoid redundant calculations
    let expectedBalance = 2500.0
    assert(account.transactions.count == 3)
    assert(account.calculatedBalance == expectedBalance, 
           "Expected balance \(expectedBalance), got \(account.calculatedBalance)")
}
```

## 4. Collection Operation Optimizations

### Issue: Inefficient Collection Operations
The `map` followed by `reduce` can be optimized.

**Current Code:**
```swift
let totalExpenses = categories.map(\.totalExpenses).reduce(0, +)
```

**Optimization - Direct Reduction:**
```swift
// More efficient - single pass
let totalExpenses = categories.reduce(0) { sum, category in
    sum + category.totalExpenses
}

// Or even better with lazy evaluation to avoid intermediate array
let totalExpenses = categories.lazy.map(\.totalExpenses).reduce(0, +)
```

## 5. Threading Opportunities

### Issue: Sequential Test Execution
Tests run sequentially, but integration tests could potentially run in parallel.

**Optimization - Concurrent Test Execution:**
```swift
import Dispatch

func runIntegrationTestsConcurrently() {
    let testGroup = DispatchGroup()
    let testQueue = DispatchQueue(label: "integration-tests", qos: .utility, attributes: .concurrent)
    
    let tests = [
        ("testAccountTransactionIntegration", testAccountTransactionIntegration),
        ("testCategoryTransactionIntegration", testCategoryTransactionIntegration),
        ("testMultiAccountBalanceCalculation", testMultiAccountBalanceCalculation),
        ("testTransactionCategoryGrouping", testTransactionCategoryGrouping)
    ]
    
    for (name, test) in tests {
        testGroup.enter()
        testQueue.async {
            defer { testGroup.leave() }
            runTest(name, test: test)
        }
    }
    
    testGroup.wait()
}

// Individual test functions for better organization
private func testAccountTransactionIntegration() {
    // Implementation here
}
```

## 6. Caching Possibilities

### Issue: Repeated Calculations in Category Totals
Category totals are recalculated each time `totalExpenses` is accessed.

**Optimization - Cached Category Totals:**
```swift
class TransactionCategory {
    let name: String
    private(set) var transactions: [FinancialTransaction]
    private var _cachedTotalExpenses: Double?
    private var totalExpensesDirty = true
    
    var totalExpenses: Double {
        if totalExpensesDirty || _cachedTotalExpenses == nil {
            _cachedTotalExpenses = transactions.reduce(0) { sum, transaction in
                transaction.transactionType == .expense ? sum + transaction.amount : sum
            }
            totalExpensesDirty = false
        }
        return _cachedTotalExpenses!
    }
    
    init(name: String, transactions: [FinancialTransaction] = []) {
        self.name = name
        self.transactions = transactions
        self.totalExpensesDirty = !transactions.isEmpty
    }
    
    func addTransaction(_ transaction: FinancialTransaction) {
        transactions.append(transaction)
        totalExpensesDirty = true
    }
    
    func removeTransaction(_ transaction: FinancialTransaction) {
        transactions.removeAll { $0 === transaction }
        totalExpensesDirty = true
    }
}
```

## Complete Optimized Version

```swift
import Foundation
import Dispatch

// MARK: - Optimized Integration Tests
class OptimizedIntegrationTests {
    // Shared test date to avoid repeated creation
    private static let testDate = Date(timeIntervalSince1970: 1640995200)
    
    // Reusable transaction factory
    private static func createTransaction(
        title: String, 
        amount: Double, 
        type: TransactionType
    ) -> FinancialTransaction {
        return FinancialTransaction(
            title: title,
            amount: amount,
            date: testDate,
            transactionType: type
        )
    }
    
    static func runIntegrationTestsConcurrently() {
        let testGroup = DispatchGroup()
        let testQueue = DispatchQueue(label: "integration-tests", qos: .utility, attributes: .concurrent)
        
        let tests = [
            ("testAccountTransactionIntegration", testAccountTransactionIntegration),
            ("testCategoryTransactionIntegration", testCategoryTransactionIntegration),
            ("testMultiAccountBalanceCalculation", testMultiAccountBalanceCalculation),
            ("testTransactionCategoryGrouping", testTransactionCategoryGrouping)
        ]
        
        for (name, test) in tests {
            testGroup.enter()
            testQueue.async {
                defer { testGroup.leave() }
                runTest(name, test: test)
            }
        }
        
        testGroup.wait()
    }
    
    private static func testAccountTransactionIntegration() {
        let transaction1 = createTransaction(title: "Salary", amount: 3000.0, type: .income)
        let transaction2 = createTransaction(title: "Rent", amount: 1200.0, type: .expense)
        let transaction3 = createTransaction(title: "Groceries", amount: 300.0, type: .expense)

        let account = FinancialAccount(
            name: "Integration Test Account",
            type: .checking,
            balance: 1000.0,
            transactions: [transaction1, transaction2, transaction3]
        )

        assert(account.transactions.count == 3)
        assert(account.calculatedBalance == 2500.0, 
               "Expected balance 2500.0, got \(account.calculatedBalance)")
    }
    
    private static func testCategoryTransactionIntegration() {
        let transaction1 = createTransaction(title: "Restaurant", amount: 50.0, type: .expense)
        let transaction2 = createTransaction(title: "Coffee Shop", amount: 25.0, type: .expense)

        let category = TransactionCategory(
            name: "Food & Dining",
            transactions: [transaction1, transaction2]
        )

        assert(category.transactions.count == 2)
        assert(category.totalExpenses == 75.0)
    }
    
    private static func testMultiAccountBalanceCalculation() {
        let checkingAccount = FinancialAccount(
            name: "Checking",
            type: .checking,
            balance: 500.0,
            transactions: [
                createTransaction(title: "Deposit", amount: 1000.0, type: .income),
                createTransaction(title: "ATM", amount: 200.0, type: .expense)
            ]
        )

        let savingsAccount = FinancialAccount(
            name: "Savings",
            type: .savings,
            balance: 2000.0,
            transactions: [
                createTransaction(title: "Interest", amount: 50.0, type: .income)
            ]
        )

        let totalBalance = checkingAccount.calculatedBalance + savingsAccount.calculatedBalance
        assert(totalBalance == 3350.0)
    }
    
    private static func testTransactionCategoryGrouping() {
        let foodCategory = TransactionCategory(
            name: "Food",
            transactions: [
                createTransaction(title: "Groceries", amount: 100.0, type: .expense),
                createTransaction(title: "Restaurant", amount: 50.0, type: .expense)
            ]
        )

        let transportCategory = TransactionCategory(
            name: "Transportation",
            transactions: [
                createTransaction(title: "Gas", amount: 60.0, type: .expense),
                createTransaction(title: "Bus Pass", amount: 40.0, type: .expense)
            ]
        )

        let categories = [foodCategory, transportCategory]
        
        // Optimized calculation - single pass
        let totalExpenses = categories.reduce(0) { sum, category in
            sum + category.totalExpenses
        }

        assert(totalExpenses == 250.0)
        assert(foodCategory.totalExpenses == 150.0)
        assert(transportCategory.totalExpenses == 100.0)
    }
}
```

## Summary of Key Optimizations

1. **Caching**: Implemented lazy evaluation with dirty flags for expensive calculations
2. **Memory Efficiency**: Reused objects and avoided redundant allocations
3. **Collection Operations**: Used direct reduction instead of map+reduce
4. **Concurrency**: Added option for parallel test execution
5. **Code Organization**: Split into smaller, more maintainable functions
6. **Reduced Redundancy**: Eliminated duplicate calculations and assertions

These optimizations will significantly improve performance, especially when running large test suites or when the underlying calculations become more complex.

## MissingTypes.swift
Looking at this Swift code, I can identify several performance optimization opportunities:

## 1. Algorithm Complexity Issues

**Issue**: The `displayName` and `icon` computed properties use switch statements that are O(n) in the worst case.

**Optimization**: Use a dictionary-based approach for O(1) lookup:

```swift
public enum InsightType: Sendable, Hashable {
    case spendingPattern, anomaly, budgetAlert, forecast, optimization, budgetRecommendation,
         positiveSpendingTrend

    private static let displayNameMap: [InsightType: String] = [
        .spendingPattern: "Spending Pattern",
        .anomaly: "Anomaly",
        .budgetAlert: "Budget Alert",
        .forecast: "Forecast",
        .optimization: "Optimization",
        .budgetRecommendation: "Budget Recommendation",
        .positiveSpendingTrend: "Positive Spending Trend"
    ]

    private static let iconMap: [InsightType: String] = [
        .spendingPattern: "chart.line.uptrend.xyaxis",
        .anomaly: "exclamationmark.triangle",
        .budgetAlert: "bell",
        .forecast: "chart.xyaxis.line",
        .optimization: "arrow.up.right.circle",
        .budgetRecommendation: "lightbulb",
        .positiveSpendingTrend: "arrow.down.circle"
    ]

    public var displayName: String {
        Self.displayNameMap[self] ?? "Unknown"
    }

    public var icon: String {
        Self.iconMap[self] ?? "questionmark"
    }
}
```

## 2. Memory Usage Problems

**Issue**: The temporary `ModelContext` struct creates unnecessary overhead when SwiftData is not available.

**Optimization**: Use a more lightweight approach or conditional compilation:

```swift
#if !canImport(SwiftData)
@frozen
public struct ModelContext: Sendable {
    @inlinable
    public init() {}
}
#endif
```

## 3. Unnecessary Computations

**Issue**: The static dictionaries are recreated each time a property is accessed.

**Optimization**: The dictionary-based approach above already addresses this by creating the mappings once.

## 4. Collection Operation Optimizations

**Issue**: No collection operations present in this specific code, but the enum could benefit from `CaseIterable`:

```swift
public enum InsightType: Sendable, Hashable, CaseIterable {
    // ... cases remain the same

    public static var allDisplayNames: [String] {
        Self.allCases.map { $0.displayName }
    }
}
```

## 5. Threading Opportunities

**Issue**: The static dictionaries are not thread-safe for initial access.

**Optimization**: Use `@Sendable` closures or lazy initialization:

```swift
private static let displayNameMap: [InsightType: String] = {
    let map: [InsightType: String] = [
        .spendingPattern: "Spending Pattern",
        .anomaly: "Anomaly",
        .budgetAlert: "Budget Alert",
        .forecast: "Forecast",
        .optimization: "Optimization",
        .budgetRecommendation: "Budget Recommendation",
        .positiveSpendingTrend: "Positive Spending Trend"
    ]
    return map
}()
```

## 6. Caching Possibilities

**Issue**: No explicit caching, but the dictionary approach provides implicit caching.

**Additional Optimization**: Pre-compute frequently used combinations:

```swift
public enum InsightType: Sendable, Hashable, CaseIterable {
    // ... cases
    
    private static let cachedInsightData: [InsightType: (displayName: String, icon: String)] = {
        let data: [InsightType: (String, String)] = [
            .spendingPattern: ("Spending Pattern", "chart.line.uptrend.xyaxis"),
            .anomaly: ("Anomaly", "exclamationmark.triangle"),
            .budgetAlert: ("Budget Alert", "bell"),
            .forecast: ("Forecast", "chart.xyaxis.line"),
            .optimization: ("Optimization", "arrow.up.right.circle"),
            .budgetRecommendation: ("Budget Recommendation", "lightbulb"),
            .positiveSpendingTrend: ("Positive Spending Trend", "arrow.down.circle")
        ]
        return data
    }()
    
    public var displayName: String {
        Self.cachedInsightData[self]?.displayName ?? "Unknown"
    }
    
    public var icon: String {
        Self.cachedInsightData[self]?.icon ?? "questionmark"
    }
    
    public var displayNameAndIcon: (displayName: String, icon: String) {
        Self.cachedInsightData[self] ?? (displayName: "Unknown", icon: "questionmark")
    }
}
```

## Additional Recommendations

1. **Add `@frozen` attribute** to the enum for better performance in release builds:
```swift
@frozen
public enum InsightType: Sendable, Hashable {
    // ...
}
```

2. **Use `@inlinable`** for simple property accessors:
```swift
@inlinable
public var displayName: String {
    Self.cachedInsightData[self]?.displayName ?? "Unknown"
}
```

3. **Consider removing the temporary definition** once the proper import is resolved to avoid duplicate code and potential inconsistencies.

The main performance gains come from:
- **O(1) lookup time** instead of O(n) switch statements
- **Reduced memory allocations** through static initialization
- **Better cache locality** with pre-computed values
- **Thread-safe initialization** of static data structures
