// Momentum Finance - Data Export View
// Copyright © 2025 Momentum Finance. All rights reserved.

import MomentumFinanceCore
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Comprehensive data export view with multiple format options
public struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var exportFormat: ExportFormat = .csv
    @State private var dateRange: DateRange = .lastYear
    @State private var customStartDate =
        Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State private var customEndDate = Date()
    @State private var includeTransactions = true
    @State private var includeAccounts = true
    @State private var includeBudgets = true
    @State private var includeSubscriptions = true
    @State private var includeGoals = true
    @State private var isExporting = false
    @State private var exportedFileURL: URL?
    @State private var showingShareSheet = false
    @State private var exportError: String?

    public var body: some View {
        NavigationView {
            Form {
                self.formatSection
                self.dateRangeSection
                self.dataSelectionSection
                self.exportSection
            }
            .navigationTitle("Export Data")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
            #endif
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { self.dismiss() }
                            .accessibilityLabel("Cancel Button")
                    }
                    #else
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { self.dismiss() }
                            .accessibilityLabel("Cancel Button")
                    }
                    #endif
                }
                .sheet(isPresented: self.$showingShareSheet) {
                    if let url = exportedFileURL {
                        ShareSheet(activityItems: [url])
                    }
                }
                .alert("Export Error", isPresented: .constant(self.exportError != nil)) {
                    Button("OK") { self.exportError = nil }
                        .accessibilityLabel("Dismiss Error Button")
                } message: {
                    if let error = exportError {
                        Text(error)
                    }
                }
        }
    }

    private var formatSection: some View {
        Section {
            Picker("Export Format", selection: self.$exportFormat) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Label(format.displayName, systemImage: format.icon)
                        .tag(format)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: self.exportFormat) { _, _ in
                #if os(iOS)
                HapticManager.shared.selection()
                #endif
            }

            Text(self.exportFormat.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Text("Export Format")
        }
    }

    private var dateRangeSection: some View {
        Section {
            Picker("Date Range", selection: self.$dateRange) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Text(range.displayName).tag(range)
                }
            }
            .onChange(of: self.dateRange) { _, _ in
                #if os(iOS)
                HapticManager.shared.selection()
                #endif
            }

            if self.dateRange == .custom {
                DatePicker(
                    "Start Date", selection: self.$customStartDate, displayedComponents: .date
                )
                DatePicker("End Date", selection: self.$customEndDate, displayedComponents: .date)
            }

            Text(self.dateRangeDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Text("Date Range")
        }
    }

    private var dataSelectionSection: some View {
        Section {
            Toggle("Transactions", isOn: self.$includeTransactions)
                .onChange(of: self.includeTransactions) { _, _ in
                    #if os(iOS)
                    HapticManager.shared.lightImpact()
                    #endif
                }

            Toggle("Accounts", isOn: self.$includeAccounts)
                .onChange(of: self.includeAccounts) { _, _ in
                    #if os(iOS)
                    HapticManager.shared.lightImpact()
                    #endif
                }

            Toggle("Budgets", isOn: self.$includeBudgets)
                .onChange(of: self.includeBudgets) { _, _ in
                    #if os(iOS)
                    HapticManager.shared.lightImpact()
                    #endif
                }

            Toggle("Subscriptions", isOn: self.$includeSubscriptions)
                .onChange(of: self.includeSubscriptions) { _, _ in
                    #if os(iOS)
                    HapticManager.shared.lightImpact()
                    #endif
                }

            Toggle("Savings Goals", isOn: self.$includeGoals)
                .onChange(of: self.includeGoals) { _, _ in
                    #if os(iOS)
                    HapticManager.shared.lightImpact()
                    #endif
                }
        } header: {
            Text("Data to Include")
        } footer: {
            Text("Select which types of data to include in your export.")
        }
    }

    private var exportSection: some View {
        Section {
            Button(action: {
                Task {
                    await self.exportData()
                }
            }) {
                HStack {
                    if self.isExporting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Text(self.isExporting ? "Exporting..." : "Export Data")
                }
            }
            .disabled(self.isExporting || !self.hasDataSelected)
            #if os(iOS)
                .hapticFeedback(.medium, trigger: self.isExporting)
            #endif
        } footer: {
            if !self.hasDataSelected {
                Text("Please select at least one data type to export.")
                    .foregroundColor(.red)
            }
        }
    }

    private var hasDataSelected: Bool {
        self.includeTransactions || self.includeAccounts || self.includeBudgets
            || self.includeSubscriptions
            || self.includeGoals
    }

    private var dateRangeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let (startDate, endDate) = self.getDateRange()
        return "From \(formatter.string(from: startDate)) to \(formatter.string(from: endDate))"
    }

    private func getDateRange() -> (start: Date, end: Date) {
        switch self.dateRange {
        case .lastWeek:
            let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return (start, Date())
        case .lastMonth:
            let start = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return (start, Date())
        case .lastThreeMonths:
            let start = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            return (start, Date())
        case .lastSixMonths:
            let start = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            return (start, Date())
        case .lastYear:
            let start = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            return (start, Date())
        case .allTime:
            return (Date.distantPast, Date())
        case .custom:
            return (self.customStartDate, self.customEndDate)
        }
    }

    @MainActor
    private func exportData() async {
        self.isExporting = true
        #if os(iOS)
        HapticManager.shared.mediumImpact()
        #endif

        do {
            let exporter = DataExporter(modelContainer: modelContext.container)
            let (start, end) = self.getDateRange()

            let exportSettings = ExportSettings(
                format: exportFormat,
                dateRange: dateRange,
                includeCategories: includeTransactions,
                includeAccounts: includeAccounts,
                includeBudgets: includeBudgets,
                startDate: start,
                endDate: end
            )

            let fileURL = try await exporter.exportData(settings: exportSettings)
            self.exportedFileURL = fileURL
            self.showingShareSheet = true
            #if os(iOS)
            HapticManager.shared.success()
            #endif
        } catch {
            self.exportError = error.localizedDescription
            #if os(iOS)
            HapticManager.shared.error()
            #endif
        }

        self.isExporting = false
    }
}

// MARK: - ShareSheet

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    /// <#Description#>
    /// - Returns: <#description#>
    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil,
        )
        return controller
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
#else
// macOS version of ShareSheet
struct ShareSheet: View {
    let activityItems: [Any]

    var body: some View {
        VStack {
            Text("Export Complete")
                .font(.headline)

            if let url = activityItems.first as? URL {
                Text("File saved at: \(url.path)")
                    .font(.subheadline)

                Button("Show in Finder") {
                    NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
                }
                .accessibilityLabel("Show In Finder Button")
                .padding(.top)
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}
#endif

#Preview {
    DataExportView()
        .modelContainer(for: [
            FinancialTransaction.self, FinancialAccount.self, Budget.self, Subscription.self,
            SavingsGoal.self,
        ])
}
