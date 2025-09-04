// DataManagers.swift
// This file contains stub implementations for data managers referenced in CloudKitMigrationHelper

import Foundation

// Task Data Manager
class TaskDataManager {
    static let shared = TaskDataManager()

    var tasks: [Task] = []

    func clearAllTasks() {
        tasks.removeAll()
    }

    func load() -> [Task] {
        tasks
    }

    func save(tasks: [Task]) {
        self.tasks = tasks
    }

    private init() {}
}

// Goal Data Manager
class GoalDataManager {
    static let shared = GoalDataManager()

    var goals: [Goal] = []

    func clearAllGoals() {
        goals.removeAll()
    }

    func load() -> [Goal] {
        goals
    }

    func save(goals: [Goal]) {
        self.goals = goals
    }

    private init() {}
}

// Calendar Data Manager
class CalendarDataManager {
    static let shared = CalendarDataManager()

    var events: [CalendarEvent] = []

    func clearAllEvents() {
        events.removeAll()
    }

    func load() -> [CalendarEvent] {
        events
    }

    func save(events: [CalendarEvent]) {
        self.events = events
    }

    private init() {}
}

// Journal Data Manager
class JournalDataManager {
    static let shared = JournalDataManager()

    var entries: [JournalEntry] = []

    func clearAllEntries() {
        entries.removeAll()
    }

    func load() -> [JournalEntry] {
        entries
    }

    func save(entries: [JournalEntry]) {
        self.entries = entries
    }

    private init() {}
}
