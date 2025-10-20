//
//  GameViewController-macOS.swift
//  AvoidObstaclesGame-macOS
//
//  Created by Daniel on 2025-01-19.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Cocoa
import SpriteKit

/// The main view controller for AvoidObstaclesGame on macOS.
/// Responsible for loading and presenting the SpriteKit game scene.
public class GameViewController: NSViewController {

    /// Reference to the game scene for multiplayer control
    private var gameScene: GameScene?

    /// Called after the controller's view is loaded into memory.
    /// Sets up and presents the main game scene.
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view as an SKView and present the game scene.
        if let view = view as? SKView {
            // Create and configure the scene to fill the screen.
            let scene = GameScene(size: view.bounds.size)
            self.gameScene = scene
            scene.scaleMode = .aspectFill

            // Present the scene.
            view.presentScene(scene)

            // Optional: For performance tuning
            view.ignoresSiblingOrder = true

            // Optional: To see physics bodies and frame rate (uncomment to use)
            // view.showsPhysics = true
            // view.showsFPS = true
            // view.showsNodeCount = true
        }

        // Set up keyboard and mouse event handling
        setupInputHandling()
    }

    /// Sets up keyboard and mouse input handling for macOS
    private func setupInputHandling() {
        // Make the view first responder to receive keyboard events
        view.window?.makeFirstResponder(view)

        // Set up keyboard event monitoring
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }

        // Set up mouse event monitoring
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .mouseMoved]) { [weak self] event in
            self?.handleMouseEvent(event)
            return event
        }
    }

    /// Handles keyboard events
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        guard let scene = gameScene else { return event }

        let keyCode = event.keyCode
        let isKeyDown = event.type == .keyDown

        // Handle movement keys
        switch keyCode {
        case 0: // A key
            scene.handleMovement(direction: .left, isActive: isKeyDown)
        case 2: // D key
            scene.handleMovement(direction: .right, isActive: isKeyDown)
        case 13: // W key
            scene.handleMovement(direction: .up, isActive: isKeyDown)
        case 1: // S key
            scene.handleMovement(direction: .down, isActive: isKeyDown)
        case 49: // Spacebar
            if isKeyDown {
                scene.handleAction(.jump)
            }
        case 36: // Return key
            if isKeyDown {
                scene.handleAction(.pause)
            }
        case 53: // Escape key
            if isKeyDown {
                scene.handleAction(.menu)
            }
        case 123: // Left arrow
            scene.handleMovement(direction: .left, isActive: isKeyDown)
        case 124: // Right arrow
            scene.handleMovement(direction: .right, isActive: isKeyDown)
        case 125: // Down arrow
            scene.handleMovement(direction: .down, isActive: isKeyDown)
        case 126: // Up arrow
            scene.handleMovement(direction: .up, isActive: isKeyDown)
        default:
            break
        }

        return event
    }

    /// Handles mouse events
    private func handleMouseEvent(_ event: NSEvent) -> NSEvent? {
        guard let scene = gameScene, let skView = view as? SKView else { return event }

        let location = event.locationInWindow
        let gameLocation = skView.convert(location, to: scene)

        switch event.type {
        case .leftMouseDown:
            scene.handleInputBegan(at: gameLocation)
        case .leftMouseUp:
            scene.handleInputEnded(at: gameLocation)
        case .mouseMoved:
            // Optional: Handle mouse movement for aiming or other features
            if event.modifierFlags.contains(.control) {
                // Control + mouse movement could be used for special controls
                scene.handleInputMoved(at: gameLocation)
            }
        default:
            break
        }

        return event
    }

    /// Called when the view controller's view has been loaded and is about to be added to the view hierarchy.
    /// Sets up the SKView if the view is not already configured.
    override public func viewWillAppear() {
        super.viewWillAppear()

        // Ensure we have an SKView
        if !(view is SKView) {
            let skView = SKView(frame: view.bounds)
            skView.autoresizingMask = [.width, .height]
            view.addSubview(skView)

            // Create and configure the scene to fill the screen.
            let scene = GameScene(size: skView.bounds.size)
            self.gameScene = scene
            scene.scaleMode = .aspectFill

            // Present the scene.
            skView.presentScene(scene)

            // Optional: For performance tuning
            skView.ignoresSiblingOrder = true

            // Optional: To see physics bodies and frame rate (uncomment to use)
            // skView.showsPhysics = true
            // skView.showsFPS = true
            // skView.showsNodeCount = true
        }
    }
}
