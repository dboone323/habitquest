// Momentum Finance - Enhanced Account Detail Export Functionality for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Shared
import SwiftData
import SwiftUI

#if os(macOS)

// MARK: - Export Options View for Enhanced Account Detail View

/// Export options sheet for exporting account transactions
struct ExportOptionsView: View {
    let account: FinancialAccount?
    let transactions: [FinancialTransaction]
    @State private var exportFormat: ExportFormat = .csv
    @State private var dateRange: DateRange = .all
    @State private var customStartDate = Date().addingTimeInterval(-30 * 24 * 60 * 60)
    @State private var customEndDate = Date()
    @Environment(\.dismiss) private var dismiss

    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case pdf = "PDF"
        case qif = "QIF"
    }

    enum DateRange: String, CaseIterable {
        case last30Days = "Last 30 Days"
        case last90Days = "Last 90 Days"
        case thisYear = "This Year"
        case custom = "Custom Range"
        case all = "All Transactions"
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Export Account Transactions")
                .font(.title2)
                .padding(.vertical)

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export Format")
                        .font(.headline)

                    Picker("Format", selection: self.$exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Date Range")
                        .font(.headline)

                    Picker("Date Range", selection: self.$dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 400)
                }

                if self.dateRange == .custom {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Start Date")
                                .font(.subheadline)
                            DatePicker("", selection: self.$customStartDate, displayedComponents: .date)
                                .labelsHidden()
                        }

                        VStack(alignment: .leading) {
                            Text("End Date")
                                .font(.subheadline)
                            DatePicker("", selection: self.$customEndDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Export Details")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Account Name: \(self.account?.name ?? "Unknown")")
                        Text("• Transaction Count: \(self.transactions.count)")
                        Text("• Fields: Date, Description, Category, Amount, Balance")

                        if self.exportFormat == .pdf {
                            Text("• Includes account summary and balance chart")
                        }
                    }
                    .font(.subheadline)
                }
            }

            Spacer()

            HStack {
                Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                    self.dismiss()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Export").accessibilityLabel("Button").accessibilityLabel("Button") {
                    self.performExport()
                    self.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
    }

    private func performExport() {
        // Export logic would go here
    }
}
#endif
