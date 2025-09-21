# Code Examples

This directory contains practical code examples for common development tasks in the Quantum workspace.

## 📱 iOS/macOS Development Examples

### Basic App Structure
```swift
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, Quantum!")
            .padding()
    }
}
```

### SwiftUI View with State Management
```swift
struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.tasks) { task in
                TaskRow(task: task)
                    .onTapGesture {
                        viewModel.toggleTask(task)
                    }
            }
            .navigationTitle("Tasks")
            .toolbar {
                Button(action: viewModel.addTask) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []

    func addTask() {
        let newTask = Task(title: "New Task", isCompleted: false)
        tasks.append(newTask)
    }

    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}
```

### SwiftData Integration
```swift
import SwiftData

@Model
class Task {
    var id = UUID()
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        container = try! ModelContainer(for: Task.self)
    }
}
```

## 🧪 Testing Examples

### Unit Test Example
```swift
import XCTest
@testable import MyApp

class TaskListViewModelTests: XCTestCase {
    var viewModel: TaskListViewModel!

    override func setUp() {
        super.setUp()
        viewModel = TaskListViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testAddTask() {
        let initialCount = viewModel.tasks.count

        viewModel.addTask()

        XCTAssertEqual(viewModel.tasks.count, initialCount + 1)
        XCTAssertEqual(viewModel.tasks.last?.title, "New Task")
        XCTAssertFalse(viewModel.tasks.last?.isCompleted ?? true)
    }

    func testToggleTask() {
        viewModel.addTask()
        let task = viewModel.tasks[0]
        let initialState = task.isCompleted

        viewModel.toggleTask(task)

        XCTAssertNotEqual(viewModel.tasks[0].isCompleted, initialState)
    }
}
```

### UI Test Example
```swift
import XCTest

class MyAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testTaskCreation() {
        let addButton = app.buttons["Add Task"]
        XCTAssertTrue(addButton.exists)

        addButton.tap()

        let taskList = app.tables["Task List"]
        XCTAssertTrue(taskList.exists)

        let newTaskCell = taskList.cells.element(boundBy: 0)
        XCTAssertTrue(newTaskCell.exists)
    }

    func testTaskCompletion() {
        // Assuming there's at least one task
        let taskCell = app.tables["Task List"].cells.element(boundBy: 0)
        XCTAssertTrue(taskCell.exists)

        taskCell.tap()

        // Verify task is marked complete
        let completedTask = app.tables["Task List"].cells.element(boundBy: 0)
        XCTAssertTrue(completedTask.exists)
    }
}
```

## 🔧 Automation Script Examples

### Basic Automation Script
```bash
#!/bin/bash

# Basic automation script template
set -euo pipefail

PROJECT_NAME="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z $PROJECT_NAME ]]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

echo "Running automation for $PROJECT_NAME..."

# Add your automation logic here
echo "✅ Automation completed for $PROJECT_NAME"
```

### Advanced Automation with Error Handling
```bash
#!/bin/bash

# Advanced automation with comprehensive error handling
set -euo pipefail

PROJECT_NAME="${1:-}"
LOG_FILE="/tmp/automation_$(date +%Y%m%d_%H%M%S).log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Validate input
if [[ -z $PROJECT_NAME ]]; then
    error_exit "Project name is required"
fi

log "Starting automation for $PROJECT_NAME"

# Your automation logic here
if your_command_here; then
    log "✅ Automation completed successfully"
else
    error_exit "Automation failed"
fi
```

## 📋 Configuration Examples

### SwiftFormat Configuration (.swiftformat)
```yaml
# SwiftFormat configuration
--indent 4
--maxwidth 120
--wraparguments beforefirst
--wrapparameters beforefirst
--binarygrouping none
--hexgrouping none
--decimalgrouping none
--octalgrouping none
--stripunusedargs closure-only
--disable blankLinesAtStartOfScope,blankLinesAtEndOfScope
```

### SwiftLint Configuration (.swiftlint.yml)
```yaml
disabled_rules:
  - trailing_whitespace
  - vertical_whitespace

opt_in_rules:
  - empty_count
  - force_unwrapping

included:
  - Source

excluded:
  - Carthage
  - Pods
  - Source/ExcludedFolder
  - Source/*/ExcludedFile.swift

line_length: 120
indentation: 4
```

## 🚀 Deployment Examples

### Fastlane Fastfile
```ruby
# Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and deploy to TestFlight"
  lane :beta do
    # Increment build number
    increment_build_number

    # Build the app
    build_app(
      scheme: "MyApp",
      export_method: "app-store"
    )

    # Upload to TestFlight
    upload_to_testflight
  end

  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "MyApp",
      devices: ["iPhone 13"]
    )
  end
end
```

### GitHub Actions Workflow
```yaml
name: CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '14.0'

    - name: Build
      run: xcodebuild -scheme MyApp -configuration Release

    - name: Run tests
      run: xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 13'

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: build-artifacts
        path: build/
```

## 📚 Additional Resources

- [Swift Documentation](https://docs.swift.org)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Xcode Help](https://help.apple.com/xcode)
- [Fastlane Documentation](https://docs.fastlane.tools)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

*Examples are automatically generated and may need adaptation for your specific use case.*
