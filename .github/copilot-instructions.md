# Quantum Workspace - Unified iOS Development Environment

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Environment Setup
- Install Python packages: `pip3 install pyyaml flask requests pytest --user` (takes 3-5 seconds)
- Check system tools: `which python3 shellcheck git` (all available)
- **CRITICAL**: iOS build tools (xcodebuild, SwiftLint, SwiftFormat) are NOT available in Linux environment

### Core Repository Commands
- Master automation status: `./Automation/master_automation.sh status` (takes <1 second)
- Validate workflows: `bash Tools/Automation/deploy_workflows_all_projects.sh --validate` (takes <1 second) 
- Architecture validation: `python3 Automation/check_architecture.py --project Projects/CodingReviewer` (takes <1 second)
- **NEVER CANCEL**: All commands in this repository complete within 10 seconds

### Linting and Quality Checks
- Shell script linting: `shellcheck Automation/master_automation.sh` (takes <1 second)
- Shell script linting (workflows): `shellcheck Tools/Automation/deploy_workflows_all_projects.sh` (takes <1 second) 
- Python module execution: `python3 Projects/CodingReviewer/CodingReviewer/TestFiles_Manual/test_module_4.py` (takes <1 second)
- pytest (with warnings): `pytest Projects/CodingReviewer/CodingReviewer/TestFiles_Manual/ -v` (takes <1 second)

## Repository Structure

### Projects (5 iOS Swift Applications)
```
Projects/
├── CodingReviewer/        # 277+ Swift files - Code review app
├── AvoidObstaclesGame/    # Game with test runner script  
├── PlannerApp/           # Planning application
├── HabitQuest/           # Habit tracking app (minimal files)
├── MomentumFinance/      # Finance app (minimal files)  
└── Tools/                # Project-specific tools
```

### Automation System
```
Automation/
├── master_automation.sh       # Main automation controller
├── check_architecture.py      # Architecture validation
├── agents/                     # Automation agents
└── requirements.txt           # Python dependencies
```

### GitHub Workflows  
```
.github/workflows/
├── pr-validation.yml          # Basic PR validation
├── validate-and-lint-pr.yml   # Automation linting
└── quantum-agent-self-heal.yml # Self-healing automation
```

## Build and Test Limitations

### What DOES NOT Work (Linux Environment)
- **iOS Building**: `xcodebuild` commands fail - not available on Linux
- **iOS Simulators**: Cannot run iOS simulators or launch iOS apps  
- **SwiftLint/SwiftFormat**: Native tools not available (configurations exist but tools missing)
- **macOS-Specific Paths**: Scripts referencing `/Users/` paths fail with permission errors
- **Native iOS Testing**: XCTest frameworks cannot run

### What DOES Work  
- **Python Automation**: All Python scripts in Automation/ directory
- **Shell Script Validation**: shellcheck works perfectly for .sh files
- **Workflow Validation**: YAML syntax validation and deployment scripts
- **Architecture Analysis**: Python-based architecture checking
- **Code Analysis**: Python test modules run independently  
- **Repository Management**: Git operations, file analysis, documentation

## Validation Scenarios

### Architecture Validation Workflow
1. **Run Master Status**: `./Automation/master_automation.sh status` 
2. **Check Architecture**: `python3 Automation/check_architecture.py --project Projects/CodingReviewer`
3. **Validate Workflows**: `bash Tools/Automation/deploy_workflows_all_projects.sh --validate`
4. **Lint Shell Scripts**: `shellcheck Automation/master_automation.sh`

### Code Quality Validation  
1. **Python Module Testing**: Execute test modules individually (e.g., `python3 Projects/CodingReviewer/CodingReviewer/TestFiles_Manual/test_module_4.py`)
2. **pytest Execution**: `pytest Projects/CodingReviewer/CodingReviewer/TestFiles_Manual/ -v` (expect warnings, no failures)
3. **Shell Script Analysis**: `shellcheck` on automation scripts
4. **Python Package Installation**: `pip3 install` for required automation packages

### Repository Analysis Workflow
1. **Count Swift Files**: `find Projects/ -name "*.swift" | wc -l` (expect 197+ files)
2. **Check Test Files**: `find Projects/ -name "*Test*.swift | head -10` (view available test files) 
3. **Examine Project Structure**: `ls -la Projects/*/` (see each project's organization)
4. **Review Configuration**: Check `.swiftformat`, `quality-config.yaml`, `Code.code-workspace`

## Common Tasks

### Repository Navigation Commands
```bash
# List all Swift files by project  
find Projects/ -name "*.swift" | head -5

# Show project directory structure
ls -la Projects/*/

# Count files by type
find . -name "*.swift" | wc -l      # Swift files (197+)
find . -name "*.py" | wc -l         # Python files
find . -name "*.sh" | wc -l         # Shell scripts  
```

### Quality Gate Commands  
```bash
# Architecture validation
python3 Automation/check_architecture.py --project Projects/CodingReviewer

# Shell script validation  
shellcheck Automation/master_automation.sh

# Workflow syntax validation
bash Tools/Automation/deploy_workflows_all_projects.sh --validate
```

### Quick Status Commands
```bash  
# Master automation status
./Automation/master_automation.sh status

# Available automation commands
./Automation/master_automation.sh list

# Tool availability check
which python3 shellcheck git pip3
```

## Development Workflow

### For Repository Changes
1. **Always validate automation first**: Run `./Automation/master_automation.sh status`
2. **Check affected workflows**: Use `bash Tools/Automation/deploy_workflows_all_projects.sh --validate`  
3. **Lint modified shell scripts**: Apply `shellcheck` to any .sh files changed
4. **Test Python components**: Execute relevant test modules in TestFiles_Manual/
5. **Verify repository structure**: Ensure Projects/ organization is maintained

### For Swift Code Analysis (Without Building)  
1. **Examine Swift file structure**: Use `find` and `ls` commands to analyze code organization
2. **Check architecture compliance**: Run `python3 Automation/check_architecture.py --project Projects/[ProjectName]`
3. **Review test file organization**: Look for `*Test*.swift` files in each project
4. **Analyze imports and dependencies**: Use grep/text analysis on Swift files

### For Automation Enhancements
1. **Install Python dependencies**: `pip3 install --user` any required packages  
2. **Test automation scripts**: Execute scripts in Automation/ directory
3. **Validate workflow changes**: Always run validation commands before committing
4. **Check shell script quality**: Apply shellcheck to new/modified .sh files

## Critical Notes

- **NEVER attempt iOS builds** - use architecture analysis and code review instead
- **NEVER wait longer than 10 seconds** - all working commands complete quickly  
- **ALWAYS validate automation changes** - use provided validation scripts
- **Repository has 197+ Swift files** organized across 5 iOS projects
- **Python automation system** is the primary working development tool in this environment
- **Use text analysis and file structure** examination for Swift code understanding
- **Focus on repository organization, automation, and workflow management** rather than iOS compilation