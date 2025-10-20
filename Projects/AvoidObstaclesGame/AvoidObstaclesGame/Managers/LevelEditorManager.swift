//
// LevelEditorManager.swift
// AvoidObstaclesGame
//
// Manages level editing functionality for user-generated content creation
//

import Combine
import Foundation
import SpriteKit

// MARK: - Level Editor Types

/// Represents a custom user-created level
struct CustomLevel: Codable, Identifiable {
    /// Unique identifier for the level
    let id: String

    /// Display name of the level
    var name: String

    /// Difficulty level (simplified as string for now)
    var difficulty: String

    /// Date the level was created
    let createdDate: Date

    /// Date the level was last modified
    var modifiedDate: Date

    /// Elements placed in the level
    var elements: [PlacedLevelElement]

    /// Level-specific settings
    var settings: LevelSettings

    /// Computed property for Identifiable conformance
    var identifier: String { id }
}

/// Settings for a custom level
struct LevelSettings: Codable {
    /// Target completion time in seconds (optional)
    var targetTime: TimeInterval?

    /// Maximum number of lives allowed
    var maxLives: Int = 3

    /// Background theme
    var backgroundTheme: BackgroundTheme = .space

    /// Music track for the level
    var musicTrack: String?

    /// Whether the level allows power-ups
    var allowPowerUps: Bool = true

    /// Whether the level has dynamic difficulty scaling
    var dynamicDifficulty: Bool = true

    /// Minimum score required to pass
    var minimumScore: Int = 0
}

/// Background themes for levels
enum BackgroundTheme: String, Codable, CaseIterable {
    case space
    case ocean
    case forest
    case desert
    case city
    case nebula

    var displayName: String {
        switch self {
        case .space: return "Space"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        case .desert: return "Desert"
        case .city: return "City"
        case .nebula: return "Nebula"
        }
    }
}

/// An element that can be placed in a level
struct LevelElement: Identifiable {
    /// Unique identifier
    var id = UUID()

    /// Type of the element
    let type: LevelElementType

    /// Display name for UI
    let displayName: String

    /// Icon name for UI representation
    let iconName: String

    /// Whether this element can be rotated
    var canRotate: Bool {
        switch type {
        case .obstacle(.moving), .obstacle(.pulsing), .obstacle(.rotating):
            return true
        case .powerUp, .playerStart, .finishLine:
            return false
        case .obstacle(.spike), .obstacle(.block), .obstacle(.bouncing), .obstacle(.teleporting), .obstacle(.splitting), .obstacle(.laser):
            return true
        }
    }

    /// Whether this element can be scaled
    var canScale: Bool {
        switch type {
        case .obstacle, .powerUp:
            return true
        case .playerStart, .finishLine:
            return false
        }
    }
}

/// Types of elements that can be placed in levels
enum LevelElementType: Codable, Hashable, Equatable {
    case obstacle(ObstacleType)
    case powerUp(PowerUpType)
    case playerStart
    case finishLine

    enum ObstacleType: String, Codable {
        case spike, block, moving, pulsing, rotating, bouncing, teleporting, splitting, laser
    }

    enum PowerUpType: String, Codable {
        case shield, speed, magnet, slowMotion, multiBall, laser, freeze, teleport, scoreMultiplier, timeBonus
    }
}

/// A placed instance of a level element
struct PlacedLevelElement: Codable, Identifiable {
    /// Unique identifier for this placement
    let id: String

    /// The element being placed
    let element: LevelElement

    /// Position in the level
    var position: CGPoint

    /// Rotation in radians
    var rotation: CGFloat

    /// Scale factor
    var scale: CGFloat

    /// Computed property for Identifiable conformance
    var identifier: String { id }

    init(id: String, element: LevelElement, position: CGPoint, rotation: CGFloat = 0, scale: CGFloat = 1.0) {
        self.id = id
        self.element = element
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, element, position, rotation, scale
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        element = try container.decode(LevelElement.self, forKey: .element)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        scale = try container.decode(CGFloat.self, forKey: .scale)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(element, forKey: .element)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(scale, forKey: .scale)
    }
}

