const { defineConfig } = require('cypress')

module.exports = defineConfig({
  projectId: 'quantum-workspace-web-testing',
  e2e: {
    baseUrl: 'http://localhost:8000',
    viewportWidth: 1280,
    viewportHeight: 720,
    defaultCommandTimeout: 10000,
    requestTimeout: 15000,
    responseTimeout: 15000,
    video: true,
    screenshotOnRunFailure: true,
    retries: {
      runMode: 2,
      openMode: 0
    },
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'cypress/support/e2e.js',
    setupNodeEvents(on, config) {
      // implement node event listeners here
      on('before:run', (details) => {
        console.log('Starting cross-platform web testing suite')
      })

      on('after:run', (results) => {
        console.log(`Testing completed. Total: ${results.totalTests}, Passed: ${results.totalPassed}, Failed: ${results.totalFailed}`)
      })
    }
  },
  env: {
    webApps: [
      'CodingReviewer',
      'PlannerApp',
      'AvoidObstaclesGame',
      'MomentumFinance',
      'HabitQuest'
    ]
  }
})