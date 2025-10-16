#!/usr/bin/env python3
"""
Enhanced Alerting System with Email/Slack Integration
Sends notifications for critical tool failures and system issues
"""

import json
import os
import smtplib
import requests
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta
import subprocess
import sys


class EnhancedAlertingSystem:
    def __init__(self, data_dir="/Users/danielstevens/Desktop/Quantum-workspace/Tools"):
        self.data_dir = data_dir
        self.logs_dir = os.path.join(data_dir, "logs")
        self.config_file = os.path.join(data_dir, "alert_config.json")

        # Default configuration
        self.config = {
            "email": {
                "enabled": False,
                "smtp_server": "smtp.gmail.com",
                "smtp_port": 587,
                "username": "",
                "password": "",
                "from_email": "",
                "to_emails": [],
            },
            "slack": {
                "enabled": False,
                "webhook_url": "",
                "channel": "#alerts",
                "username": "Tool Monitor",
            },
            "alert_levels": {
                "CRITICAL": ["email", "slack"],
                "HIGH": ["email", "slack"],
                "MEDIUM": ["slack"],
                "LOW": ["slack"],
            },
            "throttling": {"max_alerts_per_hour": 10, "cooldown_minutes": 5},
            "escalation": {
                "enabled": True,
                "policies": {
                    "frequency_escalation": {
                        "enabled": True,
                        "thresholds": {
                            3: "HIGH",  # After 3 occurrences, escalate to HIGH
                            5: "CRITICAL",  # After 5 occurrences, escalate to CRITICAL
                        },
                        "time_window_minutes": 60,  # Within 1 hour
                    },
                    "duration_escalation": {
                        "enabled": True,
                        "thresholds": {
                            30: "HIGH",  # If issue persists >30 minutes, escalate to HIGH
                            120: "CRITICAL",  # If issue persists >2 hours, escalate to CRITICAL
                        },
                    },
                    "persistent_escalation": {
                        "enabled": True,
                        "check_interval_minutes": 15,
                        "max_checks": 4,
                        "escalate_to": "CRITICAL",
                    },
                },
                "escalated_channels": {
                    "CRITICAL": ["email", "slack"],
                    "HIGH": ["email", "slack"],
                    "MEDIUM": ["slack"],
                    "LOW": ["slack"],
                },
            },
            "correlation": {
                "enabled": True,
                "rules": {
                    "time_window_minutes": 10,  # Group alerts within 10 minutes
                    "similarity_threshold": 0.7,  # Similarity score for grouping
                    "max_group_size": 5,  # Maximum alerts per correlation group
                    "correlation_patterns": {
                        "disk_issues": {
                            "keywords": ["disk", "space", "storage", "filesystem"],
                            "sources": ["system_monitor", "tool_monitor"],
                            "group_title": "Storage System Issues",
                            "group_level": "HIGH",
                        },
                        "memory_issues": {
                            "keywords": ["memory", "ram", "swap", "out of memory"],
                            "sources": ["system_monitor", "tool_monitor"],
                            "group_title": "Memory Resource Issues",
                            "group_level": "HIGH",
                        },
                        "network_issues": {
                            "keywords": ["network", "connection", "timeout", "dns"],
                            "sources": ["system_monitor", "tool_monitor"],
                            "group_title": "Network Connectivity Issues",
                            "group_level": "MEDIUM",
                        },
                        "tool_failures": {
                            "keywords": ["unhealthy", "failed", "error", "crash"],
                            "sources": ["tool_monitor", "predictive_monitor"],
                            "group_title": "Tool Health Issues",
                            "group_level": "HIGH",
                        },
                    },
                },
            },
            "custom_thresholds": {
                "enabled": True,
                "environments": {
                    "development": {
                        "disk_usage_percent": 90,
                        "memory_usage_percent": 85,
                        "cpu_usage_percent": 80,
                        "network_latency_ms": 500,
                        "tool_health_score": 0.7,
                    },
                    "staging": {
                        "disk_usage_percent": 85,
                        "memory_usage_percent": 80,
                        "cpu_usage_percent": 75,
                        "network_latency_ms": 300,
                        "tool_health_score": 0.8,
                    },
                    "production": {
                        "disk_usage_percent": 80,
                        "memory_usage_percent": 75,
                        "cpu_usage_percent": 70,
                        "network_latency_ms": 200,
                        "tool_health_score": 0.9,
                    },
                },
                "tools": {
                    "default": {
                        "response_time_ms": 1000,
                        "error_rate_percent": 5,
                        "uptime_percent": 99.5,
                        "memory_mb": 500,
                        "cpu_percent": 50,
                    },
                    "CodingReviewer": {
                        "response_time_ms": 2000,
                        "error_rate_percent": 2,
                        "uptime_percent": 99.9,
                        "memory_mb": 1000,
                        "cpu_percent": 60,
                    },
                    "PlannerApp": {
                        "response_time_ms": 1500,
                        "error_rate_percent": 3,
                        "uptime_percent": 99.7,
                        "memory_mb": 800,
                        "cpu_percent": 55,
                    },
                    "AvoidObstaclesGame": {
                        "response_time_ms": 100,
                        "error_rate_percent": 1,
                        "uptime_percent": 99.8,
                        "memory_mb": 200,
                        "cpu_percent": 40,
                    },
                },
                "current_environment": "development",
            },
        }

        self.load_config()
        self.alert_history = self.load_alert_history()

    def load_config(self):
        """Load alerting configuration"""
        try:
            if os.path.exists(self.config_file):
                with open(self.config_file, "r") as f:
                    loaded_config = json.load(f)
                    # Merge with defaults
                    self._merge_config(self.config, loaded_config)
                print("✅ Alert configuration loaded")
            else:
                print("ℹ️  No alert configuration found, using defaults")
                print("   Run setup_alerting() to configure notifications")
        except Exception as e:
            print(f"❌ Error loading alert config: {e}")

    def _merge_config(self, base, update):
        """Recursively merge configuration dictionaries"""
        for key, value in update.items():
            if key in base and isinstance(base[key], dict) and isinstance(value, dict):
                self._merge_config(base[key], value)
            else:
                base[key] = value

    def setup_alerting(self):
        """Interactive setup for alerting configuration"""
        print("🔧 Enhanced Alerting System Setup")
        print("=" * 40)

        # Email setup
        print("\n📧 Email Configuration:")
        enable_email = (
            input("Enable email notifications? (y/n): ").lower().startswith("y")
        )

        if enable_email:
            self.config["email"]["enabled"] = True
            self.config["email"]["smtp_server"] = (
                input("SMTP server (default: smtp.gmail.com): ") or "smtp.gmail.com"
            )
            self.config["email"]["smtp_port"] = int(
                input("SMTP port (default: 587): ") or "587"
            )
            self.config["email"]["username"] = input("Email username: ")
            self.config["email"]["password"] = input("Email password/app password: ")
            self.config["email"]["from_email"] = input("From email address: ")

            to_emails = input("To email addresses (comma-separated): ")
            self.config["email"]["to_emails"] = [
                email.strip() for email in to_emails.split(",") if email.strip()
            ]

        # Slack setup
        print("\n💬 Slack Configuration:")
        enable_slack = (
            input("Enable Slack notifications? (y/n): ").lower().startswith("y")
        )

        if enable_slack:
            self.config["slack"]["enabled"] = True
            self.config["slack"]["webhook_url"] = input("Slack webhook URL: ")
            self.config["slack"]["channel"] = (
                input("Slack channel (default: #alerts): ") or "#alerts"
            )
            self.config["slack"]["username"] = (
                input("Slack username (default: Tool Monitor): ") or "Tool Monitor"
            )

        # Save configuration
        self.save_config()
        print("\n✅ Alerting configuration saved!")

        # Test configuration
        if input("Test configuration? (y/n): ").lower().startswith("y"):
            self.test_configuration()

    def save_config(self):
        """Save alerting configuration"""
        try:
            with open(self.config_file, "w") as f:
                json.dump(self.config, f, indent=2)
            print("✅ Configuration saved")
        except Exception as e:
            print(f"❌ Error saving configuration: {e}")

    def test_configuration(self):
        """Test alerting configuration"""
        print("\n🧪 Testing Alert Configuration...")

        test_alert = {
            "level": "LOW",
            "title": "Test Alert",
            "message": "This is a test alert to verify your notification setup.",
            "timestamp": datetime.now().isoformat(),
            "source": "test",
        }

        success_count = 0

        # Test email
        if self.config["email"]["enabled"]:
            print("Testing email...")
            if self.send_email_alert(test_alert):
                print("✅ Email test successful")
                success_count += 1
            else:
                print("❌ Email test failed")

        # Test Slack
        if self.config["slack"]["enabled"]:
            print("Testing Slack...")
            if self.send_slack_alert(test_alert):
                print("✅ Slack test successful")
                success_count += 1
            else:
                print("❌ Slack test failed")

        if success_count > 0:
            print(f"\n✅ {success_count} notification method(s) working correctly")
        else:
            print("\n❌ No notification methods are working")

    def should_send_alert(self, alert):
        """Check if alert should be sent based on throttling rules"""
        now = datetime.now()

        # Clean old alerts from history (keep last 24 hours)
        cutoff = now - timedelta(hours=24)
        self.alert_history = [
            h
            for h in self.alert_history
            if datetime.fromisoformat(h["timestamp"]) > cutoff
        ]

        # Check alerts per hour limit
        recent_alerts = [
            h
            for h in self.alert_history
            if (now - datetime.fromisoformat(h["timestamp"])).total_seconds() < 3600
        ]

        if len(recent_alerts) >= self.config["throttling"]["max_alerts_per_hour"]:
            print("⚠️  Alert throttled: too many alerts in the last hour")
            return False

        # Check cooldown period
        last_alert_time = max(
            [datetime.fromisoformat(h["timestamp"]) for h in recent_alerts],
            default=None,
        )

        if last_alert_time:
            cooldown_seconds = self.config["throttling"]["cooldown_minutes"] * 60
            if (now - last_alert_time).total_seconds() < cooldown_seconds:
                print("⚠️  Alert throttled: cooldown period active")
                return False

        return True

    def send_alert(self, alert):
        """Send alert via configured channels"""
        alert_level = alert.get("level", "LOW")

        if not self.should_send_alert(alert):
            return False

        # Determine which channels to use
        channels = self.config["alert_levels"].get(alert_level, [])

        success = False

        if "email" in channels and self.config["email"]["enabled"]:
            if self.send_email_alert(alert):
                success = True

        if "slack" in channels and self.config["slack"]["enabled"]:
            if self.send_slack_alert(alert):
                success = True

        # Record alert in history
        self.alert_history.append(
            {
                "timestamp": datetime.now().isoformat(),
                "level": alert_level,
                "title": alert.get("title", "Alert"),
                "channels": channels,
                "success": success,
            }
        )

        self.save_alert_history()

        return success

    def send_email_alert(self, alert):
        """Send alert via email"""
        try:
            if not self.config["email"]["enabled"]:
                return False

            # Create message
            msg = MIMEMultipart()
            msg["From"] = self.config["email"]["from_email"]
            msg["To"] = ", ".join(self.config["email"]["to_emails"])
            msg["Subject"] = f"🚨 Tool Monitor Alert: {alert.get('title', 'Alert')}"

            # Create HTML body
            html_body = f"""
            <html>
            <body>
                <h2>🚨 Tool Monitor Alert</h2>
                <h3>{alert.get('title', 'Alert')}</h3>
                <p><strong>Level:</strong> {alert.get('level', 'UNKNOWN')}</p>
                <p><strong>Time:</strong> {alert.get('timestamp', datetime.now().isoformat())}</p>
                <p><strong>Source:</strong> {alert.get('source', 'unknown')}</p>
                <hr>
                <p>{alert.get('message', 'No message provided')}</p>
                {"<pre>" + alert.get('details', '') + "</pre>" if alert.get('details') else ""}
            </body>
            </html>
            """

            msg.attach(MIMEText(html_body, "html"))

            # Send email
            server = smtplib.SMTP(
                self.config["email"]["smtp_server"], self.config["email"]["smtp_port"]
            )
            server.starttls()
            server.login(
                self.config["email"]["username"], self.config["email"]["password"]
            )
            text = msg.as_string()
            server.sendmail(
                self.config["email"]["from_email"],
                self.config["email"]["to_emails"],
                text,
            )
            server.quit()

            print("📧 Email alert sent successfully")
            return True

        except Exception as e:
            print(f"❌ Email alert failed: {e}")
            return False

    def send_slack_alert(self, alert):
        """Send alert via Slack webhook"""
        try:
            if not self.config["slack"]["enabled"]:
                return False

            # Create Slack message
            level_colors = {
                "CRITICAL": "#ff0000",
                "HIGH": "#ff8000",
                "MEDIUM": "#ffff00",
                "LOW": "#00ff00",
            }

            slack_message = {
                "channel": self.config["slack"]["channel"],
                "username": self.config["slack"]["username"],
                "attachments": [
                    {
                        "color": level_colors.get(alert.get("level", "LOW"), "#808080"),
                        "title": f"🚨 {alert.get('title', 'Alert')}",
                        "fields": [
                            {
                                "title": "Level",
                                "value": alert.get("level", "UNKNOWN"),
                                "short": True,
                            },
                            {
                                "title": "Source",
                                "value": alert.get("source", "unknown"),
                                "short": True,
                            },
                            {
                                "title": "Time",
                                "value": alert.get(
                                    "timestamp", datetime.now().isoformat()
                                ),
                                "short": False,
                            },
                        ],
                        "text": alert.get("message", "No message provided"),
                        "footer": "Tool Monitor",
                        "ts": datetime.now().timestamp(),
                    }
                ],
            }

            # Add details if present
            if alert.get("details"):
                slack_message["attachments"][0]["fields"].append(
                    {
                        "title": "Details",
                        "value": f"```{alert['details']}```",
                        "short": False,
                    }
                )

            # Send to Slack
            response = requests.post(
                self.config["slack"]["webhook_url"], json=slack_message, timeout=10
            )

            if response.status_code == 200:
                print("💬 Slack alert sent successfully")
                return True
            else:
                print(f"❌ Slack alert failed: HTTP {response.status_code}")
                return False

        except Exception as e:
            print(f"❌ Slack alert failed: {e}")
            return False

    def load_alert_history(self):
        """Load alert history"""
        history_file = os.path.join(self.logs_dir, "alert_history.json")
        try:
            if os.path.exists(history_file):
                with open(history_file, "r") as f:
                    return json.load(f)
        except Exception as e:
            print(f"Warning: Could not load alert history: {e}")
        return []

    def save_alert_history(self):
        """Save alert history"""
        history_file = os.path.join(self.logs_dir, "alert_history.json")
        try:
            with open(history_file, "w") as f:
                json.dump(
                    self.alert_history[-1000:], f, indent=2
                )  # Keep last 1000 alerts
        except Exception as e:
            print(f"Warning: Could not save alert history: {e}")

    def check_for_alerts(self):
        """Check system for alerts that need to be sent"""
        alerts = []

        # Check dashboard data for issues
        dashboard_file = os.path.join(self.data_dir, "dashboard_data.json")
        try:
            with open(dashboard_file, "r") as f:
                dashboard = json.load(f)

            # Check system resources with custom thresholds
            system = dashboard.get("system", {})
            disk_usage = system.get("disk_usage", {})

            # Use custom thresholds for system metrics
            system_metrics = {}
            if "percent" in disk_usage:
                system_metrics["disk_usage_percent"] = disk_usage["percent"]

            if "memory" in system:
                memory_info = system["memory"]
                if "percent" in memory_info:
                    system_metrics["memory_usage_percent"] = memory_info["percent"]

            if "cpu" in system:
                cpu_info = system["cpu"]
                if "percent" in cpu_info:
                    system_metrics["cpu_usage_percent"] = cpu_info["percent"]

            # Check system metrics against custom thresholds
            system_alerts = self.check_custom_thresholds(system_metrics, tool_name=None)
            alerts.extend(system_alerts)

            # Check tool health with custom thresholds
            tools_details = dashboard.get("tools", {}).get("details", {})
            for tool_name, tool_info in tools_details.items():
                tool_alerts = []

                # Check basic health status
                if tool_info.get("status") != "healthy":
                    tool_alerts.append(
                        {
                            "level": "HIGH",
                            "title": f"Tool {tool_name} Unhealthy",
                            "message": f"Tool {tool_name} is reporting unhealthy status",
                            "source": "tool_monitor",
                            "details": json.dumps(tool_info, indent=2),
                        }
                    )

                # Check tool metrics against custom thresholds
                tool_metrics = {}
                if "response_time" in tool_info:
                    tool_metrics["response_time_ms"] = tool_info["response_time"]
                if "error_rate" in tool_info:
                    tool_metrics["error_rate_percent"] = tool_info["error_rate"]
                if "uptime" in tool_info:
                    tool_metrics["uptime_percent"] = tool_info["uptime"]
                if "memory_usage" in tool_info:
                    tool_metrics["memory_mb"] = tool_info["memory_usage"]
                if "cpu_usage" in tool_info:
                    tool_metrics["cpu_percent"] = tool_info["cpu_usage"]

                if tool_metrics:
                    threshold_alerts = self.check_custom_thresholds(
                        tool_metrics, tool_name=tool_name
                    )
                    tool_alerts.extend(threshold_alerts)

                alerts.extend(tool_alerts)

        except FileNotFoundError:
            alerts.append(
                {
                    "level": "MEDIUM",
                    "title": "Dashboard Data Missing",
                    "message": "Could not read dashboard data for monitoring",
                    "source": "alert_system",
                }
            )

        # Check prediction results for critical issues
        prediction_files = [
            f
            for f in os.listdir(self.logs_dir)
            if f.startswith("predictions_") and f.endswith(".json")
        ]
        if prediction_files:
            latest_prediction = max(
                prediction_files,
                key=lambda x: os.path.getctime(os.path.join(self.logs_dir, x)),
            )
            try:
                with open(os.path.join(self.logs_dir, latest_prediction), "r") as f:
                    predictions = json.load(f)

                summary = predictions.get("summary", {})
                if summary.get("critical_risks", 0) > 0:
                    alerts.append(
                        {
                            "level": "CRITICAL",
                            "title": "Critical Tool Failure Risk",
                            "message": f'{summary["critical_risks"]} tools have critical failure risk',
                            "source": "predictive_monitor",
                            "details": json.dumps(
                                predictions.get("predictions", {}), indent=2
                            ),
                        }
                    )
            except Exception as e:
                print(f"Warning: Could not read prediction file: {e}")

        return alerts

    def process_alerts(self):
        """Process and send any pending alerts"""
        alerts = self.check_for_alerts()

        if not alerts:
            print("✅ No alerts to process")
            return

        print(f"🚨 Processing {len(alerts)} alerts...")

        sent_count = 0
        for alert in alerts:
            print(f"  Sending {alert['level']} alert: {alert['title']}")
            if self.send_alert(alert):
                sent_count += 1

        print(f"✅ Sent {sent_count}/{len(alerts)} alerts successfully")

    def show_status(self):
        """Show alerting system status"""
        print("📊 Enhanced Alerting System Status")
        print("=" * 40)

        print(f"Email enabled: {'✅' if self.config['email']['enabled'] else '❌'}")
        if self.config["email"]["enabled"]:
            print(
                f"  SMTP: {self.config['email']['smtp_server']}:{self.config['email']['smtp_port']}"
            )
            print(f"  Recipients: {len(self.config['email']['to_emails'])}")

        print(f"Slack enabled: {'✅' if self.config['slack']['enabled'] else '❌'}")
        if self.config["slack"]["enabled"]:
            print(f"  Channel: {self.config['slack']['channel']}")
            print(
                f"  Webhook: {'Configured' if self.config['slack']['webhook_url'] else 'Not configured'}"
            )

        print(f"\nRecent alerts: {len(self.alert_history)} in last 24h")

        # Show alert level configuration
        print("\nAlert routing:")
        for level, channels in self.config["alert_levels"].items():
            print(f"  {level}: {', '.join(channels) if channels else 'None'}")

    def check_escalation_policies(self, alert):
        """Check if alert should be escalated based on policies"""
        now = datetime.now()

        # Get escalation config
        escalation_config = self.config.get("escalation", {})

        # Check frequency-based escalation
        frequency_config = escalation_config.get("policies", {}).get(
            "frequency_escalation", {}
        )
        if frequency_config.get("enabled", False):
            thresholds = frequency_config.get("thresholds", {})
            time_window = frequency_config.get("time_window_minutes", 60)

            # Count similar alerts in time window
            cutoff = now - timedelta(minutes=time_window)
            similar_alerts = [
                h
                for h in self.alert_history
                if datetime.fromisoformat(h["timestamp"]) > cutoff
                and h.get("title") == alert.get("title")
                and h.get("source") == alert.get("source")
            ]

            # Check thresholds in descending order (highest first)
            threshold_items = []
            for k, v in thresholds.items():
                try:
                    threshold_items.append((int(k), v))
                except ValueError:
                    continue  # Skip non-integer keys

            for threshold_count, escalate_to in sorted(
                threshold_items, key=lambda x: x[0], reverse=True
            ):
                if len(similar_alerts) >= threshold_count:
                    if (
                        alert.get("level") != escalate_to
                    ):  # Only escalate if not already at this level
                        alert["level"] = escalate_to
                        alert["escalation_reason"] = (
                            f"Frequency escalation: {len(similar_alerts)} occurrences in {time_window} minutes"
                        )
                        return True
                    break  # Found the highest applicable threshold

        # Check duration-based escalation
        duration_config = escalation_config.get("policies", {}).get(
            "duration_escalation", {}
        )
        if duration_config.get("enabled", False):
            thresholds = duration_config.get("thresholds", {})

            # Find first occurrence of this alert type
            first_occurrence = None
            for h in reversed(self.alert_history):
                if h.get("title") == alert.get("title") and h.get(
                    "source"
                ) == alert.get("source"):
                    first_occurrence = datetime.fromisoformat(h["timestamp"])
                    break

            if first_occurrence:
                duration_minutes = (now - first_occurrence).total_seconds() / 60

                # Check thresholds in descending order
                duration_threshold_items = []
                for k, v in thresholds.items():
                    try:
                        duration_threshold_items.append((int(k), v))
                    except ValueError:
                        continue

                for threshold_minutes, escalate_to in sorted(
                    duration_threshold_items, key=lambda x: x[0], reverse=True
                ):
                    if duration_minutes >= threshold_minutes:
                        if alert.get("level") != escalate_to:
                            alert["level"] = escalate_to
                            alert["escalation_reason"] = (
                                f"Duration escalation: {duration_minutes:.1f} minutes since first occurrence"
                            )
                            return True
                        break

        # Check persistent issue escalation
        persistent_config = escalation_config.get("policies", {}).get(
            "persistent_escalation", {}
        )
        if persistent_config.get("enabled", False):
            check_interval_minutes = persistent_config.get("check_interval_minutes", 15)
            max_checks = persistent_config.get("max_checks", 4)
            escalate_to = persistent_config.get("escalate_to", "CRITICAL")

            # Count alerts in recent intervals
            cutoff = now - timedelta(minutes=check_interval_minutes * max_checks)
            recent_similar = [
                h
                for h in self.alert_history
                if datetime.fromisoformat(h["timestamp"]) > cutoff
                and h.get("title") == alert.get("title")
                and h.get("source") == alert.get("source")
            ]

            # Check if alert occurred in each interval
            intervals_with_alerts = set()
            for h in recent_similar:
                alert_time = datetime.fromisoformat(h["timestamp"])
                intervals_passed = int(
                    (now - alert_time).total_seconds() / 60 / check_interval_minutes
                )
                intervals_with_alerts.add(intervals_passed)

            if len(intervals_with_alerts) >= max_checks:
                alert["level"] = escalate_to
                alert["escalation_reason"] = (
                    f"Persistent escalation: issue present in {len(intervals_with_alerts)} consecutive {check_interval_minutes}min intervals"
                )
                return True

        return False

    def send_escalated_alert(self, alert):
        """Send escalated alert with enhanced routing"""
        escalation_reason = alert.get("escalation_reason", "Unknown escalation")

        # Enhance alert message with escalation info
        original_message = alert.get("message", "")
        alert["message"] = (
            f"🚨 ESCALATED ALERT 🚨\n{escalation_reason}\n\n{original_message}"
        )

        # Add escalation to title
        alert["title"] = f"ESCALATED: {alert.get('title', 'Alert')}"

        # Force additional channels for escalated alerts
        escalation_config = self.config.get("escalation", {})
        force_channels = escalation_config.get("force_channels", [])

        # Ensure escalated alerts go to all configured channels
        current_level = alert.get("level", "LOW")
        base_channels = self.config["alert_levels"].get(current_level, [])

        # Combine base channels with forced escalation channels
        all_channels = list(set(base_channels + force_channels))

        # Override channels for this alert
        alert["_forced_channels"] = all_channels

        print(f"🚨 Sending escalated {current_level} alert: {alert['title']}")
        print(f"   Reason: {escalation_reason}")

        return self.send_alert_with_channels(alert, all_channels)

    def send_alert_with_channels(self, alert, channels):
        """Send alert via specific channels (bypassing normal routing)"""
        success = False

        if "email" in channels and self.config["email"]["enabled"]:
            if self.send_email_alert(alert):
                success = True

        if "slack" in channels and self.config["slack"]["enabled"]:
            if self.send_slack_alert(alert):
                success = True

        # Record alert in history
        self.alert_history.append(
            {
                "timestamp": datetime.now().isoformat(),
                "level": alert.get("level", "LOW"),
                "title": alert.get("title", "Alert"),
                "channels": channels,
                "success": success,
                "escalated": True,
                "escalation_reason": alert.get("escalation_reason"),
            }
        )

        self.save_alert_history()

        return success

    def process_alerts_with_escalation(self):
        """Process alerts with escalation policies"""
        alerts = self.check_for_alerts()

        if not alerts:
            print("✅ No alerts to process")
            return

        print(f"🚨 Processing {len(alerts)} alerts with escalation checks...")

        sent_count = 0
        escalated_count = 0

        for alert in alerts:
            # Check if alert should be escalated
            if self.check_escalation_policies(alert):
                print(f"  Escalating {alert['level']} alert: {alert['title']}")
                if self.send_escalated_alert(alert):
                    sent_count += 1
                    escalated_count += 1
            else:
                print(f"  Sending {alert['level']} alert: {alert['title']}")
                if self.send_alert(alert):
                    sent_count += 1

        print(
            f"✅ Sent {sent_count}/{len(alerts)} alerts successfully ({escalated_count} escalated)"
        )

    def correlate_alerts(self, alerts):
        """Correlate related alerts to reduce noise"""
        if not self.config.get("correlation", {}).get("enabled", False):
            return alerts

        correlation_config = self.config["correlation"]["rules"]
        time_window = correlation_config["time_window_minutes"]
        max_group_size = correlation_config["max_group_size"]

        # Group alerts by time windows
        time_groups = {}
        for alert in alerts:
            alert_time = datetime.fromisoformat(
                alert.get("timestamp", datetime.now().isoformat())
            )
            # Round to nearest time window
            window_start = alert_time.replace(second=0, microsecond=0)
            minutes = window_start.minute
            window_minutes = (minutes // time_window) * time_window
            window_start = window_start.replace(minute=window_minutes)

            window_key = window_start.isoformat()
            if window_key not in time_groups:
                time_groups[window_key] = []
            time_groups[window_key].append(alert)

        correlated_alerts = []

        # Process each time group
        for window_key, group_alerts in time_groups.items():
            if len(group_alerts) <= 1:
                # No correlation needed for single alerts
                correlated_alerts.extend(group_alerts)
                continue

            # Apply correlation patterns
            correlation_groups = self._apply_correlation_patterns(
                group_alerts, correlation_config
            )

            # Convert correlation groups to correlated alerts
            for group in correlation_groups:
                if len(group["alerts"]) > 1:
                    # Create correlated alert
                    correlated_alert = self._create_correlated_alert(
                        group, correlation_config
                    )
                    correlated_alerts.append(correlated_alert)
                else:
                    # Single alert, add as-is
                    correlated_alerts.extend(group["alerts"])

        return correlated_alerts

    def _apply_correlation_patterns(self, alerts, correlation_config):
        """Apply correlation patterns to group related alerts"""
        patterns = correlation_config["correlation_patterns"]
        correlation_groups = []

        # Start with each alert in its own group
        ungrouped_alerts = alerts.copy()

        for pattern_name, pattern_config in patterns.items():
            if not ungrouped_alerts:
                break

            keywords = set(pattern_config["keywords"])
            sources = set(pattern_config["sources"])

            # Find alerts matching this pattern
            matching_alerts = []
            remaining_alerts = []

            for alert in ungrouped_alerts:
                alert_text = (
                    f"{alert.get('title', '')} {alert.get('message', '')}".lower()
                )
                alert_source = alert.get("source", "")

                # Check if alert matches pattern
                keyword_match = any(keyword in alert_text for keyword in keywords)
                source_match = alert_source in sources

                if keyword_match and source_match:
                    matching_alerts.append(alert)
                else:
                    remaining_alerts.append(alert)

            # Create correlation group if we have matches
            if len(matching_alerts) > 1:
                correlation_groups.append(
                    {
                        "pattern": pattern_name,
                        "alerts": matching_alerts,
                        "pattern_config": pattern_config,
                    }
                )
                ungrouped_alerts = remaining_alerts
            elif len(matching_alerts) == 1:
                # Single match, keep separate
                remaining_alerts.extend(matching_alerts)
                ungrouped_alerts = remaining_alerts

        # Any remaining alerts become individual groups
        for alert in ungrouped_alerts:
            correlation_groups.append(
                {"pattern": "individual", "alerts": [alert], "pattern_config": {}}
            )

        return correlation_groups

    def _create_correlated_alert(self, correlation_group, correlation_config):
        """Create a correlated alert from a group of related alerts"""
        alerts = correlation_group["alerts"]
        pattern_config = correlation_group["pattern_config"]

        if not alerts:
            return None

        # Use pattern configuration or derive from alerts
        if pattern_config:
            group_title = pattern_config["group_title"]
            group_level = pattern_config["group_level"]
        else:
            # Derive from first alert
            first_alert = alerts[0]
            group_title = f"Multiple {first_alert.get('title', 'Issues')}"
            group_level = first_alert.get("level", "MEDIUM")

        # Create detailed message
        alert_summaries = []
        sources = set()
        max_level = "LOW"

        level_priority = {"LOW": 1, "MEDIUM": 2, "HIGH": 3, "CRITICAL": 4}

        for alert in alerts:
            level = alert.get("level", "LOW")
            if level_priority.get(level, 0) > level_priority.get(max_level, 0):
                max_level = level

            sources.add(alert.get("source", "unknown"))
            alert_summaries.append(
                f"• {alert.get('title', 'Unknown')}: {alert.get('message', 'No details')}"
            )

        # Use highest severity level
        final_level = (
            max_level if pattern_config.get("group_level") != "HIGH" else group_level
        )

        # Create correlated alert
        correlated_alert = {
            "level": final_level,
            "title": group_title,
            "message": f"Correlated {len(alerts)} related alerts from {len(sources)} sources",
            "source": "alert_correlator",
            "timestamp": datetime.now().isoformat(),
            "correlation_group": {
                "pattern": correlation_group["pattern"],
                "alert_count": len(alerts),
                "sources": list(sources),
                "time_window": correlation_config["time_window_minutes"],
                "alerts": [
                    {
                        "title": alert.get("title"),
                        "level": alert.get("level"),
                        "source": alert.get("source"),
                        "timestamp": alert.get("timestamp"),
                    }
                    for alert in alerts
                ],
            },
            "details": "\n".join(alert_summaries),
        }

        return correlated_alert

    def process_alerts_with_correlation(self):
        """Process alerts with correlation and escalation"""
        raw_alerts = self.check_for_alerts()

        if not raw_alerts:
            print("✅ No alerts to process")
            return

        print(f"🚨 Found {len(raw_alerts)} raw alerts, applying correlation...")

        # Apply correlation
        correlated_alerts = self.correlate_alerts(raw_alerts)

        print(f"📊 Correlation complete: {len(correlated_alerts)} correlated alerts")

        sent_count = 0
        escalated_count = 0
        correlated_count = 0

        for alert in correlated_alerts:
            is_correlated = "correlation_group" in alert
            if is_correlated:
                correlated_count += 1
                alert_count = alert["correlation_group"]["alert_count"]
                print(
                    f"  Sending correlated {alert['level']} alert: {alert['title']} ({alert_count} alerts)"
                )

            # Check if alert should be escalated
            if self.check_escalation_policies(alert):
                print(f"  Escalating {alert['level']} alert: {alert['title']}")
                if self.send_escalated_alert(alert):
                    sent_count += 1
                    escalated_count += 1
            else:
                if not is_correlated:
                    print(f"  Sending {alert['level']} alert: {alert['title']}")
                if self.send_alert(alert):
                    sent_count += 1

        correlation_saved = len(raw_alerts) - len(correlated_alerts)
        print(f"✅ Sent {sent_count}/{len(correlated_alerts)} alerts successfully")
        print(f"   📊 Correlation saved {correlation_saved} duplicate notifications")
        print(f"   🚨 {escalated_count} alerts were escalated")
        print(f"   🔗 {correlated_count} correlated alert groups sent")

    def get_environment_thresholds(self, environment=None):
        """Get thresholds for a specific environment"""
        if not environment:
            environment = self.config.get("custom_thresholds", {}).get(
                "current_environment", "development"
            )

        thresholds_config = self.config.get("custom_thresholds", {})
        environments = thresholds_config.get("environments", {})

        return environments.get(environment, environments.get("development", {}))

    def get_tool_thresholds(self, tool_name):
        """Get thresholds for a specific tool"""
        thresholds_config = self.config.get("custom_thresholds", {})
        tools = thresholds_config.get("tools", {})

        # Try specific tool first, then fall back to default
        return tools.get(tool_name, tools.get("default", {}))

    def check_custom_thresholds(self, metric_data, tool_name=None, environment=None):
        """Check if metrics exceed custom thresholds and generate alerts"""
        alerts = []

        if not self.config.get("custom_thresholds", {}).get("enabled", False):
            return alerts

        # Get appropriate thresholds
        env_thresholds = self.get_environment_thresholds(environment)
        tool_thresholds = self.get_tool_thresholds(tool_name) if tool_name else {}

        # Combine thresholds (tool-specific takes precedence)
        thresholds = {**env_thresholds, **tool_thresholds}

        # Check system metrics
        if "disk_usage_percent" in metric_data and "disk_usage_percent" in thresholds:
            disk_percent = metric_data["disk_usage_percent"]
            threshold = thresholds["disk_usage_percent"]
            if disk_percent >= threshold:
                level = "CRITICAL" if disk_percent >= threshold + 10 else "HIGH"
                alerts.append(
                    {
                        "level": level,
                        "title": f"Disk Usage Alert ({tool_name or 'System'})",
                        "message": f"Disk usage is at {disk_percent}% (threshold: {threshold}%)",
                        "source": "custom_threshold_monitor",
                        "tool": tool_name,
                        "metric": "disk_usage_percent",
                        "value": disk_percent,
                        "threshold": threshold,
                    }
                )

        if (
            "memory_usage_percent" in metric_data
            and "memory_usage_percent" in thresholds
        ):
            memory_percent = metric_data["memory_usage_percent"]
            threshold = thresholds["memory_usage_percent"]
            if memory_percent >= threshold:
                level = "CRITICAL" if memory_percent >= threshold + 10 else "HIGH"
                alerts.append(
                    {
                        "level": level,
                        "title": f"Memory Usage Alert ({tool_name or 'System'})",
                        "message": f"Memory usage is at {memory_percent}% (threshold: {threshold}%)",
                        "source": "custom_threshold_monitor",
                        "tool": tool_name,
                        "metric": "memory_usage_percent",
                        "value": memory_percent,
                        "threshold": threshold,
                    }
                )

        if "cpu_usage_percent" in metric_data and "cpu_usage_percent" in thresholds:
            cpu_percent = metric_data["cpu_usage_percent"]
            threshold = thresholds["cpu_usage_percent"]
            if cpu_percent >= threshold:
                level = "CRITICAL" if cpu_percent >= threshold + 15 else "HIGH"
                alerts.append(
                    {
                        "level": level,
                        "title": f"CPU Usage Alert ({tool_name or 'System'})",
                        "message": f"CPU usage is at {cpu_percent}% (threshold: {threshold}%)",
                        "source": "custom_threshold_monitor",
                        "tool": tool_name,
                        "metric": "cpu_usage_percent",
                        "value": cpu_percent,
                        "threshold": threshold,
                    }
                )

        # Check tool-specific metrics
        if tool_name:
            if (
                "response_time_ms" in metric_data
                and "response_time_ms" in tool_thresholds
            ):
                response_time = metric_data["response_time_ms"]
                threshold = tool_thresholds["response_time_ms"]
                if response_time >= threshold:
                    level = "CRITICAL" if response_time >= threshold * 2 else "HIGH"
                    alerts.append(
                        {
                            "level": level,
                            "title": f"Response Time Alert ({tool_name})",
                            "message": f"Response time is {response_time}ms (threshold: {threshold}ms)",
                            "source": "custom_threshold_monitor",
                            "tool": tool_name,
                            "metric": "response_time_ms",
                            "value": response_time,
                            "threshold": threshold,
                        }
                    )

            if (
                "error_rate_percent" in metric_data
                and "error_rate_percent" in tool_thresholds
            ):
                error_rate = metric_data["error_rate_percent"]
                threshold = tool_thresholds["error_rate_percent"]
                if error_rate >= threshold:
                    level = "CRITICAL" if error_rate >= threshold * 2 else "HIGH"
                    alerts.append(
                        {
                            "level": level,
                            "title": f"Error Rate Alert ({tool_name})",
                            "message": f"Error rate is {error_rate}% (threshold: {threshold}%)",
                            "source": "custom_threshold_monitor",
                            "tool": tool_name,
                            "metric": "error_rate_percent",
                            "value": error_rate,
                            "threshold": threshold,
                        }
                    )

            if "uptime_percent" in metric_data and "uptime_percent" in tool_thresholds:
                uptime = metric_data["uptime_percent"]
                threshold = tool_thresholds["uptime_percent"]
                if uptime < threshold:
                    level = "CRITICAL" if uptime < threshold - 5 else "HIGH"
                    alerts.append(
                        {
                            "level": level,
                            "title": f"Uptime Alert ({tool_name})",
                            "message": f"Uptime is {uptime}% (threshold: {threshold}%)",
                            "source": "custom_threshold_monitor",
                            "tool": tool_name,
                            "metric": "uptime_percent",
                            "value": uptime,
                            "threshold": threshold,
                        }
                    )

        return alerts

    def set_environment(self, environment):
        """Set the current environment for threshold checking"""
        if "custom_thresholds" not in self.config:
            self.config["custom_thresholds"] = {}

        self.config["custom_thresholds"]["current_environment"] = environment
        self.save_config()
        print(f"✅ Environment set to: {environment}")

    def show_thresholds(self):
        """Show current custom thresholds configuration"""
        print("📊 Custom Alert Thresholds Configuration")
        print("=" * 50)

        thresholds_config = self.config.get("custom_thresholds", {})
        if not thresholds_config.get("enabled", False):
            print("❌ Custom thresholds are disabled")
            return

        current_env = thresholds_config.get("current_environment", "development")
        print(f"Current Environment: {current_env}")
        print(
            f"Custom Thresholds: {'✅' if thresholds_config.get('enabled') else '❌'}"
        )

        # Show environment thresholds
        environments = thresholds_config.get("environments", {})
        if environments:
            print("\n🌍 Environment Thresholds:")
            for env_name, env_thresholds in environments.items():
                marker = "👉 " if env_name == current_env else "   "
                print(f"{marker}{env_name}:")
                for metric, value in env_thresholds.items():
                    print(f"    {metric}: {value}")

        # Show tool thresholds
        tools = thresholds_config.get("tools", {})
        if tools:
            print("\n🔧 Tool-Specific Thresholds:")
            for tool_name, tool_thresholds in tools.items():
                print(f"   {tool_name}:")
                for metric, value in tool_thresholds.items():
                    print(f"    {metric}: {value}")

    def update_threshold(self, category, name, metric, value):
        """Update a specific threshold value"""
        if "custom_thresholds" not in self.config:
            self.config["custom_thresholds"] = {}

        if category not in self.config["custom_thresholds"]:
            self.config["custom_thresholds"][category] = {}

        if name not in self.config["custom_thresholds"][category]:
            self.config["custom_thresholds"][category][name] = {}

        self.config["custom_thresholds"][category][name][metric] = value
        self.save_config()
        print(f"✅ Updated {category}.{name}.{metric} = {value}")


def main():
    print("🚨 Enhanced Alerting System")

    system = EnhancedAlertingSystem()

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == "setup":
            system.setup_alerting()
        elif command == "test":
            system.test_configuration()
        elif command == "status":
            system.show_status()
        elif command == "check":
            system.process_alerts_with_correlation()
        elif command == "thresholds":
            system.show_thresholds()
        elif command == "set-env":
            if len(sys.argv) > 2:
                system.set_environment(sys.argv[2])
            else:
                print("Usage: python3 enhanced_alerting.py set-env <environment>")
        else:
            print(
                "Usage: python3 enhanced_alerting.py [setup|test|status|check|thresholds|set-env]"
            )
    else:
        # Default: check and process alerts with correlation
        system.process_alerts_with_correlation()


if __name__ == "__main__":
    main()
