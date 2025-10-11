//
// GameViewController.swift
// AvoidObstaclesGame
//
// Standard ViewController to load and present the GameScene.
//

import GameplayKit
import SpriteKit
import UIKit

/// The main view controller for AvoidObstaclesGame.
/// Responsible for loading and presenting the SpriteKit game scene.
public class GameViewController: UIViewController {
    /// Called after the controller's view is loaded into memory.
    /// Sets up and presents the main game scene.
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view as an SKView and present the game scene.
        if let view = view as? SKView {
            // Create and configure the scene to fill the screen.
            let scene = GameScene(size: view.bounds.size)
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
}
