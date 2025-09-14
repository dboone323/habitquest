# CodingReviewer Architecture Guidelines

## Core Architectural Decisions (August 7, 2025)

## Cross-Language Architecture (Swift, Python, etc.)

### Universal Principles

- **Separation of Concerns:** Data models, business logic, and UI must be in separate files/modules.
- **No UI Imports in Data Models:** Never import UI libraries (SwiftUI, tkinter, etc.) in data model files.
- **No Serialization in Core Models:** Avoid direct serialization (Codable, pickle, etc.) in complex models. Use DTOs or serializers.
- **Descriptive Naming:** Avoid generic names ("Manager", "Dashboard"). Use specific, descriptive names.
- **Consistent Folder Structure:** All projects should use a layered folder structure:

```
ProjectRoot/
├── SharedTypes/      # Pure data models (no UI or serialization imports)
├── Extensions/       # UI or utility extensions for data models
├── Components/       # Reusable UI components/widgets
├── Views/            # Main app views/screens
├── Services/         # Business logic/services
├── Scripts/          # Automation and CLI scripts
└── Tests/            # Unit and integration tests
```

### Python-Specific Best Practices

- **Data Models:** Place pure data classes (using @dataclass, no UI or serialization logic) in `SharedTypes/`.
- **UI Extensions:** Place UI-specific logic (e.g., color mapping, display helpers) in `Extensions/`.
- **Business Logic:** Place core algorithms/services in `Services/`.
- **No Circular Imports:** Enforce strict boundaries between layers.
- **Serialization:** Use DTOs or separate serializers for JSON/pickle, not in core models.
- **Testing:** Place all tests in `Tests/` with clear naming and coverage.

### Example Python Structure

```
SharedTypes/
    user.py         # Pure data class
Extensions/
    user_ui.py      # UI helpers for user
Services/
    user_service.py # Business logic
Views/
    user_view.py    # UI code (tkinter, PyQt, etc.)
```

### Automation and Build

- Keep automation scripts in `Scripts/` or a dedicated automation folder.
- Use Makefile, shell scripts, or Python scripts for build/test automation.
- Each project must have a documented build/test process in its README.

### Platform Build/Run Policy

- **Swift/iOS:** Build and test on iPhone 17 simulator.
- **Swift/macOS:** Build and test on Mac.
- **Python:** Run and test on Mac (or Linux if specified).

### Migration/Refactor Checklist

1. Ensure folder structure matches above.
2. Move pure data models to `SharedTypes/`.
3. Move UI helpers/extensions to `Extensions/`.
4. Move business logic to `Services/`.
5. Move automation/build scripts to `Scripts/`.
6. Move all tests to `Tests/`.
7. Update README with build/run/test instructions.
8. Use descriptive, non-generic names for all files/classes.
9. Remove UI/serialization imports from data models.
10. Confirm build/test on the correct platform.

### 1. **Clean Separation of Concerns**

**RULE: Data models NEVER import SwiftUI**

- `SharedTypes/` folder contains pure data models
- UI extensions go in `Extensions/` folder
- This prevents circular dependencies and concurrency issues

### 2. **Synchronous-First Approach**

**DECISION: Use sync operations with background queues, not async/await everywhere**

- Main processing logic runs synchronously on background queues
- SwiftUI updates happen on MainActor via Task { @MainActor in ... }
- Avoids complex concurrency debugging

### 3. **File Organization**

```
CodingReviewer/
├── SharedTypes/           # Pure data models (no UI imports)
│   ├── BackgroundProcessingTypes.swift
│   ├── AnalysisTypes.swift
│   └── ServiceTypes.swift
├── Extensions/            # UI extensions for data models
│   └── BackgroundProcessingUI.swift
├── Components/            # Reusable UI components
├── Views/                 # Main app views
└── Services/              # Business logic services
```

### 4. **Naming Conventions**

**RULE: Avoid generic names like "Dashboard" or "Manager"**

- Use specific names: `OptimizationDashboard`, `EnterpriseAnalyticsDashboard`
- This prevents naming conflicts as the app grows

### 5. **Concurrency Strategy**

**PATTERN: Background processing with MainActor updates**

```swift
// ✅ CORRECT
jobQueue.async { [weak self] in
    // Do background work
    let result = processJob()

    Task { @MainActor [weak self] in
        // Update UI on main thread
        self?.updateUI(with: result)
    }
}

// ❌ AVOID
async func processJob() async throws -> Result {
    // Complex async chains lead to debugging nightmares
}
```

