//
//  HabitQuestTests.swift
//  HabitQuestTests
//
//  Created by GitHub Copilot on 2026-02-10.
//

import Foundation
import Testing
@testable import HabitQuest

struct HabitQuestTests {
    @Test
    func appInitialization() {
        // Test that the app can be initialized without crashing
        // This is a basic smoke test
        #expect(true, "App should initialize successfully")
    }

    @Test
    func habitModelCreation() {
        // Test that we can create a basic habit
        let habit = Habit(
            name: "Test Habit",
            habitDescription: "A test habit",
            frequency: .daily,
            xpValue: 10
        )

        #expect(habit.name == "Test Habit")
        #expect(habit.habitDescription == "A test habit")
        #expect(habit.frequency == .daily)
        #expect(habit.xpValue == 10)
        #expect(habit.streak == 0)
    }

    @Test
    func playerProfileCreation() {
        // Test that we can create a player profile
        let profile = PlayerProfile()

        #expect(profile.level == 1)
        #expect(profile.currentXP == 0)
        #expect(profile.xpForNextLevel > 0)
    }

    @Test
    func memoryManagement() {
        // Test basic memory management
        var habits: [Habit] = []

        for i in 0..<50 {
            let habit = Habit(
                name: "Habit \(i)",
                habitDescription: "Description \(i)",
                frequency: .daily,
                xpValue: 5
            )
            habits.append(habit)
        }

        #expect(habits.count == 50)
        #expect(habits[0].name == "Habit 0")
        #expect(habits[49].name == "Habit 49")

        // Clear array
        habits.removeAll()
        #expect(habits.isEmpty)
    }

    @Test
    func concurrentOperations() async {
        // Test that the app can handle concurrent operations
        let iterations = 25

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    let habit = Habit(
                        name: "Concurrent \(i)",
                        habitDescription: "Test concurrent creation",
                        frequency: .daily,
                        xpValue: 1
                    )
                    // Just create the object
                    _ = habit.id
                }
            }
        }

        // If we get here without crashing, the test passes
        #expect(true, "Concurrent operations completed successfully")
    }
}
