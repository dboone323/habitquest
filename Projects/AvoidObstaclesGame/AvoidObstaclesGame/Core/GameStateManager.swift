//
// GameStateManager.swift
// AvoidObstaclesGame
//
// Manages the overall game state, score tracking, difficulty progression,
// and game lifecycle events.
//

import Foundation

/// Protocol for game state change notifications
@MainActor
protocol GameStateDelegate: AnyObject {
    func gameStateDidChange(from oldState: GameState, to newState: GameState) async
    func scoreDidChange(to newScore: Int) async
    func difficultyDidIncrease(to level: Int) async
    func gameDidEnd(withScore finalScore: Int, survivalTime: TimeInterval) async
    func gameModeDidChange(to mode: GameMode) async
    func winConditionMet(result: GameResult) async
}

/// Represents the current state of the game
enum GameState {
    case waitingToStart
    case playing
    case paused
    case gameOver
}

/// Manages the core game state and logic
@MainActor
class GameStateManager {
    // MARK: - Properties

    /// Delegate for state change notifications
    weak var delegate: GameStateDelegate?

    /// Current game state
    private(set) var currentState: GameState = .waitingToStart {
        didSet {
            Task { @MainActor in
                await self.delegate?.gameStateDidChange(from: oldValue, to: self.currentState)
            }
        }
    }

    /// Current score
    private(set) var score: Int = 0 {
        didSet {
            Task { @MainActor in
                await self.delegate?.scoreDidChange(to: self.score)
            }
            self.updateDifficultyIfNeeded()
        }
    }

    /// Current difficulty level
    private(set) var currentDifficultyLevel: Int = 1

    /// Current difficulty settings
    private(set) var currentDifficulty: GameDifficulty = .getDifficulty(for: 0)

    /// Current game mode
    private(set) var currentGameMode: GameMode = .classic {
        didSet {
            Task { @MainActor in
                await self.delegate?.gameModeDidChange(to: self.currentGameMode)
            }
            self.updateDifficultyForGameMode()
        }
    }

    /// Game mode statistics
    private var gameModeStats: [GameMode: GameModeStats] = [:]

    /// Current game objectives (for challenge/puzzle modes)
    private(set) var currentObjectives: [GameObjective] = []

    /// Win condition checker
    private var winConditionChecker: WinConditionChecker?

    /// Game start time for survival tracking
    private var gameStartTime: Date?

    /// Total survival time in current game
    private(set) var survivalTime: TimeInterval = 0

    /// Current score multiplier (for power-ups)
    private(set) var scoreMultiplier: Int = 1

    /// Statistics tracking with security
    private var gamesPlayed: Int = 0
    private var totalScore: Int = 0
    private var bestSurvivalTime: TimeInterval = 0
    private var dataHash: Data?

    // MARK: - Security Properties

    /// Verifies score integrity
    private func verifyScoreIntegrity() -> Bool {
        let dataString = "\(score)\(currentDifficultyLevel)\(gamesPlayed)"
        let currentHash = SecurityFramework.Crypto.sha256(dataString)
        return dataHash.map { $0 == currentHash } ?? true
    }

    /// Updates data hash for integrity checking
    private func updateDataHash() {
        let dataString = "\(score)\(currentDifficultyLevel)\(gamesPlayed)\(totalScore)\(bestSurvivalTime)"
        self.dataHash = SecurityFramework.Crypto.sha256(dataString)
    }

    // MARK: - Initialization

    init() {
        self.loadStatisticsSecurely()
    }

    // MARK: - Game Lifecycle

    /// Starts a new game with security validation
    func startGame() {
        // Validate game can start
        guard self.currentState == .waitingToStart || self.currentState == .gameOver else {
            SecurityFramework.Monitoring.logSecurityEvent(.inputValidationFailed(type: "Invalid Game Start State"))
            return
        }

        self.currentState = .playing
        self.score = 0
        self.currentDifficultyLevel = 1
        self.currentDifficulty = GameDifficulty.getDifficulty(for: 0)
        self.gameStartTime = Date()
        self.survivalTime = 0
        self.scoreMultiplier = 1 // Reset score multiplier
        self.gamesPlayed += 1
        self.updateDataHash()
        self.saveStatisticsSecurely()
    }

