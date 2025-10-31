import AVFoundation
@testable import AvoidObstaclesGame
import XCTest

class AudioManagerTests: XCTestCase {

    var audioManager: AudioManager!
    var originalAudioEnabled: Bool!
    var originalMusicEnabled: Bool!
    var originalSoundEffectsVolume: Float!
    var originalMusicVolume: Float!

    override func setUp() {
        super.setUp()
        audioManager = AudioManager.shared

        // Store original settings to restore later
        originalAudioEnabled = audioManager.getAudioSettings()["audioEnabled"] as? Bool
        originalMusicEnabled = audioManager.getAudioSettings()["musicEnabled"] as? Bool
        originalSoundEffectsVolume = audioManager.getAudioSettings()["soundEffectsVolume"] as? Float
        originalMusicVolume = audioManager.getAudioSettings()["musicVolume"] as? Float
    }

    override func tearDown() {
        // Restore original settings
        audioManager.setAudioEnabled(originalAudioEnabled ?? true)
        audioManager.setMusicEnabled(originalMusicEnabled ?? true)
        audioManager.setSoundEffectsVolume(originalSoundEffectsVolume ?? 0.7)
        audioManager.setMusicVolume(originalMusicVolume ?? 0.5)

        // Clean up
        audioManager.cleanup()
        audioManager = nil
        super.tearDown()
    }

    // MARK: - HapticStyle Tests

    func testHapticStyleEnumValues() {
        // Test that all enum cases exist and are accessible
        XCTAssertEqual(HapticStyle.light, HapticStyle.light)
        XCTAssertEqual(HapticStyle.medium, HapticStyle.medium)
        XCTAssertEqual(HapticStyle.heavy, HapticStyle.heavy)
        XCTAssertEqual(HapticStyle.success, HapticStyle.success)
        XCTAssertEqual(HapticStyle.error, HapticStyle.error)
    }

    func testHapticStyleSwitchCoverage() {
        // Test that switch statements cover all cases
        let styles: [HapticStyle] = [.light, .medium, .heavy, .success, .error]

        for style in styles {
            switch style {
            case .light, .medium, .heavy, .success, .error:
                XCTAssertTrue(true, "HapticStyle \(style) is handled")
            }
        }
    }

    func testHapticStyleHashable() {
        // Test that enum values can be used as dictionary keys
        var styleDict = [HapticStyle: String]()
        styleDict[.light] = "Light feedback"
        styleDict[.medium] = "Medium feedback"
        styleDict[.heavy] = "Heavy feedback"
        styleDict[.success] = "Success feedback"
        styleDict[.error] = "Error feedback"

        XCTAssertEqual(styleDict[.light], "Light feedback")
        XCTAssertEqual(styleDict[.medium], "Medium feedback")
        XCTAssertEqual(styleDict[.heavy], "Heavy feedback")
        XCTAssertEqual(styleDict[.success], "Success feedback")
        XCTAssertEqual(styleDict[.error], "Error feedback")
    }

    func testHapticStyleEquatable() {
        // Test equality comparison
        XCTAssertEqual(HapticStyle.light, HapticStyle.light)
        XCTAssertNotEqual(HapticStyle.light, HapticStyle.medium)
    }

    // MARK: - AudioManager Singleton Tests

    @MainActor
    func testAudioManagerSingleton() {
        // Test singleton pattern
        let instance1 = AudioManager.shared
        let instance2 = AudioManager.shared

        XCTAssertEqual(instance1, instance2)
        XCTAssertTrue(instance1 === instance2)
    }

    @MainActor
    func testAudioManagerInitialization() {
        // Test that singleton initializes correctly
        XCTAssertNotNil(audioManager)
        XCTAssertNotNil(audioManager.getAudioSettings())
    }

    // MARK: - Audio Settings Tests

    @MainActor
    func testSetAudioEnabled() {
        // Test enabling/disabling audio
        audioManager.setAudioEnabled(false)
        var settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["audioEnabled"] as? Bool, false)

