//
//  EntityManager.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import SwiftData

/// Manages creation and retrieval of financial entities during import
struct EntityManager {
    let modelContext: ModelContext

    /// Gets existing account or creates a new one from CSV data
    func getOrCreateAccount(
        from fields: [String],
        columnMapping: CSVIndexMapping
    ) async throws -> FinancialAccount {
        let accountName: String = if let accountIndex = columnMapping.accountIndex,
                                     accountIndex < fields.count
        {
            fields[accountIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            "Imported Account"
        }

        // Try to find existing account
        let descriptor = FetchDescriptor<FinancialAccount>(
            predicate: #Predicate { account in
                account.name == accountName
            }
        )

        if let existingAccount = try modelContext.fetch(descriptor).first {
            return existingAccount
        }

        // Create new account
        let newAccount = FinancialAccount(
            name: accountName,
            balance: 0.0,
            iconName: "creditcard.fill"
        )

        self.modelContext.insert(newAccount)
        return newAccount
    }

    /// Gets existing category or creates a new one from CSV data
    func getOrCreateCategory(
        from fields: [String],
        columnMapping: CSVIndexMapping,
        transactionType: TransactionType
    ) async throws -> ExpenseCategory {
        let categoryName: String = if let categoryIndex = columnMapping.categoryIndex,
                                      categoryIndex < fields.count
        {
            fields[categoryIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            transactionType == .income ? "Other Income" : "Other Expenses"
        }

        // Try to find existing category
        let descriptor = FetchDescriptor<ExpenseCategory>(
            predicate: #Predicate { category in
                category.name == categoryName
            }
        )

        if let existingCategory = try modelContext.fetch(descriptor).first {
            return existingCategory
        }

        // Create new category
        let newCategory = ExpenseCategory(
            name: categoryName,
            iconName: "folder.fill"
        )

        self.modelContext.insert(newCategory)
        return newCategory
    }
}

// MARK: - Object Pooling

/// Object pool for performance optimization
@MainActor
private var objectPool: [Any] = []
@MainActor
private let maxPoolSize = 50
@MainActor
private let poolLock = NSLock()

/// Get an object from the pool or create new one
@MainActor
private func getPooledObject<T>() -> T? {
    poolLock.lock()
    defer { poolLock.unlock() }
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
@MainActor
private func returnToPool(_ object: Any) {
    poolLock.lock()
    defer { poolLock.unlock() }
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
