import JavaScriptKit

@MainActor
struct AvoidObstaclesGameWeb {
    private let document = JSObject.global.document
    private let console = JSObject.global.console

    // Game state
    private var gameRunning = false
    private var score = 0
    private var playerX: Double = 200
    private let playerY: Double = 350
    private let playerWidth: Double = 30
    private let playerHeight: Double = 30
    private var obstacles: [(x: Double, y: Double, width: Double, height: Double)] = []
    private var gameSpeed: Double = 2.0
    private var animationFrame: JSValue?

    // Canvas and context
    private var canvas: JSObject?
    private var ctx: JSObject?

    init() {
        setupUI()
        setupCanvas()
        setupEventListeners()
        render()
    }

    private func setupUI() {
        // Create main container
        let container = document.createElement("div")
        container.id = "game-container"
        container.className = "game-app"

        // Create header
        let header = document.createElement("header")
        header.className = "game-header"
        header.innerHTML = """
            <h1>🎮 Avoid Obstacles Game Web</h1>
            <div class="game-info">
                <div class="score">Score: <span id="score-display">0</span></div>
                <div class="status">Ready to Play</div>
            </div>
        """

        // Create game area
        let gameArea = document.createElement("div")
        gameArea.className = "game-area"
        gameArea.innerHTML = """
            <canvas id="game-canvas" width="400" height="400"></canvas>
            <div class="game-controls">
                <button id="start-btn" class="btn-primary">Start Game</button>
                <button id="pause-btn" class="btn-secondary" disabled>Pause</button>
                <button id="reset-btn" class="btn-secondary">Reset</button>
            </div>
            <div class="game-instructions">
                <p>🎯 Use arrow keys or click/tap to move left and right</p>
                <p>🚧 Avoid the falling obstacles!</p>
            </div>
        """

        // Create footer
        let footer = document.createElement("footer")
        footer.className = "game-footer"
        footer.innerHTML = """
            <p>AvoidObstaclesGame Web - Powered by SwiftWasm</p>
        """

        container.appendChild(header)
        container.appendChild(gameArea)
        container.appendChild(footer)

        document.body.appendChild(container)
    }

    private func setupCanvas() {
        canvas = document.getElementById("game-canvas").object
        if let canvas {
            ctx = canvas.getContext("2d").object
        }
    }

    private func setupEventListeners() {
        // Game control buttons
        if let startBtn = document.getElementById("start-btn").object {
            _ = startBtn.addEventListener("click", JSClosure { [weak self] _ in
                self?.startGame()
                return .undefined
            })
        }

        if let pauseBtn = document.getElementById("pause-btn").object {
            _ = pauseBtn.addEventListener("click", JSClosure { [weak self] _ in
                self?.pauseGame()
                return .undefined
            })
        }

        if let resetBtn = document.getElementById("reset-btn").object {
            _ = resetBtn.addEventListener("click", JSClosure { [weak self] _ in
                self?.resetGame()
                return .undefined
            })
        }

        // Keyboard controls
        _ = document.addEventListener("keydown", JSClosure { [weak self] event in
            if let self, let key = event.key.string {
                self.handleKeyPress(key)
            }
            return .undefined
        })

        // Touch/mouse controls for canvas
        if let canvas {
            _ = canvas.addEventListener("click", JSClosure { [weak self] event in
                if let self {
                    self.handleCanvasClick(event)
                }
                return .undefined
            })
        }
    }

    private func startGame() {
        if !gameRunning {
            gameRunning = true
            updateStatus("Game Running!")
            updateButtons(start: true, pause: false, reset: false)
            gameLoop()
        }
    }

    private func pauseGame() {
        gameRunning = false
        updateStatus("Game Paused")
        updateButtons(start: false, pause: true, reset: false)
        cancelAnimationFrame()
    }

    private func resetGame() {
        gameRunning = false
        score = 0
        playerX = 200
        obstacles = []
        gameSpeed = 2.0
        updateScore()
        updateStatus("Ready to Play")
        updateButtons(start: false, pause: true, reset: true)
        cancelAnimationFrame()
        render()
    }

    private func handleKeyPress(_ key: String) {
        if gameRunning {
            switch key {
            case "ArrowLeft":
                playerX = max(0, playerX - 20)
            case "ArrowRight":
                playerX = min(370, playerX + 20) // 400 - 30 = 370
            default:
                break
            }
        }
    }

    private func handleCanvasClick(_ event: JSValue) {
        if gameRunning, let rect = canvas?.getBoundingClientRect().object {
            let clientX = event.clientX.number ?? 0
            let rectLeft = rect.left.number ?? 0
            let clickX = clientX - rectLeft

            if clickX < 200 {
                playerX = max(0, playerX - 20)
            } else {
                playerX = min(370, playerX + 20)
            }
        }
    }

