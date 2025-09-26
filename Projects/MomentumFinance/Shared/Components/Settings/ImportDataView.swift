import SwiftData
import SwiftUI
import UniformTypeIdentifiers

public struct ImportDataView: View {
    @Binding var isPresented: Bool
    @Binding var importResult: ImportResult?
    @Binding var showingResult: Bool
    @Binding var isImporting: Bool
    @Environment(\.modelContext) private var modelContext

    @State private var selectedFileURL: URL?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Import Financial Data")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(
                    "Select a CSV file containing your transaction data. The file should include columns for date, title, amount, and optionally type, category, and account."
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    self.selectFile()
                }) {
                    HStack {
                        Image(systemName: "folder")
                        Text(self.selectedFileURL?.lastPathComponent ?? "Choose CSV File")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)

                if let url = selectedFileURL {
                    Text("Selected: \(url.lastPathComponent)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    Task {
                        await self.performImport()
                    }
                }) {
                    HStack {
                        if self.isImporting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(self.isImporting ? "Importing..." : "Import Data")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(self.selectedFileURL == nil || self.isImporting ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(self.selectedFileURL == nil || self.isImporting)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.isPresented = false
                }
            )
        }
        .presentationDetents([.medium])
    }

    private func selectFile() {
        #if os(iOS)
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.commaSeparatedText])
        picker.allowsMultipleSelection = false
        picker.delegate = DocumentPickerDelegate { url in
            self.selectedFileURL = url
        }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(picker, animated: true)
        }
        #else
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.commaSeparatedText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            self.selectedFileURL = url
        }
        #endif
    }

    private func performImport() async {
        guard let fileURL = selectedFileURL else { return }

        self.isImporting = true
        defer { isImporting = false }

        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let importer = DataImporter(modelContainer: modelContext.container)
            let result = try await importer.importFromCSV(content)

            self.importResult = result
            self.showingResult = true
            self.isPresented = false
        } catch {
            self.importResult = ImportResult(
                success: false,
                itemsImported: 0,
                errors: ["Failed to read file: \(error.localizedDescription)"],
                warnings: []
            )
            self.showingResult = true
            self.isPresented = false
        }
    }
}

#if os(iOS)
class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    let completion: (URL) -> Void

    init(completion: @escaping (URL) -> Void) {
        self.completion = completion
    }

    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            self.completion(url)
        }
    }
}
#endif
