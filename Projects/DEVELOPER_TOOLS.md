# Developer Tools, Debugging, and Live Reload Guide

## Debugging in VS Code

### Swift (macOS/iOS)
- **LLDB Debugging**: Use the "Debug Swift (LLDB)" configuration in the Run & Debug panel. Requires the [Swift for VS Code](https://marketplace.visualstudio.com/items?itemName=swiftlang.swift-vscode) extension and a built debug binary.
- **Xcode Previews**: For live reload and UI previews, open your SwiftUI files in Xcode and use the Canvas (⌥⌘↩). This is the fastest way to see UI changes live.
- **Breakpoints & Step Debugging**: Set breakpoints in VS Code or Xcode. Use the debug toolbar to step through code.

### Python
- Use the "Debug Python File" configuration. Requires the [Python extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python).
- For new projects, prefer the `debugpy` debug type for future compatibility.

### Node.js
- Use the "Debug Node.js File" configuration. Requires the [Node.js extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.node-debug2).
- For new projects, use `type: "node"` in your launch config.

## Live Reload

- **SwiftUI**: Live reload is best achieved with Xcode Previews. VS Code does not support true live reload for SwiftUI, but you can use the build tasks and Xcode for rapid iteration.
- **Python/Node.js**: Use extensions like [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python) and [Nodemon](https://marketplace.visualstudio.com/items?itemName=ms-vscode.nodemon) for auto-reload on file changes.

## Recommended Extensions
- See `.vscode/extensions.json` for a curated list of recommended extensions for this workspace.

## Common Tasks
- **Build, Test, Lint, CI**: Use the VS Code task runner (⇧⌘B) or the Run Task command to access all common developer workflows.
- **Terminal**: Integrated zsh shell is configured for all projects.

## Advanced Debugging
- **Remote Debugging**: For server-side Swift or Python, configure remote attach in `launch.json`.
- **Performance Profiling**: Use Xcode Instruments for Swift, or `cProfile` for Python.

---

_Last updated: September 12, 2025_
