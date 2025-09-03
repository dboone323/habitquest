// Momentum Finance - Data Import View
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Data import view for CSV files
struct DataImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showingFilePicker = false
    @State private var selectedFileURL: URL?
    @State private var importProgress: Double = 0
    @State private var isImporting = false
    @State private var importResult: ImportResult?
    @State private var showingResult = false
    @State private var importError: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
<<<<<<< HEAD
                headerSection
=======
                DataImportHeaderComponent()
>>>>>>> 1cf3938 (Create working state for recovery)

                if let fileURL = selectedFileURL {
                    selectedFileSection(fileURL)
                } else {
<<<<<<< HEAD
                    fileSelectionSection
                }

                if isImporting {
                    importProgressSection
                } else if selectedFileURL != nil {
                    importButtonSection
=======
                    FileSelectionComponent(showingFilePicker: $showingFilePicker) {
                        #if os(iOS)
                            HapticManager.shared.lightImpact()
                        #endif
                    }
                }

                if isImporting {
                    ImportProgressComponent(progress: importProgress)
                } else if selectedFileURL != nil {
                    ImportButtonComponent(isImporting: isImporting) {
                        Task { await importData() }
                    }
>>>>>>> 1cf3938 (Create working state for recovery)
                }

                Spacer()

<<<<<<< HEAD
                instructionsSection
=======
                ImportInstructionsComponent()
>>>>>>> 1cf3938 (Create working state for recovery)
            }
            .padding()
            .navigationTitle("Import Data")
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
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false,
                ) { result in
                handleFileSelection(result)
            }
            .alert("Import Error", isPresented: .constant(importError != nil)) {
                Button("OK") {
                    importError = nil
                }
            } message: {
                if let error = importError {
                    Text(error)
                }
            }
            .sheet(isPresented: $showingResult) {
                if let result = importResult {
                    ImportResultView(result: result) {
                        dismiss()
                    }
                }
=======
                .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                #else
                    ToolbarItem { Button("Cancel") { dismiss() } }
                #endif
            }
            .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.commaSeparatedText, .plainText], allowsMultipleSelection: false) { result in
                handleFileSelection(result)
            }
            .alert("Import Error", isPresented: .constant(importError != nil)) {
                Button("OK") { importError = nil }
            } message: {
                if let error = importError { Text(error) }
            }
            .sheet(isPresented: $showingResult) {
                if let result = importResult { ImportResultComponent(result: result) { dismiss() } }
>>>>>>> 1cf3938 (Create working state for recovery)
            }
        }
    }

<<<<<<< HEAD
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.and.arrow.down.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Import Financial Data")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Import transactions and other data from CSV files")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    private var fileSelectionSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingFilePicker = true
                #if os(iOS)
                HapticManager.shared.lightImpact()
                #endif
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)

                            Text("Select CSV File")
                                .font(.headline)
                                .foregroundColor(.blue)

                            Text("Tap to browse files")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        },
                        )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

=======
>>>>>>> 1cf3938 (Create working state for recovery)
    private func selectedFileSection(_ fileURL: URL) -> some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundSecondaryColor())
                .frame(height: 80)
                .overlay(
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(fileURL.lastPathComponent)
                                .font(.headline)
                                .lineLimit(1)

                            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                                Text("Size: \(ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

<<<<<<< HEAD
                        Button("Change") {
                            selectedFileURL = nil
                            showingFilePicker = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(),
                    )
        }
    }

    private var importProgressSection: some View {
        VStack(spacing: 16) {
            ProgressView("Importing data...", value: importProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())

            Text("\(Int(importProgress * 100))% complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var importButtonSection: some View {
        Button(action: {
            Task {
                await importData()
            }
        }) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue)
                .frame(height: 50)
                .overlay(
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import Data")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white),
                    )
        }
        .buttonStyle(PlainButtonStyle())
        #if os(iOS)
        .hapticFeedback(.medium, trigger: isImporting)
        #endif
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Instructions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                instructionRow(icon: "1.circle.fill", text: "Export data from your current finance app as CSV")
                instructionRow(icon: "2.circle.fill", text: "Ensure columns include: Date, Description, Amount, Category")
                instructionRow(icon: "3.circle.fill", text: "Select the CSV file and tap Import")
                instructionRow(icon: "4.circle.fill", text: "Review the import results and confirm")
            }

            Text("Supported formats: CSV files with standard financial data columns")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(backgroundSecondaryColor())
        .cornerRadius(12)
    }

    private func instructionRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)

            Spacer()
=======
                        Button("Change") { selectedFileURL = nil; showingFilePicker = true }
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding()
                )
>>>>>>> 1cf3938 (Create working state for recovery)
        }
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
<<<<<<< HEAD
        case let .success(urls):
            if let url = urls.first {
                selectedFileURL = url
                #if os(iOS)
                HapticManager.shared.success()
                #endif
            }
        case let .failure(error):
            importError = "Failed to select file: \(error.localizedDescription)"
            #if os(iOS)
            HapticManager.shared.error()
