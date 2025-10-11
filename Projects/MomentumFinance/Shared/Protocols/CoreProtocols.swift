// MARK: - Account Protocols

/// Protocol for objects that can display account details
public protocol AccountDetailDisplayable {
    var accountName: String { get }
    var balance: Decimal { get }
    var accountType: String { get }
    var formattedBalance: String { get }
    var isActive: Bool { get }
}

/// Protocol for routing account-related navigation
public protocol AccountDetailRoutable {
    func navigateToExport()
    func navigateToTransactionDetail(_ transaction: Any)
    func navigateToEditAccount()
    func navigateToAccountSettings()
}

// MARK: - Transaction Protocols

/// Protocol for objects that can display transaction information
public protocol TransactionDisplayable {
    var transactionId: String { get }
    var amount: Decimal { get }
    var description: String { get }
    var date: Date { get }
    var category: Category? { get }
    var formattedAmount: String { get }
    var formattedDate: String { get }
}

/// Protocol for transaction filtering and searching
public protocol TransactionFilterable {
    func matches(filter: TransactionFilter) -> Bool
    func contains(searchText: String) -> Bool
}

// MARK: - Budget Protocols

/// Protocol for objects that can display budget information
public protocol BudgetDisplayable {
    var budgetName: String { get }
    var allocatedAmount: Decimal { get }
    var spentAmount: Decimal { get }
    var remainingAmount: Decimal { get }
    var progressPercentage: Double { get }
    var isOverBudget: Bool { get }
}

/// Protocol for budget management operations
public protocol BudgetManageable {
    func updateBudget(amount: Decimal) async throws
    func addExpense(amount: Decimal, category: Category) async throws
    func getBudgetStatus() -> BudgetStatus
}

// MARK: - Service Protocols

/// Protocol for account data management
public protocol AccountServiceProtocol {
    func fetchAccounts() async throws -> [FinancialAccount]
    func fetchAccount(id: String) async throws -> FinancialAccount
    func createAccount(_ account: FinancialAccount) async throws -> FinancialAccount
    func updateAccount(_ account: FinancialAccount) async throws -> FinancialAccount
    func deleteAccount(id: String) async throws
}

/// Protocol for transaction data management
public protocol TransactionServiceProtocol {
    func fetchTransactions(for accountId: String) async throws -> [FinancialTransaction]
    func fetchTransaction(id: String) async throws -> FinancialTransaction
    func createTransaction(_ transaction: FinancialTransaction) async throws -> FinancialTransaction
    func updateTransaction(_ transaction: FinancialTransaction) async throws -> FinancialTransaction
    func deleteTransaction(id: String) async throws
}

/// Protocol for budget data management
public protocol BudgetServiceProtocol {
    func fetchBudgets() async throws -> [Budget]
    func fetchBudget(id: String) async throws -> Budget
    func createBudget(_ budget: Budget) async throws -> Budget
    func updateBudget(_ budget: Budget) async throws -> Budget
    func deleteBudget(id: String) async throws
}

// MARK: - View Model Protocols

/// Base protocol for all view models
public protocol ViewModelProtocol: ObservableObject {
    associatedtype State
    associatedtype Action

    var state: State { get set }
    var isLoading: Bool { get set }

    func handle(_ action: Action)
}

/// Protocol for view models that can be refreshed
public protocol RefreshableViewModel {
    func refresh() async
}

/// Protocol for view models that support search
public protocol SearchableViewModel {
    var searchText: String { get set }
    func performSearch()
}

// MARK: - Coordinator Protocols

/// Protocol for navigation coordination
public protocol CoordinatorProtocol {
    func navigate(to destination: NavigationDestination)
    func navigateBack()
    func present(_ view: AnyView)
    func dismiss()
}

// MARK: - Data Export Protocols

/// Protocol for objects that can be exported
public protocol Exportable {
    func exportData() async throws -> Data
    func exportToFile(url: URL) async throws
}

/// Protocol for export formatters
public protocol ExportFormatter {
    func format<T: Encodable>(_ data: T) throws -> Data
    func fileExtension() -> String
    func mimeType() -> String
}
