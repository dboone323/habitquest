describe('HabitQuest Web App - Cross-Platform Testing', () => {
  beforeEach(() => {
    cy.loadWebApp('HabitQuest')
  })

  it('should load the HabitQuest web application successfully', () => {
    cy.testSwiftWasmIntegration()
    cy.testBasicInteractions()
    cy.testPerformanceMetrics()
  })

  it('should display the habit tracking interface', () => {
    cy.get('[data-testid="habit-dashboard"]').should('be.visible')
    cy.get('[data-testid="habit-list"]').should('be.visible')
    cy.get('[data-testid="progress-overview"]').should('be.visible')
    cy.get('[data-testid="add-habit-button"]').should('be.visible')
  })

  it('should create new habits', () => {
    cy.measurePerformance('Habit Creation')

    // Click add habit button
    cy.get('[data-testid="add-habit-button"]').click()

    // Fill habit form
    cy.get('[data-testid="habit-name"]').type('Daily Exercise')
    cy.get('[data-testid="habit-description"]').type('30 minutes of exercise')
    cy.get('[data-testid="habit-frequency"]').select('Daily')
    cy.get('[data-testid="habit-target"]').type('30')

    // Save habit
    cy.get('[data-testid="save-habit"]').click()

    // Verify habit appears in list
    cy.get('[data-testid="habit-list"]').should('contain.text', 'Daily Exercise')
  })

  it('should track habit completion', () => {
    // Create a test habit
    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Test Habit')
    cy.get('[data-testid="save-habit"]').click()

    // Mark habit as complete
    cy.get('[data-testid="habit-item"]').contains('Test Habit')
      .find('[data-testid="complete-habit"]').click()

    // Verify completion is recorded
    cy.get('[data-testid="habit-item"]').contains('Test Habit')
      .should('have.class', 'completed')

    // Check streak counter
    cy.get('[data-testid="streak-counter"]').should('contain.text', '1')
  })

  it('should display progress statistics', () => {
    // Create and complete multiple habits
    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Habit 1')
    cy.get('[data-testid="save-habit"]').click()

    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Habit 2')
    cy.get('[data-testid="save-habit"]').click()

    // Complete both habits
    cy.get('[data-testid="habit-item"]').each(($habit) => {
      cy.wrap($habit).find('[data-testid="complete-habit"]').click()
    })

    // Check progress overview
    cy.get('[data-testid="progress-overview"]').should('be.visible')
    cy.get('[data-testid="completion-rate"]').should('contain.text', '100%')
    cy.get('[data-testid="total-completed"]').should('contain.text', '2')
  })

  it('should handle habit streaks and achievements', () => {
    // Create habit and complete multiple days
    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Streak Habit')
    cy.get('[data-testid="save-habit"]').click()

    // Complete habit multiple times (simulate multiple days)
    for (let i = 0; i < 5; i++) {
      cy.get('[data-testid="habit-item"]').contains('Streak Habit')
        .find('[data-testid="complete-habit"]').click()

      // Simulate next day
      cy.get('[data-testid="next-day"]').click()
    }

    // Check streak achievement
    cy.get('[data-testid="streak-counter"]').should('contain.text', '5')
    cy.get('[data-testid="achievement-notification"]').should('be.visible')
    cy.get('[data-testid="achievement-notification"]').should('contain.text', '5-day streak')
  })

  it('should support different habit categories', () => {
    // Test habit categorization
    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Health Habit')
    cy.get('[data-testid="habit-category"]').select('Health')
    cy.get('[data-testid="save-habit"]').click()

    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Learning Habit')
    cy.get('[data-testid="habit-category"]').select('Learning')
    cy.get('[data-testid="save-habit"]').click()

    // Filter by category
    cy.get('[data-testid="category-filter"]').select('Health')
    cy.get('[data-testid="habit-list"]').should('contain.text', 'Health Habit')
    cy.get('[data-testid="habit-list"]').should('not.contain.text', 'Learning Habit')
  })

  it('should provide habit reminders', () => {
    // Create habit with reminder
    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Reminder Habit')
    cy.get('[data-testid="habit-reminder"]').check()
    cy.get('[data-testid="reminder-time"]').type('09:00')
    cy.get('[data-testid="save-habit"]').click()

    // Check reminder functionality
    cy.get('[data-testid="reminder-list"]').should('contain.text', 'Reminder Habit')
    cy.get('[data-testid="reminder-time-display"]').should('contain.text', '9:00')
  })

  it('should maintain responsive design', () => {
    cy.testResponsiveDesign()
  })

  it('should handle errors gracefully', () => {
    cy.testErrorHandling()
  })

  it('should export habit data', () => {
    // Create some habit data
    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Export Test Habit')
    cy.get('[data-testid="save-habit"]').click()

    // Complete the habit
    cy.get('[data-testid="habit-item"]').contains('Export Test Habit')
      .find('[data-testid="complete-habit"]').click()

    // Export data
    cy.get('[data-testid="export-habits"]').click()

    // Verify export functionality
    cy.window().then((win) => {
      expect(win).to.have.property('URL')
    })
  })

  it('should persist habit progress', () => {
    // Create and complete habit
    cy.get('[data-testid="add-habit-button"]').click()
    cy.get('[data-testid="habit-name"]').type('Persistent Habit')
    cy.get('[data-testid="save-habit"]').click()

    cy.get('[data-testid="habit-item"]').contains('Persistent Habit')
      .find('[data-testid="complete-habit"]').click()

    // Refresh page
    cy.reload()
    cy.waitForWasmLoad()

    // Check habit and completion persist
    cy.get('[data-testid="habit-list"]').should('contain.text', 'Persistent Habit')
    cy.get('[data-testid="habit-item"]').contains('Persistent Habit')
      .should('have.class', 'completed')
  })
})