=======
        case .success(let urls):
            if let url = urls.first {
                selectedFileURL = url
                #if os(iOS)
                    HapticManager.shared.success()
                #endif
            }
        case .failure(let error):
            importError = "Failed to select file: \(error.localizedDescription)"
            #if os(iOS)
                HapticManager.shared.error()
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }

    @MainActor
    private func importData() async {
        guard let fileURL = selectedFileURL else { return }

        isImporting = true
        importProgress = 0
        #if os(iOS)
<<<<<<< HEAD
        HapticManager.shared.mediumImpact()
=======
            HapticManager.shared.mediumImpact()
>>>>>>> 1cf3938 (Create working state for recovery)
        #endif

        do {
            let importer = DataImporter(modelContainer: modelContext.container)

<<<<<<< HEAD
            // Simulate progress updates
            for i in 1 ... 10 {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
=======
            for i in 1...10 {
                try await Task.sleep(nanoseconds: 100_000_000)
>>>>>>> 1cf3938 (Create working state for recovery)
                importProgress = Double(i) / 10.0
            }

            let result = try await importer.importFromCSV(fileURL: fileURL)
            importResult = result
            showingResult = true
            #if os(iOS)
<<<<<<< HEAD
            HapticManager.shared.success()
=======
                HapticManager.shared.success()
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        } catch {
            importError = error.localizedDescription
            #if os(iOS)
<<<<<<< HEAD
            HapticManager.shared.error()
=======
                HapticManager.shared.error()
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        isImporting = false
        importProgress = 0
    }
}

// MARK: - Import Result View

struct ImportResultView: View {
    let result: ImportResult
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Success Icon
<<<<<<< HEAD
                Image(systemName: result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(result.success ? .green : .orange)
=======
                Image(
                    systemName: result.success
                        ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                )
                .font(.system(size: 60))
                .foregroundColor(result.success ? .green : .orange)
>>>>>>> 1cf3938 (Create working state for recovery)

                // Title
                Text(result.success ? "Import Successful" : "Import Completed with Issues")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Statistics
                VStack(spacing: 16) {
                    if result.transactionsImported > 0 {
<<<<<<< HEAD
                        statRow(label: "Transactions Imported", value: "\(result.transactionsImported)")
=======
                        statRow(
                            label: "Transactions Imported", value: "\(result.transactionsImported)")
>>>>>>> 1cf3938 (Create working state for recovery)
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
<<<<<<< HEAD
                        statRow(label: "Duplicates Skipped", value: "\(result.duplicatesSkipped)", isWarning: true)
=======
                        statRow(
                            label: "Duplicates Skipped", value: "\(result.duplicatesSkipped)",
                            isWarning: true)
>>>>>>> 1cf3938 (Create working state for recovery)
                    }
                }
                .padding()
                .background(backgroundSecondaryColor())
                .cornerRadius(12)

                // Errors Section
                if !result.errors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Issues Found:")
                            .font(.headline)
                            .foregroundColor(.red)

<<<<<<< HEAD
                        ForEach(Array(result.errors.prefix(5).enumerated()), id: \.offset) { _, error in
=======
                        ForEach(Array(result.errors.prefix(5).enumerated()), id: \.offset) {
                            _, error in
>>>>>>> 1cf3938 (Create working state for recovery)
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
                    #if os(iOS)
<<<<<<< HEAD
                    HapticManager.shared.lightImpact()
=======
                        HapticManager.shared.lightImpact()
>>>>>>> 1cf3938 (Create working state for recovery)
                    #endif
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Import Results")
            #if os(iOS)
<<<<<<< HEAD
            .navigationBarTitleDisplayMode(.inline)
=======
                .navigationBarTitleDisplayMode(.inline)
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }

<<<<<<< HEAD
    private func statRow(label: String, value: String, isError: Bool = false, isWarning: Bool = false) -> some View {
=======
    private func statRow(
        label: String, value: String, isError: Bool = false, isWarning: Bool = false
    ) -> some View {
>>>>>>> 1cf3938 (Create working state for recovery)
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

<<<<<<< HEAD
// MARK: - Supporting Types

struct ImportResult: Sendable {
    let success: Bool
    let transactionsImported: Int
    let accountsImported: Int
    let categoriesImported: Int
    let duplicatesSkipped: Int
    let errors: [String]
}

=======
>>>>>>> 1cf3938 (Create working state for recovery)
#Preview {
    DataImportView()
        .modelContainer(for: [FinancialTransaction.self, FinancialAccount.self])
}

// MARK: - Platform-specific helpers

private func backgroundSecondaryColor() -> Color {
    #if os(iOS)
<<<<<<< HEAD
    return Color(UIColor.systemGray6)
    #else
    return Color(NSColor.windowBackgroundColor).opacity(0.6)
=======
        return Color(UIColor.systemGray6)
    #else
        return Color(NSColor.windowBackgroundColor).opacity(0.6)
>>>>>>> 1cf3938 (Create working state for recovery)
    #endif
}