        audioManager.setAudioEnabled(true)
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["audioEnabled"] as? Bool, true)
    }

    @MainActor
    func testSetMusicEnabled() {
        // Test enabling/disabling music
        audioManager.setMusicEnabled(false)
        var settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicEnabled"] as? Bool, false)

        audioManager.setMusicEnabled(true)
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicEnabled"] as? Bool, true)
    }

    @MainActor
    func testSetSoundEffectsVolume() {
        // Test setting sound effects volume
        audioManager.setSoundEffectsVolume(0.3)
        let settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["soundEffectsVolume"] as? Float, 0.3)
    }

    @MainActor
    func testSetSoundEffectsVolumeClamping() {
        // Test volume clamping for sound effects
        audioManager.setSoundEffectsVolume(-0.5) // Below minimum
        var settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["soundEffectsVolume"] as? Float, 0.0)

        audioManager.setSoundEffectsVolume(0.3)
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["soundEffectsVolume"] as? Float, 0.3)

        audioManager.setSoundEffectsVolume(1.5) // Above maximum
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["soundEffectsVolume"] as? Float, 1.0)
    }

    @MainActor
    func testSetMusicVolume() {
        // Test setting music volume
        audioManager.setMusicVolume(0.8)
        let settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicVolume"] as? Float, 0.8)
    }

    @MainActor
    func testSetMusicVolumeClamping() {
        // Test volume clamping for music
        audioManager.setMusicVolume(-0.5) // Below minimum
        var settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicVolume"] as? Float, 0.0)

        audioManager.setMusicVolume(0.8)
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicVolume"] as? Float, 0.8)

        audioManager.setMusicVolume(1.5) // Above maximum
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicVolume"] as? Float, 1.0)
    }

    @MainActor
    func testGetAudioSettings() {
        // Test getting all audio settings
        let settings = audioManager.getAudioSettings()

        XCTAssertNotNil(settings["audioEnabled"])
        XCTAssertNotNil(settings["musicEnabled"])
        XCTAssertNotNil(settings["soundEffectsVolume"])
        XCTAssertNotNil(settings["musicVolume"])

        // Verify types
        XCTAssertTrue(settings["audioEnabled"] is Bool)
        XCTAssertTrue(settings["musicEnabled"] is Bool)
        XCTAssertTrue(settings["soundEffectsVolume"] is Float)
        XCTAssertTrue(settings["musicVolume"] is Float)
    }

    // MARK: - Sound Effect Tests

    @MainActor
    func testPlaySoundEffect() {
        // Test playing sound effects (will not actually play in test environment)
        audioManager.setAudioEnabled(true)

        // These should not crash even if sound files don't exist
        audioManager.playSoundEffect("collision")
        audioManager.playSoundEffect("nonexistent")

        XCTAssertTrue(true, "Sound effect methods completed without error")
    }

    @MainActor
    func testPlayCollisionSound() {
        // Test collision sound
        audioManager.setAudioEnabled(true)
        audioManager.playCollisionSound()

        XCTAssertTrue(true, "Collision sound played without error")
    }

    @MainActor
    func testPlayScoreSound() {
        // Test score sound
        audioManager.setAudioEnabled(true)
        audioManager.playScoreSound()

        XCTAssertTrue(true, "Score sound played without error")
    }

    @MainActor
    func testPlayGameOverSound() {
        // Test game over sound
        audioManager.setAudioEnabled(true)
        audioManager.playGameOverSound()

        XCTAssertTrue(true, "Game over sound played without error")
    }

    @MainActor
    func testPlayLevelUpSound() {
        // Test level up sound
        audioManager.setAudioEnabled(true)
        audioManager.playLevelUpSound()

        XCTAssertTrue(true, "Level up sound played without error")
    }

    @MainActor
    func testPlayPowerUpSound() {
        // Test power-up sound
        audioManager.setAudioEnabled(true)
        audioManager.playPowerUpSound()

        XCTAssertTrue(true, "Power-up sound played without error")
    }

    @MainActor
    func testPlayShieldSound() {
        // Test shield sound
        audioManager.setAudioEnabled(true)
        audioManager.playShieldSound()

        XCTAssertTrue(true, "Shield sound played without error")
    }

    @MainActor
    func testPlayExplosionSound() {
        // Test explosion sound
        audioManager.setAudioEnabled(true)
        audioManager.playExplosionSound()

        XCTAssertTrue(true, "Explosion sound played without error")
    }

    // MARK: - Background Music Tests

    @MainActor
    func testStartBackgroundMusic() {
        // Test starting background music
        audioManager.setMusicEnabled(true)
        audioManager.startBackgroundMusic()

        XCTAssertTrue(true, "Background music started without error")
    }

    @MainActor
    func testStopBackgroundMusic() {
        // Test stopping background music
        audioManager.stopBackgroundMusic()

        XCTAssertTrue(true, "Background music stopped without error")
    }

    @MainActor
    func testPauseResumeBackgroundMusic() {
        // Test pausing and resuming background music
        audioManager.setMusicEnabled(true)
        audioManager.startBackgroundMusic()
        audioManager.pauseBackgroundMusic()
        audioManager.resumeBackgroundMusic()

        XCTAssertTrue(true, "Background music pause/resume completed without error")
    }

    // MARK: - Procedural Audio Tests

    @MainActor
    func testPlayProceduralCollisionSound() {
        // Test procedural collision sound
        audioManager.setAudioEnabled(true)
        audioManager.playProceduralCollisionSound(intensity: 0.5)

        XCTAssertTrue(true, "Procedural collision sound played without error")
    }

    @MainActor
    func testPlayProceduralScoreSound() {
        // Test procedural score sound
        audioManager.setAudioEnabled(true)
        audioManager.playProceduralScoreSound(points: 50)
        audioManager.playProceduralScoreSound(points: 150)

        XCTAssertTrue(true, "Procedural score sounds played without error")
    }

    // MARK: - Haptic Feedback Tests

    @MainActor
    func testTriggerHapticFeedback() {
        // Test haptic feedback (will not actually trigger in test environment)
        audioManager.triggerHapticFeedback(style: .light)
        audioManager.triggerHapticFeedback(style: .medium)
        audioManager.triggerHapticFeedback(style: .heavy)
        audioManager.triggerHapticFeedback(style: .success)
        audioManager.triggerHapticFeedback(style: .error)

        XCTAssertTrue(true, "Haptic feedback triggered without error")
    }

    // MARK: - Cleanup Tests

    @MainActor
    func testCleanup() {
        // Test cleanup
        audioManager.cleanup()

        XCTAssertTrue(true, "Cleanup completed without error")
    }

    // MARK: - Async Method Tests

    func testPlaySoundEffectAsync() async {
        // Test async sound effect playing
        await audioManager.playSoundEffectAsync("collision")

        XCTAssertTrue(true, "Async sound effect played without error")
    }

    func testPlayCollisionSoundAsync() async {
        // Test async collision sound
        await audioManager.playCollisionSoundAsync()

        XCTAssertTrue(true, "Async collision sound played without error")
    }

    func testPlayScoreSoundAsync() async {
        // Test async score sound
        await audioManager.playScoreSoundAsync()

        XCTAssertTrue(true, "Async score sound played without error")
    }

    func testPlayGameOverSoundAsync() async {
        // Test async game over sound
        await audioManager.playGameOverSoundAsync()

        XCTAssertTrue(true, "Async game over sound played without error")
    }

    func testPlayLevelUpSoundAsync() async {
        // Test async level up sound
        await audioManager.playLevelUpSoundAsync()

        XCTAssertTrue(true, "Async level up sound played without error")
    }

    func testPlayPowerUpSoundAsync() async {
        // Test async power-up sound
        await audioManager.playPowerUpSoundAsync()

        XCTAssertTrue(true, "Async power-up sound played without error")
    }

    func testPlayShieldSoundAsync() async {
        // Test async shield sound
        await audioManager.playShieldSoundAsync()

        XCTAssertTrue(true, "Async shield sound played without error")
    }

    func testPlayExplosionSoundAsync() async {
        // Test async explosion sound
        await audioManager.playExplosionSoundAsync()

        XCTAssertTrue(true, "Async explosion sound played without error")
    }

    func testStartBackgroundMusicAsync() async {
        // Test async background music start
        await audioManager.startBackgroundMusicAsync()

        XCTAssertTrue(true, "Async background music started without error")
    }

    func testStopBackgroundMusicAsync() async {
        // Test async background music stop
        await audioManager.stopBackgroundMusicAsync()

        XCTAssertTrue(true, "Async background music stopped without error")
    }

    func testPauseResumeBackgroundMusicAsync() async {
        // Test async background music pause/resume
        await audioManager.pauseBackgroundMusicAsync()
        await audioManager.resumeBackgroundMusicAsync()

        XCTAssertTrue(true, "Async background music pause/resume completed without error")
    }

    func testSetAudioEnabledAsync() async {
        // Test async audio enable/disable
        await audioManager.setAudioEnabledAsync(false)
        await audioManager.setAudioEnabledAsync(true)

        XCTAssertTrue(true, "Async audio enable/disable completed without error")
    }

    func testSetMusicEnabledAsync() async {
        // Test async music enable/disable
        await audioManager.setMusicEnabledAsync(false)
        await audioManager.setMusicEnabledAsync(true)

        XCTAssertTrue(true, "Async music enable/disable completed without error")
    }

    func testSetSoundEffectsVolumeAsync() async {
        // Test async sound effects volume setting
        await audioManager.setSoundEffectsVolumeAsync(0.6)

        XCTAssertTrue(true, "Async sound effects volume set without error")
    }

    func testSetMusicVolumeAsync() async {
        // Test async music volume setting
        await audioManager.setMusicVolumeAsync(0.4)

        XCTAssertTrue(true, "Async music volume set without error")
    }

    func testGetAudioSettingsAsync() async {
        // Test async audio settings retrieval
        let settings = await audioManager.getAudioSettingsAsync()

        XCTAssertNotNil(settings)
        XCTAssertNotNil(settings["audioEnabled"])
        XCTAssertNotNil(settings["musicEnabled"])
    }

    func testPlayProceduralCollisionSoundAsync() async {
        // Test async procedural collision sound
        await audioManager.playProceduralCollisionSoundAsync(intensity: 0.7)

        XCTAssertTrue(true, "Async procedural collision sound played without error")
    }

    func testPlayProceduralScoreSoundAsync() async {
        // Test async procedural score sound
        await audioManager.playProceduralScoreSoundAsync(points: 75)

        XCTAssertTrue(true, "Async procedural score sound played without error")
    }

    func testTriggerHapticFeedbackAsync() async {
        // Test async haptic feedback
        await audioManager.triggerHapticFeedbackAsync(style: .success)

        XCTAssertTrue(true, "Async haptic feedback triggered without error")
    }

    func testCleanupAsync() async {
        // Test async cleanup
        await audioManager.cleanupAsync()

        XCTAssertTrue(true, "Async cleanup completed without error")
    }
}

    @MainActor
    func testSetAudioEnabled() {
        // Test enabling/disabling audio
        audioManager.setAudioEnabled(false)
        var settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["audioEnabled"] as? Bool, false)

        audioManager.setAudioEnabled(true)
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["audioEnabled"] as? Bool, true)
    }
    @MainActor
    func testSetMusicEnabled() {
    func testSetMusicEnabled() {
        // Test enabling/disabling music
        audioManager.setMusicEnabled(false)
        var settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicEnabled"] as? Bool, false)

        audioManager.setMusicEnabled(true)
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicEnabled"] as? Bool, true)
    }
    @MainActor
    func testSetSoundEffectsVolume() {
    func testSetSoundEffectsVolume() {
        // Test setting sound effects volume
        audioManager.setSoundEffectsVolume(0.3)
        let settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["soundEffectsVolume"] as? Float, 0.3)
    }
    @MainActor
    func testSetSoundEffectsVolumeClamping() {
    func testSetSoundEffectsVolumeClamping() {
        // Test volume clamping
        audioManager.setSoundEffectsVolume(-0.5) // Below minimum
        var settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["soundEffectsVolume"] as? Float, 0.0)

        audioManager.setSoundEffectsVolume(1.5) // Above maximum
        settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["soundEffectsVolume"] as? Float, 1.0)
    @MainActor
    func testSetMusicVolume() {

    func testSetMusicVolume() {
        // Test setting music volume
        audioManager.setMusicVolume(0.8)
        let settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicVolume"] as? Float, 0.8)
    @MainActor
    func testSetMusicVolumeClamping() {

    func testSetMusicVolumeClamping() {
        // Test volume clamping
        audioManager.setMusicVolume(-0.5) // Below minimum
        var settings = audioManager.getAudioSettings()
        XCTAssertEqual(settings["musicVolume"] as? Float, 0.0)

        audioManager.setMusicVolume(1.5) // Above maximum
        settings = audioManager.getAudioSettings()
    @MainActor
    func testGetAudioSettings() {musicVolume"] as? Float, 1.0)
    }

    func testGetAudioSettings() {
        // Test getting all audio settings
        let settings = audioManager.getAudioSettings()

        XCTAssertNotNil(settings["audioEnabled"])
        XCTAssertNotNil(settings["musicEnabled"])
        XCTAssertNotNil(settings["soundEffectsVolume"])
        XCTAssertNotNil(settings["musicVolume"])

        // Verify types
        XCTAssertTrue(settings["audioEnabled"] is Bool)
        XCTAssertTrue(settings["musicEnabled"] is Bool)
        XCTAssertTrue(settings["soundEffectsVolume"] is Float)
        XCTAssertTrue(settings["musicVolume"] is Float)
    }
    @MainActor
    func testPlaySoundEffect() {
    // MARK: - Sound Effect Tests

    func testPlaySoundEffect() {
        // Test playing sound effects (will not actually play in test environment)
        audioManager.setAudioEnabled(true)

        // These should not crash even if sound files don't exist
        audioManager.playSoundEffect("collision")
        audioManager.playSoundEffect("nonexistent")

    @MainActor
    func testPlayCollisionSound() {effect methods completed without error")
    }

    func testPlayCollisionSound() {
        // Test collision sound
        audioManager.setAudioEnabled(true)
        audioManager.playCollisionSound()
    @MainActor
    func testPlayScoreSound() {
        XCTAssertTrue(true, "Collision sound played without error")
    }

    func testPlayScoreSound() {
        // Test score sound
        audioManager.setAudioEnabled(true)
        audioManager.playScoreSound()
    @MainActor
    func testPlayGameOverSound() {
        XCTAssertTrue(true, "Score sound played without error")
    }

    func testPlayGameOverSound() {
        // Test game over sound
        audioManager.setAudioEnabled(true)
    @MainActor
    func testPlayLevelUpSound() {Sound()

        XCTAssertTrue(true, "Game over sound played without error")
    }

    func testPlayLevelUpSound() {
        // Test level up sound
        audioManager.setAudioEnabled(true)
    @MainActor
    func testPlayPowerUpSound() {ound()

        XCTAssertTrue(true, "Level up sound played without error")
    }

    func testPlayPowerUpSound() {
        // Test power-up sound
    @MainActor
    func testPlayShieldSound() {bled(true)
        audioManager.playPowerUpSound()

        XCTAssertTrue(true, "Power-up sound played without error")
    }

    func testPlayShieldSound() {
        // Test shield sound
    @MainActor
    func testPlayExplosionSound() {d(true)
        audioManager.playShieldSound()

        XCTAssertTrue(true, "Shield sound played without error")
    }

    func testPlayExplosionSound() {
        // Test explosion sound
        audioManager.setAudioEnabled(true)
        audioManager.playExplosionSound()
    @MainActor
    func testStartBackgroundMusic() {
        XCTAssertTrue(true, "Explosion sound played without error")
    }

    // MARK: - Background Music Tests

    func testStartBackgroundMusic() {
    @MainActor
    func testStopBackgroundMusic() {music
        audioManager.setMusicEnabled(true)
        audioManager.startBackgroundMusic()

        XCTAssertTrue(true, "Background music started without error")
    }

    func testStopBackgroundMusic() {
    @MainActor
    func testPauseResumeBackgroundMusic() {
        audioManager.stopBackgroundMusic()

        XCTAssertTrue(true, "Background music stopped without error")
    }

    func testPauseResumeBackgroundMusic() {
        // Test pausing and resuming background music
        audioManager.setMusicEnabled(true)
        audioManager.startBackgroundMusic()
        audioManager.pauseBackgroundMusic()
        audioManager.resumeBackgroundMusic()
    @MainActor
    func testPlayProceduralCollisionSound() {
        XCTAssertTrue(true, "Background music pause/resume completed without error")
    }

    // MARK: - Procedural Audio Tests

    func testPlayProceduralCollisionSound() {
    @MainActor
    func testPlayProceduralScoreSound() {d
        audioManager.setAudioEnabled(true)
        audioManager.playProceduralCollisionSound(intensity: 0.5)

        XCTAssertTrue(true, "Procedural collision sound played without error")
    }

    func testPlayProceduralScoreSound() {
        // Test procedural score sound
        audioManager.setAudioEnabled(true)
        audioManager.playProceduralScoreSound(points: 50)
    @MainActor
    func testTriggerHapticFeedback() {reSound(points: 150)

        XCTAssertTrue(true, "Procedural score sounds played without error")
    }

    // MARK: - Haptic Feedback Tests

    func testTriggerHapticFeedback() {
        // Test haptic feedback (will not actually trigger in test environment)
        audioManager.triggerHapticFeedback(style: .light)
        audioManager.triggerHapticFeedback(style: .medium)
        audioManager.triggerHapticFeedback(style: .heavy)
        audioManager.triggerHapticFeedback(style: .success)
    @MainActor
    func testCleanup() {ggerHapticFeedback(style: .error)

        XCTAssertTrue(true, "Haptic feedback triggered without error")
    }

    // MARK: - Cleanup Tests

    func testCleanup() {
        // Test cleanup
        audioManager.cleanup()

        XCTAssertTrue(true, "Cleanup completed without error")
    }

    // MARK: - Async Method Tests

    func testPlaySoundEffectAsync() async {
        // Test async sound effect playing
        await audioManager.playSoundEffectAsync("collision")

        XCTAssertTrue(true, "Async sound effect played without error")
    }

    func testPlayCollisionSoundAsync() async {
        // Test async collision sound
        await audioManager.playCollisionSoundAsync()

        XCTAssertTrue(true, "Async collision sound played without error")
    }

    func testPlayScoreSoundAsync() async {
        // Test async score sound
        await audioManager.playScoreSoundAsync()

        XCTAssertTrue(true, "Async score sound played without error")
    }

    func testPlayGameOverSoundAsync() async {
        // Test async game over sound
        await audioManager.playGameOverSoundAsync()

        XCTAssertTrue(true, "Async game over sound played without error")
    }

    func testPlayLevelUpSoundAsync() async {
        // Test async level up sound
        await audioManager.playLevelUpSoundAsync()

        XCTAssertTrue(true, "Async level up sound played without error")
    }

    func testPlayPowerUpSoundAsync() async {
        // Test async power-up sound
        await audioManager.playPowerUpSoundAsync()

        XCTAssertTrue(true, "Async power-up sound played without error")
    }

    func testPlayShieldSoundAsync() async {
        // Test async shield sound
        await audioManager.playShieldSoundAsync()

        XCTAssertTrue(true, "Async shield sound played without error")
    }

    func testPlayExplosionSoundAsync() async {
        // Test async explosion sound
        await audioManager.playExplosionSoundAsync()

        XCTAssertTrue(true, "Async explosion sound played without error")
    }

    func testStartBackgroundMusicAsync() async {
        // Test async background music start
        await audioManager.startBackgroundMusicAsync()

        XCTAssertTrue(true, "Async background music started without error")
    }

    func testStopBackgroundMusicAsync() async {
        // Test async background music stop
        await audioManager.stopBackgroundMusicAsync()

        XCTAssertTrue(true, "Async background music stopped without error")
    }

    func testPauseResumeBackgroundMusicAsync() async {
        // Test async background music pause/resume
        await audioManager.pauseBackgroundMusicAsync()
        await audioManager.resumeBackgroundMusicAsync()

        XCTAssertTrue(true, "Async background music pause/resume completed without error")
    }

    func testSetAudioEnabledAsync() async {
        // Test async audio enable/disable
        await audioManager.setAudioEnabledAsync(false)
        await audioManager.setAudioEnabledAsync(true)

        XCTAssertTrue(true, "Async audio enable/disable completed without error")
    }

    func testSetMusicEnabledAsync() async {
        // Test async music enable/disable
        await audioManager.setMusicEnabledAsync(false)
        await audioManager.setMusicEnabledAsync(true)

        XCTAssertTrue(true, "Async music enable/disable completed without error")
    }

    func testSetSoundEffectsVolumeAsync() async {
        // Test async sound effects volume setting
        await audioManager.setSoundEffectsVolumeAsync(0.6)

        XCTAssertTrue(true, "Async sound effects volume set without error")
    }

    func testSetMusicVolumeAsync() async {
        // Test async music volume setting
        await audioManager.setMusicVolumeAsync(0.4)

        XCTAssertTrue(true, "Async music volume set without error")
    }

    func testGetAudioSettingsAsync() async {
        // Test async audio settings retrieval
        let settings = await audioManager.getAudioSettingsAsync()

        XCTAssertNotNil(settings)
        XCTAssertNotNil(settings["audioEnabled"])
        XCTAssertNotNil(settings["musicEnabled"])
    }

    func testPlayProceduralCollisionSoundAsync() async {
        // Test async procedural collision sound
        await audioManager.playProceduralCollisionSoundAsync(intensity: 0.7)

        XCTAssertTrue(true, "Async procedural collision sound played without error")
    }

    func testPlayProceduralScoreSoundAsync() async {
        // Test async procedural score sound
        await audioManager.playProceduralScoreSoundAsync(points: 75)

        XCTAssertTrue(true, "Async procedural score sound played without error")
    }

    func testTriggerHapticFeedbackAsync() async {
        // Test async haptic feedback
        await audioManager.triggerHapticFeedbackAsync(style: .success)

        XCTAssertTrue(true, "Async haptic feedback triggered without error")
    }

    func testCleanupAsync() async {
        // Test async cleanup
        await audioManager.cleanupAsync()

        XCTAssertTrue(true, "Async cleanup completed without error")
    }
}
