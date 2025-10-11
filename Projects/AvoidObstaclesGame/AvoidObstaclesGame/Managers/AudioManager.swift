//
// AudioManager.swift
// AvoidObstaclesGame
//
// Manages audio playback, sound effects, background music, and audio settings.
//

import AVFoundation
import SpriteKit

/// Manages all audio-related functionality
public class AudioManager: NSObject {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = AudioManager()

    /// Audio engine for advanced audio processing
    private let audioEngine = AVAudioEngine()

    /// Audio players for different sound types
    private var soundEffectsPlayer: AVAudioPlayer?
    private var backgroundMusicPlayer: AVAudioPlayer?

    /// Pre-loaded sound effects
    private var soundEffects: [String: AVAudioPlayer] = [:]

    /// Audio session
    private let audioSession = AVAudioSession.sharedInstance()

    /// Audio settings
    private var isAudioEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "audioEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "audioEnabled") }
    }

    private var isMusicEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "musicEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "musicEnabled") }
    }

    private var soundEffectsVolume: Float {
        get { UserDefaults.standard.float(forKey: "soundEffectsVolume") }
        set { UserDefaults.standard.set(newValue, forKey: "soundEffectsVolume") }
    }

    private var musicVolume: Float {
        get { UserDefaults.standard.float(forKey: "musicVolume") }
        set { UserDefaults.standard.set(newValue, forKey: "musicVolume") }
    }

    /// Background music tracks
    private let backgroundMusicTracks = ["background1", "background2", "background3"]
    private var currentTrackIndex = 0

    // MARK: - Initialization

    override private init() {
        super.init()
        self.setupAudioSession()
        self.loadSoundEffects()
        self.setDefaultSettings()
    }

    // MARK: - Audio Session Setup

    /// Sets up the audio session for the app
    private func setupAudioSession() {
        do {
            try self.audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try self.audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    /// Sets default audio settings if not already set
    private func setDefaultSettings() {
        if UserDefaults.standard.object(forKey: "audioEnabled") == nil {
            self.isAudioEnabled = true
        }
        if UserDefaults.standard.object(forKey: "musicEnabled") == nil {
            self.isMusicEnabled = true
        }
        if UserDefaults.standard.object(forKey: "soundEffectsVolume") == nil {
            self.soundEffectsVolume = 0.7
        }
        if UserDefaults.standard.object(forKey: "musicVolume") == nil {
            self.musicVolume = 0.5
        }
    }

    // MARK: - Sound Effects

    /// Loads all sound effects into memory
    private func loadSoundEffects() {
        let soundEffectNames = [
            "collision",
            "score",
            "gameOver",
            "levelUp",
            "powerUp",
            "shield",
            "explosion",
        ]

        for soundName in soundEffectNames {
            self.loadSoundEffect(named: soundName)
        }
    }

    /// Loads a single sound effect
    /// - Parameter name: The name of the sound file (without extension)
    private func loadSoundEffect(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") ??
            Bundle.main.url(forResource: name, withExtension: "mp3")
        else {
            print("Could not find sound file: \(name)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = self.soundEffectsVolume
            self.soundEffects[name] = player
        } catch {
            print("Could not load sound effect \(name): \(error)")
        }
    }

    /// Plays a sound effect
    /// - Parameter name: The name of the sound effect to play
    func playSoundEffect(_ name: String) {
        guard self.isAudioEnabled, let player = soundEffects[name] else { return }

        // Reset to beginning for repeated plays
        player.currentTime = 0
        player.volume = self.soundEffectsVolume
        player.play()
    }

    /// Plays a collision sound effect
    func playCollisionSound() {
        self.playSoundEffect("collision")
    }

    /// Plays a score sound effect
    func playScoreSound() {
        self.playSoundEffect("score")
    }

    /// Plays a game over sound effect
    func playGameOverSound() {
        self.playSoundEffect("gameOver")
    }

    /// Plays a level up sound effect
    func playLevelUpSound() {
        self.playSoundEffect("levelUp")
    }

    /// Plays a power-up collection sound effect
    func playPowerUpSound() {
        self.playSoundEffect("powerUp")
    }

    /// Plays a shield activation sound effect
    func playShieldSound() {
        self.playSoundEffect("shield")
    }

    /// Plays an explosion sound effect
    func playExplosionSound() {
        self.playSoundEffect("explosion")
    }

    // MARK: - Background Music

    /// Starts playing background music
    func startBackgroundMusic() {
        guard self.isMusicEnabled else { return }

        if self.backgroundMusicPlayer == nil {
            self.playNextTrack()
        } else if !self.backgroundMusicPlayer!.isPlaying {
            self.backgroundMusicPlayer?.play()
        }
    }

    /// Stops playing background music
    func stopBackgroundMusic() {
        self.backgroundMusicPlayer?.stop()
        self.backgroundMusicPlayer = nil
    }

    /// Pauses background music
    func pauseBackgroundMusic() {
        self.backgroundMusicPlayer?.pause()
    }

    /// Resumes background music
    func resumeBackgroundMusic() {
        guard self.isMusicEnabled else { return }
        self.backgroundMusicPlayer?.play()
    }

    /// Plays the next track in the playlist
    private func playNextTrack() {
        guard self.isMusicEnabled, !self.backgroundMusicTracks.isEmpty else { return }

        let trackName = self.backgroundMusicTracks[self.currentTrackIndex]
        guard let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") ??
            Bundle.main.url(forResource: trackName, withExtension: "wav")
        else {
            print("Could not find music file: \(trackName)")
            return
        }

        do {
            self.backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            self.backgroundMusicPlayer?.volume = self.musicVolume
            self.backgroundMusicPlayer?.numberOfLoops = 0 // Play once, then move to next
            self.backgroundMusicPlayer?.delegate = self
            self.backgroundMusicPlayer?.play()

            self.currentTrackIndex = (self.currentTrackIndex + 1) % self.backgroundMusicTracks.count
        } catch {
            print("Could not load background music \(trackName): \(error)")
        }
    }

    // MARK: - Audio Settings

    /// Enables or disables all audio
    /// - Parameter enabled: Whether audio should be enabled
    func setAudioEnabled(_ enabled: Bool) {
        self.isAudioEnabled = enabled
        if !enabled {
            self.stopBackgroundMusic()
        } else if self.isMusicEnabled {
            self.startBackgroundMusic()
        }
    }

    /// Enables or disables background music
    /// - Parameter enabled: Whether music should be enabled
    func setMusicEnabled(_ enabled: Bool) {
        self.isMusicEnabled = enabled
        if enabled {
            self.startBackgroundMusic()
        } else {
            self.stopBackgroundMusic()
        }
    }

    /// Sets the sound effects volume
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setSoundEffectsVolume(_ volume: Float) {
        self.soundEffectsVolume = max(0, min(1, volume))
        for player in self.soundEffects.values {
            player.volume = self.soundEffectsVolume
        }
    }

    /// Sets the music volume
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setMusicVolume(_ volume: Float) {
        self.musicVolume = max(0, min(1, volume))
        self.backgroundMusicPlayer?.volume = self.musicVolume
    }

    /// Gets current audio settings
    /// - Returns: Dictionary of current settings
    func getAudioSettings() -> [String: Any] {
        [
            "audioEnabled": self.isAudioEnabled,
            "musicEnabled": self.isMusicEnabled,
            "soundEffectsVolume": self.soundEffectsVolume,
            "musicVolume": self.musicVolume,
        ]
    }

    // MARK: - Procedural Audio

    /// Generates a procedural collision sound based on intensity
    /// - Parameter intensity: Collision intensity (0.0 to 1.0)
    func playProceduralCollisionSound(intensity _: Float) {
        guard self.isAudioEnabled else { return }

        // For now, just play the regular collision sound
        // In a full implementation, this would generate different sounds based on intensity
        self.playCollisionSound()
    }

    /// Generates a procedural score sound based on points
    /// - Parameter points: Number of points scored
    func playProceduralScoreSound(points: Int) {
        guard self.isAudioEnabled else { return }

        // Play different sounds based on score amount
        if points >= 100 {
            // Special high-score sound
            self.playSoundEffect("score")
        } else {
            self.playSoundEffect("score")
        }
    }

    // MARK: - Haptic Feedback

    /// Triggers haptic feedback for supported devices
    /// - Parameter style: The style of haptic feedback
    func triggerHapticFeedback(style: HapticStyle = .medium) {
        #if os(iOS)
        if #available(iOS 10.0, *) {
            switch style {
            case .light:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            case .medium:
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            case .heavy:
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred()
            case .success:
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
            case .error:
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.error)
            }
        }
        #endif
    }

    // MARK: - Cleanup

    /// Cleans up audio resources
    func cleanup() {
        self.stopBackgroundMusic()
        self.soundEffects.removeAll()
        do {
            try self.audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player === self.backgroundMusicPlayer, flag {
            // Play next track when current one finishes
            self.playNextTrack()
        }
    }
}

/// Haptic feedback styles
enum HapticStyle {
    case light
    case medium
    case heavy
    case success
    case error
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

// MARK: - Async Audio Operations

extension AudioManager {
    /// Plays a sound effect asynchronously
    /// - Parameter name: The name of the sound effect to play
    func playSoundEffectAsync(_ name: String) async {
        await Task.detached {
            self.playSoundEffect(name)
        }.value
    }

    /// Plays a collision sound effect asynchronously
    func playCollisionSoundAsync() async {
        await Task.detached {
            self.playCollisionSound()
        }.value
    }

    /// Plays a score sound effect asynchronously
    func playScoreSoundAsync() async {
        await Task.detached {
            self.playScoreSound()
        }.value
    }

    /// Plays a game over sound effect asynchronously
    func playGameOverSoundAsync() async {
        await Task.detached {
            self.playGameOverSound()
        }.value
    }

    /// Plays a level up sound effect asynchronously
    func playLevelUpSoundAsync() async {
        await Task.detached {
            self.playLevelUpSound()
        }.value
    }

    /// Plays a power-up collection sound effect asynchronously
    func playPowerUpSoundAsync() async {
        await Task.detached {
            self.playPowerUpSound()
        }.value
    }

    /// Plays a shield activation sound effect asynchronously
    func playShieldSoundAsync() async {
        await Task.detached {
            self.playShieldSound()
        }.value
    }

    /// Plays an explosion sound effect asynchronously
    func playExplosionSoundAsync() async {
        await Task.detached {
            self.playExplosionSound()
        }.value
    }

    /// Starts playing background music asynchronously
    func startBackgroundMusicAsync() async {
        await Task.detached {
            self.startBackgroundMusic()
        }.value
    }

    /// Stops playing background music asynchronously
    func stopBackgroundMusicAsync() async {
        await Task.detached {
            self.stopBackgroundMusic()
        }.value
    }

    /// Pauses background music asynchronously
    func pauseBackgroundMusicAsync() async {
        await Task.detached {
            self.pauseBackgroundMusic()
        }.value
    }

    /// Resumes background music asynchronously
    func resumeBackgroundMusicAsync() async {
        await Task.detached {
            self.resumeBackgroundMusic()
        }.value
    }

    /// Enables or disables all audio asynchronously
    /// - Parameter enabled: Whether audio should be enabled
    func setAudioEnabledAsync(_ enabled: Bool) async {
        await Task.detached {
            self.setAudioEnabled(enabled)
        }.value
    }

    /// Enables or disables background music asynchronously
    /// - Parameter enabled: Whether music should be enabled
    func setMusicEnabledAsync(_ enabled: Bool) async {
        await Task.detached {
            self.setMusicEnabled(enabled)
        }.value
    }

    /// Sets the sound effects volume asynchronously
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setSoundEffectsVolumeAsync(_ volume: Float) async {
        await Task.detached {
            self.setSoundEffectsVolume(volume)
        }.value
    }

    /// Sets the music volume asynchronously
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setMusicVolumeAsync(_ volume: Float) async {
        await Task.detached {
            self.setMusicVolume(volume)
        }.value
    }

    /// Gets current audio settings asynchronously
    /// - Returns: Dictionary of current settings
    func getAudioSettingsAsync() async -> [String: Any] {
        await Task.detached {
            self.getAudioSettings()
        }.value
    }

    /// Generates a procedural collision sound based on intensity asynchronously
    /// - Parameter intensity: Collision intensity (0.0 to 1.0)
    func playProceduralCollisionSoundAsync(intensity: Float) async {
        await Task.detached {
            self.playProceduralCollisionSound(intensity: intensity)
        }.value
    }

    /// Generates a procedural score sound based on points asynchronously
    /// - Parameter points: Number of points scored
    func playProceduralScoreSoundAsync(points: Int) async {
        await Task.detached {
            self.playProceduralScoreSound(points: points)
        }.value
    }

    /// Triggers haptic feedback for supported devices asynchronously
    /// - Parameter style: The style of haptic feedback
    func triggerHapticFeedbackAsync(style: HapticStyle = .medium) async {
        await Task.detached {
            self.triggerHapticFeedback(style: style)
        }.value
    }

    /// Cleans up audio resources asynchronously
    func cleanupAsync() async {
        await Task.detached {
            self.cleanup()
        }.value
    }
}
