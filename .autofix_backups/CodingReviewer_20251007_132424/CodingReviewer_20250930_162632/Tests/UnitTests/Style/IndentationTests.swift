let code = """
class Test {
\t\tfunc method() {
\t\t\tlet veryLongVariableName = "This is a long string that might exceed the line limit when combined with indentation"
\t\t}
}
"""
print("Code:")
print(code)
print("\nLines:")
let lines = code.split(separator: "\n", omittingEmptySubsequences: false)
for (i, line) in lines.enumerated() {
    print("Line \(i + 1): \(line.count) chars - '\(line)'")
}
