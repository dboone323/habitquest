//
// PhysicsCategory.swift
// AvoidObstaclesGame
//
// Defines physics categories for collision detection.
//

import Foundation

/// Defines the categories for physics bodies to handle collisions.
/// Using UInt32 for bitmasks allows up to 32 unique categories.
public enum PhysicsCategory {
    public static let none: UInt32 = 0 // 0
    public static let player: UInt32 = 0b1 // Binary 1 (decimal 1)
    public static let obstacle: UInt32 = 0b10 // Binary 2 (decimal 2)
    public static let powerUp: UInt32 = 0b100 // Binary 4 (decimal 4)
    public static let boss: UInt32 = 0b1000 // Binary 8 (decimal 8)
    // Add more categories here if needed (e.g., ground: 0b10000)
}
