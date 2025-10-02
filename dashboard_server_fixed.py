#!/usr/bin/env python3
"""
Simple Dashboard Server for Quantum Workspace
Serves live agent status and task queue data
"""
import http.server
import json
import os
import socketserver
from pathlib import Path
import time
from urllib.parse import urlparse

STALE_AGENT_THRESHOLD = 300  # seconds without update before flagging as stale
MAX_ALERT_AGENTS = 5  # limit agent names shown per alert


def format_agent_label(agent_name: str) -> str:
    """Create a readable label for an agent key."""
    if not agent_name:
        return "unknown agent"
    name = agent_name
    if name.endswith(".sh"):
        name = name[:-3]
    if name.startswith("agent_"):
        name = name[len("agent_") :]
    return name.replace("_", " ")


class DashboardHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            # Parse the path to ignore query parameters
            parsed_path = urlparse(self.path)
            path = parsed_path.path

            if path == "/api/dashboard-data":
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
                task_history_file = agents_dir / "task_execution_history.json"
                performance_file = agents_dir / "performance_metrics.json"
                metrics_state_file = agents_dir / ".dashboard_metrics_state.json"

                dashboard_data = {
                    "agents": {},
                    "tasks": {"queued": 0, "completed": 0, "active": 0},
                    "system": {"status": "operational"},
                    "alerts": [],
                    "last_update": int(time.time()),
                }

                agent_attention = {"offline": [], "stale": []}

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

                agents_dict = (
                    dashboard_data["agents"]
                    if isinstance(dashboard_data.get("agents"), dict)
                    else {}
                )

                for agent_name, info in agents_dict.items():
                    if not isinstance(info, dict):
                        continue
                    status = str(info.get("status", "")).lower()
                    last_seen_raw = info.get("last_seen")
                    last_seen = None
                    if isinstance(last_seen_raw, (int, float)):
                        last_seen = int(last_seen_raw)
                    else:
                        try:
                            last_seen = int(str(last_seen_raw))
                        except (TypeError, ValueError):
                            last_seen = None

                    if status in {"stopped", "offline", "error", "failed", "crashed"}:
                        agent_attention["offline"].append(agent_name)
                        continue

                    if (
                        last_seen is not None
                        and dashboard_data["last_update"] - last_seen
                        > STALE_AGENT_THRESHOLD
                    ):
                        agent_attention["stale"].append(agent_name)

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

                # Load task execution history for completed/active counts and details
                if task_history_file.exists():
                    try:
                        with open(task_history_file, "r") as f:
                            history_data = json.load(f)

                        execution_records = []
                        summary = {}
                        if isinstance(history_data, dict):
                            execution_records = history_data.get(
                                "execution_history", []
                            )
                            summary = history_data.get("summary", {})

                        completed_count = None
                        if isinstance(summary, dict):
                            completed_count = summary.get("total_completed")

                        filtered_completed = []
                        filtered_active = []
                        for record in execution_records:
                            if not isinstance(record, dict):
                                continue
                            status = str(record.get("status", "")).lower()
                            if status in {"completed", "done", "success"}:
                                filtered_completed.append(record)
                            elif status in {
                                "running",
                                "in_progress",
                                "active",
                                "processing",
                            }:
                                filtered_active.append(record)

                        if completed_count is None:
                            completed_count = len(filtered_completed)

                        dashboard_data["tasks"]["completed"] = int(completed_count or 0)
                        dashboard_data["tasks"]["active"] = len(filtered_active)
                        dashboard_data["tasks"]["active_details"] = [
                            {
                                "task_id": record.get("task_id"),
                                "type": record.get("type"),
                                "assigned_agent": record.get("assigned_agent"),
                                "description": record.get("description"),
                                "started": record.get("started"),
                            }
                            for record in filtered_active
                        ]

                        filtered_completed.sort(
                            key=lambda record: record.get("completed", 0) or 0,
                            reverse=True,
                        )
                        dashboard_data["tasks"]["recent_completions"] = [
                            {
                                "task_id": record.get("task_id"),
                                "type": record.get("type"),
                                "completed": record.get("completed"),
                                "duration": record.get("duration_seconds"),
                                "result": record.get("result"),
                            }
                            for record in filtered_completed[:5]
                        ]
                    except Exception as e:
                        print(f"Error loading task history: {e}")

                dashboard_data["tasks"].setdefault("active_details", [])
                dashboard_data["tasks"].setdefault("recent_completions", [])

                # Track queue drain rate
                try:
                    previous_state = {}
                    if metrics_state_file.exists():
                        with open(metrics_state_file, "r") as f:
                            previous_state = json.load(f)

                    prev_count = previous_state.get("queued")
                    prev_timestamp = previous_state.get("timestamp")
                    now_timestamp = dashboard_data["last_update"]
                    current_count = dashboard_data["tasks"].get("queued")

                    if (
                        isinstance(prev_count, int)
                        and isinstance(prev_timestamp, (int, float))
                        and isinstance(current_count, int)
                    ):
                        elapsed_seconds = now_timestamp - int(prev_timestamp)
                        if elapsed_seconds > 0:
                            rate_per_minute = (prev_count - current_count) / (
                                elapsed_seconds / 60
                            )
                            dashboard_data["tasks"]["drain_rate_per_min"] = round(
                                rate_per_minute, 2
                            )

                    with open(metrics_state_file, "w") as f:
                        json.dump(
                            {
                                "queued": current_count,
                                "timestamp": now_timestamp,
                                "drain_rate_per_min": dashboard_data["tasks"].get(
                                    "drain_rate_per_min"
                                ),
                            },
                            f,
                        )
                except Exception as e:
                    print(f"Error tracking queue metrics: {e}")

                # Load performance metrics
                if performance_file.exists():
                    try:
                        with open(performance_file, "r") as f:
                            perf_data = json.load(f)
                        dashboard_data["system"].update(perf_data.get("system", {}))
                    except Exception as e:
                        print(f"Error loading performance data: {e}")

                alerts = []
                total_offline = len(agent_attention["offline"])
                total_stale = len(agent_attention["stale"])

                if total_offline > 0:
                    named = ", ".join(
                        format_agent_label(name)
                        for name in agent_attention["offline"][:MAX_ALERT_AGENTS]
                    )
                    if total_offline > MAX_ALERT_AGENTS:
                        named = f"{named}, +{total_offline - MAX_ALERT_AGENTS} more"
                    alerts.append(
                        {
                            "level": "critical" if total_offline > 3 else "warning",
                            "message": f"{total_offline} agent(s) offline: {named}",
                        }
                    )

                if total_stale > 0:
                    named = ", ".join(
                        format_agent_label(name)
                        for name in agent_attention["stale"][:MAX_ALERT_AGENTS]
                    )
                    if total_stale > MAX_ALERT_AGENTS:
                        named = f"{named}, +{total_stale - MAX_ALERT_AGENTS} more"
                    alerts.append(
                        {
                            "level": "warning",
                            "message": f"{total_stale} agent(s) inactive for over {STALE_AGENT_THRESHOLD // 60} minutes: {named}",
                        }
                    )

                queued_count = dashboard_data["tasks"].get("queued", 0)
                drain_rate = dashboard_data["tasks"].get("drain_rate_per_min")
                if queued_count and (drain_rate is None or drain_rate <= 0):
                    alerts.append(
                        {
                            "level": "critical" if queued_count > 500 else "warning",
                            "message": f"Task queue stalled: {queued_count} queued, drain rate 0 per minute",
                        }
                    )

                dashboard_data["alerts"] = alerts

                self.wfile.write(json.dumps(dashboard_data, indent=2).encode())

            elif path == "/" or path == "/dashboard":
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
        .section-title { font-size: 1rem; margin: 20px 0 10px; font-weight: 600; opacity: 0.9; }
        .list-container { display: flex; flex-direction: column; gap: 8px; }
        .list-item { display: flex; flex-direction: column; padding: 10px; border-radius: 8px; background: rgba(255,255,255,0.08); }
        .list-item-header { display: flex; justify-content: space-between; font-weight: 600; }
        .subtext { font-size: 0.85rem; opacity: 0.8; }
    .alert-container { margin-bottom: 20px; }
    .alert { padding: 12px 16px; border-radius: 8px; background: rgba(0,0,0,0.25); border-left: 4px solid rgba(255,255,255,0.3); margin-bottom: 10px; }
    .alert-warning { border-left-color: #ffc107; }
    .alert-critical { border-left-color: #dc3545; }
    .alert-text { font-weight: 600; }
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

        <div id="alertsContainer" class="alert-container" style="display: none;"></div>

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
                    <div class="metric">
                        <span>Drain Rate (per min)</span>
                        <span id="drainRate">n/a</span>
                    </div>
                    <h4 class="section-title">Active Tasks</h4>
                    <div id="activeTaskList" class="list-container">
                        <div class="subtext">No active tasks</div>
                    </div>
                    <h4 class="section-title">Recent Completions</h4>
                    <div id="recentCompletions" class="list-container">
                        <div class="subtext">Loading...</div>
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
            updateAlerts();
            updateAgentList();
            updateTaskMetrics();
            updateSystemStatus();
            updateLastUpdate();
        }

        function updateAlerts() {
            const container = document.getElementById('alertsContainer');
            const alerts = Array.isArray(dashboardData.alerts) ? dashboardData.alerts : [];

            if (!alerts.length) {
                container.style.display = 'none';
                container.innerHTML = '';
                return;
            }

            container.style.display = 'block';
            container.innerHTML = alerts
                .map((alert) => {
                    const level = alert.level || 'warning';
                    const message = alert.message || 'Attention required';
                    const className = level === 'critical' ? 'alert-critical' : level === 'info' ? '' : 'alert-warning';
                    return `<div class="alert ${className}"><span class="alert-text">${message}</span></div>`;
                })
                .join('');
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

            document.getElementById('queuedTasks').textContent = tasks.queued ?? 0;
            document.getElementById('activeTasks').textContent = tasks.active ?? 0;
            document.getElementById('completedTasks').textContent = tasks.completed ?? 0;

            const drainRateElement = document.getElementById('drainRate');
            if (typeof tasks.drain_rate_per_min === 'number' && !Number.isNaN(tasks.drain_rate_per_min)) {
                const rate = tasks.drain_rate_per_min;
                const formatted = rate.toFixed(2);
                const trend = rate > 0 ? 'draining' : rate < 0 ? 'growing' : 'steady';
                drainRateElement.textContent = `${formatted} ${trend}`;
            } else {
                drainRateElement.textContent = 'n/a';
            }

            const activeContainer = document.getElementById('activeTaskList');
            const activeDetails = Array.isArray(tasks.active_details) ? tasks.active_details : [];
            if (activeDetails.length === 0) {
                activeContainer.innerHTML = '<div class="subtext">No active tasks</div>';
            } else {
                activeContainer.innerHTML = activeDetails
                    .map(detail => {
                        const started = formatTimestamp(detail.started);
                        const agent = detail.assigned_agent || 'unknown agent';
                        const description = detail.description ? `<div class=\"subtext\">${detail.description}</div>` : '';
                        return `
                            <div class="list-item">
                                <div class="list-item-header">
                                    <span>${detail.task_id || 'unknown task'}</span>
                                    <span>${detail.type || 'unknown'}</span>
                                </div>
                                <div class="subtext">Started: ${started} · Agent: ${agent}</div>
                                ${description}
                            </div>
                        `;
                    })
                    .join('');
            }

            const recentContainer = document.getElementById('recentCompletions');
            const recent = Array.isArray(tasks.recent_completions) ? tasks.recent_completions : [];
            if (recent.length === 0) {
                recentContainer.innerHTML = '<div class="subtext">No recent completions</div>';
            } else {
                recentContainer.innerHTML = recent
                    .map(record => {
                        const completed = formatTimestamp(record.completed);
                        const duration = formatDuration(record.duration);
                        const result = record.result ? `<div class=\"subtext\">Result: ${record.result}</div>` : '';
                        return `
                            <div class="list-item">
                                <div class="list-item-header">
                                    <span>${record.task_id || 'unknown task'}</span>
                                    <span>${record.type || 'unknown'}</span>
                                </div>
                                <div class="subtext">Completed: ${completed} · Duration: ${duration}</div>
                                ${result}
                            </div>
                        `;
                    })
                    .join('');
            }
        }

        function updateSystemStatus() {
            const system = dashboardData.system || {};
            document.getElementById('systemStatusText').textContent = system.status || 'unknown';
        }

        function updateLastUpdate() {
            if (dashboardData.last_update) {
                document.getElementById('lastUpdate').textContent = formatTimestamp(dashboardData.last_update);
            }
        }

        function formatTimestamp(value) {
            if (!value && value !== 0) {
                return 'unknown';
            }
            const asNumber = Number(value);
            if (Number.isNaN(asNumber) || asNumber <= 0) {
                return 'unknown';
            }
            const millis = asNumber > 1_000_000_000_000 ? asNumber : asNumber * 1000;
            const date = new Date(millis);
            if (Number.isNaN(date.getTime())) {
                return 'unknown';
            }
            return date.toLocaleString();
        }

        function formatDuration(seconds) {
            if (seconds === null || seconds === undefined) {
                return 'n/a';
            }
            const value = Number(seconds);
            if (Number.isNaN(value) || value < 0) {
                return 'n/a';
            }
            const minutes = Math.floor(value / 60);
            const remainder = Math.round(value % 60);
            if (minutes > 0) {
                return `${minutes}m ${remainder}s`;
            }
            return `${remainder}s`;
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
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"Not found")
        except Exception as e:
            print(f"Error handling request: {e}")
            try:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b'{"error": "Internal server error"}')
            except:
                pass

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
