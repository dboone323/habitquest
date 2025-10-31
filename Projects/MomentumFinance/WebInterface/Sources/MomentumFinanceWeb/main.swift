import JavaScriptKit
import SwiftWebAPI

// MARK: - Data Models

struct Transaction: Codable {
    let id: String
    let amount: Double
    let description: String
    let category: String
    let date: String
    let type: TransactionType

    enum TransactionType: String, Codable {
        case income, expense
    }
}

struct Budget: Codable {
    let category: String
    let limit: Double
    let spent: Double
}

// MARK: - Finance Dashboard Web App

@MainActor
class MomentumFinanceWeb {
    private let document = JSObject.global.document
    private let console = JSObject.global.console
    private var transactions: [Transaction] = []
    private var budgets: [Budget] = []

    // DOM Elements
    private var transactionList: JSObject?
    private var budgetList: JSObject?
    private var totalIncomeDisplay: JSObject?
    private var totalExpenseDisplay: JSObject?
    private var netBalanceDisplay: JSObject?
    private var canvas: JSObject?

    init() {
        console.log("MomentumFinance Web App initializing...")
        setupUI()
        loadData()
        setupEventListeners()
        updateDashboard()
    }

    private func setupUI() {
        // Create main container
        let container = document.createElement("div")
        container.className = "finance-container"

        // Header
        let header = document.createElement("header")
        header.innerHTML = """
            <h1>💰 Momentum Finance</h1>
            <p>Your Personal Finance Dashboard</p>
        """
        container.appendChild(header)

        // Dashboard Cards
        let dashboard = document.createElement("div")
        dashboard.className = "dashboard"
        dashboard.innerHTML = """
            <div class="card">
                <h3>Total Income</h3>
                <div id="total-income" class="amount positive">$0.00</div>
            </div>
            <div class="card">
                <h3>Total Expenses</h3>
                <div id="total-expenses" class="amount negative">$0.00</div>
            </div>
            <div class="card">
                <h3>Net Balance</h3>
                <div id="net-balance" class="amount">$0.00</div>
            </div>
        """
        container.appendChild(dashboard)

        // Transaction Form
        let form = document.createElement("div")
        form.className = "transaction-form"
        form.innerHTML = """
            <h2>Add Transaction</h2>
            <form id="transaction-form">
                <input type="number" id="amount" placeholder="Amount" step="0.01" required>
                <input type="text" id="description" placeholder="Description" required>
                <select id="category" required>
                    <option value="">Select Category</option>
                    <option value="Food">Food & Dining</option>
                    <option value="Transportation">Transportation</option>
                    <option value="Entertainment">Entertainment</option>
                    <option value="Utilities">Utilities</option>
                    <option value="Healthcare">Healthcare</option>
                    <option value="Income">Income</option>
                    <option value="Other">Other</option>
                </select>
                <select id="type" required>
                    <option value="expense">Expense</option>
                    <option value="income">Income</option>
                </select>
                <button type="submit">Add Transaction</button>
            </form>
        """
        container.appendChild(form)

        // Transactions List
        let transactionsSection = document.createElement("div")
        transactionsSection.className = "transactions-section"
        transactionsSection.innerHTML = """
            <h2>Recent Transactions</h2>
            <div id="transaction-list" class="transaction-list"></div>
        """
        container.appendChild(transactionsSection)

        // Budget Section
        let budgetSection = document.createElement("div")
        budgetSection.className = "budget-section"
        budgetSection.innerHTML = """
            <h2>Budget Overview</h2>
            <div id="budget-list" class="budget-list"></div>
        """
        container.appendChild(budgetSection)

        // Chart Canvas
        let chartSection = document.createElement("div")
        chartSection.className = "chart-section"
        chartSection.innerHTML = """
            <h2>Spending by Category</h2>
            <canvas id="spending-chart" width="400" height="300"></canvas>
        """
        container.appendChild(chartSection)

        // Replace body content
        let body = document.body
        body.innerHTML = ""
        body.appendChild(container)

        // Get references to key elements
        totalIncomeDisplay = document.getElementById("total-income")
        totalExpenseDisplay = document.getElementById("total-expenses")
        netBalanceDisplay = document.getElementById("net-balance")
        transactionList = document.getElementById("transaction-list")
        budgetList = document.getElementById("budget-list")
        canvas = document.getElementById("spending-chart")
    }

    private func setupEventListeners() {
        let form = document.getElementById("transaction-form")
        form?.addEventListener("submit", JSClosure { [weak self] event in
            event.preventDefault()
            self?.addTransaction()
            return .undefined
        })
    }

    private func addTransaction() {
        guard let amountInput = document.getElementById("amount"),
              let descriptionInput = document.getElementById("description"),
              let categorySelect = document.getElementById("category"),
              let typeSelect = document.getElementById("type") else {
            return
        }

        let amount = Double(amountInput.value.string ?? "0") ?? 0
        let description = descriptionInput.value.string ?? ""
        let category = categorySelect.value.string ?? ""
        let typeString = typeSelect.value.string ?? "expense"
        let type = Transaction.TransactionType(rawValue: typeString) ?? .expense

        guard amount > 0, !description.isEmpty, !category.isEmpty else {
            console.log("Invalid transaction data")
            return
        }

        let transaction = Transaction(
            id: UUID().uuidString,
            amount: amount,
            description: description,
            category: category,
            date: getCurrentDateString(),
            type: type
        )

        transactions.append(transaction)
        saveData()
        updateDashboard()
        clearForm()

        console.log("Transaction added:", transaction.description)
    }

