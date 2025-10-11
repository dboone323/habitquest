import SwiftData
import SwiftUI

public struct ExportDataView: View {
    @Binding var isPresented: Bool
    @Binding var exportURL: URL?
    @Binding var isExporting: Bool
    @Environment(\.modelContext) private var modelContext

    @State private var selectedFormat: ExportFormat = .csv
    @State private var selectedDateRange: DateRange = .lastMonth
    @State private var includeCategories = true
    @State private var includeAccounts = true
    @State private var includeBudgets = true
    @State private var customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var customEndDate = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Export Format")) {
                    Picker("Format", selection: self.$selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            HStack {
                                Image(systemName: format.icon)
                                Text(format.displayName)
                            }
                            .tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Date Range")) {
                    Picker("Date Range", selection: self.$selectedDateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.displayName)
                                .tag(range)
                        }
                    }

                    if self.selectedDateRange == .custom {
                        DatePicker("Start Date", selection: self.$customStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: self.$customEndDate, displayedComponents: .date)
                    }
                }

                Section(header: Text("Include Data")) {
                    Toggle("Categories", isOn: self.$includeCategories)
                    Toggle("Accounts", isOn: self.$includeAccounts)
                    Toggle("Budgets", isOn: self.$includeBudgets)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.isPresented = false
                },
                trailing: Button("Export") {
                    Task {
                        await self.performExport()
                    }
                }
                .disabled(self.isExporting)
            )
        }
        .presentationDetents([.medium])
    }

    private func performExport() async {
        self.isExporting = true
        defer { isExporting = false }

        do {
            let (startDate, endDate) = self.getDateRange()

            let settings = ExportSettings(
                format: selectedFormat,
                dateRange: selectedDateRange,
                includeCategories: includeCategories,
                includeAccounts: includeAccounts,
                includeBudgets: includeBudgets,
                startDate: startDate,
                endDate: endDate
            )

            let exporter = DataExporter(modelContainer: modelContext.container)
            let url = try await exporter.exportData(settings: settings)

            self.exportURL = url
            self.isPresented = false
        } catch {
            print("Export failed: \(error.localizedDescription)")
            // In a real app, you'd show an error alert
        }
    }

    private func getDateRange() -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()

        switch self.selectedDateRange {
        case .lastWeek:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return (start, now)
        case .lastMonth:
            let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return (start, now)
        case .lastThreeMonths:
            let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return (start, now)
        case .lastSixMonths:
            let start = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            return (start, now)
        case .lastYear:
            let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return (start, now)
        case .allTime:
            return (Date.distantPast, now)
        case .custom:
            return (self.customStartDate, self.customEndDate)
        }
    }
}
