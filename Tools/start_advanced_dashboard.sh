#!/bin/bash
# Start the Advanced Analytics Dashboard

echo "🚀 Starting Advanced Analytics Dashboard..."
cd /Users/danielstevens/Desktop/Quantum-workspace/Tools || exit 1

# Start the dashboard server
python3 dashboard_server.py &
DASHBOARD_PID=$!

echo "📊 Dashboard server started with PID: $DASHBOARD_PID"
echo "🌐 Dashboard available at: http://localhost:5000"
echo ""
echo "Press Ctrl+C to stop the dashboard"

# Wait for interrupt
trap 'echo "🛑 Stopping dashboard server..."; kill $DASHBOARD_PID; exit 0' INT
wait $DASHBOARD_PID
