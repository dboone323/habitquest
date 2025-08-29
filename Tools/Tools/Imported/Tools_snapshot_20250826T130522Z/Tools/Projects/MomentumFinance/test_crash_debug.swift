#!/usr/bin/env swift

import Foundation
import SwiftData

// Test ModelContainer initialization
print("Testing ModelContainer initialization...")

do {
    let schema = Schema([
        FinancialAccount.self,
        FinancialTransaction.self,
        Subscription.self,
        Budget.self,
        ExpenseCategory.self,
        SavingsGoal.self,
    ])

    print("Schema created successfully")

    let modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true, // Use in-memory for testing
    )

    print("ModelConfiguration created successfully")

    let container = try ModelContainer(
        for: schema,
        configurations: [modelConfiguration],
    )

    print("ModelContainer created successfully!")

} catch {
    print("ERROR creating ModelContainer: \(error)")
    print("Error type: \(type(of: error))")
    if let nsError = error as NSError? {
        print("Error domain: \(nsError.domain)")
        print("Error code: \(nsError.code)")
        print("Error userInfo: \(nsError.userInfo)")
    }
}
