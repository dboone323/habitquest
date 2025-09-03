import SwiftData
import SwiftUI

//
//  HabitQuestApp.swift
//  HabitQuest
//
//  Created by Daniel Stevens on 6/27/25.
//

@main
struct HabitQuestApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitLog.self,
            PlayerProfile.self,
            Achievement.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            // Create a fallback in-memory container for testing
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                print("❌ Failed to create fallback ModelContainer: \(error)")
                fatalError("Could not create any ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppMainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
