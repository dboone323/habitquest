# Trunk Integration for Quantum-workspace

This document explains the Trunk integration setup for the unified workspace.

## Overview

[Trunk](https://trunk.io) is a meta-linter and formatter that combines multiple linting tools into a single, fast workflow. It's now integrated at the workspace root level to provide consistent code quality across all projects.

## Configuration Location

- **Main config**: `.trunk/trunk.yaml`
- **Tool configs**: `.trunk/configs/`
- **GitHub Actions**: `.github/workflows/trunk.yml`

## Supported Languages & Tools

### Languages Covered
- **Swift**: 904+ files (SwiftFormat + SwiftLint)
- **Shell**: 923+ scripts (ShellCheck + shfmt)
- **Python**: 224+ files (Black, isort, ruff, bandit)
- **Markdown**: 1181+ files (markdownlint, prettier)
- **YAML**: All workflow and config files (yamllint)

### Linters Enabled
- `actionlint` - GitHub Actions workflows
- `bandit` - Python security linting
- `black` - Python code formatting
- `checkov` - Infrastructure security scanning
- `git-diff-check` - Git whitespace issues
- `isort` - Python import sorting
- `markdownlint` - Markdown style checking
- `osv-scanner` - Security vulnerability scanning
- `prettier` - General code formatting
- `ruff` - Fast Python linter
- `shellcheck` - Shell script analysis
- `shfmt` - Shell script formatting
- `swiftformat` - Swift code formatting
- `swiftlint` - Swift code style checking
- `trufflehog` - Secret detection
- `yamllint` - YAML file linting

## Validation

Run the validation script to check setup:

```bash
./Tools/validate-trunk-setup.sh
```

## GitHub Actions Integration

Two workflows provide trunk integration:

1. **`trunk.yml`** - Comprehensive linting on all PRs and pushes
2. **`validate-and-lint-pr.yml`** - Updated to use trunk for automation script checking

## Benefits

- **Single Command**: One tool instead of managing multiple linters
- **Fast**: Parallel execution and intelligent caching
- **Consistent**: Same rules across all projects and contributors
- **Automated**: GitHub Actions integration provides status checks
- **Comprehensive**: Security scanning + code quality + formatting

## Usage in Merge Queue

The trunk workflows provide the status checks that GitHub's merge queue requires. The configurations ensure:

- Required status checks are declared in `.trunk/trunk.yaml`
- Branch protection rules can reference "Trunk Check Runner" and "Trunk Format Check" statuses
- All linting must pass before merging

## Local Development

While trunk CLI cannot be installed in the sandbox environment, the configuration is ready for local development:

```bash
# Install trunk locally
curl -fsSL https://trunk.io/releases/trunk | bash

# Run checks
trunk check

# Format files  
trunk fmt

# Check specific files
trunk check path/to/file.swift
```

## Compatibility

- Preserves existing `.swiftformat` configuration
- Works with individual project `.swiftlint.yml` files
- Integrates with existing automation tools
- Compatible with unified workspace architecture