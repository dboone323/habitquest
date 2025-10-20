//
// SettingsManager.swift
// AvoidObstaclesGame
//
// Comprehensive settings UI manager with sections for gameplay, audio, controls, accessibility, and advanced options.
//

import Foundation
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Settings section types
enum SettingsSection: String, CaseIterable {
    case gameplay = "Gameplay"
    case audio = "Audio"
    case controls = "Controls"
    case accessibility = "Accessibility"
    case advanced = "Advanced"
}

/// Settings option types
enum SettingsOptionType {
    case toggle(Bool)
    case slider(Float, Float, Float) // value, min, max
    case selection([String], Int) // options, selectedIndex
    case button(String) // action title
}

/// Individual settings option
struct SettingsOption {
    let key: String
    let title: String
    let description: String?
    var type: SettingsOptionType
}

/// Settings data structure
struct SettingsData: Codable {
    var gameplay: GameplaySettings
    var audio: AudioSettings
    var controls: ControlsSettings
    var accessibility: AccessibilitySettings
    var advanced: AdvancedSettings

    struct GameplaySettings: Codable {
        var difficulty: Int
        var tutorialEnabled: Bool
        var showHUD: Bool
        var autoSave: Bool
    }

    struct AudioSettings: Codable {
        var masterVolume: Float
        var musicVolume: Float
        var sfxVolume: Float
        var voiceVolume: Float
    }

    struct ControlsSettings: Codable {
        var sensitivity: Float
        var invertY: Bool
        var vibrationEnabled: Bool
        var controlScheme: Int
    }

    struct AccessibilitySettings: Codable {
        var highContrast: Bool
        var largeText: Bool
        var reducedMotion: Bool
        var colorBlindMode: Int
        var hapticEnabled: Bool
        var hapticIntensity: Float
    }

    struct AdvancedSettings: Codable {
        var showPerformanceStats: Bool
        var frameRateLimit: Int
        var qualityPreset: Int
        var debugMode: Bool
    }
}

/// Settings delegate protocol
@MainActor
protocol SettingsManagerDelegate: AnyObject {
    func settingsDidChange(_ settings: SettingsData)
    func settingsDidClose()
}

/// Comprehensive settings UI manager
@MainActor
class SettingsManager {
    // MARK: - Properties

    /// Delegate for settings events
    weak var delegate: SettingsManagerDelegate?

    /// Reference to the haptic manager
    private let hapticManager = HapticManager.shared

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Settings overlay node
    private var settingsOverlay: SKNode?

    /// Current settings section
    private var currentSection: SettingsSection = .gameplay

    /// Settings data organized by section
    private var settingsData: [SettingsSection: [SettingsOption]] = [:]

    /// UI elements
    private var sectionButtons: [SettingsSection: SKLabelNode] = [:]
    private var optionNodes: [String: SKNode] = [:]
    private var backButton: SKLabelNode?
    private var closeButton: SKLabelNode?

