# OA-05 Testing & Monitoring Guide

**Date:** 2025-10-05  
**Status:** Testing Phase  
**System:** AI Review & Guarded Merge

---

## 🧪 Testing Progress

### Test Branch Created

- **Branch:** `test/oa-05-verification`
- **Commit:** `b2c6debd`
- **File:** `Projects/TestFile.swift` (41 lines)
- **Purpose:** End-to-end verification of AI review workflow

### Intentional Test Issues

The test file contains 5 types of issues to verify AI detection:

1. **Unused Variable** (Line 12)

   ```swift
   let unusedVariable = "test"
   ```

   Expected: AI should flag as code quality issue

2. **Force Unwrapping** (Line 17)

   ```swift
   let firstComponent = components.first!
   ```

   Expected: AI should flag as potential crash risk

3. **Magic Number** (Line 20)

   ```swift
   if data.count > 100 {
   ```

   Expected: AI should suggest using named constant

4. **Complex Nested Logic** (Lines 24-30)

   ```swift
   if result {
       if firstComponent.count > 0 {
           if firstComponent.contains("valid") {
   ```

   Expected: AI should suggest using guard statements

5. **Missing Error Handling** (Line 37)
   ```swift
   let json = try! JSONSerialization.jsonObject(with: data!, options: [])
   ```
   Expected: AI should flag as critical error (force try)

### Testing Checklist

- [x] Test branch created and pushed
- [x] Test file with intentional issues committed
- [ ] Local AI review test completed
- [ ] PR created on GitHub
- [ ] GitHub Actions workflow triggered
- [ ] AI review comment posted to PR
- [ ] Commit status check set
- [ ] Merge guard validation completed
- [ ] Artifacts uploaded
- [ ] Review quality assessed

---

## 📊 Performance Monitoring

### Metrics to Track

#### 1. Review Generation Performance

```bash
# Monitor Ollama response time
time ./Tools/Automation/ai_code_review.sh main test/oa-05-verification

# Expected baseline:
# - Small diffs (<2KB): 30-60 seconds
# - Medium diffs (2-10KB): 60-120 seconds
# - Large diffs (10-50KB): 120-180 seconds
```

#### 2. Issue Detection Accuracy

Track false positives/negatives:

```bash
# Count issues detected
grep -A 5 "Critical Issues:" ai_reviews/review_*.md
grep -A 5 "Major Issues:" ai_reviews/review_*.md
grep -A 5 "Minor Issues:" ai_reviews/review_*.md

# Calculate detection rate
# Issues detected / Known issues = accuracy %
```

#### 3. MCP Integration Health

```bash
# Check MCP server status
curl -s http://localhost:5005/status | jq '{
  total_alerts: (.alerts | length),
  critical: [.alerts[] | select(.level == "critical")] | length,
  errors: [.alerts[] | select(.level == "error")] | length,
  warnings: [.alerts[] | select(.level == "warning")] | length
}'

# Check alert publish success rate
# Successful publishes / Total reviews = publish rate %
```

#### 4. Workflow Execution Time

```bash
# Check GitHub Actions duration
# Navigate to: https://github.com/dboone323/Quantum-workspace/actions
# Look for: "AI Code Review & Merge Guard" workflow runs

# Expected total time:
# - Setup: 2-3 minutes (Ollama + model pull)
# - Validation: 1-2 minutes per project
# - AI Review: 1-3 minutes
# - Merge Guard: <1 minute
# - Total: 5-10 minutes
```

---

## 🎯 Review Quality Assessment

### Evaluation Criteria

#### Critical Issues (Must Detect)

- [ ] Force unwrapping detected?
- [ ] Force try detected?
- [ ] Security vulnerabilities identified?
- [ ] Crash risks flagged?

#### Major Issues (Should Detect)

- [ ] Performance problems noted?
- [ ] Complex logic identified?
- [ ] Missing error handling flagged?
- [ ] Best practice violations?

#### Minor Issues (Nice to Detect)

- [ ] Unused variables found?
- [ ] Magic numbers identified?
- [ ] Naming improvements suggested?
- [ ] Code simplification opportunities?

### Quality Metrics

```bash
# Calculate precision (relevance of findings)
precision = true_positives / (true_positives + false_positives)

# Calculate recall (coverage of issues)
recall = true_positives / (true_positives + false_negatives)

# Target metrics:
# - Precision: >70% (most findings are valid)
# - Recall: >60% (catches most issues)
```

---

## 🔧 Prompt Refinement

### Current Prompt Structure

The AI review prompt includes:

1. **Context Setting**

   - "You are an expert code reviewer"
   - Focus areas defined upfront

2. **Analysis Categories**

   - Code Quality
   - Bugs & Errors
   - Security
   - Performance
   - Best Practices
   - Maintainability

3. **Output Format**
   - Summary
   - Severity Assessment
   - Detailed Findings
   - Recommendations
   - Approval Status

### Refinement Strategy

Based on test results, adjust prompts for:

#### Too Many False Positives

```bash
# Add to prompt:
"Only flag issues with high confidence.
When in doubt, classify as Minor or omit."

# Increase temperature: 0.3 → 0.4
# More creative/lenient
```

#### Missing Real Issues

```bash
# Add to prompt:
"Be thorough in identifying potential bugs.
Pay special attention to error handling and null checks."

# Decrease temperature: 0.3 → 0.2
# More deterministic/strict
```

#### Generic/Unhelpful Feedback

```bash
# Add to prompt:
"For each issue, provide:
1. Exact line number or function name
2. Specific problem description
3. Concrete fix recommendation
4. Code example if helpful"
```

