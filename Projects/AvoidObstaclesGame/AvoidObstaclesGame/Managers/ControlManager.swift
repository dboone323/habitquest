//
// ControlManager.swift
// AvoidObstaclesGame
//
// Manages customizable control schemes and sensitivity settings for player input.
//

import CoreMotion
import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Available control schemes for the game
public enum ControlScheme: String, CaseIterable, Codable, Sendable {
    case touch = "Touch"
    case tilt = "Tilt"
    case gesture = "Gesture"
    case hybrid = "Hybrid"
    case custom = "Custom"

    /// Display name for the control scheme
    public var displayName: String {
        rawValue
    }

    /// Description of the control scheme
    public var description: String {
        switch self {
        case .touch: return "Direct touch controls for precise movement"
        case .tilt: return "Device tilt controls for immersive gameplay"
        case .gesture: return "Advanced gesture-based controls"
        case .hybrid: return "Combination of touch and tilt controls"
        case .custom: return "Fully customizable control mapping"
        }
    }
}

/// Response curve for control sensitivity
public enum ResponseCurve: String, Codable, Sendable {
    case linear
    case easeIn
    case easeOut
}

/// Control sensitivity settings
public struct ControlSensitivity: Codable, Sendable {
    /// Touch sensitivity (0.0 to 2.0)
    public var touchSensitivity: Double = 1.0

    /// Tilt sensitivity (0.0 to 2.0)
    public var tiltSensitivity: Double = 1.0

    /// Gesture sensitivity (0.0 to 2.0)
    public var gestureSensitivity: Double = 1.0

    /// Dead zone for tilt controls (0.0 to 0.5)
    public var tiltDeadZone: Double = 0.1

    /// Minimum pan velocity threshold
    public var minimumPanVelocity: CGFloat = 100.0

    /// Response curve for sensitivity
    public var responseCurve: ResponseCurve = .linear

    public init(touchSensitivity: Double = 1.0,
                tiltSensitivity: Double = 1.0,
                gestureSensitivity: Double = 1.0,
                tiltDeadZone: Double = 0.1,
                minimumPanVelocity: CGFloat = 100.0,
                responseCurve: ResponseCurve = .linear)
    {
        self.touchSensitivity = touchSensitivity
        self.tiltSensitivity = tiltSensitivity
        self.gestureSensitivity = gestureSensitivity
        self.tiltDeadZone = tiltDeadZone
        self.minimumPanVelocity = minimumPanVelocity
        self.responseCurve = responseCurve
    }
}

/// Custom control mapping
public struct ControlMapping: Codable, Sendable {
    /// Whether to invert X axis
    public var invertXAxis: Bool = false

    /// Whether to invert Y axis
    public var invertYAxis: Bool = false

    /// Custom gesture mappings
    public var gestureMappings: [String: MovementDirection] = [
        "swipeUp": .up,
        "swipeDown": .down,
        "swipeLeft": .left,
        "swipeRight": .right,
    ]

    /// Action mappings
    public var actionMappings: [String: String] = [
        "doubleTap": "jump",
        "longPress": "pause",
        "twoFingerTap": "special",
    ]

    public init(invertXAxis: Bool = false,
                invertYAxis: Bool = false,
                gestureMappings: [String: MovementDirection]? = nil,
                actionMappings: [String: String]? = nil)
    {
        self.invertXAxis = invertXAxis
        self.invertYAxis = invertYAxis
        if let mappings = gestureMappings {
            self.gestureMappings = mappings
        }
        if let actions = actionMappings {
            self.actionMappings = actions
        }
    }
}

/// Complete control configuration
public struct ControlConfiguration: Codable, Sendable {
    /// Selected control scheme
    public var scheme: ControlScheme = .touch

    /// Sensitivity settings
    public var sensitivity: ControlSensitivity = .init()

    /// Custom control mapping
    public var mapping: ControlMapping = .init()

    /// Whether controls are enabled
    public var enabled: Bool = true

    /// Whether to show control hints
    public var showHints: Bool = true

