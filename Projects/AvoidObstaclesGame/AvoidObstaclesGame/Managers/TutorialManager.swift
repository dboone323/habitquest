//
// TutorialManager.swift
// AvoidObstaclesGame
//
// Comprehensive tutorial system with progressive difficulty and interactive guidance.
// Provides step-by-step learning experience for new players with animated overlays.
//

import Foundation
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Protocol for tutorial manager events
@MainActor
protocol TutorialManagerDelegate: AnyObject {
    func tutorialDidComplete()
    func tutorialStepCompleted(_ step: TutorialStep)
    func tutorialSkipped()
}

/// Represents a single tutorial step
@MainActor
struct TutorialStep {
    /// Unique identifier for the step
    let id: String

    /// Display title for the step
    let title: String

    /// Detailed instruction text
    let instruction: String

    /// Position to highlight (optional)
    let highlightPosition: CGPoint?

    /// Size of highlight area (optional)
    let highlightSize: CGSize?

    /// Animation to show for this step
    let animationType: TutorialAnimation

    /// Whether this step requires user interaction to proceed
    let requiresInteraction: Bool

    /// Action to perform when step is shown
    let onShow: (() -> Void)?

    /// Condition to check if step is completed
    let completionCondition: (() -> Bool)?

    /// Delay before showing next step (in seconds)
    let autoAdvanceDelay: TimeInterval?

    /// Difficulty level for progressive learning
    let difficulty: TutorialDifficulty

    init(id: String,
         title: String,
         instruction: String,
         highlightPosition: CGPoint? = nil,
         highlightSize: CGSize? = nil,
         animationType: TutorialAnimation = .fadeIn,
         requiresInteraction: Bool = true,
         onShow: (() -> Void)? = nil,
         completionCondition: (() -> Bool)? = nil,
         autoAdvanceDelay: TimeInterval? = nil,
         difficulty: TutorialDifficulty = .beginner)
    {

        self.id = id
        self.title = title
        self.instruction = instruction
        self.highlightPosition = highlightPosition
        self.highlightSize = highlightSize
        self.animationType = animationType
        self.requiresInteraction = requiresInteraction
        self.onShow = onShow
        self.completionCondition = completionCondition
        self.autoAdvanceDelay = autoAdvanceDelay
        self.difficulty = difficulty
    }
}

/// Animation types for tutorial steps
enum TutorialAnimation {
    case fadeIn
    case slideIn(from: SlideDirection)
    case bounce
    case pulse
    case scale
    case typewriter
}

/// Slide direction for slide animations
enum SlideDirection {
    case left, right, top, bottom
}

/// Difficulty levels for progressive learning
enum TutorialDifficulty: Int, Comparable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3

    static func < (lhs: TutorialDifficulty, rhs: TutorialDifficulty) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Tutorial state
enum TutorialState {
    case notStarted
    case inProgress
    case paused
    case completed
    case skipped
}

/// Comprehensive tutorial manager with progressive difficulty
@MainActor
class TutorialManager {
    // MARK: - Properties

    /// Delegate for tutorial events
    weak var delegate: TutorialManagerDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Current tutorial state
    private(set) var state: TutorialState = .notStarted

    /// Current tutorial steps
    private var tutorialSteps: [TutorialStep] = []

    /// Current step index
    private var currentStepIndex: Int = 0

    /// Tutorial overlay node
    private var tutorialOverlay: SKNode?

    /// Instruction label
    private var instructionLabel: SKLabelNode?

    /// Title label
    private var titleLabel: SKLabelNode?

    /// Highlight node for focusing attention
    private var highlightNode: SKShapeNode?

    /// Next button
    private var nextButton: SKLabelNode?

    /// Skip button
    private var skipButton: SKLabelNode?

    /// Progress indicator
    private var progressLabel: SKLabelNode?

    /// Animation actions for reuse
    private let fadeInAction: SKAction
    private let fadeOutAction: SKAction
    private let pulseAction: SKAction

