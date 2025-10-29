#!/bin/bash

# Build script for Quantum Web Tools (SwiftWasm)
# This script builds the SwiftWasm application for web deployment

set -e

echo "🔨 Building Quantum Web Tools with SwiftWasm..."

# Check if swiftwasm is available
if ! command -v swiftwasm &>/dev/null; then
    echo "❌ swiftwasm not found. Please install SwiftWasm:"
    echo "   curl -sL https://github.com/swiftwasm/swiftwasm-install/releases/download/0.1.0/swiftwasm-install.sh | bash"
    exit 1
fi

# Create build directory
mkdir -p build

# Build for WebAssembly
echo "📦 Building Swift code for WebAssembly..."
cd Sources/QuantumWebTools
swiftwasm build --triple wasm32-unknown-wasi --configuration release

# Copy build artifacts
echo "📋 Copying build artifacts..."
cp .build/release/QuantumWebTools.wasm ../../build/
cp .build/release/QuantumWebTools.js ../../build/

cd ../..

# Copy HTML file
cp index.html build/

echo "✅ Build completed successfully!"
echo ""
echo "🚀 To serve the web application:"
echo "   cd build && python3 -m http.server 8000"
echo "   Open http://localhost:8000 in your browser"
echo ""
echo "📁 Build artifacts are in the 'build' directory"
