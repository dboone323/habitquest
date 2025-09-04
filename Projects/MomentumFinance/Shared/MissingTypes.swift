//
//  MissingTypes.swift
//  MomentumFinance
//
//  Temporary file to resolve missing type definitions
//  These should eventually be moved to proper module files
//

import Foundation
import OSLog
import SwiftUI
import UserNotifications

// This file previously contained duplicate type declarations that conflicted
// with the canonical implementations. Those canonical types should be used instead.
// Keep only lightweight compatibility helpers here.

// MARK: - Lightweight Navigation Helpers

/// Simple wrapper to represent a deep link (kept intentionally minimal).
struct DeepLinkSimple: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let target: String
}

// MARK: - Data Import Types

// EntityManager implementation moved to Shared/Utils/ImportComponents/EntityManager.swift

// MARK: - Intelligence Types


