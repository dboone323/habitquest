import SwiftData
import SwiftUI

//
//  ContentView.swift
//  HabitQuest - Enhanced Architecture
//
//  Created by Daniel Stevens on 6/27/25.
//  Enhanced: 9/12/25 - Improved architecture with better separation of concerns
//

public struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    #if canImport(SwiftData)
    @Query private var items: [Item]
    #else
    private var items: [Item] = []
    #endif

    public var body: some View {
        NavigationSplitView {
            // MARK: - Sidebar with Enhanced Navigation

            VStack(alignment: .leading, spacing: 0) {
                // Header Section
                HeaderView()

                // Main Content List
                ItemListView(items: self.items, onDelete: self.deleteItems, onAdd: self.addItem)

                // Footer with Stats
                FooterStatsView(itemCount: self.items.count)
            }
        } detail: {
            DetailView()
        }
    }

    // MARK: - Business Logic (moved to separate functions for better organization)

    private func addItem() {
        do {
            withAnimation {
                let newItem = Item()
                // Insert the new item
                self.modelContext.insert(newItem)
            }
        } catch {
            SecurityFramework.Monitoring.logSecurityEvent(.inputValidationFailed(type: "Item Creation"), details: ["error": error.localizedDescription])
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            // Validate indices before deletion
            let validIndices = offsets.filter { $0 < self.items.count }
            for index in validIndices {
                let item = self.items[index]
                // Delete the item
                self.modelContext.delete(item)
            }
        }
    }
}

// MARK: - View Components (Extracted for better architecture)

public struct HeaderView: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.blue)
                    .font(.title2)
                    .accessibilityHidden(true) // Icon is decorative

                VStack(alignment: .leading) {
                    Text("HabitQuest")
                        .font(.headline)
                        .fontWeight(.bold)
                        .accessibilityLabel("HabitQuest App")
                        .accessibilityHint("Main application title")

                    Text("Your Journey Awaits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Motivational subtitle")
                        .accessibilityHint("Welcome message for the app")
                }

                Spacer()
            }
            .padding()
            .accessibilityElement(children: .combine)
            .accessibilityLabel("HabitQuest Header")
            .accessibilityHint("App title and welcome message")

            Divider()
                .accessibilityHidden(true) // Visual separator, not needed for accessibility
        }
    }
}

public struct ItemListView: View {
    let items: [Item]
    let onDelete: (IndexSet) -> Void
    let onAdd: () -> Void

    public var body: some View {
        List {
            ForEach(self.items) { item in
                NavigationLink {
                    ItemDetailView(item: item)
                } label: {
                    ItemRowView(item: item)
                }
            }
            .onDelete(perform: self.onDelete)
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .accessibilityLabel("Edit Items")
                    .accessibilityHint("Toggle edit mode to delete items")
            }
            #else
            ToolbarItem {
                Button(action: {
                    // For macOS, we could implement custom edit mode
                    // For now, just show a placeholder
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                .accessibilityLabel("Edit Items")
                .accessibilityHint("Toggle edit mode to delete items")
            }
            #endif
            ToolbarItem {
                Button(action: self.onAdd) {
                    Label("Add Item", systemImage: "plus")
                }
                .accessibilityLabel("Add New Item")
                .accessibilityHint("Create a new quest entry")
            }
        }
        .accessibilityLabel("Quest Items List")
        .accessibilityHint("List of your quest entries, tap to view details")
    }
}

public struct ItemRowView: View {
    let item: Item

    public var body: some View {
        HStack {
            // Icon based on time of day
            Image(systemName: self.timeBasedIcon)
                .foregroundColor(self.timeBasedColor)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true) // Icon is decorative, time info is in label

            VStack(alignment: .leading, spacing: 2) {
                Text("Quest Entry")
                    .font(.headline)
                    .accessibilityLabel("Quest Entry")

                Text(self.item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Created \(self.item.timestamp.formatted(date: .abbreviated, time: .shortened))")
            }

            Spacer()

            // Status indicator
            Circle()
                .fill(Color.green.opacity(0.7))
                .frame(width: 8, height: 8)
                .accessibilityLabel("Completed quest")
                .accessibilityHint("This quest entry is marked as completed")
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Quest Entry from \(self.timeOfDayDescription)")
        .accessibilityHint("Tap to view quest details")
        .accessibilityValue("Status: Completed")
    }

    private var timeBasedIcon: String {
        let hour = Calendar.current.component(.hour, from: self.item.timestamp)
        switch hour {
        case 6 ..< 12: return "sunrise.fill"
        case 12 ..< 18: return "sun.max.fill"
        case 18 ..< 22: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }

    private var timeBasedColor: Color {
        let hour = Calendar.current.component(.hour, from: self.item.timestamp)
        switch hour {
        case 6 ..< 12: return .orange
        case 12 ..< 18: return .yellow
        case 18 ..< 22: return .red
        default: return .purple
        }
    }

    private var timeOfDayDescription: String {
        let hour = Calendar.current.component(.hour, from: self.item.timestamp)
        switch hour {
        case 6 ..< 12: return "morning"
        case 12 ..< 18: return "afternoon"
        case 18 ..< 22: return "evening"
        default: return "night"
        }
    }
}

public struct ItemDetailView: View {
    let item: Item

    public var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .accessibilityHidden(true) // Decorative icon

                Text("Quest Entry Details")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityLabel("Quest Entry Details")
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Quest entry details header")

            // Details Card
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(
                    title: "Created",
                    value: self.item.timestamp.formatted(date: .complete, time: .shortened)
                )

                DetailRow(
                    title: "Type",
                    value: "Quest Log Entry"
                )

                DetailRow(
                    title: "Status",
                    value: "Completed"
                )
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Quest information card")
            .accessibilityHint("Contains details about the quest entry including creation time, type, and status")

            Spacer()
        }
        .padding()
        .navigationTitle("Quest Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Detailed view of quest entry")
    }
}

public struct DetailRow: View {
    let title: String
    let value: String

    public var body: some View {
        HStack {
            Text(self.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
                .accessibilityLabel("\(self.title) label")

            Text(self.value)
                .font(.body)
                .accessibilityLabel("\(self.title): \(self.value)")

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(self.title): \(self.value)")
        .accessibilityHint("Quest detail information")
    }
}

public struct FooterStatsView: View {
    let itemCount: Int

    public var body: some View {
        VStack(spacing: 4) {
            Divider()
                .accessibilityHidden(true) // Visual separator, not needed for accessibility

            HStack {
                Label("\(self.itemCount) entries", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Total quest entries: \(self.itemCount)")
                    .accessibilityHint("Number of quest entries in the list")

                Spacer()

                // Status indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                        .accessibilityLabel("Active status indicator")

                    Text("Active")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Application status: Active")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Application status: Active")
                .accessibilityHint("The application is currently active and running")
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Footer statistics")
    }
}

public struct DetailView: View {
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.7))
                .accessibilityHidden(true) // Decorative icon

            VStack(spacing: 8) {
                Text("Welcome to HabitQuest")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityLabel("Welcome to HabitQuest")

                Text("Select an item from the sidebar to view details")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Select an item from the sidebar to view details")
                    .accessibilityHint("Use the sidebar on the left to choose a quest entry to view")
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Welcome message and instructions")

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Welcome screen")
        .accessibilityHint("Main welcome view for HabitQuest application")
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
