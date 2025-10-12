# CodingReviewer API Documentation

**Generated:** Sat Oct 11 19:40:04 CDT 2025
**Version:** 1.0.0

## Overview

This document provides comprehensive API reference for CodingReviewer.

---

## AboutView.swift

**Path:** `Sources/UI/Views/AboutView.swift`

### Structs

#### `AboutView`


---

## ContentView.swift

**Path:** `Sources/UI/Views/ContentView.swift`

### Enums

#### `ContentViewType`


---

## NewReviewView.swift

**Path:** `Sources/UI/Views/NewReviewView.swift`

### Structs

#### `NewReviewView`


---

## CodeDocumentManager.swift

**Path:** `Sources/Core/Managers/CodeDocumentManager.swift`

### Description

Manages code documents with lazy loading and LRU caching for performance optimization

### Classes

#### `CodeDocumentManager`

Manages code documents with lazy loading and LRU caching for performance optimization


#### `PerformanceManager`

Manages performance monitoring and optimization for code analysis operations


### Structs

#### `CodeDocument`


#### `CacheStats`


#### `PerformanceMetrics`


#### `CodeFile`


### Enums

#### `ProgrammingLanguage`


---

## OllamaCodeAnalysisService.swift

**Path:** `Sources/Core/Services/OllamaCodeAnalysisService.swift`

### Description

Concrete implementation of CodeAnalysisService using Ollama AI models

### Classes

#### `OllamaCodeAnalysisService`

Concrete implementation of CodeAnalysisService using Ollama AI models


---

## CodeAnalysisService.swift

**Path:** `Sources/Core/Services/CodeAnalysisService.swift`

### Description

Protocol defining the interface for AI-powered code analysis services

### Protocols

#### `CodeAnalysisService`

Protocol defining the interface for AI-powered code analysis services

- `func analyzeCode(_ code: String, language: String) async throws -> AnalysisResult`
- `func suggestImprovements(for issues: [CodeIssue]) async throws -> [Suggestion]`
- `func generateDocumentation(for code: String) async throws -> String`

### Structs

#### `AnalysisResult`

Result of code analysis containing various metrics and findings


#### `CodeIssue`

Represents a specific issue found in code


#### `Suggestion`

Represents a suggestion for code improvement


---

## AICodeReviewer.swift

**Path:** `Sources/Core/Services/AICodeReviewer.swift`

### Description

AI-powered code reviewer that provides natural language processing capabilities
for code style analysis, code smell detection, and test case generation

### Structs

#### `AICodeReviewer`

AI-powered code reviewer that provides natural language processing capabilities
for code style analysis, code smell detection, and test case generation


#### `StyleReview`


#### `CodeSmell`


#### `TestCase`


#### `PerformanceAnalysis`


#### `PerformanceIssue`


#### `Optimization`


#### `RefactoringSuggestion`


#### `DocumentationResult`


#### `ArchitecturalSuggestion`


### Enums

#### `AICodeReviewerError`


---

