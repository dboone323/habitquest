// Momentum Finance - Data Export View
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Comprehensive data export view with multiple format options
struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var exportFormat: ExportFormat = .csv
    @State private var dateRange: DateRange = .lastYear
    @State private var customStartDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
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

    var body: some View {
        NavigationView {
            Form {
                formatSection
                dateRangeSection
                dataSelectionSection
                exportSection
            }
            .navigationTitle("Export Data")
            #if os(iOS)
<<<<<<< HEAD
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert("Export Error", isPresented: .constant(exportError != nil)) {
                Button("OK") {
                    exportError = nil
                }
            } message: {
                if let error = exportError {
                    Text(error)
                }
            }
=======
                .navigationBarTitleDisplayMode(.large)
            #endif
                .toolbar {
                    #if os(iOS)
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    #else
                        ToolbarItem {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    #endif
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let url = exportedFileURL {
                        ShareSheet(activityItems: [url])
                    }
                }
                .alert("Export Error", isPresented: .constant(exportError != nil)) {
                    Button("OK") {
                        exportError = nil
                    }
                } message: {
                    if let error = exportError {
                        Text(error)
                    }
                }
>>>>>>> 1cf3938 (Create working state for recovery)
        }
    }

    private var formatSection: some View {
        Section {
            Picker("Export Format", selection: $exportFormat) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Label(format.displayName, systemImage: format.icon)
                        .tag(format)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: exportFormat) { _, _ in
                #if os(iOS)
<<<<<<< HEAD
                HapticManager.shared.selection()
=======
                    HapticManager.shared.selection()
>>>>>>> 1cf3938 (Create working state for recovery)
                #endif
            }

            Text(exportFormat.description)
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Text("Export Format")
        }
    }

    private var dateRangeSection: some View {
        Section {
            Picker("Date Range", selection: $dateRange) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Text(range.displayName).tag(range)
                }
            }
            .onChange(of: dateRange) { _, _ in
                #if os(iOS)
<<<<<<< HEAD
                HapticManager.shared.selection()
=======
                    HapticManager.shared.selection()
>>>>>>> 1cf3938 (Create working state for recovery)
                #endif
            }

            if dateRange == .custom {
                DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
            }

            Text(dateRangeDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Text("Date Range")
        }
    }

    private var dataSelectionSection: some View {
        Section {
            Toggle("Transactions", isOn: $includeTransactions)
                .onChange(of: includeTransactions) { _, _ in
                    #if os(iOS)
<<<<<<< HEAD
                    HapticManager.shared.lightImpact()
=======
                        HapticManager.shared.lightImpact()
>>>>>>> 1cf3938 (Create working state for recovery)
                    #endif
                }

            Toggle("Accounts", isOn: $includeAccounts)
                .onChange(of: includeAccounts) { _, _ in
                    #if os(iOS)
<<<<<<< HEAD
                    HapticManager.shared.lightImpact()
=======
                        HapticManager.shared.lightImpact()
>>>>>>> 1cf3938 (Create working state for recovery)
                    #endif
                }

            Toggle("Budgets", isOn: $includeBudgets)
                .onChange(of: includeBudgets) { _, _ in
                    #if os(iOS)
<<<<<<< HEAD
                    HapticManager.shared.lightImpact()
=======
                        HapticManager.shared.lightImpact()
>>>>>>> 1cf3938 (Create working state for recovery)
                    #endif
                }

            Toggle("Subscriptions", isOn: $includeSubscriptions)
                .onChange(of: includeSubscriptions) { _, _ in
                    #if os(iOS)
<<<<<<< HEAD
                    HapticManager.shared.lightImpact()
=======
                        HapticManager.shared.lightImpact()
>>>>>>> 1cf3938 (Create working state for recovery)
                    #endif
                }

            Toggle("Savings Goals", isOn: $includeGoals)
                .onChange(of: includeGoals) { _, _ in
                    #if os(iOS)
<<<<<<< HEAD
                    HapticManager.shared.lightImpact()
=======
                        HapticManager.shared.lightImpact()
>>>>>>> 1cf3938 (Create working state for recovery)
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
                    await exportData()
                }
            }) {
                HStack {
                    if isExporting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Text(isExporting ? "Exporting..." : "Export Data")
                }
            }
            .disabled(isExporting || !hasDataSelected)
            #if os(iOS)
<<<<<<< HEAD
            .hapticFeedback(.medium, trigger: isExporting)
=======
                .hapticFeedback(.medium, trigger: isExporting)
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        } footer: {
            if !hasDataSelected {
                Text("Please select at least one data type to export.")
                    .foregroundColor(.red)
            }
        }
    }

    private var hasDataSelected: Bool {
        includeTransactions || includeAccounts || includeBudgets || includeSubscriptions || includeGoals
    }

    private var dateRangeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let (startDate, endDate) = getDateRange()
        return "From \(formatter.string(from: startDate)) to \(formatter.string(from: endDate))"
    }

    private func getDateRange() -> (start: Date, end: Date) {
        switch dateRange {
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
            return (customStartDate, customEndDate)
        }
    }

    @MainActor
    private func exportData() async {
        isExporting = true
        #if os(iOS)
<<<<<<< HEAD
        HapticManager.shared.mediumImpact()
=======
            HapticManager.shared.mediumImpact()
>>>>>>> 1cf3938 (Create working state for recovery)
        #endif

        do {
            let exporter = DataExporter(modelContainer: modelContext.container)
            let (startDate, endDate) = getDateRange()

            let exportSettings = ExportSettings(
                format: exportFormat,
                startDate: startDate,
                endDate: endDate,
                includeTransactions: includeTransactions,
                includeAccounts: includeAccounts,
                includeBudgets: includeBudgets,
                includeSubscriptions: includeSubscriptions,
                includeGoals: includeGoals,
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)

            let fileURL = try await exporter.export(with: exportSettings)
            exportedFileURL = fileURL
            showingShareSheet = true
            #if os(iOS)
<<<<<<< HEAD
            HapticManager.shared.success()
=======
                HapticManager.shared.success()
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        } catch {
            exportError = error.localizedDescription
            #if os(iOS)
<<<<<<< HEAD
            HapticManager.shared.error()
=======
                HapticManager.shared.error()
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        isExporting = false
    }
}

// MARK: - ShareSheet

#if os(iOS)
<<<<<<< HEAD
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    /// <#Description#>
    /// - Returns: <#description#>
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil,
            )
        return controller
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
                .padding(.top)
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}
=======
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]

    /// <#Description#>
    /// - Returns: <#description#>
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: nil,
            )
            return controller
        }

    /// <#Description#>
    /// - Returns: <#description#>
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
                    .padding(.top)
                }
            }
            .padding()
            .frame(width: 400, height: 200)
        }
    }
>>>>>>> 1cf3938 (Create working state for recovery)
#endif

#Preview {
    DataExportView()
        .modelContainer(for: [FinancialTransaction.self, FinancialAccount.self, Budget.self, Subscription.self, SavingsGoal.self])
}
