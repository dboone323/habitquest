// SECURITY: API key handling - ensure proper encryption and keychain storage
//
// APIKeySetupView.swift
// CodingReviewer
//
// API Key setup and configuration view
// Created on July 25, 2025
//

import Accessibility
import SwiftUI

struct APIKeySetupView: View {
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var tempKey = ""
    @State private var isValidating = false
    @State private var validationResult: String?
    @State private var selectedProvider = "Ollama"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)

                    Text("API Key Setup")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Configure your AI service to enable advanced code analysis")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Provider Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Provider")
                        .font(.headline)

                    Picker("Provider", selection: $selectedProvider) {
                        Text("Ollama").tag("Ollama")
                        Text("Hugging Face").tag("Hugging Face")
                    }
                    .pickerStyle(.segmented)
                }

                // API Key Input
                VStack(alignment: .leading, spacing: 12) {
                    if selectedProvider == "Ollama" {
                        Text("Ollama Setup")
                            .font(.headline)

                        Text("Ollama runs locally on your machine. Make sure Ollama is installed and running.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Install Ollama: https://ollama.ai/download")
                            .font(.caption)
                            .foregroundColor(.blue)

                        Text("Start Ollama: Run 'ollama serve' in terminal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Hugging Face Token")
                            .font(.headline)

                        SecureField("Enter your Hugging Face token", text: $tempKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))

                        Text("Get your token from https://huggingface.co/settings/tokens")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Validation Result
                if let result = validationResult {
                    Text(result)
                        .font(.caption)
                        .foregroundColor(result.contains("✅") ? .green : .red)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                }

                // Action Buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    if selectedProvider == "Ollama" {
                        Button("Test Connection") {
                            Task {
                                await validateKey()
                            }
                        }
                        .disabled(isValidating)
                        .buttonStyle(.bordered)

                        Button("Save Configuration") {
                            Task {
                                await saveKey()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Test Key") {
                            Task {
                                await validateKey()
                            }
                        }
                        .disabled(tempKey.isEmpty || isValidating)
                        .buttonStyle(.bordered)

                        Button("Save") {
                            Task {
                                await saveKey()
                            }
                        }
                        .disabled(tempKey.isEmpty)
                        .buttonStyle(.borderedProminent)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("API Key Setup")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    private func validateKey() async {
        isValidating = true
        validationResult = "Validating..."

        let isValid: Bool = if selectedProvider == "Ollama" {
            // Check if Ollama is running locally
            await checkOllamaAvailability()
        } else {
            // Validate Hugging Face token format
            tempKey.hasPrefix("hf_") && tempKey.count > 10
        }

        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        await MainActor.run {
            self.isValidating = false
            if selectedProvider == "Ollama" {
                self.validationResult = isValid ? "✅ Ollama is running and available" : "❌ Ollama is not available. Please start with 'ollama serve'"
            } else {
                self.validationResult = isValid ? "✅ Valid Hugging Face token format" : "❌ Invalid Hugging Face token format"
            }
        }
    }

    private func checkOllamaAvailability() async -> Bool {
        let ollamaURL = "http://localhost:11434/api/tags"

        guard let url = URL(string: ollamaURL) else {
            return false
        }

        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    private func saveKey() async {
        await MainActor.run {
            isValidating = true
            validationResult = "Saving..."
        }

        // Save to UserDefaults - will integrate with APIKeyManager later
        if selectedProvider == "Hugging Face" {
            UserDefaults.standard.set(tempKey, forKey: "huggingface_api_key")
        }
        // For Ollama, no key needed - it's local

        await MainActor.run {
            self.isValidating = false
            self.validationResult = selectedProvider == "Ollama" ?
                "✅ Ollama configuration saved" :
                "✅ Hugging Face token saved successfully"

            // Auto-dismiss after showing success message
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.dismiss()
            }
        }
    }
}

#Preview {
    APIKeySetupView()
}
