// Momentum Finance - Personal Finance App
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

enum Features {}

// Dashboard namespace
extension Features {
    enum Dashboard {}
}

// Transactions namespace
extension Features {
    enum Transactions {}
}

// Budgets namespace
extension Features {
    enum Budgets {}
}

// Subscriptions namespace
extension Features {
    enum Subscriptions {}
}

// GoalsAndReports namespace
extension Features {
    enum GoalsAndReports {}
}

// Theme namespace
extension Features {
    enum Theme {}
}
<<<<<<< HEAD
=======

// Global Search View
extension Features {
    struct GlobalSearchView: View {
        var body: some View {
            NavigationView {
                VStack {
                    Text("Global Search")
                        .font(.largeTitle)
                        .padding()
                    
                    Text("Search functionality coming soon...")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
>>>>>>> 1cf3938 (Create working state for recovery)
