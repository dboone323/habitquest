import SwiftUI

public struct JournalEmptyStateView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let message: String

    public var body: some View {
        Text(self.message)
            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
            .font(
                self.themeManager.currentTheme.font(
                    forName: self.themeManager.currentTheme.secondaryFontName, size: 15
                )
            )
            .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical)
    }
}

public struct JournalEmptyStateView_Previews: PreviewProvider {
    public static var previews: some View {
        JournalEmptyStateView(message: "No journal entries yet. Tap '+' to add one.")
            .environmentObject(ThemeManager())
    }
}
