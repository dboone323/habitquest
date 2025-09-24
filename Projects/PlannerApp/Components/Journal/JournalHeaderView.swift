import SwiftUI

public struct JournalHeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var showAddEntry: Bool

    public var body: some View {
        HStack {
            Spacer()
            Button(action: {
                // Custom edit implementation for macOS
            }) {
                Text("Edit")
            }
            .accessibilityLabel("Button")

            Button {
                self.showAddEntry.toggle()
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
