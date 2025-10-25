#!/usr/bin/env swift

import Foundation

// Test code from the failing test
let longLine = String(repeating: "x", count: 125)
let code = """
class Calculator {
    func calculate() {
        let result = \(longLine)
    }
}
"""

print("Code to analyze:")
print(code)
print("\nLines:")

let lines = code.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in lines.enumerated() {
    print("Line \(index + 1): \(line.count) characters - '\(line)'")
}

// Test the exact 120 chars case
let exactLine = String(repeating: "x", count: 106) // 106 + 14 ("let result = ") + 0 = 120
let code120 = """
class Calculator {
    func calculate() {
        let result = \(exactLine)
    }
}
"""

print("\n\n120 chars test:")
print("Code to analyze:")
print(code120)
print("\nLines:")

let lines120 = code120.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in lines120.enumerated() {
    print("Line \(index + 1): \(line.count) characters - '\(line)'")
}

// Test tabs case
let codeTabs = """
class Test {
\t\tfunc method() {
\t\t\tlet veryLongVariableName = "This is a very long string that will definitely exceed the line limit when combined with indentation and extra text"
\t\t}
}
"""

print("\n\nTabs test:")
print("Code to analyze:")
print(codeTabs)
print("\nLines:")

let linesTabs = codeTabs.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in linesTabs.enumerated() {
    print("Line \(index + 1): \(line.count) characters - '\(line)'")
}

// Test multiple lines
let longLine1 = String(repeating: "a", count: 130)
let longLine2 = String(repeating: "b", count: 140)
let codeMultiple = """
class TestClass {
    func method1() {
        let line1 = "\(longLine1)"
    }

    func method2() {
        let line2 = "\(longLine2)"
    }
}
"""

print("\n\nMultiple lines test:")
print("Code to analyze:")
print(codeMultiple)
print("\nLines:")

let linesMultiple = codeMultiple.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in linesMultiple.enumerated() {
    print("Line \(index + 1): \(line.count) characters - '\(line)'")
}
