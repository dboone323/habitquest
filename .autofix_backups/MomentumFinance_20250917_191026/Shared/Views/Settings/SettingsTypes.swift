//
//  SettingsTypes.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

// MARK: - Dark Mode Preferences

/// Dark mode preference options
public enum DarkModePreference: String, CaseIterable {
    case light
    case dark
    case system

    public var displayName: String {
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
