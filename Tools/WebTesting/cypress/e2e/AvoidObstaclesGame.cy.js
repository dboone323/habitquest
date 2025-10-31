describe('AvoidObstaclesGame Web App - Cross-Platform Testing', () => {
  beforeEach(() => {
    cy.loadWebApp('AvoidObstaclesGame')
  })

  it('should load the AvoidObstaclesGame web application successfully', () => {
    cy.testSwiftWasmIntegration()
    cy.testBasicInteractions()
    cy.testPerformanceMetrics()
  })

  it('should display the game interface', () => {
    cy.get('[data-testid="game-container"]').should('be.visible')
    cy.get('[data-testid="game-canvas"]').should('be.visible')
    cy.get('[data-testid="score-display"]').should('be.visible')
    cy.get('[data-testid="start-game-button"]').should('be.visible')
  })

  it('should start the game', () => {
    cy.measurePerformance('Game Start')

    // Click start game button
    cy.get('[data-testid="start-game-button"]').click()

    // Verify game starts
    cy.get('[data-testid="game-canvas"]').should('have.class', 'active')
    cy.get('[data-testid="player"]').should('be.visible')
  })

  it('should handle player controls', () => {
    // Start game
    cy.get('[data-testid="start-game-button"]').click()

    // Test keyboard controls
    cy.get('body').type('{leftarrow}')
    cy.get('body').type('{rightarrow}')
    cy.get('body').type('{space}') // Jump

    // Test touch controls (if implemented)
    cy.get('[data-testid="game-canvas"]').click(100, 200) // Touch at position

    // Verify player responds to input
    cy.get('[data-testid="player"]').should('have.attr', 'data-moved', 'true')
  })

  it('should track score correctly', () => {
    // Start game
    cy.get('[data-testid="start-game-button"]').click()

    // Wait for some gameplay
    cy.wait(2000)

    // Check score updates
    cy.get('[data-testid="score-display"]').invoke('text').then((initialScore) => {
      const initialScoreNum = parseInt(initialScore) || 0

      // Continue playing
      cy.wait(3000)

      // Check score increased
      cy.get('[data-testid="score-display"]').invoke('text').then((newScore) => {
        const newScoreNum = parseInt(newScore) || 0
        expect(newScoreNum).to.be.at.least(initialScoreNum)
      })
    })
  })

  it('should handle game physics', () => {
    // Start game
    cy.get('[data-testid="start-game-button"]').click()

    // Test collision detection
    cy.get('[data-testid="player"]').should('be.visible')
    cy.get('[data-testid="obstacle"]').should('exist')

    // Move player into obstacle path
    cy.get('body').type('{rightarrow}').type('{rightarrow}')

    // Game should either continue or end with collision
    cy.get('body').then(($body) => {
      if ($body.find('[data-testid="game-over"]').length > 0) {
        // Game ended - check game over screen
        cy.get('[data-testid="game-over"]').should('be.visible')
        cy.get('[data-testid="final-score"]').should('be.visible')
      } else {
        // Game continues - check player is still active
        cy.get('[data-testid="player"]').should('be.visible')
      }
    })
  })

  it('should handle game over and restart', () => {
    // Start game
    cy.get('[data-testid="start-game-button"]').click()

    // Force game over (by waiting or triggering collision)
    cy.wait(5000) // Let game run

    // Check for game over state
    cy.get('body').then(($body) => {
      if ($body.find('[data-testid="game-over"]').length > 0) {
        // Click restart
        cy.get('[data-testid="restart-game"]').click()

        // Verify game restarts
        cy.get('[data-testid="game-canvas"]').should('have.class', 'active')
        cy.get('[data-testid="score-display"]').should('contain.text', '0')
      }
    })
  })

  it('should support different game modes', () => {
    // Check for game mode selector
    cy.get('[data-testid="game-mode-selector"]').should('be.visible')

    // Test different modes (if available)
    cy.get('[data-testid="mode-easy"]').click()
    cy.get('[data-testid="start-game-button"]').click()
    cy.get('[data-testid="game-canvas"]').should('have.class', 'easy-mode')

    // Test another mode
    cy.get('[data-testid="restart-game"]').click()
    cy.get('[data-testid="mode-hard"]').click()
    cy.get('[data-testid="start-game-button"]').click()
    cy.get('[data-testid="game-canvas"]').should('have.class', 'hard-mode')
  })

  it('should maintain responsive design', () => {
    cy.testResponsiveDesign()
  })

  it('should handle errors gracefully', () => {
    cy.testErrorHandling()
  })

  it('should support pause/resume functionality', () => {
    // Start game
    cy.get('[data-testid="start-game-button"]').click()

    // Pause game
    cy.get('[data-testid="pause-button"]').click()
    cy.get('[data-testid="game-canvas"]').should('have.class', 'paused')

    // Resume game
    cy.get('[data-testid="resume-button"]').click()
    cy.get('[data-testid="game-canvas"]').should('have.class', 'active')
  })

  it('should display high scores', () => {
    // Play a quick game to generate score
    cy.get('[data-testid="start-game-button"]').click()
    cy.wait(3000)

    // Check high score display
    cy.get('[data-testid="high-score-display"]').should('be.visible')
    cy.get('[data-testid="high-score-list"]').should('exist')
  })
})