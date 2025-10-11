import SwiftUI

public struct ImportResultView: View {
    let result: ImportResult
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: self.result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(self.result.success ? .green : .orange)

                Text(self.result.success ? "Import Successful" : "Import Completed with Issues")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Items imported: \(self.result.itemsImported)")
                        .font(.headline)

                    if !self.result.errors.isEmpty {
                        Text("Errors (\(self.result.errors.count)):")
                            .font(.headline)
                            .foregroundColor(.red)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(self.result.errors, id: \.self) { error in
                                    Text("• \(error)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .frame(maxHeight: 100)
                    }

                    if !self.result.warnings.isEmpty {
                        Text("Warnings (\(self.result.warnings.count)):")
                            .font(.headline)
                            .foregroundColor(.orange)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(self.result.warnings, id: \.self) { warning in
                                    Text("• \(warning)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .frame(maxHeight: 100)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Spacer()

                Button("Done") {
                    self.isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Close") {
                    self.isPresented = false
                }
            )
        }
        .presentationDetents([.medium])
    }
}
