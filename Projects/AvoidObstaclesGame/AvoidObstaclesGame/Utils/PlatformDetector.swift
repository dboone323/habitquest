//
//  PlatformDetector.swift
//  AvoidObstaclesGame
//
//  Created by Daniel on 2025-01-19.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

/// Platform detection utility for cross-platform support
enum Platform {
    case iOS
    case macOS
    case tvOS
    case unknown

    static var current: Platform {
        #if os(iOS)
            #if targetEnvironment(simulator)
                return .iOS
            #else
                return .iOS
            #endif
        #elseif os(macOS)
            return .macOS
        #elseif os(tvOS)
            return .tvOS
        #else
            return .unknown
        #endif
    }

    var isTouchBased: Bool {
        switch self {
        case .iOS, .tvOS:
            return true
        case .macOS:
            return false
        case .unknown:
            return true // Default to touch for unknown platforms
        }
    }

    var supportsHapticFeedback: Bool {
        switch self {
        case .iOS, .tvOS:
            return true
        case .macOS:
            return false
        case .unknown:
            return false
        }
    }

    var preferredInputMethod: InputMethod {
        switch self {
        case .iOS:
            return .touch
        case .macOS:
            return .keyboardMouse
        case .tvOS:
            return .remote
        case .unknown:
            return .touch
        }
    }
}

enum InputMethod {
    case touch
    case keyboardMouse
    case remote
}

/// Platform-specific configuration
@MainActor
struct PlatformConfig {
    let platform: Platform

    var screenScale: CGFloat {
        #if os(iOS) || os(tvOS)
            #if os(iOS)
                return UIScreen.main.scale
            #elseif os(tvOS)
                return UIScreen.main.scale
            #endif
        #elseif os(macOS)
            return NSScreen.main?.backingScaleFactor ?? 1.0
        #else
            return 1.0
        #endif
    }

    var safeAreaInsets: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        #if os(iOS) || os(tvOS)
            #if os(iOS)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first
                {
                    let insets = window.safeAreaInsets
                    return (top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
                }
                return (top: 0, left: 0, bottom: 0, right: 0)
            #elseif os(tvOS)
                return (top: 0, left: 0, bottom: 0, right: 0) // tvOS typically doesn't have safe areas
            #endif
        #elseif os(macOS)
            return (top: 0, left: 0, bottom: 0, right: 0) // macOS doesn't have safe areas like iOS
        #else
            return (top: 0, left: 0, bottom: 0, right: 0)
        #endif
    }

    var preferredSceneSize: CGSize {
        switch platform {
        case .iOS:
            return CGSize(width: 375, height: 667) // iPhone SE size
        case .macOS:
            return CGSize(width: 1024, height: 768) // Standard macOS window size
        case .tvOS:
            return CGSize(width: 1920, height: 1080) // 1080p TV resolution
        case .unknown:
            return CGSize(width: 375, height: 667)
        }
    }
}

// Platform-specific imports and conditional compilation
#if os(iOS)
    import UIKit

    typealias ApplicationDelegate = UIApplicationDelegate
    typealias ViewController = UIViewController
    typealias Screen = UIScreen
#endif

#if os(macOS)
    import AppKit

    typealias ApplicationDelegate = NSApplicationDelegate
    typealias ViewController = NSViewController
    typealias Screen = NSScreen
#endif

#if os(tvOS)
    import UIKit

    typealias ApplicationDelegate = UIApplicationDelegate
    typealias ViewController = UIViewController
    typealias Screen = UIScreen
#endif
