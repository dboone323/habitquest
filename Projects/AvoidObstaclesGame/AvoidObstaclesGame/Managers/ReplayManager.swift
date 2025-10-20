//
// ReplayManager.swift
// AvoidObstaclesGame
//
// Manages game recording and replay functionality for analysis and sharing.
//

import Combine
import SpriteKit

/// Represents a recorded game session
@MainActor
struct GameRecording: Codable {
    let sessionId: String
    let startTime: Date
    let duration: TimeInterval
    let finalScore: Int
    let difficultyLevel: Int
    let gameMode: String
    let playerActions: [PlayerAction]
    let obstacles: [ObstacleSnapshot]
    let powerUps: [PowerUpSnapshot]
    let metadata: RecordingMetadata

    struct PlayerAction: Codable {
        let timestamp: TimeInterval
        let position: CGPoint
        let action: ActionType

        enum ActionType: String, Codable {
            case move, jump, powerUpCollected, collision, gameOver
        }
    }

    struct ObstacleSnapshot: Codable {
        let timestamp: TimeInterval
        let id: String
        let type: String
        let position: CGPoint
        let isActive: Bool
    }

    struct PowerUpSnapshot: Codable {
        let timestamp: TimeInterval
        let id: String
        let type: String
        let position: CGPoint
        let isCollected: Bool
    }

    struct RecordingMetadata: Codable {
        let playerId: String
        let deviceModel: String
        let appVersion: String
        let averageFPS: Double
        let totalObstaclesAvoided: Int
        let totalPowerUpsCollected: Int
    }
}

/// Manages game recording and replay functionality
@MainActor
class ReplayManager: GameComponent {
    private weak var scene: SKScene?
    private var isRecording: Bool = false
    private var isReplaying: Bool = false
    private var currentRecording: GameRecording?
    private var replayIndex: Int = 0
    private var replayStartTime: TimeInterval = 0

    private var playerActions: [GameRecording.PlayerAction] = []
    private var obstacleSnapshots: [GameRecording.ObstacleSnapshot] = []
    private var powerUpSnapshots: [GameRecording.PowerUpSnapshot] = []

    private var recordingStartTime: TimeInterval = 0
    private var lastSnapshotTime: TimeInterval = 0

    // Publishers for replay events
    let replayStartedPublisher = PassthroughSubject<GameRecording, Never>()
    let replayFinishedPublisher = PassthroughSubject<GameRecording, Never>()
    let recordingSavedPublisher = PassthroughSubject<GameRecording, Never>()

    // Delegate for replay coordination
    weak var delegate: ReplayManagerDelegate?

    init(scene: SKScene) {
        self.scene = scene
    }

    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    /// Starts recording a new game session
    func startRecording() {
        guard !isRecording && !isReplaying else { return }

        isRecording = true
        recordingStartTime = CACurrentMediaTime()
        lastSnapshotTime = 0

        playerActions.removeAll()
        obstacleSnapshots.removeAll()
        powerUpSnapshots.removeAll()

        currentRecording = nil

        print("🎬 Started recording game session")
    }

    /// Stops recording and saves the session
    func stopRecording(finalScore: Int, difficultyLevel: Int, gameMode: String) {
        guard isRecording else { return }

        isRecording = false

        let duration = CACurrentMediaTime() - recordingStartTime
        let sessionId = UUID().uuidString

        let metadata = GameRecording.RecordingMetadata(
            playerId: getPlayerId(),
            deviceModel: getDeviceModel(),
            appVersion: getAppVersion(),
            averageFPS: 60.0, // Would be calculated from performance data
            totalObstaclesAvoided: obstacleSnapshots.filter(\.isActive).count,
            totalPowerUpsCollected: powerUpSnapshots.filter(\.isCollected).count
        )

        let recording = GameRecording(
            sessionId: sessionId,
            startTime: Date(),
            duration: duration,
            finalScore: finalScore,
            difficultyLevel: difficultyLevel,
            gameMode: gameMode,
            playerActions: playerActions,
            obstacles: obstacleSnapshots,
            powerUps: powerUpSnapshots,
            metadata: metadata
        )

        currentRecording = recording
        saveRecording(recording)

        recordingSavedPublisher.send(recording)
        print("💾 Saved recording: \(sessionId)")
    }

    /// Records a player action
    func recordPlayerAction(position: CGPoint, action: GameRecording.PlayerAction.ActionType) {
        guard isRecording else { return }

        let timestamp = CACurrentMediaTime() - recordingStartTime
        let playerAction = GameRecording.PlayerAction(
            timestamp: timestamp,
            position: position,
            action: action
        )

        playerActions.append(playerAction)
    }

