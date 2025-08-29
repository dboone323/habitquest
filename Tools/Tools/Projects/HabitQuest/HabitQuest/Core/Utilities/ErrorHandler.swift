import Foundation
import OSLog
import SwiftUI
import os

/// Centralized error handling for the HabitQuest app
/// Provides consistent error management and user-friendly error messages
struct ErrorHandler: Sendable {

    /// Common error types in the HabitQuest app
    enum HabitQuestError: LocalizedError, @unchecked Sendable {
        case dataModelError(String)
        case gameLogicError(String)
        case validationError(String)
        case networkError(String)
        case unknownError

        nonisolated var errorDescription: String? {
            switch self {
            case .dataModelError(let message):
                return "Data Error: \(message)"
            case .gameLogicError(let message):
                return "Game Logic Error: \(message)"
            case .validationError(let message):
                return "Validation Error: \(message)"
            case .networkError(let message):
                return "Network Error: \(message)"
            case .unknownError:
                return "An unexpected error occurred"
            }
        }

        nonisolated var recoverySuggestion: String? {
            switch self {
            case .dataModelError:
                return "Please try restarting the app or contact support if the problem persists."
            case .gameLogicError:
                return "Please try the action again or restart the app."
            case .validationError:
                return "Please check your input and try again."
            case .networkError:
                return "Please check your internet connection and try again."
            case .unknownError:
                return "Please try again or restart the app."
            }
        }
    }

    private static let logger = Logger(category: .general)

    /// Handle an error with logging and optional user notification
    static func handle(_ error: Error,
                       showToUser: Bool = true,
                       file: String = #file,
                       function: String = #function,
                       line: Int = #line) {

        // Log the error
        logger.error("Error occurred: \(error.localizedDescription)", file: file, function: function, line: line)

        // Additional logging for HabitQuestError
        if let habitError = error as? HabitQuestError {
            logger.error("HabitQuest Error Type: \(habitError)", file: file, function: function, line: line)
        }

        // Handle user notification if needed
        if showToUser {
            // In a real app, this would trigger a user notification
            // For now, we'll just log it
            logger.info("User should be notified of error: \(error.localizedDescription)")
        }
    }

    /// Convert a generic error to a HabitQuestError
    static func wrap(_ error: Error, as type: HabitQuestError) -> HabitQuestError {
        return type
    }

    /// Validate habit input and return validation errors
    static func validateHabit(name: String, description: String) -> HabitQuestError? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .validationError("Habit name cannot be empty")
        }

        if name.count > 100 {
            return .validationError("Habit name cannot exceed 100 characters")
        }

        if description.count > 500 {
            return .validationError("Habit description cannot exceed 500 characters")
        }

        return nil
    }
}
