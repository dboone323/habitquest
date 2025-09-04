import SwiftUI

struct ImportResultView: View {
    let result: ImportResult
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(result.success ? .green : .orange)

            Text(result.success ? "Import Successful" : "Import Completed with Issues")
                .font(.title2)
                .fontWeight(.bold)

            Text("Imported \(result.transactionsImported) transactions")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Done", action: onDismiss)
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