    private func clearForm() {
        document.getElementById("amount")?.value = ""
        document.getElementById("description")?.value = ""
        document.getElementById("category")?.selectedIndex = 0
        document.getElementById("type")?.value = "expense"
    }

    private func updateDashboard() {
        let totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let netBalance = totalIncome - totalExpenses

        totalIncomeDisplay?.innerHTML = .string("$\(String(format: "%.2f", totalIncome))")
        totalExpenseDisplay?.innerHTML = .string("$\(String(format: "%.2f", totalExpenses))")
        netBalanceDisplay?.innerHTML = .string("$\(String(format: "%.2f", netBalance))")

        updateTransactionList()
        updateBudgetList()
        updateChart()
    }

    private func updateTransactionList() {
        guard let transactionList = transactionList else { return }

        let recentTransactions = transactions.suffix(10).reversed()

        var html = ""
        for transaction in recentTransactions {
            let amountClass = transaction.type == .income ? "positive" : "negative"
            let sign = transaction.type == .income ? "+" : "-"
            html += """
                <div class="transaction-item">
                    <div class="transaction-info">
                        <div class="transaction-description">\(transaction.description)</div>
                        <div class="transaction-category">\(transaction.category)</div>
                        <div class="transaction-date">\(transaction.date)</div>
                    </div>
                    <div class="transaction-amount \(amountClass)">\(sign)$\(String(format: "%.2f", transaction.amount))</div>
                </div>
            """
        }

        transactionList.innerHTML = .string(html)
    }

    private func updateBudgetList() {
        guard let budgetList = budgetList else { return }

        // Calculate spending by category
        var spendingByCategory: [String: Double] = [:]
        for transaction in transactions where transaction.type == .expense {
            spendingByCategory[transaction.category, default: 0] += transaction.amount
        }

        // Create budget items (using default limits for demo)
        let defaultBudgets = [
            "Food & Dining": 500.0,
            "Transportation": 300.0,
            "Entertainment": 200.0,
            "Utilities": 150.0,
            "Healthcare": 100.0
        ]

        var html = ""
        for (category, limit) in defaultBudgets {
            let spent = spendingByCategory[category] ?? 0
            let percentage = limit > 0 ? (spent / limit) * 100 : 0
            let statusClass = percentage > 90 ? "over-budget" : percentage > 75 ? "warning" : "good"

            html += """
                <div class="budget-item">
                    <div class="budget-info">
                        <div class="budget-category">\(category)</div>
                        <div class="budget-progress">
                            <div class="progress-bar">
                                <div class="progress-fill \(statusClass)" style="width: \(min(percentage, 100))%"></div>
                            </div>
                            <div class="budget-amounts">$\(String(format: "%.2f", spent)) / $\(String(format: "%.2f", limit))</div>
                        </div>
                    </div>
                </div>
            """
        }

        budgetList.innerHTML = .string(html)
    }

    private func updateChart() {
        guard let canvas = canvas else { return }

        // Simple bar chart implementation
        let ctx = canvas.getContext("2d")

        // Clear canvas
        ctx.clearRect(0, 0, 400, 300)

        // Calculate spending by category
        var spendingByCategory: [String: Double] = [:]
        for transaction in transactions where transaction.type == .expense {
            spendingByCategory[transaction.category, default: 0] += transaction.amount
        }

        let categories = Array(spendingByCategory.keys.sorted())
        let maxSpending = spendingByCategory.values.max() ?? 1

        // Draw bars
        let barWidth = 400.0 / Double(categories.count)
        for (index, category) in categories.enumerated() {
            let spending = spendingByCategory[category] ?? 0
            let barHeight = (spending / maxSpending) * 250
            let x = Double(index) * barWidth + 10
            let y = 280 - barHeight

            // Bar
            ctx.fillStyle = .string("#4CAF50")
            ctx.fillRect(x, y, barWidth - 20, barHeight)

            // Label
            ctx.fillStyle = .string("#333")
            ctx.font = .string("12px Arial")
            ctx.fillText("\(category)", x, 295)
        }
    }

    private func getCurrentDateString() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: now)
    }

    private func loadData() {
        // Load from localStorage (simplified - in real app would use proper storage)
        if let stored = JSObject.global.localStorage.getItem("momentum_transactions").string {
            if let data = stored.data(using: .utf8),
               let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
                transactions = decoded
            }
        }
    }

    private func saveData() {
        if let data = try? JSONEncoder().encode(transactions),
           let jsonString = String(data: data, encoding: .utf8) {
            JSObject.global.localStorage.setItem("momentum_transactions", jsonString)
        }
    }
}

// MARK: - Web App Entry Point

@main
struct MomentumFinanceWebApp {
    static func main() {
        let app = MomentumFinanceWeb()
        // Keep app alive
        _ = app
    }
}