    /// Records obstacle state
    func recordObstacleSnapshot(id: String, type: String, position: CGPoint, isActive: Bool) {
        guard isRecording else { return }

        let currentTime = CACurrentMediaTime() - recordingStartTime

        // Only record snapshots every 0.1 seconds to avoid excessive data
        guard currentTime - lastSnapshotTime >= 0.1 else { return }

        let snapshot = GameRecording.ObstacleSnapshot(
            timestamp: currentTime,
            id: id,
            type: type,
            position: position,
            isActive: isActive
        )

        obstacleSnapshots.append(snapshot)
        lastSnapshotTime = currentTime
    }

    /// Records power-up state
    func recordPowerUpSnapshot(id: String, type: String, position: CGPoint, isCollected: Bool) {
        guard isRecording else { return }

        let timestamp = CACurrentMediaTime() - recordingStartTime
        let snapshot = GameRecording.PowerUpSnapshot(
            timestamp: timestamp,
            id: id,
            type: type,
            position: position,
            isCollected: isCollected
        )

        powerUpSnapshots.append(snapshot)
    }

    /// Starts replaying a recorded session
    func startReplay(_ recording: GameRecording) {
        guard !isRecording && !isReplaying else { return }

        isReplaying = true
        currentRecording = recording
        replayIndex = 0
        replayStartTime = CACurrentMediaTime()

        replayStartedPublisher.send(recording)

        // Notify delegate to setup replay mode
        Task {
            await delegate?.replayDidStart(recording: recording)
        }

        print("▶️ Started replay: \(recording.sessionId)")
    }

    /// Stops the current replay
    func stopReplay() {
        guard isReplaying else { return }

        isReplaying = false

        if let recording = currentRecording {
            replayFinishedPublisher.send(recording)

            Task {
                await delegate?.replayDidFinish(recording: recording)
            }
        }

        currentRecording = nil
        replayIndex = 0

        print("⏹️ Stopped replay")
    }

    /// Updates replay state
    func updateReplay(deltaTime: TimeInterval) {
        guard isReplaying, let recording = currentRecording else { return }

        let currentReplayTime = CACurrentMediaTime() - replayStartTime

        // Check if replay is finished
        if currentReplayTime >= recording.duration {
            stopReplay()
            return
        }

        // Process player actions up to current time
        while replayIndex < recording.playerActions.count &&
            recording.playerActions[replayIndex].timestamp <= currentReplayTime
        {

            let action = recording.playerActions[replayIndex]
            Task {
                await delegate?.replayPlayerAction(action)
            }
            replayIndex += 1
        }

        // Process obstacle snapshots
        let relevantObstacles = recording.obstacles.filter { abs($0.timestamp - currentReplayTime) < 0.1 }
        for obstacle in relevantObstacles {
            Task {
                await delegate?.replayObstacleSnapshot(obstacle)
            }
        }

        // Process power-up snapshots
        let relevantPowerUps = recording.powerUps.filter { abs($0.timestamp - currentReplayTime) < 0.1 }
        for powerUp in relevantPowerUps {
            Task {
                await delegate?.replayPowerUpSnapshot(powerUp)
            }
        }
    }

