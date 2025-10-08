# Continuous Validation System

## Overview

The Continuous Validation System provides automated code quality checks integrated with the MCP automation stack. It runs SwiftLint, SwiftFormat, and build validation on Swift projects, generating reports and publishing alerts to the MCP dashboard.

## Components

### 1. continuous_validation.sh

**Location:** `Tools/Automation/continuous_validation.sh`

**Purpose:** Core validation script that runs lint, format, and build checks on projects.

**Usage:**

```bash
# Validate a specific project
./Tools/Automation/continuous_validation.sh validate CodingReviewer

# Validate all projects
./Tools/Automation/continuous_validation.sh all

# Watch mode (auto-validate on file changes)
./Tools/Automation/continuous_validation.sh watch

# View recent validation reports
./Tools/Automation/continuous_validation.sh report
```

**Features:**

- SwiftLint integration with error/warning counting
- SwiftFormat verification
- Build validation using consolidated_build.sh or xcodebuild
- JSON report generation
- MCP alert publishing
- Watch mode using fswatch

### 2. VS Code Tasks

**Location:** `.vscode/tasks.json`

**Available Tasks:**

- **Validate Current Project** - Interactive project selection
- **Validate All Projects** - Runs validation on all projects
- **Watch for Changes (Auto-validate)** - Background watch mode
- **View Validation Reports** - Display recent reports

**Usage:**

1. Press `Cmd+Shift+P` (macOS)
2. Type "Tasks: Run Task"
3. Select the validation task you want

### 3. CI/CD Integration

**Location:** `.github/workflows/continuous-validation.yml`

**Triggers:**

- Push to main/develop branches (Swift file changes)
- Pull requests (Swift file changes)
- Manual workflow dispatch

**Jobs:**

- **validate** - Runs validation checks on changed code
- **publish-results** - Publishes reports to MCP dashboard

**Artifacts:**

- Validation reports retained for 30 days
- Uploaded as workflow artifacts

## Validation Process

### Checks Performed

1. **SwiftLint**

   - Runs on all Swift files in project
   - Counts errors and warnings
   - Status: passed/failed based on error count
   - Configurable via `.swiftlint.yml` in project directory

2. **SwiftFormat**

   - Verifies code formatting compliance
   - Uses `--lint` mode (read-only)
   - Status: passed/needs_formatting/skipped
   - Configuration: `.swiftformat` in workspace root

3. **Build Validation**
   - Attempts full build via `consolidated_build.sh` if available
   - Falls back to quick xcodebuild compile check
   - Timeout: 180 seconds per project
   - Status: passed/failed/no_project/skipped

### Report Format

Reports are saved to `validation_reports/` as JSON:

```json
{
  "project": "CodingReviewer",
  "timestamp": "2025-10-05T23:51:45Z",
  "overall_status": "failed",
  "checks": {
    "lint": {
      "status": "failed",
      "warnings": 821,
      "errors": 18
    },
    "format": {
      "status": "passed"
    },
    "build": {
      "status": "failed"
    }
  }
}
```

**Overall Status Logic:**

- `failed` - If lint or build failed
- `warning` - If format needs updating
- `passed` - All checks passed

## MCP Integration

### Alert Publishing

Validation reports are automatically published to the MCP server at `http://localhost:5005/alerts` via POST request.

**Alert Structure:**

- Contains full validation report JSON
- Timestamped for tracking
- Available via MCP dashboard
- Persists to `Shared/AutomationState/alerts.json`

### Dashboard Visibility

The MCP dashboard displays validation alerts with:

- Project name
- Overall status (color-coded)
- Individual check results
- Error/warning counts
- Timestamp

## Watch Mode

### Setup

Watch mode uses `fswatch` to monitor Swift files for changes:

```bash
# Install fswatch (if not already installed)
brew install fswatch

# Start watch mode
./Tools/Automation/continuous_validation.sh watch
```

### Behavior

