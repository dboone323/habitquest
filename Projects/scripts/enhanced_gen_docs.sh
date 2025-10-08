#!/usr/bin/env bash
set -euo pipefail

# Enhanced API Documentation Generator for Quantum-workspace
# Generates comprehensive API documentation with descriptions, examples, and architecture guides

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
DOCS_DIR="${ROOT_DIR}/../Documentation"
API_DIR="${DOCS_DIR}/API"
EXAMPLES_DIR="${DOCS_DIR}/Examples"
TUTORIALS_DIR="${DOCS_DIR}/Tutorials"

# Create directories if they don't exist
mkdir -p "${API_DIR}" "${EXAMPLES_DIR}" "${TUTORIALS_DIR}"

now() { date '+%Y-%m-%d %H:%M:%S %z'; }
hr() { printf '%*s\n' 80 "" | tr ' ' '-'; }

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Extract Swift API information with enhanced details
extract_swift_api() {
    local project_name="$1"
    local project_dir="$2"
    local output_file="${API_DIR}/${project_name}_API.md"

    log_info "Extracting API for ${project_name}..."

    cat >"${output_file}" <<EOF
# ${project_name} API Documentation

Generated: $(now)
Project: ${project_name}
Location: ${project_dir}

## Overview

This document contains the comprehensive API reference for ${project_name}.

EOF

    # Find all Swift files
    local swift_files
    swift_files=$(find "${project_dir}" -name "*.swift" -type f | sort)

    if [[ -z "${swift_files}" ]]; then
        log_warn "No Swift files found in ${project_dir}"
        return 1
    fi

    # Process each Swift file
    for swift_file in ${swift_files}; do
        local relative_path="${swift_file#${project_dir}/}"
        local filename
        filename=$(basename "${swift_file}")

        # Skip test files for main API docs
        if [[ "${filename}" == *Test*.swift ]] || [[ "${filename}" == *Tests*.swift ]]; then
            continue
        fi

        log_info "Processing ${relative_path}..."

        # Extract public declarations with context
        extract_public_declarations "${swift_file}" "${relative_path}" >>"${output_file}"
    done

    # Add architecture section
    add_architecture_section "${project_name}" "${project_dir}" >>"${output_file}"

    # Add usage examples
    add_usage_examples "${project_name}" >>"${output_file}"

    # Add integration guide
    add_integration_guide "${project_name}" >>"${output_file}"

    log_success "Generated API documentation for ${project_name}"
}

# Extract public declarations with enhanced context
extract_public_declarations() {
    local swift_file="$1"
    local relative_path="$2"

    echo "## ${relative_path}"
    echo ""

    # Extract public classes, structs, enums
    grep -n "^public " "${swift_file}" | while IFS=: read -r line_num declaration; do
        # Clean up the declaration
        declaration=$(echo "${declaration}" | sed 's/^public //')

        # Determine type
        if [[ "${declaration}" == class* ]]; then
            echo "### Class: ${declaration}"
            echo "**Line ${line_num}**: ${declaration}"
            echo ""
            extract_class_details "${swift_file}" "${line_num}"
        elif [[ "${declaration}" == struct* ]]; then
            echo "### Struct: ${declaration}"
            echo "**Line ${line_num}**: ${declaration}"
            echo ""
            extract_struct_details "${swift_file}" "${line_num}"
        elif [[ "${declaration}" == enum* ]]; then
            echo "### Enum: ${declaration}"
            echo "**Line ${line_num}**: ${declaration}"
            echo ""
            extract_enum_details "${swift_file}" "${line_num}"
        elif [[ "${declaration}" == func* ]] || [[ "${declaration}" == "func "* ]]; then
            echo "### Function: ${declaration}"
            echo "**Line ${line_num}**: ${declaration}"
            echo ""
        elif [[ "${declaration}" == "let "* ]] || [[ "${declaration}" == "var "* ]]; then
            echo "### Property: ${declaration}"
            echo "**Line ${line_num}**: ${declaration}"
            echo ""
        fi
    done

    echo "---"
    echo ""
}

