#!/bin/bash

# CodingReviewer Web Build Script
# Builds SwiftWasm application for web deployment

set -e

PROJECT_NAME="CodingReviewerWeb"
BUILD_DIR="build"
SOURCE_DIR="Sources/${PROJECT_NAME}"

echo "🏗️  Building CodingReviewer Web with SwiftWasm..."

# Check if swiftwasm is available
if ! command -v swiftwasm &> /dev/null; then
    echo "❌ Error: swiftwasm toolchain not found"
    echo "Install SwiftWasm: https://book.swiftwasm.org/getting-started/setup.html"
    exit 1
fi

# Create build directory
mkdir -p "${BUILD_DIR}"

# Build with SwiftWasm
echo "📦 Compiling Swift code to WebAssembly..."
swiftwasm build \
    --triple wasm32-unknown-wasi \
    --configuration release \
    --build-path "${BUILD_DIR}"

# Check if build succeeded
if [[ ! -f "${BUILD_DIR}/release/${PROJECT_NAME}.wasm" ]]; then
    echo "❌ Build failed - WASM file not found"
    exit 1
fi

# Copy HTML and create distribution
echo "📋 Creating web distribution..."
cp "index.html" "${BUILD_DIR}/"
cp "${BUILD_DIR}/release/${PROJECT_NAME}.wasm" "${BUILD_DIR}/"

# Generate JavaScript wrapper if needed
if [[ -f "${BUILD_DIR}/release/${PROJECT_NAME}.js" ]]; then
    cp "${BUILD_DIR}/release/${PROJECT_NAME}.js" "${BUILD_DIR}/"
fi

echo "✅ Build complete!"
echo "📁 Distribution files:"
echo "   - ${BUILD_DIR}/index.html"
echo "   - ${BUILD_DIR}/${PROJECT_NAME}.wasm"
if [[ -f "${BUILD_DIR}/${PROJECT_NAME}.js" ]]; then
    echo "   - ${BUILD_DIR}/${PROJECT_NAME}.js"
fi

echo ""
echo "🌐 To serve locally:"
echo "   cd ${BUILD_DIR} && python3 -m http.server 8000"
echo "   Open http://localhost:8000 in your browser"

echo ""
echo "🚀 Deployment ready for:"
echo "   - GitHub Pages"
echo "   - Netlify"
echo "   - Vercel"
echo "   - Any static web host"
