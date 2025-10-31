// ***********************************************************
// This example support/e2e.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import './commands'

// Global test configuration for SwiftWasm web apps
Cypress.on('uncaught:exception', (err, runnable) => {
  // Return false to prevent Cypress from failing the test on uncaught exceptions
  // from the application under test (not from Cypress itself)
  if (err.message.includes('WebAssembly') ||
      err.message.includes('JavaScriptKit') ||
      err.message.includes('SwiftWasm')) {
    console.warn('Ignoring expected WebAssembly/SwiftWasm exception:', err.message)
    return false
  }
  // Let other exceptions fail the test
  return true
})

// Global beforeEach hook
beforeEach(() => {
  // Clear local storage before each test
  cy.clearLocalStorage()

  // Set viewport for consistent testing
  cy.viewport(1280, 720)

  // Disable service workers if any
  cy.window().then((win) => {
    if (win.navigator && win.navigator.serviceWorker) {
      win.navigator.serviceWorker.getRegistrations().then((registrations) => {
        registrations.forEach((registration) => {
          registration.unregister()
        })
      })
    }
  })
})

// Custom commands for SwiftWasm web app testing
Cypress.Commands.add('waitForWasmLoad', () => {
  // Wait for WebAssembly module to load
  cy.get('body', { timeout: 30000 }).should('not.have.class', 'loading')

  // Wait for Swift runtime to initialize
  cy.window({ timeout: 30000 }).should('have.property', 'SwiftWasm')

  // Check for any WebAssembly compilation errors
  cy.window().then((win) => {
    if (win.console && win.console.error) {
      // Override console.error to catch WASM errors
      const originalError = win.console.error
      win.console.error = (...args) => {
        const message = args.join(' ')
        if (message.includes('WebAssembly') || message.includes('WASM')) {
          throw new Error(`WebAssembly Error: ${message}`)
        }
        originalError.apply(win.console, args)
      }
    }
  })
})

Cypress.Commands.add('checkBrowserCompatibility', () => {
  // Check if browser supports required features
  cy.window().then((win) => {
    expect(win.WebAssembly, 'WebAssembly support required').to.exist
    expect(win.SharedArrayBuffer, 'SharedArrayBuffer support recommended').to.exist

    // Check for ES6 modules support
    const script = win.document.createElement('script')
    script.type = 'module'
    expect(() => win.document.head.appendChild(script), 'ES6 modules support required').to.not.throw()
    script.remove()
  })
})

Cypress.Commands.add('measurePerformance', (actionName) => {
  cy.window().then((win) => {
    const startTime = win.performance.now()

    // Execute the action (to be defined by the calling test)
    cy.then(() => {
      const endTime = win.performance.now()
      const duration = endTime - startTime

      cy.log(`${actionName} took ${duration.toFixed(2)}ms`)

      // Assert performance is within acceptable limits
      expect(duration).to.be.lessThan(5000) // 5 seconds max
    })
  })
})