# .github/workflows README

## Active Workflows (13 workflows)

Last updated: October 2025 (Post-Optimization)

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

#### optimized-ci.yml ⭐ RE-ENABLED

- **Purpose:** Smart path-based CI with change detection
- **Triggers:** Push/PR to main
- **Runner:** ubuntu-latest
- **Key Features:**
  - Path-based job triggering (automation, shared, projects, docs, workflows)
  - Conditional execution (only runs relevant checks)
  - Concurrency control (cancel-in-progress)
  - Security scanning with Trivy
  - Comprehensive summary report

#### unified-ci.yml ⭐ RE-ENABLED

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

### Pull Request Validation (2 workflows)

#### pr-validation-unified.yml

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

---

### Security & Quality (2 workflows)

#### codeql-analysis.yml ⭐ ENHANCED

- **Purpose:** Comprehensive security analysis (CodeQL + additional scanners)
- **Triggers:** Push/PR to main, Weekly schedule
- **Runner:** ubuntu-latest
- **Key Features:**
  - CodeQL analysis for Swift/JavaScript
  - Bandit (Python security)
  - Safety (dependency vulnerabilities)
  - Trivy (container/binary vulnerabilities)
  - Advanced secrets detection
  - Swift security analysis
  - Comprehensive security reporting

#### test-coverage.yml ⭐ RE-ENABLED

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

#### swiftlint-auto-fix.yml

- **Purpose:** Automatically fix SwiftLint violations
- **Schedule:** Daily at 01:00 UTC
- **Runner:** macos-latest
- **Tasks:**
  - Scan all Swift files
  - Auto-fix violations
  - Commit changes if any

#### weekly-health-check.yml

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

---

## Recently Removed Workflows

**Removed in October 2025 Optimization:**

- `trunk.yml` - Unused Trunk.io integration (user doesn't use Trunk)
- `pr-validation.yml` - Basic PR validation (merged into pr-validation-unified.yml)
- `enhanced-security.yml` - Security scanning (merged into codeql-analysis.yml)

---

## Workflow Consolidation History

### October 2025 - Major Optimization

**Before:** 16 workflows (including disabled)  
**After:** 13 active workflows  
**Reduction:** 3 workflows removed, 3 workflows re-enabled  

**Changes:**

1. ✅ **Removed** `trunk.yml` (unused Trunk.io integration)
2. ✅ **Removed** `pr-validation.yml` (basic checks, redundant with unified)
3. ✅ **Merged** `enhanced-security.yml` into `codeql-analysis.yml`
4. ✅ **Re-enabled** `optimized-ci.yml` (valuable conditional CI)
5. ✅ **Re-enabled** `unified-ci.yml` (comprehensive project builds)
6. ✅ **Re-enabled** `test-coverage.yml` (test coverage tracking)

**Impact:**

- Single comprehensive security workflow
- Eliminated redundant PR validation
- Restored valuable CI/CD functionality
- Improved workflow efficiency
- Better organization and maintainability

**Benefits:**

- ✅ Reduced workflow complexity (13 vs 16+)
- ✅ Enhanced security scanning coverage
- ✅ Restored comprehensive CI/CD capabilities
- ✅ Eliminated unused components
- ✅ Improved performance with conditional execution
