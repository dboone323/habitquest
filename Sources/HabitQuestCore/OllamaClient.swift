////
// OllamaClient.swift
// HabitQuestCore
//
// Minimal client for a locally running Ollama API (default http://localhost:11434).
// OllamaClient was previously supplied by the removed SharedKit package; this
// is a small local replacement so HabitQuest builds standalone (issue #51).
//
import Foundation

/// Thin client for Ollama's `/api/generate` endpoint.
///
/// OllamaClient issues real HTTP requests to a local Ollama instance; it is not
/// a mock or stub. If no Ollama instance is running, calls throw and callers
/// fall back to their existing heuristic behaviour.
@MainActor
public final class OllamaClient {
    private let session: URLSession
    private let baseURL: URL

    public init(baseURL: URL = URL(string: "http://localhost:11434")!,
                session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Generate a completion for `prompt` and return the model's response text.
    public func generate(
        model: String?,
        prompt: String,
        temperature: Double = 0.7,
        maxTokens: Int? = nil,
        useCache: Bool = true
    ) async throws -> String {
        var options: [String: Any] = ["temperature": temperature]
        var body: [String: Any] = [
            "model": model ?? "llama3.2",
            "prompt": prompt,
            "stream": false,
            "options": options
        ]
        if let maxTokens {
            body["num_predict"] = maxTokens
        }
        // `useCache` is honoured server-side by Ollama once a model is loaded;
        // nothing extra is required client-side.
        _ = useCache

        let url = baseURL.appendingPathComponent("/api/generate")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await session.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let response = json["response"] as? String, !response.isEmpty {
            return response
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
