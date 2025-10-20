import Foundation

/// Backwards compatibility shim that forwards legacy `OllamaIntegrationFramework` usages
/// to the consolidated `OllamaIntegrationManager` implementation.
@available(*, deprecated, renamed: "OllamaIntegrationManager")
public typealias OllamaIntegrationFramework = OllamaIntegrationManager

/// Namespace helpers for quickly accessing and configuring a shared integration manager.
public enum OllamaIntegration {
    /// Shared manager instance used by simplified helper methods.
    @MainActor private static var _shared: OllamaIntegrationManager?

    @MainActor public static var shared: OllamaIntegrationManager {
        get async {
            if let existing = _shared {
                return existing
            }
            let newInstance = OllamaIntegrationManager()
            _shared = newInstance
            return newInstance
        }
    }

    /// Replace the shared manager with a custom configuration.
    @MainActor public static func configureShared(config: OllamaConfig) {
        self._shared = OllamaIntegrationManager(config: config)
    }

    /// Perform a quick service health check using the shared manager.
    @MainActor public static func healthCheck() async -> ServiceHealth {
        // Stub implementation - return unknown health status
        ServiceHealth(
            serviceName: "Ollama",
            isRunning: false,
            modelsAvailable: false,
            responseTime: 0.0,
            errorRate: 0.0,
            lastChecked: Date(),
            recommendations: ["Ollama integration not available"]
        )
    }
}
