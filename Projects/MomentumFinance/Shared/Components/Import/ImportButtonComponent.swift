import SwiftUI

struct ImportButtonComponent: View {
    let isImporting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isImporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "square.and.arrow.down")
                }

                Text(isImporting ? "Importing..." : "Import Data")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isImporting ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isImporting)
    }
}
