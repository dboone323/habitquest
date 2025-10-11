//
//  FinancialIntelligencePlaceholders.swift
//  MomentumFinance
//
//  Placeholder types and extensions for Advanced Financial Intelligence
//  Extracted from AdvancedFinancialIntelligence.swift to reduce file size
//

import Foundation

// MARK: - Placeholder Types (these should exist in your actual models)

/// Lightweight transaction representation for AI analysis
public struct Transaction {
    let id: String
    let amount: Double
    let date: Date
    let category: String
    let merchant: String?
}

/// Lightweight account representation for AI analysis
public struct Account {
    let id: String
    let name: String
    let type: AccountType
    let balance: Double
}

/// Account type classifications
public enum AccountType {
    case checking, savings, investment, credit
}

/// Lightweight budget representation for AI analysis
public struct Budget {
    let id: String
    let category: String
    let amount: Double
    let period: BudgetPeriod
}

/// Lightweight struct for AI budget analysis (not the main Budget model).
public struct AIBudget {
    let id: String
    let category: String
    let amount: Double
    let period: BudgetPeriod
}

// MARK: - Protocol Conformances

extension Transaction: FinancialAnalyticsTransactionConvertible {
    var faAmount: Double { self.amount }
    var faDate: Date { self.date }
    var faCategory: String { self.category }
    var faMerchant: String? { self.merchant }
}

extension Account: FinancialAnalyticsAccountConvertible {
    var faType: FinancialAnalyticsAccountKind {
        switch self.type {
        case .checking:
            .checking
        case .savings:
            .savings
        case .investment:
            .investment
        case .credit:
            .credit
        }
    }

    var faBalance: Double { self.balance }
}

extension AIBudget: FinancialAnalyticsBudgetConvertible {
    var faCategory: String { self.category }
    var faAmount: Double { self.amount }
    var faPeriod: FinancialAnalyticsBudgetPeriod {
        switch self.period {
        case .monthly:
            .monthly
        case .yearly:
            .yearly
        }
    }
}
