//
//  CrossPlatformInputManager.swift
//  AvoidObstaclesGame
//
//  Created by Daniel on 2025-01-19.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif
#if os(macOS)
    import AppKit
#endif

/// Cross-platform input manager that handles different input methods
@MainActor
final class CrossPlatformInputManager: NSObject {
    // MARK: - Singleton

    static let shared = CrossPlatformInputManager()

    // MARK: - Properties

    private var gameScene: GameScene?
    private var currentPlatform: Platform { Platform.current }

    // Input state tracking
    private var touchLocation: CGPoint?
    private var mouseLocation: CGPoint?
    private var keyboardState: Set<KeyboardKey> = []

    // MARK: - Initialization

    override private init() {
        super.init()
        setupInputHandling()
    }

    // MARK: - Setup

    private func setupInputHandling() {
        switch currentPlatform {
        case .iOS, .tvOS:
            setupTouchHandling()
        case .macOS:
            setupMouseKeyboardHandling()
        case .unknown:
            setupTouchHandling() // Default to touch
        }
    }

    private func setupTouchHandling() {
        // Touch handling is managed by the GameScene itself
        // This method is for any additional setup needed
    }

    private func setupMouseKeyboardHandling() {
        #if os(macOS)
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                self?.handleKeyDown(event)
                return event
            }

            NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self] event in
                self?.handleKeyUp(event)
                return event
            }

            NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
                self?.handleMouseMoved(event)
                return event
            }
        #endif
    }

    // MARK: - Public Methods

    func setGameScene(_ scene: GameScene) {
        self.gameScene = scene
    }

    #if os(iOS) || os(tvOS)
        func handleTouchBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let scene = gameScene else { return }

            for touch in touches {
                let location = touch.location(in: scene)
                touchLocation = location

                // Convert touch to game input
                handleGameInput(at: location, inputType: .touchBegan)
            }
        }

        func handleTouchMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let scene = gameScene else { return }

            for touch in touches {
                let location = touch.location(in: scene)
                touchLocation = location

                // Convert touch to game input
                handleGameInput(at: location, inputType: .touchMoved)
            }
        }

        func handleTouchEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let scene = gameScene else { return }

            for touch in touches {
                let location = touch.location(in: scene)
                touchLocation = location

                // Convert touch to game input
                handleGameInput(at: location, inputType: .touchEnded)
            }
        }
    #endif

    #if os(macOS)
        private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
            guard let key = KeyboardKey(keyCode: event.keyCode) else { return event }
            keyboardState.insert(key)
            handleKeyboardInput(key: key, isPressed: true)
            return event
        }

        private func handleKeyUp(_ event: NSEvent) -> NSEvent? {
            guard let key = KeyboardKey(keyCode: event.keyCode) else { return event }
            keyboardState.remove(key)
            handleKeyboardInput(key: key, isPressed: false)
            return event
        }

        private func handleMouseMoved(_ event: NSEvent) -> NSEvent? {
            guard let scene = gameScene else { return event }
            let location = event.locationInWindow
            mouseLocation = scene.convertPoint(fromView: location)
            return event
        }

        func handleMouseDown(at location: CGPoint) {
            mouseLocation = location
            handleGameInput(at: location, inputType: .mouseDown)
        }

        func handleMouseUp(at location: CGPoint) {
            mouseLocation = location
            handleGameInput(at: location, inputType: .mouseUp)
        }
    #endif

    // MARK: - Input Processing

    private func handleGameInput(at location: CGPoint, inputType: InputType) {
        guard let scene = gameScene else { return }

        // Convert screen coordinates to game coordinates
        let gameLocation = scene.convertPoint(fromView: location)

        // Process input based on type
        switch inputType {
        case .touchBegan, .mouseDown:
            scene.handleInputBegan(at: gameLocation)
        case .touchMoved:
            scene.handleInputMoved(at: gameLocation)
        case .touchEnded, .mouseUp:
            scene.handleInputEnded(at: gameLocation)
        }
    }

    private func handleKeyboardInput(key: KeyboardKey, isPressed: Bool) {
        guard let scene = gameScene else { return }

        // Convert keyboard input to game actions
        switch key {
        case .leftArrow:
            scene.handleMovement(direction: .left, isActive: isPressed)
        case .rightArrow:
            scene.handleMovement(direction: .right, isActive: isPressed)
        case .upArrow:
            scene.handleMovement(direction: .up, isActive: isPressed)
        case .downArrow:
            scene.handleMovement(direction: .down, isActive: isPressed)
        case .space:
            if isPressed {
                scene.handleAction(.jump)
            }
        case .escape:
            if isPressed {
                scene.handleAction(.pause)
            }
        default:
            break
        }
    }

    // MARK: - Input Types

    enum InputType {
        case touchBegan
        case touchMoved
        case touchEnded
        case mouseDown
        case mouseUp
    }

    enum KeyboardKey: Hashable {
        case leftArrow
        case rightArrow
        case upArrow
        case downArrow
        case space
        case escape
        case other(Int)

        init?(keyCode: UInt16) {
            switch keyCode {
            case 123: self = .leftArrow
            case 124: self = .rightArrow
            case 125: self = .downArrow
            case 126: self = .upArrow
            case 49: self = .space
            case 53: self = .escape
            default: self = .other(Int(keyCode))
            }
        }
    }
}
