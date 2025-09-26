import Foundation
import SwiftUI

// MARK: - Import UI Components

public struct DataImportHeaderComponent: View {
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Import Financial Data")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Import transactions from CSV files")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    public init() {}
}

public struct FileSelectionComponent: View {
    @Binding public var showingFilePicker: Bool
    public let onFileSelected: () -> Void

    public var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                self.showingFilePicker = true
                self.onFileSelected()
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 32))
                    Text("Select CSV File")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(12)
            }
        }
        .padding()
    }

    public init(showingFilePicker: Binding<Bool>, onFileSelected: @escaping () -> Void) {
        _showingFilePicker = showingFilePicker
        self.onFileSelected = onFileSelected
    }
}

public struct ImportProgressComponent: View {
    public let progress: Double

    public var body: some View {
        VStack(spacing: 8) {
            Text("Importing...")
                .font(.headline)

            ProgressView(value: self.progress)
                .progressViewStyle(LinearProgressViewStyle())

            Text("\(Int(self.progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    public init(progress: Double) {
        self.progress = progress
    }
}

public struct ImportButtonComponent: View {
    public let isImporting: Bool
    public let action: () -> Void

    public var body: some View {
        Button(action: self.action) {
            HStack {
                if self.isImporting {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Text(self.isImporting ? "Importing..." : "Import Data")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(self.isImporting ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(self.isImporting)
        .accessibilityLabel("Import Data")
    }

    public init(isImporting: Bool, action: @escaping () -> Void) {
        self.isImporting = isImporting
        self.action = action
    }
}

public struct ImportInstructionsComponent: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Instructions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                self.instructionRow("1.", "Prepare a CSV file with your transaction data")
                self.instructionRow("2.", "Include columns: Date, Amount, Description")
                self.instructionRow("3.", "Optional: Category, Account columns")
                self.instructionRow("4.", "Select your file and click Import")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func instructionRow(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            Text(text)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    public init() {}
}
