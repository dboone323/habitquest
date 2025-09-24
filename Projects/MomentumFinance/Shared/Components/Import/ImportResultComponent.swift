import SwiftUI

public struct ImportResultView: View {
    let result: ImportResult
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: self.result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(self.result.success ? .green : .orange)

            Text(self.result.success ? "Import Successful" : "Import Completed with Issues")
                .font(.title2)
                .fontWeight(.bold)

            Text("Imported \(self.result.transactionsImported) transactions")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Done", action: self.onDismiss).accessibilityLabel("Button").accessibilityLabel("Button")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding()
    }
}
