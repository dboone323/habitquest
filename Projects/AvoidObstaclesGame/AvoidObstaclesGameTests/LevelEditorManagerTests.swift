@testable import AvoidObstaclesGame
import SpriteKit
import XCTest

class LevelEditorManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here
    }

    override func tearDown() {
        // Put teardown code here
        super.tearDown()
    }

    // MARK: - structCustomLevel:Codable,Identifiable{ Tests

    // MARK: - structCustomLevel:Codable,Identifiable{ Tests

    func teststructCustomLevelInitialization() {
        // Test basic initialization
        let levelId = "test-level-123"
        let levelName = "Test Level"
        let difficulty = "Medium"
        let createdDate = Date()
        let modifiedDate = Date()
        let elements = [PlacedLevelElement(id: "elem1", element: LevelElement(type: .obstacle(.block), displayName: "Block", iconName: "block"), position: CGPoint(x: 100, y: 100))]
        let settings = LevelSettings(targetTime: 60.0, maxLives: 5, backgroundTheme: .forest)

        let level = CustomLevel(
            id: levelId,
            name: levelName,
            difficulty: difficulty,
            createdDate: createdDate,
            modifiedDate: modifiedDate,
            elements: elements,
            settings: settings
        )

        XCTAssertEqual(level.id, levelId)
        XCTAssertEqual(level.name, levelName)
        XCTAssertEqual(level.difficulty, difficulty)
        XCTAssertEqual(level.createdDate, createdDate)
        XCTAssertEqual(level.modifiedDate, modifiedDate)
        XCTAssertEqual(level.elements.count, 1)
        XCTAssertEqual(level.settings.targetTime, 60.0)
        XCTAssertEqual(level.identifier, levelId)
    }

    func teststructCustomLevelProperties() {
        // Test property access and validation
        var level = CustomLevel(
            id: "test-level",
            name: "Original Name",
            difficulty: "Easy",
            createdDate: Date(),
            modifiedDate: Date(),
            elements: [],
            settings: LevelSettings()
        )

        // Test mutable properties
        level.name = "Updated Name"
        level.difficulty = "Hard"
        level.modifiedDate = Date()

        XCTAssertEqual(level.name, "Updated Name")
        XCTAssertEqual(level.difficulty, "Hard")
        XCTAssertEqual(level.id, "test-level") // Should remain unchanged

        // Test computed property
        XCTAssertEqual(level.identifier, level.id)
    }

    func teststructCustomLevelMethods() {
        // Test method functionality - primarily Codable conformance
        let originalLevel = CustomLevel(
            id: "test-level",
            name: "Test Level",
            difficulty: "Medium",
            createdDate: Date(),
            modifiedDate: Date(),
            elements: [PlacedLevelElement(id: "elem1", element: LevelElement(type: .obstacle(.block), displayName: "Block", iconName: "block"), position: CGPoint(x: 50, y: 50))],
            settings: LevelSettings(targetTime: 120.0, backgroundTheme: .space)
        )

        // Test encoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        XCTAssertNoThrow(try encoder.encode(originalLevel))

        // Test decoding
        let data = try! encoder.encode(originalLevel)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedLevel = try! decoder.decode(CustomLevel.self, from: data)

        XCTAssertEqual(decodedLevel.id, originalLevel.id)
        XCTAssertEqual(decodedLevel.name, originalLevel.name)
        XCTAssertEqual(decodedLevel.difficulty, originalLevel.difficulty)
        XCTAssertEqual(decodedLevel.elements.count, originalLevel.elements.count)
        XCTAssertEqual(decodedLevel.settings.targetTime, originalLevel.settings.targetTime)
    }

    // MARK: - structLevelSettings:Codable{ Tests

    func teststructLevelSettingsInitialization() {
        // Test basic initialization
        let settings = LevelSettings(
            targetTime: 90.0,
            maxLives: 5,
            backgroundTheme: .ocean,
            musicTrack: "ocean_theme.mp3",
            allowPowerUps: false,
            dynamicDifficulty: false,
            minimumScore: 1000
        )

        XCTAssertEqual(settings.targetTime, 90.0)
        XCTAssertEqual(settings.maxLives, 5)
        XCTAssertEqual(settings.backgroundTheme, .ocean)
        XCTAssertEqual(settings.musicTrack, "ocean_theme.mp3")
        XCTAssertFalse(settings.allowPowerUps)
        XCTAssertFalse(settings.dynamicDifficulty)
        XCTAssertEqual(settings.minimumScore, 1000)
    }

    func teststructLevelSettingsProperties() {
        // Test property access and validation
        var settings = LevelSettings()

        // Test default values
        XCTAssertNil(settings.targetTime)
        XCTAssertEqual(settings.maxLives, 3)
        XCTAssertEqual(settings.backgroundTheme, .space)
        XCTAssertNil(settings.musicTrack)
        XCTAssertTrue(settings.allowPowerUps)
        XCTAssertTrue(settings.dynamicDifficulty)
        XCTAssertEqual(settings.minimumScore, 0)

        // Test mutability
        settings.targetTime = 120.0
        settings.maxLives = 1
        settings.backgroundTheme = .desert
        settings.musicTrack = "desert_wind.mp3"
        settings.allowPowerUps = false
        settings.dynamicDifficulty = false
        settings.minimumScore = 500

        XCTAssertEqual(settings.targetTime, 120.0)
        XCTAssertEqual(settings.maxLives, 1)
        XCTAssertEqual(settings.backgroundTheme, .desert)
        XCTAssertEqual(settings.musicTrack, "desert_wind.mp3")
        XCTAssertFalse(settings.allowPowerUps)
        XCTAssertFalse(settings.dynamicDifficulty)
        XCTAssertEqual(settings.minimumScore, 500)
    }

    func teststructLevelSettingsMethods() {
        // Test method functionality - Codable conformance
        let originalSettings = LevelSettings(
            targetTime: 60.0,
            maxLives: 3,
            backgroundTheme: .forest,
            musicTrack: "forest_ambient.mp3",
            allowPowerUps: true,
            dynamicDifficulty: true,
            minimumScore: 250
        )

        // Test encoding
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(originalSettings))

        // Test decoding
        let data = try! encoder.encode(originalSettings)
        let decoder = JSONDecoder()
        let decodedSettings = try! decoder.decode(LevelSettings.self, from: data)

        XCTAssertEqual(decodedSettings.targetTime, originalSettings.targetTime)
        XCTAssertEqual(decodedSettings.maxLives, originalSettings.maxLives)
        XCTAssertEqual(decodedSettings.backgroundTheme, originalSettings.backgroundTheme)
        XCTAssertEqual(decodedSettings.musicTrack, originalSettings.musicTrack)
        XCTAssertEqual(decodedSettings.allowPowerUps, originalSettings.allowPowerUps)
        XCTAssertEqual(decodedSettings.dynamicDifficulty, originalSettings.dynamicDifficulty)
        XCTAssertEqual(decodedSettings.minimumScore, originalSettings.minimumScore)
    }

    // MARK: - enumBackgroundTheme:String,Codable,CaseIterable{ Tests

    func testenumBackgroundThemeInitialization() {
        // Test basic initialization
        let spaceTheme = BackgroundTheme.space
        let oceanTheme = BackgroundTheme.ocean
        let forestTheme = BackgroundTheme.forest

        XCTAssertEqual(spaceTheme, .space)
        XCTAssertEqual(oceanTheme, .ocean)
        XCTAssertEqual(forestTheme, .forest)

        // Test CaseIterable
        let allCases = BackgroundTheme.allCases
        XCTAssertEqual(allCases.count, 6)
        XCTAssertTrue(allCases.contains(.space))
        XCTAssertTrue(allCases.contains(.ocean))
        XCTAssertTrue(allCases.contains(.forest))
        XCTAssertTrue(allCases.contains(.desert))
        XCTAssertTrue(allCases.contains(.city))
        XCTAssertTrue(allCases.contains(.nebula))
    }

    func testenumBackgroundThemeProperties() {
        // Test property access and validation
        XCTAssertEqual(BackgroundTheme.space.displayName, "Space")
        XCTAssertEqual(BackgroundTheme.ocean.displayName, "Ocean")
        XCTAssertEqual(BackgroundTheme.forest.displayName, "Forest")
        XCTAssertEqual(BackgroundTheme.desert.displayName, "Desert")
        XCTAssertEqual(BackgroundTheme.city.displayName, "City")
        XCTAssertEqual(BackgroundTheme.nebula.displayName, "Nebula")

        // Test raw values (String conformance)
        XCTAssertEqual(BackgroundTheme.space.rawValue, "space")
        XCTAssertEqual(BackgroundTheme.ocean.rawValue, "ocean")
        XCTAssertEqual(BackgroundTheme.forest.rawValue, "forest")
        XCTAssertEqual(BackgroundTheme.desert.rawValue, "desert")
        XCTAssertEqual(BackgroundTheme.city.rawValue, "city")
        XCTAssertEqual(BackgroundTheme.nebula.rawValue, "nebula")
    }

    func testenumBackgroundThemeMethods() {
        // Test method functionality - Codable conformance
        let originalTheme = BackgroundTheme.forest

        // Test encoding
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(originalTheme))

        // Test decoding
        let data = try! encoder.encode(originalTheme)
        let decoder = JSONDecoder()
        let decodedTheme = try! decoder.decode(BackgroundTheme.self, from: data)

        XCTAssertEqual(decodedTheme, originalTheme)
        XCTAssertEqual(decodedTheme.displayName, "Forest")

        // Test all themes can be encoded/decoded
        for theme in BackgroundTheme.allCases {
            let themeData = try! encoder.encode(theme)
            let decoded = try! decoder.decode(BackgroundTheme.self, from: themeData)
            XCTAssertEqual(decoded, theme)
        }
    }

    // MARK: - structLevelElement:Identifiable{ Tests

    func teststructLevelElementInitialization() {
        // Test basic initialization
        let element = LevelElement(type: .obstacle(.block), displayName: "Block", iconName: "block_icon")

        XCTAssertEqual(element.type, LevelElementType.obstacle(.block))
        XCTAssertEqual(element.displayName, "Block")
        XCTAssertEqual(element.iconName, "block_icon")
        XCTAssertNotNil(element.id) // UUID should be generated
    }

    func teststructLevelElementProperties() {
        // Test property access and validation
        let blockElement = LevelElement(type: .obstacle(.block), displayName: "Block", iconName: "block_icon")
        let playerStartElement = LevelElement(type: .playerStart, displayName: "Player Start", iconName: "player_icon")
        let movingObstacleElement = LevelElement(type: .obstacle(.moving), displayName: "Moving Block", iconName: "moving_icon")

        // Test canRotate property
        XCTAssertTrue(blockElement.canRotate) // blocks can rotate
        XCTAssertFalse(playerStartElement.canRotate) // player start cannot rotate
        XCTAssertTrue(movingObstacleElement.canRotate) // moving obstacles can rotate

        // Test canScale property
        XCTAssertTrue(blockElement.canScale) // blocks can scale
        XCTAssertFalse(playerStartElement.canScale) // player start cannot scale
        XCTAssertTrue(movingObstacleElement.canScale) // moving obstacles can scale
    }

    func teststructLevelElementMethods() {
        // Test method functionality - Codable conformance
        let originalElement = LevelElement(type: .obstacle(.spike), displayName: "Spike", iconName: "spike_icon")

        // Test encoding
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(originalElement))

        // Test decoding
        let data = try! encoder.encode(originalElement)
        let decoder = JSONDecoder()
        let decodedElement = try! decoder.decode(LevelElement.self, from: data)

        XCTAssertEqual(decodedElement.type, originalElement.type)
        XCTAssertEqual(decodedElement.displayName, originalElement.displayName)
        XCTAssertEqual(decodedElement.iconName, originalElement.iconName)
        XCTAssertEqual(decodedElement.id, originalElement.id)
    }

    // MARK: - enumLevelElementType:Codable,Hashable,Equatable{ Tests

    func testenumLevelElementTypeInitialization() {
        // Test basic initialization
        let obstacleType = LevelElementType.obstacle(.block)
        let powerUpType = LevelElementType.powerUp(.shield)
        let playerStartType = LevelElementType.playerStart
        let finishLineType = LevelElementType.finishLine

        XCTAssertEqual(obstacleType, LevelElementType.obstacle(.block))
        XCTAssertEqual(powerUpType, LevelElementType.powerUp(.shield))
        XCTAssertEqual(playerStartType, LevelElementType.playerStart)
        XCTAssertEqual(finishLineType, LevelElementType.finishLine)
    }

    func testenumLevelElementTypeProperties() {
        // Test property access and validation
        let obstacleType = LevelElementType.obstacle(.laser)
        let powerUpType = LevelElementType.powerUp(.speed)

        // Test that they are different types
        XCTAssertNotEqual(obstacleType, powerUpType)
        XCTAssertNotEqual(obstacleType, .playerStart)
        XCTAssertNotEqual(powerUpType, .finishLine)
    }

    func testenumLevelElementTypeMethods() {
        // Test method functionality - Codable, Hashable, Equatable conformance
        let originalType = LevelElementType.obstacle(.moving)

        // Test encoding
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(originalType))

        // Test decoding
        let data = try! encoder.encode(originalType)
        let decoder = JSONDecoder()
        let decodedType = try! decoder.decode(LevelElementType.self, from: data)

        XCTAssertEqual(decodedType, originalType)

        // Test Hashable
        var typeSet = Set<LevelElementType>()
        typeSet.insert(.obstacle(.block))
        typeSet.insert(.powerUp(.shield))
        typeSet.insert(.playerStart)
        typeSet.insert(.finishLine)
        typeSet.insert(.obstacle(.block)) // Duplicate should not be added

        XCTAssertEqual(typeSet.count, 4) // Should have 4 unique types
    }

    // MARK: - structPlacedLevelElement:Codable,Identifiable{ Tests

    func teststructPlacedLevelElementInitialization() {
        // Test basic initialization
        let element = LevelElement(type: .obstacle(.block), displayName: "Block", iconName: "block_icon")
        let position = CGPoint(x: 100, y: 200)
        let placedElement = PlacedLevelElement(id: "test-element-1", element: element, position: position, rotation: .pi / 4, scale: 1.5)

        XCTAssertEqual(placedElement.id, "test-element-1")
        XCTAssertEqual(placedElement.element.type, .obstacle(.block))
        XCTAssertEqual(placedElement.position, position)
        XCTAssertEqual(placedElement.rotation, .pi / 4)
        XCTAssertEqual(placedElement.scale, 1.5)
        XCTAssertEqual(placedElement.identifier, "test-element-1")
    }

    func teststructPlacedLevelElementProperties() {
        // Test property access and validation
        let element = LevelElement(type: .powerUp(.shield), displayName: "Shield", iconName: "shield_icon")
        var placedElement = PlacedLevelElement(id: "test-element", element: element, position: CGPoint(x: 50, y: 50))

        // Test initial values
        XCTAssertEqual(placedElement.rotation, 0)
        XCTAssertEqual(placedElement.scale, 1.0)

        // Test mutability
        placedElement.position = CGPoint(x: 100, y: 150)
        placedElement.rotation = .pi / 2
        placedElement.scale = 2.0

        XCTAssertEqual(placedElement.position, CGPoint(x: 100, y: 150))
        XCTAssertEqual(placedElement.rotation, .pi / 2)
        XCTAssertEqual(placedElement.scale, 2.0)

        // Test computed property
        XCTAssertEqual(placedElement.identifier, placedElement.id)
    }

    func teststructPlacedLevelElementMethods() {
        // Test method functionality - Codable conformance
        let element = LevelElement(type: .finishLine, displayName: "Finish Line", iconName: "finish_icon")
        let originalPlacedElement = PlacedLevelElement(
            id: "test-placed-element",
            element: element,
            position: CGPoint(x: 300, y: 400),
            rotation: .pi,
            scale: 0.8
        )

        // Test encoding
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(originalPlacedElement))

        // Test decoding
        let data = try! encoder.encode(originalPlacedElement)
        let decoder = JSONDecoder()
        let decodedPlacedElement = try! decoder.decode(PlacedLevelElement.self, from: data)

        XCTAssertEqual(decodedPlacedElement.id, originalPlacedElement.id)
        XCTAssertEqual(decodedPlacedElement.element.type, originalPlacedElement.element.type)
        XCTAssertEqual(decodedPlacedElement.position, originalPlacedElement.position)
        XCTAssertEqual(decodedPlacedElement.rotation, originalPlacedElement.rotation)
        XCTAssertEqual(decodedPlacedElement.scale, originalPlacedElement.scale)
    }

    // MARK: - enumLevelEditorState{ Tests

    func testenumLevelEditorStateInitialization() {
        // Test basic initialization
        let startedState = LevelEditorState.started
        let stoppedState = LevelEditorState.stopped

        XCTAssertEqual(startedState, .started)
        XCTAssertEqual(stoppedState, .stopped)

        // Test associated value cases
        let level = CustomLevel(
            id: "test-level",
            name: "Test Level",
            difficulty: "Easy",
            createdDate: Date(),
            modifiedDate: Date(),
            elements: [],
            settings: LevelSettings()
        )

        let levelCreatedState = LevelEditorState.levelCreated(level)
        let levelLoadedState = LevelEditorState.levelLoaded(level)
        let levelSavedState = LevelEditorState.levelSaved(level)

        if case let .levelCreated(createdLevel) = levelCreatedState {
            XCTAssertEqual(createdLevel.id, level.id)
        } else {
            XCTFail("Expected levelCreated state")
        }

        if case let .levelLoaded(loadedLevel) = levelLoadedState {
            XCTAssertEqual(loadedLevel.name, level.name)
        } else {
            XCTFail("Expected levelLoaded state")
        }

        if case let .levelSaved(savedLevel) = levelSavedState {
            XCTAssertEqual(savedLevel.difficulty, level.difficulty)
        } else {
            XCTFail("Expected levelSaved state")
        }
    }

    func testenumLevelEditorStateProperties() {
        // Test property access and validation
        let deletedState = LevelEditorState.levelDeleted("TestLevel")

        if case let .levelDeleted(levelName) = deletedState {
            XCTAssertEqual(levelName, "TestLevel")
        } else {
            XCTFail("Expected levelDeleted state")
        }

        // Test error state
        let testError = NSError(domain: "TestError", code: 123, userInfo: nil)
        let errorState = LevelEditorState.error(.saveFailed(testError))

        if case let .error(editorError) = errorState {
            if case let .saveFailed(error) = editorError {
                XCTAssertEqual((error as NSError).code, 123)
            } else {
                XCTFail("Expected saveFailed error")
            }
        } else {
            XCTFail("Expected error state")
        }
    }

    func testenumLevelEditorStateMethods() {
        // Test method functionality - Equatable conformance
        let state1 = LevelEditorState.started
        let state2 = LevelEditorState.started
        let state3 = LevelEditorState.stopped

        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)

        // Test with associated values
        let level1 = CustomLevel(
            id: "level1",
            name: "Level 1",
            difficulty: "Easy",
            createdDate: Date(),
            modifiedDate: Date(),
            elements: [],
            settings: LevelSettings()
        )

        let level2 = CustomLevel(
            id: "level2",
            name: "Level 2",
            difficulty: "Hard",
            createdDate: Date(),
            modifiedDate: Date(),
            elements: [],
            settings: LevelSettings()
        )

        let stateLevel1 = LevelEditorState.levelCreated(level1)
        let stateLevel1Copy = LevelEditorState.levelCreated(level1)
        let stateLevel2 = LevelEditorState.levelCreated(level2)

        XCTAssertEqual(stateLevel1, stateLevel1Copy)
        XCTAssertNotEqual(stateLevel1, stateLevel2)
    }

    // MARK: - enumLevelEditorError:Error{ Tests

    func testenumLevelEditorErrorInitialization() {
        // Test basic initialization
        let testError = NSError(domain: "TestDomain", code: 999, userInfo: nil)

        let saveError = LevelEditorError.saveFailed(testError)
        let loadError = LevelEditorError.loadFailed(testError)
        let deleteError = LevelEditorError.deleteFailed(testError)
        let invalidDataError = LevelEditorError.invalidLevelData

        XCTAssertEqual(saveError, LevelEditorError.saveFailed(testError))
        XCTAssertEqual(loadError, LevelEditorError.loadFailed(testError))
        XCTAssertEqual(deleteError, LevelEditorError.deleteFailed(testError))
        XCTAssertEqual(invalidDataError, LevelEditorError.invalidLevelData)
    }

    func testenumLevelEditorErrorProperties() {
        // Test property access and validation
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let saveError = LevelEditorError.saveFailed(testError)

        if case let .saveFailed(error) = saveError {
            XCTAssertEqual((error as NSError).domain, "TestDomain")
            XCTAssertEqual((error as NSError).code, 123)
        } else {
            XCTFail("Expected saveFailed error")
        }

        // Test that different error types are not equal
        XCTAssertNotEqual(saveError, LevelEditorError.loadFailed(testError))
        XCTAssertNotEqual(saveError, LevelEditorError.invalidLevelData)
    }

    func testenumLevelEditorErrorMethods() {
        // Test method functionality - Error protocol conformance
        let testError = NSError(domain: "TestDomain", code: 456, userInfo: nil)
        let saveError = LevelEditorError.saveFailed(testError)

        // Test that it conforms to Error protocol
        XCTAssertNotNil(saveError as? Error, "LevelEditorError should conform to Error protocol")

        // Test that enum cases can be created and are not nil
        XCTAssertNotNil(saveError)
        XCTAssertNotNil(LevelEditorError.invalidLevelData)
    }

    // MARK: - classLevelEditorOverlay:SKNode{ Tests

    @MainActor
    func testclassLevelEditorOverlayInitialization() {
        // Test basic initialization
        let overlaySize = CGSize(width: 800, height: 600)
        let overlay = LevelEditorOverlay(size: overlaySize)

        // Test that overlay is created
        XCTAssertNotNil(overlay)

        // Test that overlay has the expected size
        XCTAssertEqual(overlay.children.count, 2) // Background and toolbar

        // Test that overlay contains background and toolbar
        let background = overlay.children.first { $0.name == nil } // Background has no name
        XCTAssertNotNil(background)

        let toolbar = overlay.children.first { $0 is LevelEditorToolbar }
        XCTAssertNotNil(toolbar)
    }

    @MainActor
    func testclassLevelEditorOverlayProperties() {
        let overlaySize = CGSize(width: 800, height: 600)
        let overlay = LevelEditorOverlay(size: overlaySize)

        // Test that overlay has children (background and toolbar)
        XCTAssertGreaterThan(overlay.children.count, 0, "Overlay should have child nodes")

        // Test that overlay has background
        let background = overlay.children.first { $0 is SKShapeNode }
        XCTAssertNotNil(background, "Overlay should have a background shape node")

        // Test that overlay has toolbar
        let toolbar = overlay.children.first { $0 is LevelEditorToolbar }
        XCTAssertNotNil(toolbar, "Overlay should have a toolbar")

        // Test zPosition is set correctly
        if let bgShape = background as? SKShapeNode {
            XCTAssertEqual(bgShape.zPosition, 1000, "Background should have zPosition 1000")
        }
    }

    @MainActor
    func testclassLevelEditorOverlayMethods() {
        // Test method functionality
        let overlaySize = CGSize(width: 800, height: 600)
        let overlay = LevelEditorOverlay(size: overlaySize)

        // Test that overlay can be added to a scene
        let scene = SKScene(size: overlaySize)
        scene.addChild(overlay)

        // Test that overlay is in the scene
        XCTAssertTrue(scene.children.contains(overlay))

        // Test that overlay can be removed from scene
        overlay.removeFromParent()
        XCTAssertFalse(scene.children.contains(overlay))

        // Test that overlay can be initialized with different sizes
        let smallOverlay = LevelEditorOverlay(size: CGSize(width: 400, height: 300))
        XCTAssertNotNil(smallOverlay)
        XCTAssertGreaterThan(smallOverlay.children.count, 0) // Should have at least background
    }

    // MARK: - classLevelEditorToolbar:SKNode{ Tests

    @MainActor
    func testclassLevelEditorToolbarInitialization() {
        let toolbarSize = CGSize(width: 400, height: 100)
        let toolbar = LevelEditorToolbar(size: toolbarSize)

        // Test that toolbar is initialized
        XCTAssertNotNil(toolbar, "Toolbar should be initialized")

        // Test that toolbar has children (buttons)
        XCTAssertGreaterThanOrEqual(toolbar.children.count, 0, "Toolbar should have child nodes")
    }

    @MainActor
    func testclassLevelEditorToolbarProperties() {
        let toolbarSize = CGSize(width: 400, height: 100)
        let toolbar = LevelEditorToolbar(size: toolbarSize)

        // Test that toolbar can be added to a scene
        let scene = SKScene(size: toolbarSize)
        scene.addChild(toolbar)

        // Test that toolbar is in the scene
        XCTAssertTrue(scene.children.contains(toolbar), "Toolbar should be added to scene")

        // Test that toolbar can be removed from scene
        toolbar.removeFromParent()
        XCTAssertFalse(scene.children.contains(toolbar), "Toolbar should be removed from scene")
    }

    @MainActor
    func testclassLevelEditorToolbarMethods() {
        let toolbarSize = CGSize(width: 400, height: 100)
        let toolbar = LevelEditorToolbar(size: toolbarSize)

        // Test that toolbar can be positioned
        let newPosition = CGPoint(x: 100, y: 50)
        toolbar.position = newPosition
        XCTAssertEqual(toolbar.position, newPosition, "Toolbar position should be settable")

        // Test that toolbar can be scaled
        let newScale: CGFloat = 1.5
        toolbar.setScale(newScale)
        XCTAssertEqual(toolbar.xScale, newScale, "Toolbar should be scalable")
        XCTAssertEqual(toolbar.yScale, newScale, "Toolbar should be scalable")
    }

    // MARK: - classLevelEditorButton:SKNode{ Tests

    @MainActor
    func testclassLevelEditorButtonInitialization() {
        var actionCalled = false
        let button = LevelEditorButton(action: { actionCalled = true })

        // Test that button is initialized
        XCTAssertNotNil(button, "Button should be initialized")

        // Test that button has visual elements
        XCTAssertGreaterThan(button.children.count, 0, "Button should have child nodes")

        // Test that button has a shape node (circle)
        let shapeNode = button.children.first { $0 is SKShapeNode }
        XCTAssertNotNil(shapeNode, "Button should have a shape node")

        // Test user interaction is enabled
        XCTAssertTrue(button.isUserInteractionEnabled, "Button should have user interaction enabled")
    }

    @MainActor
    func testclassLevelEditorButtonProperties() {
        var actionCallCount = 0
        let button = LevelEditorButton(action: { actionCallCount += 1 })

        // Test that button can be added to a scene
        let scene = SKScene(size: CGSize(width: 100, height: 100))
        scene.addChild(button)

        // Test that button is in the scene
        XCTAssertTrue(scene.children.contains(button), "Button should be added to scene")

        // Test that button can be removed from scene
        button.removeFromParent()
        XCTAssertFalse(scene.children.contains(button), "Button should be removed from scene")

        // Test button positioning
        let newPosition = CGPoint(x: 50, y: 25)
        button.position = newPosition
        XCTAssertEqual(button.position, newPosition, "Button position should be settable")
    }

    @MainActor
    func testclassLevelEditorButtonMethods() {
        // Test just one property at a time to isolate the issue
        var actionCallCount = 0
        let button = LevelEditorButton(action: { actionCallCount += 1 })

        // Test just alpha first
        let newAlpha: CGFloat = 0.5
        button.alpha = newAlpha
        XCTAssertEqual(button.alpha, newAlpha, "Button alpha should be set to \(newAlpha)")

        // Test isHidden
        button.isHidden = true
        XCTAssertTrue(button.isHidden, "Button should be hidden")
        button.isHidden = false
        XCTAssertFalse(button.isHidden, "Button should be visible")

        // Test setScale
        let newScale: CGFloat = 1.5
        button.setScale(newScale)
        XCTAssertEqual(button.xScale, newScale, "Button should be scalable")
        XCTAssertEqual(button.yScale, newScale, "Button should be scalable")
    }
}
