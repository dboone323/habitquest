import Foundation
import LocalAuthentication
import OSLog

// MARK: - Authentication & Security

extension NavigationCoordinator {

    /// Authenticate user with biometrics (Face ID/Touch ID)
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        else {
            Logger.logWarning(
                "Biometric authentication not available: \(String(describing: error))")
            return false
        }

        do {
            // Perform biometric authentication
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your financial data"
            )

            if success {
                isAuthenticated = true
                lastAuthenticationTime = Date()
                return true
            } else {
                return false
            }
        } catch {
            Logger.logError(error, context: "Authentication")
            return false
        }
    }

    /// Check if authentication has timed out
    func checkAuthenticationStatus() -> Bool {
        guard requiresAuthentication else { return true }

        if let lastAuth = lastAuthenticationTime,
           Date().timeIntervalSince(lastAuth) < authenticationTimeoutInterval
        {
            return true
        }

        isAuthenticated = false
        return false
    }

    /// Reset authentication state
    func resetAuthentication() {
        isAuthenticated = false
        lastAuthenticationTime = nil
    }
}
