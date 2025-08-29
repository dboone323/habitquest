import SwiftUI

struct ImportResultComponent: View {
    let result: ImportResult
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(result.success ? .green : .orange)

                Text(result.success ? "Import Successful" : "Import Completed with Issues")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(spacing: 16) {
                    if result.transactionsImported > 0 {
                        statRow(label: "Transactions Imported", value: "\(result.transactionsImported)")
                    }

                    if result.accountsImported > 0 {
                        statRow(label: "Accounts Imported", value: "\(result.accountsImported)")
                    }

                    if result.categoriesImported > 0 {
                        statRow(label: "Categories Imported", value: "\(result.categoriesImported)")
                    }

                    if !result.errors.isEmpty {
                        statRow(label: "Errors", value: "\(result.errors.count)", isError: true)
                    }

                    if result.duplicatesSkipped > 0 {
                        statRow(label: "Duplicates Skipped", value: "\(result.duplicatesSkipped)", isWarning: true)
                    }
                }
                .padding()
                .background(backgroundSecondaryColor())
                .cornerRadius(12)

                if !result.errors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Issues Found:")
                            .font(.headline)
                            .foregroundColor(.red)

                        ForEach(Array(result.errors.prefix(5).enumerated()), id: \.offset) { _, error in
                            Text("• \(error)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if result.errors.count > 5 {
                            Text("... and \(result.errors.count - 5) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }

                Spacer()

                Button("Done") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Import Results")
        }
    }

    private func statRow(label: String, value: String, isError: Bool = false, isWarning: Bool = false) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(isError ? .red : isWarning ? .orange : .primary)
        }
    }
}

#Preview {
    ImportResultComponent(result: ImportResult(success: true, transactionsImported: 10, accountsImported: 1, categoriesImported: 0, duplicatesSkipped: 0, errors: []), onDismiss: {})
}
