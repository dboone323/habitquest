import Foundation
import Observation
import SwiftUI
import os

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

/// Centralized error handling for the Momentum Finance app
@MainActor
@Observable
final class ErrorHandler {
    var currentError: AppError?
    var isShowingError = false

    // Error recovery options
    var recoveryOptions: [ErrorRecoveryOption] = []

    // Error analytics
    private var errorCounts: [String: Int] = [:]
    private let maxErrorsPerType = 5
    private var lastErrorTime: Date?

    static let shared = ErrorHandler()

    private init() {
        #if DEBUG
        Logger.logDebug("ErrorHandler initialized", category: Logger.ui)
        #endif
    }

    /// Handle an error and optionally show it to the user
    @MainActor
    /// <#Description#>
    /// - Returns: <#description#>
    func handle(
        _ error: Error, showToUser: Bool = true, context: String = "", file: String = #file,
        function: String = #function, line: Int = #line
    ) {
        let appError = AppError.from(error, context: context)

        // Track error frequency
        trackError(appError)

        // Log the error with source information
        Logger.logError(
            appError,
            context:
                "\(context) [\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)]",
            )

        // Determine if this is a frequent error (same type occurring rapidly)
        let isFrequentError = isErrorOccurringFrequently(appError)

        // Generate recovery options based on error type
        let options = generateRecoveryOptions(for: appError)

        if showToUser && !isFrequentError {
            DispatchQueue.main.async {
                self.currentError = appError
                self.recoveryOptions = options
                self.isShowingError = true
            }
        } else if isFrequentError {
            // Log but don't show frequent identical errors to avoid spamming the user
            Logger.logDebug(
                "Suppressing frequent error: \(appError.errorDescription ?? "Unknown")",
                category: Logger.ui,
                )
        }
    }

    /// Clear the current error
    /// <#Description#>
    /// - Returns: <#description#>
    func clearError() {
        DispatchQueue.main.async {
            self.currentError = nil
            self.isShowingError = false
            self.recoveryOptions = []
        }
    }

    /// Track error frequency to avoid spamming users with the same error
    private func trackError(_ error: AppError) {
        let errorKey = error.id
        errorCounts[errorKey, default: 0] += 1
        lastErrorTime = Date()
    }

    /// Check if an error is occurring too frequently (potential issue causing repeated errors)
    private func isErrorOccurringFrequently(_ error: AppError) -> Bool {
        let errorKey = error.id
        let count = errorCounts[errorKey, default: 0]

        // Reset error counts after a period of no errors (10 minutes)
        if let lastTime = lastErrorTime, Date().timeIntervalSince(lastTime) > 600 {
            errorCounts = [:]
            return false
        }

        return count > maxErrorsPerType
    }

    /// Generate recovery options based on error type
    private func generateRecoveryOptions(for error: AppError) -> [ErrorRecoveryOption] {
        var options: [ErrorRecoveryOption] = []

        // Add "Try Again" option for network errors
        if case .networkError = error {
            options.append(
                ErrorRecoveryOption(
                    title: "Try Again",
                    action: {
                        // User would retry the operation that failed
                        Logger.logUI("User selected 'Try Again' for network error")
                        // Implementation depends on the specific context of the error
                    }))
        }

        // Add data repair option for data errors
        if case .dataError = error {
            options.append(
                ErrorRecoveryOption(
                    title: "Repair Data",
                    action: {
                        Logger.logData("User initiated data repair")
                        // Implementation would attempt to fix corrupted data
                    }))
        }

        // Add common options for all errors
        options.append(
            ErrorRecoveryOption(
                title: "Dismiss",
                action: {
                    self.clearError()
                }))

        return options
    }

    /// Report an error to analytics system
    /// <#Description#>
    /// - Returns: <#description#>
    func reportErrorToAnalytics(_ error: AppError) {
        // Here you would integrate with an analytics system like Firebase Crashlytics
        // Example: Crashlytics.record(error: error)

        #if DEBUG
        Logger.logDebug(
            "Error would be reported to analytics: \(error.errorDescription ?? "Unknown")")
        #endif
    }
}

/// Struct to represent error recovery options
struct ErrorRecoveryOption: Identifiable {
    let id = UUID()
    let title: String
    let action: () -> Void
}

/// Application-specific error types
enum AppError: LocalizedError, Identifiable {
    case dataError(String)
    case validationError(String)
    case networkError(String)
    case businessLogicError(String)
    case subscriptionError(String)
    case budgetError(String)
    case goalError(String)
    case permissionError(String)
    case authenticationError(String)
    case syncError(String)
    case fileSystemError(String)
    case unknown(String)

    var id: String {
        switch self {
        case .dataError(let message):
            "data_\(message)"
        case .validationError(let message):
            "validation_\(message)"
        case .networkError(let message):
            "network_\(message)"
        case .businessLogicError(let message):
            "business_\(message)"
        case .subscriptionError(let message):
            "subscription_\(message)"
        case .budgetError(let message):
            "budget_\(message)"
        case .goalError(let message):
            "goal_\(message)"
        case .permissionError(let message):
            "permission_\(message)"
        case .authenticationError(let message):
            "auth_\(message)"
        case .syncError(let message):
            "sync_\(message)"
        case .fileSystemError(let message):
            "file_\(message)"
        case .unknown(let message):
            "unknown_\(message)"
        }
    }

