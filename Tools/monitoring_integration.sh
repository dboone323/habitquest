#!/bin/bash
# Quantum Workspace Monitoring Integration
# Runs all monitoring components and updates dashboard

WORKSPACE_DIR="/Users/danielstevens/Desktop/Quantum-workspace"
TOOLS_DIR="${WORKSPACE_DIR}/Tools"

echo "🔄 Quantum Workspace Monitoring Integration"
echo "==========================================="

# Run tool health check
echo "📊 Running tool health monitoring..."
if [[ -x "${TOOLS_DIR}/tool_health_monitor.sh" ]]; then
    "${TOOLS_DIR}/tool_health_monitor.sh" check
    echo "✅ Tool health check completed"
else
    echo "❌ Tool health monitor not found"
fi

echo ""

# Run alerts check
echo "🚨 Checking for alerts..."
if [[ -x "${TOOLS_DIR}/tool_alerts.sh" ]]; then
    "${TOOLS_DIR}/tool_alerts.sh" check
    echo "✅ Alerts check completed"
else
    echo "❌ Alerts script not found"
fi

echo ""

# Run performance benchmark
echo "⚡ Running performance benchmark..."
if [[ -x "${TOOLS_DIR}/tool_benchmark.sh" ]]; then
    "${TOOLS_DIR}/tool_benchmark.sh" run >/dev/null 2>&1
    echo "✅ Performance benchmark completed"
else
    echo "❌ Benchmark script not found"
fi

echo ""

# Show summary
echo "📋 Monitoring Summary:"
echo "======================"

# Show tool status
if [[ -x "${TOOLS_DIR}/tool_health_monitor.sh" ]]; then
    echo "🔍 Tool Health:"
    "${TOOLS_DIR}/tool_health_monitor.sh" status | sed 's/^/  /'
fi

echo ""

# Show recent alerts
if [[ -x "${TOOLS_DIR}/tool_alerts.sh" ]]; then
    echo "🚨 Recent Alerts:"
    "${TOOLS_DIR}/tool_alerts.sh" show 1 | head -10 | sed 's/^/  /'
fi

echo ""

# Show benchmark trends
if [[ -x "${TOOLS_DIR}/tool_benchmark.sh" ]]; then
    echo "⚡ Performance Trends:"
    "${TOOLS_DIR}/tool_benchmark.sh" trends 2>/dev/null | head -5 | sed 's/^/  /'
fi

echo ""
echo "🌐 Dashboard available at: http://localhost:8004/dashboard"
echo "📊 API Endpoint: http://localhost:8004/api/dashboard-data"
echo ""
echo "✅ Monitoring integration completed"