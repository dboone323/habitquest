//
// CodeTypes.swift
// CodingReviewer
//
// SharedTypes Module - Centralized type definitions
// Created on July 27, 2025
//

import Foundation

// MARK: - Programming Language Types

// Note: CodeLanguage enum is now defined in Services/LanguageDetectionService.swift
// This allows the service to manage language-specific functionality independently

// MARK: - Quality and Analysis Types

enum Severity: String, CaseIterable, Codable {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
    case critical = "Critical"

    var systemImageName: String {
        switch self {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        case .critical: return "exclamationmark.octagon"
        }
    }
}

enum QualityLevel: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case critical = "Critical"

    var score: Int {
        switch self {
        case .excellent: return 90
        case .good: return 75
        case .fair: return 60
        case .poor: return 40
        case .critical: return 20
        }
    }
}

enum EffortLevel: String, CaseIterable, Codable {
    case minimal = "Minimal"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case extensive = "Extensive"

    var estimatedHours: String {
        switch self {
        case .minimal: return "< 1 hour"
        case .low: return "1-4 hours"
        case .medium: return "1-2 days"
        case .high: return "3-5 days"
        case .extensive: return "1+ weeks"
        }
    }
}

enum ImpactLevel: String, CaseIterable, Codable {
    case negligible = "Negligible"
    case minor = "Minor"
    case moderate = "Moderate"
    case major = "Major"
    case critical = "Critical"

    var priority: Int {
        switch self {
        case .negligible: return 1
        case .minor: return 2
        case .moderate: return 3
        case .major: return 4
        case .critical: return 5
        }
    }
}
