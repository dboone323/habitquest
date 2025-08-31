//
// CodeTypes.swift
// CodingReviewer
//
// SharedTypes Module - Centralized type definitions
// Created on July 27, 2025
//

import Foundation
import SwiftUI

// MARK: - Programming Language Types

// Note: CodeLanguage enum is now defined in Services/LanguageDetectionService.swift
// This allows the service to manage language-specific functionality independently

// MARK: - Quality and Analysis Types

enum Severity: String, CaseIterable, Codable {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .info: .blue
        case .warning: .orange
        case .error: .red
        case .critical: .purple
        }
    }

    var systemImage: String {
        switch self {
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .error: "xmark.circle"
        case .critical: "exclamationmark.octagon"
        }
    }
}

enum QualityLevel: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .excellent: .green
        case .good: .blue
        case .fair: .yellow
        case .poor: .orange
        case .critical: .red
        }
    }

    var score: Int {
        switch self {
        case .excellent: 90
        case .good: 75
        case .fair: 60
        case .poor: 40
        case .critical: 20
        }
    }
}

enum EffortLevel: String, CaseIterable, Codable {
    case minimal = "Minimal"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case extensive = "Extensive"

    var color: Color {
        switch self {
        case .minimal: .green
        case .low: .blue
        case .medium: .yellow
        case .high: .orange
        case .extensive: .red
        }
    }

    var estimatedHours: String {
        switch self {
        case .minimal: "< 1 hour"
        case .low: "1-4 hours"
        case .medium: "1-2 days"
        case .high: "3-5 days"
        case .extensive: "1+ weeks"
        }
    }
}

enum ImpactLevel: String, CaseIterable, Codable {
    case negligible = "Negligible"
    case minor = "Minor"
    case moderate = "Moderate"
    case major = "Major"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .negligible: .gray
        case .minor: .blue
        case .moderate: .yellow
        case .major: .orange
        case .critical: .red
        }
    }

    var priority: Int {
        switch self {
        case .negligible: 1
        case .minor: 2
        case .moderate: 3
        case .major: 4
        case .critical: 5
        }
    }
}
