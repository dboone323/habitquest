import Foundation

// MARK: - Shared Application Error

enum AppError: LocalizedError {
    case invalidInput(String)
    case fileNotFound(String)
    case networkError(String)
    case parsingError(String)
    case apiError(String)
    case configurationError(String)
    case unauthorized
    case invalidCredentials
    case operationFailed(String)
    case invalidConfiguration(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case let .invalidInput(message):
            "Invalid input: \(message)"
        case let .fileNotFound(filename):
            "File not found: \(filename)"
        case let .networkError(message):
            "Network error: \(message)"
        case let .parsingError(message):
            "Parsing error: \(message)"
        case let .apiError(message):
            "API error: \(message)"
        case let .configurationError(message):
            "Configuration error: \(message)"
        case .unauthorized:
            "Unauthorized access"
        case .invalidCredentials:
            "Invalid credentials"
        case let .operationFailed(message):
            "Operation failed: \(message)"
        case let .invalidConfiguration(message):
            "Invalid configuration: \(message)"
        case .unknown:
            "An unknown error occurred"
        }
    }
}
