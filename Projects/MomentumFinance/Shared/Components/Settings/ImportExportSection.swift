import SwiftData
import SwiftUI

public struct ImportExportSection: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var exportURL: URL?
    @State private var importResult: ImportResult?
    @State private var showingImportResult = false
    @State private var isExporting = false
    @State private var isImporting = false

    var body: some View {
        Section(header: Text("Import & Export")) {
            Button(action: {
                self.showingExportSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Data")
                    Spacer()
                    if self.isExporting {
                        ProgressView()
                    }
                }
            }
            .disabled(self.isExporting)

            Button(action: {
                self.showingImportPicker = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import Data")
                    Spacer()
                    if self.isImporting {
                        ProgressView()
                    }
                }
            }
            .disabled(self.isImporting)
        }
        .sheet(isPresented: self.$showingExportSheet) {
            ExportDataView(
                isPresented: self.$showingExportSheet,
                exportURL: self.$exportURL,
                isExporting: self.$isExporting
            )
        }
        .sheet(isPresented: self.$showingImportPicker) {
            ImportDataView(
                isPresented: self.$showingImportPicker,
                importResult: self.$importResult,
                showingResult: self.$showingImportResult,
                isImporting: self.$isImporting
            )
        }
        .sheet(isPresented: self.$showingImportResult) {
            if let result = importResult {
                ImportResultView(result: result, isPresented: self.$showingImportResult)
            }
        }
        .onChange(of: self.exportURL) { _, newURL in
            if let url = newURL {
                self.shareExportedFile(url)
            }
        }
    }

    private func shareExportedFile(_ url: URL) {
        #if os(iOS)
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        #else
        // On macOS, you might want to show a save panel or open the file
        NSWorkspace.shared.open(url)
        #endif
    }
}
