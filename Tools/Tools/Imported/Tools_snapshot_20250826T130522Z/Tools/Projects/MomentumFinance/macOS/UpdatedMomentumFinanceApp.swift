// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData
import SwiftUI

// Model references for SwiftData container
private extension MomentumFinanceApp {
    enum ModelReferences {
        static let accounts = FinancialAccount.self
        static let transactions = FinancialTransaction.self
        static let subscriptions = Subscription.self
        static let budgets = Budget.self
        static let categories = ExpenseCategory.self
        static let goals = SavingsGoal.self
    }
}

@main
struct MomentumFinanceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ModelReferences.accounts,
            ModelReferences.transactions,
            ModelReferences.subscriptions,
            ModelReferences.budgets,
            ModelReferences.categories,
            ModelReferences.goals,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

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
        .modelContainer(sharedModelContainer)

        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}
