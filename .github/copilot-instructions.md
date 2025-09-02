# Copilot Instructions for Quantum-workspace

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Repository Overview

This is a **Unified Code Architecture** workspace containing multiple iOS Swift projects consolidated for maximum code reuse and automation efficiency. The repository contains 6 iOS projects with ~200+ Swift files, extensive automation tooling, and AI-powered self-healing workflows.

**Key Projects:**
- **CodingReviewer**: 132+ Swift files - Code review application
- **PlannerApp**: 57+ Swift files - Planning and organization app with CloudKit integration
- **AvoidObstaclesGame**: 8 Swift files - SpriteKit-based game
- **MomentumFinance**: Finance tracking app
- **HabitQuest**: Habit tracking application
- **Tools**: Development and automation utilities

**Languages & Frameworks:** Swift (primary), SwiftUI, UIKit, SpriteKit, CloudKit, Python (automation), Shell scripts, GitHub Actions

## Working Effectively in This Repository

### Bootstrap, Build, and Test the Repository

**CRITICAL - Environment Dependencies:**
- **macOS Required**: Full functionality requires macOS with Xcode for iOS builds
- **Linux/Windows**: Limited functionality - can run automation scripts but cannot build iOS projects
- **Tool Installation**: SwiftLint and SwiftFormat required for full automation

```bash
# ALWAYS start with environment check
./Tools/Automation/master_automation.sh status

# This shows available tools:
# ✅ Swift Compiler (available on Linux/macOS)
# ❌ Xcode Build System (macOS only)
# ❌ SwiftLint (must install separately)
# ❌ SwiftFormat (must install separately)
```

**On macOS - Full Setup:**
```bash
# Install required tools
brew install swiftlint swiftformat

# Verify environment
./Tools/Automation/master_automation.sh status

# Run full automation (NEVER CANCEL: Takes 5-10 minutes)
timeout 900 ./Tools/Automation/master_automation.sh all
```

**On Linux/Windows - Limited Setup:**
```bash
# Check what's available (no Xcode, limited functionality)
./Tools/Automation/master_automation.sh status

# List projects (works on all platforms)
./Tools/Automation/master_automation.sh list

# Individual project automation (may fail without Xcode)
./Tools/Automation/master_automation.sh run AvoidObstaclesGame
```

### Build & Test Individual Projects

**NEVER CANCEL: Build operations may take 2-5 minutes per project. Always set timeouts of 600+ seconds.**

```bash
# Build specific project via Xcode (macOS only)
cd Projects/CodingReviewer
open CodingReviewer.xcodeproj
# In Xcode: ⌘+B (Build), ⌘+R (Run), ⌘+U (Test)

# Build via command line (macOS only)
cd Projects/CodingReviewer  
xcodebuild -project CodingReviewer.xcodeproj -scheme CodingReviewer -destination 'platform=macOS' build

# Run project-specific tests (NEVER CANCEL: May take 2-5 minutes)
cd Projects/AvoidObstaclesGame
timeout 300 ./test_game.sh

# Run automation for individual project
timeout 300 ./Tools/Automation/master_automation.sh run CodingReviewer
```

### Validation & Quality Checks

```bash
# ALWAYS run these before committing (each takes 30-60 seconds)
timeout 120 bash -n Tools/Automation/master_automation.sh

# Format code (if tools available - will fail if not installed)
swiftformat . --config .swiftformat || echo "SwiftFormat not available"

# Lint code (if tools available - will fail if not installed) 
swiftlint --strict || echo "SwiftLint not available"

# Check quality gates compliance
cat quality-config.yaml  # Review coverage targets: 70-85%
```

## Project Architecture & Layout

### Directory Structure
```
/
├── Projects/                   # Individual iOS applications
│   ├── CodingReviewer/        # Main code review app (132 Swift files)
│   ├── AvoidObstaclesGame/    # Game project (8 Swift files)
│   ├── PlannerApp/            # Planning app (57 Swift files)
│   ├── MomentumFinance/       # Finance app
│   └── HabitQuest/            # Habit tracking app
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

## Validation & Manual Testing Scenarios

**ALWAYS perform these validation steps after making changes:**

### Complete Build Validation
```bash
# NEVER CANCEL: Full validation takes 10-15 minutes
timeout 1200 ./Tools/Automation/master_automation.sh all

# Check build success for key projects (macOS only)
cd Projects/CodingReviewer
timeout 600 xcodebuild -project CodingReviewer.xcodeproj -scheme CodingReviewer -destination 'platform=macOS' build

cd ../AvoidObstaclesGame  
timeout 600 xcodebuild -project AvoidObstaclesGame.xcodeproj -scheme AvoidObstaclesGame -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Functional Testing Scenarios  
**CRITICAL**: After code changes, ALWAYS test these user scenarios:

#### CodingReviewer App Testing
```bash
# 1. Open in Xcode and run (macOS only)
cd Projects/CodingReviewer
open CodingReviewer.xcodeproj
# In Xcode: ⌘+R to run
# Test: Load sample Swift code, run analysis, verify quantum analysis tab appears
```

#### AvoidObstaclesGame Testing  
```bash
# 1. Run automated test suite (NEVER CANCEL: Takes 2-3 minutes)
cd Projects/AvoidObstaclesGame
timeout 300 ./test_game.sh

# 2. Manual validation in simulator:
# - Game starts without crashes
# - High score tracking works (top 10 scores)
# - Progressive difficulty increases
# - Level indicators display correctly
```

