# MCP Server Migration Guide

## Overview

This document describes the migration from VS Code extensions to MCP (Model Context Protocol) servers completed on November 1, 2025. MCP servers provide better integration, security, and standardization for AI-powered development tools compared to traditional VS Code extensions.

## What is MCP?

Model Context Protocol (MCP) is an open protocol that standardizes how AI applications provide context to Large Language Models (LLMs). Unlike traditional VS Code extensions that operate within the editor's constraints, MCP servers:

- Provide direct, standardized access to tools and data sources
- Offer better security through controlled access patterns
- Enable consistent AI integration across different tools
- Support more flexible deployment options
- Improve performance through optimized data transfer

## Migration Summary

### Previous Extension-Based Setup

The workspace previously relied on the following VS Code extensions:

1. **swiftlang.swift-vscode** - Swift language support
2. **github.vscode-github-actions** - GitHub Actions integration
3. **streetsidesoftware.code-spell-checker** - Spell checking
4. **esbenp.prettier-vscode** - Code formatting
5. **dbaeumer.vscode-eslint** - ESLint linting
6. **ms-python.python** - Python language support
7. **ms-python.black-formatter** - Python Black formatter
8. **swiftformat.swiftformat-vscode** - Swift code formatting
9. **gitlab.commitizen** - Conventional commits
10. **eamodio.gitlens** - Git visualization
11. **github.vscode-pull-request-github** - GitHub PR management
12. **ollama.vscode-ollama** - Local AI model integration

### New MCP Server-Based Setup

The migration implements the following MCP servers:

1. **GitHub MCP Server** (`@modelcontextprotocol/server-github`)
   - Replaces: GitHub Actions extension, GitHub PR extension, GitLens
   - Provides: Repository access, PR management, Actions monitoring, Git history
   - Configuration: Requires GITHUB_TOKEN environment variable

2. **Filesystem MCP Server** (`@modelcontextprotocol/server-filesystem`)
   - Replaces: Direct file system operations
   - Provides: Structured file access, directory navigation, file watching
   - Configuration: Scoped to workspace folder

3. **Git MCP Server** (`@modelcontextprotocol/server-git`)
   - Replaces: GitLens functionality
   - Provides: Git operations, history, blame, diff analysis
   - Configuration: Scoped to workspace folder

4. **Shell MCP Server** (`@modelcontextprotocol/server-shell`)
   - Replaces: Manual terminal operations
   - Provides: Automated script execution, command running
   - Configuration: Available for automation tasks

5. **Memory MCP Server** (`@modelcontextprotocol/server-memory`)
   - New capability: Persistent context storage for AI
   - Provides: Session memory, context preservation
   - Configuration: Automatic persistence

### Extensions That Remain as Language Services

Some functionality is still provided by language-specific tooling:

- **Swift Language Support**: Managed by Swift toolchain and LSP
- **Python Language Support**: Managed by Python LSP and built-in VS Code support
- **Code Formatting**: Handled by native formatters (swiftformat, black) via command line
- **Linting**: Handled by native linters (swiftlint, eslint) via command line
- **Spell Checking**: Now handled by cspell command line tool (see cspell.json)

## Configuration Files

### 1. `.vscode/mcp-settings.json`

This file contains the MCP server configurations for direct usage:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/workspace"]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git", "/path/to/workspace"]
    },
    "shell": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-shell"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

### 2. `Code.code-workspace`

The main workspace file has been updated with MCP settings:

```json
{
  "settings": {
    "chat.mcp.autostart": "always",
    "chat.mcp.enabled": true,
    "mcp.servers": {
      "github": { ... },
      "filesystem": { ... },
      "git": { ... }
    }
  },
  "extensions": {
    "recommendations": [
      "github.copilot",
      "github.copilot-chat"
    ]
  }
}
```

### 3. `.vscode/extensions.json` and `Projects/.vscode/extensions.json`

These files now document deprecated extensions and recommend only Copilot:

```json
{
  "recommendations": ["github.copilot", "github.copilot-chat"],
  "deprecated": ["swiftlang.swift-vscode", ...]
}
```

## Environment Setup

### Required Environment Variables

1. **GITHUB_TOKEN**: Personal access token for GitHub MCP server
   ```bash
   export GITHUB_TOKEN="ghp_your_token_here"
   ```

### Required Dependencies

MCP servers are distributed via npm. Ensure Node.js and npm are installed:

```bash
node --version  # Should be v18 or higher
npm --version   # Should be v9 or higher
```

The MCP servers will be automatically installed via `npx` when first accessed.

## Migration Benefits

### For AI-Powered Development

1. **Better Context**: MCP servers provide richer, more structured context to AI
2. **Consistent Integration**: Same tools work across different AI platforms
3. **Real-time Updates**: Servers can push updates rather than polling
4. **Reduced Overhead**: Direct protocol communication vs. extension APIs

### For Automation

