# CodingReviewer Modular Architecture - Usage Guide

## Quick Start

### 1. Start the Platform (Python Server)
```bash
cd /Users/danielstevens/Desktop/CodingReviewer-Modular/CodingReviewer-Platform
/Users/danielstevens/Desktop/CodingReviewer/.venv/bin/python server_simple.py
```

### 2. Open the Swift App
```bash
cd /Users/danielstevens/Desktop/CodingReviewer-Modular/CodingReviewer-App
open CodingReviewer.xcodeproj
```

### 3. Test API Communication
```bash
# Health check
curl http://localhost:8000/health

# Platform status
curl http://localhost:8000/api/v1/status

# Request analysis
curl -X POST http://localhost:8000/api/v1/analyze \
  -H "Content-Type: application/json" \
  -d '{"project_path": "/path/to/project"}'
```

## Repository Structure

```
CodingReviewer-Modular/
├── CodingReviewer-App/          # Swift macOS application
│   ├── CodingReviewer/
│   │   ├── Services/
│   │   │   └── PlatformAPIClient.swift    # API client
│   │   └── Views/
│   │       └── PlatformConnectionView.swift # Demo UI
│   └── CodingReviewer.xcodeproj
├── CodingReviewer-Platform/     # Python automation platform
│   ├── src/codingreviewer_platform/
│   ├── server_simple.py         # FastAPI server
│   └── pyproject.toml
└── CodingReviewer-Protocol/     # API contracts
    └── README.md
```

## API Endpoints

### Health & Status
- `GET /health` - Health check
- `GET /api/v1/status` - Platform status and capabilities

### Analysis
- `POST /api/v1/analyze` - Request project analysis
- `GET /api/v1/analyze/{id}` - Get analysis status/results

### Projects
- `GET /api/v1/projects` - List available projects

## Swift Integration

### Using the API Client
```swift
import SwiftUI

struct MyView: View {
    @StateObject private var apiClient = PlatformAPIClient()
    
    var body: some View {
        VStack {
            // Connection status
            Text("Status: \(apiClient.connectionStatus)")
            
            // Request analysis
            Button("Start Analysis") {
                Task {
                    let result = try await apiClient.requestAnalysis(
                        projectPath: "/path/to/project"
                    )
                    print("Analysis started: \(result.id)")
                }
            }
        }
        .task {
            // Check health on appear
            try await apiClient.checkHealth()
        }
    }
}
```

### Data Models
```swift
// Available in both Swift and Python
struct AnalysisRequest: Codable {
    let projectPath: String
    let analysisType: String = "full"
    let options: [String: Any]? = nil
}

struct AnalysisResult: Codable {
    let id: String
    let projectPath: String
    let status: String
    let progress: Double
    let message: String?
    let results: [String: Any]?
}
```

## Development Workflow

### 1. Platform Development
```bash
cd CodingReviewer-Platform
# Install dependencies
/Users/danielstevens/Desktop/CodingReviewer/.venv/bin/pip install -e .

# Start server
python server_simple.py

# Test endpoints
curl http://localhost:8000/api/v1/status
```

### 2. App Development
```bash
cd CodingReviewer-App
# Open in Xcode
open CodingReviewer.xcodeproj

# Build and run
# Use PlatformConnectionView for testing
```

### 3. Protocol Changes
- Update API contracts in `CodingReviewer-Protocol/`
- Update Python server models
- Update Swift client models
- Test integration

## Architecture Benefits

### ✅ **Complete Separation**
- Swift app and Python platform are independent
- Can be developed, tested, and deployed separately
- Clear API contracts prevent breaking changes

### ✅ **Scalability** 
- Platform can serve multiple clients
- Horizontal scaling with load balancers
- Background processing capabilities

### ✅ **Maintainability**
- Clean code organization
- Modular development workflow
- Independent testing strategies

### ✅ **Cross-Platform Ready**
- API-driven architecture
- Platform-agnostic protocols
- Ready for web, mobile, or CLI clients

## Troubleshooting

### Server Won't Start
```bash
# Check Python environment
/Users/danielstevens/Desktop/CodingReviewer/.venv/bin/python --version

# Install dependencies
pip install fastapi uvicorn pydantic

# Check port availability
lsof -i :8000
```

### Swift Build Issues
- Ensure Xcode is updated
- Check Swift package dependencies
- Verify ARCHITECTURE.md compliance

### API Connection Issues
```bash
# Test connectivity
curl http://localhost:8000/health

# Check server logs
tail -f server.log

# Verify CORS settings
# Check browser network tab for errors
```

## Production Considerations

### Security
- [ ] Add authentication (JWT tokens)
- [ ] Enable HTTPS/TLS
- [ ] Validate all inputs
- [ ] Rate limiting

### Performance
- [ ] Connection pooling
- [ ] Caching strategies
- [ ] Background job queues
- [ ] Health monitoring

### Deployment
- [ ] Docker containers
- [ ] Environment configuration
- [ ] CI/CD pipelines
- [ ] Logging and monitoring

## Future Enhancements

### Phase 3: Advanced Features
- Real-time collaboration
- Advanced automation workflows
- Performance analytics
- Comprehensive testing

### Phase 4: Production
- Cloud deployment
- Monitoring dashboard
- User authentication
- Documentation site

## Support

For issues or questions:
1. Check this usage guide
2. Review ARCHITECTURE.md
3. Test API endpoints manually
4. Check server and client logs
5. Verify environment setup
