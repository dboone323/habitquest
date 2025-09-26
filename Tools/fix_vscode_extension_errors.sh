#!/bin/bash
# Script to fix VS Code extension errors

echo "🔧 Fixing VS Code Extension Errors..."

# 1. Clear VS Code extension cache and logs
echo "Clearing VS Code extension cache..."
rm -rf "${HOME}/.vscode-insiders/logs"
rm -rf "${HOME}/.vscode-insiders/CachedExtensions"
rm -rf "${HOME}/.vscode-insiders/CachedExtensionVSIXs"

# 2. Reset Continue extension data
echo "Resetting Continue extension data..."
rm -rf "${HOME}/.continue"
mkdir -p "${HOME}/.continue"

# 3. Create missing settings for MCP and GitHub Copilot
echo "Creating VS Code settings to resolve warnings..."
VSCODE_SETTINGS_DIR="${HOME}/Library/Application Support/Code - Insiders/User"
mkdir -p "${VSCODE_SETTINGS_DIR}"

# Update settings.json to include MCP and GitHub Copilot settings
SETTINGS_FILE="${VSCODE_SETTINGS_DIR}/settings.json"

# Create or update settings.json
if [[ -f "${SETTINGS_FILE}" ]]; then
  # Backup existing settings
  cp "${SETTINGS_FILE}" "${SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "Backed up existing settings.json"
fi

# Create new settings with MCP and GitHub Copilot configurations
cat >"${SETTINGS_FILE}" <<'EOF'
{
    "mcp": {
        "enabled": true,
        "servers": {},
        "logging": {
            "level": "info"
        }
    },
    "GitHub.copilot.manageExtension": {
        "enabled": true,
        "autoUpdate": true
    },
    "continue.telemetryEnabled": false,
    "continue.manuallyRunningSelfHostedModel": false,
    "gemini.excludePatterns": [
        "**/node_modules/**",
        "**/dist/**",
        "**/build/**",
        "**/target/**",
        "**/.git/**",
        "**/output:*"
    ],
    "files.exclude": {
        "**/output:*": true
    },
    "search.exclude": {
        "**/output:*": true
    }
}
EOF

echo "✅ Updated VS Code settings.json"

# 4. Fix file system provider issues
echo "Fixing filesystem provider issues..."
# Clear workspace state that might have invalid paths
rm -rf "${HOME}/Library/Application Support/Code - Insiders/User/workspaceStorage"

# 5. Restart VS Code extension host
echo "Extension fixes applied. Please:"
echo "1. Restart VS Code Insiders"
echo "2. Reload the window (Cmd+Shift+P -> 'Developer: Reload Window')"
echo "3. If issues persist, disable and re-enable problematic extensions"

echo "🎉 VS Code extension error fixes completed!"
