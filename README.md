# Quantum Workspace

A comprehensive development environment for iOS/macOS applications with advanced automation, AI integration, and cross-platform capabilities.

## 🚀 Quick Start

1. **Clone and Setup**:

   ```bash
   git clone <repository-url>
   cd Quantum-workspace
   ./Tools/scripts/setup_workspace.sh
   ```

2. **Install Dependencies**:

   ```bash
   ./Tools/Automation/setup_venv.sh
   pre-commit install
   ```

3. **Open in VS Code**:
   - Use Dev Containers for full environment
   - Or open directly with local development setup

## 📁 Workspace Structure

```
Quantum-workspace/
├── 📱 Projects/           # Main application projects
│   ├── AvoidObstaclesGame/
│   ├── CodingReviewer/
│   ├── HabitQuest/
│   ├── MomentumFinance/
│   └── PlannerApp/
├── 🔧 Tools/             # Development tools & automation
│   ├── Automation/       # CI/CD & deployment scripts
│   ├── Config/          # Configuration files
│   ├── Containers/      # Docker setup
│   ├── Monitoring/      # Performance monitoring
│   ├── scripts/         # Utility scripts
│   └── logs/            # Log files
├── 🔗 Shared/            # Shared components
│   ├── Intelligence/    # AI/ML components
│   ├── Sources/         # Shared Swift code
│   └── Testing/         # Test utilities
├── 🧪 Testing/           # Test project versions
├── 📚 docs/              # Documentation
└── ⚙️ .workspace/        # Consolidated config
    ├── .vscode/         # VS Code settings
    ├── .github/         # GitHub workflows
    └── .trunk/          # Code quality tools
```

## 🎯 Key Features

### 🤖 AI-Powered Development

- Intelligent code review and enhancement
- Automated testing and validation
- Smart build and deployment systems

### 🔄 Advanced Automation

- Multi-project CI/CD pipelines
- Automated dependency management
- Workflow orchestration and monitoring

### 📊 Comprehensive Monitoring

- **Tool Health Monitoring**: Automated monitoring of 14 essential development tools
- **Real-time Dashboards**: Live performance tracking and status visualization
- **Alerting System**: Critical issue notifications and system health alerts
- **Performance Benchmarking**: Response time tracking and trend analysis
- **Build Status Tracking**: CI/CD pipeline monitoring and reporting
- **Quality Metrics**: Code quality and test coverage reporting

**Quick Monitoring Commands**:
```bash
# Run complete monitoring suite
./Tools/monitoring_integration.sh

# Check tool health status
./Tools/tool_health_monitor.sh status

# View recent alerts
./Tools/tool_alerts.sh show

# Run performance benchmark
./Tools/tool_benchmark.sh run
```

**Dashboard Access**:
- **URL**: http://localhost:8004/dashboard
- **API**: http://localhost:8004/api/dashboard-data

### 🛠️ Development Excellence

- SwiftFormat & SwiftLint integration
- Pre-commit hooks for code quality
- Cross-platform build support

## 📚 Documentation

- **[Full Documentation](docs/)** - Complete guides and references
- **[Architecture](docs/architecture/)** - System design docs
- **[Enhancements](docs/enhancements/)** - AI features
- **[Guides](docs/guides/)** - Tutorials and setup

## 🏗️ Projects

### iOS Applications

- **AvoidObstaclesGame** - iOS game with obstacle avoidance mechanics
- **HabitQuest** - Habit tracking and gamification app
- **MomentumFinance** - Financial management and tracking
- **PlannerApp** - Task planning and organization tool

### Development Tools

- **CodingReviewer** - AI-powered code review and analysis tool

## 🚀 Development Workflow

1. **Local Development**: Use VS Code with local Swift toolchain
2. **Container Development**: Use Dev Containers for consistent environment
3. **Testing**: Use test versions in `Testing/` folder
4. **CI/CD**: Automated pipelines handle building and deployment

## 🤝 Contributing

See [Contributing Guide](docs/guides/CONTRIBUTING.md) for development guidelines.

## 📄 License

See individual project licenses for details.