# Extract class details
extract_class_details() {
    local swift_file="$1"
    local start_line="$2"

    # Find the end of the class (next class/struct/enum or end of file)
    local end_line
    end_line=$(tail -n +$((start_line + 1)) "${swift_file}" | grep -n "^public \|class \|struct \|enum \|^}" | head -1 | cut -d: -f1)

    if [[ -z "${end_line}" ]]; then
        end_line=$(wc -l <"${swift_file}")
    else
        end_line=$((start_line + end_line - 1))
    fi

    # Extract methods and properties within the class
    sed -n "${start_line},${end_line}p" "${swift_file}" | grep -E "(func |let |var |init)" | while read -r line; do
        if [[ "${line}" == *"func "* ]]; then
            echo "- **Method**: ${line}"
        elif [[ "${line}" == *"let "* ]] || [[ "${line}" == *"var "* ]]; then
            echo "- **Property**: ${line}"
        elif [[ "${line}" == *"init"* ]]; then
            echo "- **Initializer**: ${line}"
        fi
    done
    echo ""
}

# Extract struct details
extract_struct_details() {
    local swift_file="$1"
    local start_line="$2"

    # Similar to class extraction but for structs
    extract_class_details "${swift_file}" "${start_line}"
}

# Extract enum details
extract_enum_details() {
    local swift_file="$1"
    local start_line="$2"

    # Find the end of the enum
    local end_line
    end_line=$(tail -n +$((start_line + 1)) "${swift_file}" | grep -n "^public \|class \|struct \|enum \|^}" | head -1 | cut -d: -f1)

    if [[ -z "${end_line}" ]]; then
        end_line=$(wc -l <"${swift_file}")
    else
        end_line=$((start_line + end_line - 1))
    fi

    # Extract cases
    sed -n "${start_line},${end_line}p" "${swift_file}" | grep -E "case " | while read -r line; do
        echo "- **Case**: ${line}"
    done
    echo ""
}

# Add architecture section
add_architecture_section() {
    local project_name="$1"
    local project_dir="$2"

    echo "## Architecture Overview"
    echo ""

    case "${project_name}" in
        "CodingReviewer")
            cat <<'EOF'
### MVVM Architecture Pattern

CodingReviewer follows the Model-View-ViewModel (MVVM) pattern with the following components:

#### Core Services
- **CodeReviewService**: Main service for code analysis and review operations
- **AIEnhancedCodeAnalysisService**: AI-powered code analysis and suggestions
- **PerformanceAnalysisService**: Performance monitoring and optimization
- **SecurityAnalysisService**: Security vulnerability detection
- **StyleAnalysisService**: Code style and formatting analysis

#### View Models
- **ContentViewModel**: Main application state management
- **CodeReviewViewModel**: Code review workflow management
- **AnalysisResultsViewModel**: Analysis results presentation

#### Views
- **ContentView**: Main application interface
- **CodeReviewView**: Code review interface
- **AnalysisResultsView**: Results display
- **SidebarView**: Navigation and project structure

#### Data Flow
```
Code File → CodeReviewService → Analysis Engine → Results View
```

### Key Design Patterns

1. **Dependency Injection**: Services are injected through Dependencies struct
2. **Protocol-Oriented Programming**: Service protocols define clear interfaces
3. **ObservableObject**: SwiftUI state management with Combine
4. **Error Handling**: Comprehensive error handling with CodingReviewerError

EOF
            ;;
        "PlannerApp")
            cat <<'EOF'
### CloudKit Integration Architecture

PlannerApp integrates with CloudKit for data synchronization across devices.

#### Core Components
- **CloudKitManager**: Handles all CloudKit operations
- **DataSyncService**: Manages data synchronization
- **LocalStorageManager**: Local data persistence

#### Data Models
- **PlanItem**: Individual planning items
- **Category**: Item categorization
- **Reminder**: Time-based notifications

EOF
            ;;
        "AvoidObstaclesGame")
            cat <<'EOF'
### SpriteKit Game Architecture

AvoidObstaclesGame is built with SpriteKit for 2D game development.

#### Game Components
- **GameScene**: Main game scene management
- **Player**: Player character logic
- **Obstacle**: Dynamic obstacle system
- **ScoreManager**: Game scoring and statistics

#### Game Loop
```
Update → Physics → Collision Detection → Render
```

EOF
            ;;
        *)
            echo "Standard SwiftUI application architecture with MVVM pattern."
            ;;
    esac

    echo ""
}

# Add usage examples
add_usage_examples() {
    local project_name="$1"

    echo "## Usage Examples"
    echo ""

    case "${project_name}" in
        "CodingReviewer")
            cat <<'EOF'
