let longLine1 = String(repeating: "a", count: 130)
let longLine2 = String(repeating: "b", count: 140)
let code = """
class TestClass {
    func method1() {
        let line1 = "\(longLine1)"
    }

    func method2() {
        let line2 = "\(longLine2)"
    }
}
"""
print("Code:")
print(code)
print("\nLines:")
let lines = code.split(separator: "\n", omittingEmptySubsequences: false)
for (i, line) in lines.enumerated() {
    print("Line \(i + 1): \(line.count) chars - '\(line.prefix(50))...'")
}
