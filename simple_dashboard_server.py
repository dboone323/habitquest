#!/usr/bin/env python3
"""
Simple Dashboard Server for Quantum Workspace
Serves live agent status and task queue data
"""
import http.server
import json
import os
import socketserver
import threading
from pathlib import Path
import time


class DashboardHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        try:
            if self.path == "/api/dashboard-data":
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()

                # Read agent status and task queue data
                agents_dir = Path(
                    "/Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents"
                )
                agent_status_file = agents_dir / "agent_status.json"
                task_queue_file = agents_dir / "task_queue.json"
                performance_file = agents_dir / "performance_metrics.json"

                dashboard_data = {
                    "agents": {},
                    "tasks": {"queued": 0, "completed": 0, "active": 0},
                    "system": {"status": "operational"},
                    "last_update": int(time.time()),
                }

                # Load agent status
                if agent_status_file.exists():
                    try:
                        with open(agent_status_file, "r") as f:
                            agent_data = json.load(f)
                        dashboard_data["agents"] = agent_data.get("agents", {})
                    except Exception as e:
                        print(f"Error loading agent status: {e}")
                        dashboard_data["agents"] = {
                            "error": f"Failed to load agent status: {e}"
                        }

                # Load task queue info
                if task_queue_file.exists():
                    try:
                        with open(task_queue_file, "r") as f:
                            task_data = json.load(f)
                        if isinstance(task_data, list):
                            dashboard_data["tasks"]["queued"] = len(task_data)
                        elif isinstance(task_data, dict) and "tasks" in task_data:
                            dashboard_data["tasks"]["queued"] = len(task_data["tasks"])
                        else:
                            dashboard_data["tasks"]["queued"] = 0
                    except Exception as e:
                        print(f"Error loading task queue: {e}")
                        dashboard_data["tasks"]["queued"] = 0

                # Load performance metrics
                if performance_file.exists():
                    try:
                        with open(performance_file, "r") as f:
                            perf_data = json.load(f)
                        dashboard_data["system"].update(perf_data.get("system", {}))
                    except Exception as e:
                        print(f"Error loading performance data: {e}")

                self.wfile.write(json.dumps(dashboard_data, indent=2).encode())

            elif self.path == "/" or self.path == "/dashboard":
                self.send_response(200)
                self.send_header("Content-type", "text/html")
                self.end_headers()

                # Serve simple dashboard HTML
                html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quantum Workspace Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 30px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .card { background: rgba(255,255,255,0.1); border-radius: 10px; padding: 20px; backdrop-filter: blur(10px); }
        .agent-item { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid rgba(255,255,255,0.2); }
        .status-available { color: #28a745; }
        .status-stopped { color: #dc3545; }
        .status-running { color: #007bff; }
        .status-unknown { color: #ffc107; }
        .metric { display: flex; justify-content: space-between; padding: 10px 0; }
        .refresh-btn { background: #28a745; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 10px; }
        .refresh-btn:hover { background: #218838; }
        .error { color: #dc3545; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Quantum Workspace Agent Dashboard</h1>
            <p>Real-time monitoring of your AI agent ecosystem</p>
            <button class="refresh-btn" onclick="loadData()">🔄 Refresh</button>
        </div>

        <div class="grid">
            <div class="card">
                <h3>🤖 Agent Status (<span id="agentCount">0</span>)</h3>
                <div id="agentList">
                    <div class="agent-item">
                        <span>Loading agents...</span>
                    </div>
                </div>
            </div>

            <div class="card">
                <h3>📋 Task Queue</h3>
                <div id="taskMetrics">
                    <div class="metric">
                        <span>Queued Tasks</span>
                        <span id="queuedTasks">0</span>
                    </div>
                    <div class="metric">
                        <span>Active Tasks</span>
                        <span id="activeTasks">0</span>
                    </div>
                    <div class="metric">
                        <span>Completed Tasks</span>
                        <span id="completedTasks">0</span>
                    </div>
                </div>
            </div>

            <div class="card">
                <h3>⚙️ System Status</h3>
                <div id="systemStatus">
                    <div class="metric">
                        <span>Status</span>
                        <span id="systemStatusText">Checking...</span>
                    </div>
                </div>
            </div>
        </div>

        <div style="text-align: center; margin-top: 30px; opacity: 0.8;">
            <p>Last updated: <span id="lastUpdate">Never</span></p>
        </div>
    </div>

    <script>
        let dashboardData = {};

        async function loadData() {
            try {
                const response = await fetch('/api/dashboard-data');
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                dashboardData = await response.json();
                updateDisplay();
            } catch (error) {
                console.error('Error loading data:', error);
                document.getElementById('agentList').innerHTML = '<div class="agent-item"><span class="error">Error loading data: ' + error.message + '</span></div>';
                document.getElementById('agentCount').textContent = '0';
            }
        }

        function updateDisplay() {
            updateAgentList();
            updateTaskMetrics();
            updateSystemStatus();
            updateLastUpdate();
        }

        function updateAgentList() {
            const container = document.getElementById('agentList');
            const countElement = document.getElementById('agentCount');

            if (dashboardData.agents && Object.keys(dashboardData.agents).length > 0) {
                let html = '';
                let count = 0;
                Object.entries(dashboardData.agents).forEach(([name, data]) => {
                    count++;
                    const statusClass = `status-${data.status || 'unknown'}`;
                    const statusText = data.status || 'unknown';
                    html += `
                        <div class="agent-item">
                            <span>${name.replace(/_/g, ' ').replace('.sh', '')}</span>
                            <span class="${statusClass}">${statusText}</span>
                        </div>
                    `;
                });
                container.innerHTML = html;
                countElement.textContent = count;
            } else {
                container.innerHTML = '<div class="agent-item"><span>No agents found</span></div>';
                countElement.textContent = '0';
            }
        }

        function updateTaskMetrics() {
            const tasks = dashboardData.tasks || {};
            document.getElementById('queuedTasks').textContent = tasks.queued || 0;
            document.getElementById('activeTasks').textContent = tasks.active || 0;
            document.getElementById('completedTasks').textContent = tasks.completed || 0;
        }

        function updateSystemStatus() {
            const system = dashboardData.system || {};
            document.getElementById('systemStatusText').textContent = system.status || 'unknown';
        }

        function updateLastUpdate() {
            if (dashboardData.last_update) {
                document.getElementById('lastUpdate').textContent = new Date(dashboardData.last_update * 1000).toLocaleString();
            }
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            loadData();
        });

        // Auto-refresh every 30 seconds
        setInterval(loadData, 30000);
    </script>
</body>
</html>"""
                self.wfile.write(html.encode())
            else:
                # Serve static files from the agents directory
                super().do_GET()
        except Exception as e:
            print(f"Error handling request: {e}")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b'{"error": "Internal server error"}')

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()


class ThreadedHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    """Handle requests in a separate thread."""


def run_server(port=8004):
    """Run the dashboard server"""
    agents_dir = Path(
        "/Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents"
    )
    os.chdir(agents_dir)

    server_address = ("", port)
    httpd = ThreadedHTTPServer(server_address, DashboardHandler)
    print(f"Dashboard server running at http://localhost:{port}")
    print("Press Ctrl+C to stop")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped")
        httpd.shutdown()


if __name__ == "__main__":
    run_server()
