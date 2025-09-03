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

                Image(systemName: searchText.isEmpty ? "list.bullet" : "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                VStack(spacing: 8) {
                    Text(searchText.isEmpty ? "No Transactions" : "No Results Found")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(
                        searchText.isEmpty
                            ? "Add your first transaction to get started"
                            : "Try adjusting your search or filters"
                    )
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }

                if searchText.isEmpty {
                    Button("Add Transaction") {
                        onAddTransaction()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}
