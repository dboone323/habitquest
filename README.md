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

- **MCP Integration**: Model Context Protocol servers for AI tools (migrated Nov 2025)
- GitHub Copilot with enhanced context via MCP servers
- Intelligent code review and enhancement
- Automated testing and validation
- Smart build and deployment systems
- See [MCP Migration Guide](Documentation/MCP_MIGRATION_GUIDE.md)

### 🔄 Advanced Automation

- Multi-project CI/CD pipelines
- Automated dependency management
- Workflow orchestration and monitoring

### 📊 Comprehensive Monitoring

- Real-time performance tracking
- Build status dashboards
- Quality metrics and reporting

### 🛠️ Development Excellence

- SwiftFormat & SwiftLint integration (command-line tools)
- Pre-commit hooks for code quality
- Cross-platform build support
- MCP servers for AI-enhanced workflows
- See [MCP Quick Reference](MCP_QUICK_REFERENCE.md)

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
