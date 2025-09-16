//
//  ViewController.swift
//  CodingReviewer
//
//  Created by Quantum Automation on 2025-08-29.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the coding reviewer interface
        setupUI()
    }

    private func setupUI() {
        // Setup the main user interface for code review functionality
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
