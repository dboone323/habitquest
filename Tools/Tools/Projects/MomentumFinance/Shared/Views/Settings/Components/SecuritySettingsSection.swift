//
//  SecuritySettingsSection.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import LocalAuthentication
import SwiftUI

/// Security and privacy settings section with biometric authentication
struct SecuritySettingsSection: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Binding var biometricEnabled: Bool
    @Binding var authenticationTimeout: Double
    @Binding var hapticFeedbackEnabled: Bool
    @State private var biometricStatus: BiometricStatus = .unknown

    var body: some View {
        Section {
            HStack {
                Label("Biometric Authentication", systemImage: biometricIcon)
                    .foregroundColor(.primary)

                Spacer()

                Toggle("", isOn: $biometricEnabled)
                    .disabled(!biometricStatus.isAvailable)
                    .onChange(of: biometricEnabled) { _, newValue in
                        if newValue {
                            Task {
                                await enableBiometricAuthentication()
                            }
                        } else {
                            coordinator.requiresAuthentication = false
                        }
                    }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Biometric Authentication")
            .accessibilityValue(biometricEnabled ? "Enabled" : "Disabled")

            if !biometricStatus.isAvailable {
                Text(biometricStatus.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if biometricEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Authentication Timeout")
                        .font(.subheadline)

                    HStack {
                        Text("5 min")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Slider(value: $authenticationTimeout, in: 60 ... 1800, step: 60) {
                            Text("Timeout")
                        }
                        .onChange(of: authenticationTimeout) { _, newValue in
                            coordinator.authenticationTimeoutInterval = newValue
                            #if os(iOS)
                                HapticManager.shared.impact(.light)
                            #endif
                        }

                        Text("30 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("Auto-lock after \(Int(authenticationTimeout / 60)) minutes of inactivity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        } header: {
            Text("Security & Privacy")
        } footer: {
            if biometricEnabled {
                Text("Your financial data is protected with \(biometricStatus.name) authentication.")
            }
        }
        .onAppear {
            checkBiometricStatus()
        }
    }

    private var biometricIcon: String {
        switch biometricStatus {
        case .faceID:
            "faceid"
        case .touchID:
            "touchid"
        case .unknown, .notAvailable, .notEnrolled:
            "lock.shield"
        }
    }

    private func checkBiometricStatus() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricStatus = .faceID
            case .touchID:
                biometricStatus = .touchID
            default:
                biometricStatus = .unknown
            }
        } else {
            if let error = error as? LAError {
                switch error.code {
                case .biometryNotEnrolled:
                    biometricStatus = .notEnrolled
                default:
                    biometricStatus = .notAvailable
                }
            } else {
                biometricStatus = .notAvailable
            }
        }
    }

    private func enableBiometricAuthentication() async {
        let success = await coordinator.authenticateWithBiometrics()
        if success {
            coordinator.requiresAuthentication = true
            if hapticFeedbackEnabled {
                HapticManager.shared.success()
            }
        } else {
            biometricEnabled = false
            if hapticFeedbackEnabled {
                HapticManager.shared.error()
            }
        }
    }
}
