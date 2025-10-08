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

        self.score += points

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
