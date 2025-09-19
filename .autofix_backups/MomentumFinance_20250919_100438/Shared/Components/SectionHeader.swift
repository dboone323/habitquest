import SwiftUI

public struct SectionHeader: View {
    let title: String
    let icon: String

    public init(title: String, icon: String) {
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: self.icon)
                .foregroundColor(.blue)
            Text(self.title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
    }
}
