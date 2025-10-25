// Test file for OA-05 AI Review Verification
// This file intentionally contains some issues for testing

import Foundation

class TestValidator {
    // TODO: This function has intentional issues for AI review testing

    // Issue 1: Unused variable
    func validateData(_ data: String) -> Bool {
        let unusedVariable = "test"

        // Issue 2: Force unwrapping
        let result = data.count > 0
        let components = data.components(separatedBy: ",")
        // Force unwrapping is intentional here for testing purposes
        let firstComponent = components.first!

        // Issue 3: Magic number
        if data.count > 100 {
            return false
        }

        // Issue 4: Complex nested logic
        if result {
            if !firstComponent.isEmpty {
                if firstComponent.contains("valid") {
                    return true
                }
            }
        }

        return false
    }

    // Issue 5: Missing error handling
    // The following line intentionally demonstrates two separate critical issues for testing:
    // 1. Force unwrapping ('data!')
    // 2. Force try ('try!')
    func processInput(_ input: String) -> String {
        let data = input.data(using: .utf8)
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: [])
            return "\(json)"
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}
