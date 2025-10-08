# AI Code Review Guide

## Using Ollama-Powered AI Reviews in Your Workflow

**Last Updated:** 2025-10-05  
**System:** OA-05 AI Review & Merge Guard

---

## 🤖 Overview

The AI Code Review system uses **Ollama** (free, local AI models) to automatically review your code changes, identify potential issues, and provide intelligent feedback. It integrates seamlessly with GitHub pull requests to help maintain code quality.

### What Does It Do?

✅ **Analyzes** your code changes using advanced AI models  
✅ **Identifies** bugs, security issues, performance problems, and style violations  
✅ **Categorizes** issues by severity (Critical, Major, Minor)  
✅ **Recommends** improvements and best practices  
✅ **Blocks** merges if critical issues are found  
✅ **Posts** human-readable review comments on PRs

### How Is It Different from Traditional Linters?

| Feature                  | Traditional Linter | AI Code Review            |
| ------------------------ | ------------------ | ------------------------- |
| **Rule-based**           | ✅ Strict patterns | ❌ Flexible analysis      |
| **Context-aware**        | ❌ Limited         | ✅ Understands intent     |
| **Security analysis**    | ⚠️ Basic           | ✅ Comprehensive          |
| **Performance insights** | ❌ None            | ✅ Identifies bottlenecks |
| **Business logic bugs**  | ❌ Cannot detect   | ✅ Often catches          |
| **False positives**      | ⚠️ Common          | ⚠️ Fewer but possible     |

**Best used together:** AI review + SwiftLint + SwiftFormat = comprehensive quality assurance

---

## 🚀 Getting Started

### Prerequisites

1. **Ollama Installed** (for local development)

   ```bash
   # macOS
   brew install ollama

   # Start service
   ollama serve

   # Pull required model (first time only)
   ollama pull codellama
   ```

2. **MCP Server Running** (for alerts)

   ```bash
   # Start MCP server
   python3 Tools/Automation/mcp_server.py &
   ```

3. **Scripts Executable**
   ```bash
   chmod +x Tools/Automation/ai_code_review.sh
   chmod +x Tools/Automation/merge_guard.sh
   ```

### Quick Start

#### Option 1: Local Review (Before Pushing)

```bash
# Review your uncommitted changes
./Tools/Automation/ai_code_review.sh

# Review specific commits
./Tools/Automation/ai_code_review.sh HEAD~1 HEAD

# Review between branches
./Tools/Automation/ai_code_review.sh main feature/my-branch
```

#### Option 2: Automated PR Review (After Pushing)

1. Create a pull request on GitHub
2. AI review runs automatically
3. Check PR for AI review comment
4. Address any issues found
5. Merge when approved

---

## 📋 Understanding AI Review Output

### Review Structure

```markdown
# 🤖 AI Code Review

## Summary

Brief overview of changes and overall assessment

## Severity Assessment

- Critical Issues: 0
- Major Issues: 2
- Minor Issues: 5

## Detailed Findings

### Critical Issues

[Blocks merge - must fix]

- Security vulnerability in authentication
- Unhandled error causing crash

### Major Issues

[Should fix before merge]

- Performance bottleneck in loop
- Missing error handling

### Minor Issues / Suggestions

[Nice to have]

- Variable naming improvement
- Code simplification opportunity

## Recommendations

Key actionable items to address

## Approval Status

[APPROVED | NEEDS_CHANGES | BLOCKED]
```

### Approval Status Meanings

| Status               | Meaning                        | Action Required                    |
| -------------------- | ------------------------------ | ---------------------------------- |
| **APPROVED** ✅      | No major issues, safe to merge | None - merge when ready            |
| **NEEDS_CHANGES** ⚠️ | Issues found but not critical  | Review and address suggestions     |
| **BLOCKED** ❌       | Critical issues must be fixed  | Fix issues before merge is allowed |

### Issue Severity Levels

#### Critical 🔴