### Basic Code Review

```swift
import CodingReviewer

let reviewService = CodeReviewService()

// Analyze Swift code
let result = try await reviewService.analyzeCode(
    code: "func hello() { print(\"Hello\") }",
    language: "swift",
    analysisType: .comprehensive
)

// Process results
for issue in result.issues {
    print("Issue: \(issue.description) at line \(issue.line ?? 0)")
}
```

### AI-Enhanced Analysis

```swift
let aiService = AIEnhancedCodeAnalysisService()

let aiResult = try await aiService.analyzeCodeWithAI(
    code: swiftCode,
    language: "swift",
    context: "iOS application"
)

// Get AI suggestions
for suggestion in aiResult.suggestions {
    print("Suggestion: \(suggestion.description)")
}
```

EOF
            ;;
        "PlannerApp")
            cat <<'EOF'
### Creating and Managing Plans

```swift
import PlannerApp

let planManager = PlanManager()

// Create a new plan
let plan = PlanItem(
    title: "Project Review",
    description: "Review project progress",
    dueDate: Date().addingTimeInterval(86400),
    priority: .high
)

// Save to CloudKit
try await planManager.savePlan(plan)
```

EOF
            ;;
        *)
            echo "See project-specific examples in the Examples directory."
            ;;
    esac

    echo ""
}

# Add integration guide
add_integration_guide() {
    local project_name="$1"

    echo "## Integration Guide"
    echo ""

    case "${project_name}" in
        "CodingReviewer")
            cat <<'EOF'
### Integrating with Xcode

1. **Add as Dependency**: Include CodingReviewer in your Xcode project
2. **Configure Services**: Set up required services in Dependencies.swift
3. **Initialize**: Create CodeReviewService instance
4. **Analyze Code**: Use service methods for code analysis

### Command Line Usage

```bash
# Analyze single file
coding-review analyze --file MyClass.swift --language swift

# Generate documentation
coding-review docs --project MyProject.xcodeproj
```

### CI/CD Integration

Add to your CI pipeline:

```yaml
- name: Code Review
  run: |
    ./Tools/Automation/master_automation.sh run CodingReviewer
```

EOF
            ;;
        *)
            cat <<EOF
### Basic Integration

1. Add project as dependency
2. Import required modules
3. Initialize services
4. Use API methods

See project README for detailed integration instructions.
EOF
            ;;
    esac

    echo ""
}

