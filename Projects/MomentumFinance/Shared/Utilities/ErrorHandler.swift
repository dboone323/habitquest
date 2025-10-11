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
    /// <#Description#>
    /// - Returns: <#description#>
    @MainActor
    func handle(
        _ error: Error, showToUser: Bool = true, context: String = "", file: String = #file,
        function: String = #function, line: Int = #line
    ) {
        let appError = AppError.from(error, context: context)

        // Track error frequency
        self.trackError(appError)

        // Log the error with source information
        Logger.logError(
            appError,
            context:
            "\(context) [\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)]",
        )

        // Determine if this is a frequent error (same type occurring rapidly)
        let isFrequentError = self.isErrorOccurringFrequently(appError)

        // Generate recovery options based on error type
        let options = self.generateRecoveryOptions(for: appError)

        if showToUser, !isFrequentError {
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
        self.errorCounts[errorKey, default: 0] += 1
        self.lastErrorTime = Date()
    }

    /// Check if an error is occurring too frequently (potential issue causing repeated errors)
    private func isErrorOccurringFrequently(_ error: AppError) -> Bool {
        let errorKey = error.id
        let count = self.errorCounts[errorKey, default: 0]

        // Reset error counts after a period of no errors (10 minutes)
        if let lastTime = lastErrorTime, Date().timeIntervalSince(lastTime) > 600 {
            self.errorCounts = [:]
            return false
        }

        return count > self.maxErrorsPerType
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
                    }
                )
            )
        }

        // Add data repair option for data errors
        if case .dataError = error {
            options.append(
                ErrorRecoveryOption(
                    title: "Repair Data",
                    action: {
                        Logger.logData("User initiated data repair")
                        // Implementation would attempt to fix corrupted data
                    }
                )
            )
        }

        // Add common options for all errors
        options.append(
            ErrorRecoveryOption(
                title: "Dismiss",
                action: {
                    self.clearError()
                }
            )
        )

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
            "Error would be reported to analytics: \(error.errorDescription ?? "Unknown")"
        )
        #endif
    }
}

/// Struct to represent error recovery options
public struct ErrorRecoveryOption: Identifiable {
    public let id = UUID()
    let title: String
    let action: () -> Void
}

/// Application-specific error types
public enum AppError: LocalizedError, Identifiable {
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

    public var id: String {
        switch self {
        case let .dataError(message):
            "data_\(message)"
        case let .validationError(message):
            "validation_\(message)"
        case let .networkError(message):
            "network_\(message)"
        case let .businessLogicError(message):
            "business_\(message)"
        case let .subscriptionError(message):
            "subscription_\(message)"
        case let .budgetError(message):
            "budget_\(message)"
        case let .goalError(message):
            "goal_\(message)"
        case let .permissionError(message):
            "permission_\(message)"
        case let .authenticationError(message):
            "auth_\(message)"
        case let .syncError(message):
            "sync_\(message)"
        case let .fileSystemError(message):
            "file_\(message)"
        case let .unknown(message):
            "unknown_\(message)"
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .dataError(message):
            "Data Error: \(message)"
        case let .validationError(message):
            "Validation Error: \(message)"
        case let .networkError(message):
            "Network Error: \(message)"
        case let .businessLogicError(message):
            "Business Logic Error: \(message)"
        case let .subscriptionError(message):
            "Subscription Error: \(message)"
        case let .budgetError(message):
            "Budget Error: \(message)"
        case let .goalError(message):
            "Goal Error: \(message)"
        case let .permissionError(message):
            "Permission Error: \(message)"
        case let .authenticationError(message):
            "Authentication Error: \(message)"
        case let .syncError(message):
            "Sync Error: \(message)"
        case let .fileSystemError(message):
            "File System Error: \(message)"
        case let .unknown(message):
            "Unknown Error: \(message)"
        }
    }

    public var failureReason: String? {
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

    public var recoverySuggestion: String? {
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
        return self.classifyErrorByName(error, context: context)
    }

    private static func handleNSErrorDomain(_ nsError: NSError, context: String) -> AppError? {
        switch nsError.domain {
        case NSURLErrorDomain:
            .networkError("\(context) \(nsError.localizedDescription)")

        case NSCocoaErrorDomain:
            self.handleCocoaError(nsError, context: context)

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
            ("Storage", .fileSystemError(description)),
        ]

        for (keyword, errorType) in errorMappings where errorName.contains(keyword) {
            return errorType
        }

        return .unknown(description)
    }
}

// MARK: - SwiftUI Error Presentation

public struct ErrorAlert: ViewModifier {
    @State var errorHandler = ErrorHandler.shared

    private var alertTitle: String {
        self.errorHandler.currentError?.errorDescription ?? "Error"
    }

    private var isShowingErrorBinding: Binding<Bool> {
        Binding(
            get: { self.errorHandler.isShowingError },
            set: { self.errorHandler.isShowingError = $0 }
        )
    }

    private func alertActions(_: Error) -> some View {
        ForEach(self.errorHandler.recoveryOptions) { option in
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
    public func body(content: Content) -> some View {
        content
            .alert(
                self.alertTitle,
                isPresented: self.isShowingErrorBinding,
                presenting: self.errorHandler.currentError,
                actions: self.alertActions,
                message: self.alertMessage
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
