#!/bin/bash

# AvoidObstaclesGame Web Build Script
# Compiles Swift code to WebAssembly for web-based game deployment

set -e

echo "🎮 Building Avoid Obstacles Game Web with SwiftWasm..."

# Check if carton is available
if ! command -v carton &> /dev/null; then
    echo "❌ Error: carton (SwiftWasm toolchain) not found"
    echo "Please install carton:"
    echo "  git clone https://github.com/swiftwasm/carton.git"
    echo "  cd carton && swift run carton --version"
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

# Check for SDK compatibility issues
echo "⚠️  Note: SwiftWasm toolchain may have SDK compatibility issues on macOS Sequoia"
echo "   If build fails, consider using Docker containers or alternative toolchains"

# Build with Carton (SwiftWasm)
if carton build \
    --release \
    --build-path "$BUILD_DIR"; then

    echo "🎨 Generating JavaScript wrapper for game..."

    # The build should generate AvoidObstaclesGameWeb.wasm and AvoidObstaclesGameWeb.js
    if [ -f "$BUILD_DIR/release/AvoidObstaclesGameWeb.wasm" ]; then
        echo "✅ WebAssembly game module generated: AvoidObstaclesGameWeb.wasm"

        # Copy WASM file to web directory
        cp "$BUILD_DIR/release/AvoidObstaclesGameWeb.wasm" "$SCRIPT_DIR/"

        # Generate JavaScript wrapper if not already present
        if [ ! -f "$SCRIPT_DIR/AvoidObstaclesGameWeb.js" ]; then
            cat > "$SCRIPT_DIR/AvoidObstaclesGameWeb.js" << 'EOF'
// AvoidObstaclesGameWeb JavaScript Wrapper
// Generated for SwiftWasm game integration

class AvoidObstaclesGameWebLoader {
    constructor() {
        this.instance = null;
        this.memory = null;
        this.gameStarted = false;
    }

    async load() {
        try {
            console.log('Loading Avoid Obstacles Game WebAssembly module...');

            const importObject = {
                wasi_snapshot_preview1: {
                    // WASI imports for game
                    proc_exit: () => {},
                    fd_write: () => {},
                    fd_read: () => {},
                    fd_close: () => {},
                    fd_seek: () => {},
                    clock_time_get: () => Date.now() * 1000000,
                    random_get: (buffer, length) => {
                        const array = new Uint8Array(buffer);
                        for (let i = 0; i < length; i++) {
                            array[i] = Math.floor(Math.random() * 256);
                        }
                        return 0;
                    },
                },
                env: {
                    memory: new WebAssembly.Memory({ initial: 256 }),
                }
            };

            const response = await fetch('AvoidObstaclesGameWeb.wasm');
            const buffer = await response.arrayBuffer();
            const module = await WebAssembly.compile(buffer);
            this.instance = await WebAssembly.instantiate(module, importObject);

            console.log('Avoid Obstacles Game WebAssembly module loaded successfully');

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
            console.error('Failed to load Avoid Obstacles Game WebAssembly module:', error);
            const loading = document.getElementById('loading');
            if (loading) {
                loading.innerHTML = '❌ Failed to load game<br>' + error.message;
            }
        }
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    const loader = new AvoidObstaclesGameWebLoader();
    loader.load();
});
EOF
            echo "✅ JavaScript wrapper generated: AvoidObstaclesGameWeb.js"
        else
            echo "ℹ️  JavaScript wrapper already exists"
        fi

        echo ""
        echo "🎉 Game build completed successfully!"
        echo ""
        echo "📁 Output files:"
        echo "   - AvoidObstaclesGameWeb.wasm (WebAssembly game module)"
        echo "   - AvoidObstaclesGameWeb.js (JavaScript game wrapper)"
        echo "   - index.html (Game interface)"
        echo ""
        echo "🎮 To test locally:"
        echo "   1. Start a local web server:"
        echo "      python3 -m http.server 8000"
        echo "   2. Open http://localhost:8000 in your browser"
        echo "   3. Use arrow keys or click/tap to play!"
        echo ""
        echo "🌐 For deployment:"
        echo "   Upload AvoidObstaclesGameWeb.wasm, AvoidObstaclesGameWeb.js, and index.html to your web server"
        echo ""
        echo "⚡ Game Features:"
        echo "   - HTML5 Canvas rendering"
        echo "   - Keyboard and touch controls"
        echo "   - Progressive difficulty"
        echo "   - Real-time collision detection"

    else
        echo "❌ Error: WebAssembly game module not found in build directory"
        echo "Build directory contents:"
        ls -la "$BUILD_DIR/release/" 2>/dev/null || echo "Build directory is empty"
        exit 1
    fi

else
    echo "❌ Build failed due to toolchain compatibility issues"
    echo ""
    echo "🔧 Troubleshooting Options:"
    echo "   1. Use Docker containers for SwiftWasm builds"
    echo "   2. Update to a compatible SwiftWasm toolchain"
    echo "   3. Use alternative WebAssembly compilation methods"
    echo ""
    echo "🐳 Docker Build Alternative:"
    echo "   docker run --rm -v \$(pwd):/workspace -w /workspace swiftwasm/swiftwasm:latest carton build --release"
    echo ""
    echo "📚 For Phase 9 cross-platform testing, consider:"
    echo "   - Docker-based build environments"
    echo "   - CI/CD pipelines with compatible toolchains"
    echo "   - Alternative WebAssembly toolchains"
    exit 1
fi
