import Foundation
import os

/// CodingReviewer-specific error handling
/// Provides consistent error management and logging for CodingReviewer
public enum CodingReviewerErrorHandler {
    /// CodingReviewer-specific error types
    public enum CodingReviewerError: LocalizedError {
        case fileOperationError(String)
        case analysisError(String)
        case reviewError(String)
        case configurationError(String)

        public var errorDescription: String? {
            switch self {
            case let .fileOperationError(message):
                "File Operation Error: \(message)"
            case let .analysisError(message):
                "Analysis Error: \(message)"
            case let .reviewError(message):
                "Review Error: \(message)"
            case let .configurationError(message):
                "Configuration Error: \(message)"
            }
        }

        public var recoverySuggestion: String? {
            switch self {
            case .fileOperationError:
                "Please check file permissions and try again."
            case .analysisError:
                "Please check the code file and try again."
            case .reviewError:
                "Please check the review criteria and try again."
            case .configurationError:
                "Please check your configuration settings and try again."
            }
        }
    }

    private static let logger = Logger(subsystem: "com.quantum.codingreviewer", category: "CodingReviewerError")

    /// Handle errors with logging
    public static func handle(
        _ error: Error,
        showToUser: Bool = true,
        context: String = "",
        file _: String = #file,
        function _: String = #function,
        line _: Int = #line
    ) {
        let errorMessage = error.localizedDescription
        let fullContext = context.isEmpty ? "" : "[\(context)] "

        // Log the error
        self.logger.error("\(fullContext)Error occurred: \(errorMessage)")

        // Additional logging for CodingReviewerError
        if let reviewerError = error as? CodingReviewerError {
            self.logger.error("\(fullContext)CodingReviewer Error Type: \(reviewerError)")
        }

        // Handle user notification if needed
        if showToUser {
            // In a real app, this would trigger a user notification
            // For now, we'll just log it
            self.logger.info("\(fullContext)User should be notified of error: \(errorMessage)")
        }
    }

    /// Handle CodingReviewer-specific errors
    public static func handleCodingReviewerError(
        _ error: CodingReviewerError,
        showToUser: Bool = true,
        context: String = "",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.handle(error, showToUser: showToUser, context: context, file: file, function: function, line: line)
    }

    /// Validate file path
    public static func validateFilePath(_ path: String) -> CodingReviewerError? {
        if path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .fileOperationError("File path cannot be empty")
        }

        if !FileManager.default.fileExists(atPath: path) {
            return .fileOperationError("File does not exist at path: \(path)")
        }

        return nil
    }

    /// Validate code content
    public static func validateCodeContent(_ content: String) -> CodingReviewerError? {
        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .analysisError("Code content cannot be empty")
        }

        if content.count > 1_000_000 {
            return .analysisError("Code content is too large (max 1MB)")
        }

        return nil
    }
}
