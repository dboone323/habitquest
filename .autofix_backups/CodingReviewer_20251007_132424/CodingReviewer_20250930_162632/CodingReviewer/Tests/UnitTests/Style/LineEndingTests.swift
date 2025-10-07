let code = """
// TODO: Add implementation
print("debug")
"""
let lines = code.components(separatedBy: "\n")
print("Total lines: \(lines.count)")
for (i, line) in lines.enumerated() {
    print("Line \(i + 1): '\(line)' (contains TODO: \(line.contains("TODO"))) (contains print: \(line.contains("print(")))")
}