// MARK: - Codable Extensions

extension LevelElement: Codable {
    enum CodingKeys: String, CodingKey {
        case id, type, displayName, iconName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(LevelElementType.self, forKey: .type)
        displayName = try container.decode(String.self, forKey: .displayName)
        iconName = try container.decode(String.self, forKey: .iconName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(iconName, forKey: .iconName)
    }
}

// MARK: - Equatable Extensions

extension CustomLevel: Equatable {
    static func == (lhs: CustomLevel, rhs: CustomLevel) -> Bool {
        lhs.id == rhs.id
    }
}

extension LevelElement: Equatable {
    static func == (lhs: LevelElement, rhs: LevelElement) -> Bool {
        lhs.id == rhs.id
    }
}

extension PlacedLevelElement: Equatable {
    static func == (lhs: PlacedLevelElement, rhs: PlacedLevelElement) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Level Editor Types
@MainActor
protocol LevelEditorDelegate: AnyObject {
    func levelEditorDidSaveLevel(_ level: CustomLevel)
    func levelEditorDidLoadLevel(_ level: CustomLevel)
    func levelEditorDidCreateNewLevel()
    func levelEditorDidDeleteLevel(named: String)
}

/// Manages level editing functionality
@MainActor
final class LevelEditorManager {
    // MARK: - Properties

    /// Delegate for level editor events
    weak var delegate: LevelEditorDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Current level being edited
    private(set) var currentLevel: CustomLevel?

    /// Available level elements for placement
    private(set) var availableElements: [LevelElement] = []

    /// Currently selected element for placement
    private(set) var selectedElement: LevelElement?

    /// Level editor UI overlay
    private var editorOverlay: LevelEditorOverlay?

    /// Is editor currently active
    private(set) var isEditing = false

    /// Publisher for editor state changes
    let editorStatePublisher = PassthroughSubject<LevelEditorState, Never>()

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        setupAvailableElements()
    }

    /// Updates the scene reference
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    /// Updates the level editor manager
    func update(_ deltaTime: TimeInterval) {
        // Update editor-specific logic
        guard isEditing else { return }

        // Update visual feedback for selected elements
        updateElementHighlights()
    }

    // MARK: - Public Interface

    /// Starts the level editor
    func startEditing() {
        guard !isEditing else { return }

        isEditing = true
        createEditorOverlay()
        setupEditorScene()

        editorStatePublisher.send(.started)
        print("🎨 Level Editor started")
    }

    /// Stops the level editor
    func stopEditing() {
        guard isEditing else { return }

        isEditing = false
        removeEditorOverlay()
        restoreGameScene()

        editorStatePublisher.send(.stopped)
        print("🎨 Level Editor stopped")
    }

    /// Creates a new level
    func createNewLevel(name: String, difficulty: String = "Easy") {
        let newLevel = CustomLevel(
            id: UUID().uuidString,
            name: name,
            difficulty: difficulty,
            createdDate: Date(),
            modifiedDate: Date(),
            elements: [],
            settings: LevelSettings()
        )

        currentLevel = newLevel
        clearSceneElements()
        delegate?.levelEditorDidCreateNewLevel()

        editorStatePublisher.send(.levelCreated(newLevel))
        print("🎨 Created new level: \(name)")
    }

    /// Loads an existing level
    func loadLevel(_ level: CustomLevel) {
        currentLevel = level
        loadLevelElements(level.elements)
        delegate?.levelEditorDidLoadLevel(level)

        editorStatePublisher.send(.levelLoaded(level))
        print("🎨 Loaded level: \(level.name)")
    }

    /// Saves the current level
    func saveCurrentLevel() {
        guard var level = currentLevel else {
            print("❌ No level to save")
            return
        }

        // Update level elements from scene
        updateLevelElementsFromScene()

        // Save to storage
        do {
            try saveLevelToStorage(level)
            level.modifiedDate = Date()
            currentLevel = level // Update the stored level
            delegate?.levelEditorDidSaveLevel(level)

            editorStatePublisher.send(.levelSaved(level))
            print("💾 Saved level: \(level.name)")
        } catch {
            print("❌ Failed to save level: \(error)")
            editorStatePublisher.send(.error(.saveFailed(error)))
        }
    }

