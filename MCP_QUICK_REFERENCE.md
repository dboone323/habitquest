# MCP Quick Reference

## What Changed?

✅ **MCP servers** are now the primary way AI tools access your code  
❌ Most VS Code extensions have been deprecated  
🎯 Focus: Better AI integration with GitHub Copilot

## Daily Workflow

### Using Copilot Chat with MCP

MCP servers automatically provide context. Just ask naturally:

```
Show me recent commits
What files changed in the last PR?
List all Swift files in Projects/
Check the status of GitHub Actions
```

### Available MCP Servers

- **@github**: GitHub operations (repos, PRs, Actions)
- **@git**: Git operations (commits, diffs, branches)
- **@filesystem**: File operations
- **@shell**: Run commands
- **@memory**: Persistent AI context

### Tools Still Used via Command Line

```bash
# Swift formatting
swiftformat .

# Swift linting
swiftlint

# Python formatting
black .

# Spell checking
npx cspell "**/*.{swift,md,py}"

# Master automation
./Tools/Automation/master_automation.sh status
```

## Quick Setup Check

```bash
# 1. Verify environment
echo $GITHUB_TOKEN  # Should show your token

# 2. Verify Node.js
node --version  # v18+

# 3. Open workspace
code Code.code-workspace

# 4. Check MCP status in VS Code
# Look for MCP indicator in status bar
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| MCP not starting | Check VS Code settings: `chat.mcp.enabled` |
| GitHub auth fails | Set GITHUB_TOKEN environment variable |
| Slow performance | Pre-install: `npm i -g @modelcontextprotocol/server-*` |

## Key Files

- `.vscode/mcp-settings.json` - MCP configuration
- `Code.code-workspace` - Workspace with MCP settings
- `Documentation/MCP_MIGRATION_GUIDE.md` - Full guide

## Need Extensions?

Only these are recommended now:
- github.copilot
- github.copilot-chat

Everything else is handled by MCP servers or command-line tools.

---
Updated: 2025-11-01
