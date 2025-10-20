//
// MultiplayerManager.swift
// AvoidObstaclesGame
//
// Manages multiplayer game modes including local and online multiplayer
// with competitive and cooperative gameplay.
//

import Combine
import GameKit
import SpriteKit

/// Protocol for multiplayer events
protocol MultiplayerDelegate: AnyObject {
    func playerJoined(_ player: MultiplayerPlayer) async
    func playerLeft(_ player: MultiplayerPlayer) async
    func gameStarted(with players: [MultiplayerPlayer]) async
    func gameEnded(with results: MultiplayerGameResults) async
    func receivedMove(from player: MultiplayerPlayer, move: PlayerMove) async
}

/// Types of multiplayer modes available
enum MultiplayerMode {
    case localSplitScreen
    case localTurnBased
    case onlineCompetitive
    case onlineCooperative
}

/// Represents a player in multiplayer mode
struct MultiplayerPlayer: Identifiable, Hashable, Codable {
    let id: String
    let displayName: String
    let avatar: String?
    var score: Int = 0
    var lives: Int = 3
    var isActive: Bool = true
    var position: CGPoint = .zero

    static func == (lhs: MultiplayerPlayer, rhs: MultiplayerPlayer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// A player move in multiplayer
struct PlayerMove: Codable {
    let playerId: String
    let action: MultiplayerAction
    let timestamp: Date
}

/// Types of multiplayer actions
enum MultiplayerAction: Codable {
    case move(CGVector)
    case jump
    case usePowerUp(String)
    case pause
    case resume
}

/// Results of a multiplayer game
struct MultiplayerGameResults: Codable {
    let winner: MultiplayerPlayer?
    let rankings: [MultiplayerPlayer]
    let duration: TimeInterval
    let gameMode: String // Store as string since enum isn't Codable
}

/// Manages multiplayer functionality (focused on local multiplayer for now)
@MainActor
class MultiplayerManager {
    // MARK: - Properties

    /// Delegate for multiplayer events
    weak var delegate: MultiplayerDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Current multiplayer mode
    private var currentMode: MultiplayerMode?

    /// Connected players
    private var players: [MultiplayerPlayer] = []

    /// Local player
    private var localPlayer: MultiplayerPlayer?

    /// Game state
    private var isGameActive = false

    /// Public accessor for game active state
    var gameIsActive: Bool {
        isGameActive
    }

    /// Move history for synchronization
    private var moveHistory: [PlayerMove] = []

    /// Publishers for reactive updates
    let playerJoinedPublisher = PassthroughSubject<MultiplayerPlayer, Never>()
    let playerLeftPublisher = PassthroughSubject<MultiplayerPlayer, Never>()
    let gameStatePublisher = PassthroughSubject<MultiplayerGameState, Never>()

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        setupLocalPlayer()
    }

    private func setupLocalPlayer() {
        let playerId = UUID().uuidString
        let displayName = "Player 1"

        localPlayer = MultiplayerPlayer(
            id: playerId,
            displayName: displayName,
            avatar: nil,
            score: 0,
            lives: 3,
            isActive: true
        )
    }

    // MARK: - Multiplayer Mode Setup

    /// Starts a multiplayer game with the specified mode
    /// - Parameter mode: The multiplayer mode to start
    func startMultiplayerGame(mode: MultiplayerMode) {
        currentMode = mode

        switch mode {
        case .localSplitScreen:
            startLocalSplitScreen()
        case .localTurnBased:
            startLocalTurnBased()
        case .onlineCompetitive, .onlineCooperative:
            // Online multiplayer not implemented yet
            // Would require Game Center or custom networking
            startLocalSplitScreen() // Fallback to local
        }
    }

    private func startLocalSplitScreen() {
        // Create AI opponents for local multiplayer
        let aiPlayers = createAIPlayers(count: 1)
        players = [localPlayer!]

        for aiPlayer in aiPlayers {
            players.append(aiPlayer)
            Task { @MainActor in
                await delegate?.playerJoined(aiPlayer)
            }
            playerJoinedPublisher.send(aiPlayer)
        }

        startGame()
    }

    private func startLocalTurnBased() {
        // Turn-based local multiplayer
        let aiPlayers = createAIPlayers(count: 2)
        players = [localPlayer!] + aiPlayers

        for player in players {
            Task { @MainActor in
                await delegate?.playerJoined(player)
            }
            playerJoinedPublisher.send(player)
        }

        startGame()
    }

    private func createAIPlayers(count: Int) -> [MultiplayerPlayer] {
        var aiPlayers: [MultiplayerPlayer] = []

        for i in 1 ... count {
            let aiPlayer = MultiplayerPlayer(
                id: "ai_player_\(i)",
                displayName: "AI Player \(i)",
                avatar: nil,
                score: 0,
                lives: 3,
                isActive: true
            )
            aiPlayers.append(aiPlayer)
        }

        return aiPlayers
    }

    private func startGame() {
        isGameActive = true
        Task { @MainActor in
            await delegate?.gameStarted(with: players)
        }
        gameStatePublisher.send(.active)
    }

    // MARK: - Player Actions

    /// Sends a player move to other players
    /// - Parameter move: The move to send
    func sendMove(_ move: PlayerMove) {
        moveHistory.append(move)

        // For local multiplayer, handle AI responses or turn-based logic
        handleLocalMove(move)

        Task { @MainActor in
            await delegate?.receivedMove(from: players.first { $0.id == move.playerId }!, move: move)
        }
    }

    private func handleLocalMove(_ move: PlayerMove) {
        // Handle AI responses or turn-based logic
        if move.playerId.hasPrefix("ai_player_") {
            // AI player made a move
            return
        }

        // For turn-based, switch to next player
        if currentMode == .localTurnBased {
            switchToNextPlayer()
        }
    }

    private func switchToNextPlayer() {
        // Implement turn switching logic
        guard let currentPlayerIndex = players.firstIndex(where: { $0.isActive }) else { return }

        // Deactivate current player
        players[currentPlayerIndex].isActive = false

        // Activate next player
        let nextIndex = (currentPlayerIndex + 1) % players.count
        players[nextIndex].isActive = true
    }

    // MARK: - Game Management

    /// Ends the current multiplayer game
    /// - Parameter results: The game results
    func endGame(with results: MultiplayerGameResults) {
        isGameActive = false
        Task { @MainActor in
            await delegate?.gameEnded(with: results)
        }
        gameStatePublisher.send(.finished)

        // Clean up
        players.removeAll()
        moveHistory.removeAll()
    }

    /// Updates player score
    /// - Parameters:
    ///   - playerId: The player ID
    ///   - points: Points to add
    func updatePlayerScore(playerId: String, points: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].score += points
        }
    }

    /// Updates player lives
    /// - Parameters:
    ///   - playerId: The player ID
    ///   - lives: New lives count
    func updatePlayerLives(playerId: String, lives: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].lives = lives

            if lives <= 0 {
                players[index].isActive = false
                checkGameEndConditions()
            }
        }
    }

    private func checkGameEndConditions() {
        let activePlayers = players.filter(\.isActive)

        if activePlayers.count <= 1 {
            // Game ended
            let winner = activePlayers.first
            let rankings = players.sorted { $0.score > $1.score }

            let results = MultiplayerGameResults(
                winner: winner,
                rankings: rankings,
                duration: 0, // Would need to track actual duration
                gameMode: modeToString(currentMode ?? .localSplitScreen)
            )

            endGame(with: results)
        }
    }

    private func modeToString(_ mode: MultiplayerMode) -> String {
        switch mode {
        case .localSplitScreen: return "localSplitScreen"
        case .localTurnBased: return "localTurnBased"
        case .onlineCompetitive: return "onlineCompetitive"
        case .onlineCooperative: return "onlineCooperative"
        }
    }
}

/// Game state for multiplayer
enum MultiplayerGameState {
    case waiting
    case active
    case paused
    case finished
}

/// Errors that can occur in multiplayer
enum MultiplayerError: Error {
    case playerNotAuthenticated
    case matchCreationFailed
    case connectionLost
    case invalidMove
}
