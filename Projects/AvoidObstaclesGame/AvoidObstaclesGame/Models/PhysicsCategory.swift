//
// PhysicsCategory.swift
// AvoidObstaclesGame
//
// Defines physics categories for collision detection.
//

import Foundation

/// Defines the categories for physics bodies to handle collisions.
/// Using UInt32 for bitmasks allows up to 32 unique categories.
enum PhysicsCategory {
    static let none: UInt32 = 0 // 0
    static let player: UInt32 = 0b1 // Binary 1 (decimal 1)
    static let obstacle: UInt32 = 0b10 // Binary 2 (decimal 2)
    static let powerUp: UInt32 = 0b100 // Binary 4 (decimal 4)
    // Add more categories here if needed (e.g., ground: 0b1000)
}