#### Architecture Compliance Testing
```bash
# Verify no SwiftUI imports in data models
grep -r "import SwiftUI" Projects/*/SharedTypes/ && echo "ERROR: SwiftUI in data models" || echo "✅ Clean data models"

# Check for forbidden Codable usage in complex types
grep -r ": Codable" Projects/ --include="*.swift" | grep -v "Simple\|DTO" && echo "WARNING: Complex Codable usage"

# Validate Sendable compliance
grep -r "Sendable" Projects/ --include="*.swift" | head -5
```

## Troubleshooting Guide

### Environment Issues
- **Problem**: "SwiftLint/SwiftFormat not found"  
  **Solution**: `brew install swiftlint swiftformat` on macOS, or skip formatting commands
  **Test**: Run `./Tools/Automation/master_automation.sh status` to check tool availability
  
- **Problem**: Automation scripts fail on Linux/Windows  
  **Solution**: Many scripts expect macOS/Xcode - use `status` command to see limitations
  **Workaround**: Use individual commands like `bash -n` for syntax checking
  
- **Problem**: Build timeouts or hanging commands
  **Solution**: Set appropriate timeouts - builds take 2-5 minutes, full automation 5-15 minutes
  **Never cancel**: Long-running operations are normal in this large codebase

### Architecture Issues  
- **Problem**: SwiftUI import errors in data models  
  **Solution**: Keep pure data models in `SharedTypes/`, UI extensions in `Extensions/`
  **Test**: `grep -r "import SwiftUI" Projects/*/SharedTypes/` should return no results
  
- **Problem**: Circular dependency errors  
  **Solution**: Avoid `Codable` in complex nested types, use separate DTOs
  **Check**: Look for complex `Codable` conformances that might cause issues

- **Problem**: Concurrency crashes  
  **Solution**: Use `Sendable` types and background queues with MainActor updates
  **Pattern**: Follow the BaseViewModel pattern shown in architecture section

### Build Failures
- **Problem**: Xcode project won't open or build fails
  **Solution**: Clean derived data, restart Xcode, check for missing dependencies
  **Command**: `xcodebuild clean -project Project.xcodeproj` 
  
- **Problem**: Test failures  
  **Solution**: Check individual test scripts like `./Projects/AvoidObstaclesGame/test_game.sh`
  **Note**: Test scripts may require simulators or specific device configurations

### File Locations for Common Tasks
- **Add shared UI components**: `Shared/` directory  
- **Project-specific code**: `Projects/{ProjectName}/`
- **Automation enhancements**: `Tools/Automation/`
- **Workflow modifications**: `.github/workflows/`
- **Documentation updates**: `Documentation/`
- **Quality configuration**: `quality-config.yaml`
- **Code formatting rules**: `.swiftformat`
- **Linting configuration**: `Projects/{ProjectName}/.swiftlint.yml`

## Common Tasks & Frequent Commands

### Environment Setup & Status
```bash
# Check current repository state  
./Tools/Automation/master_automation.sh status
./Tools/Automation/master_automation.sh list

# Open unified development workspace
code Code.code-workspace

# Count Swift files across all projects
find Projects/ -name "*.swift" | wc -l  # Should show ~200 files
```

### Daily Development Workflow
```bash
# 1. Start work session - check status
./Tools/Automation/master_automation.sh status

# 2. Work on specific project
cd Projects/CodingReviewer  # or AvoidObstaclesGame, PlannerApp
open CodingReviewer.xcodeproj  # Opens in Xcode (macOS only)

# 3. Before committing - validate changes
timeout 300 ./Tools/Automation/master_automation.sh run CodingReviewer
timeout 120 bash -n Tools/Automation/master_automation.sh

# 4. Optional: Format and lint (if tools available)
swiftformat . --config .swiftformat || echo "SwiftFormat not available"
swiftlint --strict || echo "SwiftLint not available"
```

### Project Structure Quick Reference
```
# View project directory structure
ls -la Projects/
# Shows: AvoidObstaclesGame, CodingReviewer, HabitQuest, MomentumFinance, PlannerApp, Tools

# Check individual project Swift file counts  
find Projects/CodingReviewer -name "*.swift" | wc -l      # ~132 files
find Projects/PlannerApp -name "*.swift" | wc -l          # ~57 files  
find Projects/AvoidObstaclesGame -name "*.swift" | wc -l   # ~8 files

# View automation and configuration files
ls -la .swiftformat quality-config.yaml cspell.json
ls -la .github/workflows/
```

## Performance Expectations & Timeouts

**CRITICAL TIMING INFORMATION** - NEVER CANCEL these operations:

### Expected Command Durations
- **Environment status check**: < 5 seconds
- **Individual project automation**: 1-3 minutes (set timeout: 300s)
- **Full automation (`all` command)**: 5-15 minutes (set timeout: 1200s)
- **Individual Xcode builds**: 2-5 minutes (set timeout: 600s)  
- **Test suite execution**: 2-5 minutes per project (set timeout: 300s)
- **SwiftLint validation**: 30-90 seconds (set timeout: 120s)
- **SwiftFormat execution**: 10-30 seconds (set timeout: 60s)

### Quality Gates & CI/CD

#### GitHub Workflows
1. **pr-validation.yml**: Basic sanity checks for all PRs
2. **validate-and-lint-pr.yml**: Validates automation scripts, runs ShellCheck  
3. **quantum-agent-self-heal.yml**: AI-powered self-healing system

#### Quality Targets (quality-config.yaml)
- **Code Coverage**: 70% minimum, 85% target
- **Build Performance**: Max 120 seconds (individual builds)
- **Test Performance**: Max 30 seconds (unit test suites)
- **File Limits**: Max 500 lines per file, 1000KB file size  
- **Complexity**: Max 10 cyclomatic, 15 cognitive complexity

---

**Trust these instructions first** - only search/explore if information is incomplete or found to be incorrect. The automation system is complex but well-documented; follow the established patterns rather than creating new approaches.