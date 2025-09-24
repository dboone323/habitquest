import SwiftUI

public struct DataImportHeaderComponent: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Import Financial Data")
                .font(.title2)
                .fontWeight(.bold)

            Text("Import your financial data from CSV files")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
}
