describe('PlannerApp Web App - Cross-Platform Testing', () => {
  beforeEach(() => {
    cy.loadWebApp('PlannerApp')
  })

  it('should load the PlannerApp web application successfully', () => {
    cy.testSwiftWasmIntegration()
    cy.testBasicInteractions()
    cy.testPerformanceMetrics()
  })

  it('should display the main planner interface', () => {
    cy.get('[data-testid="planner-container"]').should('be.visible')
    cy.get('[data-testid="task-list"]').should('be.visible')
    cy.get('[data-testid="calendar-view"]').should('be.visible')
    cy.get('[data-testid="add-task-button"]').should('be.visible')
  })

  it('should create new tasks', () => {
    cy.measurePerformance('Task Creation')

    // Click add task button
    cy.get('[data-testid="add-task-button"]').click()

    // Fill task form
    cy.get('[data-testid="task-title"]').type('Test Task')
    cy.get('[data-testid="task-description"]').type('This is a test task')
    cy.get('[data-testid="task-due-date"]').type('2025-12-31')

    // Save task
    cy.get('[data-testid="save-task"]').click()

    // Verify task appears in list
    cy.get('[data-testid="task-list"]').should('contain.text', 'Test Task')
  })

  it('should handle calendar navigation', () => {
    // Test calendar view
    cy.get('[data-testid="calendar-view"]').should('be.visible')

    // Navigate to different months
    cy.get('[data-testid="calendar-prev"]').click()
    cy.get('[data-testid="calendar-next"]').click()

    // Select a date
    cy.get('[data-testid="calendar-day"]').first().click()

    // Check that date selection works
    cy.get('[data-testid="selected-date"]').should('be.visible')
  })

  it('should manage task states', () => {
    // Create a test task first
    cy.get('[data-testid="add-task-button"]').click()
    cy.get('[data-testid="task-title"]').type('State Test Task')
    cy.get('[data-testid="save-task"]').click()

    // Mark task as complete
    cy.get('[data-testid="task-item"]').contains('State Test Task')
      .find('[data-testid="task-complete"]').click()

    // Verify task shows as completed
    cy.get('[data-testid="task-item"]').contains('State Test Task')
      .should('have.class', 'completed')

    // Delete task
    cy.get('[data-testid="task-item"]').contains('State Test Task')
      .find('[data-testid="task-delete"]').click()

    // Verify task is removed
    cy.get('[data-testid="task-list"]').should('not.contain.text', 'State Test Task')
  })

  it('should handle CloudKit sync status', () => {
    // Check sync status indicator
    cy.get('[data-testid="sync-status"]').should('be.visible')

    // Test sync operation (if manual sync is available)
    cy.get('[data-testid="sync-button"]').click()

    // Verify sync completes
    cy.get('[data-testid="sync-status"]').should('contain.text', 'Synced')
  })

  it('should navigate between different views', () => {
    // Test navigation between planner views
    cy.get('[data-testid="nav-calendar"]').click()
    cy.get('[data-testid="calendar-view"]').should('be.visible')

    cy.get('[data-testid="nav-tasks"]').click()
    cy.get('[data-testid="task-list"]').should('be.visible')

    cy.get('[data-testid="nav-projects"]').click()
    cy.get('[data-testid="project-list"]').should('be.visible')
  })

  it('should maintain responsive design', () => {
    cy.testResponsiveDesign()
  })

  it('should handle errors gracefully', () => {
    cy.testErrorHandling()
  })

  it('should support keyboard shortcuts', () => {
    // Test common keyboard shortcuts
    cy.get('body').type('{ctrl}n') // New task shortcut
    cy.get('[data-testid="task-form"]').should('be.visible')

    cy.get('body').type('{esc}') // Close form
    cy.get('[data-testid="task-form"]').should('not.be.visible')
  })

  it('should persist data across sessions', () => {
    // Create a task
    cy.get('[data-testid="add-task-button"]').click()
    cy.get('[data-testid="task-title"]').type('Persistent Task')
    cy.get('[data-testid="save-task"]').click()

    // Refresh page
    cy.reload()
    cy.waitForWasmLoad()

    // Check if task persists
    cy.get('[data-testid="task-list"]').should('contain.text', 'Persistent Task')
  })
})