- Monitors `Projects/` and `Shared/` directories
- Triggers validation on Swift file changes
- Debounced to prevent rapid re-runs
- Runs in background, can be cancelled with Ctrl+C

### Configuration

Watch mode settings in `continuous_validation.sh`:

```bash
WATCH_PATHS="Projects Shared"  # Directories to monitor
WATCH_EXTENSIONS="*.swift"     # File patterns to watch
```

## Integration with consolidated_build.sh

The validation system integrates with `Projects/scripts/consolidated_build.sh` for comprehensive build validation:

**Benefits:**

- Multi-platform build validation (iOS + macOS)
- Detailed build metadata
- Consistent with existing build pipeline
- JSON output for parsing

**Fallback:**
If `consolidated_build.sh` is not available, validation falls back to quick `xcodebuild` compile check.

## Troubleshooting

### Common Issues

**1. SwiftLint not found**

```bash
# Install SwiftLint
brew install swiftlint

# Or disable in validation script
export SKIP_LINT=1
```

**2. Build timeouts**

```bash
# Increase timeout in continuous_validation.sh
# Default: 180 seconds
timeout 300 xcodebuild ...
```

**3. MCP server not responding**

```bash
# Check if MCP server is running
curl http://localhost:5005/status

# Start MCP server
python3 Tools/Automation/mcp_server.py &
```

**4. Watch mode not triggering**

```bash
# Verify fswatch is installed
which fswatch

# Check fswatch is monitoring correctly
fswatch -v Projects/ Shared/
```

### Validation Report Location

Reports are saved to:

```
validation_reports/
├── CodingReviewer_validation_20251005_185143.json
├── PlannerApp_validation_20251005_190234.json
└── ...
```

### Logs

Validation script outputs to stdout with colored status indicators:

- 🔵 **[AI-AUTOMATION]** - Info messages
- 🟢 **[AI-SUCCESS]** - Success messages
- 🟡 **[AI-WARNING]** - Warning messages
- 🔴 **[AI-ERROR]** - Error messages

## Configuration

### Environment Variables

```bash
# MCP server URL (default: http://localhost:5005)
export MCP_URL="http://localhost:5005"

# Skip specific checks
export SKIP_LINT=1
export SKIP_FORMAT=1
export SKIP_BUILD=1

# Custom report directory
export VALIDATION_REPORT_DIR="/path/to/reports"

# Workspace root (auto-detected)
export WORKSPACE_ROOT="/Users/user/Quantum-workspace"
```

### Quality Gates

Quality thresholds are defined in `quality-config.yaml`:

- Code coverage: 70% minimum, 85% target
- Build performance: Max 120 seconds
- Test performance: Max 30 seconds
- File limits: Max 500 lines, 1000KB size
- Complexity: Max 10 cyclomatic, 15 cognitive

## Best Practices

1. **Run validation before commits**

   ```bash
   ./Tools/Automation/continuous_validation.sh validate <project>
   ```

2. **Use watch mode during development**

   ```bash
   ./Tools/Automation/continuous_validation.sh watch
   ```

3. **Review validation reports**

   ```bash
   ./Tools/Automation/continuous_validation.sh report
   ```

4. **Address errors before warnings**

   - Fix build errors first
   - Then SwiftLint errors
   - Finally format issues and warnings

5. **Check CI validation status**
   - Review local Ollama CI/CD results: `./Tools/local_ci_cd.sh report`
   - Check validation logs in `Tools/local_ci_logs/`
   - Fix issues identified in local CI runs

## Future Enhancements

- [ ] Code coverage integration
- [ ] Performance regression detection
- [ ] Automated fix suggestions
- [ ] Slack/email notifications
- [ ] Historical trend analysis
- [ ] Custom validation rules per project
- [ ] Integration with git hooks (pre-commit)

## Related Documentation

- [Master Automation README](../Tools/Automation/README.md)
- [MCP Integration Guide](OA_Implementation_Summary.md)
- [Quality Configuration](../quality-config.yaml)
- [Architecture Guidelines](../ARCHITECTURE.md)
