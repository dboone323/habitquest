import SwiftUI

struct ImportButtonComponent: View {
    let isImporting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue)
                .frame(height: 50)
                .overlay(
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import Data")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ImportButtonComponent(isImporting: false, action: {})
}
