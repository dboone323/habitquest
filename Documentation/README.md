# Quantum-workspace Documentation

Generated: 2025-10-08 14:42:50 -0500

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
   ```bash
   git clone <repository-url>
   cd Quantum-workspace
   ```

2. **Setup Environment**
   ```bash
   # Check automation status
   ./Tools/Automation/master_automation.sh status

   # Run full automation
   ./Tools/Automation/master_automation.sh all
   ```

3. **Open Projects**
   - Open individual `.xcodeproj` files in Xcode
   - Or use unified workspace: `Code.code-workspace`

## Architecture Principles

### Shared Architecture

All projects follow consistent architectural patterns:

#### BaseViewModel Protocol
```swift
@MainActor
protocol BaseViewModel: ObservableObject {
    associatedtype State
    associatedtype Action
    var state: State { get set }
    var isLoading: Bool { get set }
    func handle(_ action: Action)
}
```

#### Key Rules
1. **Data models NEVER import SwiftUI** - keeps separation of concerns
2. **Avoid Codable in complex data models** - prevents circular dependencies
3. **Use synchronous operations with background queues** - not async/await everywhere
4. **Specific naming over generic** - avoid "Dashboard", "Manager" names
5. **Sendable for thread safety** - prefer over complex async patterns

### Code Organization

```
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
```

## Development Workflow

### Building Projects

```bash
# Build all projects
./Tools/Automation/master_automation.sh all

# Build specific project
./Tools/Automation/master_automation.sh run CodingReviewer

# Check status
./Tools/Automation/master_automation.sh status
```

### Quality Gates

- **Code Coverage**: Minimum 70%, target 85%
- **Build Performance**: Maximum 120 seconds
- **Test Performance**: Maximum 30 seconds
- **File Limits**: Maximum 500 lines per file, 1000KB file size

### Linting and Formatting

```bash
# Format code
swiftformat .

# Lint code
swiftlint --strict
```

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
