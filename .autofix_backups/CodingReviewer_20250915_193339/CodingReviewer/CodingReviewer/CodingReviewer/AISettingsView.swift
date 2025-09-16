import Foundation
import OSLog
// SECURITY: API key handling - ensure proper encryption and keychain storage
import SwiftUI

struct AISettingsView: View {
    @State private var huggingFaceToken = ""
    @State private var selectedProvider: AIProvider = .ollama
    @State private var showAlert = false
    @State private var alertMessage = ""

    enum AIProvider: String, CaseIterable {
        case ollama = "Ollama"
        case huggingFace = "Hugging Face"

        var displayName: String { rawValue }
    }

    var body: some View {
        Form {
            Section("AI Provider") {
                Picker("Provider", selection: $selectedProvider) {
                    ForEach(AIProvider.allCases, id: \.self) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedProvider) { _, newValue in
                    Logger().info("Provider changed to: \(newValue.rawValue)")
                }
            }

            Section("AI Configuration") {
                if selectedProvider == .ollama {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ollama Setup")
                            .font(.headline)
                        Text(
                            "Ollama runs locally on your machine. Make sure it's installed and running."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        Text("• Install: https://ollama.ai/download")
                        Text("• Start: Run 'ollama serve' in terminal")
                        Text("• Pull models: 'ollama pull codellama'")
                    }
                    .padding(.vertical, 8)
                } else {
                    SecureField("Hugging Face Token", text: $huggingFaceToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Text("Get your token from https://huggingface.co/settings/tokens")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button("Save Configuration") {
                    saveConfiguration()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Save Configuration Button")
            }
        }
        .navigationTitle("AI Settings")
        .onAppear {
            loadAPIKeys()
        }
        .alert("Settings", isPresented: $showAlert) {
            Button("OK") {
                // Dismiss alert
            }
            .accessibilityLabel("OK Button")
        } message: {
            Text(alertMessage)
        }
    }

    private func saveConfiguration() {
        // Save configuration to UserDefaults
        if selectedProvider == .huggingFace {
            UserDefaults.standard.set(huggingFaceToken, forKey: "huggingface_api_key")
        }
        UserDefaults.standard.set(selectedProvider.rawValue, forKey: "selected_provider")

        alertMessage = "Configuration saved successfully"
        showAlert = true
        Logger().info("AI configuration saved")
    }

    private func loadAPIKeys() {
        huggingFaceToken = UserDefaults.standard.string(forKey: "huggingface_api_key") ?? ""

        if let provider = UserDefaults.standard.string(forKey: "selected_provider"),
           let aiProvider = AIProvider(rawValue: provider) {
            selectedProvider = aiProvider
            Logger().info("Loaded provider from UserDefaults: \(provider)")
        } else {
            selectedProvider = .ollama
            Logger().info("Set default provider to ollama")
        }
    }
}