    /// Ends the current game with validation
    func endGame() {
        guard self.currentState == .playing else {
            SecurityFramework.Monitoring.logSecurityEvent(.inputValidationFailed(type: "Invalid Game End State"))
            return
        }

        self.currentState = .gameOver
        self.survivalTime = self.gameStartTime.map { Date().timeIntervalSince($0) } ?? 0

        // Validate survival time
        let timeValidation = SecurityFramework.Validation.validateNumericInput(self.survivalTime, minValue: 0, maxValue: 3600) // Max 1 hour
        guard case .success = timeValidation else {
            SecurityFramework.Monitoring.logSecurityEvent(.inputValidationFailed(type: "Invalid Survival Time"))
            return
        }

        self.totalScore += self.score

        if self.survivalTime > self.bestSurvivalTime {
            self.bestSurvivalTime = self.survivalTime
        }

        self.updateDataHash()
        self.saveStatisticsSecurely()
        Task { @MainActor in
            await self.delegate?.gameDidEnd(withScore: self.score, survivalTime: self.survivalTime)
        }
    }

    /// Pauses the game
    func pauseGame() {
        guard self.currentState == .playing else { return }
        self.currentState = .paused
    }

    /// Resumes the game
    func resumeGame() {
        guard self.currentState == .paused else { return }
        self.currentState = .playing
    }

    /// Restarts the game
    func restartGame() {
        self.endGame()
        self.startGame()
    }

    // MARK: - Score Management

    /// Adds points to the score with validation
    /// - Parameter points: Number of points to add
    func addScore(_ points: Int) {
        guard self.currentState == .playing else {
            SecurityFramework.Monitoring.logSecurityEvent(.inputValidationFailed(type: "Invalid Game State"))
            return
        }

        // Validate points input
        let validation = SecurityFramework.Validation.validateNumericInput(points, minValue: 0, maxValue: 1000)
        guard case .success = validation else {
            SecurityFramework.Monitoring.logSecurityEvent(.inputValidationFailed(type: "Invalid Score Points"))
            return
        }

        // Apply score multiplier
        let multipliedPoints = points * self.scoreMultiplier
        self.score += multipliedPoints

        // Verify score integrity
        if !self.verifyScoreIntegrity() {
            SecurityFramework.Monitoring.logSecurityEvent(.incidentDetected(type: "Score Integrity Violation"))
        }
    }

    /// Gets the current score
    /// - Returns: Current score value
    func getCurrentScore() -> Int {
        self.score
    }

    /// Sets the score multiplier for power-ups
    /// - Parameter multiplier: The multiplier value (1 = normal, 2 = double score, etc.)
    func setScoreMultiplier(_ multiplier: Int) {
        guard multiplier >= 1 && multiplier <= 10 else { return } // Reasonable bounds
        self.scoreMultiplier = multiplier
    }

    /// Resets the score multiplier to default (1x)
    func resetScoreMultiplier() {
        self.scoreMultiplier = 1
    }

    /// Gets the current score multiplier
    /// - Returns: Current multiplier value
    func getScoreMultiplier() -> Int {
        self.scoreMultiplier
    }

    /// Adds bonus time to the survival time (for time bonus power-ups)
    /// - Parameter seconds: Number of seconds to add
    func addBonusTime(_ seconds: TimeInterval) {
        guard self.currentState == .playing, seconds > 0 else { return }
        self.survivalTime += seconds
    }

    // MARK: - Difficulty Management

