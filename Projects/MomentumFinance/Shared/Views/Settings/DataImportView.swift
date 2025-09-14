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
                DataImportHeaderComponent()

                if let fileURL = selectedFileURL {
                    selectedFileSection(fileURL)
                } else {
                    FileSelectionComponent(showingFilePicker: $showingFilePicker)
                }

                if isImporting {
                    ImportProgressComponent(progress: importProgress)
                } else if selectedFileURL != nil {
                    ImportButtonComponent(isImporting: isImporting) {
                        Task { await importData() }
                    }
                }

                Spacer()

                ImportInstructionsComponent()
            }
            .padding()
            .navigationTitle("Import Data")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar(content: {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .accessibilityLabel("Cancel")
                }
                #else
                ToolbarItem {
                    Button("Cancel") { dismiss() }
                        .accessibilityLabel("Cancel")
                }
                #endif
            })
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .alert("Import Error", isPresented: .constant(importError != nil)) {
                Button("OK") { importError = nil }
                    .accessibilityLabel("OK")
            } message: {
                if let error = importError { Text(error) }
            }
            .sheet(isPresented: $showingResult) {
                if let result = importResult { ImportResultView(result: result) { dismiss() } }
            }
        }
    }

    private func selectedFileSection(_ fileURL: URL) -> some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
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

                            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey])
                                .fileSize {
                                Text(
                                    "Size: \(ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file))"
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Button("Change") {
                            selectedFileURL = nil
                            showingFilePicker = true
                        }
                        .accessibilityLabel("Change")
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                )
        }
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
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
            #endif
        }
    }

    @MainActor
    private func importData() async {
        guard let fileURL = selectedFileURL else { return }

        isImporting = true
        importProgress = 0
        #if os(iOS)
        HapticManager.shared.mediumImpact()
        #endif

        do {
            let importer = DataImporter(modelContainer: modelContext.container)

            for i in 1...10 {
                try await Task.sleep(nanoseconds: 100_000_000)
                importProgress = Double(i) / 10.0
            }

            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let result = try await importer.importFromCSV(content)
            importResult = result
            showingResult = true
            #if os(iOS)
            HapticManager.shared.success()
            #endif
        } catch {
            importError = error.localizedDescription
            #if os(iOS)
            HapticManager.shared.error()
            #endif
        }

        isImporting = false
        importProgress = 0
    }
}

#Preview {
    DataImportView()
        .modelContainer(for: [FinancialTransaction.self, FinancialAccount.self])
}
