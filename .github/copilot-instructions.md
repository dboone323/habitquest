# Project-Specific Copilot Instructions

> **Note:** Global instructions are in `~/.copilot-instructions.md`  
> These instructions supplement the global guidelines.

## Project Context

**Project Type:** Swift/SwiftUI iOS Application  
**Architecture:** MVVM with @Observable ViewModels  
**Data Layer:** SwiftData  
**Platforms:** iOS 17+, macOS 14+

## Project-Specific Patterns

### Key Features

- [Add main features here]

### Data Models

- [List main SwiftData models]

### ViewModels

- [List key ViewModels]

### Special Considerations

- [Any project-specific patterns or requirements]

## Common Tasks

### Adding a New Feature

1. Create feature folder in `Shared/Features/`
2. Implement ViewModel with @MainActor @Observable
3. Create View with SwiftUI
4. Add SwiftData models if needed
5. Write unit tests
6. Update documentation

### Running Tests

```bash
./dev.sh test
```

### Building

```bash
./dev.sh build
```

---

_Refer to global instructions in `~/.copilot-instructions.md` for standard patterns_
