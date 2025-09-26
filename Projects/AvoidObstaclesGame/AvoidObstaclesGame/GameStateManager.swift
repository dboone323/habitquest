//
// GameStateManager.swift
// AvoidObstaclesGame
//
// Manages the overall game state, score tracking, difficulty progression,
// and game lifecycle events.
//

import Foundation

/// Protocol for game state change notifications
protocol GameStateDelegate: AnyObject {
    func gameStateDidChange(from oldState: GameState, to newState: GameState)
    func scoreDidChange(to newScore: Int)
    func difficultyDidIncrease(to level: Int)
    func gameDidEnd(withScore finalScore: Int, survivalTime: TimeInterval)
}

/// Represents the current state of the game
enum GameState {
    case waitingToStart
    case playing
    case paused
    case gameOver
}

/// Manages the core game state and logic
class GameStateManager {
    // MARK: - Properties

    /// Delegate for state change notifications
    weak var delegate: GameStateDelegate?

    /// Current game state
    private(set) var currentState: GameState = .waitingToStart {
        didSet {
            delegate?.gameStateDidChange(from: oldValue, to: currentState)
        }
    }

    /// Current score
    private(set) var score: Int = 0 {
        didSet {
            delegate?.scoreDidChange(to: score)
            updateDifficultyIfNeeded()
        }
    }

    /// Current difficulty level
    private(set) var currentDifficultyLevel: Int = 1

    /// Current difficulty settings
    private(set) var currentDifficulty: GameDifficulty = .getDifficulty(for: 0)

    /// Game start time for survival tracking
    private var gameStartTime: Date?

    /// Total survival time in current game
    private(set) var survivalTime: TimeInterval = 0

    /// Statistics tracking
    private var gamesPlayed: Int = 0
    private var totalScore: Int = 0
    private var bestSurvivalTime: TimeInterval = 0

    // MARK: - Initialization

    init() {
        loadStatistics()
    }

    // MARK: - Game Lifecycle

    /// Starts a new game
    func startGame() {
        currentState = .playing
        score = 0
        currentDifficultyLevel = 1
        currentDifficulty = GameDifficulty.getDifficulty(for: 0)
        gameStartTime = Date()
        survivalTime = 0
        gamesPlayed += 1
        saveStatistics()
    }

    /// Ends the current game
    func endGame() {
        currentState = .gameOver
        survivalTime = gameStartTime.map { Date().timeIntervalSince($0) } ?? 0
        totalScore += score

        if survivalTime > bestSurvivalTime {
            bestSurvivalTime = survivalTime
        }

        saveStatistics()
        delegate?.gameDidEnd(withScore: score, survivalTime: survivalTime)
    }

    /// Pauses the game
    func pauseGame() {
        guard currentState == .playing else { return }
        currentState = .paused
    }

    /// Resumes the game
    func resumeGame() {
        guard currentState == .paused else { return }
        currentState = .playing
    }

    /// Restarts the game
    func restartGame() {
        endGame()
        startGame()
    }

    // MARK: - Score Management

    /// Adds points to the score
    /// - Parameter points: Number of points to add
    func addScore(_ points: Int) {
        guard currentState == .playing else { return }
        score += points
    }

    /// Gets the current score
    /// - Returns: Current score value
    func getCurrentScore() -> Int {
        score
    }

    // MARK: - Difficulty Management

    /// Updates difficulty based on current score
    private func updateDifficultyIfNeeded() {
        let newDifficulty = GameDifficulty.getDifficulty(for: score)
        let newLevel = GameDifficulty.getDifficultyLevel(for: score)

        if newLevel > currentDifficultyLevel {
            currentDifficultyLevel = newLevel
            currentDifficulty = newDifficulty
            delegate?.difficultyDidIncrease(to: newLevel)
        }
    }

    /// Gets current difficulty settings
    /// - Returns: Current GameDifficulty
    func getCurrentDifficulty() -> GameDifficulty {
        currentDifficulty
    }

    /// Gets current difficulty level
    /// - Returns: Current difficulty level
    func getCurrentDifficultyLevel() -> Int {
        currentDifficultyLevel
    }

    // MARK: - Statistics

    /// Gets game statistics
    /// - Returns: Dictionary of statistics
    func getStatistics() -> [String: Any] {
        [
            "gamesPlayed": gamesPlayed,
            "totalScore": totalScore,
            "averageScore": gamesPlayed > 0 ? Double(totalScore) / Double(gamesPlayed) : 0,
            "bestSurvivalTime": bestSurvivalTime,
            "highestScore": HighScoreManager.shared.getHighestScore(),
        ]
    }

    /// Gets game statistics (async version)
    /// - Returns: Dictionary of statistics
    func getStatisticsAsync() async -> [String: Any] {
        let highestScore = await HighScoreManager.shared.getHighestScoreAsync()
        return [
            "gamesPlayed": gamesPlayed,
            "totalScore": totalScore,
            "averageScore": gamesPlayed > 0 ? Double(totalScore) / Double(gamesPlayed) : 0,
            "bestSurvivalTime": bestSurvivalTime,
            "highestScore": highestScore,
        ]
    }

    /// Resets all statistics
    func resetStatistics() {
        gamesPlayed = 0
        totalScore = 0
        bestSurvivalTime = 0
        UserDefaults.standard.removeObject(forKey: "gameStatistics")
        UserDefaults.standard.synchronize()
    }

    /// Resets all statistics (async version)
    func resetStatisticsAsync() async {
        await Task.detached {
            self.gamesPlayed = 0
            self.totalScore = 0
            self.bestSurvivalTime = 0
            UserDefaults.standard.removeObject(forKey: "gameStatistics")
            UserDefaults.standard.synchronize()
        }.value
    }

    // MARK: - Persistence

    private func loadStatistics() {
        let defaults = UserDefaults.standard
        gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        totalScore = defaults.integer(forKey: "totalScore")
        bestSurvivalTime = defaults.double(forKey: "bestSurvivalTime")
    }

    private func loadStatisticsAsync() async {
        await Task.detached {
            let defaults = UserDefaults.standard
            self.gamesPlayed = defaults.integer(forKey: "gamesPlayed")
            self.totalScore = defaults.integer(forKey: "totalScore")
            self.bestSurvivalTime = defaults.double(forKey: "bestSurvivalTime")
        }.value
    }

    private func saveStatistics() {
        let defaults = UserDefaults.standard
        defaults.set(gamesPlayed, forKey: "gamesPlayed")
        defaults.set(totalScore, forKey: "totalScore")
        defaults.set(bestSurvivalTime, forKey: "bestSurvivalTime")
        defaults.synchronize()
    }

    private func saveStatisticsAsync() async {
        await Task.detached {
            let defaults = UserDefaults.standard
            defaults.set(self.gamesPlayed, forKey: "gamesPlayed")
            defaults.set(self.totalScore, forKey: "totalScore")
            defaults.set(self.bestSurvivalTime, forKey: "bestSurvivalTime")
            defaults.synchronize()
        }.value
    }

    // MARK: - State Queries

    /// Checks if the game is currently active
    /// - Returns: True if game is playing
    func isGameActive() -> Bool {
        currentState == .playing
    }

    /// Checks if the game is over
    /// - Returns: True if game is over
    func isGameOver() -> Bool {
        currentState == .gameOver
    }

    /// Checks if the game is paused
    /// - Returns: True if game is paused
    func isGamePaused() -> Bool {
        currentState == .paused
    }
}

// MARK: - Object Pooling

/// Object pool for performance optimization
private var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
