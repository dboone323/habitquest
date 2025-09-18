import Foundation

// Intentionally left blank.
// Data manager types were moved into dedicated files (e.g., GoalDataManager, TaskDataManager).


// DataManagers.swift
// This file contains stub implementations for data managers referenced in CloudKitMigrationHelper

import Foundation
import CloudKit

// DataManagers.swift is now empty. Data manager classes have been split into separate files for better type resolution and Xcode compatibility.

    /// Saves the provided journal entries to memory.
    /// - Parameter entries: Array of `JournalEntry` objects to save.
    func save(entries: [JournalEntry]) {
        self.entries = entries
    }

    /// Private initializer to enforce singleton usage.
    private init() {}
}
