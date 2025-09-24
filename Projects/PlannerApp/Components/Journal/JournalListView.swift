import SwiftUI

public struct JournalListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let filteredEntries: [JournalEntry]
    let searchText: String
    let journalEntries: [JournalEntry]
    let onDeleteEntry: (IndexSet) -> Void

    public var body: some View {
        List {
            if self.journalEntries.isEmpty {
                JournalEmptyStateView(message: "No journal entries yet. Tap '+' to add one.")
            } else if self.filteredEntries.isEmpty, !self.searchText.isEmpty {
                JournalEmptyStateView(message: "No results found for \"\(self.searchText)\"")
            } else {
                ForEach(self.filteredEntries) { entry in
                    NavigationLink {
                        JournalDetailView(entry: entry)
                            .environmentObject(self.themeManager)
                    } label: {
                        JournalRow(entry: entry)
                            .environmentObject(self.themeManager)
                    }
                }
                .onDelete(perform: self.onDeleteEntry)
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
            }
        }
        .background(self.themeManager.currentTheme.primaryBackgroundColor)
        .scrollContentBackground(.hidden)
    }
}

public struct JournalListView_Previews: PreviewProvider {
    public static var previews: some View {
        let sampleEntries = [
            JournalEntry(title: "Sample Entry", body: "This is a test entry", date: Date(), mood: "😊")
        ]
        JournalListView(
            filteredEntries: sampleEntries,
            searchText: "",
            journalEntries: sampleEntries,
            onDeleteEntry: { _ in }
        )
        .environmentObject(ThemeManager())
    }
}
