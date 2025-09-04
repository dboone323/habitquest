import SwiftUI

struct DataManagementSection: View {
    @Binding var dataRetentionDays: Int
    @Binding var showingDeleteConfirmation: Bool

    var body: some View {
        Section(header: Text("Data Management")) {
            Picker("Keep data for", selection: $dataRetentionDays) {
                Text("30 days").tag(30)
                Text("90 days").tag(90)
                Text("1 year").tag(365)
                Text("Forever").tag(0)
            }

            Button(action: { showingDeleteConfirmation = true }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("Delete All Data")
                        .foregroundColor(.red)
                }
            }
            .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Handle data deletion
                }
            } message: {
                Text("This action cannot be undone. All your financial data will be permanently deleted.")
            }
        }
    }
}
