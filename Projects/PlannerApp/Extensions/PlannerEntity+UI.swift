//
//  PlannerEntity+UI.swift
//  PlannerApp
//
//  UI extensions for PlannerEntity protocols to provide SwiftUI Color conversions
//

import SwiftUI
import Foundation

// Import the protocols from PlannerEntities
// Note: In a real project, these would be in a separate module or framework

// MARK: - Color Extensions for Planner Entities

extension PlannerRenderable {
    /// Converts the string-based color to a SwiftUI Color
    var uiColor: Color {
        Color(color)
    }
}

extension PlannerPriority {
    /// Converts the string-based color to a SwiftUI Color
    var uiColor: Color {
        Color(color)
    }
}

// MARK: - Color Mapping Extensions

extension String {
    /// Converts a color string to SwiftUI Color with fallback
    var toColor: Color {
        switch self.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        case "gray", "grey": return .gray
        case "black": return .black
        case "white": return .white
        case "primary": return .primary
        case "secondary": return .secondary
        case "accent": return .accentColor
        default: return .blue // Default fallback color
        }
    }
}