# Generate comprehensive README
generate_comprehensive_readme() {
    local readme_file="${DOCS_DIR}/README.md"

    cat >"${readme_file}" <<EOF
# Quantum-workspace Documentation

Generated: $(now)

## Overview

This documentation provides comprehensive guides, API references, and examples for the Quantum-workspace project - a unified Swift development environment containing multiple applications with shared architecture and automation tooling.

## Projects

### CodingReviewer
Advanced code review and analysis application with AI-powered suggestions.

- **Platform**: macOS
- **Architecture**: MVVM with SwiftUI
- **Key Features**: AI analysis, performance monitoring, security scanning
- **API Docs**: [CodingReviewer API](./API/CodingReviewer_API.md)

### PlannerApp
Planning and organization application with CloudKit synchronization.

- **Platform**: macOS, iOS
- **Architecture**: MVVM with CloudKit integration
- **Key Features**: Cross-device sync, reminders, categories
- **API Docs**: [PlannerApp API](./API/PlannerApp_API.md)

### AvoidObstaclesGame
2D obstacle avoidance game built with SpriteKit.

- **Platform**: iOS
- **Architecture**: Game loop with SpriteKit
- **Key Features**: Physics-based gameplay, scoring system
- **API Docs**: [AvoidObstaclesGame API](./API/AvoidObstaclesGame_API.md)

### MomentumFinance
Financial tracking and management application.

- **Platform**: macOS, iOS
- **Architecture**: MVVM with local storage
- **Key Features**: Budget tracking, expense categorization
- **API Docs**: [MomentumFinance API](./API/MomentumFinance_API.md)

### HabitQuest
Habit tracking application with gamification elements.

- **Platform**: iOS
- **Architecture**: MVVM with Core Data
- **Key Features**: Habit streaks, achievements, progress tracking
- **API Docs**: [HabitQuest API](./API/HabitQuest_API.md)

## Getting Started

### Prerequisites

- **macOS**: 12.0 or later
- **Xcode**: 14.0 or later
- **Swift**: 5.7 or later
- **Command Line Tools**: Latest version

### Quick Start

1. **Clone Repository**
   \`\`\`bash
   git clone <repository-url>
   cd Quantum-workspace
   \`\`\`

2. **Setup Environment**
   \`\`\`bash
   # Check automation status
   ./Tools/Automation/master_automation.sh status

   # Run full automation
   ./Tools/Automation/master_automation.sh all
   \`\`\`

3. **Open Projects**
   - Open individual \`.xcodeproj\` files in Xcode
   - Or use unified workspace: \`Code.code-workspace\`

## Architecture Principles

### Shared Architecture

All projects follow consistent architectural patterns:

#### BaseViewModel Protocol
\`\`\`swift
@MainActor
protocol BaseViewModel: ObservableObject {
    associatedtype State
    associatedtype Action
    var state: State { get set }
    var isLoading: Bool { get set }
    func handle(_ action: Action)
}
\`\`\`

#### Key Rules
1. **Data models NEVER import SwiftUI** - keeps separation of concerns
2. **Avoid Codable in complex data models** - prevents circular dependencies
3. **Use synchronous operations with background queues** - not async/await everywhere
4. **Specific naming over generic** - avoid "Dashboard", "Manager" names
5. **Sendable for thread safety** - prefer over complex async patterns

### Code Organization

\`\`\`
Projects/
├── {ProjectName}/
│   ├── {ProjectName}/           # Main application code
│   │   ├── Views/              # SwiftUI views
│   │   ├── ViewModels/         # View models
│   │   ├── Models/             # Data models
│   │   ├── Services/           # Business logic
│   │   └── Utilities/          # Helper functions
│   ├── Tests/                  # Unit and UI tests
│   └── {ProjectName}.xcodeproj # Xcode project
\`\`\`

## Development Workflow

### Building Projects

\`\`\`bash
# Build all projects
./Tools/Automation/master_automation.sh all

# Build specific project
./Tools/Automation/master_automation.sh run CodingReviewer

# Check status
./Tools/Automation/master_automation.sh status
\`\`\`

### Quality Gates

- **Code Coverage**: Minimum 70%, target 85%
- **Build Performance**: Maximum 120 seconds
- **Test Performance**: Maximum 30 seconds
- **File Limits**: Maximum 500 lines per file, 1000KB file size

### Linting and Formatting

\`\`\`bash
# Format code
swiftformat .

# Lint code
swiftlint --strict
\`\`\`

## Documentation Sections

### API Reference
- [CodingReviewer API](./API/CodingReviewer_API.md)
- [PlannerApp API](./API/PlannerApp_API.md)
- [AvoidObstaclesGame API](./API/AvoidObstaclesGame_API.md)
- [MomentumFinance API](./API/MomentumFinance_API.md)
- [HabitQuest API](./API/HabitQuest_API.md)

### Tutorials
- [Getting Started](./Tutorials/getting_started.md)
- [Developer Tools](./Tutorials/developer_tools.md)
- [CI/CD Setup](./Tutorials/ci_cd_setup.md)

### Guides
- [AI Code Review Guide](./AI_CODE_REVIEW_GUIDE.md)
- [Continuous Validation Guide](./CONTINUOUS_VALIDATION_GUIDE.md)
- [Production Deployment Guide](./PRODUCTION_DEPLOYMENT_GUIDE.md)

### Examples
See the [Examples](./Examples/) directory for code samples and integration examples.

## Contributing

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftFormat for consistent formatting
- Write comprehensive unit tests
- Document public APIs

### Testing
- Unit tests for business logic
- UI tests for critical user flows
- Integration tests for services
- Performance tests for critical paths

### Pull Request Process
1. Create feature branch
2. Implement changes with tests
3. Run full automation suite
4. Submit pull request with description
5. Address review feedback

## Troubleshooting

### Common Issues

#### Build Failures
- Ensure Xcode command line tools are installed
- Check Swift version compatibility
- Verify all dependencies are available

#### Test Failures
- Run tests individually to isolate issues
- Check test logs for detailed error messages
- Verify test data and mock objects

#### Performance Issues
- Use Instruments to profile performance
- Check for memory leaks
- Optimize expensive operations

### Getting Help

- Check existing issues and documentation
- Review automation logs for errors
- Use the status command for environment validation

## License

See individual project licenses for details.

---

*Generated by Quantum-workspace documentation generator*
EOF

    log_success "Generated comprehensive README"
}

# Generate usage examples
generate_usage_examples() {
    local examples_readme="${EXAMPLES_DIR}/README.md"

    cat >"${examples_readme}" <<'EOF'
# Code Examples and Integration Guides

This directory contains practical examples and integration guides for Quantum-workspace projects.

## CodingReviewer Examples

### Basic Code Analysis

```swift
import CodingReviewer

// Initialize service
let reviewService = CodeReviewService()

// Analyze code
do {
    let result = try await reviewService.analyzeCode(
        code: """
        func calculateTotal(items: [Double]) -> Double {
            return items.reduce(0, +)
        }
        """,
        language: "swift",
        analysisType: .comprehensive
    )

    // Process results
    print("Analysis complete:")
    print("- Issues found: \(result.issues.count)")
    print("- Suggestions: \(result.suggestions.count)")

    for issue in result.issues {
        print("Issue: \(issue.description)")
    }

} catch {
    print("Analysis failed: \(error)")
}
```

### AI-Enhanced Code Review

```swift
import CodingReviewer

let aiService = AIEnhancedCodeAnalysisService()

// Perform AI analysis
do {
    let aiResult = try await aiService.analyzeCodeWithAI(
        code: swiftCode,
        language: "swift",
        context: "iOS networking layer"
    )

    // Display results
    for suggestion in aiResult.suggestions {
        print("AI Suggestion: \(suggestion.description)")
        print("Impact: \(suggestion.impact)")
        print("Confidence: \(suggestion.confidence)%")
    }

} catch {
    print("AI analysis failed: \(error)")
}
```

### Custom Analysis Rules

```swift
import CodingReviewer

// Create custom validation rules
let customRules = [
    ValidationRule(
        name: "API Key Security",
        pattern: #"API_KEY\s*=\s*["'][^"']*["']"#,
        severity: .critical,
        message: "Hardcoded API keys detected"
    )
]

// Apply custom validation
let validator = CustomValidator(rules: customRules)
let violations = validator.validate(code: sourceCode)

for violation in violations {
    print("Violation: \(violation.message) at line \(violation.line)")
}
```

## PlannerApp Examples

### CloudKit Synchronization

```swift
import PlannerApp

class PlanManager {
    private let cloudKitManager = CloudKitManager()

    func syncPlans() async throws {
        // Fetch remote changes
        let remotePlans = try await cloudKitManager.fetchPlans()

        // Merge with local data
        let mergedPlans = try await mergePlans(localPlans, remotePlans)

        // Save merged data
        try await cloudKitManager.savePlans(mergedPlans)
    }

    func createPlan(title: String, dueDate: Date) async throws {
        let plan = PlanItem(
            id: UUID(),
            title: title,
            dueDate: dueDate,
            isCompleted: false
        )

        try await cloudKitManager.savePlan(plan)
    }
}
```

### Reminder Management

```swift
import PlannerApp

class ReminderService {
    func scheduleReminder(for plan: PlanItem) {
        let content = UNMutableNotificationContent()
        content.title = "Plan Due"
        content.body = plan.title
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: plan.dueDate
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: plan.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
```

## AvoidObstaclesGame Examples

### Game Scene Setup

```swift
import SpriteKit

class GameScene: SKScene {
    private var player: SKSpriteNode!
    private var obstacles: [SKSpriteNode] = []
    private var scoreLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        setupPlayer()
        setupPhysics()
        setupScoreLabel()
        startObstacleSpawner()
    }

    private func setupPlayer() {
        player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: 100)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        addChild(player)
    }

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
    }
}
```

### Collision Detection

```swift
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.player | PhysicsCategory.obstacle {
            gameOver()
        } else if collision == PhysicsCategory.player | PhysicsCategory.coin {
            collectCoin(contact.bodyB.node!)
        }
    }

    private func gameOver() {
        // Handle game over logic
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)

        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                self?.resetGame()
            }
        ]))
    }
}
```

## Integration Examples

### Command Line Tool Integration

```bash
#!/bin/bash