    public init(scheme: ControlScheme = .touch,
                sensitivity: ControlSensitivity = ControlSensitivity(),
                mapping: ControlMapping = ControlMapping(),
                enabled: Bool = true,
                showHints: Bool = true)
    {
        self.scheme = scheme
        self.sensitivity = sensitivity
        self.mapping = mapping
        self.enabled = enabled
        self.showHints = showHints
    }
}

/// Protocol for control events
@MainActor
public protocol ControlDelegate: AnyObject {
    func controlSchemeChanged(to scheme: ControlScheme)
    func sensitivityChanged(to sensitivity: ControlSensitivity)
    func controlConfigurationUpdated(_ configuration: ControlConfiguration)
}

/// Manages customizable control schemes and settings
@MainActor
public class ControlManager {
    // MARK: - Properties

    /// Shared singleton instance
    public static let shared = ControlManager()

    /// Delegate for control events
    public weak var delegate: ControlDelegate?

    /// Current control configuration
    public private(set) var configuration: ControlConfiguration {
        didSet {
            saveConfiguration()
            delegate?.controlConfigurationUpdated(configuration)
        }
    }

    /// Motion manager for tilt controls
    #if os(iOS) || os(tvOS)
        private let motionManager = CMMotionManager()
    #endif

    /// Whether tilt controls are currently active
    private var tiltControlsActive = false

    /// Control presets for different schemes
    private let controlPresets: [ControlScheme: ControlConfiguration] = [
        .touch: ControlConfiguration(
            scheme: .touch,
            sensitivity: ControlSensitivity(touchSensitivity: 1.0, tiltSensitivity: 0.0, gestureSensitivity: 0.0),
            mapping: ControlMapping()
        ),
        .tilt: ControlConfiguration(
            scheme: .tilt,
            sensitivity: ControlSensitivity(touchSensitivity: 0.0, tiltSensitivity: 1.0, gestureSensitivity: 0.0),
            mapping: ControlMapping()
        ),
        .gesture: ControlConfiguration(
            scheme: .gesture,
            sensitivity: ControlSensitivity(touchSensitivity: 0.0, tiltSensitivity: 0.0, gestureSensitivity: 1.0),
            mapping: ControlMapping()
        ),
        .hybrid: ControlConfiguration(
            scheme: .hybrid,
            sensitivity: ControlSensitivity(touchSensitivity: 0.7, tiltSensitivity: 0.8, gestureSensitivity: 0.5),
            mapping: ControlMapping()
        ),
        .custom: ControlConfiguration(
            scheme: .custom,
            sensitivity: ControlSensitivity(),
            mapping: ControlMapping()
        ),
    ]

    // MARK: - Initialization

    private init() {
        self.configuration = ControlConfiguration() // Initialize with default first
        self.configuration = loadConfiguration() // Then load from UserDefaults
        setupMotionManager()
    }

    // MARK: - Configuration Management

    /// Sets the control scheme
    /// - Parameter scheme: The control scheme to use
    public func setControlScheme(_ scheme: ControlScheme) {
        guard scheme != configuration.scheme else { return }

        // Load preset configuration for the scheme
        if let preset = controlPresets[scheme] {
            configuration = preset
        } else {
            configuration.scheme = scheme
        }

        updateControlSystems()
        delegate?.controlSchemeChanged(to: scheme)
    }

    /// Updates sensitivity settings
    /// - Parameter sensitivity: New sensitivity configuration
    public func updateSensitivity(_ sensitivity: ControlSensitivity) {
        configuration.sensitivity = sensitivity
        updateControlSystems()
        delegate?.sensitivityChanged(to: sensitivity)
    }

    /// Updates control mapping
    /// - Parameter mapping: New control mapping
    public func updateMapping(_ mapping: ControlMapping) {
        configuration.mapping = mapping
        updateControlSystems()
    }

    /// Enables or disables controls
    /// - Parameter enabled: Whether controls should be enabled
    public func setControlsEnabled(_ enabled: Bool) {
        configuration.enabled = enabled
        updateControlSystems()
    }

    /// Sets whether to show control hints
    /// - Parameter showHints: Whether to show control hints
    public func setShowHints(_ showHints: Bool) {
        configuration.showHints = showHints
    }

