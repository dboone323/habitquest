#!/bin/bash

# VS Code Extension Fix Script
# Resolves Git, Trunk, and Pylance extension errors

echo "🔧 Fixing VS Code Extension Issues..."

# Kill VS Code processes
echo "Stopping VS Code processes..."
pkill -f "Code.*Helper"
pkill -f "Electron"
sleep 2

# Clear VS Code caches
echo "Clearing VS Code caches..."
rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/Cache/*
rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/CachedData/*
rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/GPUCache/*

# Clear extension caches
echo "Clearing extension caches..."
rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/extensions/ms-python.python*
rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/extensions/trunk.io*

# Clear workspace storage
echo "Clearing workspace storage..."
rm -rf ~/Library/Application\ Support/Code\ -\ Insiders/User/workspaceStorage/*

echo "✅ Extension caches cleared. Please restart VS Code manually."
echo ""
echo "📋 Next steps:"
echo "1. Close VS Code completely"
echo "2. Reopen VS Code"
echo "3. Check if extension errors are resolved"
echo "4. If issues persist, try: 'Developer: Reload Window' from Command Palette"