import SwiftUI

struct ImportInstructionsComponent: View {
    var body: some View {
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
        }
    }
}

#Preview {
    ImportInstructionsComponent()
}
