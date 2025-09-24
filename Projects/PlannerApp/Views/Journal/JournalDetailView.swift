// PlannerApp/Views/Journal/JournalDetailView.swift (Updated)
import SwiftUI

public struct JournalDetailView: View {
    // Access shared ThemeManager
    @EnvironmentObject var themeManager: ThemeManager
    // The specific journal entry to display
    var entry: JournalEntry

    // Read settings if needed (e.g., for date formatting)
    @AppStorage(AppSettingKeys.use24HourTime) private var use24HourTime: Bool = false

    // Formatter for the date displayed prominently in the detail view
    private var detailDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // e.g., April 29, 2025
        formatter.timeStyle = .short // e.g., 1:47 PM or 13:47
        // Set locale based on 24-hour setting
        formatter.locale = Locale(identifier: self.use24HourTime ? "en_GB" : "en_US")
        return formatter
    }

    public var body: some View {
        // Use ScrollView to allow content longer than the screen height
        ScrollView {
            // Main content laid out vertically
            VStack(alignment: .leading, spacing: 15) { // Add spacing between elements
                // Mood Emoji Section
                HStack {
                    Text(self.entry.mood)
                        .font(.system(size: 60)) // Make emoji large
                    Spacer() // Push emoji to the left (or center if desired)
                }

                // Title Section
                Text(self.entry.title)
                    // Apply theme font (primary, large title size, bold) and color
                    .font(self.themeManager.currentTheme.font(
                        forName: self.themeManager.currentTheme.primaryFontName,
                        size: 30,
                        weight: .bold
                    ))
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                // Date Section
                Text(self.entry.date, formatter: self.detailDateFormatter) // Use the detailed formatter
                    // Apply theme font (secondary, smaller size) and color
                    .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.secondaryFontName, size: 16))
                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                // Divider line (uses system/theme appropriate color)
                Divider()

                // Body Text Section
                Text(self.entry.body)
                    // Apply theme font (primary, body size) and color
                    .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.primaryFontName, size: 17))
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                    .lineSpacing(5) // Add extra space between lines for readability
            } // End VStack
            .padding() // Add padding around the entire content VStack
        } // End ScrollView
        .navigationTitle("Entry Details") // Set navigation bar title
        // Apply theme background color to the ScrollView's content area
        .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
        // Apply theme accent color for potential interactive elements (though none here)
        .accentColor(self.themeManager.currentTheme.primaryAccentColor)
    }
}

// --- Preview Provider ---
public struct JournalDetailView_Previews: PreviewProvider {
    public static var previews: some View {
        // Embed in NavigationStack for the preview to show the title bar
        NavigationStack {
            // Create a sample entry for the preview
            JournalDetailView(entry: JournalEntry(
                title: "A Wonderful Day",
                body: "Spent the afternoon reading in the park. The weather was perfect and it felt great to relax and unwind.",
                date: Date(),
                mood: "😊"
            ))
            // Provide the ThemeManager environment object for the preview
            .environmentObject(ThemeManager())
        }
    }
}
