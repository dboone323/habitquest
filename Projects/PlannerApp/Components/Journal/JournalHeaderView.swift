import SwiftUI

public struct JournalHeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var showAddEntry: Bool

    public var body: some View {
        HStack {
            Spacer()
            Button {
                // Custom edit implementation for macOS
            } label: {
                Text("Edit")
            }
            .accessibilityLabel("Button")

            Button {
                showAddEntry.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

public struct JournalHeaderView_Previews: PreviewProvider {
    public static var previews: some View {
        JournalHeaderView(showAddEntry: .constant(false))
            .environmentObject(ThemeManager())
    }
}