    private func gameLoop() {
        if gameRunning {
            updateGame()
            render()
            animationFrame = JSObject.global.requestAnimationFrame(JSClosure { [weak self] _ in
                self?.gameLoop()
                return .undefined
            })
        }
    }

    private func updateGame() {
        // Move obstacles down
        obstacles = obstacles.map { (x: $0.x, y: $0.y + gameSpeed, width: $0.width, height: $0.height) }

        // Remove obstacles that are off screen
        obstacles = obstacles.filter { $0.y < 450 }

        // Add new obstacles randomly
        if Double.random(in: 0 ... 1) < 0.02 { // 2% chance per frame
            let obstacleWidth = Double.random(in: 20 ... 60)
            let obstacleX = Double.random(in: 0 ... (400 - obstacleWidth))
            obstacles.append((x: obstacleX, y: -20, width: obstacleWidth, height: 20))
        }

        // Check collisions
        for obstacle in obstacles {
            if checkCollision(playerX: playerX, playerY: playerY, playerWidth: playerWidth, playerHeight: playerHeight,
                              obstacleX: obstacle.x, obstacleY: obstacle.y, obstacleWidth: obstacle.width, obstacleHeight: obstacle.height)
            {
                gameOver()
                return
            }
        }

        // Increase score and speed
        score += 1
        if score % 100 == 0 {
            gameSpeed += 0.5
        }

        updateScore()
    }

    private func checkCollision(playerX: Double, playerY: Double, playerWidth: Double, playerHeight: Double,
                                obstacleX: Double, obstacleY: Double, obstacleWidth: Double, obstacleHeight: Double) -> Bool
    {
        playerX < obstacleX + obstacleWidth &&
            playerX + playerWidth > obstacleX &&
            playerY < obstacleY + obstacleHeight &&
            playerY + playerHeight > obstacleY
    }

    private func gameOver() {
        gameRunning = false
        updateStatus("Game Over! Final Score: \(score)")
        updateButtons(start: false, pause: true, reset: false)
        cancelAnimationFrame()
    }

    private func render() {
        guard let ctx else { return }

        // Clear canvas
        _ = ctx.clearRect(0, 0, 400, 400)

        // Draw background
        _ = ctx.fillStyle = JSValue.string("#f0f8ff")
        _ = ctx.fillRect(0, 0, 400, 400)

        // Draw player (blue square)
        _ = ctx.fillStyle = JSValue.string("#3498db")
        _ = ctx.fillRect(JSValue.number(playerX), JSValue.number(playerY), JSValue.number(playerWidth), JSValue.number(playerHeight))

        // Draw obstacles (red rectangles)
        _ = ctx.fillStyle = JSValue.string("#e74c3c")
        for obstacle in obstacles {
            _ = ctx.fillRect(JSValue.number(obstacle.x), JSValue.number(obstacle.y), JSValue.number(obstacle.width), JSValue.number(obstacle.height))
        }

        // Draw ground line
        _ = ctx.strokeStyle = JSValue.string("#2c3e50")
        _ = ctx.lineWidth = JSValue.number(2)
        _ = ctx.beginPath()
        _ = ctx.moveTo(0, 380)
        _ = ctx.lineTo(400, 380)
        _ = ctx.stroke()
    }

    private func updateScore() {
        if let scoreDisplay = document.getElementById("score-display").object {
            scoreDisplay.innerText = JSValue.string(String(score))
        }
    }

    private func updateStatus(_ status: String) {
        if let statusDiv = document.querySelector(".status").object {
            statusDiv.innerText = JSValue.string(status)
        }
    }

    private func updateButtons(start: Bool, pause: Bool, reset: Bool) {
        if let startBtn = document.getElementById("start-btn").object {
            _ = startBtn.disabled = JSValue.boolean(start)
        }
        if let pauseBtn = document.getElementById("pause-btn").object {
            _ = pauseBtn.disabled = JSValue.boolean(pause)
        }
        if let resetBtn = document.getElementById("reset-btn").object {
            _ = resetBtn.disabled = JSValue.boolean(reset)
        }
    }

    private func cancelAnimationFrame() {
        if let animationFrame {
            _ = JSObject.global.cancelAnimationFrame(animationFrame)
            self.animationFrame = nil
        }
    }
}

// Initialize the game when DOM is loaded
_ = JSObject.global.addEventListener("DOMContentLoaded", JSClosure { _ in
    let _ = AvoidObstaclesGameWeb()
    return .undefined
})
