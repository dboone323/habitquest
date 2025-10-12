# CodingReviewer API Reference

**Generated:** Sun Oct 12 09:52:57 CDT 2025
**Type:** Manual Documentation

## Public API Overview

### Public Classes

- `public class OllamaClient: ObservableObject, OllamaClientProtocol `
- `public class OllamaIntegrationManager: AITextGenerationService, AICodeAnalysisService, AICodeGenerationService, AICachingService, AIPerformanceMonitoring, @unchecked Sendable `

### Public Structs

- `public struct ContentView: View `
- `public struct ContentView_Previews: PreviewProvider `
- `public struct CodingReviewer: App `
- `public struct OllamaConfig `
- `public struct OllamaMessage: Codable `
- `public struct OllamaGenerateResponse: Codable `
- `public struct OllamaServerStatus `
- `public struct ServiceHealth `
- `public struct CodeGenerationResult `
- `public struct CodeAnalysisResult `
- `public struct CodeIssue `
- `public struct DocumentationResult `
- `public struct TestGenerationResult `
- `public struct AutomationTask `
- `public struct TaskResult `
- `public struct HealthStats `
- `public struct CurrentHealth `
- `public struct ServiceHealth: Codable, Sendable `
- `public struct CodeAnalysisResult: Codable, Sendable `
- `public struct CodeIssue: Codable, Sendable `
- `public struct CodeGenerationResult: Codable, Sendable `
- `public struct CacheStats: Codable, Sendable `
- `public struct PerformanceMetrics: Codable, Sendable `
- `public struct AIServiceInfo: Codable, Sendable `
- `public struct AIOperation: Codable, Sendable `
- `public struct AIOperationResult: Codable, Sendable `
- `public struct ServiceHealthOverview: Codable, Sendable `
- `public struct AIServiceConfiguration: Codable, Sendable `
- `public struct RateLimit: Codable, Sendable `
- `public struct AnyCodable: Codable, Sendable `

### Public Enums

- `public enum OllamaIntegration `
- `public enum OllamaError: LocalizedError `
- `public enum CodeComplexity `
- `public enum AnalysisType `
- `public enum IssueSeverity `
- `public enum TaskType `
- `public enum IntegrationError: Error `
- `public enum IssueSeverity: String, Codable, Sendable `
- `public enum AnalysisType: String, Codable, Sendable `
- `public enum CodeComplexity: String, Codable, Sendable `
- `public enum AIServiceType: String, Codable, Sendable `
- `public enum AICapability: String, Codable, Sendable `
- `public enum AIOperationType: String, Codable, Sendable `
- `public enum OperationPriority: String, Codable, Sendable `
- `public enum AIError: Error, LocalizedError `

### Public Protocols

- `public protocol OllamaClientProtocol `
- `public protocol AITextGenerationService `
- `public protocol AICodeAnalysisService `
- `public protocol AICodeGenerationService `
- `public protocol AICachingService `
- `public protocol AIPerformanceMonitoring `
- `public protocol AIServiceCoordinator `
- `public protocol AIConfigurationService `


## Usage

For detailed usage examples, see the source files in:
`/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/`

## Architecture Notes

This project follows the Quantum Workspace architecture patterns. See [ARCHITECTURE.md](../../ARCHITECTURE.md) for details.

---

*For full HTML documentation, run:*
```bash
jazzy --module CodingReviewer --output Documentation/API/CodingReviewer
```
