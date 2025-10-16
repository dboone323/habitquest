#!/usr/bin/env python3
"""
Performance Trend Analysis System
Analyzes tool performance trends and detects degradation patterns
"""

import json
import os
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
import matplotlib.pyplot as plt
import warnings

warnings.filterwarnings("ignore")


class PerformanceTrendAnalyzer:
    def __init__(self, data_dir="/Users/danielstevens/Desktop/Quantum-workspace/Tools"):
        self.data_dir = data_dir
        self.metrics_dir = os.path.join(data_dir, "metrics")
        self.logs_dir = os.path.join(data_dir, "logs")
        self.reports_dir = os.path.join(data_dir, "reports")

        # Create reports directory if it doesn't exist
        os.makedirs(self.reports_dir, exist_ok=True)

        # Tools to monitor
        self.tools = [
            "git",
            "python3",
            "node",
            "npm",
            "brew",
            "ollama",
            "jq",
            "swiftlint",
            "swiftformat",
            "xcodebuild",
            "swift",
            "fastlane",
            "pod",
            "gh",
        ]

    def load_historical_data(self):
        """Load all historical benchmark data"""
        data_files = []
        if os.path.exists(self.metrics_dir):
            for file in os.listdir(self.metrics_dir):
                if file.startswith("benchmark_") and file.endswith(".json"):
                    data_files.append(os.path.join(self.metrics_dir, file))

        all_data = []
        for file_path in data_files:
            try:
                with open(file_path, "r") as f:
                    benchmark_data = json.load(f)
                    timestamp = benchmark_data.get("timestamp")

                    for result in benchmark_data.get("results", []):
                        all_data.append(
                            {
                                "timestamp": timestamp,
                                "tool": result["tool"],
                                "response_time": result["response_time"],
                                "status": result["status"],
                            }
                        )
            except Exception as e:
                print(f"Warning: Could not load {file_path}: {e}")

        if all_data:
            df = pd.DataFrame(all_data)
            df["timestamp"] = pd.to_datetime(df["timestamp"])
            df = df.sort_values(["tool", "timestamp"])
            print(
                f"✅ Loaded {len(all_data)} historical data points from {len(data_files)} files"
            )
            return df
        else:
            print("❌ No historical data found")
            return None

    def calculate_trend_metrics(self, df):
        """Calculate trend metrics for each tool"""
        trend_results = {}

        for tool in self.tools:
            tool_data = df[df["tool"] == tool].copy()

            if len(tool_data) < 3:  # Need at least 3 points for trend analysis
                trend_results[tool] = {
                    "trend": "insufficient_data",
                    "slope": 0,
                    "correlation": 0,
                    "volatility": 0,
                    "data_points": len(tool_data),
                }
                continue

            # Prepare data for trend analysis
            tool_data = tool_data.sort_values("timestamp")
            tool_data["time_index"] = range(len(tool_data))
            tool_data["response_time_ma"] = (
                tool_data["response_time"]
                .rolling(window=min(5, len(tool_data)), center=True)
                .mean()
            )

            # Linear regression for trend
            X = tool_data["time_index"].values.reshape(-1, 1)
            y = tool_data["response_time"].values

            try:
                model = LinearRegression()
                model.fit(X, y)
                slope = model.coef_[0]
                correlation = np.corrcoef(X.flatten(), y)[0, 1]

                # Calculate volatility (coefficient of variation)
                volatility = (
                    tool_data["response_time"].std() / tool_data["response_time"].mean()
                    if tool_data["response_time"].mean() > 0
                    else 0
                )

                # Determine trend direction
                if slope > 0.001:
                    trend = "degrading"
                elif slope < -0.001:
                    trend = "improving"
                else:
                    trend = "stable"

                # Check for recent degradation (last 3 points vs previous)
                recent_data = tool_data.tail(3)
                previous_data = tool_data.head(-3) if len(tool_data) > 3 else tool_data

                if len(recent_data) >= 3 and len(previous_data) >= 3:
                    recent_avg = recent_data["response_time"].mean()
                    previous_avg = previous_data["response_time"].mean()
                    recent_change = (
                        (recent_avg - previous_avg) / previous_avg
                        if previous_avg > 0
                        else 0
                    )

                    if recent_change > 0.1:  # 10% increase
                        trend = "rapid_degradation"
                    elif recent_change > 0.05:  # 5% increase
                        trend = "gradual_degradation"
                elif len(recent_data) >= 2:
                    # Check for consecutive increases
                    recent_values = recent_data["response_time"].values
                    if (
                        len(recent_values) >= 2
                        and recent_values[-1] > recent_values[-2] * 1.05
                    ):
                        trend = "increasing"

                trend_results[tool] = {
                    "trend": trend,
                    "slope": slope,
                    "correlation": correlation,
                    "volatility": volatility,
                    "data_points": len(tool_data),
                    "current_avg": tool_data["response_time"].tail(3).mean(),
                    "overall_avg": tool_data["response_time"].mean(),
                    "max_response": tool_data["response_time"].max(),
                    "min_response": tool_data["response_time"].min(),
                }

            except Exception as e:
                trend_results[tool] = {
                    "trend": "error",
                    "error": str(e),
                    "data_points": len(tool_data),
                }

        return trend_results

    def detect_performance_anomalies(self, df):
        """Detect performance anomalies using statistical methods"""
        anomalies = {}

        for tool in self.tools:
            tool_data = df[df["tool"] == tool].copy()

            if len(tool_data) < 5:  # Need minimum data points
                anomalies[tool] = []
                continue

            # Calculate rolling statistics
            tool_data = tool_data.sort_values("timestamp")
            tool_data["rolling_mean"] = (
                tool_data["response_time"].rolling(window=5, center=True).mean()
            )
            tool_data["rolling_std"] = (
                tool_data["response_time"].rolling(window=5, center=True).std()
            )

            # Detect anomalies (values > 2 standard deviations from rolling mean)
            tool_anomalies = []
            for idx, row in tool_data.iterrows():
                if pd.notna(row["rolling_mean"]) and pd.notna(row["rolling_std"]):
                    threshold = row["rolling_mean"] + 2 * row["rolling_std"]
                    if row["response_time"] > threshold:
                        tool_anomalies.append(
                            {
                                "timestamp": row["timestamp"].isoformat(),
                                "response_time": row["response_time"],
                                "threshold": threshold,
                                "deviation": (
                                    row["response_time"] - row["rolling_mean"]
                                )
                                / row["rolling_std"],
                            }
                        )

            anomalies[tool] = tool_anomalies

        return anomalies

    def generate_trend_report(self, trend_results, anomalies):
        """Generate comprehensive trend analysis report"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "analysis_period": "all_available_data",
            "summary": {
                "total_tools": len(self.tools),
                "degrading_tools": len(
                    [
                        t
                        for t in trend_results.values()
                        if t.get("trend")
                        in ["degrading", "rapid_degradation", "gradual_degradation"]
                    ]
                ),
                "improving_tools": len(
                    [t for t in trend_results.values() if t.get("trend") == "improving"]
                ),
                "stable_tools": len(
                    [t for t in trend_results.values() if t.get("trend") == "stable"]
                ),
                "insufficient_data": len(
                    [
                        t
                        for t in trend_results.values()
                        if t.get("trend") == "insufficient_data"
                    ]
                ),
                "total_anomalies": sum(len(anoms) for anoms in anomalies.values()),
            },
            "trends": trend_results,
            "anomalies": anomalies,
            "recommendations": self.generate_recommendations(trend_results, anomalies),
        }

        return report

    def generate_recommendations(self, trend_results, anomalies):
        """Generate actionable recommendations based on trends and anomalies"""
        recommendations = []

        for tool, trend in trend_results.items():
            trend_type = trend.get("trend", "unknown")

            if trend_type in ["degrading", "rapid_degradation"]:
                recommendations.append(
                    {
                        "tool": tool,
                        "priority": (
                            "HIGH" if trend_type == "rapid_degradation" else "MEDIUM"
                        ),
                        "issue": f'Performance degradation detected (slope: {trend.get("slope", 0):.4f})',
                        "action": f"Investigate {tool} performance issues and consider optimization or replacement",
                    }
                )

            elif trend_type == "gradual_degradation":
                recommendations.append(
                    {
                        "tool": tool,
                        "priority": "MEDIUM",
                        "issue": f"Gradual performance decline over time",
                        "action": f"Monitor {tool} closely and plan maintenance",
                    }
                )

            if len(anomalies.get(tool, [])) > 0:
                recommendations.append(
                    {
                        "tool": tool,
                        "priority": "MEDIUM",
                        "issue": f"{len(anomalies[tool])} performance anomalies detected",
                        "action": f"Analyze anomalous behavior for {tool} and identify root causes",
                    }
                )

        # Sort by priority
        priority_order = {"HIGH": 0, "MEDIUM": 1, "LOW": 2}
        recommendations.sort(key=lambda x: priority_order.get(x["priority"], 3))

        return recommendations

    def save_report(self, report, filename=None):
        """Save trend analysis report to file"""
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"trend_analysis_{timestamp}.json"

        filepath = os.path.join(self.reports_dir, filename)
        with open(filepath, "w") as f:
            json.dump(report, f, indent=2, default=str)

        print(f"📄 Report saved to {filepath}")
        return filepath

    def print_summary(self, report):
        """Print human-readable summary of trend analysis"""
        print("\n📊 Performance Trend Analysis Summary")
        print("=" * 50)

        summary = report["summary"]
        print(f"Total Tools Analyzed: {summary['total_tools']}")
        print(f"Degrading Performance: {summary['degrading_tools']}")
        print(f"Improving Performance: {summary['improving_tools']}")
        print(f"Stable Performance: {summary['stable_tools']}")
        print(f"Insufficient Data: {summary['insufficient_data']}")
        print(f"Total Anomalies: {summary['total_anomalies']}")

        print("\n🔍 Tool Performance Trends:")
        for tool, trend in report["trends"].items():
            trend_type = trend.get("trend", "unknown")
            status_icon = {
                "degrading": "📉",
                "rapid_degradation": "🚨",
                "gradual_degradation": "⚠️",
                "improving": "📈",
                "stable": "➡️",
                "insufficient_data": "❓",
                "error": "❌",
            }.get(trend_type, "❓")

            data_points = trend.get("data_points", 0)
            slope = trend.get("slope", 0)

            print(
                f"  {status_icon} {tool}: {trend_type} ({data_points} data points, slope: {slope:.4f})"
            )

        if report["recommendations"]:
            print("\n💡 Recommendations:")
            for rec in report["recommendations"][:5]:  # Show top 5
                priority_icon = {"HIGH": "🔴", "MEDIUM": "🟡", "LOW": "🟢"}.get(
                    rec["priority"], "⚪"
                )
                print(
                    f"  {priority_icon} [{rec['priority']}] {rec['tool']}: {rec['action']}"
                )


def main():
    print("📈 Performance Trend Analysis Starting...")

    analyzer = PerformanceTrendAnalyzer()

    # Load historical data
    historical_data = analyzer.load_historical_data()

    if historical_data is None:
        print("❌ No historical data available for trend analysis")
        return

    # Calculate trend metrics
    print("🔄 Analyzing performance trends...")
    trend_results = analyzer.calculate_trend_metrics(historical_data)

    # Detect anomalies
    print("🔍 Detecting performance anomalies...")
    anomalies = analyzer.detect_performance_anomalies(historical_data)

    # Generate comprehensive report
    report = analyzer.generate_trend_report(trend_results, anomalies)

    # Save report
    analyzer.save_report(report)

    # Print summary
    analyzer.print_summary(report)

    print("\n✅ Performance trend analysis completed!")


if __name__ == "__main__":
    main()
