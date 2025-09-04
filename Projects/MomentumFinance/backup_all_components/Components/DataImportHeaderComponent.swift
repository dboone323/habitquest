import SwiftUI

struct DataImportHeaderComponent: View {
    var body: some View {
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
}

#Preview {
    DataImportHeaderComponent()
}