    /// Updates difficulty based on current score
    private func updateDifficultyIfNeeded() {
        let newDifficulty = GameDifficulty.getDifficulty(for: self.score)
        let newLevel = GameDifficulty.getDifficultyLevel(for: self.score)

        if newLevel > self.currentDifficultyLevel {
            self.currentDifficultyLevel = newLevel
            self.currentDifficulty = newDifficulty
            Task { @MainActor in
                await self.delegate?.difficultyDidIncrease(to: newLevel)
            }
        }
    }

    /// Gets current difficulty settings
    /// - Returns: Current GameDifficulty
    func getCurrentDifficulty() -> GameDifficulty {
        self.currentDifficulty
    }

    /// Gets current difficulty level
    /// - Returns: Current difficulty level
    func getCurrentDifficultyLevel() -> Int {
        self.currentDifficultyLevel
    }

    // MARK: - Statistics

    /// Gets game statistics
    /// - Returns: Dictionary of statistics
    func getStatistics() -> [String: Any] {
        [
            "gamesPlayed": self.gamesPlayed,
            "totalScore": self.totalScore,
            "averageScore": self.gamesPlayed > 0 ? Double(self.totalScore) / Double(self.gamesPlayed) : 0,
            "bestSurvivalTime": self.bestSurvivalTime,
            "highestScore": HighScoreManager.shared.getHighestScore(),
        ]
    }

    /// Gets game statistics (async version)
    /// - Returns: Dictionary of statistics
    func getStatisticsAsync() async -> [String: Any] {
        let highestScore = await HighScoreManager.shared.getHighestScoreAsync()
        return [
            "gamesPlayed": self.gamesPlayed,
            "totalScore": self.totalScore,
            "averageScore": self.gamesPlayed > 0 ? Double(self.totalScore) / Double(self.gamesPlayed) : 0,
            "bestSurvivalTime": self.bestSurvivalTime,
            "highestScore": highestScore,
        ]
    }

    /// Resets all statistics
    func resetStatistics() {
        self.gamesPlayed = 0
        self.totalScore = 0
        self.bestSurvivalTime = 0
        UserDefaults.standard.removeObject(forKey: "gameStatistics")
        UserDefaults.standard.synchronize()
    }

    /// Resets all statistics (async version)
    func resetStatisticsAsync() async {
        self.gamesPlayed = 0
        self.totalScore = 0
        self.bestSurvivalTime = 0
        UserDefaults.standard.removeObject(forKey: "gameStatistics")
        UserDefaults.standard.synchronize()
    }

    // MARK: - Secure Persistence

    private func loadStatisticsSecurely() {
        do {
            // Try to load from secure storage first
            if let secureData = try? SecurityFramework.DataSecurity.retrieveFromKeychain(key: "gameStatistics") {
                let statistics = try JSONDecoder().decode(GameStatistics.self, from: secureData)

                // Verify data integrity
                if statistics.verifyIntegrity() {
                    self.gamesPlayed = statistics.gamesPlayed
                    self.totalScore = statistics.totalScore
                    self.bestSurvivalTime = statistics.bestSurvivalTime
                    self.dataHash = statistics.dataHash
                    return
                } else {
                    SecurityFramework.Monitoring.logSecurityEvent(.incidentDetected(type: "Statistics Integrity Violation"))
                }
            }
        } catch {
            SecurityFramework.Monitoring.logSecurityEvent(.keychainOperationFailed(operation: "Load Statistics"))
        }

        // Fallback to UserDefaults
        self.loadStatistics()
    }

    private func saveStatisticsSecurely() {
        let statistics = GameStatistics(
            gamesPlayed: self.gamesPlayed,
            totalScore: self.totalScore,
            bestSurvivalTime: self.bestSurvivalTime,
            dataHash: self.dataHash
        )

        do {
            let data = try JSONEncoder().encode(statistics)
            try SecurityFramework.DataSecurity.storeInKeychain(key: "gameStatistics", data: data)
        } catch {
            SecurityFramework.Monitoring.logSecurityEvent(.keychainOperationFailed(operation: "Save Statistics"))
            // Fallback to UserDefaults
            self.saveStatistics()
        }
    }

