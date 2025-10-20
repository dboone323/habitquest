//
// GestureManager.swift
// AvoidObstaclesGame
//
// Manages advanced touch gestures for precise player control and game interactions.
//

import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Types of gestures supported by the game
public indirect enum GestureType {
    case tap
    case doubleTap
    case longPress
    case swipe(direction: SwipeDirection)
    case pan(velocity: CGPoint)
    case pinch(scale: CGFloat)
    case rotation(angle: CGFloat)
    // Advanced gesture types
    case multiTap(count: Int)
    case forceTouch(pressure: CGFloat)
    case multiFingerSwipe(directions: [SwipeDirection])
    case gestureCombo(primary: GestureType, secondary: GestureType)
    case diagonalSwipe(direction: DiagonalDirection)
    case circularGesture(clockwise: Bool, radius: CGFloat)
}

/// Direction of swipe gestures
public enum SwipeDirection {
    case up
    case down
    case left
    case right
}

/// Diagonal swipe directions
public enum DiagonalDirection {
    case upLeft
    case upRight
    case downLeft
    case downRight
}

/// Protocol for gesture events
@MainActor
public protocol GestureDelegate: AnyObject {
    func gestureRecognized(_ gesture: GestureType, at location: CGPoint)
    func gestureBegan(_ gesture: GestureType, at location: CGPoint)
    func gestureChanged(_ gesture: GestureType, at location: CGPoint)
    func gestureEnded(_ gesture: GestureType, at location: CGPoint)
}

/// Manages advanced gesture recognition for the game
@MainActor
public class GestureManager {
    // MARK: - Properties

    /// Delegate for gesture events
    public weak var delegate: GestureDelegate?

    /// Whether gesture recognition is enabled
    public var isEnabled = true

    /// Minimum swipe distance to recognize a swipe gesture
    public var minimumSwipeDistance: CGFloat = 50.0

    /// Maximum time for a swipe gesture
    public var maximumSwipeTime: TimeInterval = 0.5

    /// Minimum velocity for pan gestures
    public var minimumPanVelocity: CGFloat = 100.0

    /// Gesture recognizers (iOS/tvOS only)
    #if os(iOS) || os(tvOS)
        private var gestureRecognizers: [UIGestureRecognizer] = []
        private weak var view: UIView?
    #endif

    /// Current gesture state
    private var currentGesture: GestureType?

    /// Gesture start location
    private var gestureStartLocation: CGPoint?

    /// Gesture start time
    private var gestureStartTime: TimeInterval?

    /// Multi-touch tracking (iOS/tvOS only)
    #if os(iOS) || os(tvOS)
    private var activeTouches: [UITouch: CGPoint] = [:]
    private var touchStartTimes: [UITouch: TimeInterval] = [:]
    #else
    private var activeTouches: [AnyHashable: CGPoint] = [:]
    private var touchStartTimes: [AnyHashable: TimeInterval] = [:]
    #endif

    /// Force touch support
    private var forceTouchAvailable = false
    private var maximumForce: CGFloat = 0.0

    /// Gesture combination tracking
    private var recentGestures: [GestureType] = []
    private var gestureCombinationTimeout: TimeInterval = 0.5

    /// Circular gesture tracking
    private var circularGesturePoints: [CGPoint] = []
    private var circularGestureThreshold: CGFloat = 50.0

    // MARK: - Initialization

    public init() {
        #if os(iOS) || os(tvOS)
            self.setupGestureRecognizers()
        #endif
    }

    /// Sets up gesture recognizers for the view
    /// - Parameter view: The view to attach gesture recognizers to
    #if os(iOS) || os(tvOS)
        public func setupForView(_ view: UIView) {
            self.view = view
            self.checkForceTouchAvailability()
            self.addGestureRecognizers(to: view)
        }
    #else
        public func setupForView(_ view: Any) {
            // No-op on platforms without gesture recognizers
        }
    #endif

