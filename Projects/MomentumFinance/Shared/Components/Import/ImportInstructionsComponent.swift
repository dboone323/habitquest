import SwiftUI

public struct ImportInstructionsComponent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Instructions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text("Supported format: CSV files with headers")
                }

                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text("Required columns: Date, Description, Amount, Category")
                }

                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text("Date format: YYYY-MM-DD or MM/DD/YYYY")
                }

                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text("Amount format: Use negative values for expenses")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}
