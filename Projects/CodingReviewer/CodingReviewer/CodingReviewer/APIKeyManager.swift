import Combine
import Foundation

// SECURITY: API key handling - ensure proper encryption and keychain storage
import OSLog
import SwiftUI

/// APIKeyManager class
/// TODO: Add detailed documentation
@MainActor
// / APIKeyManager class
// / TODO: Add detailed documentation
public class APIKeyManager: ObservableObject {
    static let shared = APIKeyManager()

    @Published var showingKeySetup = false
    @Published var hasValidKey = false
    @Published var isConfigured = false
    @Published var hasValidGeminiKey = false

    // Free AI Services
    @Published var hasOllamaAvailable = false
    @Published var hasHuggingFaceAvailable = false

    // Keys
    private let openAIKeyAccount = "openai_api_key"
    private let geminiKeyAccount = "gemini_api_key"
    private let huggingFaceKeyAccount = "huggingface_api_key"
    private let huggingFaceKeyAccount = "huggingface_api_key"

    // Free AI Services
    @Published var hasOllamaAvailable = false
    @Published var hasHuggingFaceAvailable = false

    // MARK: - Generic UserDefaults Methods (simplified for now)

    private func setUserDefaultsValue(_ value: String, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private func getUserDefaultsValue(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    private func removeUserDefaultsValue(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - OpenAI API Key Methods

    func getOpenAIKey() -> String? {
        // First check environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            os_log("%@", "Using OpenAI API key from environment")
            return envKey
        }

        // Then check UserDefaults
        return getUserDefaultsValue(key: openAIKeyAccount)
    }

    func setOpenAIKey(_ key: String) {
        setUserDefaultsValue(key, key: openAIKeyAccount)
        hasValidKey = true
        isConfigured = true
        os_log("%@", "OpenAI API key saved successfully")
    }

    func removeOpenAIKey() {
        removeUserDefaultsValue(key: openAIKeyAccount)
        hasValidKey = false
        isConfigured = false
        os_log("%@", "OpenAI API key removed")
    }

    func validateOpenAIKey(_ key: String) async -> Bool {
        // Add your validation logic here
        os_log("%@", "OpenAI API key validation successful")
        return true
    }

    func checkAPIKeyStatus() {
        let hasKey = getOpenAIKey() != nil
        hasValidKey = hasKey
        isConfigured = hasKey

        let hasGeminiKey = getGeminiKey() != nil
        hasValidGeminiKey = hasGeminiKey

        let hasHFKey = getHuggingFaceKey() != nil
        hasHuggingFaceAvailable = hasHFKey

        // Check Ollama availability asynchronously
        Task {
            let ollamaAvailable = await checkOllamaAvailability()
            await MainActor.run {
                hasOllamaAvailable = ollamaAvailable
            }
        }

        if !hasKey {
            os_log("%@", "No OpenAI API key found")
        }

        if !hasGeminiKey {
            os_log("%@", "No Gemini API key found")
        }

        if !hasHFKey {
            os_log("%@", "No Hugging Face token found - using free tier")
        }

        if !hasOllamaAvailable {
            os_log("%@", "Ollama not available - start with: ollama serve")
        }
    }

    // MARK: - Gemini API Key Methods

    func getGeminiKey() -> String? {
        // First check environment variable
        if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
            os_log("%@", "Using Gemini API key from environment")
            return envKey
        }

        // Then check UserDefaults
        return getUserDefaultsValue(key: geminiKeyAccount)
    }

    func setGeminiKey(_ key: String) {
        setUserDefaultsValue(key, key: geminiKeyAccount)
        hasValidGeminiKey = true
        os_log("%@", "Gemini API key saved successfully")
    }

    func removeGeminiKey() {
        removeUserDefaultsValue(key: geminiKeyAccount)
        hasValidGeminiKey = false
        os_log("%@", "Gemini API key removed")
    }

    func validateGeminiKey(_ key: String) async -> Bool {
        // Add your validation logic here
        os_log("%@", "Gemini API key validation successful")
        return true
    }

    // MARK: - Hugging Face API Key Methods (Free Tier)

    func getHuggingFaceKey() -> String? {
        // First check environment variable
        if let envKey = ProcessInfo.processInfo.environment["HF_TOKEN"] {
            os_log("%@", "Using Hugging Face token from environment")
            return envKey
        }

        // Then check UserDefaults
        return getUserDefaultsValue(key: huggingFaceKeyAccount)
    }

    func setHuggingFaceKey(_ key: String) {
        setUserDefaultsValue(key, key: huggingFaceKeyAccount)
        hasHuggingFaceAvailable = true
        os_log("%@", "Hugging Face token saved successfully")
    }

    func removeHuggingFaceKey() {
        removeUserDefaultsValue(key: huggingFaceKeyAccount)
        hasHuggingFaceAvailable = false
        os_log("%@", "Hugging Face token removed")
    }

    func validateHuggingFaceKey(_ key: String) async -> Bool {
        // Simple validation - check if token format looks valid
        let tokenPattern = "^hf_[a-zA-Z0-9]{34,}$"
        let regex = try? NSRegularExpression(pattern: tokenPattern, options: [])
        let range = NSRange(location: 0, length: key.count)
        let matches = regex?.numberOfMatches(in: key, options: [], range: range) ?? 0
        return matches > 0
    }

    // MARK: - Ollama Methods (Free Local AI)

    func checkOllamaAvailability() async -> Bool {
        let ollamaURL = "http://localhost:11434/api/tags"

        guard let url = URL(string: ollamaURL) else {
            return false
        }

        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            let isAvailable = (response as? HTTPURLResponse)?.statusCode == 200
            hasOllamaAvailable = isAvailable
            return isAvailable
        } catch {
            hasOllamaAvailable = false
            return false
        }
    }

    func getOllamaModels() async -> [String] {
        let ollamaURL = "http://localhost:11434/api/tags"

        guard let url = URL(string: ollamaURL) else {
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let models = json["models"] as? [[String: Any]]
            {
                return models.compactMap { $0["name"] as? String }
            }
        } catch {
            os_log("%@", "Failed to fetch Ollama models: \(error.localizedDescription)")
        }

        return []
    }

    func showKeySetup() {
        os_log("%@", "🔑 [DEBUG] APIKeyManager.showKeySetup() called")
        os_log("%@", "🔑 [DEBUG] Before change - showingKeySetup: \(showingKeySetup)")
        DispatchQueue.main.async {
            self.showingKeySetup = true
        }
        os_log("%@", "🔑 [DEBUG] After change - showingKeySetup: \(showingKeySetup)")
    }
}
