import SwiftData
import SwiftUI

//
//  ContentView.swift
//  HabitQuest
//
//  Created by Daniel Stevens on 6/27/25.
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
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text(
                            "Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))"
                        )
                    } label: {
                        Text(
                            item.timestamp,
                            format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
