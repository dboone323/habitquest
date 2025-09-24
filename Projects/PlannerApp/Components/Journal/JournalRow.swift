import SwiftUI

public struct JournalRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let entry: JournalEntry

    private var rowDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.entry.title)
                    .font(
                        self.themeManager.currentTheme.font(
                            forName: self.themeManager.currentTheme.primaryFontName, size: 17,
                            weight: .medium
                        )
                    )
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                    .lineLimit(1)
                Text(self.entry.date, formatter: self.rowDateFormatter)
                    .font(
                        self.themeManager.currentTheme.font(
                            forName: self.themeManager.currentTheme.secondaryFontName, size: 14
                        )
                    )
                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                Text(self.entry.body)
                    .font(
                        self.themeManager.currentTheme.font(
                            forName: self.themeManager.currentTheme.secondaryFontName, size: 13
                        )
                    )
                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor.opacity(0.8))
                    .lineLimit(1)
            }
            Spacer()
            Text(self.entry.mood)
                .font(.system(size: 30))
        }
        .padding(.vertical, 5)
    }
}

public struct JournalRow_Previews: PreviewProvider {
    public static var previews: some View {
        JournalRow(entry: JournalEntry(title: "Sample Entry", body: "This is a test entry", date: Date(), mood: "😊"))
            .environmentObject(ThemeManager())
    }
}