    /// Deletes a level
    func deleteLevel(named name: String) {
        do {
            try deleteLevelFromStorage(named: name)
            delegate?.levelEditorDidDeleteLevel(named: name)

            editorStatePublisher.send(.levelDeleted(name))
            print("🗑️ Deleted level: \(name)")
        } catch {
            print("❌ Failed to delete level: \(error)")
            editorStatePublisher.send(.error(.deleteFailed(error)))
        }
    }

    /// Selects an element for placement
    func selectElement(_ element: LevelElement) {
        selectedElement = element
        updateElementHighlights()

        editorStatePublisher.send(.elementSelected(element))
        print("🎯 Selected element: \(element.type)")
    }

    /// Places the selected element at the specified position
    func placeElement(at position: CGPoint) {
        guard let element = selectedElement, var level = currentLevel else { return }

        let placedElement = PlacedLevelElement(
            id: UUID().uuidString,
            element: element,
            position: position,
            rotation: 0,
            scale: 1.0
        )

        level.elements.append(placedElement)
        currentLevel = level // Update the stored level
        addElementToScene(placedElement)

        editorStatePublisher.send(.elementPlaced(placedElement))
        print("📍 Placed element: \(element.type) at \(position)")
    }

    /// Removes an element at the specified position
    func removeElement(at position: CGPoint) {
        guard var level = currentLevel else { return }

        // Find element at position (with some tolerance)
        let tolerance: CGFloat = 30
        if let index = level.elements.firstIndex(where: {
            abs($0.position.x - position.x) < tolerance &&
                abs($0.position.y - position.y) < tolerance
        }) {
            let removedElement = level.elements.remove(at: index)
            currentLevel = level // Update the stored level
            removeElementFromScene(removedElement)

            editorStatePublisher.send(.elementRemoved(removedElement))
            print("🗑️ Removed element: \(removedElement.element.type)")
        }
    }

    /// Tests the current level
    func testCurrentLevel() {
        guard let level = currentLevel else {
            print("❌ No level to test")
            return
        }

        // Save current state
        saveCurrentLevel()

        // Switch to test mode
        editorStatePublisher.send(.testingStarted(level))
        print("🧪 Testing level: \(level.name)")
    }

    /// Stops testing and returns to editor
    func stopTesting() {
        editorStatePublisher.send(.testingStopped)
        print("🧪 Stopped testing")
    }

    // MARK: - Private Methods

    private func setupAvailableElements() {
        availableElements = [
            // Obstacles
            LevelElement(type: .obstacle(.spike), displayName: "Spike", iconName: "spike_icon"),
            LevelElement(type: .obstacle(.block), displayName: "Block", iconName: "block_icon"),
            LevelElement(type: .obstacle(.moving), displayName: "Moving Block", iconName: "moving_icon"),
            LevelElement(type: .obstacle(.pulsing), displayName: "Pulsing Block", iconName: "pulsing_icon"),
            LevelElement(type: .obstacle(.rotating), displayName: "Rotating Block", iconName: "rotating_icon"),
            LevelElement(type: .obstacle(.bouncing), displayName: "Bouncing Block", iconName: "bouncing_icon"),
            LevelElement(type: .obstacle(.teleporting), displayName: "Teleporting Block", iconName: "teleporting_icon"),
            LevelElement(type: .obstacle(.splitting), displayName: "Splitting Block", iconName: "splitting_icon"),
            LevelElement(type: .obstacle(.laser), displayName: "Laser", iconName: "laser_icon"),

            // Power-ups
            LevelElement(type: .powerUp(.shield), displayName: "Shield", iconName: "shield_icon"),
            LevelElement(type: .powerUp(.speed), displayName: "Speed Boost", iconName: "speed_icon"),
            LevelElement(type: .powerUp(.magnet), displayName: "Magnet", iconName: "magnet_icon"),
            LevelElement(type: .powerUp(.slowMotion), displayName: "Slow Motion", iconName: "slowmotion_icon"),
            LevelElement(type: .powerUp(.multiBall), displayName: "Multi Ball", iconName: "multiball_icon"),
            LevelElement(type: .powerUp(.laser), displayName: "Laser", iconName: "laser_powerup_icon"),
            LevelElement(type: .powerUp(.freeze), displayName: "Freeze", iconName: "freeze_icon"),
            LevelElement(type: .powerUp(.teleport), displayName: "Teleport", iconName: "teleport_icon"),
            LevelElement(type: .powerUp(.scoreMultiplier), displayName: "Score Multiplier", iconName: "multiplier_icon"),
            LevelElement(type: .powerUp(.timeBonus), displayName: "Time Bonus", iconName: "time_icon"),

            // Special elements
            LevelElement(type: .playerStart, displayName: "Player Start", iconName: "player_icon"),
            LevelElement(type: .finishLine, displayName: "Finish Line", iconName: "finish_icon"),
        ]
    }

