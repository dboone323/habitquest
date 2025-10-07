let exactLine = String(repeating: "x", count: 120)
let code = """
class Calculator {
    func calculate() {
        let result = \(exactLine)
    }
}
"""
print("Code:")
print(code)
print("\nLines:")
let lines = code.split(separator: "\n", omittingEmptySubsequences: false)
for (lineIndex, line) in lines.enumerated() {
    print("Line \(lineIndex + 1): \(line.count) chars - '\(line)'")
}