    /// Animation actions
    private let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
    private let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)

    // MARK: - Initialization

    /// Initializes the settings manager
    /// - Parameter scene: The game scene to display settings in
    init(scene: SKScene) {
        self.scene = scene
        self.setupSettingsData()

        // Initialize haptic settings from HapticManager
        setSetting("hapticEnabled", value: hapticManager.getHapticEnabled())
        setSetting("hapticIntensity", value: hapticManager.getHapticIntensity())

        self.loadSettings()
    }

    // MARK: - Settings Persistence

    /// UserDefaults key for storing settings
    private let settingsKey = "AvoidObstaclesGame_Settings"

    /// Saves current settings to UserDefaults
    private func saveSettings() {
        let settings = getCurrentSettings()
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            UserDefaults.standard.set(data, forKey: settingsKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Failed to save settings: \(error)")
        }
    }

    /// Loads settings from UserDefaults
    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: settingsKey) else {
            // No saved settings, use defaults
            return
        }

        do {
            let decoder = JSONDecoder()
            let savedSettings = try decoder.decode(SettingsData.self, from: data)
            applySettings(savedSettings)
        } catch {
            print("Failed to load settings: \(error)")
            // Fall back to defaults if loading fails
        }
    }

    /// Applies loaded settings to the current settings data
    /// - Parameter settings: The settings to apply
    private func applySettings(_ settings: SettingsData) {
        // Apply gameplay settings
        setSetting("difficulty", value: settings.gameplay.difficulty)
        setSetting("tutorialEnabled", value: settings.gameplay.tutorialEnabled)
        setSetting("showHUD", value: settings.gameplay.showHUD)
        setSetting("autoSave", value: settings.gameplay.autoSave)

        // Apply audio settings
        setSetting("masterVolume", value: settings.audio.masterVolume)
        setSetting("musicVolume", value: settings.audio.musicVolume)
        setSetting("sfxVolume", value: settings.audio.sfxVolume)
        setSetting("voiceVolume", value: settings.audio.voiceVolume)

        // Apply controls settings
        setSetting("sensitivity", value: settings.controls.sensitivity)
        setSetting("invertY", value: settings.controls.invertY)
        setSetting("vibrationEnabled", value: settings.controls.vibrationEnabled)
        setSetting("controlScheme", value: settings.controls.controlScheme)

        // Apply accessibility settings
        setSetting("highContrast", value: settings.accessibility.highContrast)
        setSetting("largeText", value: settings.accessibility.largeText)
        setSetting("reducedMotion", value: settings.accessibility.reducedMotion)
        setSetting("colorBlindMode", value: settings.accessibility.colorBlindMode)
        setSetting("hapticEnabled", value: settings.accessibility.hapticEnabled)
        setSetting("hapticIntensity", value: settings.accessibility.hapticIntensity)

        // Apply advanced settings
        setSetting("showPerformanceStats", value: settings.advanced.showPerformanceStats)
        setSetting("frameRateLimit", value: settings.advanced.frameRateLimit)
        setSetting("qualityPreset", value: settings.advanced.qualityPreset)
        setSetting("debugMode", value: settings.advanced.debugMode)
    }

    /// Resets all settings to defaults
    func resetToDefaults() {
        // Clear saved settings
        UserDefaults.standard.removeObject(forKey: settingsKey)
        UserDefaults.standard.synchronize()

        // Reinitialize with default values
        setupSettingsData()

        // Reset haptic settings to defaults
        hapticManager.setHapticEnabled(true)
        hapticManager.setHapticIntensity(1.0)
        setSetting("hapticEnabled", value: true)
        setSetting("hapticIntensity", value: 1.0)

        // Notify delegate
        delegate?.settingsDidChange(getCurrentSettings())
    }

    // MARK: - Settings Data Setup

    /// Sets up the settings data structure
    private func setupSettingsData() {
        // Gameplay Settings
        settingsData[.gameplay] = [
            SettingsOption(
                key: "difficulty",
                title: "Difficulty Level",
                description: "Adjust the game's difficulty",
                type: .selection(["Easy", "Balanced", "Hard", "Expert"], 1)
            ),
            SettingsOption(
                key: "tutorialEnabled",
                title: "Show Tutorials",
                description: "Enable interactive tutorials for new players",
                type: .toggle(true)
            ),
            SettingsOption(
                key: "showHUD",
                title: "Show HUD",
                description: "Display game interface elements",
                type: .toggle(true)
            ),
            SettingsOption(
                key: "autoSave",
                title: "Auto-Save Progress",
                description: "Automatically save game progress",
                type: .toggle(true)
            ),
        ]

        // Audio Settings
        settingsData[.audio] = [
            SettingsOption(
                key: "masterVolume",
                title: "Master Volume",
                description: "Overall audio volume",
                type: .slider(0.8, 0.0, 1.0)
            ),
            SettingsOption(
                key: "musicVolume",
                title: "Music Volume",
                description: "Background music volume",
                type: .slider(0.6, 0.0, 1.0)
            ),
            SettingsOption(
                key: "sfxVolume",
                title: "Sound Effects",
                description: "Game sound effects volume",
                type: .slider(0.7, 0.0, 1.0)
            ),
            SettingsOption(
                key: "voiceVolume",
                title: "Voice Volume",
                description: "Voice guidance volume",
                type: .slider(0.8, 0.0, 1.0)
            ),
        ]

        // Controls Settings
        settingsData[.controls] = [
            SettingsOption(
                key: "controlScheme",
                title: "Control Scheme",
                description: "Choose your preferred control method",
                type: .selection(["Touch", "Swipe", "Tilt"], 0)
            ),
            SettingsOption(
                key: "sensitivity",
                title: "Control Sensitivity",
                description: "Adjust control responsiveness",
                type: .slider(0.5, 0.1, 1.0)
            ),
            SettingsOption(
                key: "invertY",
                title: "Invert Controls",
                description: "Reverse control directions",
                type: .toggle(false)
            ),
            SettingsOption(
                key: "vibrationEnabled",
                title: "Vibration Feedback",
                description: "Enable haptic feedback",
                type: .toggle(true)
            ),
        ]

        // Accessibility Settings
        settingsData[.accessibility] = [
            SettingsOption(
                key: "highContrast",
                title: "High Contrast Mode",
                description: "Increase contrast for better visibility",
                type: .toggle(false)
            ),
            SettingsOption(
                key: "largeText",
                title: "Large Text",
                description: "Use larger fonts for better readability",
                type: .toggle(false)
            ),
            SettingsOption(
                key: "reducedMotion",
                title: "Reduced Motion",
                description: "Minimize animations and transitions",
                type: .toggle(false)
            ),
            SettingsOption(
                key: "colorBlindMode",
                title: "Color Blind Support",
                description: "Adjust colors for color blindness",
                type: .selection(["None", "Deuteranopia", "Protanopia", "Tritanopia"], 0)
            ),
            SettingsOption(
                key: "hapticEnabled",
                title: "Haptic Feedback",
                description: "Enable vibration feedback for interactions",
                type: .toggle(true)
            ),
            SettingsOption(
                key: "hapticIntensity",
                title: "Haptic Intensity",
                description: "Adjust the strength of haptic feedback",
                type: .slider(1.0, 0.1, 1.0)
            ),
        ]

        // Advanced Settings
        settingsData[.advanced] = [
            SettingsOption(
                key: "showPerformanceStats",
                title: "Performance Monitor",
                description: "Show FPS and memory usage",
                type: .toggle(false)
            ),
            SettingsOption(
                key: "frameRateLimit",
                title: "Frame Rate Limit",
                description: "Limit maximum frame rate",
                type: .selection(["30 FPS", "60 FPS", "120 FPS", "Unlimited"], 1)
            ),
            SettingsOption(
                key: "qualityPreset",
                title: "Quality Preset",
                description: "Graphics quality settings",
                type: .selection(["Low", "Medium", "High", "Ultra"], 2)
            ),
            SettingsOption(
                key: "debugMode",
                title: "Debug Mode",
                description: "Enable developer debugging features",
                type: .toggle(false)
            ),
            SettingsOption(
                key: "resetSettings",
                title: "Reset to Defaults",
                description: "Restore all settings to default values",
                type: .button("Reset")
            ),
        ]
    }

    // MARK: - UI Management

    /// Shows the settings overlay
    func showSettings() {
        guard let scene else { return }

        // Hide existing overlay if present
        hideSettings()

        // Create main overlay
        settingsOverlay = SKNode()
        settingsOverlay?.zPosition = 1000

        // Create background overlay
        let background = SKShapeNode(rectOf: scene.size)
        background.fillColor = .black.withAlphaComponent(0.7)
        background.strokeColor = .clear
        background.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        background.zPosition = 0
        settingsOverlay?.addChild(background)

        // Create settings panel
        let panelSize = CGSize(width: scene.size.width * 0.8, height: scene.size.height * 0.8)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 10)
        panel.fillColor = .white
        panel.strokeColor = .gray
        panel.lineWidth = 2
        panel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        panel.zPosition = 1
        settingsOverlay?.addChild(panel)

        // Create close button
        closeButton = SKLabelNode(fontNamed: "Arial-Bold")
        closeButton?.text = "✕"
        closeButton?.fontSize = 24
        closeButton?.fontColor = .black
        closeButton?.position = CGPoint(x: panelSize.width / 2 - 20, y: panelSize.height / 2 - 20)
        closeButton?.zPosition = 2
        panel.addChild(closeButton!)

        // Create section buttons
        createSectionButtons(in: panel, panelSize: panelSize)

        // Show current section
        showSection(currentSection, in: panel, panelSize: panelSize)

        // Add to scene
        scene.addChild(settingsOverlay!)
    }

    /// Hides the settings overlay
    func hideSettings() {
        settingsOverlay?.run(SKAction.sequence([
            fadeOutAction,
            SKAction.removeFromParent(),
        ]))
        settingsOverlay = nil
        sectionButtons.removeAll()
        optionNodes.removeAll()
        backButton?.removeFromParent()
        backButton = nil
        closeButton?.removeFromParent()
        closeButton = nil

        delegate?.settingsDidClose()
    }

    /// Checks if settings overlay is currently visible
    /// - Returns: True if settings are visible
    func isSettingsVisible() -> Bool {
        settingsOverlay != nil
    }

    /// Creates section navigation buttons
    /// - Parameters:
    ///   - panel: The settings panel node
    ///   - panelSize: Size of the panel
    private func createSectionButtons(in panel: SKShapeNode, panelSize: CGSize) {
        let sectionCount = SettingsSection.allCases.count
        let buttonWidth = panelSize.width / CGFloat(sectionCount)
        let buttonY = panelSize.height / 2 - 50

        for (index, section) in SettingsSection.allCases.enumerated() {
            let button = SKLabelNode(fontNamed: "Arial-Bold")
            button.text = section.rawValue
            button.fontSize = 16
            button.fontColor = currentSection == section ? .blue : .black
            button.position = CGPoint(x: -panelSize.width / 2 + buttonWidth * (CGFloat(index) + 0.5), y: buttonY)
            button.zPosition = 2
            button.name = "section_\(section.rawValue)"

            panel.addChild(button)
            sectionButtons[section] = button
        }
    }

    /// Shows a specific settings section
    /// - Parameters:
    ///   - section: The section to show
    ///   - panel: The settings panel node
    ///   - panelSize: Size of the panel
    private func showSection(_ section: SettingsSection, in panel: SKShapeNode, panelSize: CGSize) {
        // Clear existing options
        for (_, node) in optionNodes {
            node.removeFromParent()
        }
        optionNodes.removeAll()

        guard let options = settingsData[section] else { return }

        let startY = panelSize.height / 2 - 100
        let spacing: CGFloat = 60

        for (index, option) in options.enumerated() {
            let optionNode = createOptionNode(for: option, at: CGPoint(x: 0, y: startY - CGFloat(index) * spacing), in: panel)
            optionNodes[option.key] = optionNode
        }
    }

    /// Creates a UI node for a settings option
    /// - Parameters:
    ///   - option: The settings option
    ///   - position: Position within the panel
    ///   - panel: The panel node
    /// - Returns: The created option node
    private func createOptionNode(for option: SettingsOption, at position: CGPoint, in panel: SKShapeNode) -> SKNode {
        let optionNode = SKNode()
        optionNode.position = position
        optionNode.zPosition = 2

        // Title label
        let titleLabel = SKLabelNode(fontNamed: "Arial-Bold")
        titleLabel.text = option.title
        titleLabel.fontSize = 18
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: -150, y: 10)
        titleLabel.horizontalAlignmentMode = .left
        optionNode.addChild(titleLabel)

        // Description label (if present)
        if let description = option.description {
            let descLabel = SKLabelNode(fontNamed: "Arial")
            descLabel.text = description
            descLabel.fontSize = 12
            descLabel.fontColor = .gray
            descLabel.position = CGPoint(x: -150, y: -10)
            descLabel.horizontalAlignmentMode = .left
            optionNode.addChild(descLabel)
        }

        // Control based on type
        switch option.type {
        case let .toggle(value):
            let toggleLabel = SKLabelNode(fontNamed: "Arial-Bold")
            toggleLabel.text = value ? "✓" : "○"
            toggleLabel.fontSize = 20
            toggleLabel.fontColor = value ? .green : .gray
            toggleLabel.position = CGPoint(x: 150, y: 0)
            toggleLabel.name = "toggle_\(option.key)"
            optionNode.addChild(toggleLabel)

        case let .slider(value, _, _):
            let sliderLabel = SKLabelNode(fontNamed: "Arial")
            sliderLabel.text = String(format: "%.1f", value)
            sliderLabel.fontSize = 16
            sliderLabel.fontColor = .black
            sliderLabel.position = CGPoint(x: 150, y: 0)
            sliderLabel.name = "slider_\(option.key)"
            optionNode.addChild(sliderLabel)

        case let .selection(options, selectedIndex):
            let selectionLabel = SKLabelNode(fontNamed: "Arial")
            selectionLabel.text = options[selectedIndex]
            selectionLabel.fontSize = 16
            selectionLabel.fontColor = .black
            selectionLabel.position = CGPoint(x: 150, y: 0)
            selectionLabel.name = "selection_\(option.key)"
            optionNode.addChild(selectionLabel)

        case let .button(actionTitle):
            let buttonLabel = SKLabelNode(fontNamed: "Arial-Bold")
            buttonLabel.text = actionTitle
            buttonLabel.fontSize = 16
            buttonLabel.fontColor = .blue
            buttonLabel.position = CGPoint(x: 150, y: 0)
            buttonLabel.name = "button_\(option.key)"
            optionNode.addChild(buttonLabel)
        }

        panel.addChild(optionNode)
        return optionNode
    }

    /// Handles touch events within the settings overlay
    /// - Parameter location: Touch location in scene coordinates
    func handleTouch(at location: CGPoint) {
        guard let settingsOverlay, let scene else { return }

        // Convert scene coordinates to overlay coordinates
        let overlayLocation = scene.convert(location, to: settingsOverlay)

        // Check close button
        if let closeButton, closeButton.contains(overlayLocation) {
            hapticManager.playButtonTapHaptic()
            hideSettings()
            return
        }

        // Check section buttons
        for (section, button) in sectionButtons {
            if button.contains(overlayLocation) {
                hapticManager.playMenuNavigationHaptic()
                switchToSection(section)
                return
            }
        }

        // Check option controls
        for (key, node) in optionNodes {
            let nodeLocation = scene.convert(location, to: node)

            // Find the control within the option node
            for child in node.children {
                if let label = child as? SKLabelNode, label.contains(nodeLocation) {
                    handleOptionTap(key: key, label: label)
                    return
                }
            }
        }
    }

    /// Switches to a different settings section
    /// - Parameter section: The section to switch to
    private func switchToSection(_ section: SettingsSection) {
        // Update button colors
        for (sectionType, button) in sectionButtons {
            button.fontColor = sectionType == section ? .blue : .black
        }

        currentSection = section

        // Update panel content
        if let panel = settingsOverlay?.children.first(where: { $0 is SKShapeNode && $0.zPosition == 1 }) as? SKShapeNode {
            let panelSize = panel.frame.size
            showSection(section, in: panel, panelSize: panelSize)
        }
    }

    /// Handles tapping on an option control
    /// - Parameters:
    ///   - key: The option key
    ///   - label: The tapped label
    private func handleOptionTap(key: String, label: SKLabelNode) {
        guard let option = findOption(by: key) else { return }

        // Play haptic feedback for interaction
        hapticManager.playButtonTapHaptic()

        switch option.type {
        case let .toggle(currentValue):
            let newValue = !currentValue
            setSetting(key, value: newValue)
            label.text = newValue ? "✓" : "○"
            label.fontColor = newValue ? .green : .gray

            // Special handling for haptic settings
            if key == "hapticEnabled" {
                hapticManager.setHapticEnabled(newValue)
            }

        case let .slider(currentValue, minValue, maxValue):
            // Simple increment/decrement for demo
            let step: Float = (maxValue - minValue) / 10
            let newValue = Swift.min(Swift.max(currentValue + step, minValue), maxValue)
            setSetting(key, value: newValue)
            label.text = String(format: "%.1f", newValue)

            // Special handling for haptic intensity
            if key == "hapticIntensity" {
                hapticManager.setHapticIntensity(newValue)
                // Play haptic to demonstrate the new intensity
                hapticManager.playSelectionChangeHaptic()
            }

        case let .selection(options, currentIndex):
            let newIndex = (currentIndex + 1) % options.count
            setSetting(key, value: newIndex)
            label.text = options[newIndex]

            // Play selection change haptic
            hapticManager.playSelectionChangeHaptic()

        case .button:
            handleButtonAction(key: key)
        }

        // Notify delegate with updated settings
        delegate?.settingsDidChange(getCurrentSettings())

        // Save settings to UserDefaults
        saveSettings()
    }

    /// Finds an option by its key
    /// - Parameter key: The option key
    /// - Returns: The settings option, or nil if not found
    private func findOption(by key: String) -> SettingsOption? {
        for options in settingsData.values {
            if let option = options.first(where: { $0.key == key }) {
                return option
            }
        }
        return nil
    }

    /// Handles button action taps
    /// - Parameter key: The button key
    private func handleButtonAction(key: String) {
        switch key {
        case "resetSettings":
            resetToDefaults()
            // Refresh the UI to show default values
            if let panel = settingsOverlay?.children.first(where: { $0 is SKShapeNode && $0.zPosition == 1 }) as? SKShapeNode {
                let panelSize = panel.frame.size
                showSection(currentSection, in: panel, panelSize: panelSize)
            }

        case "resetProgress":
            // Show confirmation dialog (simplified for now)
            print("Reset progress action triggered")

        case "exportData":
            // Export data action
            print("Export data action triggered")

        default:
            break
        }
    }

    // MARK: - Settings Management

    /// Gets the current settings as a structured data object
    /// - Returns: Current settings data
    func getCurrentSettings() -> SettingsData {
        SettingsData(
            gameplay: SettingsData.GameplaySettings(
                difficulty: getSetting("difficulty") as? Int ?? 1,
                tutorialEnabled: getSetting("tutorialEnabled") as? Bool ?? true,
                showHUD: getSetting("showHUD") as? Bool ?? true,
                autoSave: getSetting("autoSave") as? Bool ?? true
            ),
            audio: SettingsData.AudioSettings(
                masterVolume: getSetting("masterVolume") as? Float ?? 0.8,
                musicVolume: getSetting("musicVolume") as? Float ?? 0.6,
                sfxVolume: getSetting("sfxVolume") as? Float ?? 0.7,
                voiceVolume: getSetting("voiceVolume") as? Float ?? 0.8
            ),
            controls: SettingsData.ControlsSettings(
                sensitivity: getSetting("sensitivity") as? Float ?? 0.5,
                invertY: getSetting("invertY") as? Bool ?? false,
                vibrationEnabled: getSetting("vibrationEnabled") as? Bool ?? true,
                controlScheme: getSetting("controlScheme") as? Int ?? 0
            ),
            accessibility: SettingsData.AccessibilitySettings(
                highContrast: getSetting("highContrast") as? Bool ?? false,
                largeText: getSetting("largeText") as? Bool ?? false,
                reducedMotion: getSetting("reducedMotion") as? Bool ?? false,
                colorBlindMode: getSetting("colorBlindMode") as? Int ?? 0,
                hapticEnabled: getSetting("hapticEnabled") as? Bool ?? true,
                hapticIntensity: getSetting("hapticIntensity") as? Float ?? 1.0
            ),
            advanced: SettingsData.AdvancedSettings(
                showPerformanceStats: getSetting("showPerformanceStats") as? Bool ?? false,
                frameRateLimit: getSetting("frameRateLimit") as? Int ?? 1,
                qualityPreset: getSetting("qualityPreset") as? Int ?? 2,
                debugMode: getSetting("debugMode") as? Bool ?? false
            )
        )
    }

    /// Gets the current value of a setting
    /// - Parameter key: The setting key
    /// - Returns: The current value, or nil if not found
    func getSetting(_ key: String) -> Any? {
        for options in settingsData.values {
            if let option = options.first(where: { $0.key == key }) {
                switch option.type {
                case let .toggle(value):
                    return value
                case let .slider(value, _, _):
                    return value
                case let .selection(_, selectedIndex):
                    return selectedIndex
                case .button:
                    return nil
                }
            }
        }
        return nil
    }

    /// Sets a setting value
    /// - Parameters:
    ///   - key: The setting key
    ///   - value: The new value
    func setSetting(_ key: String, value: Any) {
        for (section, options) in settingsData {
            if let index = options.firstIndex(where: { $0.key == key }) {
                var option = options[index]

                switch option.type {
                case .toggle:
                    if let boolValue = value as? Bool {
                        option.type = .toggle(boolValue)
                    }
                case let .slider(_, min, max):
                    if let floatValue = value as? Float {
                        option.type = .slider(floatValue, min, max)
                    }
                case let .selection(options, _):
                    if let intValue = value as? Int, intValue >= 0 && intValue < options.count {
                        option.type = .selection(options, intValue)
                    }
                case .button:
                    break
                }

                settingsData[section]?[index] = option
            }
        }
    }
}
