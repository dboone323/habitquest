import SwiftUI

public struct DataImportHeaderComponent: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Import Financial Data").font(.title2).fontWeight(.bold)
            Text("Import your financial data from CSV files").font(.subheadline).foregroundColor(
                .secondary
            )
        }.padding()
    }
}

public struct FileSelectionComponent: View {
    @Binding var showingFilePicker: Bool
    public init(showingFilePicker: Binding<Bool>) { _showingFilePicker = showingFilePicker }
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus").font(.system(size: 48)).foregroundColor(.blue)
            Text("Select CSV File").font(.headline)
            Text("Choose a CSV file containing your financial data").font(.subheadline)
                .foregroundColor(.secondary).multilineTextAlignment(.center)
            Button(action: { self.showingFilePicker = true }) {
                Label("Choose File", systemImage: "folder").padding().background(Color.blue)
                    .foregroundColor(.white).cornerRadius(8)
            }
            .accessibilityLabel("Choose File")
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

public struct ImportProgressComponent: View {
    let progress: Double
    public init(progress: Double) { self.progress = progress }
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: self.progress, total: 1.0).progressViewStyle(
                CircularProgressViewStyle()
            )
            Text("Importing data...").font(.subheadline).foregroundColor(.secondary)
            Text("\(Int(self.progress * 100))% complete").font(.caption).foregroundColor(.secondary)
        }.padding()
    }
}

public struct ImportButtonComponent: View {
    let isImporting: Bool
    let action: () -> Void
    public init(isImporting: Bool, action: @escaping () -> Void) {
        self.isImporting = isImporting
        self.action = action
    }

    public var body: some View {
        Button(action: self.action) {
            if self.isImporting {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Label("Import Data", systemImage: "square.and.arrow.down")
            }
        }
        .accessibilityLabel(self.isImporting ? "Importing" : "Import Data")
        .padding()
        .background(self.isImporting ? Color.gray : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .disabled(self.isImporting)
    }
}

public struct ImportInstructionsComponent: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Instructions").font(.headline)
            VStack(alignment: .leading, spacing: 8) {
                Text("• CSV file should contain columns: date, title, amount")
                Text("• Date format: YYYY-MM-DD")
                Text("• Amount format: positive for income, negative for expenses")
                Text("• Optional columns: notes, category, account")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(platformGrayColor())
        .cornerRadius(8)
    }
}

public struct ImportResultView: View {
    let result: ImportResult
    let onDismiss: () -> Void
    public init(result: ImportResult, onDismiss: @escaping () -> Void) {
        self.result = result
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: self.result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 48)).foregroundColor(self.result.success ? .green : .red)
            Text(self.result.success ? "Import Successful" : "Import Failed").font(.title2)
                .fontWeight(.bold)
            VStack(alignment: .leading, spacing: 8) {
                Text("Items imported: \(self.result.itemsImported)").font(.body)
                if !self.result.errors.isEmpty {
                    Text("Errors:").font(.headline).foregroundColor(.red)
                    ForEach(self.result.errors, id: \.self) { error in
                        Text("• \(error)").font(.subheadline).foregroundColor(.red)
                    }
                }
                if !self.result.warnings.isEmpty {
                    Text("Warnings:").font(.headline).foregroundColor(.orange)
                    ForEach(self.result.warnings, id: \.self) { warning in
                        Text("• \(warning)").font(.subheadline).foregroundColor(.orange)
                    }
                }
            }
            Button("Done", action: self.onDismiss)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .accessibilityLabel("Done")
        }.padding()
    }
}
