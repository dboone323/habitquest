import Foundation
import os
import SwiftData
import SwiftUI

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

// Model references for SwiftData container
fileprivate extension MomentumFinanceApp {
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
    @State private var showingError = false
    @State private var errorMessage = ""

    init() {
        print("MomentumFinanceApp: init started")
        // TODO: Implement app initialization analytics tracking
        // TODO: Add crash reporting setup in init method
        // TODO: Initialize user preferences and settings on app launch
    }

    var sharedModelContainer: ModelContainer? = {
        print("MomentumFinanceApp: Creating ModelContainer")

        let schema = Schema([
            ModelReferences.accounts,
            ModelReferences.transactions,
            ModelReferences.subscriptions,
            ModelReferences.budgets,
            ModelReferences.categories,
            ModelReferences.goals,
        ])

        print("MomentumFinanceApp: Schema created")

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        print("MomentumFinanceApp: ModelConfiguration created")

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("MomentumFinanceApp: ModelContainer created successfully")
            return container
        } catch {
            // Log the error instead of crashing
            print("MomentumFinanceApp: ERROR creating ModelContainer: \(error)")
            os_log(
                "Could not create ModelContainer: %@", log: .default, type: .error,
                error.localizedDescription
            )

            // Try with in-memory storage as fallback
            do {
                let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [inMemoryConfig])
                print("MomentumFinanceApp: In-memory ModelContainer created successfully")
                return container
            } catch {
                print("MomentumFinanceApp: ERROR creating in-memory ModelContainer: \(error)")
                os_log(
                    "Could not create in-memory ModelContainer: %@", log: .default, type: .error,
                    error.localizedDescription
                )
                return nil
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                ContentView()
                    .modelContainer(container)
                    .onAppear {
                        print("MomentumFinanceApp: ContentView appeared")
                    }
            } else {
                // Show error view if ModelContainer couldn't be created
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)

                    Text("Unable to Initialize Database")
                        .font(.title)
                        .fontWeight(.bold)

                    Text(
                        "The app encountered an error while setting up the database. Please try restarting the app."
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                    Button("Quit App") {
                        #if os(iOS)
                        // iOS doesn't allow programmatic app termination
                        // User must manually close the app
                        #else
                        NSApplication.shared.terminate(nil)
                        #endif
                    }
                    .accessibilityLabel("Button")
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #if os(iOS)
                    .background(Color(uiColor: .systemBackground))
                #else
                    .background(Color(NSColor.windowBackgroundColor))
                #endif
                    .onAppear {
                        print("MomentumFinanceApp: Error view appeared")
                    }
            }
        }

        #if os(macOS)
        Settings {
            if let container = sharedModelContainer {
                SettingsView()
                    .modelContainer(container)
            } else {
                Text("Settings unavailable - Database error")
                    .padding()
            }
        }
        #endif
    }
}
