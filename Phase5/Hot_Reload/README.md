# Hot Reload System

A comprehensive hot reload system for Swift applications that enables real-time code updates without restarting the application. This system provides incremental compilation, runtime patching, state preservation, and intelligent error recovery.

## Features

### 🚀 Core Capabilities
- **Incremental Compilation**: Only recompiles changed files and their dependencies
- **Runtime Patching**: Dynamically updates running code without application restart
- **State Preservation**: Maintains application state across reloads using observer patterns
- **File Watching**: Monitors file system changes with debouncing and filtering
- **Error Recovery**: Automatic error detection and recovery with multiple strategies
- **Reload Coordination**: Manages concurrent reloads with queuing and prioritization

### 🎯 Key Benefits
- **Faster Development**: See changes instantly without rebuild/restart cycles
- **State Preservation**: Maintain complex application state during development
- **Error Resilience**: Automatic recovery from common compilation and runtime errors
- **Performance Optimized**: Minimal compilation overhead with dependency tracking
- **Developer Friendly**: Comprehensive logging and diagnostic information

## Architecture

The system consists of six core components working together:

```
FileWatcher → ReloadCoordinator → HotReloadEngine
    ↓              ↓              ↓
ErrorHandler ← StatePreserver ← IncrementalCompiler
                     ↓
               RuntimePatcher
```

### Components

#### HotReloadEngine
Central coordinator that orchestrates the entire reload process. Manages configuration, coordinates between components, and provides the main API.

#### IncrementalCompiler
Handles intelligent recompilation of only changed files. Tracks dependencies, manages compilation caching, and integrates with the Swift compiler.

#### RuntimePatcher
Applies compiled changes to the running application using Objective-C runtime. Supports method swizzling, class modifications, and patch validation.

#### StatePreserver
Captures and restores application state during reloads. Uses observer patterns to monitor state changes and provides restoration guarantees.

#### ReloadCoordinator
Manages reload lifecycle, queuing, and concurrency. Handles prioritization, timeout management, and reload history tracking.

#### ErrorHandler
Comprehensive error handling with automatic recovery strategies. Classifies errors, attempts fixes, and provides diagnostic information.

#### FileWatcher
Monitors file system changes with filtering and debouncing. Supports multiple directories and provides real-time change notifications.

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourorg/HotReload.git", from: "1.0.0")
]
```

### Manual Installation

1. Copy the Hot Reload source files to your project
2. Ensure proper module structure
3. Import the framework in your code

## Quick Start

### Basic Setup

```swift
import HotReload

// Create and configure the hot reload engine
let engine = HotReloadEngine(configuration: .default)

// Start watching your source directory
try engine.startWatching(directory: URL(fileURLWithPath: "./Sources"))

// The system will automatically reload when files change
```

### Advanced Configuration

```swift
// Configure for development environment
let config = HotReloadEngine.Configuration(
    enableLogging: true,
    maxConcurrentReloads: 2,
    debounceInterval: 0.3,
    watchedExtensions: ["swift", "h", "m", "xib"]
)

let engine = HotReloadEngine(configuration: config)

// Monitor reload status
engine.reloadStatus
    .sink { status in
        print("Reload status: \(status)")
    }
    .store(in: &cancellables)
```

### State Preservation

```swift
// Preserve application state during reloads
let viewModel = MyViewModel()
viewModel.loadData()

// Capture state before reload
let stateId = try await engine.captureApplicationState()

// Perform reload
try await engine.reload(files: changedFiles)

// Restore state after reload
try await engine.restoreApplicationState(stateId)

// View model state is preserved
```

## API Reference

### HotReloadEngine

```swift
public class HotReloadEngine {

    // Initialization
    init(configuration: Configuration = .default)

    // Core functionality
    func reload(files: [URL]) async throws
    func startWatching(directory: URL) throws
    func stopWatching()

    // State management
    func captureApplicationState() async throws -> StateID
    func restoreApplicationState(_ stateId: StateID) async throws

    // Status monitoring
    var reloadStatus: AnyPublisher<ReloadStatus, Never> { get }
    var fileChanges: AnyPublisher<FileChange, Never> { get }
}
```

### Configuration Options

```swift
public struct Configuration {
    var enableLogging: Bool = false
    var maxConcurrentReloads: Int = 1
    var debounceInterval: TimeInterval = 0.5
    var watchedExtensions: [String] = ["swift"]
    var ignoredPatterns: [String] = [".git", ".build"]
    var enableStatePreservation: Bool = true
    var enableErrorRecovery: Bool = true
}
```

## Usage Examples

### Development Workflow Integration

```swift
class DevelopmentController {

    private var hotReloadEngine: HotReloadEngine!
    private var cancellables = Set<AnyCancellable>()

    func setupDevelopmentEnvironment() {
        // Initialize hot reload
        hotReloadEngine = HotReloadEngine()

        // Watch source directories
        try? hotReloadEngine.startWatching(directory: URL(fileURLWithPath: "./Sources"))
        try? hotReloadEngine.startWatching(directory: URL(fileURLWithPath: "./Tests"))

        // Handle reload events
        hotReloadEngine.reloadStatus
            .sink { [weak self] status in
                self?.handleReloadStatus(status)
            }
            .store(in: &cancellables)

        // Handle file changes
        hotReloadEngine.fileChanges
            .sink { [weak self] change in
                self?.handleFileChange(change)
            }
            .store(in: &cancellables)
    }

    private func handleReloadStatus(_ status: ReloadStatus) {
        switch status {
        case .preparing:
            showToast("Preparing reload...")
        case .compiling:
            showToast("Compiling changes...")
        case .patching:
            showToast("Applying changes...")
        case .completed:
            showToast("Reload complete!")
        case .failed(let error):
            showError("Reload failed: \(error.localizedDescription)")
        }
    }

