// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************

/// <reference types="cypress" />

// Custom commands for SwiftWasm web application testing

Cypress.Commands.add('loadWebApp', (appName) => {
  cy.visit(`/${appName}/WebInterface/demo.html`)
  cy.waitForWasmLoad()
  cy.checkBrowserCompatibility()
})

Cypress.Commands.add('testBasicInteractions', () => {
  // Test that basic UI elements are present and interactive
  cy.get('body').should('be.visible')

  // Test button interactions (if buttons exist)
  cy.get('button').each(($btn) => {
    cy.wrap($btn).should('be.visible').and('not.be.disabled')
  })

  // Test input fields (if any exist)
  cy.get('input').each(($input) => {
    cy.wrap($input).should('be.visible')
  })

  // Test links (if any exist)
  cy.get('a').each(($link) => {
    cy.wrap($link).should('have.attr', 'href')
  })
})

Cypress.Commands.add('testSwiftWasmIntegration', () => {
  // Test that SwiftWasm runtime is properly initialized
  cy.window().should('have.property', 'SwiftWasm')

  // Test that WebAssembly module is loaded
  cy.window().its('WebAssembly').should('exist')

  // Check for JavaScriptKit integration
  cy.window().should('have.property', 'JavaScriptKit')
})

Cypress.Commands.add('testResponsiveDesign', () => {
  // Test different viewport sizes
  const viewports = [
    { width: 1920, height: 1080 }, // Desktop
    { width: 1366, height: 768 },  // Laptop
    { width: 768, height: 1024 },  // Tablet
    { width: 375, height: 667 }    // Mobile
  ]

  viewports.forEach((viewport) => {
    cy.viewport(viewport.width, viewport.height)
    cy.get('body').should('be.visible')
    // Check that content is still accessible at different sizes
    cy.get('*').should('not.have.css', 'overflow', 'hidden').and('not.have.css', 'overflow-x', 'hidden')
  })
})

Cypress.Commands.add('testPerformanceMetrics', () => {
  cy.window().then((win) => {
    // Measure initial load performance
    const loadTime = win.performance.timing.loadEventEnd - win.performance.timing.navigationStart
    cy.log(`Page load time: ${loadTime}ms`)
    expect(loadTime).to.be.lessThan(10000) // 10 seconds max

    // Measure memory usage (if available)
    if (win.performance.memory) {
      const memoryUsage = win.performance.memory.usedJSHeapSize / 1024 / 1024 // MB
      cy.log(`Memory usage: ${memoryUsage.toFixed(2)}MB`)
      expect(memoryUsage).to.be.lessThan(100) // 100MB max
    }
  })
})

Cypress.Commands.add('testErrorHandling', () => {
  // Test that application handles errors gracefully
  cy.window().then((win) => {
    // Override console.error to capture errors
    const errors = []
    const originalError = win.console.error
    win.console.error = (...args) => {
      errors.push(args.join(' '))
      originalError.apply(win.console, args)
    }

    // Trigger some potential error conditions
    cy.then(() => {
      // Check that no critical errors occurred
      const criticalErrors = errors.filter(error =>
        error.includes('WebAssembly') ||
        error.includes('JavaScriptKit') ||
        error.includes('SwiftWasm') ||
        error.includes('TypeError') ||
        error.includes('ReferenceError')
      )

      if (criticalErrors.length > 0) {
        throw new Error(`Critical errors detected: ${criticalErrors.join('; ')}`)
      }
    })
  })
})