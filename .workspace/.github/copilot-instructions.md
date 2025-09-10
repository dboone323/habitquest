# Copilot Instructions for Quantum-workspace

## Repository Overview

This is a **Unified Code Architecture** workspace containing multiple Swift projects consolidated for maximum code reuse and automation efficiency. The repository contains 5 projects with ~400+ Swift files, extensive automation tooling, and AI-powered self-healing workflows.

**Key Projects:**

- **CodingReviewer**: 132 Swift files - Code review application (macOS)
- **PlannerApp**: 57 Swift files - Planning and organization app with CloudKit integration (macOS, iOS)
- **AvoidObstaclesGame**: 8 Swift files - SpriteKit-based game (iOS)
- **MomentumFinance**: Finance tracking app (macOS, iOS)
- **HabitQuest**: Habit tracking application (iOS)

**Languages & Frameworks:** Swift (primary), SwiftUI, UIKit, SpriteKit, CloudKit, Python (automation), Shell scripts, GitHub Actions

## Build Instructions & Dependencies

### Required Tools

**CRITICAL**: The following tools are expected but may not be installed in all environments:

```bash
# Check tool availability first
brew install swiftlint swiftformat
# Or install via other package managers as needed
```

### Master Automation System

The repository uses a centralized automation controller at `Tools/Automation/master_automation.sh`:

```bash
# ALWAYS start with status check to verify environment
./Tools/Automation/master_automation.sh status

# List all available projects
./Tools/Automation/master_automation.sh list

# Run automation for specific project
./Tools/Automation/master_automation.sh run CodingReviewer

# Run automation for all projects (CAUTION: time-intensive)
./Tools/Automation/master_automation.sh all
```

**⚠️ Common Issues:**

- If SwiftLint/SwiftFormat are missing, install them before running automation
- The `status` command shows which tools are available vs missing
- Automation may fail if run on non-macOS systems (Xcode dependency)
- Some commands require 2-5 minutes to complete

### Individual Project Builds

Each project has its own Xcode project file:

- `Projects/CodingReviewer/CodingReviewer.xcodeproj` (macOS)
- `Projects/AvoidObstaclesGame/AvoidObstaclesGame.xcodeproj` (iOS)
- `Projects/PlannerApp/PlannerApp.xcodeproj` (macOS, iOS)
- `Projects/MomentumFinance/` (macOS, iOS) - _Project structure TBD_
- `Projects/HabitQuest/` (iOS) - _Project structure TBD_

**Build Process:**

1. Open individual `.xcodeproj` files in Xcode on macOS
2. Each project includes its own SwiftLint configuration (`.swiftlint.yml`)
3. SwiftFormat rules are defined in root `.swiftformat` file
4. Quality gates defined in `quality-config.yaml` with coverage targets (70-85%)

### Testing

```bash
# Individual project test scripts exist, example:
./Projects/AvoidObstaclesGame/test_game.sh

# Integration tests via automation
./Tools/Automation/run_integration_tests.sh
```

## Project Architecture & Layout

### Directory Structure

```
/
├── Projects/                   # Individual applications
│   ├── CodingReviewer/        # Main code review app (132 Swift files) - macOS
│   ├── AvoidObstaclesGame/    # Game project (8 Swift files) - iOS
│   ├── PlannerApp/            # Planning app (57 Swift files) - macOS, iOS
│   ├── MomentumFinance/       # Finance app - macOS, iOS
│   └── HabitQuest/            # Habit tracking app - iOS
├── Shared/                    # Reusable components across projects
│   ├── SharedArchitecture.swift  # BaseViewModel protocol & MVVM patterns
│   ├── Testing/               # Shared testing utilities
│   └── Utilities/             # Helper functions and extensions
├── Tools/                     # Development tools and automation
│   └── Automation/            # Master automation system (600+ files)
├── .github/workflows/         # CI/CD pipelines
├── Documentation/             # Extensive project documentation
└── Configuration files:
    ├── .swiftformat           # Code formatting rules
    ├── quality-config.yaml    # Quality gates and metrics
    └── cspell.json           # Spell checking configuration
```