    /// Checks if force touch is available on the current device
    #if os(iOS) || os(tvOS)
        private func checkForceTouchAvailability() {
            if #available(iOS 9.0, tvOS 9.0, *) {
                self.forceTouchAvailable = self.view?.traitCollection.forceTouchCapability == .available
            } else {
                self.forceTouchAvailable = false
            }
        }
    #endif

    /// Removes gesture recognizers from the current view
    public func removeFromView() {
        #if os(iOS) || os(tvOS)
            guard let view = self.view else { return }
            for recognizer in self.gestureRecognizers {
                view.removeGestureRecognizer(recognizer)
            }
            self.gestureRecognizers.removeAll()
        #endif
    }

    // MARK: - Gesture Recognizer Setup

    #if os(iOS) || os(tvOS)
        private func setupGestureRecognizers() {
            // Tap gesture
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapRecognizer.numberOfTapsRequired = 1
            self.gestureRecognizers.append(tapRecognizer)

            // Double tap gesture
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            tapRecognizer.require(toFail: doubleTapRecognizer) // Single tap fails if double tap occurs
            self.gestureRecognizers.append(doubleTapRecognizer)

            // Multi-tap gestures (3 and 4 taps)
            let tripleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMultiTap(_:)))
            tripleTapRecognizer.numberOfTapsRequired = 3
            doubleTapRecognizer.require(toFail: tripleTapRecognizer)
            self.gestureRecognizers.append(tripleTapRecognizer)

            let quadrupleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMultiTap(_:)))
            quadrupleTapRecognizer.numberOfTapsRequired = 4
            tripleTapRecognizer.require(toFail: quadrupleTapRecognizer)
            self.gestureRecognizers.append(quadrupleTapRecognizer)

            // Long press gesture
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPressRecognizer.minimumPressDuration = 0.5
            self.gestureRecognizers.append(longPressRecognizer)

            // Swipe gestures (including diagonal)
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeUp.direction = .up
            self.gestureRecognizers.append(swipeUp)

            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeDown.direction = .down
            self.gestureRecognizers.append(swipeDown)

            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeLeft.direction = .left
            self.gestureRecognizers.append(swipeLeft)

            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeRight.direction = .right
            self.gestureRecognizers.append(swipeRight)

            // Diagonal swipe gestures
            let swipeUpLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleDiagonalSwipe(_:)))
            swipeUpLeft.direction = [.up, .left]
            self.gestureRecognizers.append(swipeUpLeft)

            let swipeUpRight = UISwipeGestureRecognizer(target: self, action: #selector(handleDiagonalSwipe(_:)))
            swipeUpRight.direction = [.up, .right]
            self.gestureRecognizers.append(swipeUpRight)

            let swipeDownLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleDiagonalSwipe(_:)))
            swipeDownLeft.direction = [.down, .left]
            self.gestureRecognizers.append(swipeDownLeft)

            let swipeDownRight = UISwipeGestureRecognizer(target: self, action: #selector(handleDiagonalSwipe(_:)))
            swipeDownRight.direction = [.down, .right]
            self.gestureRecognizers.append(swipeDownRight)

            // Pan gesture
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panRecognizer.maximumNumberOfTouches = 2 // Allow multi-touch pan
            self.gestureRecognizers.append(panRecognizer)

            // Pinch gesture
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            self.gestureRecognizers.append(pinchRecognizer)

            // Rotation gesture
            let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
            self.gestureRecognizers.append(rotationRecognizer)

            // Multi-finger swipe gestures
            let twoFingerSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleMultiFingerSwipe(_:)))
            twoFingerSwipeUp.direction = .up
            twoFingerSwipeUp.numberOfTouchesRequired = 2
            self.gestureRecognizers.append(twoFingerSwipeUp)

            let twoFingerSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleMultiFingerSwipe(_:)))
            twoFingerSwipeDown.direction = .down
            twoFingerSwipeDown.numberOfTouchesRequired = 2
            self.gestureRecognizers.append(twoFingerSwipeDown)

            let twoFingerSwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleMultiFingerSwipe(_:)))
            twoFingerSwipeLeft.direction = .left
            twoFingerSwipeLeft.numberOfTouchesRequired = 2
            self.gestureRecognizers.append(twoFingerSwipeLeft)

            let twoFingerSwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleMultiFingerSwipe(_:)))
            twoFingerSwipeRight.direction = .right
            twoFingerSwipeRight.numberOfTouchesRequired = 2
            self.gestureRecognizers.append(twoFingerSwipeRight)
        }

        private func addGestureRecognizers(to view: UIView) {
            for recognizer in self.gestureRecognizers {
                view.addGestureRecognizer(recognizer)
            }
        }
    #endif

    // MARK: - Gesture Handlers

    #if os(iOS) || os(tvOS)
        @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)
            self.delegate?.gestureRecognized(.tap, at: location)
        }

        @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)
            self.delegate?.gestureRecognized(.doubleTap, at: location)
        }

        @objc private func handleMultiTap(_ recognizer: UITapGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)
            let tapCount = recognizer.numberOfTapsRequired
            self.delegate?.gestureRecognized(.multiTap(count: tapCount), at: location)
        }

        @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)

            switch recognizer.state {
            case .began:
                self.delegate?.gestureBegan(.longPress, at: location)
            case .ended:
                self.delegate?.gestureEnded(.longPress, at: location)
            default:
                break
            }
        }

        @objc private func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)

            let direction: SwipeDirection
            switch recognizer.direction {
            case .up:
                direction = .up
            case .down:
                direction = .down
            case .left:
                direction = .left
            case .right:
                direction = .right
            default:
                return
            }

            self.delegate?.gestureRecognized(.swipe(direction: direction), at: location)
        }

        @objc private func handleDiagonalSwipe(_ recognizer: UISwipeGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)

            let direction: DiagonalDirection
            switch recognizer.direction {
            case [.up, .left]:
                direction = .upLeft
            case [.up, .right]:
                direction = .upRight
            case [.down, .left]:
                direction = .downLeft
            case [.down, .right]:
                direction = .downRight
            default:
                return
            }

            self.delegate?.gestureRecognized(.diagonalSwipe(direction: direction), at: location)
        }

        @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)
            let velocity = recognizer.velocity(in: recognizer.view)

            switch recognizer.state {
            case .began:
                self.delegate?.gestureBegan(.pan(velocity: velocity), at: location)
            case .changed:
                self.delegate?.gestureChanged(.pan(velocity: velocity), at: location)
            case .ended:
                self.delegate?.gestureEnded(.pan(velocity: velocity), at: location)
            default:
                break
            }
        }

        @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)
            let scale = recognizer.scale

            switch recognizer.state {
            case .began:
                self.delegate?.gestureBegan(.pinch(scale: scale), at: location)
            case .changed:
                self.delegate?.gestureChanged(.pinch(scale: scale), at: location)
            case .ended:
                self.delegate?.gestureEnded(.pinch(scale: scale), at: location)
            default:
                break
            }
        }

        @objc private func handleRotation(_ recognizer: UIRotationGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)
            let angle = recognizer.rotation

            switch recognizer.state {
            case .began:
                self.delegate?.gestureBegan(.rotation(angle: angle), at: location)
            case .changed:
                self.delegate?.gestureChanged(.rotation(angle: angle), at: location)
            case .ended:
                self.delegate?.gestureEnded(.rotation(angle: angle), at: location)
            default:
                break
            }
        }

        @objc private func handleMultiFingerSwipe(_ recognizer: UISwipeGestureRecognizer) {
            guard self.isEnabled else { return }
            let location = recognizer.location(in: recognizer.view)
            let touchCount = recognizer.numberOfTouchesRequired

            let direction: SwipeDirection
            switch recognizer.direction {
            case .up:
                direction = .up
            case .down:
                direction = .down
            case .left:
                direction = .left
            case .right:
                direction = .right
            default:
                return
            }

            // Create multi-direction array for multi-finger swipe
            let directions = Array(repeating: direction, count: touchCount)
            self.delegate?.gestureRecognized(.multiFingerSwipe(directions: directions), at: location)
        }
    #endif

    // MARK: - Custom Gesture Recognition

    /// Processes touch events for custom gesture recognition
    /// - Parameters:
    ///   - touches: Set of touches
    ///   - event: Touch event
    ///   - view: The view receiving touches
    #if os(iOS) || os(tvOS)
        public func processTouches(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) {
            guard self.isEnabled else { return }

            // Handle custom gesture recognition for platforms without built-in recognizers
            // or for additional custom gestures

            for touch in touches {
                let location = touch.location(in: view)
                let previousLocation = touch.previousLocation(in: view)

                // Handle force touch if available
                if self.forceTouchAvailable, #available(iOS 9.0, tvOS 9.0, *) {
                    let force = touch.force
                    let maxForce = touch.maximumPossibleForce
                    if force > 0 && maxForce > 0 {
                        let normalizedForce = force / maxForce
                        if normalizedForce > 0.1 { // Threshold to avoid noise
                            self.handleForceTouch(at: location, force: normalizedForce, touch: touch)
                        }
                    }
                }

                switch touch.phase {
                case .began:
                    self.handleTouchBegan(at: location, touch: touch)
                case .moved:
                    self.handleTouchMoved(from: previousLocation, to: location, touch: touch)
                case .ended:
                    self.handleTouchEnded(at: location, touch: touch)
                case .cancelled:
                    self.handleTouchCancelled(touch: touch)
                default:
                    break
                }
            }

            // Check for circular gestures
            self.detectCircularGesture(with: touches, in: view)

            // Check for gesture combinations
            self.detectGestureCombinations()
        }
    #else
        public func processTouches(_ touches: Any, with event: Any?, in view: Any) {
            // No-op on platforms without touch support
        }
    #endif

    #if os(iOS) || os(tvOS)
        private func handleTouchBegan(at location: CGPoint, touch: UITouch) {
            self.activeTouches[touch] = location
            self.touchStartTimes[touch] = touch.timestamp

            // Track gesture for combinations
            if self.gestureStartLocation == nil {
                self.gestureStartLocation = location
                self.gestureStartTime = touch.timestamp
            }
        }

        private func handleTouchMoved(from previousLocation: CGPoint, to location: CGPoint, touch: UITouch) {
            self.activeTouches[touch] = location

            // Handle continuous gestures like custom swipes or drags
            guard let startLocation = self.gestureStartLocation,
                  let startTime = self.gestureStartTime else { return }

            let distance = hypot(location.x - startLocation.x, location.y - startLocation.y)
            let timeElapsed = touch.timestamp - startTime

            // Check for potential swipe with velocity consideration
            if distance >= self.minimumSwipeDistance && timeElapsed <= self.maximumSwipeTime {
                let deltaX = location.x - startLocation.x
                let deltaY = location.y - startLocation.y

                // Calculate velocity for enhanced gesture recognition
                let velocity = CGPoint(x: deltaX / CGFloat(timeElapsed), y: deltaY / CGFloat(timeElapsed))

                if abs(deltaX) > abs(deltaY) {
                    // Horizontal swipe
                    let direction: SwipeDirection = deltaX > 0 ? .right : .left
                    self.delegate?.gestureRecognized(.swipe(direction: direction), at: location)
                } else {
                    // Vertical swipe
                    let direction: SwipeDirection = deltaY > 0 ? .down : .up
                    self.delegate?.gestureRecognized(.swipe(direction: direction), at: location)
                }

                // Reset gesture tracking
                self.gestureStartLocation = nil
                self.gestureStartTime = nil
            }

            // Handle multi-touch gestures
            if self.activeTouches.count > 1 {
                self.handleMultiTouchGesture(at: location)
            }
        }

        private func handleTouchEnded(at location: CGPoint, touch: UITouch) {
            // Handle tap if no significant movement occurred
            if let startLocation = self.gestureStartLocation,
               let startTime = self.touchStartTimes[touch]
            {
                let distance = hypot(location.x - startLocation.x, location.y - startLocation.y)
                let timeElapsed = touch.timestamp - startTime

                if distance < 10.0 && timeElapsed < 0.5 {
                    // This was a tap
                    self.delegate?.gestureRecognized(.tap, at: location)

                    // Add to recent gestures for combination detection
                    self.recentGestures.append(.tap)
                    if self.recentGestures.count > 10 {
                        self.recentGestures.removeFirst()
                    }
                }
            }

            // Clean up touch tracking
            self.activeTouches.removeValue(forKey: touch)
            self.touchStartTimes.removeValue(forKey: touch)

            // Reset gesture tracking if no more active touches
            if self.activeTouches.isEmpty {
                self.gestureStartLocation = nil
                self.gestureStartTime = nil
            }
        }

        private func handleTouchCancelled(touch: UITouch) {
            // Clean up touch tracking
            self.activeTouches.removeValue(forKey: touch)
            self.touchStartTimes.removeValue(forKey: touch)

            // Reset gesture tracking if no more active touches
            if self.activeTouches.isEmpty {
                self.gestureStartLocation = nil
                self.gestureStartTime = nil
            }
        }

        private func handleMultiTouchGesture(at location: CGPoint) {
            let touchCount = self.activeTouches.count

            // Handle different multi-touch scenarios
            switch touchCount {
            case 2:
                // Two-finger gestures
                self.handleTwoFingerGesture(at: location)
            case 3:
                // Three-finger gestures
                self.handleThreeFingerGesture(at: location)
            case 4:
                // Four-finger gestures
                self.handleFourFingerGesture(at: location)
            default:
                break
            }
        }

        private func handleTwoFingerGesture(at location: CGPoint) {
            // Two-finger tap or swipe
            let locations = Array(self.activeTouches.values)
            guard locations.count == 2 else { return }

            let finger1 = locations[0]
            let finger2 = locations[1]
            let distance = hypot(finger2.x - finger1.x, finger2.y - finger1.y)

            // If fingers are close together, it might be a two-finger tap
            if distance < 50.0 {
                // Two-finger tap detected
                let center = CGPoint(x: (finger1.x + finger2.x) / 2, y: (finger1.y + finger2.y) / 2)
                self.delegate?.gestureRecognized(.multiTap(count: 2), at: center)
            }
        }

        private func handleThreeFingerGesture(at location: CGPoint) {
            // Three-finger swipe or special action
            let center = self.calculateCenter(of: Array(self.activeTouches.values))
            self.delegate?.gestureRecognized(.multiTap(count: 3), at: center)
        }

        private func handleFourFingerGesture(at location: CGPoint) {
            // Four-finger gesture - typically for system actions, but can be used for game controls
            let center = self.calculateCenter(of: Array(self.activeTouches.values))
            self.delegate?.gestureRecognized(.multiTap(count: 4), at: center)
        }
    #endif

    // MARK: - Configuration

    /// Enables or disables gesture recognition
    /// - Parameter enabled: Whether gestures should be recognized
    public func setEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
        #if os(iOS) || os(tvOS)
            for recognizer in self.gestureRecognizers {
                recognizer.isEnabled = enabled
            }
        #endif
    }

    /// Configures gesture sensitivity settings
    /// - Parameters:
    ///   - swipeDistance: Minimum distance for swipe recognition
    ///   - swipeTime: Maximum time for swipe recognition
    ///   - panVelocity: Minimum velocity for pan recognition
    public func configureSensitivity(swipeDistance: CGFloat? = nil,
                                     swipeTime: TimeInterval? = nil,
                                     panVelocity: CGFloat? = nil)
    {
        if let distance = swipeDistance {
            self.minimumSwipeDistance = distance
        }
        if let time = swipeTime {
            self.maximumSwipeTime = time
        }
        if let velocity = panVelocity {
            self.minimumPanVelocity = velocity
        }
    }

    // MARK: - Cleanup

    deinit {
        // Cleanup is handled by calling removeFromView() explicitly before deallocation
    }
}