    var errorDescription: String? {
        switch self {
        case .dataError(let message):
            "Data Error: \(message)"
        case .validationError(let message):
            "Validation Error: \(message)"
        case .networkError(let message):
            "Network Error: \(message)"
        case .businessLogicError(let message):
            "Business Logic Error: \(message)"
        case .subscriptionError(let message):
            "Subscription Error: \(message)"
        case .budgetError(let message):
            "Budget Error: \(message)"
        case .goalError(let message):
            "Goal Error: \(message)"
        case .permissionError(let message):
            "Permission Error: \(message)"
        case .authenticationError(let message):
            "Authentication Error: \(message)"
        case .syncError(let message):
            "Sync Error: \(message)"
        case .fileSystemError(let message):
            "File System Error: \(message)"
        case .unknown(let message):
            "Unknown Error: \(message)"
        }
    }

    var failureReason: String? {
        switch self {
        case .dataError:
            "There was a problem with data storage or retrieval."
        case .validationError:
            "The provided information is invalid or incomplete."
        case .networkError:
            "There was a problem with the network connection."
        case .businessLogicError:
            "A business rule was violated."
        case .subscriptionError:
            "There was a problem processing a subscription."
        case .budgetError:
            "There was a problem with budget calculations."
        case .goalError:
            "There was a problem with goal processing."
        case .permissionError:
            "The app doesn't have the required permissions."
        case .authenticationError:
            "There was a problem with authentication."
        case .syncError:
            "There was a problem syncing your data."
        case .fileSystemError:
            "There was a problem accessing files."
        case .unknown:
            "An unexpected error occurred."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .dataError:
            "Try restarting the app or repairing your data."
        case .validationError:
            "Please check your input and try again."
        case .networkError:
            "Check your internet connection and try again."
        case .businessLogicError:
            "This operation couldn't be completed due to a logical conflict."
        case .subscriptionError:
            "Check your subscription details and try again."
        case .budgetError:
            "Try reviewing your budget settings."
        case .goalError:
            "Check your savings goal parameters."
        case .permissionError:
            "Please grant the required permissions in settings."
        case .authenticationError:
            "Please sign in again."
        case .syncError:
            "Try syncing again later."
        case .fileSystemError:
            "Check your device storage space."
        case .unknown:
            "Try restarting the app."
        }
    }

    var isTransient: Bool {
        switch self {
        case .networkError, .syncError:
            true
        default:
            false
        }
    }

    // Convert any error to an AppError
    static func from(_ error: Error, context: String = "") -> AppError {
        // If it's already an AppError, return it
        if let appError = error as? AppError {
            return appError
        }

        // Handle NSError types
        let nsError = error as NSError
        if let nsDomainError = handleNSErrorDomain(nsError, context: context) {
            return nsDomainError
        }

        // Generic error handling based on error type name
        return classifyErrorByName(error, context: context)
    }

    private static func handleNSErrorDomain(_ nsError: NSError, context: String) -> AppError? {
        switch nsError.domain {
        case NSURLErrorDomain:
            .networkError("\(context) \(nsError.localizedDescription)")

        case NSCocoaErrorDomain:
            handleCocoaError(nsError, context: context)

        default:
            nil
        }
    }

    private static func handleCocoaError(_ nsError: NSError, context: String) -> AppError {
        if nsError.code == NSValidationErrorMinimum {
            return .validationError("\(context) \(nsError.localizedDescription)")
        } else if nsError.code == NSFileReadNoSuchFileError
                    || nsError.code == NSFileWriteOutOfSpaceError {
            return .fileSystemError("\(context) \(nsError.localizedDescription)")
        }
        return .dataError("\(context) \(nsError.localizedDescription)")
    }

    private static func classifyErrorByName(_ error: Error, context: String) -> AppError {
        let errorName = String(describing: type(of: error))
        let description = "\(context) \(error.localizedDescription)"

        let errorMappings: [(String, AppError)] = [
            ("Auth", .authenticationError(description)),
            ("Login", .authenticationError(description)),
            ("URL", .networkError(description)),
            ("Network", .networkError(description)),
            ("Connection", .networkError(description)),
            ("Data", .dataError(description)),
            ("Model", .dataError(description)),
            ("SwiftData", .dataError(description)),
            ("Valid", .validationError(description)),
            ("Subscription", .subscriptionError(description)),
            ("Budget", .budgetError(description)),
            ("Goal", .goalError(description)),
            ("Sync", .syncError(description)),
            ("File", .fileSystemError(description)),
            ("Storage", .fileSystemError(description))
        ]

        for (keyword, errorType) in errorMappings where errorName.contains(keyword) {
            return errorType
        }

        return .unknown(description)
    }
}

// MARK: - SwiftUI Error Presentation

struct ErrorAlert: ViewModifier {
    @State var errorHandler = ErrorHandler.shared

    private var alertTitle: String {
        errorHandler.currentError?.errorDescription ?? "Error"
    }

    private var isShowingErrorBinding: Binding<Bool> {
        Binding(
            get: { errorHandler.isShowingError },
            set: { errorHandler.isShowingError = $0 }
        )
    }

    private func alertActions(_ error: Error) -> some View {
        ForEach(errorHandler.recoveryOptions) { option in
            Button(action: {
                option.action()
            }) {
                Text(option.title)
            }
            .accessibilityLabel("Button")
        }
    }

    private func alertMessage(_ error: Error) -> some View {
        Group {
            if let localizedError = error as? LocalizedError {
                if let reason = localizedError.failureReason {
                    Text(reason)
                }
                if let suggestion = localizedError.recoverySuggestion {
                    Text(suggestion)
                }
            } else {
                Text(error.localizedDescription)
            }
        }
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func body(content: Content) -> some View {
        content
            .alert(
                alertTitle,
                isPresented: isShowingErrorBinding,
                presenting: errorHandler.currentError,
                actions: alertActions,
                message: alertMessage
            )
    }
}

extension View {
    /// <#Description#>
    /// - Returns: <#description#>
    func withErrorHandling() -> some View {
        modifier(ErrorAlert())
    }
}
