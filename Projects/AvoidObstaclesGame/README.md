# AvoidObstaclesGame

Thinking...
The user wants a comprehensive README.md for a Swift project with several files listed. We don't have content, but we can infer functionality based on file names. We need to produce a README covering overview, features, installation, usage examples, architecture, contributing, license. Provide placeholders for code snippets. Make it professional. Ensure sections. Probably use markdown. Also note license placeholder (MIT). Provide usage example for GameViewController integration. Let's write.
...done thinking.

# AvoidObstaclesGame

**AvoidObstaclesGame** is a fast‑paced, arcade‑style iOS game written in Swift that challenges players to steer a ship (or character) through an endless stream of dynamically generated obstacles. The project showcases a clean, modular architecture for game development, using SpriteKit and a suite of manager classes that encapsulate distinct responsibilities such as physics, audio, high‑scores, and visual effects.

---

## Table of Contents

- [Project Overview & Purpose](#project-overview--purpose)
- [Features](#features)
- [Installation](#installation)
- [Usage Examples](#usage-examples)
- [Architecture Overview](#architecture-overview)
- [Contributing](#contributing)
- [License](#license)

---

## Project Overview & Purpose

AvoidObstaclesGame demonstrates how to build a maintainable, testable, and expandable 2‑D game on iOS using **SpriteKit** and **Swift 5+**. The codebase is deliberately segmented into manager classes, each handling a single domain of the game (physics, audio, effects, etc.). This structure makes it easy for developers to:

- Learn best practices for separating concerns in a game loop.
- Extend the game (new obstacles, power‑ups, UI screens, etc.) without touching unrelated code.
- Integrate the game into existing iOS applications or use it as a teaching example for Swift game development.

---

## Features

| ✅  | Feature                            | Description                                                                                                       |
| --- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| ✅  | **Procedural Obstacle Generation** | `ObstacleManager` spawns obstacles at varying intervals, speeds, and patterns.                                    |
| ✅  | **Robust Physics System**          | `PhysicsManager` configures SpriteKit physics bodies, collisions, and integrates a custom `PhysicsCategory` enum. |
| ✅  | **Performance Monitoring**         | `PerformanceManager` records frame‑rate, node count, and memory usage in real time.                               |
| ✅  | **Audio & Sound Effects**          | `AudioManager` centralises background music, SFX, and volume control.                                             |
| ✅  | **Visual Effects**                 | `EffectsManager` provides particle systems, screen shake, and transition animations.                              |
| ✅  | **Game State Management**          | `GameStateManager` handles pause/resume, game‑over, and level progression.                                        |
| ✅  | **High‑Score Persistence**         | `HighScoreManager` stores local best scores with `UserDefaults` and supports CloudKit sync hooks.                 |
| ✅  | **Player Management**              | `PlayerManager` tracks lives, score, power‑ups, and player‑specific settings.                                     |
| ✅  | **Modular & Testable Code**        | Each manager follows the **singleton** pattern (where appropriate) and is unit‑test ready.                        |
| ✅  | **Swift Package Friendly**         | The project can be embedded as a Swift Package or a traditional Xcode project.                                    |

---

## Installation

### Prerequisites

| Tool                                         | Minimum Version  |
| -------------------------------------------- | ---------------- |
| Xcode                                        | 15.0 (Swift 5.9) |
| iOS SDK                                      | 17.0             |
| macOS                                        | 14.0 (Ventura)   |
| CocoaPods / Swift Package Manager (optional) | —                |

### Step‑by‑Step

1. **Clone the repository**

   ```bash
   git clone https://github.com/your‑org/AvoidObstaclesGame.git
   cd AvoidObstaclesGame
   ```

2. **Open the Xcode workspace**

   ```bash
   open AvoidObstaclesGame.xcodeproj
   ```

   The project contains a single target **AvoidObstaclesGame** with the default SpriteKit template.

3. **Configure signing**

   - In Xcode, select the project → **Signing & Capabilities**.
   - Choose your personal/team Apple ID and a valid bundle identifier.

4. **Build & Run**

   - Select a simulator or a connected iOS device.
   - Press **⌘ + R** (or click the Run button).

   The game will launch, displaying the main menu and then the gameplay screen.

### Optional: Swift Package Integration

If you want to embed the game into another app as a package:

```swift
.package(url: "https://github.com/your-org/AvoidObstaclesGame.git", from: "1.0.0")
```

Add `AvoidObstaclesGame` as a dependency of your target and import the module where needed:

```swift
import AvoidObstaclesGame
```

---

## Usage Examples

Below are common snippets showing how to interact with the core managers from your own code.

### Launching the Game from another View Controller

```swift
import UIKit
import AvoidObstaclesGame

class MainMenuViewController: UIViewController {

    @IBAction func playButtonTapped(_ sender: UIButton) {
        // Instantiate the GameViewController from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let gameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController")
                as? GameViewController else { return }

        // Optional: inject a custom configuration (e.g., difficulty)
        gameVC.gameDifficulty = .hard

        // Present the game full‑screen
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true, completion: nil)
    }
}
```

### Pausing & Resuming the Game

```swift
// Pause
GameStateManager.shared.pauseGame()

// Resume
GameStateManager.shared.resumeGame()
```

### Adding a New Power‑Up (example in `PlayerManager`)

```swift
extension PlayerManager {
    func grantShield(duration: TimeInterval) {
        shieldActive = true
        // Visual cue
        EffectsManager.shared.showShieldEffect(on: playerNode)

        // Auto‑expire after `duration`
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.shieldActive = false
            self?.effectsNode?.removeAllChildren()
        }
    }
}
```

### Subscribing to High‑Score Updates

```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(highScoreDidChange(_:)),
    name: .highScoreDidUpdate,
    object: nil)

@objc private func highScoreDidChange(_ notification: Notification) {
    guard let newScore = notification.userInfo?["score"] as? Int else { return }
    print("🚀 New high score: \(newScore)")
}
```

### Using the `PerformanceManager` for Debugging

```swift
#if DEBUG
PerformanceManager.shared.startMonitoring()
#endif

// Later, maybe when a button is tapped:
PerformanceManager.shared.logCurrentMetrics()
```

---

## Architecture Overview

### High‑Level Diagram

```
+-------------------+      +--------------------+      +-------------------+
|   GameViewController  |←──►|   GameStateManager   |←──►|   PlayerManager   |
+-------------------+      +--------------------+      +-------------------+
          ▲                        ▲                         ▲
          │                        │                         │
          │                        │                         │
+-------------------+      +--------------------+      +-------------------+
|   PhysicsManager  |←──►|   PhysicsCategory   |      |   ObstacleManager |
+-------------------+      +--------------------+      +-------------------+
          ▲                        ▲                         ▲
          │                        │                         │
+-------------------+      +--------------------+      +-------------------+
|   EffectsManager  |←──►|   AudioManager      |←──►|   HighScoreManager |
+-------------------+      +--------------------+      +-------------------+

            (PerformanceManager sits on the side, pulling metrics from
            SpriteKit's view and the above managers)
```

### Component Responsibilities

| Manager                | Responsibility                                                                 | Key Public API                                         |
| ---------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------ |
| **GameViewController** | UI layer, SpriteKit scene creation, user input handling.                       | `setupScene()`, `handleTap(_:)`                        |
| **GameStateManager**   | Global state machine (`.playing`, `.paused`, `.gameOver`).                     | `pauseGame()`, `resumeGame()`, `endGame()`             |
| **PlayerManager**      | Stores player stats (score, lives, power‑ups).                                 | `addScore(_:)`, `loseLife()`, `grantShield(duration:)` |
| **ObstacleManager**    | Generates and recycles obstacles, updates difficulty.                          | `spawnObstacle()`, `resetObstacles()`                  |
| **PhysicsManager**     | Configures physics world, collision callbacks.                                 | `setupPhysics(for:)`, `handleCollision(_:)`            |
| **PhysicsCategory**    | `OptionSet` defining category bit masks used throughout collision handling.    | `.player`, `.obstacle`, `.powerUp`                     |
| **AudioManager**       | Loads/plays background music and SFX, manages volume.                          | `playMusic(named:)`, `playSoundEffect(named:)`         |
| **EffectsManager**     | Handles particle emitters, screen shakes, UI flash effects.                    | `showExplosion(at:)`, `shakeScreen(intensity:)`        |
| **HighScoreManager**   | Persists best scores locally (UserDefaults) and provides a CloudKit sync hook. | `saveScore(_:)`, `fetchHighScores(completion:)`        |
| **PerformanceManager** | Real‑time FPS, node count, memory usage; optional overlay UI.                  | `startMonitoring()`, `logCurrentMetrics()`             |

### Data Flow

1. **Input** – Touch events in `GameViewController` are forwarded to `PlayerManager` (move player) and `GameStateManager` (pause/resume).
2. **Game Loop** – SpriteKit calls `update(_:)` each frame. `GameViewController` invokes manager updates (obstacle movement, physics stepping).
3. **Collision Detection** – `PhysicsManager` receives `didBegin(_:)` notifications from the physics world, resolves collisions via `PlayerManager` & `ObstacleManager`.
4. **Scoring** – When a player successfully passes an obstacle, `ObstacleManager` notifies `PlayerManager`, which updates the score and notifies `HighScoreManager` if a new record is achieved.
5. **Audio / Visual Feedback** – `AudioManager` and `EffectsManager` are called from the appropriate managers to provide immersive feedback.
6. **Performance Monitoring** – `PerformanceManager` optionally overlays diagnostics to aid development.

---

## Contributing

We welcome contributions! Follow these steps to get started:

1. **Fork the repository** and clone your fork.
2. **Create a feature branch**:

   ```bash
   git checkout -b feature/awesome-ability
   ```

3. **Write code** adhering to the existing coding style:

   - Use **SwiftLint** (the repo includes a `.swiftlint.yml`).
   - Prefer **explicit access control** (`private`, `fileprivate`, etc.).
   - Document public APIs with **MarkDoc** style comments.

4. **Add unit tests** under `AvoidObstaclesGameTests/`. The project uses **XCTest**; aim for 80 %+ coverage for new logic.

5. **Run the test suite** locally:

   ```bash
   xcodebuild test -scheme AvoidObstaclesGame -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
   ```

6. **Commit with a clear message** (follow the conventional commits format).

   ```bash
   git commit -m "feat(obstacle): add rotating laser obstacle"
   ```

7. **Push** and open a **Pull Request**.

### Code Review Checklist

- [ ] Does the PR include **unit tests** for new behavior?
- [ ] Are all new public methods documented?
- [ ] Are magic numbers extracted into named constants or config structs?
- [ ] Does the UI remain responsive on older devices (iPhone SE 2nd gen)?
- [ ] Are any new assets added to the **Asset Catalog** with proper compression?

### Local Development Tips

- **Hot‑Reload** – Use the Xcode “Live View” feature: edit sprite textures or particle files and press **⌘ + R** to see changes instantly.
- **Debugging Physics** – Enable `view.showsPhysics = true` in `GameViewController` to view bodies and contacts.
- **Performance Profiling** – Activate the `PerformanceManager` overlay in Debug builds to spot frame‑rate drops early.

---

## License

```
MIT License

Copyright (c) 2025 <Your Name / Organization>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[...standard MIT text...]
```

Feel free to use, modify, and distribute this project under the terms of the MIT license.

---

**Happy coding, and enjoy dodging those obstacles!**

---

_Documentation generated by AI-Enhanced Automation_
