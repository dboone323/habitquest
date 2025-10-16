#!/usr/bin/env python3
"""
Resource Usage Forecasting System
Predicts future resource usage patterns to prevent system bottlenecks
"""

import json
import os
import psutil
import subprocess
from datetime import datetime, timedelta
from collections import deque
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import joblib
import warnings

warnings.filterwarnings("ignore")


class ResourceUsageForecaster:
    def __init__(self, data_dir="/Users/danielstevens/Desktop/Quantum-workspace/Tools"):
        self.data_dir = data_dir
        self.models_dir = os.path.join(data_dir, "models")
        self.logs_dir = os.path.join(data_dir, "logs")
        self.metrics_dir = os.path.join(data_dir, "metrics")

        # Create directories if they don't exist
        os.makedirs(self.models_dir, exist_ok=True)
        os.makedirs(self.metrics_dir, exist_ok=True)

        # Historical data storage
        self.resource_history_file = os.path.join(
            self.metrics_dir, "resource_history.json"
        )
        self.max_history_points = 1000  # Keep last 1000 measurements

        # Forecasting models
        self.cpu_forecaster = None
        self.memory_forecaster = None
        self.disk_forecaster = None
        self.scaler = StandardScaler()

        # Resource thresholds
        self.thresholds = {
            "cpu_percent": 80.0,  # Alert if CPU > 80%
            "memory_percent": 85.0,  # Alert if memory > 85%
            "disk_percent": 90.0,  # Alert if disk > 90%
            "cpu_trend_threshold": 5.0,  # Alert if CPU increasing by >5% per hour
            "memory_trend_threshold": 5.0,  # Alert if memory increasing by >5% per hour
        }

    def collect_current_metrics(self):
        """Collect current system resource metrics"""
        try:
            # CPU metrics
            cpu_percent = psutil.cpu_percent(interval=1)
            cpu_count = psutil.cpu_count()
            cpu_freq = psutil.cpu_freq()

            # Memory metrics
            memory = psutil.virtual_memory()
            memory_percent = memory.percent
            memory_used = memory.used / (1024**3)  # GB
            memory_total = memory.total / (1024**3)  # GB

            # Disk metrics
            disk = psutil.disk_usage("/")
            disk_percent = disk.percent
            disk_used = disk.used / (1024**3)  # GB
            disk_total = disk.total / (1024**3)  # GB

            # Network metrics (basic)
            network = psutil.net_io_counters()
            bytes_sent = network.bytes_sent / (1024**2)  # MB
            bytes_recv = network.bytes_recv / (1024**2)  # MB

            # System load
            load_avg = os.getloadavg() if hasattr(os, "getloadavg") else (0, 0, 0)

            metrics = {
                "timestamp": datetime.now().isoformat(),
                "cpu": {
                    "percent": cpu_percent,
                    "count": cpu_count,
                    "frequency_mhz": cpu_freq.current if cpu_freq else 0,
                },
                "memory": {
                    "percent": memory_percent,
                    "used_gb": round(memory_used, 2),
                    "total_gb": round(memory_total, 2),
                },
                "disk": {
                    "percent": disk_percent,
                    "used_gb": round(disk_used, 2),
                    "total_gb": round(disk_total, 2),
                },
                "network": {
                    "bytes_sent_mb": round(bytes_sent, 2),
                    "bytes_recv_mb": round(bytes_recv, 2),
                },
                "system": {
                    "load_average": load_avg,
                    "uptime_seconds": self.get_system_uptime(),
                },
            }

            return metrics

        except Exception as e:
            print(f"Error collecting metrics: {e}")
            return None

    def get_system_uptime(self):
        """Get system uptime in seconds"""
        try:
            with open("/proc/uptime", "r") as f:
                uptime_seconds = float(f.readline().split()[0])
                return uptime_seconds
        except:
            # Fallback for macOS
            try:
                result = subprocess.run(
                    ["sysctl", "-n", "kern.boottime"], capture_output=True, text=True
                )
                if result.returncode == 0:
                    # Parse boottime and calculate uptime
                    boottime_str = result.stdout.strip()
                    # This is a simplified parsing - in production you'd parse the full timestamp
                    return 0  # Placeholder
            except:
                pass
        return 0

    def store_metrics(self, metrics):
        """Store metrics in historical data file"""
        try:
            # Load existing history
            history = self.load_history()

            # Add new metrics
            history.append(metrics)

            # Keep only recent history
            if len(history) > self.max_history_points:
                history = history[-self.max_history_points :]

            # Save to file
            with open(self.resource_history_file, "w") as f:
                json.dump(history, f, indent=2)

        except Exception as e:
            print(f"Error storing metrics: {e}")

    def load_history(self):
        """Load historical resource metrics"""
        try:
            if os.path.exists(self.resource_history_file):
                with open(self.resource_history_file, "r") as f:
                    return json.load(f)
        except Exception as e:
            print(f"Error loading history: {e}")

        return []

    def prepare_forecasting_data(self, history, hours_ahead=24):
        """Prepare data for forecasting models"""
        if len(history) < 10:  # Need minimum data points
            return None

        df = pd.DataFrame(history)

        # Convert timestamp and extract time features
        df["timestamp"] = pd.to_datetime(df["timestamp"])
        df = df.sort_values("timestamp")

        # Add time-based features
        df["hour"] = df["timestamp"].dt.hour
        df["day_of_week"] = df["timestamp"].dt.dayofweek
        df["is_weekend"] = df["timestamp"].dt.dayofweek.isin([5, 6]).astype(int)

        # Extract resource metrics
        df["cpu_percent"] = df["cpu"].apply(lambda x: x.get("percent", 0))
        df["memory_percent"] = df["memory"].apply(lambda x: x.get("percent", 0))
        df["disk_percent"] = df["disk"].apply(lambda x: x.get("percent", 0))

        # Create target variables (predict next values)
        df["cpu_next"] = df["cpu_percent"].shift(-1)
        df["memory_next"] = df["memory_percent"].shift(-1)
        df["disk_next"] = df["disk_percent"].shift(-1)

        # Drop rows with NaN targets
        df = df.dropna(subset=["cpu_next", "memory_next", "disk_next"])

        if len(df) < 5:
            return None

        # Feature columns
        feature_cols = [
            "hour",
            "day_of_week",
            "is_weekend",
            "cpu_percent",
            "memory_percent",
            "disk_percent",
        ]

        return df, feature_cols

    def train_forecasting_models(self, df, feature_cols):
        """Train forecasting models for each resource"""
        print("🔄 Training resource forecasting models...")

        X = df[feature_cols]
        X_scaled = self.scaler.fit_transform(X)

        # Train CPU forecasting model
        y_cpu = df["cpu_next"]
        X_train_cpu, X_test_cpu, y_train_cpu, y_test_cpu = train_test_split(
            X_scaled, y_cpu, test_size=0.2, random_state=42
        )

        self.cpu_forecaster = RandomForestRegressor(
            n_estimators=100, max_depth=10, random_state=42
        )
        self.cpu_forecaster.fit(X_train_cpu, y_train_cpu)

        # Train Memory forecasting model
        y_memory = df["memory_next"]
        X_train_mem, X_test_mem, y_train_mem, y_test_mem = train_test_split(
            X_scaled, y_memory, test_size=0.2, random_state=42
        )

        self.memory_forecaster = RandomForestRegressor(
            n_estimators=100, max_depth=10, random_state=42
        )
        self.memory_forecaster.fit(X_train_mem, y_train_mem)

        # Train Disk forecasting model
        y_disk = df["disk_next"]
        X_train_disk, X_test_disk, y_train_disk, y_test_disk = train_test_split(
            X_scaled, y_disk, test_size=0.2, random_state=42
        )

        self.disk_forecaster = RandomForestRegressor(
            n_estimators=100, max_depth=10, random_state=42
        )
        self.disk_forecaster.fit(X_train_disk, y_train_disk)

        # Save models
        joblib.dump(
            self.cpu_forecaster, os.path.join(self.models_dir, "cpu_forecaster.pkl")
        )
        joblib.dump(
            self.memory_forecaster,
            os.path.join(self.models_dir, "memory_forecaster.pkl"),
        )
        joblib.dump(
            self.disk_forecaster, os.path.join(self.models_dir, "disk_forecaster.pkl")
        )
        joblib.dump(self.scaler, os.path.join(self.models_dir, "resource_scaler.pkl"))

        print("✅ Resource forecasting models trained and saved")

    def generate_forecasts(self, hours_ahead=24):
        """Generate resource usage forecasts"""
        if not self.load_models():
            print("❌ Forecasting models not available")
            return None

        forecasts = []
        current_time = datetime.now()

        # Get current metrics for starting point
        current_metrics = self.collect_current_metrics()
        if not current_metrics:
            return None

        # Generate forecast for each hour ahead
        for hour in range(1, hours_ahead + 1):
            forecast_time = current_time + timedelta(hours=hour)

            # Prepare features for prediction
            features = np.array(
                [
                    [
                        forecast_time.hour,  # hour
                        forecast_time.weekday(),  # day_of_week
                        1 if forecast_time.weekday() >= 5 else 0,  # is_weekend
                        current_metrics["cpu"]["percent"],  # current cpu
                        current_metrics["memory"]["percent"],  # current memory
                        current_metrics["disk"]["percent"],  # current disk
                    ]
                ]
            )

            # Scale features
            features_scaled = self.scaler.transform(features)

            # Generate predictions
            cpu_forecast = self.cpu_forecaster.predict(features_scaled)[0]
            memory_forecast = self.memory_forecaster.predict(features_scaled)[0]
            disk_forecast = self.disk_forecaster.predict(features_scaled)[0]

            forecast = {
                "timestamp": forecast_time.isoformat(),
                "hours_ahead": hour,
                "cpu_percent": round(max(0, min(100, cpu_forecast)), 2),
                "memory_percent": round(max(0, min(100, memory_forecast)), 2),
                "disk_percent": round(max(0, min(100, disk_forecast)), 2),
            }

            forecasts.append(forecast)

        return forecasts

    def load_models(self):
        """Load trained forecasting models"""
        try:
            self.cpu_forecaster = joblib.load(
                os.path.join(self.models_dir, "cpu_forecaster.pkl")
            )
            self.memory_forecaster = joblib.load(
                os.path.join(self.models_dir, "memory_forecaster.pkl")
            )
            self.disk_forecaster = joblib.load(
                os.path.join(self.models_dir, "disk_forecaster.pkl")
            )
            self.scaler = joblib.load(
                os.path.join(self.models_dir, "resource_scaler.pkl")
            )
            return True
        except FileNotFoundError:
            return False

    def analyze_forecasts(self, forecasts):
        """Analyze forecasts for potential issues"""
        if not forecasts:
            return None

        analysis = {
            "period_hours": len(forecasts),
            "alerts": [],
            "trends": {},
            "recommendations": [],
        }

        # Analyze CPU trends
        cpu_values = [f["cpu_percent"] for f in forecasts]
        cpu_trend = self.calculate_trend(cpu_values)
        analysis["trends"]["cpu"] = {
            "average": round(np.mean(cpu_values), 2),
            "peak": round(max(cpu_values), 2),
            "trend": cpu_trend,
            "will_exceed_threshold": max(cpu_values) > self.thresholds["cpu_percent"],
        }

        # Analyze Memory trends
        memory_values = [f["memory_percent"] for f in forecasts]
        memory_trend = self.calculate_trend(memory_values)
        analysis["trends"]["memory"] = {
            "average": round(np.mean(memory_values), 2),
            "peak": round(max(memory_values), 2),
            "trend": memory_trend,
            "will_exceed_threshold": max(memory_values)
            > self.thresholds["memory_percent"],
        }

        # Analyze Disk trends
        disk_values = [f["disk_percent"] for f in forecasts]
        disk_trend = self.calculate_trend(disk_values)
        analysis["trends"]["disk"] = {
            "average": round(np.mean(disk_values), 2),
            "peak": round(max(disk_values), 2),
            "trend": disk_trend,
            "will_exceed_threshold": max(disk_values) > self.thresholds["disk_percent"],
        }

        # Generate alerts
        if analysis["trends"]["cpu"]["will_exceed_threshold"]:
            analysis["alerts"].append(
                {
                    "type": "cpu_threshold",
                    "severity": "high",
                    "message": f'CPU usage forecasted to exceed {self.thresholds["cpu_percent"]}% threshold',
                    "peak_value": analysis["trends"]["cpu"]["peak"],
                }
            )

        if analysis["trends"]["memory"]["will_exceed_threshold"]:
            analysis["alerts"].append(
                {
                    "type": "memory_threshold",
                    "severity": "high",
                    "message": f'Memory usage forecasted to exceed {self.thresholds["memory_percent"]}% threshold',
                    "peak_value": analysis["trends"]["memory"]["peak"],
                }
            )

        if analysis["trends"]["disk"]["will_exceed_threshold"]:
            analysis["alerts"].append(
                {
                    "type": "disk_threshold",
                    "severity": "critical",
                    "message": f'Disk usage forecasted to exceed {self.thresholds["disk_percent"]}% threshold',
                    "peak_value": analysis["trends"]["disk"]["peak"],
                }
            )

        # Generate recommendations
        if cpu_trend > self.thresholds["cpu_trend_threshold"]:
            analysis["recommendations"].append(
                {
                    "resource": "cpu",
                    "action": "Monitor CPU-intensive processes and consider load balancing",
                    "priority": "medium",
                }
            )

        if memory_trend > self.thresholds["memory_trend_threshold"]:
            analysis["recommendations"].append(
                {
                    "resource": "memory",
                    "action": "Check for memory leaks and optimize memory usage",
                    "priority": "high",
                }
            )

        if analysis["trends"]["disk"]["trend"] > 0.1:  # Disk increasing significantly
            analysis["recommendations"].append(
                {
                    "resource": "disk",
                    "action": "Clean up old files and archives to prevent disk space issues",
                    "priority": "medium",
                }
            )

        return analysis

    def calculate_trend(self, values):
        """Calculate linear trend slope"""
        if len(values) < 2:
            return 0

        x = np.arange(len(values))
        slope, _ = np.polyfit(x, values, 1)
        return slope

    def generate_forecast_report(self, forecasts, analysis):
        """Generate comprehensive forecast report"""
        current_metrics = self.collect_current_metrics()

        report = {
            "timestamp": datetime.now().isoformat(),
            "current_metrics": current_metrics,
            "forecast_period_hours": len(forecasts) if forecasts else 0,
            "forecasts": forecasts,
            "analysis": analysis,
            "thresholds": self.thresholds,
        }

        return report

    def save_forecast_report(self, report):
        """Save forecast report to file"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"resource_forecast_{timestamp}.json"
        filepath = os.path.join(self.logs_dir, filename)

        with open(filepath, "w") as f:
            json.dump(report, f, indent=2, default=str)

        print(f"📄 Forecast report saved to {filepath}")
        return filepath

    def print_forecast_summary(self, report):
        """Print human-readable forecast summary"""
        print("\n📊 Resource Usage Forecast Summary")
        print("=" * 50)

        current = report.get("current_metrics", {})
        analysis = report.get("analysis", {})

        if current:
            print("Current Resource Usage:")
            print(f"  CPU: {current.get('cpu', {}).get('percent', 0):.1f}%")
            print(f"  Memory: {current.get('memory', {}).get('percent', 0):.1f}%")
            print(f"  Disk: {current.get('disk', {}).get('percent', 0):.1f}%")
        if analysis:
            trends = analysis.get("trends", {})
            alerts = analysis.get("alerts", [])
            recommendations = analysis.get("recommendations", [])

            print(
                f"\nForecast Analysis ({report.get('forecast_period_hours', 0)} hours ahead):"
            )

            for resource, trend in trends.items():
                status = "🚨" if trend.get("will_exceed_threshold") else "✅"
                print(
                    f"  {status} {resource.upper()}: avg {trend.get('average', 0):.1f}%, peak {trend.get('peak', 0):.1f}% ({trend.get('trend', 0):.3f} trend)"
                )
            if alerts:
                print("\n🚨 Alerts:")
                for alert in alerts:
                    print(f"  {alert['message']}")

            if recommendations:
                print("\n💡 Recommendations:")
                for rec in recommendations:
                    priority_icon = {"high": "🔴", "medium": "🟡", "low": "🟢"}.get(
                        rec["priority"], "⚪"
                    )
                    print(
                        f"  {priority_icon} {rec['resource'].upper()}: {rec['action']}"
                    )


def main():
    print("🔮 Resource Usage Forecasting Starting...")

    forecaster = ResourceUsageForecaster()

    # Collect current metrics
    print("📏 Collecting current resource metrics...")
    current_metrics = forecaster.collect_current_metrics()
    if current_metrics:
        forecaster.store_metrics(current_metrics)
        print("✅ Metrics collected and stored")

    # Load historical data and train models if needed
    history = forecaster.load_history()
    if len(history) >= 10:
        print("🔄 Preparing forecasting data...")
        forecast_data = forecaster.prepare_forecasting_data(history)

        if forecast_data:
            df, feature_cols = forecast_data
            forecaster.train_forecasting_models(df, feature_cols)

            # Generate forecasts
            print("🔮 Generating resource forecasts...")
            forecasts = forecaster.generate_forecasts(hours_ahead=24)

            if forecasts:
                # Analyze forecasts
                analysis = forecaster.analyze_forecasts(forecasts)

                # Generate and save report
                report = forecaster.generate_forecast_report(forecasts, analysis)
                forecaster.save_forecast_report(report)

                # Print summary
                forecaster.print_forecast_summary(report)
            else:
                print("❌ Failed to generate forecasts")
        else:
            print("❌ Insufficient data for forecasting")
    else:
        print(
            f"ℹ️  Need at least 10 data points for forecasting. Currently have {len(history)}."
        )
        print("   Run this script multiple times to collect more historical data.")

    print("\n✅ Resource forecasting completed!")


if __name__ == "__main__":
    main()
