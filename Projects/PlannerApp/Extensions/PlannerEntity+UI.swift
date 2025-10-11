//
//  PlannerEntity+UI.swift
//  PlannerApp
//
//  UI extensions for PlannerEntity protocols to provide SwiftUI Color conversions
//

import SwiftUI
import Foundation
import SharedKit

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
// Note: String.toColor extension is now in SharedKit