    /// Timer for auto-advancing steps
    private var autoAdvanceTimer: Timer?

    /// Timer for checking step completion
    private var completionCheckTimer: Timer?

    /// Tutorial completion tracking
    private var completedSteps: Set<String> = []

    /// User preferences for tutorial behavior
    private var showTutorials: Bool = true
    private var tutorialSpeed: TutorialSpeed = .normal

    // MARK: - Initialization

    /// Initializes the tutorial manager
    /// - Parameter scene: The game scene to show tutorials in
    init(scene: SKScene) {
        // Pre-create reusable actions
        self.fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        self.fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
        self.pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5),
        ])

        self.scene = scene
        self.loadTutorialPreferences()
        self.setupTutorialSteps()
    }

    /// Updates the scene reference
    func updateScene(_ scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Tutorial Setup

    /// Sets up the tutorial steps with progressive difficulty
    private func setupTutorialSteps() {
        guard let scene else { return }

        // Beginner level steps
        let step1 = TutorialStep(
            id: "welcome",
            title: "Welcome to Avoid Obstacles!",
            instruction: "Tap anywhere to move your character and avoid the obstacles. Let's start with the basics!",
            animationType: .fadeIn,
            requiresInteraction: true,
            difficulty: .beginner
        )

        let step2 = TutorialStep(
            id: "first_move",
            title: "Make Your First Move",
            instruction: "Tap on the screen to move your character. Try to avoid the red obstacles!",
            highlightPosition: CGPoint(x: scene.size.width / 2, y: scene.size.height / 2),
            highlightSize: CGSize(width: 100, height: 100),
            animationType: .pulse,
            requiresInteraction: false,
            completionCondition: { [weak self] in
                // Complete when player moves for the first time
                return self?.hasPlayerMoved ?? false
            },
            difficulty: .beginner
        )

        let step3 = TutorialStep(
            id: "avoid_obstacles",
            title: "Avoid the Obstacles",
            instruction: "Great! Now keep moving to avoid the red obstacles. Don't let them touch you!",
            animationType: .bounce,
            requiresInteraction: true,
            autoAdvanceDelay: 3.0,
            difficulty: .beginner
        )

        let step4 = TutorialStep(
            id: "collect_powerups",
            title: "Collect Power-ups",
            instruction: "Look for green power-ups that appear occasionally. They give you special abilities!",
            animationType: .slideIn(from: .right),
            requiresInteraction: true,
            autoAdvanceDelay: 4.0,
            difficulty: .beginner
        )

        // Intermediate level steps
        let step5 = TutorialStep(
            id: "increasing_difficulty",
            title: "Getting Harder",
            instruction: "As you progress, obstacles will move faster and appear more frequently. Stay focused!",
            animationType: .scale,
            requiresInteraction: true,
            autoAdvanceDelay: 3.0,
            difficulty: .intermediate
        )

        let step6 = TutorialStep(
            id: "score_system",
            title: "Scoring Points",
            instruction: "You earn points for each obstacle you avoid. Try to beat your high score!",
            highlightPosition: CGPoint(x: 100, y: scene.size.height - 30),
            animationType: .slideIn(from: .top),
            requiresInteraction: true,
            autoAdvanceDelay: 4.0,
            difficulty: .intermediate
        )

        let step7 = TutorialStep(
            id: "special_obstacles",
            title: "Special Obstacles",
            instruction: "Watch out for special obstacles like moving barriers and pattern-based threats!",
            animationType: .bounce,
            requiresInteraction: true,
            autoAdvanceDelay: 3.0,
            difficulty: .intermediate
        )

        // Advanced level steps
        let step8 = TutorialStep(
            id: "advanced_techniques",
            title: "Advanced Techniques",
            instruction: "Master precise timing and prediction. Use power-ups strategically for maximum effect.",
            animationType: .pulse,
            requiresInteraction: true,
            autoAdvanceDelay: 4.0,
            difficulty: .advanced
        )

        let step9 = TutorialStep(
            id: "survival_mode",
            title: "Survival Mode",
            instruction: "In later levels, focus on survival patterns. Every move counts!",
            animationType: .slideIn(from: .bottom),
            requiresInteraction: true,
            autoAdvanceDelay: 3.0,
            difficulty: .advanced
        )

        let step10 = TutorialStep(
            id: "tutorial_complete",
            title: "Tutorial Complete!",
            instruction: "You've learned the basics! Continue playing to improve your skills. Good luck!",
            animationType: .scale,
            requiresInteraction: true,
            onShow: { [weak self] in
                self?.markTutorialCompleted()
            },
            difficulty: .advanced
        )

        self.tutorialSteps = [step1, step2, step3, step4, step5, step6, step7, step8, step9, step10]
    }

    // MARK: - Tutorial Control

    /// Starts the tutorial
    func startTutorial() {
        guard showTutorials, state == .notStarted else { return }

        self.state = .inProgress
        self.currentStepIndex = 0
        self.showTutorialStep(at: 0)
    }

    /// Pauses the current tutorial
    func pauseTutorial() {
        self.state = .paused
        self.hideTutorialOverlay()
        self.cancelAutoAdvanceTimer()
    }

    /// Resumes the paused tutorial
    func resumeTutorial() {
        guard state == .paused else { return }
        self.state = .inProgress
        self.showTutorialStep(at: currentStepIndex)
    }

    /// Skips the current tutorial
    func skipTutorial() {
        self.state = .skipped
        self.hideTutorialOverlay()
        self.cancelAutoAdvanceTimer()
        self.saveTutorialProgress()
        self.delegate?.tutorialSkipped()
    }

    /// Advances to the next tutorial step
    func nextStep() {
        guard state == .inProgress else { return }

        self.completedSteps.insert(self.tutorialSteps[self.currentStepIndex].id)
        self.delegate?.tutorialStepCompleted(self.tutorialSteps[self.currentStepIndex])

        self.currentStepIndex += 1

        if self.currentStepIndex < self.tutorialSteps.count {
            self.showTutorialStep(at: self.currentStepIndex)
        } else {
            self.completeTutorial()
        }
    }

    /// Goes back to the previous step
    func previousStep() {
        guard state == .inProgress, currentStepIndex > 0 else { return }

        self.currentStepIndex -= 1
        self.showTutorialStep(at: currentStepIndex)
    }

    /// Completes the tutorial
    private func completeTutorial() {
        self.state = .completed
        self.hideTutorialOverlay()
        self.saveTutorialProgress()
        self.delegate?.tutorialDidComplete()
    }

    // MARK: - Tutorial Display

    /// Shows a tutorial step at the specified index
    private func showTutorialStep(at index: Int) {
        guard index < tutorialSteps.count, let _ = scene else { return }

        let step = tutorialSteps[index]

        // Execute onShow action if present
        step.onShow?()

        // Create tutorial overlay
        self.createTutorialOverlay()

        // Show highlight if specified
        if let position = step.highlightPosition, let size = step.highlightSize {
            self.showHighlight(at: position, size: size)
        }

        // Show instruction text
        self.showInstruction(for: step)

        // Show progress indicator
        self.showProgressIndicator(current: index + 1, total: tutorialSteps.count)

        // Show navigation buttons
        self.showNavigationButtons(for: step)

        // Animate the overlay appearance
        self.animateOverlayAppearance(for: step.animationType)

        // Set up auto-advance if specified
        if let delay = step.autoAdvanceDelay {
            self.scheduleAutoAdvance(delay: delay)
        }

        // Check completion condition periodically if needed
        if step.completionCondition != nil {
            self.startCompletionChecking(for: step)
        }
    }

    /// Creates the tutorial overlay
    private func createTutorialOverlay() {
        guard let scene else { return }

        // Remove existing overlay
        self.tutorialOverlay?.removeFromParent()

        // Create semi-transparent overlay
        self.tutorialOverlay = SKNode()
        self.tutorialOverlay?.zPosition = 1000

        // Background overlay
        let background = SKShapeNode(rectOf: scene.size)
        background.fillColor = .black.withAlphaComponent(0.7)
        background.strokeColor = .clear
        background.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        background.zPosition = -1

        self.tutorialOverlay?.addChild(background)
        scene.addChild(self.tutorialOverlay!)
    }

    /// Shows a highlight at the specified position
    private func showHighlight(at position: CGPoint, size: CGSize) {
        // Remove existing highlight
        self.highlightNode?.removeFromParent()

        // Create highlight circle
        self.highlightNode = SKShapeNode(circleOfRadius: max(size.width, size.height) / 2)
        self.highlightNode?.fillColor = .clear
        self.highlightNode?.strokeColor = .yellow
        self.highlightNode?.lineWidth = 3
        self.highlightNode?.position = position
        self.highlightNode?.zPosition = 1

        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8),
        ])
        self.highlightNode?.run(SKAction.repeatForever(pulse))

        self.tutorialOverlay?.addChild(self.highlightNode!)
    }

    /// Shows the instruction text for a tutorial step
    private func showInstruction(for step: TutorialStep) {
        guard let scene else { return }

        // Remove existing labels
        self.titleLabel?.removeFromParent()
        self.instructionLabel?.removeFromParent()

        // Create title label
        self.titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.titleLabel?.text = step.title
        self.titleLabel?.fontSize = 24
        self.titleLabel?.fontColor = .white
        self.titleLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.75)
        self.titleLabel?.zPosition = 2

        // Create instruction label
        self.instructionLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.instructionLabel?.text = step.instruction
        self.instructionLabel?.fontSize = 18
        self.instructionLabel?.fontColor = .lightGray
        self.instructionLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.65)
        self.instructionLabel?.zPosition = 2
        self.instructionLabel?.horizontalAlignmentMode = .center
        self.instructionLabel?.verticalAlignmentMode = .center
        self.instructionLabel?.lineBreakMode = .byWordWrapping
        self.instructionLabel?.preferredMaxLayoutWidth = scene.size.width * 0.8

        // Add labels to overlay
        if let titleLabel { self.tutorialOverlay?.addChild(titleLabel) }
        if let instructionLabel { self.tutorialOverlay?.addChild(instructionLabel) }
    }

    /// Shows the progress indicator
    private func showProgressIndicator(current: Int, total: Int) {
        guard let scene else { return }

        // Remove existing progress
        self.progressLabel?.removeFromParent()

        // Create progress label
        self.progressLabel = SKLabelNode(fontNamed: "Menlo")
        self.progressLabel?.text = "\(current)/\(total)"
        self.progressLabel?.fontSize = 16
        self.progressLabel?.fontColor = .cyan
        self.progressLabel?.position = CGPoint(x: scene.size.width - 40, y: scene.size.height - 30)
        self.progressLabel?.zPosition = 2

        self.tutorialOverlay?.addChild(self.progressLabel!)
    }

    /// Shows navigation buttons for the tutorial step
    private func showNavigationButtons(for step: TutorialStep) {
        guard let scene else { return }

        // Remove existing buttons
        self.nextButton?.removeFromParent()
        self.skipButton?.removeFromParent()

        // Create next button
        self.nextButton = SKLabelNode(fontNamed: "Chalkduster")
        self.nextButton?.text = step.requiresInteraction ? "Tap to Continue" : "Next"
        self.nextButton?.fontSize = 20
        self.nextButton?.fontColor = .green
        self.nextButton?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.25)
        self.nextButton?.zPosition = 2

        // Create skip button
        self.skipButton = SKLabelNode(fontNamed: "Chalkduster")
        self.skipButton?.text = "Skip Tutorial"
        self.skipButton?.fontSize = 16
        self.skipButton?.fontColor = .red
        self.skipButton?.position = CGPoint(x: scene.size.width - 80, y: 30)
        self.skipButton?.zPosition = 2

        // Add buttons to overlay
        if let nextButton { self.tutorialOverlay?.addChild(nextButton) }
        if let skipButton { self.tutorialOverlay?.addChild(skipButton) }
    }

    /// Animates the overlay appearance based on animation type
    private func animateOverlayAppearance(for animationType: TutorialAnimation) {
        guard let overlay = tutorialOverlay else { return }

        // Start with invisible state
        overlay.alpha = 0

        let animation: SKAction

        switch animationType {
        case .fadeIn:
            animation = self.fadeInAction
        case let .slideIn(direction):
            let slideDistance: CGFloat = 50
            var startPosition = overlay.position

            switch direction {
            case .left: startPosition.x -= slideDistance
            case .right: startPosition.x += slideDistance
            case .top: startPosition.y += slideDistance
            case .bottom: startPosition.y -= slideDistance
            }

            overlay.position = startPosition
            animation = SKAction.group([
                SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.3),
                self.fadeInAction,
            ])
        case .bounce:
            animation = SKAction.sequence([
                SKAction.scale(to: 0.8, duration: 0.1),
                SKAction.scale(to: 1.1, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.1),
                self.fadeInAction,
            ])
        case .pulse:
            animation = SKAction.sequence([
                self.fadeInAction,
                SKAction.repeatForever(self.pulseAction),
            ])
        case .scale:
            overlay.setScale(0.5)
            animation = SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.3),
                self.fadeInAction,
            ])
        case .typewriter:
            // For typewriter effect, we'd need to animate text character by character
            // For now, just use fade in
            animation = self.fadeInAction
        }

        overlay.run(animation)
    }

    /// Hides the tutorial overlay
    private func hideTutorialOverlay() {
        self.tutorialOverlay?.run(SKAction.sequence([
            self.fadeOutAction,
            SKAction.removeFromParent(),
        ]))
        self.tutorialOverlay = nil
        self.cancelAutoAdvanceTimer()
    }

    // MARK: - Auto Advance

    /// Schedules auto-advance for a step
    private func scheduleAutoAdvance(delay: TimeInterval) {
        self.cancelAutoAdvanceTimer()
        self.autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.nextStep()
            }
        }
    }

    /// Cancels the auto-advance timer
    private func cancelAutoAdvanceTimer() {
        self.autoAdvanceTimer?.invalidate()
        self.autoAdvanceTimer = nil
    }

    /// Cancels the completion check timer
    private func cancelCompletionCheckTimer() {
        self.completionCheckTimer?.invalidate()
        self.completionCheckTimer = nil
    }

    // MARK: - Completion Checking

    /// Starts checking for step completion
    private func startCompletionChecking(for step: TutorialStep) {
        // Cancel any existing completion timer
        self.cancelCompletionCheckTimer()

        // Check every 0.5 seconds if the condition is met
        self.completionCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if step.completionCondition?() == true {
                    self.cancelCompletionCheckTimer()
                    self.nextStep()
                }
            }
        }
    }

    // MARK: - Touch Handling

    /// Handles touch events for tutorial interaction
    /// - Parameter location: Touch location in scene coordinates
    /// - Returns: Whether the touch was handled by the tutorial
    @MainActor
    func handleTouch(at location: CGPoint) -> Bool {
        guard state == .inProgress, let currentStep = tutorialSteps[safe: currentStepIndex] else {
            return false
        }

        // Check if skip button was tapped
        if let skipButton, skipButton.contains(location) {
            self.skipTutorial()
            return true
        }

        // Check if next button was tapped (if step requires interaction)
        if currentStep.requiresInteraction,
           let nextButton, nextButton.contains(location)
        {
            self.nextStep()
            return true
        }

        // For steps that don't require specific interaction, any tap advances
        if !currentStep.requiresInteraction {
            self.nextStep()
            return true
        }

        return false
    }

    // MARK: - Progress Tracking

    /// Checks if the tutorial has been completed before
    func hasCompletedTutorial() -> Bool {
        UserDefaults.standard.bool(forKey: "tutorial_completed")
    }

    /// Marks the tutorial as completed
    private func markTutorialCompleted() {
        UserDefaults.standard.set(true, forKey: "tutorial_completed")
    }

    /// Saves tutorial progress
    private func saveTutorialProgress() {
        let progress = TutorialProgress(
            completedSteps: Array(completedSteps),
            lastStepIndex: currentStepIndex,
            state: state
        )

        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: "tutorial_progress")
        }
    }

    /// Loads tutorial progress
    private func loadTutorialProgress() {
        if let data = UserDefaults.standard.data(forKey: "tutorial_progress"),
           let progress = try? JSONDecoder().decode(TutorialProgress.self, from: data)
        {
            self.completedSteps = Set(progress.completedSteps)
            self.currentStepIndex = progress.lastStepIndex
            self.state = progress.state
        }
    }

    /// Loads tutorial preferences
    private func loadTutorialPreferences() {
        self.showTutorials = UserDefaults.standard.bool(forKey: "show_tutorials")
        if let speedRaw = UserDefaults.standard.string(forKey: "tutorial_speed"),
           let speed = TutorialSpeed(rawValue: speedRaw)
        {
            self.tutorialSpeed = speed
        }
    }

    // MARK: - State Queries

    /// Returns whether the tutorial is currently active
    func isTutorialActive() -> Bool {
        state == .inProgress
    }

    /// Returns the current tutorial step
    func getCurrentStep() -> TutorialStep? {
        guard currentStepIndex < tutorialSteps.count else { return nil }
        return tutorialSteps[currentStepIndex]
    }

    /// Returns the current difficulty level
    func getCurrentDifficulty() -> TutorialDifficulty {
        guard let step = getCurrentStep() else { return .beginner }
        return step.difficulty
    }

    // MARK: - External State Updates

    /// Notifies the tutorial that the player has moved (for completion conditions)
    private var hasPlayerMoved = false
    func playerDidMove() {
        self.hasPlayerMoved = true
    }

    /// Notifies the tutorial that the player collected a power-up
    func playerDidCollectPowerUp() {
        // Could trigger specific tutorial steps or hints
    }

    /// Notifies the tutorial that the player hit an obstacle
    func playerDidHitObstacle() {
        // Could show helpful hints or restart tutorial sections
    }

    // MARK: - Cleanup

    /// Cleans up the tutorial manager
    func cleanup() {
        self.cancelAutoAdvanceTimer()
        self.cancelCompletionCheckTimer()
        self.hideTutorialOverlay()
        self.state = .notStarted
    }
}

// MARK: - Supporting Types

/// Tutorial speed settings
enum TutorialSpeed: String {
    case slow
    case normal
    case fast

    var delayMultiplier: TimeInterval {
        switch self {
        case .slow: return 1.5
        case .normal: return 1.0
        case .fast: return 0.7
        }
    }
}

/// Tutorial progress for persistence
struct TutorialProgress: Codable {
    let completedSteps: [String]
    let lastStepIndex: Int
    let state: TutorialState
}

// MARK: - TutorialState Codable Extension

extension TutorialState: Codable {
    enum CodingKeys: String, CodingKey {
        case notStarted, inProgress, paused, completed, skipped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .notStarted: try container.encode("notStarted")
        case .inProgress: try container.encode("inProgress")
        case .paused: try container.encode("paused")
        case .completed: try container.encode("completed")
        case .skipped: try container.encode("skipped")
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        switch string {
        case "notStarted": self = .notStarted
        case "inProgress": self = .inProgress
        case "paused": self = .paused
        case "completed": self = .completed
        case "skipped": self = .skipped
        default: throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid tutorial state")
        }
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
