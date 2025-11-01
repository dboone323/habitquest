#!/bin/bash

# VS Code MCP Migration Fix Script
# Note: Extensions have been migrated to MCP servers (Nov 2025)
# This script is maintained for backward compatibility

echo "🔧 VS Code Setup - MCP Migration Info..."
echo ""
echo "⚠️  IMPORTANT: This workspace has migrated to MCP servers!"
echo ""
echo "Traditional VS Code extensions have been replaced with MCP (Model Context Protocol) servers."
echo "See MCP_QUICK_REFERENCE.md for details."
echo ""
echo "If you're experiencing issues, please try:"
echo ""
echo "1. Ensure you have the latest GitHub Copilot extensions:"
echo "   - github.copilot"
echo "   - github.copilot-chat"
echo ""
echo "2. Verify MCP settings in Code.code-workspace:"
echo "   - chat.mcp.enabled: true"
echo "   - chat.mcp.autostart: always"
echo ""
echo "3. Check environment variables:"
echo "   - GITHUB_TOKEN should be set for GitHub MCP server"
echo ""
echo "4. Verify Node.js is installed (for npx):"
echo "   node --version  # Should be v18+"
echo ""
echo "5. If you still want to clear VS Code caches (legacy approach):"
read -p "   Clear caches? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Stopping VS Code processes..."
  pkill -f "Code.*Helper" 2>/dev/null || true
  pkill -f "Electron" 2>/dev/null || true
  sleep 2
  
  echo "Clearing VS Code caches..."
  rm -rf ~/Library/Application\ Support/Code/Cache/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code/CachedData/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code/GPUCache/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/Cache/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/CachedData/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/GPUCache/* 2>/dev/null || true
  
  echo "✅ Caches cleared. Please restart VS Code manually."
else
  echo "Skipping cache clear."
fi
echo ""
echo "📚 For more information:"
echo "   - MCP_QUICK_REFERENCE.md - Quick start guide"
echo "   - Documentation/MCP_MIGRATION_GUIDE.md - Full migration details"
