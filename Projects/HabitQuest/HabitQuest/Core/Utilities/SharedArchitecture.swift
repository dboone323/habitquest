import Foundation
import SwiftUI

// MARK: - Shared View Model Protocol

/// Protocol for standardized MVVM pattern across all projects
@MainActor
public protocol BaseViewModel: ObservableObject {
    associatedtype State
    associatedtype Action

    var state: State { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }

    func handle(_ action: Action)
    func resetError()
}

extension BaseViewModel {
    public func resetError() {
        errorMessage = nil
    }

    func setLoading(_ loading: Bool) {
        isLoading = loading
    }

    func setError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}

// MARK: - Error Handling

/// Standardized error types across projects
public enum AppError: LocalizedError {
    case networkError(String)
    case dataError(String)
    case validationError(String)
    case unknownError

    public var errorDescription: String? {
        switch self {
        case let .networkError(message):
            "Network Error: \(message)"
        case let .dataError(message):
            "Data Error: \(message)"
        case let .validationError(message):
            "Validation Error: \(message)"
        case .unknownError:
            "An unknown error occurred"
        }
    }
}