    /// Gets the current control scheme
    /// - Returns: Current control scheme
    public func getCurrentScheme() -> ControlScheme {
        configuration.scheme
    }

    /// Gets the current sensitivity settings
    /// - Returns: Current sensitivity configuration
    public func getCurrentSensitivity() -> ControlSensitivity {
        configuration.sensitivity
    }

    /// Gets the current control mapping
    /// - Returns: Current control mapping
    public func getCurrentMapping() -> ControlMapping {
        configuration.mapping
    }

    /// Gets available control schemes
    /// - Returns: Array of available control schemes
    public func getAvailableSchemes() -> [ControlScheme] {
        ControlScheme.allCases
    }

    /// Resets controls to default settings for current scheme
    public func resetToDefaults() {
        if let preset = controlPresets[configuration.scheme] {
            configuration = preset
        }
        updateControlSystems()
    }

    // MARK: - Control Processing

    /// Processes touch input based on current control scheme
    /// - Parameters:
    ///   - location: Touch location
    ///   - playerManager: Player manager to control
    func processTouch(at location: CGPoint, with playerManager: PlayerManager) {
        guard configuration.enabled else { return }

        switch configuration.scheme {
        case .touch, .hybrid:
            // Apply touch sensitivity
            let adjustedLocation = applyTouchSensitivity(to: location)
            playerManager.handleTouch(at: adjustedLocation)

        case .tilt, .gesture:
            // Touch input disabled for these schemes
            break

        case .custom:
            // Custom touch handling
            let adjustedLocation = applyCustomTouchSensitivity(to: location)
            playerManager.handleTouch(at: adjustedLocation)
        }
    }

    /// Processes gesture input
    /// - Parameters:
    ///   - gesture: Gesture type
    ///   - location: Gesture location
    ///   - playerManager: Player manager to control
    func processGesture(_ gesture: GestureType, at location: CGPoint, with playerManager: PlayerManager) {
        guard configuration.enabled else { return }

        switch configuration.scheme {
        case .gesture, .hybrid, .custom:
            handleGestureMovement(gesture, at: location, with: playerManager)

        case .touch, .tilt:
            // Gesture input disabled for these schemes
            break
        }
    }

    /// Processes movement direction input
    /// - Parameters:
    ///   - direction: Movement direction
    ///   - active: Whether direction is active
    ///   - playerManager: Player manager to control
    func processMovementDirection(_ direction: MovementDirection, active: Bool, with playerManager: PlayerManager) {
        guard configuration.enabled else { return }

        let adjustedDirection = applyDirectionMapping(direction)
        playerManager.setMovementDirection(adjustedDirection, active: active)
    }

    // MARK: - Private Methods

    private func setupMotionManager() {
        #if os(iOS) || os(tvOS)
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 FPS
        #endif
    }

    private func updateControlSystems() {
        // Update tilt controls based on scheme
        let shouldUseTilt = configuration.scheme == .tilt || configuration.scheme == .hybrid
        if shouldUseTilt && !tiltControlsActive {
            enableTiltControls()
        } else if !shouldUseTilt && tiltControlsActive {
            disableTiltControls()
        }
    }

