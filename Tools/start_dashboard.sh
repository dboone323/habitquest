#!/bin/bash
# Start the monitoring dashboard server

echo "Starting Monitoring Dashboard Server..."
echo "Dashboard will be available at: http://localhost:8000"
echo "Press Ctrl+C to stop the server"
echo ""

python3 dashboard_server.py