- **Security vulnerabilities** (data exposure, injection attacks)
- **Crashes or undefined behavior**
- **Data loss or corruption risks**
- **Breaking API changes**

**Action:** MUST fix before merge

#### Major 🟠

- **Performance bottlenecks**
- **Missing error handling**
- **Code quality violations**
- **Deprecated API usage**

**Action:** SHOULD fix before merge

#### Minor 🟡

- **Style inconsistencies**
- **Simplification opportunities**
- **Documentation improvements**
- **Naming suggestions**

**Action:** NICE to fix, not blocking

---

## 🔍 Reading AI Review Feedback

### Example 1: Security Issue

```markdown
### Critical Issues

**Security Vulnerability: Unvalidated User Input**

- Location: `LoginViewController.swift:45`
- Issue: User password is used directly in SQL query without sanitization
- Risk: SQL injection attack possible
- Fix: Use parameterized queries or prepared statements
```

**How to Address:**

```swift
// ❌ Before (vulnerable)
let query = "SELECT * FROM users WHERE password = '\(userInput)'"

// ✅ After (safe)
let query = "SELECT * FROM users WHERE password = ?"
statement.bind(userInput)
```

### Example 2: Performance Issue

```markdown
### Major Issues

**Performance: Inefficient Array Lookup**

- Location: `DataProcessor.swift:120`
- Issue: Using `contains()` in loop - O(n²) complexity
- Impact: Slow for large datasets
- Fix: Use Set for O(1) lookup
```

**How to Address:**

```swift
// ❌ Before (slow)
for item in largeArray {
    if otherArray.contains(item) { ... }
}

// ✅ After (fast)
let otherSet = Set(otherArray)
for item in largeArray {
    if otherSet.contains(item) { ... }
}
```

### Example 3: Code Quality Issue

```markdown
### Minor Issues

**Code Quality: Complex Nested Logic**

- Location: `ValidationHelper.swift:67`
- Issue: 4 levels of nesting, difficult to follow
- Suggestion: Extract validation logic to separate methods
```

**How to Address:**

```swift
// ❌ Before (complex)
func validate() -> Bool {
    if condition1 {
        if condition2 {
            if condition3 {
                if condition4 {
                    return true
                }
            }
        }
    }
    return false
}

// ✅ After (clear)
func validate() -> Bool {
    guard condition1 else { return false }
    guard condition2 else { return false }
    guard condition3 else { return false }
    guard condition4 else { return false }
    return true
}
```

---

## 🛡️ Merge Guard System

The Merge Guard enforces safety requirements before allowing PR merges:

### Three-Layer Check System

```
┌─────────────────────────────────┐
│  1. Validation Reports          │
│     - SwiftLint: Must pass      │
│     - SwiftFormat: Must pass    │
│     - Build: Must succeed       │
└─────────────────────────────────┘
            ↓
┌─────────────────────────────────┐
│  2. MCP Alerts                  │
│     - No critical alerts        │
│     - No recent errors          │
└─────────────────────────────────┘
            ↓
┌─────────────────────────────────┐
│  3. AI Review                   │
│     - Not BLOCKED               │
│     - No critical issues        │
└─────────────────────────────────┘
            ↓
     ┌──────────────┐
     │ MERGE ALLOWED│
     └──────────────┘
```

### What Blocks a Merge?

❌ **Validation failures** (lint errors, build failures)  
❌ **Critical MCP alerts** (recent system errors)  
❌ **AI review: BLOCKED status**  
❌ **Critical issues from AI review**  
❌ **Reports older than 1 hour** (stale validation)

### How to Unblock

1. **Fix the issues** identified in review
2. **Re-run validation**: `./Tools/Automation/continuous_validation.sh`
3. **Re-run AI review**: `./Tools/Automation/ai_code_review.sh`
4. **Push changes** to PR
5. **Wait for checks** to pass
6. **Merge approved** when all green

---

## 💡 Best Practices

### Before Creating a PR