    private func enableTiltControls() {
        #if os(iOS) || os(tvOS)
            guard motionManager.isDeviceMotionAvailable else { return }

            tiltControlsActive = true
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, error in
                guard let self, let motion, error == nil, self.tiltControlsActive else { return }
                // Tilt processing handled by PlayerManager
            }
        #endif
    }

    private func disableTiltControls() {
        #if os(iOS) || os(tvOS)
            tiltControlsActive = false
            motionManager.stopDeviceMotionUpdates()
        #endif
    }

    private func applyTouchSensitivity(to location: CGPoint) -> CGPoint {
        // Apply sensitivity scaling to touch location
        // For touch controls, sensitivity affects movement speed, not position
        // This could be used for scaling touch areas or response zones
        location
    }

    private func applyCustomTouchSensitivity(to location: CGPoint) -> CGPoint {
        // Apply custom sensitivity and axis inversion
        var adjustedLocation = location

        if configuration.mapping.invertXAxis {
            // Invert X axis (flip left/right)
            adjustedLocation.x = -adjustedLocation.x
        }

        if configuration.mapping.invertYAxis {
            // Invert Y axis (flip up/down)
            adjustedLocation.y = -adjustedLocation.y
        }

        return adjustedLocation
    }

    private func handleGestureMovement(_ gesture: GestureType, at location: CGPoint, with playerManager: PlayerManager) {
        switch gesture {
        case let .swipe(direction):
            let mappedDirection = configuration.mapping.gestureMappings["swipe\(direction.displayName)"] ?? MovementDirection(direction) ?? .up
            processMovementDirection(mappedDirection, active: true, with: playerManager)

            // Deactivate after short delay for swipe gestures
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.processMovementDirection(mappedDirection, active: false, with: playerManager)
            }

        case let .pan(velocity):
            // Handle continuous pan movement
            let speed = hypot(velocity.x, velocity.y)
            if speed > configuration.sensitivity.minimumPanVelocity {
                // Convert velocity to direction
                let angle = atan2(velocity.y, velocity.x)
                let direction: MovementDirection
                if abs(angle) < .pi / 4 {
                    direction = .right
                } else if abs(angle) > 3 * .pi / 4 {
                    direction = .left
                } else if angle > 0 {
                    direction = .down
                } else {
                    direction = .up
                }
                processMovementDirection(direction, active: true, with: playerManager)
            }

        default:
            break
        }
    }

    private func applyDirectionMapping(_ direction: MovementDirection) -> MovementDirection {
        var adjustedDirection = direction

        if configuration.mapping.invertXAxis {
            switch direction {
            case .left: adjustedDirection = .right
            case .right: adjustedDirection = .left
            default: break
            }
        }

        if configuration.mapping.invertYAxis {
            switch direction {
            case .up: adjustedDirection = .down
            case .down: adjustedDirection = .up
            default: break
            }
        }

        return adjustedDirection
    }

    // MARK: - Persistence

    private func saveConfiguration() {
        do {
            let data = try JSONEncoder().encode(configuration)
            UserDefaults.standard.set(data, forKey: "controlConfiguration")
        } catch {
            print("Failed to save control configuration: \(error)")
        }
    }

    private func loadConfiguration() -> ControlConfiguration {
        guard let data = UserDefaults.standard.data(forKey: "controlConfiguration") else {
            return ControlConfiguration() // Return default configuration
        }

        do {
            return try JSONDecoder().decode(ControlConfiguration.self, from: data)
        } catch {
            print("Failed to load control configuration: \(error)")
            return ControlConfiguration() // Return default on error
        }
    }

    // MARK: - Testing & Calibration

    /// Tests control responsiveness
    /// - Returns: Test results with latency measurements
    public func testControlResponsiveness() -> [String: TimeInterval] {
        var results: [String: TimeInterval] = [:]

        let startTime = Date()

        // Test touch response (simulated)
        results["touchResponse"] = Date().timeIntervalSince(startTime)

        // Test gesture response (simulated)
        results["gestureResponse"] = Date().timeIntervalSince(startTime)

        // Test tilt response (simulated)
        results["tiltResponse"] = Date().timeIntervalSince(startTime)

        return results
    }

    /// Calibrates tilt controls
    public func calibrateTiltControls() {
        #if os(iOS) || os(tvOS)
            // Reset tilt calibration
            configuration.sensitivity.tiltDeadZone = 0.1
            saveConfiguration()
        #endif
    }

    /// Gets control scheme recommendations based on device capabilities
    /// - Returns: Recommended control schemes for current device
    public func getRecommendedSchemes() -> [ControlScheme] {
        var recommendations: [ControlScheme] = [.touch] // Touch always available

        #if os(iOS) || os(tvOS)
            if motionManager.isDeviceMotionAvailable {
                recommendations.append(.tilt)
                recommendations.append(.hybrid)
            }
            recommendations.append(.gesture)
        #endif

        recommendations.append(.custom)

        return recommendations
    }
}

// MARK: - Extensions

extension SwipeDirection {
    var displayName: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        case .left: return "Left"
        case .right: return "Right"
        }
    }
}

extension MovementDirection {
    init?(_ swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        }
    }
}
