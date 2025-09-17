// PlannerApp/Views/Journal/JournalView.swift (Biometrics Removed - v10)
import SwiftUI

// Removed LocalAuthentication import

struct JournalView: View {
    // Access shared ThemeManager and data/settings
    @EnvironmentObject var themeManager: ThemeManager
    @State private var journalEntries: [JournalEntry] = []
    @State private var showAddEntry = false
    @State private var searchText = ""

    // --- Security State REMOVED ---
    // @AppStorage(AppSettingKeys.journalBiometricsEnabled) private var biometricsEnabled: Bool = false
    // @State private var isUnlocked: Bool = true // Assume always unlocked now
    // @State private var showingAuthenticationError = false
    // @State private var authenticationErrorMsg = ""
    // @State private var isAuthenticating = false

    // Filtered and sorted entries
    private var filteredEntries: [JournalEntry] {
        let sorted = self.journalEntries.sorted(by: { $0.date > $1.date })
        if self.searchText.isEmpty { return sorted }
        return sorted.filter {
            $0.title.localizedCaseInsensitiveContains(self.searchText)
                || $0.body.localizedCaseInsensitiveContains(self.searchText)
                || $0.mood.contains(self.searchText)
        }
    }

    // Removed init() related to isUnlocked state

    var body: some View {
        NavigationStack {
            // Directly show journal content, bypassing lock checks
            self.journalContent
                .navigationTitle("Journal")
                .toolbar {
                    // Always show toolbar items
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            self.showAddEntry.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigation) {
                        Button("Edit") {
                            // Custom edit implementation for macOS
                        }
                        .accessibilityLabel("Button")
                    }
                }
                .sheet(isPresented: self.$showAddEntry) {
                    AddJournalEntryView(journalEntries: self.$journalEntries)
                        .environmentObject(self.themeManager) // Pass ThemeManager
                        .onDisappear(perform: self.saveEntries)
                }
                .onAppear {
                    print("[JournalView Simplified] onAppear.")
                    // Only load entries
                    self.loadEntries()
                }
                // Apply theme accent color to toolbar items
                .accentColor(self.themeManager.currentTheme.primaryAccentColor)
            // Removed alert for authentication errors
        } // End NavigationStack
        // Removed .onChange(of: biometricsEnabled)
    }

    // --- View Builder for Journal Content ---
    @ViewBuilder
    private var journalContent: some View {
        VStack(spacing: 0) {
            List {
                if self.journalEntries.isEmpty {
                    self.makeEmptyStateText("No journal entries yet. Tap '+' to add one.")
                } else if self.filteredEntries.isEmpty, !self.searchText.isEmpty {
                    self.makeEmptyStateText("No results found for \"\(self.searchText)\"")
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
                    .onDelete(perform: self.deleteEntry) // Use the updated deleteEntry function
                    .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
                }
            }
            .background(self.themeManager.currentTheme.primaryBackgroundColor)
            .scrollContentBackground(.hidden)
            .searchable(text: self.$searchText, prompt: "Search Entries")
        }
        .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
    }

    // Helper for empty state text (Unchanged)
    private func makeEmptyStateText(_ text: String) -> some View {
        Text(text)
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

    // --- View Builder for Locked State (REMOVED) ---

    // --- Authentication Function (REMOVED) ---

    // --- Data Functions ---
    private func deleteEntry(at offsets: IndexSet) {
        print("[JournalView Simplified] deleteEntry called with offsets: \(offsets)")
        let idsToDelete = offsets.map { offset -> UUID in
            return self.filteredEntries[offset].id
        }
        print("[JournalView Simplified] IDs to delete: \(idsToDelete)")
        self.journalEntries.removeAll { entry in
            idsToDelete.contains(entry.id)
        }
        self.saveEntries()
    }

    private func loadEntries() {
        print("[JournalView Simplified] loadEntries called")
        self.journalEntries = JournalDataManager.shared.load()
        print("[JournalView Simplified] Loaded \(self.journalEntries.count) entries.")
    }

    private func saveEntries() {
        print("[JournalView Simplified] saveEntries called")
        JournalDataManager.shared.save(entries: self.journalEntries)
    }
}

// --- JournalRow Subview (Unchanged) ---
struct JournalRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let entry: JournalEntry

    private var rowDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
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

// --- Preview Provider (Unchanged) ---
struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .environmentObject(ThemeManager())
    }
}
