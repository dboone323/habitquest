#!/usr/bin/env swift

import Foundation

// Test code for LineExactly120Chars
let code1 = """
class Calculator {
    func calculate() {
        let result = "This is a string that should be exactly 120 characters or less when counted by the service"
    }
}
"""

print("=== LineExactly120Chars Test ===")
let lines1 = code1.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in lines1.enumerated() {
    print("Line \(index + 1): \(line.count) chars - '\(line)'")
}

// Test code for LineWithTabs
let code2 = """
class Test {
\t\tfunc method() {
\t\t\tlet veryLongVariableName = "This is a very long string that will definitely exceed the line limit when combined with indentation and extra text"
\t\t}
}
"""

print("\n=== LineWithTabs Test ===")
let lines2 = code2.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in lines2.enumerated() {
    print("Line \(index + 1): \(line.count) chars - '\(line)'")
}

// Test code for LongLine
let longLine = String(repeating: "x", count: 125)
let code3 = """
class Calculator {
    func calculate() {
        let result = \(longLine)
    }
}
"""

print("\n=== LongLine Test ===")
let lines3 = code3.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in lines3.enumerated() {
    print("Line \(index + 1): \(line.count) chars - '\(line)'")
}

// Test code for MultipleLongLines
let longLine1 = String(repeating: "a", count: 130)
let longLine2 = String(repeating: "b", count: 140)
let code4 = """
class TestClass {
    func method1() {
        let line1 = "\(longLine1)"
    }

    func method2() {
        let line2 = "\(longLine2)"
    }
}
"""

print("\n=== MultipleLongLines Test ===")
let lines4 = code4.split(separator: "\n", omittingEmptySubsequences: false)
for (index, line) in lines4.enumerated() {
    print("Line \(index + 1): \(line.count) chars - '\(line)'")
}
