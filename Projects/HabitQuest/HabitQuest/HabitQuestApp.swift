import SwiftData
import SwiftUI

//
//  HabitQuestApp.swift
//  HabitQuest
//
//  Created by Daniel Stevens on 6/27/25.
//

@main
public struct HabitQuestApp: App {
    @State private var showDatabaseError = false
    @State private var databaseError: Error?

    public init() {}

    var sharedModelContainer: ModelContainer? = {
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
                // Return nil to trigger error UI
                return nil
            }
        }
    }()

    public var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                AppMainView()
                    .modelContainer(container)
            } else {
                // Show error view when database initialization fails
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)

                    Text("Database Error")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Unable to initialize the app database. Your data may not be saved properly.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Continue (Data may not persist)") {
                        // Continue with limited functionality
                        // In a real app, this might show a read-only mode
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Quit App") {
                        #if os(iOS)
                        // iOS doesn't allow programmatic termination
                        #else
                        NSApplication.shared.terminate(nil)
                        #endif
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
