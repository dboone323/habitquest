# .github/workflows README

## Active Workflows (14 workflows)

Last updated: October 6, 2025

---

### Continuous Integration (3 workflows)

#### automation-ci.yml

- **Purpose:** Tests automation code with Python version matrix
- **Triggers:** Push/PR to `Tools/Automation/**`
- **Runner:** ubuntu-latest
- **Key Features:**
  - Python 3.10, 3.11, 3.12 matrix testing
  - Pip caching with wheels
  - Virtual environment management
  - Asset building
  - Test reports (JUnit XML)
  - Artifact uploads

#### optimized-ci.yml

- **Purpose:** Smart path-based CI with change detection
- **Triggers:** Push/PR to main
- **Runner:** ubuntu-latest
- **Key Features:**
  - Path-based job triggering (automation, shared, projects, docs, workflows)
  - Conditional execution (only runs relevant checks)
  - Concurrency control (cancel-in-progress)
  - Security scanning with Trivy
  - Comprehensive summary report

#### unified-ci.yml

- **Purpose:** Full build and test for all 5 Swift projects
- **Triggers:** Push/PR to main
- **Runner:** macos-latest
- **Key Features:**
  - Matrix build for all projects (AvoidObstaclesGame, HabitQuest, MomentumFinance, PlannerApp, CodingReviewer)
  - SwiftFormat idempotence check
  - SwiftLint validation
  - SwiftPM and Xcode builds
  - Semantic release on main
  - Artifact archival

---

### Pull Request Validation (3 workflows)

#### pr-validation-unified.yml ⭐ NEW

- **Purpose:** Unified PR validation (basic + automation checks)
- **Triggers:** PR opened/sync/reopened
- **Runner:** ubuntu-latest
- **Key Features:**
  - Always: Basic sanity checks, TODO/FIXME enforcement
  - Conditional: Automation validation (when Tools/Automation or .github/workflows changed)
  - Bash syntax checking
  - ShellCheck linting
  - Deploy validation
  - Workflow YAML validation
  - Comprehensive summary

#### ai-code-review.yml

- **Purpose:** AI-powered code review and merge guard
- **Triggers:** PR
- **Runner:** ubuntu-latest
- **Unique:** AI analysis of code changes

#### trunk.yml

- **Purpose:** Trunk.io code quality checks
- **Triggers:** PR, push to main
- **Runner:** ubuntu-latest
- **Unique:** Third-party integration for code quality

---

### Security & Quality (2 workflows)

#### enhanced-security.yml

- **Purpose:** Unified security vulnerability scanning
- **Triggers:** Push (main, develop), PR, Schedule
- **Runner:** ubuntu-latest
- **Key Features:**
  - Trivy vulnerability scanner
  - SARIF report upload
  - CodeQL integration

#### test-coverage.yml

- **Purpose:** Test coverage tracking and quality gates
- **Triggers:** Push to main, PR
- **Runner:** macos-latest
- **Key Features:**
  - Coverage analysis
  - Quality gate enforcement
  - Trend tracking

---

### Scheduled Maintenance (4 workflows)

#### nightly-hygiene.yml

- **Purpose:** Daily automated maintenance
- **Schedule:** Daily at 00:00 UTC
- **Runner:** ubuntu-latest
- **Tasks:**
  - Backup cleanup (keep last 7 days)
  - Backup compression (files >24h old)
  - Metrics cleanup (90-day retention)
  - Log rotation
  - Watchdog execution
  - Metrics snapshot

#### swiftlint-auto-fix.yml ⭐ NEW

- **Purpose:** Automatically fix SwiftLint violations
- **Schedule:** Daily at 01:00 UTC
- **Runner:** macos-latest
- **Tasks:**
  - Scan all Swift files
  - Auto-fix violations
  - Commit changes if any

#### weekly-health-check.yml ⭐ NEW

- **Purpose:** Comprehensive system health monitoring
- **Schedule:** Weekly Sunday at 02:00 UTC
- **Runner:** ubuntu-latest
- **Tasks:**
  - System health analysis
  - GitHub issue creation for CRITICAL problems
  - Health report generation

#### workflow-failure-notify.yml

- **Purpose:** Notification system for workflow failures
- **Triggers:** Workflow failure events
- **Runner:** ubuntu-latest
- **Tasks:**
  - Alert on failures
  - Create notifications

---

### Specialized (2 workflows)

#### quantum-agent-self-heal.yml

- **Purpose:** Reusable self-healing workflow
- **Type:** Reusable workflow
- **Runner:** ubuntu-latest
- **Unique:** Called by other workflows for self-healing capabilities

#### create-review-issues.yml

