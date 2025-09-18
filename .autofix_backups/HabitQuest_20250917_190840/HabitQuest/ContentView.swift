import SwiftData
import SwiftUI

//
//  ContentView.swift
//  HabitQuest - Enhanced Architecture
//
//  Created by Daniel Stevens on 6/27/25.
//  Enhanced: 9/12/25 - Improved architecture with better separation of concerns
//

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    #if canImport(SwiftData)
    @Query private var items: [Item]
    #else
    private var items: [Item] = []
    #endif

    var body: some View {
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
        withAnimation {
            let newItem = Item(timestamp: Date())
            self.modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                self.modelContext.delete(self.items[index])
            }
        }
    }
}

// MARK: - View Components (Extracted for better architecture)

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.blue)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text("HabitQuest")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text("Your Journey Awaits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()

            Divider()
        }
    }
}

struct ItemListView: View {
    let items: [Item]
    let onDelete: (IndexSet) -> Void
    let onAdd: () -> Void

    var body: some View {
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
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .accessibilityLabel("Edit Items")
            }
            ToolbarItem {
                Button(action: self.onAdd) {
                    Label("Add Item", systemImage: "plus")
                }
                .accessibilityLabel("Add New Item")
            }
        }
    }
}

struct ItemRowView: View {
    let item: Item

    var body: some View {
        HStack {
            // Icon based on time of day
            Image(systemName: self.timeBasedIcon)
                .foregroundColor(self.timeBasedColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Quest Entry")
                    .font(.headline)

                Text(self.item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status indicator
            Circle()
                .fill(Color.green.opacity(0.7))
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 2)
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
}

struct ItemDetailView: View {
    let item: Item

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)

                Text("Quest Entry Details")
                    .font(.title2)
                    .fontWeight(.bold)
            }

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
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .navigationTitle("Quest Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(self.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)

            Text(self.value)
                .font(.body)

            Spacer()
        }
    }
}

struct FooterStatsView: View {
    let itemCount: Int

    var body: some View {
        VStack(spacing: 4) {
            Divider()

            HStack {
                Label("\(self.itemCount) entries", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Status indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)

                    Text("Active")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

struct DetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.7))

            VStack(spacing: 8) {
                Text("Welcome to HabitQuest")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Select an item from the sidebar to view details")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