    // MARK: - Legacy Persistence (for fallback)

    private func loadStatistics() {
        let defaults = UserDefaults.standard
        self.gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        self.totalScore = defaults.integer(forKey: "totalScore")
        self.bestSurvivalTime = defaults.double(forKey: "bestSurvivalTime")
    }

    private func saveStatistics() {
        let defaults = UserDefaults.standard
        defaults.set(self.gamesPlayed, forKey: "gamesPlayed")
        defaults.set(self.totalScore, forKey: "totalScore")
        defaults.set(self.bestSurvivalTime, forKey: "bestSurvivalTime")
        defaults.synchronize()
    }

    // MARK: - State Queries

    /// Checks if the game is currently active
    /// - Returns: True if game is playing
    func isGameActive() -> Bool {
        self.currentState == .playing
    }

    /// Checks if the game is over
    /// - Returns: True if game is over
    func isGameOver() -> Bool {
        self.currentState == .gameOver
    }

    /// Checks if the game is paused
    /// - Returns: True if game is paused
    func isGamePaused() -> Bool {
        self.currentState == .paused
    }

    // MARK: - Game Mode Management

    /// Sets the current game mode
    /// - Parameter mode: The game mode to set
    func setGameMode(_ mode: GameMode) {
        self.currentGameMode = mode
        self.setupWinConditionChecker()
        self.setupObjectivesForGameMode()
    }

    /// Gets the current game mode
    /// - Returns: The current game mode
    func getCurrentGameMode() -> GameMode {
        self.currentGameMode
    }

    /// Updates difficulty based on game mode progression
    private func updateDifficultyForGameMode() {
        switch self.currentGameMode.difficultyProgression {
        case .scoreBased:
            // Standard score-based progression (already implemented)
            break
        case let .timeBased(accelerateAfter):
            if let startTime = self.gameStartTime,
               Date().timeIntervalSince(startTime) > accelerateAfter
            {
                // Accelerate difficulty after time threshold
                let acceleratedLevel = self.currentDifficultyLevel + 1
                self.currentDifficulty = GameDifficulty.getDifficulty(for: acceleratedLevel * 25)
            }
        case .waveBased:
            // Wave-based progression handled by win condition checker
            break
        case let .static(level):
            self.currentDifficulty = GameDifficulty.getDifficulty(for: level * 25)
        case .objectiveBased:
            // Objective-based progression
            break
        case .custom:
            // Custom progression logic
            break
        }
    }

    /// Sets up the win condition checker for the current game mode
    private func setupWinConditionChecker() {
        self.winConditionChecker = WinConditionChecker(winCondition: self.currentGameMode.winCondition)
    }

    /// Sets up objectives for the current game mode
    private func setupObjectivesForGameMode() {
        switch self.currentGameMode {
        case .puzzle:
            self.currentObjectives = [
                GameObjective(description: "Solve 5 obstacle patterns", type: .patternsSolved(count: 5), progress: 0),
                GameObjective(description: "Complete within time limit", type: .timeLimit(seconds: 120), progress: 0),
            ]
        case .challenge:
            self.currentObjectives = [
                GameObjective(description: "Avoid obstacles for 60 seconds", type: .surviveTime(seconds: 60), progress: 0),
                GameObjective(description: "Collect 10 power-ups", type: .powerUpsCollected(count: 10), progress: 0),
            ]
        case .survival:
            self.currentObjectives = [
                GameObjective(description: "Complete 10 waves", type: .wavesCompleted(count: 10), progress: 0),
            ]
        default:
            self.currentObjectives = []
        }
    }

    /// Checks if win condition is met and handles game completion
    func checkWinCondition() -> Bool {
        guard let checker = self.winConditionChecker else { return false }

        if checker.isMet(with: self) {
            self.completeGame(success: true)
            return true
        }
        return false
    }

