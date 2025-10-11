//
// PerformanceOverlayManager.swift
// AvoidObstaclesGame
//
// Manages the performance monitoring overlay display.
// Component extracted from UIManager.swift
//

import SpriteKit

/// Manages the performance monitoring overlay
class PerformanceOverlayManager {
    // MARK: - Properties

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Performance monitoring overlay
    private var performanceOverlay: SKNode?
    private var fpsLabel: SKLabelNode?
    private var memoryLabel: SKLabelNode?
    private var qualityLabel: SKLabelNode?
    private var performanceUpdateTimer: Timer?

    /// Whether performance monitoring is enabled
    private var performanceMonitoringEnabled = false

    // MARK: - Initialization

    /// Initializes the performance overlay manager with a scene reference
    /// - Parameter scene: The game scene to add performance overlay to
    init(scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Performance Monitoring

    /// Enables or disables performance monitoring overlay
    /// - Parameter enabled: Whether to show performance stats
    func setPerformanceMonitoring(enabled: Bool) {
        self.performanceMonitoringEnabled = enabled

        if enabled {
            self.setupPerformanceOverlay()
            self.startPerformanceUpdates()
        } else {
            self.hidePerformanceOverlay()
            self.stopPerformanceUpdates()
        }
    }

    /// Toggles performance monitoring overlay
    func togglePerformanceMonitoring() {
        self.setPerformanceMonitoring(enabled: !self.performanceMonitoringEnabled)
    }

    /// Sets up the performance monitoring overlay
    private func setupPerformanceOverlay() {
        guard let scene else { return }

        // Create overlay container
        self.performanceOverlay = SKNode()
        self.performanceOverlay?.zPosition = 200 // Above everything else

        // FPS Label
        fpsLabel = SKLabelNode(fontNamed: "Menlo")
        fpsLabel?.text = "FPS: --"
        fpsLabel?.fontSize = 14
        fpsLabel?.fontColor = .green
        fpsLabel?.horizontalAlignmentMode = .left
        fpsLabel?.position = CGPoint(x: 10, y: scene.size.height - 30)

        // Memory Label
        memoryLabel = SKLabelNode(fontNamed: "Menlo")
        memoryLabel?.text = "MEM: -- MB"
        memoryLabel?.fontSize = 14
        memoryLabel?.fontColor = .cyan
        memoryLabel?.horizontalAlignmentMode = .left
        memoryLabel?.position = CGPoint(x: 10, y: scene.size.height - 50)

        // Quality Label
        qualityLabel = SKLabelNode(fontNamed: "Menlo")
        qualityLabel?.text = "QUAL: HIGH"
        qualityLabel?.fontSize = 14
        qualityLabel?.fontColor = .yellow
        qualityLabel?.horizontalAlignmentMode = .left
        qualityLabel?.position = CGPoint(x: 10, y: scene.size.height - 70)

        // Add background for readability
        let background = SKShapeNode(rectOf: CGSize(width: 120, height: 70))
        background.fillColor = .black.withAlphaComponent(0.7)
        background.strokeColor = .white.withAlphaComponent(0.3)
        background.lineWidth = 1
        background.position = CGPoint(x: 60, y: scene.size.height - 50)
        background.zPosition = -1

        self.performanceOverlay?.addChild(background)
        if let fpsLabel { self.performanceOverlay?.addChild(fpsLabel) }
        if let memoryLabel { self.performanceOverlay?.addChild(memoryLabel) }
        if let qualityLabel { self.performanceOverlay?.addChild(qualityLabel) }

        scene.addChild(self.performanceOverlay!)
    }

    /// Hides the performance monitoring overlay
    private func hidePerformanceOverlay() {
        self.performanceOverlay?.removeFromParent()
        self.performanceOverlay = nil
        self.fpsLabel = nil
        self.memoryLabel = nil
        self.qualityLabel = nil
    }

    /// Starts periodic performance updates
    private func startPerformanceUpdates() {
        self.performanceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updatePerformanceDisplay()
        }
    }

    /// Stops performance updates
    private func stopPerformanceUpdates() {
        self.performanceUpdateTimer?.invalidate()
        self.performanceUpdateTimer = nil
    }

    /// Updates the performance display with current stats
    private func updatePerformanceDisplay() {
        let stats = PerformanceManager.shared.getPerformanceStats()

        // Update FPS
        self.fpsLabel?.text = String(format: "FPS: %.1f", stats.averageFPS)
        self.fpsLabel?.fontColor = stats.averageFPS >= 55 ? .green : (stats.averageFPS >= 30 ? .yellow : .red)

        // Update Memory
        let memoryMB = Double(stats.currentMemoryUsage) / (1024 * 1024)
        self.memoryLabel?.text = String(format: "MEM: %.1f MB", memoryMB)
        self.memoryLabel?.fontColor = memoryMB < 50 ? .cyan : (memoryMB < 100 ? .yellow : .red)

        // Update Quality
        switch stats.currentQualityLevel {
        case .high:
            self.qualityLabel?.text = "QUAL: HIGH"
            self.qualityLabel?.fontColor = .green
        case .medium:
            self.qualityLabel?.text = "QUAL: MED"
            self.qualityLabel?.fontColor = .yellow
        case .low:
            self.qualityLabel?.text = "QUAL: LOW"
            self.qualityLabel?.fontColor = .red
        }
    }

    // MARK: - Cleanup

    /// Removes all performance overlay elements from the scene
    func removeAllPerformanceElements() {
        self.hidePerformanceOverlay()
        self.stopPerformanceUpdates()
    }
}
