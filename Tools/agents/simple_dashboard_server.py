#!/usr/bin/env python3
"""
Simple Dashboard API Server
Serves basic dashboard data from existing agent files
"""

import http.server
import json
import socketserver
import time
import os
from pathlib import Path

PORT = 8004
AGENTS_DIR = Path(__file__).parent

class SimpleDashboardHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/dashboard-data":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()

            dashboard_data = self.get_simple_dashboard_data()
            self.wfile.write(json.dumps(dashboard_data, indent=2).encode())
        elif self.path in ["/", "/dashboard", "/dashboard.html"]:
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()

            # Serve the simple dashboard HTML
            simple_dashboard_path = AGENTS_DIR.parent / "Automation" / "simple_dashboard.html"
            if simple_dashboard_path.exists():
                with open(simple_dashboard_path, "r") as f:
                    self.wfile.write(f.read().encode())
            else:
                self.wfile.write(
                    b"<html><body><h1>Simple Dashboard not found</h1><p>simple_dashboard.html missing</p></body></html>"
                )
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'{"error": "Endpoint not found"}')

    def get_simple_dashboard_data(self):
        """Generate simple dashboard data from existing files"""
        current_time = int(time.time())

        # Load agent status
        agent_status_file = AGENTS_DIR / "agent_status.json"
        agent_data = {}
        if agent_status_file.exists():
            try:
                with open(agent_status_file, "r") as f:
                    data = json.load(f)
                    agent_data = data.get("agents", {})
            except Exception as e:
                print(f"Error reading agent_status.json: {e}")

        # Process agents
        agents = {}
        for agent_name, agent_info in agent_data.items():
            status = agent_info.get("status", "unknown")
            last_seen = agent_info.get("last_seen", 0)

            # Determine display status
            if status in ["active", "running"]:
                display_status = "running"
            elif status == "idle":
                display_status = "idle"
            elif status == "offline":
                display_status = "stopped"
            else:
                display_status = status

            agents[agent_name] = {
                "status": display_status,
                "last_seen": last_seen,
                "pid": agent_info.get("pid", "N/A")
            }

        # Get task queue count
        task_queue_file = AGENTS_DIR / "task_queue.json"
        task_count = "N/A"
        if task_queue_file.exists():
            try:
                # Get file size in MB for large files
                file_size = task_queue_file.stat().st_size
                if file_size > 1024 * 1024:  # > 1MB
                    task_count = f"{file_size // (1024 * 1024)}MB"
                else:
                    with open(task_queue_file, "r") as f:
                        data = json.load(f)
                        if isinstance(data, list):
                            task_count = len(data)
                        elif isinstance(data, dict) and "tasks" in data:
                            task_count = len(data["tasks"])
                        else:
                            task_count = "Unknown"
            except Exception as e:
                print(f"Error reading task_queue.json: {e}")
                task_count = "Error"

        # Basic system info
        try:
            # Get number of running agent processes
            import subprocess
            result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
            running_processes = len([line for line in result.stdout.split('\n') if 'agent_' in line and '.sh' in line])
        except:
            running_processes = 0

        return {
            "agents": agents,
            "system": {
                "cpu_usage": "N/A",
                "memory_usage": "N/A",
                "running_processes": running_processes
            },
            "tasks": task_count,
            "last_update": current_time
        }

def main():
    print(f"Starting Simple Dashboard API Server on port {PORT}")
    print(f"Dashboard: http://localhost:{PORT}/dashboard")
    print(f"API endpoint: http://localhost:{PORT}/api/dashboard-data")
    print(f"Agent data directory: {AGENTS_DIR}")

    with socketserver.TCPServer(("", PORT), SimpleDashboardHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down server...")
            httpd.shutdown()

if __name__ == "__main__":
    main()