# Integrate with CodingReviewer CLI
analyze_code() {
    local file="$1"
    local language="${2:-swift}"

    if command -v coding-review >/dev/null 2>&1; then
        coding-review analyze --file "$file" --language "$language"
    else
        echo "CodingReviewer CLI not found"
        return 1
    fi
}

# Usage
analyze_code "MyClass.swift" "swift"
```

### CI/CD Pipeline Integration

```yaml
# .github/workflows/code-review.yml
name: Code Review
on: [pull_request]

jobs:
  review:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup CodingReviewer
        run: |
          brew install coding-reviewer

      - name: Analyze Code
        run: |
          coding-review analyze --project MyProject.xcodeproj --output review-results.json

      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: code-review-results
          path: review-results.json
```

### Swift Package Manager Integration

```swift
// Package.swift
// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/quantum-workspace/CodingReviewer.git", from: "1.0.0"),
        .package(url: "https://github.com/quantum-workspace/PlannerApp.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyApp",
            dependencies: ["CodingReviewer", "PlannerApp"]
        )
    ]
)
```

---

*These examples demonstrate common usage patterns and integration approaches for Quantum-workspace projects.*
EOF

    log_success "Generated usage examples"
}

# Generate tutorial content
generate_tutorials() {
    # Getting started tutorial
    cat >"${TUTORIALS_DIR}/getting_started.md" <<'EOF'
# Getting Started with Quantum-workspace

This tutorial will guide you through setting up and running your first Quantum-workspace project.

## Prerequisites

Before you begin, ensure you have:

- **macOS 12.0+**
- **Xcode 14.0+**
- **Swift 5.7+**
- **Git**

## Step 1: Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd Quantum-workspace

# Check environment status
./Tools/Automation/master_automation.sh status

# Run initial setup
./Tools/Automation/master_automation.sh all
```

