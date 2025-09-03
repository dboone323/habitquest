//
//  SearchAndFilterSection.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftUI

// MARK: - Transaction Filter

/// Filter options for transaction lists
public enum TransactionFilter: String, CaseIterable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
}

extension Features.Transactions {

    struct SearchAndFilterSection: View {
        @Binding var searchText: String
        @Binding var selectedFilter: TransactionFilter
        @Binding var showingSearch: Bool

        var body: some View {
            VStack(spacing: 12) {
                // Simple Search Bar
                TextField("Search transactions...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}