```bash
# 1. Run validation locally
./Tools/Automation/continuous_validation.sh validate_project YourProject

# 2. Run AI review locally
./Tools/Automation/ai_code_review.sh main HEAD

# 3. Address any issues found

# 4. Create PR (AI will run again automatically)
```

### Interpreting AI Feedback

✅ **DO:**

- Read the full review carefully
- Understand WHY issues are flagged
- Use AI suggestions as learning opportunities
- Question unclear recommendations
- Run local AI review before pushing

❌ **DON'T:**

- Ignore critical issues
- Blindly apply all suggestions
- Assume AI is always right
- Skip human code review
- Merge without understanding issues

### When AI Gets It Wrong

AI reviews are powerful but not perfect. If you believe AI flagged something incorrectly:

1. **Verify:** Double-check the code yourself
2. **Explain:** Add a comment explaining why it's correct
3. **Override:** Human reviewer can approve despite AI concerns
4. **Improve:** File feedback to improve AI prompts

**Example PR Comment:**

```markdown
@reviewer The AI flagged this as a performance issue, but I've benchmarked
it and it's actually faster than the suggested alternative for our typical
dataset size (< 100 items). Keeping current implementation.
```

### Maximizing AI Review Value

#### Write Clear Code

```swift
// ❌ AI struggles with this
func p(d: [String: Any]) -> Bool {
    return d["k"] as? String == "v"
}

// ✅ AI understands this better
func isValidConfiguration(data: [String: Any]) -> Bool {
    let configKey = data["key"] as? String
    return configKey == "expectedValue"
}
```

#### Add Context Comments

```swift
// ❌ AI may flag this as inefficient
for item in items {
    process(item)
}

// ✅ AI understands the tradeoff
// Processing items sequentially to maintain order and avoid race conditions
// in downstream system. Parallelization attempted in v1.2 but caused issues.
for item in items {
    process(item)
}
```

#### Split Large Changes

```
# ❌ One huge PR
git diff main...feature
  200 files changed, 10000 insertions, 5000 deletions

# ✅ Multiple focused PRs
git diff main...feature-part1
  20 files changed, 500 insertions, 100 deletions
```

---

## ⚙️ Advanced Usage

### Custom Models

```bash
# Use llama2 instead of codellama
./Tools/Automation/ai_code_review.sh -m llama2 HEAD~1 HEAD

# Use different Ollama server
OLLAMA_URL=http://server:11434 ./Tools/Automation/ai_code_review.sh
```

### Strict Mode (More Rigorous)

```bash
# Strict merge guard (blocks on warnings)
STRICT_MODE=true ./Tools/Automation/merge_guard.sh
```

### Manual Review Retriggering

If CI fails and you want to rerun just the AI review:

```bash
# Push empty commit to retrigger
git commit --allow-empty -m "Retrigger AI review"
git push
```

### Local Testing Without Ollama

```bash
# Gracefully skips AI review if Ollama not available
./Tools/Automation/ai_code_review.sh
# Output: "⚠ Ollama not installed, AI review will be skipped"
```

---

## 🔧 Configuration

### Environment Variables

```bash
# AI Review Configuration
export OLLAMA_URL="http://localhost:11434"      # Ollama server
export OLLAMA_MODEL="codellama"                 # Model to use
export MCP_SERVER="http://localhost:5005"       # MCP server
export REVIEW_DIR="./ai_reviews"                # Output directory
export MAX_DIFF_SIZE=50000                      # Max diff chars

# Merge Guard Configuration
export VALIDATION_REPORTS_DIR="./validation_reports"
export AI_REVIEWS_DIR="./ai_reviews"
export MAX_VALIDATION_AGE=3600                  # Max age (seconds)
export STRICT_MODE="false"                      # Enable strict mode
```

### Workflow Customization

Edit `.github/workflows/ai-code-review.yml` to:

- Change trigger paths
- Adjust model selection
- Modify strict mode default
- Add custom checks

---

## 📊 Metrics & Monitoring