    private func createEditorOverlay() {
        guard let scene else { return }

        editorOverlay = LevelEditorOverlay(size: scene.size)
        if let overlay = editorOverlay {
            scene.addChild(overlay)
        }
    }

    private func removeEditorOverlay() {
        editorOverlay?.removeFromParent()
        editorOverlay = nil
    }

    private func setupEditorScene() {
        // Disable normal game systems during editing
        // This would need coordination with other managers
    }

    private func restoreGameScene() {
        // Re-enable normal game systems
    }

    private func clearSceneElements() {
        // Remove all current level elements from scene
        scene?.children.filter { $0.name?.hasPrefix("level_element_") ?? false }
            .forEach { $0.removeFromParent() }
    }

    private func loadLevelElements(_ elements: [PlacedLevelElement]) {
        clearSceneElements()
        elements.forEach { addElementToScene($0) }
    }

    private func addElementToScene(_ placedElement: PlacedLevelElement) {
        guard let scene else { return }

        let node = createNodeForElement(placedElement)
        node.name = "level_element_\(placedElement.id)"
        node.position = placedElement.position
        node.zRotation = placedElement.rotation
        node.setScale(placedElement.scale)

        scene.addChild(node)
    }

    private func removeElementFromScene(_ placedElement: PlacedLevelElement) {
        scene?.childNode(withName: "level_element_\(placedElement.id)")?.removeFromParent()
    }

    private func createNodeForElement(_ placedElement: PlacedLevelElement) -> SKNode {
        switch placedElement.element.type {
        case let .obstacle(type):
            return createObstacleNode(for: type)
        case let .powerUp(type):
            return createPowerUpNode(for: type)
        case .playerStart:
            return createPlayerStartNode()
        case .finishLine:
            return createFinishLineNode()
        }
    }