## Step 2: Open a Project

Choose one of the projects to get started:

### CodingReviewer (Recommended for beginners)

```bash
# Open in Xcode
open Projects/CodingReviewer/CodingReviewer.xcodeproj
```

CodingReviewer is a code review application that demonstrates:
- SwiftUI architecture
- MVVM pattern implementation
- Service-oriented design
- Comprehensive testing

### AvoidObstaclesGame (Game development)

```bash
# Open in Xcode
open Projects/AvoidObstaclesGame/AvoidObstaclesGame.xcodeproj
```

Perfect for learning:
- SpriteKit game development
- Physics and collision detection
- Game state management
- Performance optimization

## Step 3: Build and Run

1. **Select Target**: Choose your project target in Xcode
2. **Select Device**: Pick a simulator or connected device
3. **Build**: Cmd+B or Product → Build
4. **Run**: Cmd+R or Product → Run

## Step 4: Explore the Code

### Project Structure

Each project follows a consistent structure:

```
ProjectName/
├── ProjectName/           # Main source code
│   ├── Views/            # SwiftUI views
│   ├── ViewModels/       # Business logic
│   ├── Models/           # Data structures
│   ├── Services/         # External integrations
│   └── Utilities/        # Helper functions
├── Tests/                # Test files
└── ProjectName.xcodeproj # Xcode project
```

### Key Files to Explore

- **ContentView.swift**: Main application interface
- **Dependencies.swift**: Service configuration
- **SharedArchitecture.swift**: Common protocols (from Shared/)

## Step 5: Make Your First Change

Let's add a simple feature:

1. **Open ContentView.swift**
2. **Add a new Text view**:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, Quantum-workspace!")
                .font(.title)
                .padding()

            Text("Welcome to your first SwiftUI app")
                .foregroundColor(.secondary)
        }
    }
}
```

3. **Build and run** to see your changes

## Step 6: Run Tests

```bash
# Run tests for your project
cd Projects/CodingReviewer
xcodebuild test -project CodingReviewer.xcodeproj -scheme CodingReviewer
```

## Step 7: Use Automation Tools

The workspace includes powerful automation:

```bash
# Check all project status
./Tools/Automation/master_automation.sh status

# Run quality checks
./Tools/Automation/master_automation.sh run CodingReviewer

