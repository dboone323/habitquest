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
            self.delegate?.gameStateDidChange(from: oldValue, to: self.currentState)
        }
    }

    /// Current score
    private(set) var score: Int = 0 {
        didSet {
            self.delegate?.scoreDidChange(to: self.score)
            self.updateDifficultyIfNeeded()
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
        self.loadStatistics()
    }

    // MARK: - Game Lifecycle

    /// Starts a new game
    func startGame() {
        self.currentState = .playing
        self.score = 0
        self.currentDifficultyLevel = 1
        self.currentDifficulty = GameDifficulty.getDifficulty(for: 0)
        self.gameStartTime = Date()
        self.survivalTime = 0
        self.gamesPlayed += 1
        self.saveStatistics()
    }

    /// Ends the current game
    func endGame() {
        self.currentState = .gameOver
        self.survivalTime = self.gameStartTime.map { Date().timeIntervalSince($0) } ?? 0
        self.totalScore += self.score

        if self.survivalTime > self.bestSurvivalTime {
            self.bestSurvivalTime = self.survivalTime
        }

        self.saveStatistics()
        self.delegate?.gameDidEnd(withScore: self.score, survivalTime: self.survivalTime)
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

    /// Adds points to the score
    /// - Parameter points: Number of points to add
    func addScore(_ points: Int) {
        guard self.currentState == .playing else { return }
        self.score += points
    }

    /// Gets the current score
    /// - Returns: Current score value
    func getCurrentScore() -> Int {
        self.score
    }

    // MARK: - Difficulty Management

    /// Updates difficulty based on current score
    private func updateDifficultyIfNeeded() {
        let newDifficulty = GameDifficulty.getDifficulty(for: self.score)
        let newLevel = GameDifficulty.getDifficultyLevel(for: self.score)

        if newLevel > self.currentDifficultyLevel {
            self.currentDifficultyLevel = newLevel
            self.currentDifficulty = newDifficulty
            self.delegate?.difficultyDidIncrease(to: newLevel)
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
        self.gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        self.totalScore = defaults.integer(forKey: "totalScore")
        self.bestSurvivalTime = defaults.double(forKey: "bestSurvivalTime")
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
        defaults.set(self.gamesPlayed, forKey: "gamesPlayed")
        defaults.set(self.totalScore, forKey: "totalScore")
        defaults.set(self.bestSurvivalTime, forKey: "bestSurvivalTime")
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
