#!/usr/bin/env python3
"""
Predictive Maintenance System for Tool Monitoring
Implements ML-based failure prediction using historical monitoring data
"""

import json
import os
import sys
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from sklearn.ensemble import RandomForestClassifier, IsolationForest
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import joblib
import warnings

warnings.filterwarnings("ignore")


class PredictiveMaintenanceSystem:
    def __init__(self, data_dir="/Users/danielstevens/Desktop/Quantum-workspace/Tools"):
        self.data_dir = data_dir
        self.metrics_dir = os.path.join(data_dir, "metrics")
        self.logs_dir = os.path.join(data_dir, "logs")
        self.models_dir = os.path.join(data_dir, "models")
        self.dashboard_data_file = os.path.join(data_dir, "dashboard_data.json")

        # Create models directory if it doesn't exist
        os.makedirs(self.models_dir, exist_ok=True)

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

        # ML models
        self.failure_predictor = None
        self.anomaly_detector = None
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()

    def generate_synthetic_data(self, days=30):
        """Generate synthetic historical data for training"""
        print("🔄 Generating synthetic training data...")

        data = []
        base_time = datetime.now() - timedelta(days=days)

        for day in range(days):
            for hour in range(24):
                timestamp = base_time + timedelta(days=day, hours=hour)

                for tool in self.tools:
                    # Simulate realistic tool behavior
                    response_time = np.random.exponential(
                        0.1
                    )  # Most tools respond quickly

                    # Introduce occasional failures and performance degradation
                    failure_prob = 0.02  # 2% base failure rate
                    if np.random.random() < failure_prob:
                        status = "failed"
                        response_time = np.random.uniform(5, 30)  # Slow when failing
                    else:
                        status = "success"

                    # Add some tools that are more prone to failure
                    if tool in ["swiftlint", "swiftformat", "xcodebuild"]:
                        if (
                            np.random.random() < 0.05
                        ):  # 5% failure rate for complex tools
                            status = "failed"
                            response_time = np.random.uniform(10, 60)

                    # Simulate periodic maintenance windows
                    if timestamp.hour in [2, 3, 4]:  # Maintenance window
                        if np.random.random() < 0.1:
                            status = "failed"
                            response_time = np.random.uniform(15, 120)

                    # Add system load factor
                    system_load = np.random.uniform(0.1, 0.9)
                    if system_load > 0.8 and np.random.random() < 0.3:
                        response_time *= 2
                        if np.random.random() < 0.1:
                            status = "failed"

                    data.append(
                        {
                            "timestamp": timestamp.isoformat(),
                            "tool": tool,
                            "response_time": round(response_time, 3),
                            "status": status,
                            "system_load": round(system_load, 2),
                            "hour": timestamp.hour,
                            "day_of_week": timestamp.weekday(),
                            "is_maintenance_window": (
                                1 if timestamp.hour in [2, 3, 4] else 0
                            ),
                        }
                    )

        df = pd.DataFrame(data)
        df.to_csv(
            os.path.join(self.metrics_dir, "synthetic_training_data.csv"), index=False
        )
        print(f"✅ Generated {len(data)} synthetic data points")
        return df

    def prepare_features(self, df):
        """Prepare features for ML training"""
        # Create failure indicator
        df["failure"] = (df["status"] == "failed").astype(int)

        # Create time-based features
        df["timestamp"] = pd.to_datetime(df["timestamp"])
        df["hour_sin"] = np.sin(2 * np.pi * df["hour"] / 24)
        df["hour_cos"] = np.cos(2 * np.pi * df["hour"] / 24)

        # Rolling statistics (simulate historical context)
        df = df.sort_values(["tool", "timestamp"])
        df["rolling_mean_response"] = (
            df.groupby("tool")["response_time"]
            .rolling(window=10, min_periods=1)
            .mean()
            .reset_index(0, drop=True)
        )
        df["rolling_std_response"] = (
            df.groupby("tool")["response_time"]
            .rolling(window=10, min_periods=1)
            .std()
            .reset_index(0, drop=True)
        )
        df["rolling_failure_rate"] = (
            df.groupby("tool")["failure"]
            .rolling(window=20, min_periods=1)
            .mean()
            .reset_index(0, drop=True)
        )

        # Fill NaN values
        df = df.fillna(0)

        # Select features for prediction
        features = [
            "response_time",
            "system_load",
            "hour_sin",
            "hour_cos",
            "is_maintenance_window",
            "rolling_mean_response",
            "rolling_std_response",
            "rolling_failure_rate",
            "day_of_week",
        ]

        return df, features

    def train_failure_predictor(self, df, features):
        """Train the failure prediction model"""
        print("🔄 Training failure prediction model...")

        X = df[features]
        y = df["failure"]

        # Handle class imbalance
        failure_count = y.sum()
        total_count = len(y)
        print(
            f"Training data: {total_count} samples, {failure_count} failures ({failure_count/total_count*100:.1f}%)"
        )

        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )

        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)

        # Train Random Forest
        self.failure_predictor = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            min_samples_split=10,
            min_samples_leaf=5,
            random_state=42,
            class_weight="balanced",
        )

        self.failure_predictor.fit(X_train_scaled, y_train)

        # Evaluate
        y_pred = self.failure_predictor.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)
        precision = precision_score(y_test, y_pred)
        recall = recall_score(y_test, y_pred)
        f1 = f1_score(y_test, y_pred)

        print(f"  Accuracy: {accuracy:.3f}")
        print(f"  Precision: {precision:.3f}")
        print(f"  Recall: {recall:.3f}")
        print(f"  F1-Score: {f1:.3f}")
        # Save model
        model_path = os.path.join(self.models_dir, "failure_predictor.pkl")
        joblib.dump(self.failure_predictor, model_path)
        joblib.dump(self.scaler, os.path.join(self.models_dir, "scaler.pkl"))

        return {
            "accuracy": accuracy,
            "precision": precision,
            "recall": recall,
            "f1": f1,
        }

    def train_anomaly_detector(self, df, features):
        """Train anomaly detection model"""
        print("🔄 Training anomaly detection model...")

        # Use only successful operations for anomaly detection
        normal_data = df[df["failure"] == 0][features]

        # Scale features
        scaler_anomaly = StandardScaler()
        normal_scaled = scaler_anomaly.fit_transform(normal_data)

        # Train Isolation Forest
        self.anomaly_detector = IsolationForest(
            n_estimators=100, contamination=0.05, random_state=42  # Expect 5% anomalies
        )

        self.anomaly_detector.fit(normal_scaled)

        # Save model
        joblib.dump(
            self.anomaly_detector, os.path.join(self.models_dir, "anomaly_detector.pkl")
        )
        joblib.dump(scaler_anomaly, os.path.join(self.models_dir, "anomaly_scaler.pkl"))

        print("✅ Anomaly detection model trained")

    def predict_failures(self, current_data):
        """Predict failure probabilities for current tool states"""
        if self.failure_predictor is None:
            self.load_models()

        predictions = {}

        for tool_data in current_data:
            tool = tool_data["tool"]

            # Create feature vector (simplified for current data)
            features = np.array(
                [
                    [
                        tool_data.get("response_time", 0),
                        tool_data.get("system_load", 0.5),
                        np.sin(2 * np.pi * datetime.now().hour / 24),  # hour_sin
                        np.cos(2 * np.pi * datetime.now().hour / 24),  # hour_cos
                        (
                            1 if datetime.now().hour in [2, 3, 4] else 0
                        ),  # maintenance_window
                        tool_data.get("rolling_mean", 0.1),  # rolling_mean_response
                        tool_data.get("rolling_std", 0.05),  # rolling_std_response
                        tool_data.get("failure_rate", 0.02),  # rolling_failure_rate
                        datetime.now().weekday(),  # day_of_week
                    ]
                ]
            )

            # Scale features
            features_scaled = self.scaler.transform(features)

            # Predict
            failure_prob = self.failure_predictor.predict_proba(features_scaled)[0][1]
            is_anomaly = self.check_anomaly(features_scaled)

            predictions[tool] = {
                "failure_probability": round(failure_prob, 3),
                "is_anomaly": bool(is_anomaly),
                "risk_level": self.get_risk_level(failure_prob),
                "recommendations": self.get_recommendations(
                    failure_prob, is_anomaly, tool
                ),
            }

        return predictions

    def check_anomaly(self, features_scaled):
        """Check if current features are anomalous"""
        if self.anomaly_detector is None:
            return False

        # Load anomaly detector if needed
        try:
            anomaly_detector = joblib.load(
                os.path.join(self.models_dir, "anomaly_detector.pkl")
            )
            anomaly_scaler = joblib.load(
                os.path.join(self.models_dir, "anomaly_scaler.pkl")
            )

            # Rescale for anomaly detector
            features_anomaly = anomaly_scaler.transform(features_scaled)
            anomaly_score = anomaly_detector.predict(features_anomaly)

            return anomaly_score[0] == -1  # -1 indicates anomaly
        except:
            return False

    def get_risk_level(self, failure_prob):
        """Convert failure probability to risk level"""
        if failure_prob > 0.7:
            return "CRITICAL"
        elif failure_prob > 0.4:
            return "HIGH"
        elif failure_prob > 0.2:
            return "MEDIUM"
        elif failure_prob > 0.1:
            return "LOW"
        else:
            return "NORMAL"

    def get_recommendations(self, failure_prob, is_anomaly, tool):
        """Generate remediation recommendations"""
        recommendations = []

        if failure_prob > 0.7:
            recommendations.append(f"URGENT: Immediate attention required for {tool}")
            recommendations.append("Consider restarting related services")
            recommendations.append("Check system resources and dependencies")
        elif failure_prob > 0.4:
            recommendations.append(f"Monitor {tool} closely - high failure risk")
            recommendations.append("Prepare backup solutions")
        elif failure_prob > 0.2:
            recommendations.append(f"Watch {tool} performance trends")
        elif is_anomaly:
            recommendations.append(f"Unusual behavior detected for {tool}")
            recommendations.append("Investigate recent changes or system updates")

        return recommendations

    def load_models(self):
        """Load trained models"""
        try:
            self.failure_predictor = joblib.load(
                os.path.join(self.models_dir, "failure_predictor.pkl")
            )
            self.scaler = joblib.load(os.path.join(self.models_dir, "scaler.pkl"))
            print("✅ Models loaded successfully")
        except FileNotFoundError:
            print("❌ No trained models found. Run training first.")
            return False
        return True

    def load_historical_data(self):
        """Load existing historical data"""
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
                                "system_load": 0.5,  # Default system load
                                "hour": datetime.fromisoformat(
                                    timestamp.replace("Z", "+00:00")
                                ).hour,
                                "day_of_week": datetime.fromisoformat(
                                    timestamp.replace("Z", "+00:00")
                                ).weekday(),
                                "is_maintenance_window": 0,
                            }
                        )
            except Exception as e:
                print(f"Warning: Could not load {file_path}: {e}")

        if all_data:
            df = pd.DataFrame(all_data)
            print(f"✅ Loaded {len(all_data)} historical data points")
            return df
        else:
            print("ℹ️ No historical data found, will use synthetic data")
            return None

    def generate_predictions_report(self, predictions):
        """Generate a comprehensive predictions report"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_tools": len(predictions),
                "critical_risks": len(
                    [p for p in predictions.values() if p["risk_level"] == "CRITICAL"]
                ),
                "high_risks": len(
                    [p for p in predictions.values() if p["risk_level"] == "HIGH"]
                ),
                "anomalies": len([p for p in predictions.values() if p["is_anomaly"]]),
            },
            "predictions": predictions,
        }

        # Save report
        report_file = os.path.join(
            self.logs_dir,
            f"predictions_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json",
        )
        with open(report_file, "w") as f:
            json.dump(report, f, indent=2)

        return report


def main():
    print("🚀 Predictive Maintenance System Starting...")

    system = PredictiveMaintenanceSystem()

    # Load existing historical data
    historical_data = system.load_historical_data()

    # Generate synthetic data if needed
    if historical_data is None or len(historical_data) < 1000:
        training_data = system.generate_synthetic_data(days=30)
    else:
        training_data = historical_data

    # Prepare features
    training_data, features = system.prepare_features(training_data)

    # Train models
    metrics = system.train_failure_predictor(training_data, features)
    system.train_anomaly_detector(training_data, features)

    print("\n📊 Model Performance:")
    for metric, value in metrics.items():
        print(f"  {metric.capitalize()}: {value:.3f}")
    # Load current dashboard data for predictions
    try:
        with open(system.dashboard_data_file, "r") as f:
            dashboard_data = json.load(f)

        # Extract current tool states
        current_states = []
        tools_details = dashboard_data.get("tools", {}).get("details", {})
        benchmark_results = dashboard_data.get("benchmark", {}).get("results", [])

        # Create a mapping of tool to benchmark data
        benchmark_map = {result["tool"]: result for result in benchmark_results}

        for tool_name, tool_info in tools_details.items():
            benchmark_data = benchmark_map.get(tool_name, {})

            current_states.append(
                {
                    "tool": tool_name,
                    "response_time": benchmark_data.get("response_time", 0.0),
                    "system_load": 0.5,  # Default system load
                    "rolling_mean": benchmark_data.get(
                        "response_time", 0.1
                    ),  # Use current as approximation
                    "rolling_std": 0.05,  # Default std
                    "failure_rate": (
                        0.02 if tool_info.get("status") == "healthy" else 0.1
                    ),  # Estimate failure rate
                }
            )

        # Generate predictions
        predictions = system.predict_failures(current_states)

        # Generate report
        report = system.generate_predictions_report(predictions)

        print("\n🔮 Failure Predictions:")
        for tool, pred in predictions.items():
            status = (
                "🚨"
                if pred["risk_level"] in ["CRITICAL", "HIGH"]
                else "⚠️" if pred["risk_level"] == "MEDIUM" else "✅"
            )
            anomaly = " (ANOMALY)" if pred["is_anomaly"] else ""
            print(
                f"  {status} {tool}: {pred['failure_probability']:.3f} risk ({pred['risk_level']}){anomaly}"
            )
        print(f"\n📄 Detailed report saved to predictions JSON file")

    except FileNotFoundError:
        print("❌ Dashboard data not found. Run tool monitoring first.")
    except Exception as e:
        print(f"❌ Error generating predictions: {e}")


if __name__ == "__main__":
    main()
