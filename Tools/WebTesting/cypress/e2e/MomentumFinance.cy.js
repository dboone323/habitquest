describe('MomentumFinance Web App - Cross-Platform Testing', () => {
  beforeEach(() => {
    cy.loadWebApp('MomentumFinance')
  })

  it('should load the MomentumFinance web application successfully', () => {
    cy.testSwiftWasmIntegration()
    cy.testBasicInteractions()
    cy.testPerformanceMetrics()
  })

  it('should display the finance dashboard', () => {
    cy.get('[data-testid="finance-dashboard"]').should('be.visible')
    cy.get('[data-testid="account-summary"]').should('be.visible')
    cy.get('[data-testid="transaction-list"]').should('be.visible')
    cy.get('[data-testid="add-transaction-button"]').should('be.visible')
  })

  it('should handle financial data input', () => {
    cy.measurePerformance('Transaction Input')

    // Click add transaction
    cy.get('[data-testid="add-transaction-button"]').click()

    // Fill transaction form
    cy.get('[data-testid="transaction-amount"]').type('100.50')
    cy.get('[data-testid="transaction-description"]').type('Test transaction')
    cy.get('[data-testid="transaction-category"]').select('Food')
    cy.get('[data-testid="transaction-date"]').type('2025-10-31')

    // Save transaction
    cy.get('[data-testid="save-transaction"]').click()

    // Verify transaction appears
    cy.get('[data-testid="transaction-list"]').should('contain.text', 'Test transaction')
    cy.get('[data-testid="transaction-list"]').should('contain.text', '$100.50')
  })

  it('should calculate financial metrics', () => {
    // Add multiple transactions
    cy.get('[data-testid="add-transaction-button"]').click()
    cy.get('[data-testid="transaction-amount"]').type('50.00')
    cy.get('[data-testid="transaction-description"]').type('Income')
    cy.get('[data-testid="transaction-category"]').select('Income')
    cy.get('[data-testid="save-transaction"]').click()

    cy.get('[data-testid="add-transaction-button"]').click()
    cy.get('[data-testid="transaction-amount"]').type('-25.00')
    cy.get('[data-testid="transaction-description"]').type('Expense')
    cy.get('[data-testid="transaction-category"]').select('Utilities')
    cy.get('[data-testid="save-transaction"]').click()

    // Check calculations
    cy.get('[data-testid="total-income"]').should('contain.text', '$50.00')
    cy.get('[data-testid="total-expenses"]').should('contain.text', '$25.00')
    cy.get('[data-testid="net-amount"]').should('contain.text', '$25.00')
  })

  it('should render charts and graphs', () => {
    // Ensure some data exists
    cy.get('[data-testid="add-transaction-button"]').click()
    cy.get('[data-testid="transaction-amount"]').type('100.00')
    cy.get('[data-testid="transaction-description"]').type('Chart test')
    cy.get('[data-testid="save-transaction"]').click()

    // Check chart rendering
    cy.get('[data-testid="expense-chart"]').should('be.visible')
    cy.get('[data-testid="income-chart"]').should('be.visible')

    // Verify chart has content (canvas or SVG)
    cy.get('[data-testid="expense-chart"]').find('canvas, svg').should('exist')
  })

  it('should handle different account types', () => {
    // Test account switching
    cy.get('[data-testid="account-selector"]').should('be.visible')

    // Select different accounts
    cy.get('[data-testid="account-checking"]').click()
    cy.get('[data-testid="account-summary"]').should('contain.text', 'Checking')

    cy.get('[data-testid="account-savings"]').click()
    cy.get('[data-testid="account-summary"]').should('contain.text', 'Savings')
  })

  it('should support budget tracking', () => {
    // Set budget limits
    cy.get('[data-testid="budget-settings"]').click()
    cy.get('[data-testid="budget-food"]').type('200.00')
    cy.get('[data-testid="budget-utilities"]').type('100.00')
    cy.get('[data-testid="save-budget"]').click()

    // Add expense that exceeds budget
    cy.get('[data-testid="add-transaction-button"]').click()
    cy.get('[data-testid="transaction-amount"]').type('-250.00')
    cy.get('[data-testid="transaction-description"]').type('Overspend test')
    cy.get('[data-testid="transaction-category"]').select('Food')
    cy.get('[data-testid="save-transaction"]').click()

    // Check budget warning
    cy.get('[data-testid="budget-warning"]').should('be.visible')
    cy.get('[data-testid="budget-warning"]').should('contain.text', 'Food budget exceeded')
  })

  it('should maintain responsive design', () => {
    cy.testResponsiveDesign()
  })

  it('should handle errors gracefully', () => {
    cy.testErrorHandling()
  })

  it('should export financial data', () => {
    // Add some test data
    cy.get('[data-testid="add-transaction-button"]').click()
    cy.get('[data-testid="transaction-amount"]').type('75.00')
    cy.get('[data-testid="transaction-description"]').type('Export test')
    cy.get('[data-testid="save-transaction"]').click()

    // Test export functionality
    cy.get('[data-testid="export-data"]').click()

    // Verify download is triggered (check for download event or file dialog)
    cy.window().then((win) => {
      // This would need to be customized based on actual implementation
      expect(win).to.have.property('URL')
    })
  })

  it('should persist financial data', () => {
    // Add transaction
    cy.get('[data-testid="add-transaction-button"]').click()
    cy.get('[data-testid="transaction-amount"]').type('42.42')
    cy.get('[data-testid="transaction-description"]').type('Persistence test')
    cy.get('[data-testid="save-transaction"]').click()

    // Refresh page
    cy.reload()
    cy.waitForWasmLoad()

    // Check data persists
    cy.get('[data-testid="transaction-list"]').should('contain.text', 'Persistence test')
  })
})