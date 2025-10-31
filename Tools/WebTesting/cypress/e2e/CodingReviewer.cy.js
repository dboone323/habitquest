describe('CodingReviewer Web App - Cross-Platform Testing', () => {
  beforeEach(() => {
    cy.loadWebApp('CodingReviewer')
  })

  it('should load the CodingReviewer web application successfully', () => {
    cy.testSwiftWasmIntegration()
    cy.testBasicInteractions()
    cy.testPerformanceMetrics()
  })

  it('should display the main interface elements', () => {
    // Check for main UI components
    cy.get('[data-testid="main-container"]').should('be.visible')
    cy.get('[data-testid="file-selector"]').should('be.visible')
    cy.get('[data-testid="analysis-panel"]').should('be.visible')
    cy.get('[data-testid="results-display"]').should('be.visible')
  })

  it('should handle file selection interaction', () => {
    cy.measurePerformance('File Selection')

    // Click file selector button
    cy.get('[data-testid="file-selector"]').click()

    // Check that file dialog opens or mock file is loaded
    cy.get('body').should('not.have.class', 'loading')

    // Verify analysis can start
    cy.get('[data-testid="start-analysis"]').should('be.visible').and('not.be.disabled')
  })

  it('should perform code analysis', () => {
    cy.measurePerformance('Code Analysis')

    // Start analysis with mock data
    cy.get('[data-testid="start-analysis"]').click()

    // Wait for analysis to complete
    cy.get('[data-testid="analysis-progress"]', { timeout: 30000 }).should('not.exist')

    // Check results are displayed
    cy.get('[data-testid="analysis-results"]').should('be.visible')
    cy.get('[data-testid="results-display"]').should('contain.text', 'Analysis complete')
  })

  it('should handle sidebar navigation', () => {
    // Test navigation between different views
    cy.get('[data-testid="sidebar-nav"]').should('be.visible')

    // Click different navigation items
    cy.get('[data-testid="nav-files"]').click()
    cy.get('[data-testid="file-list"]').should('be.visible')

    cy.get('[data-testid="nav-analysis"]').click()
    cy.get('[data-testid="analysis-panel"]').should('be.visible')

    cy.get('[data-testid="nav-settings"]').click()
    cy.get('[data-testid="settings-panel"]').should('be.visible')
  })

  it('should maintain responsive design across viewports', () => {
    cy.testResponsiveDesign()
  })

  it('should handle errors gracefully', () => {
    cy.testErrorHandling()
  })

  it('should work with keyboard navigation', () => {
    // Test tab navigation
    cy.get('body').tab().tab().tab()

    // Test enter key on buttons
    cy.get('[data-testid="start-analysis"]').focus().type('{enter}')

    // Verify analysis starts
    cy.get('[data-testid="analysis-progress"]').should('be.visible')
  })

  it('should persist analysis results', () => {
    // Perform analysis
    cy.get('[data-testid="start-analysis"]').click()
    cy.get('[data-testid="analysis-results"]').should('be.visible')

    // Refresh page
    cy.reload()
    cy.waitForWasmLoad()

    // Check if results are still available (if persistence is implemented)
    cy.get('[data-testid="analysis-results"]').should('exist')
  })
})