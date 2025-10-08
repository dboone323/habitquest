//
//  Item.swift
//  HabitQuest
//
//  Created by Daniel Stevens on 6/27/25.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable, Validatable {
    var id: UUID
    var timestamp: Date
    var title: String
    var notes: String?
    var isCompleted: Bool
    var priority: Priority
    var category: String?

    // Security-related properties
    var createdBy: String?
    var lastModified: Date
    var dataHash: Data?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        title: String = "",
        notes: String? = nil,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        category: String? = nil,
        createdBy: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.createdBy = createdBy
        self.lastModified = Date()

        // Generate data hash for integrity checking
        self.dataHash = self.generateDataHash()
    }

    // MARK: - Validation

    var isValid: Bool {
        validationErrors.isEmpty
    }

    var validationErrors: [ValidationError] {
        var errors: [ValidationError] = []

        // Validate title
        let titleValidation = SecurityFramework.Validation.validateStringInput(
            title,
            maxLength: 200,
            allowedCharacters: .alphanumerics.union(.whitespacesAndNewlines).union(CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?"))
        )
        if case .failure(let error) = titleValidation {
            errors.append(.invalidTitle(error.localizedDescription))
        }

        // Validate notes if present
        if let notes = notes {
            let notesValidation = SecurityFramework.Validation.validateStringInput(
                notes,
                maxLength: 1000
            )
            if case .failure(let error) = notesValidation {
                errors.append(.invalidNotes(error.localizedDescription))
            }
        }

        // Validate category if present
        if let category = category {
            let categoryValidation = SecurityFramework.Validation.validateStringInput(
                category,
                maxLength: 50
            )
            if case .failure(let error) = categoryValidation {
                errors.append(.invalidCategory(error.localizedDescription))
            }
        }

        // Validate timestamp is not in future
        if timestamp > Date().addingTimeInterval(300) { // Allow 5 minute clock skew
            errors.append(.invalidTimestamp)
        }

        return errors
    }

    // MARK: - Security Methods

    /// Generates a hash of the item's data for integrity checking
    private func generateDataHash() -> Data {
        let dataString = "\(id.uuidString)\(timestamp.ISO8601Format())\(title)\(notes ?? "")\(isCompleted)\(priority.rawValue)\(category ?? "")"
        return SecurityFramework.Crypto.sha256(dataString)
    }

    /// Verifies data integrity by comparing current hash with stored hash
    func verifyIntegrity() -> Bool {
        guard let storedHash = dataHash else { return false }
        let currentHash = generateDataHash()
        return storedHash == currentHash
    }

    /// Updates the item with security validation
    func updateSecurely(
        title: String? = nil,
        notes: String? = nil,
        isCompleted: Bool? = nil,
        priority: Priority? = nil,
        category: String? = nil
    ) throws {
        if let title = title {
            self.title = title
        }
        if let notes = notes {
            self.notes = notes
        }
        if let isCompleted = isCompleted {
            self.isCompleted = isCompleted
        }
        if let priority = priority {
            self.priority = priority
        }
        if let category = category {
            self.category = category
        }

        self.lastModified = Date()

        // Validate before updating hash
        guard self.isValid else {
            throw ValidationError.invalidData
        }

        // Update hash for integrity checking
        self.dataHash = self.generateDataHash()
    }

    // MARK: - Priority Enum

    enum Priority: String, Codable, CaseIterable {
        case low, medium, high, urgent
    }

    // MARK: - Validation Error Types

    enum ValidationError: Error, LocalizedError {
        case invalidTitle(String)
        case invalidNotes(String)
        case invalidCategory(String)
        case invalidTimestamp
        case invalidData

        var errorDescription: String? {
            switch self {
            case .invalidTitle(let reason):
                return "Invalid title: \(reason)"
            case .invalidNotes(let reason):
                return "Invalid notes: \(reason)"
            case .invalidCategory(let reason):
                return "Invalid category: \(reason)"
            case .invalidTimestamp:
                return "Timestamp cannot be in the future"
            case .invalidData:
                return "Item data validation failed"
            }
        }
    }
}

// MARK: - Validatable Protocol

protocol Validatable {
    var isValid: Bool { get }
    var validationErrors: [Item.ValidationError] { get }
}
