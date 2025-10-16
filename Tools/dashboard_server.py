#!/usr/bin/env python3
"""
Advanced Analytics Dashboard Server
Interactive web dashboard with real-time metrics visualization
"""
import json
import os
import time
from datetime import datetime, timedelta
from pathlib import Path
from flask import Flask, render_template, jsonify, request, send_from_directory
from flask_cors import CORS
import threading
import psutil


class AdvancedAnalyticsDashboard:
    def __init__(self, data_dir="/Users/danielstevens/Desktop/Quantum-workspace/Tools"):
        self.data_dir = Path(data_dir)
        self.logs_dir = self.data_dir / "logs"
        self.metrics_dir = self.data_dir / "metrics"
        self.templates_dir = self.data_dir / "templates"

        # Create templates directory if it doesn't exist
        self.templates_dir.mkdir(exist_ok=True)

        # Initialize Flask app
        self.app = Flask(
            __name__,
            template_folder=str(self.templates_dir),
            static_folder=str(self.data_dir / "static"),
        )
        CORS(self.app)

        self.setup_routes()
        self.create_templates()

    def setup_routes(self):
        """Setup Flask routes"""

        @self.app.route("/")
        def dashboard():
            return render_template("dashboard.html")

        @self.app.route("/api/dashboard-data")
        def get_dashboard_data():
            return jsonify(self.get_dashboard_data())

        @self.app.route("/api/metrics/<metric_type>")
        def get_metrics(metric_type):
            return jsonify(self.get_metrics_data(metric_type))

        @self.app.route("/api/alerts")
        def get_alerts():
            return jsonify(self.get_alerts_data())

        @self.app.route("/api/predictions")
        def get_predictions():
            return jsonify(self.get_predictions_data())

        @self.app.route("/api/trends/<timeframe>")
        def get_trends(timeframe):
            return jsonify(self.get_trends_data(timeframe))

        @self.app.route("/api/system-info")
        def get_system_info():
            return jsonify(self.get_system_info())

        @self.app.route("/api/health")
        def health_check():
            return jsonify(
                {"status": "healthy", "timestamp": datetime.now().isoformat()}
            )

    def create_templates(self):
        """Create HTML templates for the dashboard"""
        dashboard_html = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Advanced Analytics Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/moment@2.29.4/moment.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-moment@1.0.1/dist/chartjs-adapter-moment.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .card { margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric-card { text-align: center; }
        .metric-value { font-size: 2rem; font-weight: bold; }
        .metric-label { color: #6c757d; font-size: 0.9rem; }
        .alert-critical { background-color: #f8d7da; border-color: #f5c6cb; }
        .alert-high { background-color: #fff3cd; border-color: #ffeaa7; }
        .alert-medium { background-color: #d1ecf1; border-color: #bee5eb; }
        .alert-low { background-color: #d4edda; border-color: #c3e6cb; }
        .status-healthy { color: #28a745; }
        .status-warning { color: #ffc107; }
        .status-critical { color: #dc3545; }
    </style>
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <div class="container-fluid">
            <span class="navbar-brand mb-0 h1">🚀 Advanced Analytics Dashboard</span>
            <div id="last-update" class="text-light"></div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <!-- System Overview -->
        <div class="row">
            <div class="col-md-3">
                <div class="card metric-card">
                    <div class="card-body">
                        <div class="metric-value text-primary" id="cpu-usage">0%</div>
                        <div class="metric-label">CPU Usage</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card metric-card">
                    <div class="card-body">
                        <div class="metric-value text-info" id="memory-usage">0%</div>
                        <div class="metric-label">Memory Usage</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card metric-card">
                    <div class="card-body">
                        <div class="metric-value text-warning" id="disk-usage">0%</div>
                        <div class="metric-label">Disk Usage</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card metric-card">
                    <div class="card-body">
                        <div class="metric-value text-success" id="tools-healthy">0/0</div>
                        <div class="metric-label">Tools Healthy</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Row -->
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h5>System Metrics Over Time</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="metricsChart" width="400" height="200"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5>Active Alerts</h5>
                    </div>
                    <div class="card-body" id="alerts-panel">
                        <p class="text-muted">Loading alerts...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tool Status and Predictions -->
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Tool Status</h5>
                    </div>
                    <div class="card-body" id="tools-panel">
                        <p class="text-muted">Loading tool status...</p>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Failure Predictions</h5>
                    </div>
                    <div class="card-body" id="predictions-panel">
                        <p class="text-muted">Loading predictions...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Performance Trends -->
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header">
                        <h5>Performance Trends (24h)</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="trendsChart" width="400" height="150"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        let metricsChart, trendsChart;
        let lastUpdate = Date.now();

        // Initialize charts
        function initCharts() {
            const ctx = document.getElementById('metricsChart').getContext('2d');
            metricsChart = new Chart(ctx, {
                type: 'line',
                data: {
                    datasets: [{
                        label: 'CPU Usage %',
                        borderColor: 'rgb(75, 192, 192)',
                        data: []
                    }, {
                        label: 'Memory Usage %',
                        borderColor: 'rgb(255, 99, 132)',
                        data: []
                    }, {
                        label: 'Disk Usage %',
                        borderColor: 'rgb(255, 205, 86)',
                        data: []
                    }]
                },
                options: {
                    scales: {
                        x: {
                            type: 'time',
                            time: {
                                unit: 'minute',
                                displayFormats: {
                                    minute: 'HH:mm'
                                }
                            }
                        }
                    },
                    animation: false
                }
            });

            const trendsCtx = document.getElementById('trendsChart').getContext('2d');
            trendsChart = new Chart(trendsCtx, {
                type: 'line',
                data: {
                    datasets: [{
                        label: 'Response Time (ms)',
                        borderColor: 'rgb(54, 162, 235)',
                        data: []
                    }]
                },
                options: {
                    scales: {
                        x: {
                            type: 'time',
                            time: {
                                unit: 'hour'
                            }
                        }
                    },
                    animation: false
                }
            });
        }

        // Update dashboard data
        async function updateDashboard() {
            try {
                const response = await fetch('/api/dashboard-data');
                const data = await response.json();

                updateMetrics(data);
                updateTools(data);
                updateLastUpdate();

            } catch (error) {
                console.error('Error updating dashboard:', error);
            }
        }

        // Update metrics display
        function updateMetrics(data) {
            const system = data.system || {};

            // Update metric cards
            document.getElementById('cpu-usage').textContent =
                system.cpu ? Math.round(system.cpu.percent) + '%' : 'N/A';
            document.getElementById('memory-usage').textContent =
                system.memory ? Math.round(system.memory.percent) + '%' : 'N/A';
            document.getElementById('disk-usage').textContent =
                system.disk_usage ? Math.round(system.disk_usage.percent) + '%' : 'N/A';

            // Update tools healthy count
            const tools = data.tools || {};
            const details = tools.details || {};
            const totalTools = Object.keys(details).length;
            const healthyTools = Object.values(details).filter(t => t.status === 'healthy').length;
            document.getElementById('tools-healthy').textContent = `${healthyTools}/${totalTools}`;

            // Update charts with historical data
            updateCharts();
        }

        // Update tools panel
        function updateTools(data) {
            const tools = data.tools || {};
            const details = tools.details || {};
            const panel = document.getElementById('tools-panel');

            let html = '';
            for (const [name, info] of Object.entries(details)) {
                const statusClass = info.status === 'healthy' ? 'status-healthy' : 'status-critical';
                const statusIcon = info.status === 'healthy' ? '✅' : '❌';
                html += `
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span>${name}</span>
                        <span class="${statusClass}">${statusIcon} ${info.status}</span>
                    </div>
                `;
            }
            panel.innerHTML = html || '<p class="text-muted">No tools data available</p>';
        }

        // Update charts with metrics data
        async function updateCharts() {
            try {
                const response = await fetch('/api/metrics/system');
                const metrics = await response.json();

                if (metricsChart && metrics.length > 0) {
                    metricsChart.data.datasets[0].data = metrics.map(m => ({
                        x: new Date(m.timestamp),
                        y: m.cpu_percent
                    }));
                    metricsChart.data.datasets[1].data = metrics.map(m => ({
                        x: new Date(m.timestamp),
                        y: m.memory_percent
                    }));
                    metricsChart.data.datasets[2].data = metrics.map(m => ({
                        x: new Date(m.timestamp),
                        y: m.disk_percent
                    }));
                    metricsChart.update();
                }
            } catch (error) {
                console.error('Error updating charts:', error);
            }
        }

        // Update alerts panel
        async function updateAlerts() {
            try {
                const response = await fetch('/api/alerts');
                const alerts = await response.json();
                const panel = document.getElementById('alerts-panel');

                let html = '';
                const recentAlerts = alerts.slice(0, 5); // Show last 5 alerts

                for (const alert of recentAlerts) {
                    const levelClass = `alert-${alert.level.toLowerCase()}`;
                    html += `
                        <div class="alert ${levelClass} py-2 px-3 mb-2">
                            <small><strong>${alert.level}:</strong> ${alert.title}</small>
                        </div>
                    `;
                }
                panel.innerHTML = html || '<p class="text-muted">No recent alerts</p>';
            } catch (error) {
                console.error('Error updating alerts:', error);
            }
        }

        // Update predictions panel
        async function updatePredictions() {
            try {
                const response = await fetch('/api/predictions');
                const predictions = await response.json();
                const panel = document.getElementById('predictions-panel');

                let html = '';
                if (predictions.summary) {
                    const summary = predictions.summary;
                    html += `<p><strong>Risks:</strong> ${summary.critical_risks} critical, ${summary.high_risks} high</p>`;
                }

                if (predictions.predictions) {
                    for (const [tool, pred] of Object.entries(predictions.predictions)) {
                        const riskClass = pred.risk_level === 'CRITICAL' ? 'status-critical' :
                                        pred.risk_level === 'HIGH' ? 'status-warning' : 'status-healthy';
                        html += `
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <small>${tool}</small>
                                <small class="${riskClass}">${pred.risk_level}</small>
                            </div>
                        `;
                    }
                }
                panel.innerHTML = html || '<p class="text-muted">No predictions available</p>';
            } catch (error) {
                console.error('Error updating predictions:', error);
            }
        }

        // Update last update timestamp
        function updateLastUpdate() {
            lastUpdate = Date.now();
            document.getElementById('last-update').textContent =
                'Last update: ' + new Date(lastUpdate).toLocaleTimeString();
        }

        // Initialize and start updates
        document.addEventListener('DOMContentLoaded', function() {
            initCharts();
            updateDashboard();
            updateAlerts();
            updatePredictions();

            // Update every 30 seconds
            setInterval(() => {
                updateDashboard();
                updateAlerts();
                updatePredictions();
            }, 30000);
        });
    </script>
</body>
</html>
        """

        # Write dashboard template
        with open(self.templates_dir / "dashboard.html", "w") as f:
            f.write(dashboard_html)

    def get_dashboard_data(self):
        """Get current dashboard data"""
        data_file = self.data_dir / "dashboard_data.json"
        if data_file.exists():
            try:
                with open(data_file, "r") as f:
                    return json.load(f)
            except Exception as e:
                return {"error": str(e)}
        return {"error": "Dashboard data not found"}

    def get_metrics_data(self, metric_type):
        """Get historical metrics data"""
        metrics = []

        # Look for metrics files
        if self.metrics_dir.exists():
            for file_path in sorted(self.metrics_dir.glob("*.json")):
                try:
                    with open(file_path, "r") as f:
                        data = json.load(f)
                        if metric_type in data:
                            metrics.extend(data[metric_type])
                except Exception:
                    continue

        # Return last 100 data points
        return metrics[-100:]

    def get_alerts_data(self):
        """Get recent alerts data"""
        alerts_file = self.logs_dir / "alert_history.json"
        if alerts_file.exists():
            try:
                with open(alerts_file, "r") as f:
                    alerts = json.load(f)
                    # Return last 50 alerts
                    return alerts[-50:]
            except Exception:
                pass
        return []

    def get_predictions_data(self):
        """Get latest predictions data"""
        prediction_files = list(self.logs_dir.glob("predictions_*.json"))
        if prediction_files:
            latest_file = max(prediction_files, key=lambda x: x.stat().st_mtime)
            try:
                with open(latest_file, "r") as f:
                    return json.load(f)
            except Exception:
                pass
        return {}

    def get_trends_data(self, timeframe):
        """Get trend data for specified timeframe"""
        # This would aggregate data over the specified timeframe
        # For now, return sample data
        return {"timeframe": timeframe, "data": []}

    def get_system_info(self):
        """Get current system information"""
        return {
            "cpu_percent": psutil.cpu_percent(interval=1),
            "memory": psutil.virtual_memory()._asdict(),
            "disk": psutil.disk_usage("/")._asdict(),
            "timestamp": datetime.now().isoformat(),
        }

    def run(self, host="0.0.0.0", port=5000, debug=False):
        """Run the dashboard server"""
        print(f"🚀 Advanced Analytics Dashboard starting on http://{host}:{port}")
        print("Features:")
        print("  📊 Real-time metrics visualization")
        print("  📈 Interactive charts and graphs")
        print("  🚨 Live alerts monitoring")
        print("  🔮 Predictive analytics display")
        print("  📱 Responsive design")
        print()

        self.app.run(host=host, port=port, debug=debug)


def main():
    dashboard = AdvancedAnalyticsDashboard()
    dashboard.run()


if __name__ == "__main__":
    main()
