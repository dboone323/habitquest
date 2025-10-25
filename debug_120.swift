#!/usr/bin/env swift

import Foundation

// Test the exact 120 chars case after my fix
let exactLine = String(repeating: "x", count: 96) // 96 + 8 (indent) + 14 ("let result = ") + 2 (quotes) = 120
let code120 = """
class Calculator {
    func calculate() {
        let result = \(exactLine)
    }
}
"""

print("120 chars test after fix:")
print("Code to analyze:")
print(code120)
print("\nLines:")

let lines120 = code120.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in lines120.enumerated() {
    print("Line \(index + 1): \(line.count) characters - '\(line)'")
}

// Also check what happens if I make it exactly 120
let exact120Line = String(repeating: "x", count: 88) // Let's try 88
let code120_exact = """
class Calculator {
    func calculate() {
        let result = \(exact120Line)
    }
}
"""

print("\n\nTrying with 88 x's:")
print("Code to analyze:")
print(code120_exact)
print("\nLines:")

let lines120_exact = code120_exact.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in lines120_exact.enumerated() {
    print("Line \(index + 1): \(line.count) characters - '\(line)'")
}
