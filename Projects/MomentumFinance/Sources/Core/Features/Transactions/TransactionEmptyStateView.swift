//
//  TransactionEmptyStateView.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftUI

extension Features.Transactions {
    struct TransactionEmptyStateView: View {
        let searchText: String
        let onAddTransaction: () -> Void

        var body: some View {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: self.searchText.isEmpty ? "list.bullet" : "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                VStack(spacing: 8) {
                    Text(self.searchText.isEmpty ? "No Transactions" : "No Results Found")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(
                        self.searchText.isEmpty
                            ? "Add your first transaction to get started"
                            : "Try adjusting your search or filters"
                    )
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }

                if self.searchText.isEmpty {
                    Button("Add Transaction").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.onAddTransaction()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}
