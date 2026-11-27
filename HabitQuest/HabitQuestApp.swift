import HabitQuestCore
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
    @StateObject private var themeManager = ThemeManager()

    public init() {}

    private let containerResult: SharedModelContainer.ContainerResult? = {
        do {
            return try SharedModelContainer.createContainerWithMigrationStatus(inMemoryOnly: false)
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            do {
                return try SharedModelContainer.createContainerWithMigrationStatus(inMemoryOnly: true)
            } catch {
                print("❌ Failed to create fallback ModelContainer: \(error)")
                return nil
            }
        }
    }()

    var sharedModelContainer: ModelContainer? {
        containerResult?.container
    }

    public var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                AppMainView()
                    .modelContainer(container)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.isSystem ? nil : themeManager.colorScheme)
                    .appAccessibilityDefaults()
                    .onAppear {
                        HabitQuestLifecycleCoordinator.configureOnLaunch()
                        ensureDefaultPlayerProfile(in: container.mainContext)
                        if let migrationError = containerResult?.migrationError {
                            databaseError = migrationError
                            showDatabaseError = true
                        }
                    }
                    .alert("Storage Migration Issue", isPresented: $showDatabaseError) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(
                            "Could not migrate your data to shared widget storage ("
                                + (databaseError?.localizedDescription ?? "Unknown error")
                                + "). Your existing local data is still active and safe."
                        )
                    }
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

    @MainActor
    private func ensureDefaultPlayerProfile(in context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<PlayerProfile>()
            let existing = try context.fetch(descriptor)
            if existing.isEmpty {
                let profile = PlayerProfile()
                context.insert(profile)
                try context.save()
            }
        } catch {
            print("❌ Failed to ensure default player profile: \(error)")
        }
    }
}