- **Purpose:** Auto-create review issues for changes
- **Triggers:** Push to main
- **Runner:** ubuntu-latest
- **Tasks:**
  - Analyze changes
  - Create GitHub issues for review

---

### Swift Code Validation (1 workflow)

#### continuous-validation.yml

- **Purpose:** Swift code quality validation for Projects and Shared
- **Triggers:**
  - Push/PR to main/develop (when Swift files change)
  - Manual workflow_dispatch (can specify project)
- **Runner:** macos-latest
- **Key Features:**
  - SwiftLint and SwiftFormat validation
  - Project-specific or all-project validation
  - Validation report generation
  - Optional MCP server integration
  - Fails on validation errors
- **Unique:** Only workflow focused on Swift code quality validation
- **Status:** ✅ KEEP (unique Swift validation functionality)

---

## Archived Workflows

See `archive_20251006/README.md` for workflows deprecated during the October 2025 consolidation.

**Archived (October 6, 2025):**

- `pr-validation.yml` - Merged into pr-validation-unified.yml
- `validate-and-lint-pr.yml` - Merged into pr-validation-unified.yml

**Note:** `ci.yml` and `automation-tests.yml` mentioned in initial analysis were already absent from repository.

---

## Workflow Consolidation History

### October 6, 2025 - Phase 1 & 2 Consolidation

**Before:** 16 workflows  
**After:** 14 workflows  
**Reduction:** 2 workflows (12.5% ↓)

**Changes:**

1. ✅ Created `pr-validation-unified.yml` (combines 2 workflows)
2. ✅ Archived `pr-validation.yml` (generic PR checks)
3. ✅ Archived `validate-and-lint-pr.yml` (automation-specific checks)
4. ✅ Investigated `continuous-validation.yml` - KEEP (unique Swift validation)

**Impact:**

- Single entry point for PR validation
- Clearer organization
- Conditional path-based execution preserved
- All functionality maintained
- Easier maintenance

**Benefits:**

- ✅ Reduced PR validation complexity
- ✅ Conditional execution still efficient
- ✅ Clearer workflow purpose
- ✅ Easier to maintain and update

---

## Workflow Organization Matrix

| Category             | Count  | Purpose                                      |
| -------------------- | ------ | -------------------------------------------- |
| **CI**               | 3      | Build, test, and validate code changes       |
| **PR Validation**    | 3      | Validate pull requests before merge          |
| **Security**         | 2      | Scan for vulnerabilities and enforce quality |
| **Maintenance**      | 4      | Automated daily/weekly maintenance tasks     |
| **Specialized**      | 2      | Self-healing and issue automation            |
| **Swift Validation** | 1      | Swift-specific code quality checks           |
| **TOTAL**            | **14** | Comprehensive CI/CD coverage                 |

---

## Quick Reference

### For Contributors

**When you open a PR:**

- `pr-validation-unified.yml` runs automatically
- `ai-code-review.yml` provides AI feedback
- `trunk.yml` checks code quality
- If you modified automation/workflows: additional validation runs

**When you push to main:**

- `optimized-ci.yml` runs (smart path-based checks)
- `unified-ci.yml` builds all Swift projects (if Swift files changed)
- `continuous-validation.yml` validates Swift code (if Swift files changed)
- `create-review-issues.yml` may create issues for review

**Nightly (automatically):**

- 00:00 UTC: Backup cleanup, compression, metrics cleanup
- 01:00 UTC: SwiftLint auto-fixes committed

**Weekly (automatically):**

- Sunday 02:00 UTC: Comprehensive health report

### For Maintainers

**Monitor workflows:**

```bash
gh run list --limit 20
gh run list --status failure --limit 10
```

**Check specific workflow:**

```bash
gh run list --workflow=pr-validation-unified.yml --limit 5
```

**Disable workflow temporarily:**

```bash
gh workflow disable <workflow-name>.yml
```

**View workflow file:**

```bash
cat .github/workflows/<workflow-name>.yml
```

---

## Future Improvements

Potential optimizations (low priority):

1. **Workflow Run Time:** Track and optimize slow workflows
2. **Caching:** Expand caching strategies for faster runs
3. **Matrix Optimization:** Review matrix strategies for efficiency
4. **Alert Tuning:** Fine-tune failure notification thresholds
5. **Documentation:** Add inline documentation to complex workflows

---

## Questions or Issues?

- **Documentation:** See `WORKFLOW_CONSOLIDATION_ANALYSIS_20251006.md`
- **Restoration:** See `archive_20251006/README.md`
- **GitHub Issues:** Create issue with `workflow` label
- **Monitoring:** Check GitHub Actions dashboard

**Last Updated:** October 6, 2025  
**Status:** ✅ Consolidation Phase 1 & 2 Complete  
**Next Review:** October 13, 2025
