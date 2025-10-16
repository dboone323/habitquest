#!/bin/bash
# On-demand Ollama wrapper

OLLAMA_PID_FILE="/tmp/quantum_ollama.pid"

start_ollama() {
    if [[ ! -f "$OLLAMA_PID_FILE" ]] || ! kill -0 "$(cat "$OLLAMA_PID_FILE" 2>/dev/null)" 2>/dev/null; then
        echo "Starting Ollama..."
        nohup ollama serve > /dev/null 2>&1 &
        echo $! > "$OLLAMA_PID_FILE"
        sleep 2  # Wait for startup
    fi
}

stop_ollama() {
    if [[ -f "$OLLAMA_PID_FILE" ]]; then
        kill "$(cat "$OLLAMA_PID_FILE" 2>/dev/null)" 2>/dev/null || true
        rm -f "$OLLAMA_PID_FILE"
    fi
}

# Start Ollama, run command, then stop
start_ollama
"$@"
stop_ollama
