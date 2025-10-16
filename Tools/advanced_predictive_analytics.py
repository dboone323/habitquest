#!/usr/bin/env python3
"""
Advanced Predictive Analytics Engine
Implements comprehensive tool health forecasting with advanced ML models,
trend analysis, and proactive recommendations
"""

import json
import os
import sys
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.model_selection import TimeSeriesSplit
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.statespace.sarimax import SARIMAX
from statsmodels.tsa.holtwinters import ExponentialSmoothing
import joblib
import warnings

warnings.filterwarnings("ignore")


class AdvancedPredictiveAnalytics:
    def __init__(self, data_dir="/Users/danielstevens/Desktop/Quantum-workspace/Tools"):
        self.data_dir = data_dir
        self.metrics_dir = os.path.join(data_dir, "metrics")
        self.logs_dir = os.path.join(data_dir, "logs")
        self.models_dir = os.path.join(data_dir, "models")
        self.analytics_dir = os.path.join(data_dir, "analytics")
        self.dashboard_data_file = os.path.join(data_dir, "dashboard_data.json")

        # Create directories
        for dir_path in [self.analytics_dir]:
            os.makedirs(dir_path, exist_ok=True)

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

        # Advanced ML models
        self.health_scorer = None
        self.trend_forecaster = None
        self.performance_predictor = None
        self.time_series_models = {}
        self.scaler = StandardScaler()
        self.health_scaler = MinMaxScaler()

        # Analytics parameters
        self.forecast_horizon = 24  # hours
        self.health_score_weights = {
            "response_time": 0.3,
            "failure_rate": 0.4,
            "anomaly_score": 0.2,
            "trend_slope": 0.1,
        }

    def calculate_health_score(self, tool_data):
        """Calculate comprehensive health score for a tool"""
        try:
            # Extract metrics
            response_time = tool_data.get("response_time", 0)
            failure_rate = tool_data.get("failure_rate", 0)
            anomaly_score = tool_data.get("anomaly_score", 0)
            trend_slope = tool_data.get("trend_slope", 0)

            # Normalize metrics (lower is better for most)
            norm_response = min(response_time / 10.0, 1.0)  # Cap at 10 seconds
            norm_failure = failure_rate  # Already 0-1
            norm_anomaly = anomaly_score  # Already 0-1

            # Trend slope: negative is good (improving), positive is bad (degrading)
            norm_trend = max(
                0, min(1, (trend_slope + 0.1) / 0.2)
            )  # Normalize -0.1 to 0.1 range

            # Calculate weighted health score (0-1, higher is better)
            health_score = (
                self.health_score_weights["response_time"] * (1 - norm_response)
                + self.health_score_weights["failure_rate"] * (1 - norm_failure)
                + self.health_score_weights["anomaly_score"] * (1 - norm_anomaly)
                + self.health_score_weights["trend_slope"] * (1 - norm_trend)
            )

            return round(health_score, 3)

        except Exception as e:
            print(f"Error calculating health score: {e}")
            return 0.5  # Default neutral score

    def get_health_status(self, health_score):
        """Convert health score to status category"""
        if health_score >= 0.8:
            return "EXCELLENT"
        elif health_score >= 0.6:
            return "GOOD"
        elif health_score >= 0.4:
            return "FAIR"
        elif health_score >= 0.2:
            return "POOR"
        else:
            return "CRITICAL"

    def train_advanced_models(self, historical_data):
        """Train advanced ML models for health scoring and forecasting"""
        print("🔄 Training advanced predictive analytics models...")

        # Prepare comprehensive feature set
        features_df = self.prepare_advanced_features(historical_data)

        if len(features_df) < 100:
            print("❌ Insufficient data for advanced training")
            return False

        # Train health scorer
        self.train_health_scorer(features_df)

        # Train performance predictor
        self.train_performance_predictor(features_df)

        # Train time series models for each tool
        self.train_time_series_models(features_df)

        print("✅ Advanced models trained successfully")
        return True

    def prepare_advanced_features(self, df):
        """Prepare comprehensive features for advanced analytics"""
        df = df.copy()
        df["timestamp"] = pd.to_datetime(df["timestamp"])
        df = df.sort_values(["tool", "timestamp"])

        # Basic features
        df["failure"] = (df["status"] == "failed").astype(int)

        # Time-based features
        df["hour"] = df["timestamp"].dt.hour
        df["day_of_week"] = df["timestamp"].dt.dayofweek
        df["month"] = df["timestamp"].dt.month
        df["hour_sin"] = np.sin(2 * np.pi * df["hour"] / 24)
        df["hour_cos"] = np.cos(2 * np.pi * df["hour"] / 24)

        # Rolling statistics with multiple windows
        for window in [6, 12, 24, 48]:  # hours
            df[f"rolling_mean_response_{window}h"] = (
                df.groupby("tool")["response_time"]
                .rolling(window=window, min_periods=1)
                .mean()
                .reset_index(0, drop=True)
            )
            df[f"rolling_std_response_{window}h"] = (
                df.groupby("tool")["response_time"]
                .rolling(window=window, min_periods=1)
                .std()
                .reset_index(0, drop=True)
            )
            df[f"rolling_failure_rate_{window}h"] = (
                df.groupby("tool")["failure"]
                .rolling(window=window, min_periods=1)
                .mean()
                .reset_index(0, drop=True)
            )

        # Trend features
        df["response_time_trend"] = (
            df.groupby("tool")["response_time"]
            .rolling(window=12, min_periods=6)
            .apply(lambda x: np.polyfit(range(len(x)), x, 1)[0] if len(x) >= 6 else 0)
            .reset_index(0, drop=True)
        )

        # Fill NaN values
        df = df.fillna(method="bfill").fillna(method="ffill").fillna(0)

        return df

    def train_health_scorer(self, df):
        """Train ML model for comprehensive health scoring"""
        print("  Training health scorer...")

        # Create target health score
        df["target_health"] = df.apply(
            lambda row: self.calculate_health_score(
                {
                    "response_time": row["response_time"],
                    "failure_rate": row["rolling_failure_rate_24h"],
                    "anomaly_score": 0.1 if row["failure"] == 1 else 0.0,
                    "trend_slope": row["response_time_trend"],
                }
            ),
            axis=1,
        )

        # Features for health scoring
        health_features = [
            "response_time",
            "rolling_mean_response_24h",
            "rolling_std_response_24h",
            "rolling_failure_rate_24h",
            "response_time_trend",
            "hour_sin",
            "hour_cos",
            "day_of_week",
            "system_load",
        ]

        X = df[health_features]
        y = df["target_health"]

        # Scale features
        X_scaled = self.health_scaler.fit_transform(X)

        # Train Gradient Boosting for health scoring
        self.health_scorer = GradientBoostingRegressor(
            n_estimators=200, max_depth=6, learning_rate=0.1, random_state=42
        )

        self.health_scorer.fit(X_scaled, y)

        # Save model
        joblib.dump(
            self.health_scorer, os.path.join(self.models_dir, "health_scorer.pkl")
        )
        joblib.dump(
            self.health_scaler, os.path.join(self.models_dir, "health_scaler.pkl")
        )

    def train_performance_predictor(self, df):
        """Train model for performance trend prediction"""
        print("  Training performance predictor...")

        # Use response time as target for next hour prediction
        df["next_hour_response"] = df.groupby("tool")["response_time"].shift(-1)

        # Features for prediction
        perf_features = [
            "response_time",
            "rolling_mean_response_12h",
            "rolling_std_response_12h",
            "rolling_failure_rate_12h",
            "response_time_trend",
            "hour_sin",
            "hour_cos",
            "day_of_week",
            "system_load",
        ]

        # Remove rows with NaN target
        valid_data = df.dropna(subset=["next_hour_response"])

        X = valid_data[perf_features]
        y = valid_data["next_hour_response"]

        # Scale features
        X_scaled = self.scaler.fit_transform(X)

        # Train Random Forest for performance prediction
        self.performance_predictor = RandomForestRegressor(
            n_estimators=100, max_depth=8, random_state=42
        )

        self.performance_predictor.fit(X_scaled, y)

        # Save model
        joblib.dump(
            self.performance_predictor,
            os.path.join(self.models_dir, "performance_predictor.pkl"),
        )

    def train_time_series_models(self, df):
        """Train time series models for each tool"""
        print("  Training time series models...")

        for tool in self.tools:
            tool_data = df[df["tool"] == tool].copy()
            if len(tool_data) < 24:  # Need at least 24 hours of data
                continue

            try:
                # Prepare time series data
                ts_data = (
                    tool_data.set_index("timestamp")["response_time"]
                    .resample("H")
                    .mean()
                    .fillna(method="ffill")
                )

                if len(ts_data) < 24:
                    continue

                # Train ARIMA model
                arima_model = ARIMA(ts_data, order=(1, 1, 1))
                arima_fit = arima_model.fit()

                # Train Exponential Smoothing
                try:
                    ets_model = ExponentialSmoothing(
                        ts_data, seasonal_periods=24, trend="add", seasonal="add"
                    )
                    ets_fit = ets_model.fit()
                except:
                    # Fallback to simple exponential smoothing
                    ets_model = ExponentialSmoothing(ts_data, trend="add")
                    ets_fit = ets_model.fit()

                self.time_series_models[tool] = {
                    "arima": arima_fit,
                    "ets": ets_fit,
                    "last_values": ts_data.tail(24).values,
                }

            except Exception as e:
                print(f"    Warning: Could not train time series model for {tool}: {e}")
                continue

        # Save time series models
        joblib.dump(
            self.time_series_models,
            os.path.join(self.models_dir, "time_series_models.pkl"),
        )

    def generate_advanced_predictions(self, current_data):
        """Generate comprehensive predictions using advanced analytics"""
        predictions = {}

        # Load models if needed
        self.load_advanced_models()

        for tool_data in current_data:
            tool = tool_data["tool"]

            try:
                # Calculate current health score
                health_score = self.predict_health_score(tool_data)
                health_status = self.get_health_status(health_score)

                # Generate performance forecast
                performance_forecast = self.forecast_performance(tool, tool_data)

                # Generate time series forecast
                time_series_forecast = self.forecast_time_series(tool)

                # Generate proactive recommendations
                recommendations = self.generate_proactive_recommendations(
                    tool, health_score, performance_forecast, time_series_forecast
                )

                # Calculate risk metrics
                risk_metrics = self.calculate_risk_metrics(
                    tool, health_score, performance_forecast, time_series_forecast
                )

                predictions[tool] = {
                    "health_score": health_score,
                    "health_status": health_status,
                    "performance_forecast": performance_forecast,
                    "time_series_forecast": time_series_forecast,
                    "recommendations": recommendations,
                    "risk_metrics": risk_metrics,
                    "timestamp": datetime.now().isoformat(),
                }

            except Exception as e:
                print(f"Error generating predictions for {tool}: {e}")
                predictions[tool] = self.get_fallback_prediction(tool)

        return predictions

    def predict_health_score(self, tool_data):
        """Predict comprehensive health score using ML model"""
        if self.health_scorer is None:
            return self.calculate_health_score(tool_data)

        try:
            # Prepare features
            features = np.array(
                [
                    [
                        tool_data.get("response_time", 0),
                        tool_data.get(
                            "rolling_mean_response_24h",
                            tool_data.get("response_time", 0),
                        ),
                        tool_data.get("rolling_std_response_24h", 0.1),
                        tool_data.get("rolling_failure_rate_24h", 0.02),
                        tool_data.get("response_time_trend", 0),
                        np.sin(2 * np.pi * datetime.now().hour / 24),
                        np.cos(2 * np.pi * datetime.now().hour / 24),
                        datetime.now().weekday(),
                        tool_data.get("system_load", 0.5),
                    ]
                ]
            )

            # Scale and predict
            features_scaled = self.health_scaler.transform(features)
            predicted_health = self.health_scorer.predict(features_scaled)[0]

            return round(max(0, min(1, predicted_health)), 3)

        except Exception as e:
            print(f"Error in health score prediction: {e}")
            return self.calculate_health_score(tool_data)

    def forecast_performance(self, tool, tool_data):
        """Forecast performance for next hours"""
        if self.performance_predictor is None:
            return {"forecast": [], "confidence": 0.5}

        try:
            # Prepare features for forecasting
            base_features = np.array(
                [
                    [
                        tool_data.get("response_time", 0),
                        tool_data.get(
                            "rolling_mean_response_12h",
                            tool_data.get("response_time", 0),
                        ),
                        tool_data.get("rolling_std_response_12h", 0.1),
                        tool_data.get("rolling_failure_rate_12h", 0.02),
                        tool_data.get("response_time_trend", 0),
                        np.sin(2 * np.pi * datetime.now().hour / 24),
                        np.cos(2 * np.pi * datetime.now().hour / 24),
                        datetime.now().weekday(),
                        tool_data.get("system_load", 0.5),
                    ]
                ]
            )

            # Generate forecast for next 6 hours
            forecast_values = []
            current_features = base_features.copy()

            for hour in range(6):
                # Scale and predict
                features_scaled = self.scaler.transform(current_features)
                predicted_response = self.performance_predictor.predict(
                    features_scaled
                )[0]

                forecast_values.append(round(predicted_response, 3))

                # Update features for next prediction (simplified)
                current_features[0][0] = predicted_response  # Update response time
                current_features[0][5] = np.sin(
                    2 * np.pi * (datetime.now().hour + hour + 1) / 24
                )  # Next hour
                current_features[0][6] = np.cos(
                    2 * np.pi * (datetime.now().hour + hour + 1) / 24
                )

            return {
                "forecast": forecast_values,
                "confidence": 0.75,  # Estimated confidence
                "horizon_hours": 6,
            }

        except Exception as e:
            print(f"Error in performance forecasting: {e}")
            return {"forecast": [], "confidence": 0.5}

    def forecast_time_series(self, tool):
        """Generate time series forecast using trained models"""
        if tool not in self.time_series_models:
            return {"forecast": [], "method": "unavailable"}

        try:
            models = self.time_series_models[tool]

            # Generate forecasts using different methods
            forecasts = {}

            # ARIMA forecast
            try:
                arima_forecast = models["arima"].forecast(steps=self.forecast_horizon)
                forecasts["arima"] = arima_forecast.tolist()
            except:
                forecasts["arima"] = []

            # Exponential Smoothing forecast
            try:
                ets_forecast = models["ets"].forecast(steps=self.forecast_horizon)
                forecasts["ets"] = ets_forecast.tolist()
            except:
                forecasts["ets"] = []

            # Ensemble forecast (average of available methods)
            available_forecasts = [
                f for f in [forecasts.get("arima"), forecasts.get("ets")] if f
            ]
            if available_forecasts:
                ensemble_forecast = np.mean(available_forecasts, axis=0).tolist()
            else:
                ensemble_forecast = []

            return {
                "forecast": [
                    round(x, 3) for x in ensemble_forecast[:6]
                ],  # Next 6 hours
                "method": "ensemble",
                "confidence": 0.7,
                "horizon_hours": 6,
            }

        except Exception as e:
            print(f"Error in time series forecasting for {tool}: {e}")
            return {"forecast": [], "method": "error"}

    def generate_proactive_recommendations(
        self, tool, health_score, perf_forecast, ts_forecast
    ):
        """Generate proactive recommendations based on predictions"""
        recommendations = []

        # Health-based recommendations
        if health_score < 0.3:
            recommendations.append(
                f"CRITICAL: Immediate intervention required for {tool}"
            )
            recommendations.append(
                "Consider restarting related services and checking dependencies"
            )
            recommendations.append("Monitor system resources and network connectivity")
        elif health_score < 0.5:
            recommendations.append(
                f"URGENT: {tool} health deteriorating - schedule maintenance"
            )
            recommendations.append("Review recent configuration changes")
        elif health_score < 0.7:
            recommendations.append(f"Monitor {tool} performance trends closely")

        # Performance forecast recommendations
        if perf_forecast.get("forecast"):
            avg_forecast = np.mean(perf_forecast["forecast"])
            current_response = (
                perf_forecast["forecast"][0] if perf_forecast["forecast"] else 0
            )

            if avg_forecast > current_response * 1.5:
                recommendations.append(
                    f"Performance degradation predicted for {tool} - prepare mitigation"
                )
            elif avg_forecast < current_response * 0.7:
                recommendations.append(f"Performance improvement expected for {tool}")

        # Time series forecast recommendations
        if ts_forecast.get("forecast"):
            ts_avg = np.mean(ts_forecast["forecast"])
            ts_trend = np.polyfit(
                range(len(ts_forecast["forecast"])), ts_forecast["forecast"], 1
            )[0]

            if ts_trend > 0.1:  # Degrading trend
                recommendations.append(
                    f"Long-term performance decline detected for {tool}"
                )
            elif ts_trend < -0.1:  # Improving trend
                recommendations.append(
                    f"Performance improving for {tool} - continue monitoring"
                )

        # Tool-specific recommendations
        tool_specific = self.get_tool_specific_recommendations(tool, health_score)
        recommendations.extend(tool_specific)

        return recommendations[:5]  # Limit to top 5 recommendations

    def get_tool_specific_recommendations(self, tool, health_score):
        """Get tool-specific recommendations"""
        recommendations = []

        tool_recommendations = {
            "swiftlint": [
                "Check SwiftLint configuration file",
                "Verify Swift version compatibility",
                "Review custom rules that may be causing issues",
            ],
            "swiftformat": [
                "Validate SwiftFormat configuration",
                "Check for conflicting formatting rules",
                "Consider updating to latest SwiftFormat version",
            ],
            "xcodebuild": [
                "Clear Xcode derived data",
                "Check available disk space",
                "Verify Xcode command line tools installation",
            ],
            "node": [
                "Check Node.js version compatibility",
                "Clear npm cache if needed",
                "Verify package.json dependencies",
            ],
            "npm": [
                "Clear npm cache",
                "Check network connectivity",
                "Verify npm registry access",
            ],
            "brew": [
                "Run 'brew update' to refresh formulae",
                "Check Homebrew installation integrity",
                "Verify macOS compatibility",
            ],
        }

        if tool in tool_recommendations and health_score < 0.7:
            recommendations.extend(
                tool_recommendations[tool][:2]
            )  # Add 1-2 specific recommendations

        return recommendations

    def calculate_risk_metrics(self, tool, health_score, perf_forecast, ts_forecast):
        """Calculate comprehensive risk metrics"""
        risk_score = 1 - health_score  # Invert health score

        # Performance risk
        perf_risk = 0
        if perf_forecast.get("forecast"):
            current = perf_forecast["forecast"][0]
            max_future = max(perf_forecast["forecast"])
            perf_risk = min(1, (max_future - current) / max(current, 0.1))

        # Trend risk
        trend_risk = 0
        if ts_forecast.get("forecast") and len(ts_forecast["forecast"]) > 1:
            trend_slope = np.polyfit(
                range(len(ts_forecast["forecast"])), ts_forecast["forecast"], 1
            )[0]
            trend_risk = max(0, min(1, trend_slope / 0.5))  # Normalize trend slope

        # Overall risk assessment
        overall_risk = risk_score * 0.5 + perf_risk * 0.3 + trend_risk * 0.2

        risk_level = "LOW"
        if overall_risk > 0.7:
            risk_level = "CRITICAL"
        elif overall_risk > 0.5:
            risk_level = "HIGH"
        elif overall_risk > 0.3:
            risk_level = "MEDIUM"

        return {
            "overall_risk": round(overall_risk, 3),
            "risk_level": risk_level,
            "health_risk": round(risk_score, 3),
            "performance_risk": round(perf_risk, 3),
            "trend_risk": round(trend_risk, 3),
        }

    def get_fallback_prediction(self, tool):
        """Provide fallback prediction when advanced models fail"""
        return {
            "health_score": 0.5,
            "health_status": "UNKNOWN",
            "performance_forecast": {"forecast": [], "confidence": 0.0},
            "time_series_forecast": {"forecast": [], "method": "unavailable"},
            "recommendations": [f"Unable to generate advanced predictions for {tool}"],
            "risk_metrics": {
                "overall_risk": 0.5,
                "risk_level": "UNKNOWN",
                "health_risk": 0.5,
                "performance_risk": 0.0,
                "trend_risk": 0.0,
            },
            "timestamp": datetime.now().isoformat(),
        }

    def load_advanced_models(self):
        """Load trained advanced models"""
        try:
            self.health_scorer = joblib.load(
                os.path.join(self.models_dir, "health_scorer.pkl")
            )
            self.health_scaler = joblib.load(
                os.path.join(self.models_dir, "health_scaler.pkl")
            )
            self.performance_predictor = joblib.load(
                os.path.join(self.models_dir, "performance_predictor.pkl")
            )
            self.time_series_models = joblib.load(
                os.path.join(self.models_dir, "time_series_models.pkl")
            )
            return True
        except FileNotFoundError:
            print("Advanced models not found, using fallback methods")
            return False
        except Exception as e:
            print(f"Error loading advanced models: {e}")
            return False

    def generate_analytics_report(self, predictions):
        """Generate comprehensive analytics report"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_tools": len(predictions),
                "excellent_health": len(
                    [
                        p
                        for p in predictions.values()
                        if p["health_status"] == "EXCELLENT"
                    ]
                ),
                "good_health": len(
                    [p for p in predictions.values() if p["health_status"] == "GOOD"]
                ),
                "fair_health": len(
                    [p for p in predictions.values() if p["health_status"] == "FAIR"]
                ),
                "poor_health": len(
                    [p for p in predictions.values() if p["health_status"] == "POOR"]
                ),
                "critical_health": len(
                    [
                        p
                        for p in predictions.values()
                        if p["health_status"] == "CRITICAL"
                    ]
                ),
                "high_risk": len(
                    [
                        p
                        for p in predictions.values()
                        if p["risk_metrics"]["risk_level"] == "HIGH"
                    ]
                ),
                "critical_risk": len(
                    [
                        p
                        for p in predictions.values()
                        if p["risk_metrics"]["risk_level"] == "CRITICAL"
                    ]
                ),
            },
            "predictions": predictions,
            "insights": self.generate_insights(predictions),
        }

        # Save report
        report_file = os.path.join(
            self.analytics_dir,
            f"advanced_analytics_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json",
        )
        with open(report_file, "w") as f:
            json.dump(report, f, indent=2)

        return report

    def generate_insights(self, predictions):
        """Generate actionable insights from predictions"""
        insights = []

        # Overall system health
        avg_health = np.mean([p["health_score"] for p in predictions.values()])
        if avg_health < 0.5:
            insights.append(
                "Overall system health is concerning - prioritize maintenance"
            )
        elif avg_health > 0.8:
            insights.append("System health is excellent - maintain current practices")

        # Risk analysis
        high_risk_tools = [
            tool
            for tool, pred in predictions.items()
            if pred["risk_metrics"]["risk_level"] in ["HIGH", "CRITICAL"]
        ]

        if high_risk_tools:
            insights.append(
                f"High-risk tools requiring attention: {', '.join(high_risk_tools)}"
            )

        # Performance trends
        degrading_tools = []
        improving_tools = []

        for tool, pred in predictions.items():
            if pred.get("time_series_forecast", {}).get("forecast"):
                forecast = pred["time_series_forecast"]["forecast"]
                if len(forecast) > 1:
                    trend = np.polyfit(range(len(forecast)), forecast, 1)[0]
                    if trend > 0.05:
                        degrading_tools.append(tool)
                    elif trend < -0.05:
                        improving_tools.append(tool)

        if degrading_tools:
            insights.append(f"Performance degrading: {', '.join(degrading_tools)}")
        if improving_tools:
            insights.append(f"Performance improving: {', '.join(improving_tools)}")

        return insights

    def update_dashboard_data(self, predictions):
        """Update dashboard with advanced analytics"""
        try:
            with open(self.dashboard_data_file, "r") as f:
                dashboard_data = json.load(f)

            # Add advanced analytics section
            dashboard_data["advanced_analytics"] = {
                "predictions": predictions,
                "last_updated": datetime.now().isoformat(),
                "model_version": "1.0",
            }

            with open(self.dashboard_data_file, "w") as f:
                json.dump(dashboard_data, f, indent=2)

            print("✅ Dashboard updated with advanced analytics")

        except Exception as e:
            print(f"Error updating dashboard: {e}")

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

    def generate_synthetic_data(self, days=14):
        """Generate synthetic historical data for training"""
        print("🔄 Generating synthetic training data...")

        data = []
        base_time = datetime.now() - timedelta(days=days)

        for day in range(days):
            for hour in range(24):
                timestamp = base_time + timedelta(days=day, hours=hour)

                for tool in self.tools:
                    # Simulate realistic tool behavior with more variation
                    base_response = np.random.exponential(0.05)  # Faster baseline

                    # Add tool-specific characteristics
                    if tool in ["swiftlint", "swiftformat"]:
                        base_response += np.random.uniform(0.1, 0.5)  # Slower tools
                    elif tool in ["git", "python3"]:
                        base_response += np.random.uniform(0.01, 0.1)  # Faster tools

                    response_time = base_response

                    # Introduce occasional failures and performance degradation
                    failure_prob = 0.01  # Lower base failure rate
                    if np.random.random() < failure_prob:
                        status = "failed"
                        response_time = np.random.uniform(2, 15)  # Slow when failing
                    else:
                        status = "success"

                    # Tool-specific failure patterns
                    if tool in ["swiftlint", "swiftformat", "xcodebuild"]:
                        if (
                            np.random.random() < 0.03
                        ):  # Higher failure rate for complex tools
                            status = "failed"
                            response_time = np.random.uniform(5, 30)

                    # Periodic maintenance windows
                    if timestamp.hour in [2, 3, 4]:  # Maintenance window
                        if np.random.random() < 0.05:
                            status = "failed"
                            response_time = np.random.uniform(10, 60)

                    # System load impact
                    system_load = np.random.uniform(0.1, 0.9)
                    if system_load > 0.8 and np.random.random() < 0.2:
                        response_time *= 1.5
                        if np.random.random() < 0.05:
                            status = "failed"

                    # Add some trend variation
                    day_factor = 1 + 0.1 * np.sin(2 * np.pi * day / 7)  # Weekly pattern
                    response_time *= day_factor

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
            os.path.join(self.metrics_dir, "synthetic_training_data_advanced.csv"),
            index=False,
        )
        print(f"✅ Generated {len(data)} synthetic data points")
        return df

    def load_current_tool_states(self):
        """Load current tool states from dashboard data"""
        try:
            with open(self.dashboard_data_file, "r") as f:
                dashboard_data = json.load(f)

            current_states = []
            tools_details = dashboard_data.get("tools", {}).get("details", {})
            benchmark_results = dashboard_data.get("benchmark", {}).get("results", [])

            benchmark_map = {result["tool"]: result for result in benchmark_results}

            for tool_name, tool_info in tools_details.items():
                benchmark_data = benchmark_map.get(tool_name, {})

                # Calculate rolling statistics from available data
                response_time = benchmark_data.get("response_time", 0.1)
                failure_rate = 0.02 if tool_info.get("status") == "healthy" else 0.1

                current_states.append(
                    {
                        "tool": tool_name,
                        "response_time": response_time,
                        "system_load": 0.5,
                        "rolling_mean_response_24h": response_time,
                        "rolling_std_response_24h": response_time * 0.2,
                        "rolling_failure_rate_24h": failure_rate,
                        "rolling_mean_response_12h": response_time,
                        "rolling_std_response_12h": response_time * 0.15,
                        "rolling_failure_rate_12h": failure_rate,
                        "response_time_trend": 0.0,  # Neutral trend
                    }
                )

            return current_states

        except FileNotFoundError:
            print("❌ Dashboard data not found")
            return []
        except Exception as e:
            print(f"❌ Error loading current states: {e}")
            return []


def main():
    print("🚀 Advanced Predictive Analytics Engine Starting...")

    engine = AdvancedPredictiveAnalytics()

    # Load historical data
    historical_data = engine.load_historical_data()

    if historical_data is None or len(historical_data) < 100:
        print("Generating synthetic data for training...")
        historical_data = engine.generate_synthetic_data(days=14)

    # Train advanced models
    if engine.train_advanced_models(historical_data):
        print("✅ Advanced models trained successfully")
    else:
        print("❌ Advanced model training failed, using basic methods")

    # Load current tool states
    current_states = engine.load_current_tool_states()

    if not current_states:
        print("❌ No current tool states available")
        return

    # Generate advanced predictions
    predictions = engine.generate_advanced_predictions(current_states)

    # Generate analytics report
    report = engine.generate_analytics_report(predictions)

    # Update dashboard
    engine.update_dashboard_data(predictions)

    # Display results
    print("\n🔮 Advanced Predictive Analytics Results:")
    print(f"Total tools analyzed: {len(predictions)}")

    for tool, pred in predictions.items():
        status_emoji = {
            "EXCELLENT": "🟢",
            "GOOD": "🟡",
            "FAIR": "🟠",
            "POOR": "🔴",
            "CRITICAL": "🚨",
            "UNKNOWN": "❓",
        }.get(pred["health_status"], "❓")

        risk_emoji = {
            "CRITICAL": "🚨",
            "HIGH": "🔴",
            "MEDIUM": "🟠",
            "LOW": "🟡",
            "UNKNOWN": "❓",
        }.get(pred["risk_metrics"]["risk_level"], "❓")

        print(
            f"  {status_emoji}{risk_emoji} {tool}: Health {pred['health_score']:.2f} ({pred['health_status']}) | Risk: {pred['risk_metrics']['risk_level']}"
        )

        if pred["recommendations"]:
            print(f"    💡 {pred['recommendations'][0]}")

    print(f"\n📄 Detailed analytics report saved to {engine.analytics_dir}")
    print("✅ Advanced predictive analytics complete!")


if __name__ == "__main__":
    main()
