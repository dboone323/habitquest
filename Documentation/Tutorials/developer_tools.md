# Developer Tools and Automation

Learn to use the powerful automation and development tools included in Quantum-workspace.

## Master Automation System

The heart of the development workflow is the master automation script:

```bash
./Tools/Automation/master_automation.sh
```

### Available Commands

```bash
# Check environment and tool availability
./Tools/Automation/master_automation.sh status

# List all projects
./Tools/Automation/master_automation.sh list

# Run automation for specific project
./Tools/Automation/master_automation.sh run CodingReviewer

# Run automation for all projects (comprehensive)
./Tools/Automation/master_automation.sh all
```

### What Automation Does

For each project, automation performs:

1. **Code Quality Checks**
   - SwiftLint for style violations
   - SwiftFormat for code formatting
   - Custom validation rules

2. **Build Verification**
   - Clean build for all targets
   - Test execution
   - Coverage analysis

3. **Documentation Generation**
   - API documentation updates
   - Example code validation

4. **Security Scanning**
   - Dependency vulnerability checks
   - Code security analysis

## Code Quality Tools

### SwiftFormat

Formats Swift code according to project standards:

```bash
# Format all Swift files
swiftformat .

# Format specific file
swiftformat MyFile.swift

# Check formatting without changes
swiftformat --lint .
```

### SwiftLint

Enforces coding standards and catches potential issues:

```bash
# Lint all files
swiftlint

# Lint with strict rules
swiftlint --strict

# Lint specific file
swiftlint MyFile.swift

# Auto-correct fixable issues
swiftlint --fix
```

### Custom Validation

Project-specific validation rules:

```bash
# Run custom validation
./Tools/Automation/validate_custom_rules.sh

# Validate specific project
./Tools/Automation/validate_custom_rules.sh CodingReviewer
```

## Testing Tools

### Unit Test Execution

```bash
# Run all tests
xcodebuild test -project Project.xcodeproj -scheme Project

# Run specific test class
xcodebuild test -project Project.xcodeproj -scheme Project -only-testing:TestClass

# Run with code coverage
xcodebuild test -project Project.xcodeproj -scheme Project -enableCodeCoverage YES
```

### Test Coverage Analysis

```bash
# Generate coverage report
xcodebuild test -project Project.xcodeproj -scheme Project -enableCodeCoverage YES

# View coverage in Xcode
# Xcode → Report Navigator → Coverage
```

### Integration Testing

```bash
# Run integration tests
./Tools/Automation/run_integration_tests.sh

# Test specific components
./Tools/Automation/run_integration_tests.sh --component services
```

## Documentation Tools

### API Documentation Generation

```bash
# Generate API docs for all projects
./Projects/scripts/gen_docs.sh

# Generate docs for specific project
./Projects/scripts/gen_docs.sh --project CodingReviewer
```

### Documentation Validation

```bash
# Check documentation completeness
./Tools/Automation/validate_documentation.sh

# Validate API examples
./Tools/Automation/validate_examples.sh
```

## Performance Monitoring

### Build Performance Tracking

```bash
# Monitor build times
./Tools/Automation/monitor_build_performance.sh

# Generate performance report
./Tools/Automation/generate_performance_report.sh
```

### Runtime Performance Analysis

```bash
# Profile application performance
# Xcode → Product → Profile
# Choose "Time Profiler" instrument
```

## Debugging Tools

### Logging Configuration

```swift
import Dependencies

// Configure logging level
Dependencies.logger.logLevel = .debug

// Log messages
Dependencies.logger.info("Application started")
Dependencies.logger.error("Failed to load data: \(error)")
```

### Error Handling

```swift
do {
    try await performOperation()
} catch let error as CodingReviewerError {
    // Handle specific errors
    switch error {
    case .networkError:
        showNetworkError()
    case .validationError:
        showValidationError()
    }
} catch {
    // Handle unexpected errors
    showGenericError(error)
}
```

## CI/CD Integration

### Local CI Pipeline

```bash
# Run local CI pipeline
./Projects/scripts/ci.sh

# Run specific CI checks
./Projects/scripts/ci.sh --check lint
./Projects/scripts/ci.sh --check test
./Projects/scripts/ci.sh --check build
```

### GitHub Actions Integration

The repository includes GitHub Actions workflows:

- `pr-validation.yml`: Basic PR validation
- `validate-and-lint-pr.yml`: Comprehensive validation
- `quantum-agent-self-heal.yml`: AI-powered fixes

## Custom Tool Development

### Creating New Automation Scripts

```bash
#!/bin/bash
set -euo pipefail

# Template for new automation scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/shared_functions.sh"

log_info "Starting custom automation..."

# Your automation logic here

log_success "Custom automation completed"
```

### Adding Custom Validation Rules

```bash
# Add to quality-config.yaml
custom_rules:
  - name: "API Key Check"
    pattern: "API_KEY.*=.*['\"][^'\"]*['\"]"
    severity: critical
    message: "Hardcoded API keys detected"

  - name: "Force Unwrap Check"
    pattern: "\\w+!"
    severity: warning
    message: "Force unwrap detected, consider optional binding"
```

## Advanced Usage

### Parallel Processing

```bash
# Run automation in parallel for faster execution
./Tools/Automation/master_automation.sh all --parallel

# Limit parallel jobs
./Tools/Automation/master_automation.sh all --parallel --jobs 4
```

### Custom Build Configurations

```bash
# Build with custom configuration
xcodebuild -project Project.xcodeproj -scheme Project -configuration CustomConfig

# Build for multiple destinations
xcodebuild -project Project.xcodeproj -scheme Project \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  -destination 'platform=iOS,name=My iPhone'
```

### Environment-Specific Builds

```bash
# Development build
./Tools/Automation/build.sh --environment development

# Staging build
./Tools/Automation/build.sh --environment staging

# Production build
./Tools/Automation/build.sh --environment production
```

## Best Practices

### Development Workflow

1. **Start with Status Check**
   ```bash
   ./Tools/Automation/master_automation.sh status
   ```

2. **Make Changes Incrementally**
   - Write code
   - Run tests locally
   - Format and lint
   - Commit with clear message

3. **Validate Before Push**
   ```bash
   ./Tools/Automation/master_automation.sh run YourProject
   ```

4. **Monitor Performance**
   - Keep build times under 120 seconds
   - Maintain 70%+ code coverage
   - Fix linting issues promptly

### Code Quality Standards

- **Naming**: Use descriptive, specific names
- **Documentation**: Document public APIs and complex logic
- **Testing**: Write tests for new features and bug fixes
- **Performance**: Profile and optimize critical paths
- **Security**: Follow secure coding practices

### Troubleshooting Automation

**Script fails with permission denied**
```bash
chmod +x Tools/Automation/master_automation.sh
```

**Tools not found**
```bash
# Install missing tools
brew install swiftlint swiftformat
```

**Build timeouts**
```bash
# Increase timeout or optimize build
export BUILD_TIMEOUT=300
```

---

*Master these tools to become a Quantum-workspace power user!*
