//
//  SettingsTypes.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import LocalAuthentication

/// Biometric authentication status and capabilities
enum BiometricStatus {
    case faceID
    case touchID
    case unknown
    case notAvailable
    case notEnrolled

    var isAvailable: Bool {
        switch self {
        case .faceID, .touchID:
            true
        case .unknown, .notAvailable, .notEnrolled:
            false
        }
    }

    var name: String {
        switch self {
        case .faceID:
            "Face ID"
        case .touchID:
            "Touch ID"
        case .unknown:
            "Biometric"
        case .notAvailable, .notEnrolled:
            "Biometric"
        }
    }

    var statusMessage: String {
        switch self {
        case .faceID, .touchID:
            ""
        case .unknown:
            "Biometric authentication is available but type is unknown"
        case .notAvailable:
            "Biometric authentication is not available on this device"
        case .notEnrolled:
            "No biometric authentication is set up. Please set up Face ID or Touch ID in Settings."
        }
    }
}

/// Dark mode preference options
enum DarkModePreference: String, CaseIterable {
    case light
    case dark
    case system

    var displayName: String {
        switch self {
        case .light:
            "Light"
        case .dark:
            "Dark"
        case .system:
            "System"
        }
    }
}