    private func createObstacleNode(for type: LevelElementType.ObstacleType) -> SKNode {
        // Create a simple visual representation for the level editor
        let node: SKNode
        switch type {
        case .spike:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -5, y: -10))
            path.addLine(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: 5, y: -10))
            path.closeSubpath()
            let shape = SKShapeNode(path: path)
            shape.fillColor = .red
            shape.strokeColor = .white
            shape.lineWidth = 1
            node = shape
        case .laser:
            let shape = SKShapeNode(rectOf: CGSize(width: 50, height: 4))
            shape.fillColor = .white
            shape.strokeColor = .red
            shape.lineWidth = 1
            shape.glowWidth = 2
            node = shape
        default:
            let shape = SKShapeNode(rectOf: CGSize(width: 15, height: 15))
            shape.fillColor = .orange
            shape.strokeColor = .white
            shape.lineWidth = 1
            node = shape
        }
        return node
    }

    private func createPowerUpNode(for type: LevelElementType.PowerUpType) -> SKNode {
        // Create a simple visual representation for the level editor
        let shape = SKShapeNode(circleOfRadius: 8)
        shape.strokeColor = .white
        shape.lineWidth = 1

        switch type {
        case .shield:
            shape.fillColor = .blue
        case .speed:
            shape.fillColor = .green
        case .magnet:
            shape.fillColor = .yellow
        case .slowMotion:
            shape.fillColor = .purple
        default:
            shape.fillColor = .cyan
        }

        return shape
    }

    private func createPlayerStartNode() -> SKNode {
        let node = SKShapeNode(circleOfRadius: 20)
        node.fillColor = .green
        node.strokeColor = .white
        node.lineWidth = 2
        return node
    }

    private func createFinishLineNode() -> SKNode {
        let node = SKShapeNode(rectOf: CGSize(width: 10, height: 200))
        node.fillColor = .yellow
        node.strokeColor = .black
        node.lineWidth = 2
        return node
    }

    private func updateElementHighlights() {
        // Update visual highlights for selectable elements
        // This would add glow effects or selection indicators
    }

    private func updateLevelElementsFromScene() {
        // Update level elements based on current scene state
        // This would be called before saving
    }

    private func saveLevelToStorage(_ level: CustomLevel) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(level)

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let levelsURL = documentsURL.appendingPathComponent("CustomLevels")
        try fileManager.createDirectory(at: levelsURL, withIntermediateDirectories: true)

        let fileURL = levelsURL.appendingPathComponent("\(level.id).json")
        try data.write(to: fileURL)
    }

    private func deleteLevelFromStorage(named name: String) throws {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let levelsURL = documentsURL.appendingPathComponent("CustomLevels")

        let fileURLs = try fileManager.contentsOfDirectory(at: levelsURL, includingPropertiesForKeys: nil)
        if let levelFile = fileURLs.first(where: { $0.lastPathComponent.contains(name) }) {
            try fileManager.removeItem(at: levelFile)
        }
    }
}

// MARK: - Supporting Types

/// Represents the state of the level editor
enum LevelEditorState {
    case started
    case stopped
    case levelCreated(CustomLevel)
    case levelLoaded(CustomLevel)
    case levelSaved(CustomLevel)
    case levelDeleted(String)
    case elementSelected(LevelElement)
    case elementPlaced(PlacedLevelElement)
    case elementRemoved(PlacedLevelElement)
    case testingStarted(CustomLevel)
    case testingStopped
    case error(LevelEditorError)
}

/// Level editor errors
enum LevelEditorError: Error {
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)
    case invalidLevelData
}

/// UI overlay for the level editor
@MainActor
class LevelEditorOverlay: SKNode {
    private let toolbar: LevelEditorToolbar

    init(size: CGSize) {
        self.toolbar = LevelEditorToolbar(size: size)
        super.init()

        setupOverlay(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupOverlay(size: CGSize) {
        // Semi-transparent background
        let background = SKShapeNode(rectOf: size)
        background.fillColor = SKColor.black.withAlphaComponent(0.3)
        background.strokeColor = .clear
        background.zPosition = 1000
        addChild(background)

        // Add toolbar
        toolbar.position = CGPoint(x: 0, y: size.height / 2 - 50)
        addChild(toolbar)
    }
}

/// Toolbar for level editor tools
@MainActor
class LevelEditorToolbar: SKNode {
    private let elementButtons: [LevelEditorButton] = []

    init(size: CGSize) {
        super.init()

        setupToolbar(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupToolbar(size: CGSize) {
        // Create buttons for different tools
        let buttonSize = CGSize(width: 60, height: 60)
        let spacing: CGFloat = 10
        let startX = -size.width / 2 + 30

        // This would create buttons for save, load, test, etc.
        // Implementation details would depend on UI framework used
    }
}

/// Button for level editor toolbar
@MainActor
class LevelEditorButton: SKNode {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init()

        setupButton()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        let button = SKShapeNode(circleOfRadius: 25)
        button.fillColor = .blue
        button.strokeColor = .white
        button.lineWidth = 2
        addChild(button)

        // Add touch handling
        isUserInteractionEnabled = true
    }

    #if os(iOS) || os(tvOS)
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            action()
        }
    #endif
}
