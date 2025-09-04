#!/usr/bin/env python3
"""
Simple HTTP server to serve the monitoring dashboard with live data
"""
import http.server
import json
import os
import socketserver
from pathlib import Path


class DashboardHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/dashboard-data":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()

            # Read dashboard data
            data_file = Path(
                "/Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/dashboard_data.json"
            )
            if data_file.exists():
                try:
                    with open(data_file, "r") as f:
                        data = json.load(f)
                    self.wfile.write(json.dumps(data).encode())
                except Exception as e:
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
            else:
                self.wfile.write(
                    json.dumps({"error": "Dashboard data not found"}).encode()
                )
        else:
            # Serve static files
            super().do_GET()

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()


def run_server(port=8000):
    """Run the dashboard server"""
    os.chdir("/Users/danielstevens/Desktop/Quantum-workspace/Tools")

    with socketserver.TCPServer(("", port), DashboardHandler) as httpd:
        print(f"Dashboard server running at http://localhost:{port}")
        print("Press Ctrl+C to stop")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped")
            httpd.shutdown()


if __name__ == "__main__":
    run_server()