    /// Completes the game with success/failure status
    /// - Parameter success: Whether the game was completed successfully
    private func completeGame(success: Bool) {
        let result = GameResult(
            finalScore: self.score,
            survivalTime: self.survivalTime,
            completed: success,
            gameMode: self.currentGameMode,
            difficultyLevel: self.currentDifficultyLevel,
            achievements: [] // Would be populated by achievement system
        )

        // Update statistics
        self.updateGameModeStats(with: result)

        // Notify delegate
        Task { @MainActor in
            await self.delegate?.winConditionMet(result: result)
        }

        // End game
        self.endGame()
    }

    /// Updates game mode statistics
    /// - Parameter result: The game result to record
    private func updateGameModeStats(with result: GameResult) {
        var stats = self.gameModeStats[result.gameMode] ?? GameModeStats()
        stats.update(with: result)
        self.gameModeStats[result.gameMode] = stats
    }

    /// Gets statistics for a specific game mode
    /// - Parameter mode: The game mode to get stats for
    /// - Returns: Statistics for the game mode
    func getGameModeStats(for mode: GameMode) -> GameModeStats {
        self.gameModeStats[mode] ?? GameModeStats()
    }
}

// MARK: - Supporting Types

/// Secure game statistics structure
private struct GameStatistics: Codable {
    let gamesPlayed: Int
    let totalScore: Int
    let bestSurvivalTime: TimeInterval
    let dataHash: Data?

    /// Verifies data integrity
    func verifyIntegrity() -> Bool {
        guard let storedHash = dataHash else { return false }
        let dataString = "\(gamesPlayed)\(totalScore)\(bestSurvivalTime)"
        let currentHash = SecurityFramework.Crypto.sha256(dataString)
        return storedHash == currentHash
    }
}

/// Win condition checker for different game modes
class WinConditionChecker {
    let winCondition: GameWinCondition

    init(winCondition: GameWinCondition) {
        self.winCondition = winCondition
    }

    @MainActor
    func isMet(with gameState: GameStateManager) -> Bool {
        switch self.winCondition {
        case let .survivalTime(minimum):
            if let minimum {
                return gameState.survivalTime >= minimum
            }
            return false // Endless mode never "wins"
        case let .wavesCompleted(count):
            // Would need wave tracking - for now return false
            return false
        case let .patternsSolved(count):
            // Would need pattern tracking - for now return false
            return false
        case .objectivesCompleted:
            return gameState.currentObjectives.allSatisfy(\.isCompleted)
        case let .scoreReached(target):
            return gameState.score >= target
        case .custom:
            // Custom condition logic
            return false
        }
    }
}

/// Game objective for challenge and puzzle modes
struct GameObjective {
    let description: String
    let type: ObjectiveType
    var progress: Double

    var isCompleted: Bool {
        switch self.type {
        case let .surviveTime(seconds):
            return self.progress >= seconds
        case let .powerUpsCollected(count):
            return self.progress >= Double(count)
        case let .patternsSolved(count):
            return self.progress >= Double(count)
        case let .wavesCompleted(count):
            return self.progress >= Double(count)
        case let .timeLimit(seconds):
            return self.progress <= seconds
        case let .scoreReached(target):
            return self.progress >= Double(target)
        }
    }

    mutating func updateProgress(_ newProgress: Double) {
        self.progress = newProgress
    }
}

/// Types of game objectives
enum ObjectiveType {
    case surviveTime(seconds: Double)
    case powerUpsCollected(count: Int)
    case patternsSolved(count: Int)
    case wavesCompleted(count: Int)
    case timeLimit(seconds: Double)
    case scoreReached(target: Int)

    var targetValue: Double {
        switch self {
        case let .surviveTime(seconds):
            return seconds
        case let .powerUpsCollected(count):
            return Double(count)
        case let .patternsSolved(count):
            return Double(count)
        case let .wavesCompleted(count):
            return Double(count)
        case let .timeLimit(seconds):
            return seconds
        case let .scoreReached(target):
            return Double(target)
        }
    }
}