    private func handleFileChange(_ change: FileChange) {
        print("File changed: \(change.fileURL.lastPathComponent)")
    }
}
```

### Custom Error Recovery

```swift
class CustomErrorHandler: ErrorHandler {

    override func addRecoveryStrategy(_ strategy: RecoveryStrategy, for errorType: ErrorType) {
        // Add custom recovery strategies
        switch errorType {
        case .compilation:
            addRecoveryStrategy(CustomCompilationFixStrategy(), for: .compilation)
        case .runtime:
            addRecoveryStrategy(CustomRuntimeRecoveryStrategy(), for: .runtime)
        default:
            super.addRecoveryStrategy(strategy, for: errorType)
        }
    }
}

struct CustomCompilationFixStrategy: RecoveryStrategy {
    let name = "Custom Fix"
    let description = "Applies custom compilation fixes"

    func execute(error: Error, context: ErrorContext) async throws {
        // Implement custom fix logic
        print("Applying custom compilation fix")
    }
}
```

### Performance Monitoring

```swift
class PerformanceMonitor {

    private var reloadCoordinator: ReloadCoordinator!

    func monitorPerformance() {
        // Get reload statistics
        let stats = reloadCoordinator.getReloadStatistics()

        print("Reload Performance:")
        print("- Total reloads: \(stats.totalReloads)")
        print("- Success rate: \(Int(stats.successRate * 100))%")
        print("- Average duration: \(String(format: "%.2f", stats.averageDuration))s")

        // Get error patterns
        let patterns = errorHandler.getErrorPatterns()
        if !patterns.isEmpty {
            print("Error Patterns:")
            for pattern in patterns {
                print("- \(pattern.description): \(pattern.frequency) occurrences")
            }
        }
    }
}
```

## Error Handling

The system provides comprehensive error handling with automatic recovery:

### Error Types
- **Compilation Errors**: Syntax errors, missing imports, type mismatches
- **Runtime Errors**: Method conflicts, state corruption, patching failures
- **File System Errors**: Permission issues, missing files, disk space
- **Network Errors**: Remote dependency issues, connection timeouts

### Recovery Strategies
- **Retry**: Simple retry with backoff
- **Clean Build**: Full recompilation to resolve state issues
- **State Reset**: Reset to known good state
- **Component Isolation**: Isolate faulty components
- **Custom Strategies**: User-defined recovery logic

### Error Reporting

```swift
// Get diagnostic report
let report = errorHandler.generateDiagnosticReport()

print("Error Summary:")
print("- Total errors: \(report.statistics.totalErrors)")
print("- Recovery rate: \(Int(report.statistics.recoveryRate * 100))%")

if !report.recommendations.isEmpty {
    print("Recommendations:")
    for recommendation in report.recommendations {
        print("- \(recommendation)")
    }
}
```

## Testing

### Integration Tests

```swift
import XCTest
@testable import HotReload

class HotReloadIntegrationTests: XCTestCase {

    func testFullReloadCycle() async throws {
        // Test complete reload workflow
        let engine = HotReloadEngine()

        // Create test files
        let testFile = createTestFile()

        // Perform reload
        try await engine.reload(files: [testFile])

        // Verify changes were applied
        XCTAssertTrue(verifyReloadSuccess())
    }
}
```

### Performance Tests

```swift
class HotReloadPerformanceTests: XCTestCase {

    func testReloadPerformance() async throws {
        let engine = HotReloadEngine()

        let startTime = Date()
        try await engine.reload(files: testFiles)
        let duration = Date().timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 2.0, "Reload too slow")
    }
}
```

## Best Practices

### Configuration
- Use appropriate debounce intervals (0.3-0.5s for development)
- Configure watched extensions based on your project
- Enable logging during development, disable in production

### State Management
- Use `@Published` properties for automatic state tracking
- Implement `StateObserver` for custom state preservation
- Test state restoration after reloads

### Error Handling
- Implement custom recovery strategies for domain-specific errors
- Monitor error patterns to identify systemic issues
- Use diagnostic reports for troubleshooting

### Performance
- Limit concurrent reloads based on system capabilities
- Use dependency tracking to minimize compilation scope
- Monitor reload statistics to identify bottlenecks

## Troubleshooting

### Common Issues

**Reload Not Triggering**
- Check file watching is enabled
- Verify file extensions are configured
- Ensure debounce interval isn't too long

**Compilation Failures**
- Check Swift compiler installation
- Verify file permissions
- Review error logs for specific issues

**State Loss**
- Ensure objects conform to state preservation protocols
- Check observer registration
- Verify state capture timing

**Performance Issues**
- Reduce concurrent reload limit
- Increase debounce interval
- Review dependency tracking

### Debug Mode

Enable debug logging for detailed information:

```swift
let config = Configuration(
    enableLogging: true,
    logLevel: .debug
)
```

### Diagnostic Tools

```swift
// Generate comprehensive diagnostic report
let report = engine.generateDiagnosticReport()
print(report)

// Check component health
let healthStatus = engine.healthCheck()
print("System health: \(healthStatus)")
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Roadmap

### Planned Features
- **Visual Debugging**: GUI for reload monitoring and debugging
- **Remote Hot Reload**: Network-based reload for device testing
- **Plugin System**: Extensible architecture for custom components
- **Advanced Profiling**: Detailed performance and memory analysis
- **Multi-Language Support**: Extend beyond Swift to other languages

### Version History

- **v1.0.0**: Initial release with core hot reload functionality
- **v1.1.0**: Enhanced error recovery and state preservation
- **v1.2.0**: Performance optimizations and advanced monitoring