### Code Architecture Principles

**CRITICAL RULES** (from ARCHITECTURE.md):

1. **Data models NEVER import SwiftUI** - keeps them in `SharedTypes/` folder
2. **Avoid Codable in complex data models** - causes circular dependencies
3. **Use synchronous operations with background queues** - not async/await everywhere
4. **Specific naming over generic** - avoid "Dashboard", "Manager" names
5. **Sendable for thread safety** - prefer over complex async patterns

**Shared Architecture Pattern:**

```swift
// All projects follow this BaseViewModel pattern
@MainActor
protocol BaseViewModel: ObservableObject {
    associatedtype State
    associatedtype Action
    var state: State { get set }
    var isLoading: Bool { get set }
    func handle(_ action: Action)
}
```

## CI/CD & Validation

### GitHub Workflows

1. **pr-validation.yml**: Basic sanity checks for all PRs
2. **validate-and-lint-pr.yml**: Validates automation scripts, runs ShellCheck
3. **quantum-agent-self-heal.yml**: AI-powered self-healing system

### Quality Gates (quality-config.yaml)

- **Code Coverage**: 70% minimum, 85% target
- **Build Performance**: Max 120 seconds
- **Test Performance**: Max 30 seconds
- **File Limits**: Max 500 lines per file, 1000KB file size
- **Complexity**: Max 10 cyclomatic, 15 cognitive complexity

### Pre-commit Validation Steps

```bash
# Validate automation scripts
bash -n Tools/Automation/master_automation.sh

# Run deployment validation
bash Tools/Automation/deploy_workflows_all_projects.sh --validate

# Format code (if tools available)
swiftformat . --config .swiftformat

# Lint code
swiftlint --strict
```

## Common Pitfalls & Solutions

### Environment Issues

- **Problem**: "SwiftLint/SwiftFormat not found"  
  **Solution**: Install via `brew install swiftlint swiftformat` or skip formatting
- **Problem**: Automation scripts fail on Linux/Windows  
  **Solution**: Many scripts expect macOS/Xcode - check `status` command first

- **Problem**: Build timeouts  
  **Solution**: Some operations take 2-5 minutes - increase timeout limits

### Architecture Issues

- **Problem**: SwiftUI import errors in data models  
  **Solution**: Keep pure data models in `SharedTypes/`, UI extensions in `Extensions/`
- **Problem**: Circular dependency errors  
  **Solution**: Avoid `Codable` in complex nested types, use separate DTOs

- **Problem**: Concurrency crashes  
  **Solution**: Use `Sendable` types and background queues with MainActor updates

## Development Workflow

### Making Changes

1. **Always check automation status first**: `./Tools/Automation/master_automation.sh status`
2. **Use VSCode workspace**: Open `Code.code-workspace` for unified development
3. **Follow architecture principles**: No SwiftUI in data models, specific naming
4. **Test incrementally**: Use project-specific automation before full builds
5. **Validate before commit**: Run validation scripts in `.github/workflows/`

### File Locations for Common Tasks

- **Add shared UI components**: `Shared/` directory
- **Project-specific code**: `Projects/{ProjectName}/`
- **Automation enhancements**: `Tools/Automation/`
- **Workflow modifications**: `.github/workflows/`
- **Documentation updates**: `Documentation/`

### Performance Considerations

- Full automation can take 5-10 minutes across all projects
- Individual project automation typically completes in 1-2 minutes
- Quality gate validation adds 30-60 seconds to build time
- SwiftLint with `--strict` flag may have higher failure rates

---

**Trust these instructions first** - only search/explore if information is incomplete or found to be incorrect. The automation system is complex but well-documented; follow the established patterns rather than creating new approaches.