1. **Programmatic Access**: MCP servers can be used in automation scripts
2. **Standardized Interface**: Same API across different tools
3. **Better Performance**: Optimized for batch operations
4. **Improved Security**: Fine-grained access control

### For Maintenance

1. **Simplified Dependencies**: Fewer extensions to manage
2. **Version Control**: MCP servers version independently
3. **Easier Updates**: `npx` automatically handles versions
4. **Better Documentation**: Standardized protocol documentation

## Automation Script Updates

### Tools That Now Use MCP Servers

The following automation scripts can potentially leverage MCP servers:

1. **Master Automation** (`Tools/Automation/master_automation.sh`)
   - Can use Git MCP server for repository operations
   - Can use Shell MCP server for command execution

2. **GitHub Workflows** (`.github/workflows/*`)
   - Can use GitHub MCP server for Actions integration
   - Already configured via GITHUB_TOKEN

3. **Quality Checks** (`run_code_quality_checks.sh`)
   - Uses command-line tools (no change needed)
   - MCP Shell server available for future enhancements

### No Changes Required

Most automation scripts continue to work as-is because they:
- Use command-line tools directly (swiftlint, swiftformat, etc.)
- Operate via git CLI (already works)
- Run independently of VS Code

## Testing MCP Integration

### Verify MCP Servers Are Running

1. Open VS Code with the workspace
2. Open GitHub Copilot Chat
3. Check that MCP servers start automatically (see status bar)
4. Test each server:

   ```
   @github list repositories
   @git show recent commits
   ```

### Test GitHub MCP Server

```bash
# Verify GITHUB_TOKEN is set
echo $GITHUB_TOKEN

# Test via command line (if MCP CLI is available)
npx @modelcontextprotocol/server-github --test
```

### Test Filesystem and Git MCP Servers

These should work automatically within VS Code Copilot Chat:

```
Can you list the files in the Projects directory?
What's the latest commit in this repository?
```

## Rollback Procedure

If issues arise with MCP servers, you can temporarily revert:

1. **Restore Extension Recommendations**:
   ```bash
   git checkout HEAD~1 -- .vscode/extensions.json
   git checkout HEAD~1 -- Projects/.vscode/extensions.json
   ```

2. **Disable MCP in Workspace**:
   Edit `Code.code-workspace`:
   ```json
   "chat.mcp.enabled": false
   ```

3. **Reinstall Extensions**:
   Open VS Code and install recommended extensions from the restored files.

## Future Enhancements

### Planned MCP Servers

1. **Database MCP Server**: For Quantum Finance data operations
2. **Swift Package MCP Server**: For Swift dependency management
3. **Custom Automation MCP Server**: For Quantum-workspace specific operations

### Integration Opportunities

1. **CI/CD Pipeline**: Use MCP servers in GitHub Actions
2. **Local AI**: Integrate with Ollama via MCP
3. **Documentation**: Auto-generate docs via MCP servers

## Troubleshooting

### MCP Servers Not Starting

**Problem**: MCP servers don't start automatically

**Solutions**:
1. Check `chat.mcp.autostart` is set to "always"
2. Verify Node.js and npm are installed
3. Check network access (npx needs to download packages)
4. Review VS Code output panel for errors

### GitHub MCP Server Authentication Issues

**Problem**: GitHub operations fail with auth errors

**Solutions**:
1. Verify GITHUB_TOKEN environment variable is set
2. Check token has required scopes (repo, workflow)
3. Ensure token is not expired
4. Try regenerating the token

### Performance Issues

**Problem**: Slow response from MCP servers

**Solutions**:
1. Check network connectivity
2. Consider pre-installing MCP servers globally:
   ```bash
   npm install -g @modelcontextprotocol/server-github
   npm install -g @modelcontextprotocol/server-filesystem
   npm install -g @modelcontextprotocol/server-git
   ```
3. Adjust `chat.agent.maxRequests` if needed

### Command-Line Tools Still Needed

**Problem**: Some operations still require command-line tools

**Solutions**:
This is expected! MCP servers complement but don't replace:
- SwiftLint/SwiftFormat: Use command-line tools
- Black formatter: Use command-line tool
- Build tools: Use xcodebuild, swift build, etc.

The migration focuses on AI integration, not replacing all tooling.

## References

- [Model Context Protocol Specification](https://github.com/modelcontextprotocol)
- [MCP Server GitHub](https://github.com/modelcontextprotocol/server-github)
- [VS Code MCP Integration](https://code.visualstudio.com/docs/copilot/chat-mcp)
- [Quantum-workspace Architecture](./ARCHITECTURE.md)

## Support

For issues or questions:
1. Check this guide and troubleshooting section
2. Review MCP server documentation
3. Check Quantum-workspace issue tracker
4. Contact repository maintainers

---

**Migration Date**: November 1, 2025  
**Migration Status**: ✅ Complete  
**Next Review**: December 1, 2025
