import Foundation

enum SecurityConfig {
    static let minPasswordLength = 12
    static let sessionTimeout: TimeInterval = 3600 // 1 hour
    static let maxFailedAttempts = 3
    static let requiredHTTPS = true
    static let logSecurityEvents = true

    // Secure defaults
    static let allowedAPIEndpoints = [
        "http://localhost:11434", // Ollama local server
        "https://huggingface.co", // Hugging Face free tier
        "https://api.github.com" // GitHub API for repository access
    ]

    static func validateEndpoint(_ endpoint: String) -> Bool {
        guard SecurityManager.shared.validateSecureURL(endpoint) else {
            return false
        }

        return allowedAPIEndpoints.contains { endpoint.hasPrefix($0) }
    }
}