### 6. **Color and UI Handling**

**PATTERN: String identifiers in data models, Color extensions in UI files**

```swift
// In SharedTypes (data model)
var colorIdentifier: String { return "blue" }

// In Extensions (UI layer)
var color: Color {
    switch colorIdentifier {
    case "blue": return .blue
    // ...
    }
}
```

### 7. **Codable Strategy**

**CRITICAL DECISION: Avoid Codable in complex data models**

- Codable creates circular dependencies and concurrency issues
- Use simple property access for data persistence instead
- If serialization is needed, create separate DTO (Data Transfer Object) types
- Keep core data models clean and dependency-free

```swift
// ✅ CORRECT - Clean data model
struct ProcessingJob: Identifiable, Sendable {
    let id: UUID
    let type: JobType
    // ... properties only
}

// ❌ AVOID - Codable causes circular references
struct ProcessingJob: Identifiable, Sendable, Codable {
    // This leads to compiler errors and instability
}
```

## Benefits of This Architecture

1. **No circular dependencies** - Data models don't know about UI or encoding
2. **Easy testing** - Pure data models can be tested independently
3. **Clear boundaries** - Each layer has a single responsibility
4. **Stable builds** - No more back-and-forth fixes
5. **Scalable** - Easy to add new features without breaking existing code
6. **Concurrency safe** - No MainActor conflicts or encoding race conditions

## Migration Strategy

When adding new features:

1. Define data models in `SharedTypes/` first (NO Codable, NO SwiftUI imports)
2. Add UI extensions in `Extensions/` if needed
3. Build UI components that use the extensions
4. Never import SwiftUI in data model files
5. If persistence is needed, create separate serialization logic outside the core models

## Critical Rules to Prevent Issues

**NEVER ADD THESE TO SharedTypes:**

- ❌ `import SwiftUI`
- ❌ `: Codable` conformance
- ❌ `@preconcurrency` (indicates architectural problems)
- ❌ Generic names like "Dashboard" or "Manager"

**ALWAYS DO:**

- ✅ Use `Sendable` for thread safety
- ✅ Use `colorIdentifier: String` instead of `Color`
- ✅ Keep data models pure and simple
- ✅ Use specific, descriptive names

## Automation Strategy

Keep automation scripts **separate** from the main app:

- Background scripts should modify files directly
- Use file system notifications for real-time updates
- Avoid complex inter-process communication

This architecture ensures stability and prevents the fix-rollback cycle we've been experiencing.

## Strategic Implementation Patterns (August 8, 2025)

### Lessons Learned from 81→0 Error Resolution

**CRITICAL INSIGHT: Implement types properly from the start, not bandaid fixes**

#### 1. **Type Implementation Strategy**

```swift
// ✅ STRATEGIC APPROACH - Complete type implementation
struct ProcessingJob: Identifiable, Sendable, Comparable {
    let id: UUID
    let type: JobType
    var status: JobStatus = .pending    // Mutable runtime state
    var progress: Double = 0.0          // Mutable progress tracking
    var errorMessage: String?           // Proper error handling
    var startTime: Date?               // Complete timing info
    var completionTime: Date?          // Complete timing info

    // Implement ALL required protocols properly
    static func < (lhs: ProcessingJob, rhs: ProcessingJob) -> Bool {
        lhs.priority.rawValue < rhs.priority.rawValue
    }
}

// ❌ BANDAID APPROACH - Leads to cascading errors
struct ProcessingJob: Identifiable {
    let id: UUID
    // Missing properties, will cause errors later
}
```

#### 2. **Sendable vs Codable Trade-offs**n**RULE: Choose Sendable for concurrency safety over Codable convenience**

- Use `Sendable` for thread-safe data models
- Avoid `Codable` in complex nested types (causes circular references)
- Create separate DTOs for serialization if needed
- Never mix concurrency and encoding protocols without careful design

#### 3. **Property Mutability Patterns**

```swift
// ✅ CORRECT - Clear separation of immutable identity vs mutable state
struct SystemLoad: Sendable {
    let timestamp: Date              // Immutable identity
    var cpuUsage: Double            // Mutable runtime state
    var memoryUsage: Double         // Mutable runtime state
    var diskUsage: Double           // Mutable runtime state
}
```

... (file continues as provided) ...