#### Wrong Severity Classification

```bash
# Add severity definitions:
"Critical: Code that will crash or expose data
Major: Performance issues, missing error handling
Minor: Style, naming, simplification opportunities"
```

### Prompt Iteration Log

| Version | Date       | Change                           | Result     |
| ------- | ---------- | -------------------------------- | ---------- |
| 1.0     | 2025-10-05 | Initial prompt with 6 categories | Testing... |
|         |            |                                  |            |

---

## 🚀 Next Steps

### Immediate (This Session)

1. **Complete Local Test**

   ```bash
   # Let Ollama finish generation
   ./Tools/Automation/ai_code_review.sh main test/oa-05-verification

   # Review output
   cat ai_reviews/review_*.md

   # Check issue detection
   ```

2. **Create GitHub PR**

   ```bash
   # Visit: https://github.com/dboone323/Quantum-workspace/pull/new/test/oa-05-verification
   # Or use GitHub CLI:
   gh pr create --base main --head test/oa-05-verification \
     --title "Test: OA-05 AI Review Verification" \
     --body "Testing AI review workflow with intentional code issues"
   ```

3. **Monitor Workflow**

   - Watch GitHub Actions run
   - Check for PR comment
   - Verify commit status
   - Review artifacts

4. **Assess Results**
   - Did AI detect the 5 intentional issues?
   - Was severity classification appropriate?
   - Were recommendations helpful?
   - Did merge guard work correctly?

### Short-Term (This Week)

1. **Performance Baseline**

   - Run 3-5 more test reviews
   - Record average response times
   - Document typical detection patterns

2. **Prompt Refinement**

   - Adjust based on false positives/negatives
   - Test refined prompts
   - Document improvements

3. **Real-World Testing**
   - Use on actual feature PRs
   - Gather developer feedback
   - Identify edge cases

### Medium-Term (Next Sprint)

1. **OA-06: Observability & Hygiene**

   - Watchdog for automation logs
   - Nightly metrics snapshots
   - Branch/PR cleanup automation
   - Health monitoring dashboard

2. **System Refinement**

   - Optimize Ollama prompt for speed
   - Add caching for repeated diffs
   - Improve MCP alert categorization
   - Enhanced artifact analysis

3. **Documentation**
   - Create troubleshooting playbook
   - Add FAQ section
   - Record common issues and solutions

---

## 📈 Success Criteria

### OA-05 is Successful If:

✅ **Functional Requirements**

- [ ] AI reviews generate consistently (>95% success rate)
- [ ] Critical issues are detected (>80% recall)
- [ ] False positives are manageable (<30%)
- [ ] PR comments are helpful and actionable
- [ ] Merge guard blocks unsafe merges (100% when critical)

✅ **Performance Requirements**

- [ ] Reviews complete in <3 minutes (median)
- [ ] Workflow completes in <10 minutes (total)
- [ ] MCP integration has <1% failure rate
- [ ] Ollama server uptime >99%

✅ **User Experience**

- [ ] Developers find reviews helpful
- [ ] Recommendations are actionable
- [ ] False positive rate is acceptable
- [ ] Review doesn't slow down workflow significantly

---

## 🔍 Debugging Common Issues

### Ollama Slow Response

```bash
# Check Ollama resource usage
ps aux | grep ollama

# Check model size
ollama list

# Try smaller/faster model
OLLAMA_MODEL=phi3 ./Tools/Automation/ai_code_review.sh
```

### AI Review Fails

```bash
# Check Ollama logs
tail -f ~/.ollama/logs/server.log

# Verify model availability
curl http://localhost:11434/api/tags

# Test simple generation
curl http://localhost:11434/api/generate \
  -d '{"model":"codellama","prompt":"test","stream":false}'
```

### Merge Guard Blocks Incorrectly

```bash
# Run with verbose output
./Tools/Automation/merge_guard.sh

# Check each validation layer:
ls -la validation_reports/
cat ai_reviews/review_*.md | grep "Approval Status"
curl http://localhost:5005/status | jq '.alerts[-5:]'
```

### GitHub Workflow Fails

```bash
# Check workflow syntax
actionlint .github/workflows/ai-code-review.yml

# View workflow logs in GitHub Actions
# Check for Ollama installation issues
# Verify MCP server started correctly
```

---

## 📝 Test Results Template

```markdown
## Test Run: [Date]

**Branch:** test/oa-05-verification
**Commit:** b2c6debd

### Issues Detected

- [ ] Critical: Force try (Line 37)
- [ ] Critical: Force unwrap (Line 17)
- [ ] Major: Complex nested logic (Lines 24-30)
- [ ] Major: Magic number (Line 20)
- [ ] Minor: Unused variable (Line 12)

### Performance

- Ollama response time: [X seconds]
- Total workflow time: [X minutes]
- MCP publish success: [Yes/No]

### Approval Status

- AI Review: [APPROVED/NEEDS_CHANGES/BLOCKED]
- Merge Guard: [APPROVED/BLOCKED]

### Issues Found

- False Positives: [List]
- False Negatives: [List]
- Severity Misclassifications: [List]

### Recommendations

[What should be adjusted in prompts or configuration]

### Next Actions

[What to test or improve next]
```

---

## 🎯 Current Status

**As of 2025-10-05:**

- ✅ Test branch created and pushed
- ✅ Test file with 5 intentional issues committed
- 🔄 Local AI review in progress (Ollama generating response)
- ⏳ Waiting for review completion to assess quality
- ⏳ PR not yet created (pending local test results)

**Next Immediate Action:**
Let local AI review complete, then assess results and create PR for full workflow test.
