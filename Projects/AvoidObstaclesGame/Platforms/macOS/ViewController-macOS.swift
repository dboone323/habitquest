//
//  ViewController-macOS.swift
//  AvoidObstaclesGame-macOS
//
//  Created by Daniel on 2025-01-19.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.width, .height]
        view.addSubview(skView)

        // Load the SKScene from 'GameScene.sks'
        if let scene = SKScene(fileNamed: "GameScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill

            // Present the scene
            skView.presentScene(scene)
        }

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        // Make the view controller the window's first responder for keyboard input
        view.window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        // Handle keyboard input for macOS
        switch event.keyCode {
        case 123: // Left arrow
            // Handle left movement
            break
        case 124: // Right arrow
            // Handle right movement
            break
        case 125: // Down arrow
            // Handle down movement
            break
        case 126: // Up arrow
            // Handle up movement
            break
        default:
            break
        }
    }

    override func mouseDown(with event: NSEvent) {
        // Handle mouse input for macOS
        let location = event.locationInWindow
        let skLocation = skView.convert(location, from: nil)

        // Pass touch event to game scene
        if let scene = skView.scene as? GameScene {
            scene.handleMouseDown(at: skLocation)
        }
    }
}
