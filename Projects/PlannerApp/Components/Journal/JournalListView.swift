import SwiftUI

public struct JournalListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let filteredEntries: [JournalEntry]
    let searchText: String
    let journalEntries: [JournalEntry]
    let onDeleteEntry: (IndexSet) -> Void

    public var body: some View {
        List {
            if journalEntries.isEmpty {
                JournalEmptyStateView(message: "No journal entries yet. Tap '+' to add one.")
            } else if filteredEntries.isEmpty, !searchText.isEmpty {
                JournalEmptyStateView(message: "No results found for \"\(searchText)\"")
            } else {
                ForEach(filteredEntries) { entry in
                    NavigationLink {
                        JournalDetailView(entry: entry)
                            .environmentObject(themeManager)
                    } label: {
                        JournalRow(entry: entry)
                            .environmentObject(themeManager)
                    }
                }
                .onDelete(perform: onDeleteEntry)
                .listRowBackground(themeManager.currentTheme.secondaryBackgroundColor)
            }
        }
        .background(themeManager.currentTheme.primaryBackgroundColor)
        .scrollContentBackground(.hidden)
    }
}

public struct JournalListView_Previews: PreviewProvider {
    public static var previews: some View {
        let sampleEntries = [
            JournalEntry(title: "Sample Entry", body: "This is a test entry", date: Date(), mood: "😊"),
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