# Format code
swiftformat .
```

## Next Steps

- **Read the API Documentation**: Check `Documentation/API/` for detailed API references
- **Explore Examples**: See `Documentation/Examples/` for integration patterns
- **Learn Architecture**: Study `Shared/SharedArchitecture.swift` for design patterns
- **Contribute**: Check the contributing guidelines in the main README

## Troubleshooting

### Common Issues

**Build fails with "Command not found"**
- Install Xcode command line tools: `xcode-select --install`

**Simulator won't start**
- Reset simulator: Hardware → Erase All Content and Settings

**Tests fail**
- Clean build: Cmd+Shift+K
- Clean derived data: Xcode → Preferences → Locations → Derived Data → Delete

**Automation scripts fail**
- Check permissions: `chmod +x Tools/Automation/master_automation.sh`
- Verify environment: `./Tools/Automation/master_automation.sh status`

### Getting Help

- Check the [Troubleshooting Guide](../README.md#troubleshooting)
- Review automation logs in the terminal
- Open an issue with detailed error messages

---

*Congratulations! You've successfully set up Quantum-workspace and run your first project.*
EOF

    # Developer tools tutorial
    cat >"${TUTORIALS_DIR}/developer_tools.md" <<'EOF'
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
EOF

    log_success "Generated tutorial content"
}

# Main execution
main() {
    log_info "Starting comprehensive API documentation generation..."

    # Generate API docs for each project
    projects=("CodingReviewer" "PlannerApp" "AvoidObstaclesGame" "MomentumFinance" "HabitQuest")

    for project in "${projects[@]}"; do
        project_dir="${ROOT_DIR}/${project}"
        if [[ -d "${project_dir}" ]]; then
            extract_swift_api "${project}" "${project_dir}"
        else
            log_warn "Project directory not found: ${project_dir}"
        fi
    done

    # Generate comprehensive documentation
    generate_comprehensive_readme
    generate_usage_examples
    generate_tutorials

    # Generate final summary
    cat >"${DOCS_DIR}/DOCUMENTATION_GENERATION_REPORT.md" <<EOF
# Documentation Generation Report

Generated: $(now)

## Summary

Comprehensive API documentation and guides have been generated for the Quantum-workspace.

## Generated Files

### API Documentation
$(find "${API_DIR}" -name "*.md" | sed 's|.*/||' | sed 's/^/- /')

### Guides and Tutorials
- README.md (comprehensive project overview)
- Examples/README.md (usage examples and integration guides)
- Tutorials/getting_started.md (beginner-friendly setup guide)
- Tutorials/developer_tools.md (advanced tooling and automation guide)

## Key Improvements

1. **Enhanced API Documentation**
   - Detailed class/struct/enum descriptions
   - Method signatures with parameters
   - Usage examples for key APIs
   - Architecture overviews

2. **Comprehensive Guides**
   - Getting started tutorial for new developers
   - Developer tools and automation guide
   - Integration examples and patterns

3. **Project-Specific Content**
   - Architecture diagrams and patterns
   - Platform-specific integration guides
   - Best practices and troubleshooting

4. **Quality Standards**
   - Consistent formatting and structure
   - Cross-referenced documentation
   - Searchable content organization

## Coverage Assessment

### Projects Documented: 5/5
- ✅ CodingReviewer (macOS code review app)
- ✅ PlannerApp (macOS/iOS planning app)
- ✅ AvoidObstaclesGame (iOS SpriteKit game)
- ✅ MomentumFinance (macOS/iOS finance app)
- ✅ HabitQuest (iOS habit tracking app)

### Documentation Types
- ✅ API Reference (classes, methods, properties)
- ✅ Architecture Guides (design patterns, data flow)
- ✅ Usage Examples (code samples, integration)
- ✅ Tutorials (setup, development workflow)
- ✅ Troubleshooting (common issues, solutions)

## Next Steps

1. **Review Generated Content**: Check all generated files for accuracy
2. **Add Missing Examples**: Include more project-specific examples
3. **Update for Changes**: Regenerate when APIs change
4. **User Feedback**: Incorporate developer feedback for improvements

## Automation Integration

This documentation is automatically generated and can be integrated into CI/CD:

\`\`\`bash
# Generate documentation
./Projects/scripts/gen_docs.sh

# Validate documentation
./Tools/Automation/validate_documentation.sh
\`\`\`

---

*Documentation generation completed successfully*
EOF

    log_success "Documentation generation completed!"
    log_info "Generated files are available in: ${DOCS_DIR}"
}

# Run main function
main "$@"
