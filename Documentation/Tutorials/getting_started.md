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
