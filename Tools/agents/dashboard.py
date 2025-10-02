#!/usr/bin/env python3
"""
Robust Web Dashboard for Quantum Workspace Autonomous Agent System
Real-time monitoring with auto-refresh, charts, and detailed status
"""

import os
import subprocess
import sys
import time
import webbrowser
from datetime import datetime
from threading import Thread

try:
    from flask import Flask, jsonify, render_template_string, request
    from flask_cors import CORS
except ImportError:
    print("Installing required packages...")
    subprocess.run(
        [sys.executable, "-m", "pip", "install", "flask", "flask-cors"], check=True
    )
    from flask import Flask, jsonify, render_template_string
    from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Configuration
AGENTS_DIR = os.path.dirname(__file__)
MCP_URL = "http://127.0.0.1:5005"
DASHBOARD_PORT = 8080

# Dashboard HTML Template
DASHBOARD_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🤖 Quantum Workspace Agent Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .header h1 {
            color: #2c3e50;
            font-size: 2.5rem;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        .status-healthy { background: #27ae60; }
        .status-warning { background: #f39c12; }
        .status-error { background: #e74c3c; }

        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .main-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .panel {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .panel h2 {
            color: #2c3e50;
            margin-bottom: 15px;
            font-size: 1.3rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .agent-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px;
            margin-bottom: 8px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 8px;
            border-left: 4px solid #3498db;
            transition: all 0.3s ease;
        }

        .agent-item:hover {
            background: rgba(255, 255, 255, 0.8);
            transform: translateX(5px);
        }

        .agent-item.running {
            border-left-color: #27ae60;
        }

        .agent-item.stopped {
            border-left-color: #e74c3c;
        }

        .agent-item.idle {
            border-left-color: #f39c12;
        }

        .agent-name {
            font-weight: 600;
            color: #2c3e50;
        }

        .agent-status {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-running {
            background: #d4edda;
            color: #155724;
        }

        .status-stopped {
            background: #f8d7da;
            color: #721c24;
        }

        .status-idle {
            background: #fff3cd;
            color: #856404;
        }

        .task-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px;
            margin-bottom: 6px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 6px;
            font-size: 0.9rem;
        }

        .task-type {
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .type-debug { background: #ffebee; color: #c62828; }
        .type-build { background: #e8f5e8; color: #2e7d32; }
        .type-generate { background: #e3f2fd; color: #1565c0; }
        .type-ui { background: #f3e5f5; color: #7b1fa2; }

        .log-panel {
            grid-column: 1 / -1;
            max-height: 400px;
            overflow-y: auto;
        }

        .log-entry {
            font-family: 'Monaco', 'Courier New', monospace;
            font-size: 0.8rem;
            padding: 5px 10px;
            margin-bottom: 2px;
            border-radius: 4px;
            white-space: pre-wrap;
        }

        .log-info { background: #e3f2fd; color: #1565c0; }
        .log-warn { background: #fff3e0; color: #ef6c00; }
        .log-error { background: #ffebee; color: #c62828; }

        .controls {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-primary {
            background: #3498db;
            color: white;
        }

        .btn-success {
            background: #27ae60;
            color: white;
        }

        .btn-danger {
            background: #e74c3c;
            color: white;
        }

        .btn-warning {
            background: #f39c12;
            color: white;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .auto-refresh {
            position: fixed;
            top: 20px;
            right: 20px;
            background: rgba(255, 255, 255, 0.9);
            padding: 10px 15px;
            border-radius: 25px;
            font-size: 0.8rem;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .chart-container {
            height: 200px;
            margin: 15px 0;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #7f8c8d;
        }

        @media (max-width: 768px) {
            .main-grid {
                grid-template-columns: 1fr;
            }

            .controls {
                flex-direction: column;
            }

            .header h1 {
                font-size: 1.8rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>
                🤖 Quantum Workspace Agent Dashboard
                <span id="systemStatus" class="status-indicator status-healthy"></span>
            </h1>
            <p id="lastUpdated">Last updated: <span id="updateTime">--</span></p>
        </div>

        <div class="auto-refresh">
            🔄 Auto-refresh: <span id="refreshCountdown">30</span>s
        </div>

        <div class="controls">
            <button class="btn btn-primary" onclick="refreshData()">🔄 Refresh Now</button>
            <button class="btn btn-success" onclick="showHealthCheck()">🏥 Health Check</button>
            <button class="btn btn-warning" onclick="showLogs()">📋 View Logs</button>
            <button class="btn btn-danger" onclick="confirmStop()">⏹ Stop System</button>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number" id="agentCount">--</div>
                <div class="stat-label">Active Agents</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="taskCount">--</div>
                <div class="stat-label">Queued Tasks</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="completedCount">--</div>
                <div class="stat-label">Completed Tasks</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="uptime">--</div>
                <div class="stat-label">System Uptime</div>
            </div>
        </div>

        <div class="main-grid">
            <div class="panel">
                <h2>🤖 Agent Status</h2>
                <div id="agentList">
                    <div class="agent-item">
                        <span class="agent-name">Loading agents...</span>
                    </div>
                </div>
            </div>

            <div class="panel">
                <h2>📋 Task Queue</h2>
                <div id="taskList">
                    <div class="task-item">
                        <span>Loading tasks...</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel log-panel">
            <h2>📝 System Logs</h2>
            <div id="logContainer">
                <div class="log-entry log-info">Loading system logs...</div>
            </div>
        </div>
    </div>

    <script>
        let refreshInterval;
        let countdownInterval;
        let systemStartTime = new Date();

        // Initialize dashboard
        document.addEventListener('DOMContentLoaded', function() {
            refreshData();
            startAutoRefresh();
        });

        // Auto refresh functionality
        function startAutoRefresh() {
            refreshInterval = setInterval(refreshData, 30000); // 30 seconds
            startCountdown();
        }

        function startCountdown() {
            let seconds = 30;
            countdownInterval = setInterval(() => {
                seconds--;
                document.getElementById('refreshCountdown').textContent = seconds;
                if (seconds <= 0) {
                    seconds = 30;
                }
            }, 1000);
        }

        // Refresh data from backend
        async function refreshData() {
            try {
                const response = await fetch('/api/status');
                const data = await response.json();
                updateDashboard(data);
                updateSystemStatus('healthy');
                document.getElementById('updateTime').textContent = new Date().toLocaleTimeString();
            } catch (error) {
                console.error('Failed to fetch data:', error);
                updateSystemStatus('error');
            }
        }

        // Update dashboard with new data
        function updateDashboard(data) {
            // Update stats
            document.getElementById('agentCount').textContent = data.stats?.active_agents || 0;
            document.getElementById('taskCount').textContent = data.stats?.queued_tasks || 0;
            document.getElementById('completedCount').textContent = data.stats?.completed_tasks || 0;

            // Update uptime
            const uptime = Math.floor((new Date() - systemStartTime) / 1000 / 60);
            document.getElementById('uptime').textContent = uptime + 'm';

            // Update agents
            updateAgentList(data.agents || {});

            // Update tasks
            updateTaskList(data.tasks || []);

            // Update logs
            updateLogs(data.logs || []);
        }

        // Update agent list
        function updateAgentList(agents) {
            const container = document.getElementById('agentList');
            const agentNames = [
                'agent_build.sh',
                'agent_debug.sh',
                'agent_codegen.sh',
                'agent_todo.sh',
                'task_orchestrator.sh'
            ];

            container.innerHTML = '';

            agentNames.forEach(name => {
                const agent = agents[name] || {};
                const status = agent.status || 'unknown';
                const pid = agent.pid || 'N/A';

                const item = document.createElement('div');
                item.className = `agent-item ${status}`;
                item.innerHTML = `
                    <div>
                        <div class="agent-name">${name.replace('.sh', '').replace('agent_', '')}</div>
                        <small>PID: ${pid}</small>
                    </div>
                    <span class="agent-status status-${status}">${status}</span>
                `;
                container.appendChild(item);
            });
        }

        // Update task list
        function updateTaskList(tasks) {
            const container = document.getElementById('taskList');
            container.innerHTML = '';

            if (tasks.length === 0) {
                container.innerHTML = '<div class="task-item"><span>No active tasks</span></div>';
                return;
            }

            tasks.slice(0, 10).forEach(task => {
                const item = document.createElement('div');
                item.className = 'task-item';
                item.innerHTML = `
                    <div>
                        <div>${task.description}</div>
                        <small>Agent: ${task.assigned_agent}</small>
                    </div>
                    <span class="task-type type-${task.type}">${task.type}</span>
                `;
                container.appendChild(item);
            });
        }

        // Update logs
        function updateLogs(logs) {
            const container = document.getElementById('logContainer');
            container.innerHTML = '';

            if (logs.length === 0) {
                container.innerHTML = '<div class="log-entry log-info">No recent logs available</div>';
                return;
            }

            logs.slice(-20).forEach(log => {
                const entry = document.createElement('div');
                entry.className = `log-entry log-${log.level.toLowerCase()}`;
                entry.textContent = `[${log.timestamp}] ${log.message}`;
                container.appendChild(entry);
            });

            container.scrollTop = container.scrollHeight;
        }

        // Update system status indicator
        function updateSystemStatus(status) {
            const indicator = document.getElementById('systemStatus');
            indicator.className = `status-indicator status-${status}`;
        }

        // Control functions
        async function showHealthCheck() {
            try {
                const response = await fetch('/api/health');
                const health = await response.json();

                let message = `System Health Check\\n\\n`;
                message += `MCP Server: ${health.mcp_status}\\n`;
                message += `Active Agents: ${health.active_agents}\\n`;
                message += `System Load: ${health.system_load}\\n`;
                message += `Memory Usage: ${health.memory_usage}\\n`;

                alert(message);
            } catch (error) {
                alert('Health check failed: ' + error.message);
            }
        }

        async function showLogs() {
            window.open('/logs', '_blank');
        }

        function confirmStop() {
            if (confirm('Are you sure you want to stop the agent system?')) {
                fetch('/api/stop', { method: 'POST' })
                    .then(() => {
                        alert('System stop command sent');
                        clearInterval(refreshInterval);
                        clearInterval(countdownInterval);
                    })
                    .catch(error => alert('Failed to stop system: ' + error.message));
            }
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case 'r':
                        e.preventDefault();
                        refreshData();
                        break;
                    case 'h':
                        e.preventDefault();
                        showHealthCheck();
                        break;
                }
            }
        });
    </script>
</body>
</html>
"""


class DashboardManager:
    def __init__(self):
        self.agents_dir = AGENTS_DIR
        self.system_start_time = datetime.now()

    def get_agent_status(self):
        """Get status of all agents"""
        agents = {}
        essential_agents = [
            "agent_build.sh",
            "agent_debug.sh",
            "agent_codegen.sh",
            "agent_todo.sh",
            "task_orchestrator.sh",
        ]

        for agent in essential_agents:
            pid_file = os.path.join(self.agents_dir, f"{agent}.pid")
            if os.path.exists(pid_file):
                try:
                    with open(pid_file, "r") as f:
                        pid = int(f.read().strip())

                    # Check if process is running
                    try:
                        os.kill(pid, 0)
                        status = "running"
                    except OSError:
                        status = "stopped"

                    agents[agent] = {"status": status, "pid": pid}
                except:
                    agents[agent] = {"status": "unknown", "pid": "N/A"}
            else:
                agents[agent] = {"status": "stopped", "pid": "N/A"}

        return agents

    def get_mcp_status(self):
        """Get MCP server status and tasks"""
        try:
            import requests

            response = requests.get(f"{MCP_URL}/status", timeout=5)
            return response.json()
        except:
            return {"agents": {}, "tasks": [], "completed": [], "stats": {}}

    def get_recent_logs(self):
        """Get recent log entries"""
        logs = []
        log_files = [
            "agent_supervisor.log",
            "agent_build.log",
            "agent_debug.log",
            "agent_codegen.log",
            "agent_todo.log",
        ]

        for log_file in log_files:
            log_path = os.path.join(self.agents_dir, log_file)
            if os.path.exists(log_path):
                try:
                    with open(log_path, "r") as f:
                        lines = f.readlines()[-10:]  # Last 10 lines

                    for line in lines:
                        line = line.strip()
                        if line:
                            level = "info"
                            if "ERROR" in line or "FAIL" in line:
                                level = "error"
                            elif "WARN" in line:
                                level = "warn"

                            logs.append(
                                {
                                    "timestamp": datetime.now().strftime("%H:%M:%S"),
                                    "level": level,
                                    "message": line,
                                    "source": log_file,
                                }
                            )
                except:
                    continue

        return sorted(logs, key=lambda x: x["timestamp"])[-20:]  # Last 20 entries

    def get_system_health(self):
        """Get system health metrics"""
        agents = self.get_agent_status()
        self.get_mcp_status()

        active_agents = len([a for a in agents.values() if a["status"] == "running"])

        try:
            import requests

            mcp_status = (
                "HEALTHY"
                if requests.get(f"{MCP_URL}/health", timeout=3).status_code == 200
                else "DOWN"
            )
        except:
            mcp_status = "DOWN"

        return {
            "mcp_status": mcp_status,
            "active_agents": f"{active_agents}/{len(agents)}",
            "system_load": "Normal",  # Could implement actual system load
            "memory_usage": "Good",  # Could implement actual memory usage
        }


dashboard_manager = DashboardManager()


@app.route("/")
def dashboard():
    """Main dashboard page"""
    return render_template_string(DASHBOARD_HTML)


@app.route("/api/status")
def api_status():
    """API endpoint for dashboard status"""
    agents = dashboard_manager.get_agent_status()
    mcp_data = dashboard_manager.get_mcp_status()
    logs = dashboard_manager.get_recent_logs()

    # Combine agent data
    all_agents = agents.copy()
    all_agents.update(mcp_data.get("agents", {}))

    return jsonify(
        {
            "agents": all_agents,
            "tasks": mcp_data.get("tasks", []),
            "completed": mcp_data.get("completed", []),
            "stats": {
                "total_agents": len(agents),
                "active_agents": len(
                    [a for a in agents.values() if a["status"] == "running"]
                ),
                "queued_tasks": len(mcp_data.get("tasks", [])),
                "completed_tasks": len(mcp_data.get("completed", [])),
            },
            "logs": logs,
        }
    )


@app.route("/api/health")
def api_health():
    """API endpoint for system health"""
    return jsonify(dashboard_manager.get_system_health())


@app.route("/api/stop", methods=["POST"])
def api_stop():
    """API endpoint to stop the system"""
    try:
        supervisor_script = os.path.join(AGENTS_DIR, "agent_supervisor.sh")
        subprocess.run([supervisor_script, "stop"], check=True)
        return jsonify({"success": True, "message": "Stop command sent"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/logs")
def logs_page():
    """Detailed logs page"""
    logs = dashboard_manager.get_recent_logs()

    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>System Logs</title>
        <style>
            body { font-family: monospace; background: #1e1e1e; color: #d4d4d4; padding: 20px; }
            .log-entry { margin: 5px 0; padding: 5px; border-left: 3px solid #555; }
            .log-error { border-color: #e74c3c; background: rgba(231, 76, 60, 0.1); }
            .log-warn { border-color: #f39c12; background: rgba(243, 156, 18, 0.1); }
            .log-info { border-color: #3498db; background: rgba(52, 152, 219, 0.1); }
        </style>
    </head>
    <body>
        <h1>System Logs</h1>
        <div id="logs">
    """

    for log in logs:
        html += f'<div class="log-entry log-{log["level"]}">[{log["timestamp"]}] {log["message"]}</div>'

    html += """
        </div>
        <script>
            setInterval(() => location.reload(), 30000);
        </script>
    </body>
    </html>
    """

    return html


def open_dashboard():
    """Open dashboard in default browser"""
    time.sleep(2)  # Wait for server to start
    webbrowser.open(f"http://localhost:{DASHBOARD_PORT}")


if __name__ == "__main__":
    print(f"🚀 Starting Robust Agent Dashboard on port {DASHBOARD_PORT}")
    print(f"📊 Dashboard will be available at: http://localhost:{DASHBOARD_PORT}")
    print(f"📁 Monitoring agents in: {AGENTS_DIR}")

    # Open browser in background thread
    Thread(target=open_dashboard, daemon=True).start()

    # Start Flask app
    try:
        app.run(host="0.0.0.0", port=DASHBOARD_PORT, debug=False)
    except KeyboardInterrupt:
        print("\n🛑 Dashboard stopped by user")
    except Exception as e:
        print(f"❌ Dashboard error: {e}")
