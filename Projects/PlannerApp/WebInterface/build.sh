#!/bin/bash

# PlannerApp Web Build Script
# Compiles Swift code to WebAssembly for web deployment

set -e

echo "🚀 Building PlannerApp Web with SwiftWasm..."

# Check if swiftwasm is available
if ! command -v swiftwasm &> /dev/null; then
    echo "❌ Error: swiftwasm toolchain not found"
    echo "Please install SwiftWasm toolchain:"
    echo "  curl -sL https://github.com/swiftwasm/swiftwasm-install/releases/download/0.1.0/swiftwasm-install.sh | bash"
    exit 1
fi

# Set working directory to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 Working directory: $PWD"

# Create build directory
BUILD_DIR="$SCRIPT_DIR/build"
mkdir -p "$BUILD_DIR"

echo "🔨 Compiling Swift to WebAssembly..."

# Build with SwiftWasm
swiftwasm build \
    --configuration release \
    --build-path "$BUILD_DIR" \
    --triple wasm32-unknown-wasi

echo "📦 Generating JavaScript wrapper..."

# The build should generate PlannerAppWeb.wasm and PlannerAppWeb.js
if [ -f "$BUILD_DIR/release/PlannerAppWeb.wasm" ]; then
    echo "✅ WebAssembly module generated: PlannerAppWeb.wasm"

    # Copy WASM file to web directory
    cp "$BUILD_DIR/release/PlannerAppWeb.wasm" "$SCRIPT_DIR/"

    # Generate JavaScript wrapper if not already present
    if [ ! -f "$SCRIPT_DIR/PlannerAppWeb.js" ]; then
        cat > "$SCRIPT_DIR/PlannerAppWeb.js" << 'EOF'
// PlannerAppWeb JavaScript Wrapper
// Generated for SwiftWasm integration

class PlannerAppWebLoader {
    constructor() {
        this.instance = null;
        this.memory = null;
    }

    async load() {
        try {
            console.log('Loading PlannerApp WebAssembly module...');

            const importObject = {
                wasi_snapshot_preview1: {
                    // WASI imports would go here
                    proc_exit: () => {},
                    fd_write: () => {},
                    fd_read: () => {},
                    fd_close: () => {},
                    fd_seek: () => {},
                    clock_time_get: () => {},
                    random_get: () => {},
                },
                env: {
                    memory: new WebAssembly.Memory({ initial: 256 }),
                }
            };

            const response = await fetch('PlannerAppWeb.wasm');
            const buffer = await response.arrayBuffer();
            const module = await WebAssembly.compile(buffer);
            this.instance = await WebAssembly.instantiate(module, importObject);

            console.log('PlannerApp WebAssembly module loaded successfully');

            // Call Swift main function
            if (this.instance.exports.main) {
                this.instance.exports.main();
            }

            // Hide loading indicator
            const loading = document.getElementById('loading');
            if (loading) {
                loading.style.display = 'none';
            }

        } catch (error) {
            console.error('Failed to load PlannerApp WebAssembly module:', error);
            const loading = document.getElementById('loading');
            if (loading) {
                loading.innerHTML = '❌ Failed to load PlannerApp Web<br>' + error.message;
            }
        }
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    const loader = new PlannerAppWebLoader();
    loader.load();
});
EOF
        echo "✅ JavaScript wrapper generated: PlannerAppWeb.js"
    else
        echo "ℹ️  JavaScript wrapper already exists"
    fi

    echo ""
    echo "🎉 Build completed successfully!"
    echo ""
    echo "📁 Output files:"
    echo "   - PlannerAppWeb.wasm (WebAssembly module)"
    echo "   - PlannerAppWeb.js (JavaScript wrapper)"
    echo "   - index.html (Web interface)"
    echo ""
    echo "🌐 To test locally:"
    echo "   1. Start a local web server:"
    echo "      python3 -m http.server 8000"
    echo "   2. Open http://localhost:8000 in your browser"
    echo ""
    echo "📤 For deployment:"
    echo "   Upload PlannerAppWeb.wasm, PlannerAppWeb.js, and index.html to your web server"

else
    echo "❌ Error: WebAssembly module not found in build directory"
    echo "Build directory contents:"
    ls -la "$BUILD_DIR/release/" 2>/dev/null || echo "Build directory is empty"
    exit 1
fi
