#!/bin/bash
# VS Code Insiders Extension Migration Script
# This script installs all extensions from regular VS Code to VS Code Insiders

echo "🚀 Migrating extensions to VS Code Insiders..."

# Core Development Extensions
echo "📦 Installing Core Development Extensions..."
code-insiders --install-extension ms-vscode.vscode-typescript-next
code-insiders --install-extension ms-python.python
code-insiders --install-extension ms-python.vscode-pylance
code-insiders --install-extension ms-python.debugpy
code-insiders --install-extension swiftlang.swift-vscode
code-insiders --install-extension ms-vscode.cpptools
code-insiders --install-extension llvm-vs-code-extensions.lldb-dap

# AI and Copilot Extensions
echo "🤖 Installing AI and Copilot Extensions..."
code-insiders --install-extension github.copilot
code-insiders --install-extension github.copilot-chat
code-insiders --install-extension continue.continue
code-insiders --install-extension google.geminicodeassist
code-insiders --install-extension openai.chatgpt
code-insiders --install-extension teamsdevapp.vscode-ai-foundry
code-insiders --install-extension ms-windows-ai-studio.windows-ai-studio

# Git and GitHub Extensions
echo "🔄 Installing Git and GitHub Extensions..."
code-insiders --install-extension eamodio.gitlens
code-insiders --install-extension github.vscode-github-actions
code-insiders --install-extension github.vscode-pull-request-github
code-insiders --install-extension ms-vscode.azure-repos
code-insiders --install-extension github.codespaces
code-insiders --install-extension github.remotehub

# Remote Development
echo "🌐 Installing Remote Development Extensions..."
code-insiders --install-extension ms-vscode-remote.remote-containers
code-insiders --install-extension ms-vscode-remote.remote-ssh
code-insiders --install-extension ms-vscode-remote.remote-ssh-edit
code-insiders --install-extension ms-vscode-remote.remote-explorer
code-insiders --install-extension ms-vscode.remote-repositories

# Container and Docker
echo "🐳 Installing Container and Docker Extensions..."
code-insiders --install-extension ms-azuretools.vscode-docker
code-insiders --install-extension docker.docker
code-insiders --install-extension ms-azuretools.vscode-containers
code-insiders --install-extension ms-azuretools.vscode-azureresourcegroups

# Jupyter and Data Science
echo "📊 Installing Jupyter and Data Science Extensions..."
code-insiders --install-extension ms-toolsai.jupyter
code-insiders --install-extension ms-toolsai.jupyter-keymap
code-insiders --install-extension ms-toolsai.jupyter-renderers
code-insiders --install-extension ms-toolsai.vscode-jupyter-cell-tags
code-insiders --install-extension ms-toolsai.vscode-jupyter-slideshow

# Code Quality and Linting
echo "🔍 Installing Code Quality Extensions..."
code-insiders --install-extension dbaeumer.vscode-eslint
code-insiders --install-extension esbenp.prettier-vscode
code-insiders --install-extension streetsidesoftware.code-spell-checker
code-insiders --install-extension redhat.vscode-yaml
code-insiders --install-extension mads-hartmann.bash-ide-vscode

# Productivity and Tools
echo "🛠️ Installing Productivity Extensions..."
code-insiders --install-extension yzhang.markdown-all-in-one
code-insiders --install-extension gruntfuggly.todo-tree
code-insiders --install-extension ms-vscode.makefile-tools
code-insiders --install-extension ms-vscode.test-adapter-converter
code-insiders --install-extension ms-vscode.vscode-speech
code-insiders --install-extension ms-vscode.vscode-websearchforcopilot

# Browser Development
echo "🌐 Installing Browser Development Extensions..."
code-insiders --install-extension ms-edgedevtools.vscode-edge-devtools

echo "✅ Extension migration complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Open VS Code Insiders"
echo "2. Go to Command Palette (Cmd+Shift+P)"
echo "3. Run: 'Developer: Reload Window' to ensure all extensions are loaded"
echo "4. Open your Quantum workspace: File > Open Workspace from File > Select Quantum-workspace.code-workspace"
echo ""
echo "🎯 Your Quantum workspace is ready in VS Code Insiders!"