#if os(iOS) || os(tvOS)
    extension GestureManager {
        private func handleForceTouch(at location: CGPoint, force: CGFloat, touch: UITouch) {
            self.delegate?.gestureRecognized(.forceTouch(pressure: force), at: location)
        }

        private func detectCircularGesture(with touches: Set<UITouch>, in view: UIView) {
            guard touches.count == 1, let touch = touches.first else { return }

            let location = touch.location(in: view)
            self.circularGesturePoints.append(location)

            // Keep only recent points for performance
            if self.circularGesturePoints.count > 20 {
                self.circularGesturePoints.removeFirst()
            }

            // Need at least 10 points to detect a circle
            guard self.circularGesturePoints.count >= 10 else { return }

            // Calculate if points form a circle
            if self.isCircularGesture(points: self.circularGesturePoints) {
                let center = self.calculateCenter(of: self.circularGesturePoints)
                let radius = self.calculateAverageRadius(from: center, points: self.circularGesturePoints)
                let clockwise = self.isClockwise(points: self.circularGesturePoints)

                self.delegate?.gestureRecognized(.circularGesture(clockwise: clockwise, radius: radius), at: center)

                // Clear points after detection
                self.circularGesturePoints.removeAll()
            }
        }

        private func isCircularGesture(points: [CGPoint]) -> Bool {
            guard points.count >= 10 else { return false }

            let center = self.calculateCenter(of: points)
            let avgRadius = self.calculateAverageRadius(from: center, points: points)

            // Check if all points are within reasonable distance of the circle
            let tolerance = avgRadius * 0.3 // 30% tolerance
            for point in points {
                let distance = hypot(point.x - center.x, point.y - center.y)
                if abs(distance - avgRadius) > tolerance {
                    return false
                }
            }

            return true
        }

        private func calculateCenter(of points: [CGPoint]) -> CGPoint {
            var sumX: CGFloat = 0
            var sumY: CGFloat = 0

            for point in points {
                sumX += point.x
                sumY += point.y
            }

            return CGPoint(x: sumX / CGFloat(points.count), y: sumY / CGFloat(points.count))
        }

        private func calculateAverageRadius(from center: CGPoint, points: [CGPoint]) -> CGFloat {
            var totalRadius: CGFloat = 0

            for point in points {
                totalRadius += hypot(point.x - center.x, point.y - center.y)
            }

            return totalRadius / CGFloat(points.count)
        }

        private func isClockwise(points: [CGPoint]) -> Bool {
            guard points.count >= 3 else { return false }

            // Calculate the sum of angular changes
            var sum: CGFloat = 0
            let center = self.calculateCenter(of: points)

            for i in 0 ..< points.count {
                let p1 = points[i]
                let p2 = points[(i + 1) % points.count]

                let angle1 = atan2(p1.y - center.y, p1.x - center.x)
                let angle2 = atan2(p2.y - center.y, p2.x - center.x)

                var delta = angle2 - angle1

                // Normalize delta to [-π, π]
                while delta > .pi {
                    delta -= 2 * .pi
                }
                while delta < -.pi {
                    delta += 2 * .pi
                }

                sum += delta
            }

            return sum > 0
        }

        private func detectGestureCombinations() {
            // Clean up old gestures
            let currentTime = Date().timeIntervalSince1970
            self.recentGestures = self.recentGestures.filter { gesture in
                // Keep gestures within the combination timeout window
                if let gestureTime = self.getGestureTimestamp(gesture) {
                    return currentTime - gestureTime < self.gestureCombinationTimeout
                }
                return false
            }

            // Check for common gesture combinations
            if self.recentGestures.count >= 2 {
                let lastTwo = Array(self.recentGestures.suffix(2))

                // Example: Tap + Swipe = Quick directional move
                if case .tap = lastTwo[0], case .swipe = lastTwo[1] {
                    if let location = self.getGestureLocation(lastTwo[1]) {
                        self.delegate?.gestureRecognized(.gestureCombo(primary: lastTwo[0], secondary: lastTwo[1]), at: location)
                    }
                }

                // Example: Double tap + Long press = Special action
                if case .doubleTap = lastTwo[0], case .longPress = lastTwo[1] {
                    if let location = self.getGestureLocation(lastTwo[1]) {
                        self.delegate?.gestureRecognized(.gestureCombo(primary: lastTwo[0], secondary: lastTwo[1]), at: location)
                    }
                }
            }
        }

        private func getGestureTimestamp(_ gesture: GestureType) -> TimeInterval? {
            // This would need to be implemented to track timestamps for each gesture
            // For now, return current time as approximation
            Date().timeIntervalSince1970
        }

        private func getGestureLocation(_ gesture: GestureType) -> CGPoint? {
            // This would need to be implemented to track locations for each gesture
            // For now, return a default location
            self.gestureStartLocation
        }
    }
#endif
