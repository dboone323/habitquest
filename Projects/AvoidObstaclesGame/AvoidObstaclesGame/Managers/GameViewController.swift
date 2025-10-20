//
// GameViewController.swift
// AvoidObstaclesGame
//
// Standard ViewController to load and present the GameScene.
//

import GameplayKit
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit

    /// The main view controller for AvoidObstaclesGame.
    /// Responsible for loading and presenting the SpriteKit game scene.
    public class GameViewController: UIViewController {
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

            // Set up enhanced touch handling for iOS
            setupEnhancedTouchHandling()
        }

        /// Sets up enhanced touch handling with multi-touch support and gesture recognition
        private func setupEnhancedTouchHandling() {
            // Enable multi-touch
            view.isMultipleTouchEnabled = true

            // Set up gesture recognizers for enhanced input
            setupGestureRecognizers()
        }

        /// Sets up gesture recognizers for advanced touch controls
        private func setupGestureRecognizers() {
            // Double tap for jump action
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTap)

            // Single tap for regular input
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
            singleTap.require(toFail: doubleTap)
            view.addGestureRecognizer(singleTap)

            // Long press for pause/special actions
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            view.addGestureRecognizer(longPress)

            // Swipe gestures for directional movement
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeUp.direction = .up
            view.addGestureRecognizer(swipeUp)

            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeDown.direction = .down
            view.addGestureRecognizer(swipeDown)

            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeLeft.direction = .left
            view.addGestureRecognizer(swipeLeft)

            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeRight.direction = .right
            view.addGestureRecognizer(swipeRight)

            // Pinch gesture for zoom or special effects
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            view.addGestureRecognizer(pinch)

            // Pan gesture for continuous movement
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            pan.maximumNumberOfTouches = 1
            view.addGestureRecognizer(pan)
        }

        /// Handles single tap gestures
        @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: view)
            gameScene?.handleInputBegan(at: location)
        }

        /// Handles double tap gestures for jump actions
        @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            gameScene?.handleAction(.jump)
        }

        /// Handles long press gestures for pause/special actions
        @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                gameScene?.handleAction(.pause)
            }
        }

        /// Handles swipe gestures for directional movement
        @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            guard let scene = gameScene else { return }

            switch gesture.direction {
            case .up:
                scene.handleMovement(direction: .up, isActive: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scene.handleMovement(direction: .up, isActive: false)
                }
            case .down:
                scene.handleMovement(direction: .down, isActive: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scene.handleMovement(direction: .down, isActive: false)
                }
            case .left:
                scene.handleMovement(direction: .left, isActive: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scene.handleMovement(direction: .left, isActive: false)
                }
            case .right:
                scene.handleMovement(direction: .right, isActive: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scene.handleMovement(direction: .right, isActive: false)
                }
            default:
                break
            }
        }

        /// Handles pinch gestures for zoom or special effects
        @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            // Pinch could be used for zooming UI or triggering special abilities
            if gesture.state == .ended {
                if gesture.scale > 1.5 {
                    // Pinch out - could zoom in or activate ability
                    gameScene?.handleAction(.jump) // Placeholder action
                } else if gesture.scale < 0.7 {
                    // Pinch in - could zoom out or different effect
                    gameScene?.handleAction(.pause) // Placeholder action
                }
            }
        }

        /// Handles pan gestures for continuous movement
        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: view)

            switch gesture.state {
            case .began:
                gameScene?.handleInputBegan(at: location)
            case .changed:
                gameScene?.handleInputMoved(at: location)
            case .ended:
                gameScene?.handleInputEnded(at: location)
            default:
                break
            }
        }

        /// Specifies the supported interface orientations for the game.
        /// - Returns: The allowed interface orientations depending on device type.
        override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            if UIDevice.current.userInterfaceIdiom == .phone {
                .allButUpsideDown
            } else {
                .all
            }
        }

        /// Hides the status bar for a more immersive game experience.
        override public var prefersStatusBarHidden: Bool {
            true
        }

        /// Enables multiplayer mode for the game
        /// - Parameter enabled: Whether to enable or disable multiplayer
        public func setMultiplayerMode(_ enabled: Bool) {
            if enabled {
                self.gameScene?.enableMultiplayerMode()
            } else {
                self.gameScene?.disableMultiplayerMode()
            }
        }

        /// Checks if multiplayer mode is currently enabled
        /// - Returns: True if multiplayer mode is active
        public func isMultiplayerModeEnabled() -> Bool {
            // This would need to be implemented in GameScene to check the current state
            // For now, return false as a placeholder
            false
        }
    }

#elseif os(macOS)
    import Cocoa

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
        }

        /// Enables multiplayer mode for the game
        /// - Parameter enabled: Whether to enable or disable multiplayer
        public func setMultiplayerMode(_ enabled: Bool) {
            if enabled {
                self.gameScene?.enableMultiplayerMode()
            } else {
                self.gameScene?.disableMultiplayerMode()
            }
        }

        /// Checks if multiplayer mode is currently enabled
        /// - Returns: True if multiplayer mode is active
        public func isMultiplayerModeEnabled() -> Bool {
            // This would need to be implemented in GameScene to check the current state
            // For now, return false as a placeholder
            false
        }
    }
#endif