    /// Gets all saved recordings
    func getSavedRecordings() -> [GameRecording] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }

        let recordingsDirectory = documentsDirectory.appendingPathComponent("GameRecordings")

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: recordingsDirectory, includingPropertiesForKeys: nil)
            var recordings: [GameRecording] = []

            for fileURL in fileURLs where fileURL.pathExtension == "json" {
                if let data = try? Data(contentsOf: fileURL),
                   let recording = try? JSONDecoder().decode(GameRecording.self, from: data)
                {
                    recordings.append(recording)
                }
            }

            return recordings.sorted { $0.startTime > $1.startTime }
        } catch {
            print("Error loading recordings: \(error)")
            return []
        }
    }

    /// Deletes a recording
    func deleteRecording(_ recording: GameRecording) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let fileURL = documentsDirectory
            .appendingPathComponent("GameRecordings")
            .appendingPathComponent("\(recording.sessionId).json")

        try? FileManager.default.removeItem(at: fileURL)
    }

    /// Exports recording for sharing
    func exportRecording(_ recording: GameRecording) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let recordingsDirectory = documentsDirectory.appendingPathComponent("GameRecordings")
        let sourceURL = recordingsDirectory.appendingPathComponent("\(recording.sessionId).json")

        // Create a shareable copy
        let tempDirectory = FileManager.default.temporaryDirectory
        let exportURL = tempDirectory.appendingPathComponent("GameReplay_\(recording.sessionId).json")

        do {
            try FileManager.default.copyItem(at: sourceURL, to: exportURL)
            return exportURL
        } catch {
            print("Error exporting recording: \(error)")
            return nil
        }
    }

    /// Shows replay selection UI
    func showReplaySelectionUI() {
        guard let scene else { return }

        let recordings = getSavedRecordings()

        // Create overlay
        let overlay = SKShapeNode(rectOf: scene.frame.size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.8)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        overlay.name = "replayOverlay"
        overlay.zPosition = 1000
        scene.addChild(overlay)

        // Add title
        let titleLabel = SKLabelNode(text: "Game Replays")
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: scene.frame.height / 2 - 60)
        overlay.addChild(titleLabel)

        // Add recordings list
        for (index, recording) in recordings.prefix(5).enumerated() {
            let replayButton = createReplayButton(for: recording, at: index)
            overlay.addChild(replayButton)
        }

        // Add close button
        let closeButton = SKLabelNode(text: "✕")
        closeButton.fontSize = 24
        closeButton.fontColor = .white
        closeButton.position = CGPoint(x: scene.frame.width / 2 - 40, y: scene.frame.height / 2 - 40)
        closeButton.name = "closeReplay"
        overlay.addChild(closeButton)
    }

    private func createReplayButton(for recording: GameRecording, at index: Int) -> SKNode {
        let container = SKNode()
        container.name = "replay_\(recording.sessionId)"

        // Background
        let background = SKShapeNode(rectOf: CGSize(width: 300, height: 60))
        background.fillColor = .blue
        background.strokeColor = .white
        background.lineWidth = 2
        container.addChild(background)

        // Score and date
        let scoreLabel = SKLabelNode(text: "Score: \(recording.finalScore)")
        scoreLabel.fontSize = 16
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: -120, y: 10)
        container.addChild(scoreLabel)

        let dateLabel = SKLabelNode(text: formatDate(recording.startTime))
        dateLabel.fontSize = 12
        dateLabel.fontColor = .yellow
        dateLabel.position = CGPoint(x: -120, y: -10)
        container.addChild(dateLabel)

        // Duration
        let durationLabel = SKLabelNode(text: String(format: "%.1fs", recording.duration))
        durationLabel.fontSize = 14
        durationLabel.fontColor = .cyan
        durationLabel.position = CGPoint(x: 80, y: 0)
        container.addChild(durationLabel)

        container.position = CGPoint(x: 0, y: 100 - CGFloat(index) * 80)

        return container
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Hides replay selection UI
    func hideReplaySelectionUI() {
        scene?.childNode(withName: "replayOverlay")?.removeFromParent()
    }

    /// Handles touch input on replay UI
    func handleReplayUITouch(at location: CGPoint) -> Bool {
        guard let overlay = scene?.childNode(withName: "replayOverlay") else { return false }

        let localLocation = overlay.convert(location, from: scene!)

        // Check for close button
        if let closeButton = overlay.childNode(withName: "closeReplay"),
           closeButton.contains(localLocation)
        {
            hideReplaySelectionUI()
            return true
        }

        // Check for replay buttons
        let recordings = getSavedRecordings()
        for (_, recording) in recordings.prefix(5).enumerated() {
            if let replayButton = overlay.childNode(withName: "replay_\(recording.sessionId)"),
               replayButton.contains(localLocation)
            {
                hideReplaySelectionUI()
                startReplay(recording)
                return true
            }
        }

        return false
    }

    /// Saves a recording to disk
    private func saveRecording(_ recording: GameRecording) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let recordingsDirectory = documentsDirectory.appendingPathComponent("GameRecordings")

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)

        let fileURL = recordingsDirectory.appendingPathComponent("\(recording.sessionId).json")

        if let data = try? JSONEncoder().encode(recording) {
            try? data.write(to: fileURL)
        }
    }

    private func getPlayerId() -> String {
        if let playerId = UserDefaults.standard.string(forKey: "playerId") {
            return playerId
        } else {
            let newPlayerId = UUID().uuidString
            UserDefaults.standard.set(newPlayerId, forKey: "playerId")
            return newPlayerId
        }
    }

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    private func getAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    func update(deltaTime: TimeInterval) {
        if isReplaying {
            updateReplay(deltaTime: deltaTime)
        }
    }

    func reset() {
        if isRecording {
            stopRecording(finalScore: 0, difficultyLevel: 1, gameMode: "unknown")
        }
        if isReplaying {
            stopReplay()
        }
    }

    var isCurrentlyRecording: Bool { isRecording }
    var isCurrentlyReplaying: Bool { isReplaying }
}

/// Delegate protocol for replay coordination
@MainActor
protocol ReplayManagerDelegate: AnyObject {
    func replayDidStart(recording: GameRecording) async
    func replayDidFinish(recording: GameRecording) async
    func replayPlayerAction(_ action: GameRecording.PlayerAction) async
    func replayObstacleSnapshot(_ snapshot: GameRecording.ObstacleSnapshot) async
    func replayPowerUpSnapshot(_ snapshot: GameRecording.PowerUpSnapshot) async
}
