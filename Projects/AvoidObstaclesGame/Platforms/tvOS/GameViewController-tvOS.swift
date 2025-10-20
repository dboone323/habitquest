//
//  GameViewController-tvOS.swift
//  AvoidObstaclesGame-tvOS
//
//  Created by Daniel on 2025-01-19.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SpriteKit
import UIKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view
        let skView = self.view as! SKView

        // Configure SpriteKit view for tvOS
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true

        // Create and configure the scene
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill

        // Present the scene
        skView.presentScene(scene)

        // Set up tvOS-specific input handling
        setupTVOSInputHandling()
    }

    /// Sets up tvOS-specific input handling including Siri Remote gestures
    private func setupTVOSInputHandling() {
        // Enable focus-based navigation
        view.window?.rootViewController?.navigationController?.navigationBar.isHidden = true

        // Set up gesture recognizers for Siri Remote
        setupRemoteGestures()
    }

    /// Sets up gesture recognizers for enhanced Siri Remote control
    private func setupRemoteGestures() {
        // Swipe gesture recognizer for directional movement
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

        // Long press for special actions
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        view.addGestureRecognizer(longPress)

        // Pan gesture for continuous movement
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }

    /// Handles swipe gestures from Siri Remote
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let scene = (view as? SKView)?.scene as? GameScene else { return }

        switch gesture.direction {
        case .up:
            scene.handleRemoteInput(.up)
        case .down:
            scene.handleRemoteInput(.down)
        case .left:
            scene.handleRemoteInput(.left)
        case .right:
            scene.handleRemoteInput(.right)
        default:
            break
        }
    }

    /// Handles long press gestures for special actions
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let scene = (view as? SKView)?.scene as? GameScene else { return }

        // Long press could trigger pause or special ability
        scene.handleAction(.pause)
    }

    /// Handles pan gestures for continuous movement
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let scene = (view as? SKView)?.scene as? GameScene else { return }

        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .began:
            // Start continuous movement based on initial direction
            if abs(velocity.x) > abs(velocity.y) {
                // Horizontal movement
                scene.handleRemoteInput(velocity.x > 0 ? .right : .left)
            } else {
                // Vertical movement
                scene.handleRemoteInput(velocity.y > 0 ? .up : .down)
            }
        case .changed:
            // Update movement direction based on current velocity
            if abs(velocity.x) > abs(velocity.y) {
                scene.handleRemoteInput(velocity.x > 0 ? .right : .left)
            } else {
                scene.handleRemoteInput(velocity.y > 0 ? .up : .down)
            }
        case .ended:
            // Stop all movement
            scene.handleRemoteInput(.release)
        default:
            break
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)

        // Handle tvOS remote control input
        for press in presses {
            switch press.type {
            case .select:
                // Handle select button press
                if let scene = (view as? SKView)?.scene as? GameScene {
                    scene.handleRemoteInput(.select)
                }
            case .playPause:
                // Handle play/pause button
                if let scene = (view as? SKView)?.scene as? GameScene {
                    scene.handleRemoteInput(.playPause)
                }
            case .upArrow:
                // Handle up arrow
                if let scene = (view as? SKView)?.scene as? GameScene {
                    scene.handleRemoteInput(.up)
                }
            case .downArrow:
                // Handle down arrow
                if let scene = (view as? SKView)?.scene as? GameScene {
                    scene.handleRemoteInput(.down)
                }
            case .leftArrow:
                // Handle left arrow
                if let scene = (view as? SKView)?.scene as? GameScene {
                    scene.handleRemoteInput(.left)
                }
            case .rightArrow:
                // Handle right arrow
                if let scene = (view as? SKView)?.scene as? GameScene {
                    scene.handleRemoteInput(.right)
                }
            default:
                break
            }
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)

        // Handle button releases if needed
        for press in presses {
            switch press.type {
            case .select, .playPause, .upArrow, .downArrow, .leftArrow, .rightArrow:
                if let scene = (view as? SKView)?.scene as? GameScene {
                    scene.handleRemoteInput(.release)
                }
            default:
                break
            }
        }
    }
}
