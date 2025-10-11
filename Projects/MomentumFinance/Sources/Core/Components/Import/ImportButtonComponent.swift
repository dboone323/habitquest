import SwiftUI

public struct ImportButtonComponent: View {
    let isImporting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action).accessibilityLabel("Button").accessibilityLabel("Button") {
            HStack {
                if self.isImporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "square.and.arrow.down")
                }

                Text(self.isImporting ? "Importing..." : "Import Data")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(self.isImporting ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(self.isImporting)
    }
}