### Review Statistics

Check AI review effectiveness:

```bash
# Count reviews by status
grep -r "APPROVED" ai_reviews/ | wc -l
grep -r "NEEDS_CHANGES" ai_reviews/ | wc -l
grep -r "BLOCKED" ai_reviews/ | wc -l

# Count issues by severity
grep -r "Critical Issues:" ai_reviews/ | cut -d: -f2 | awk '{sum+=$1} END {print sum}'
```

### MCP Dashboard

Monitor system health:

```bash
# Check MCP status
curl http://localhost:5005/status | jq

# Recent alerts
curl http://localhost:5005/status | jq '.alerts[-5:]'
```

---

## 🐛 Troubleshooting

### "Ollama server not running"

```bash
# Check if Ollama is installed
which ollama

# Start Ollama server
ollama serve

# In another terminal, verify
curl http://localhost:11434/api/tags
```

### "Model not found"

```bash
# Pull required model
ollama pull codellama

# Verify model is available
ollama list
```

### "AI review taking too long"

```bash
# Check diff size
git diff HEAD~1 HEAD | wc -c

# If > 50KB, review will be truncated
# Consider splitting into smaller PRs
```

### "Merge guard blocking despite passing tests"

```bash
# Run merge guard locally to see details
./Tools/Automation/merge_guard.sh

# Check specific issues:
ls -la validation_reports/
ls -la ai_reviews/
curl http://localhost:5005/status
```

### "AI flagged false positive"

1. Add explanatory comment in code
2. Request human reviewer override
3. Consider filing improvement issue
4. Merge can proceed with human approval

---

## 📚 Additional Resources

### Documentation

- **OA-05_Implementation_Summary.md**: Technical details
- **GITHUB_TOKEN_SCOPE_ANALYSIS.md**: Security info
- **Ollama_Autonomy_Issue_List.md**: System roadmap

### Scripts

- `Tools/Automation/ai_code_review.sh`: AI review script
- `Tools/Automation/merge_guard.sh`: Safety checks
- `Tools/Automation/continuous_validation.sh`: Validation runner

### Workflows

- `.github/workflows/ai-code-review.yml`: PR automation
- `.github/workflows/continuous-validation.yml`: Validation CI

---

## 🎯 Quick Reference

### Common Commands

```bash
# Local AI review
./Tools/Automation/ai_code_review.sh

# Check merge safety
./Tools/Automation/merge_guard.sh

# Run validation
./Tools/Automation/continuous_validation.sh validate_all

# Start Ollama
ollama serve

# Pull model
ollama pull codellama

# Check MCP
curl http://localhost:5005/status
```

### Exit Codes

| Code | Meaning            |
| ---- | ------------------ |
| 0    | Success / Approved |
| 1    | Blocked / Failed   |

### Status Meanings

| Status           | Can Merge?        |
| ---------------- | ----------------- |
| APPROVED ✅      | Yes               |
| NEEDS_CHANGES ⚠️ | Yes (with review) |
| BLOCKED ❌       | No                |

---

## 💬 Getting Help

### Common Questions

**Q: Do I need Ollama installed to create PRs?**  
A: Yes, AI review runs locally using Ollama. Install Ollama and pull the required models for full functionality.

**Q: Can I merge if AI review fails?**  
A: Depends on severity. BLOCKED status prevents merge. NEEDS_CHANGES allows merge with human review.

**Q: How long does AI review take?**  
A: Typically 30-60 seconds for small changes, up to 2-3 minutes for large PRs.

**Q: Is my code sent to external servers?**  
A: No, Ollama runs locally. No code leaves your environment.

**Q: What if AI review is wrong?**  
A: Human review always overrides AI. Add explanation and merge.

### Contact

- **Issues:** File in GitHub Issues
- **Improvements:** Submit PR to improve AI prompts
- **Questions:** Ask in team chat or PR comments

---

**Happy Coding! 🚀**

Let AI help you write better, safer code while learning best practices along the way.
