//
// Debug JavaScript analysis
//

import Foundation

// Mock the services for testing
struct MockSecurityAnalysisService {
    func detectSecurityIssues(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        if code.contains("eval("), language == "JavaScript" {
            issues.append(CodeIssue(
                description: "Use of eval() detected - security risk",
                severity: .high,
                line: nil,
                category: .security
            ))
        }

        if code.contains("innerHTML"), language == "JavaScript" {
            issues.append(CodeIssue(
                description: "Direct innerHTML assignment - potential XSS vulnerability",
                severity: .medium,
                line: nil,
                category: .security
            ))
        }

        return issues
    }
}

struct MockBugDetectionService {
    func detectBasicBugs(code: String, language _: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        if code.contains("TODO") || code.contains("FIXME") {
            issues.append(CodeIssue(
                description: "TODO or FIXME comments found - these should be addressed",
                severity: .medium,
                line: nil,
                category: .bug
            ))
        }

        return issues
    }
}

struct MockPerformanceAnalysisService {
    func detectPerformanceIssues(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        if language == "JavaScript" {
            if code.contains("forEach"), code.contains("push") {
                issues.append(CodeIssue(
                    description: "Using forEach with push - consider using map instead",
                    severity: .low,
                    line: nil,
                    category: .performance
                ))
            }
        }

        return issues
    }
}

struct MockStyleAnalysisService {
    func detectStyleIssues(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        if language == "JavaScript" {
            let lines = code.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                if line.count > 120 {
                    issues.append(CodeIssue(
                        description: "Line \(index + 1) is too long (\(line.count) characters)",
                        severity: .low,
                        line: index + 1,
                        category: .style
                    ))
                }
            }
        }

        return issues
    }
}

// Test the JavaScript code from the failing test
let jsCode = """
// TODO: Implement security check
function processUserInput(input) {
    console.log("Processing: " + input); // Debug log

    // Dangerous eval usage
    const result = eval(input);

    // Setting innerHTML directly
    document.getElementById('output').innerHTML = result;

    // Inefficient array processing
    const numbers = [1, 2, 3, 4, 5];
    const doubled = [];
    numbers.forEach(num => {
        doubled.push(num * 2);
    });

    return result;
}

// Very long function name that exceeds line length limits and should be flagged as a style issue
function thisIsAVeryLongFunctionNameThatDefinitelyExceedsTheRecommendedLineLengthLimitForJavaScriptCode(parameter1, parameter2, parameter3, parameter4, parameter5) {
    return "This line is also very long and should be detected as a style issue because it exceeds normal line length recommendations for readable code";
}
"""

print("Testing JavaScript analysis...")
print("Code contains 'eval(': \(jsCode.contains("eval("))")
print("Code contains 'innerHTML': \(jsCode.contains("innerHTML"))")
print("Code contains 'TODO': \(jsCode.contains("TODO"))")
print("Code contains 'forEach': \(jsCode.contains("forEach"))")
print("Code contains 'push': \(jsCode.contains("push"))")

let securityService = MockSecurityAnalysisService()
let bugService = MockBugDetectionService()
let performanceService = MockPerformanceAnalysisService()
let styleService = MockStyleAnalysisService()

let securityIssues = securityService.detectSecurityIssues(code: jsCode, language: "JavaScript")
let bugIssues = bugService.detectBasicBugs(code: jsCode, language: "JavaScript")
let performanceIssues = performanceService.detectPerformanceIssues(code: jsCode, language: "JavaScript")
let styleIssues = styleService.detectStyleIssues(code: jsCode, language: "JavaScript")

print("\nSecurity issues: \(securityIssues.count)")
for issue in securityIssues {
    print("  - \(issue.description)")
}

print("\nBug issues: \(bugIssues.count)")
for issue in bugIssues {
    print("  - \(issue.description)")
}

print("\nPerformance issues: \(performanceIssues.count)")
for issue in performanceIssues {
    print("  - \(issue.description)")
}

print("\nStyle issues: \(styleIssues.count)")
for issue in styleIssues {
    print("  - \(issue.description)")
}

let totalIssues = securityIssues.count + bugIssues.count + performanceIssues.count + styleIssues.count
print("\nTotal issues: \(totalIssues)")
