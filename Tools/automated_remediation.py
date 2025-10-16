#!/usr/bin/env python3
"""
Automated Remediation Engine
Analyzes issues and provides automated remediation suggestions and actions
"""

import json
import os
import subprocess
import sys
from datetime import datetime, timedelta
import re


class AutomatedRemediationEngine:
    def __init__(self, data_dir="/Users/danielstevens/Desktop/Quantum-workspace/Tools"):
        self.data_dir = data_dir
        self.logs_dir = os.path.join(data_dir, "logs")
        self.models_dir = os.path.join(data_dir, "models")
        self.dashboard_data_file = os.path.join(data_dir, "dashboard_data.json")

        # Remediation actions database
        self.remediation_actions = {
            "tool_not_found": {
                "description": "Tool executable not found in PATH",
                "actions": [
                    {
                        "type": "install",
                        "command": "brew install {tool}",
                        "description": "Install via Homebrew",
                    },
                    {
                        "type": "check_path",
                        "command": "which {tool}",
                        "description": "Verify installation",
                    },
                    {
                        "type": "alternative_install",
                        "command": "Install {tool} manually or via package manager",
                        "description": "Manual installation",
                    },
                ],
            },
            "tool_timeout": {
                "description": "Tool response timeout",
                "actions": [
                    {
                        "type": "restart_service",
                        "command": "pkill -f {tool} && sleep 2 && {tool} --version",
                        "description": "Restart tool process",
                    },
                    {
                        "type": "check_resources",
                        "command": "ps aux | grep {tool}",
                        "description": "Check if tool is running",
                    },
                    {
                        "type": "system_resources",
                        "command": "top -l 1 | head -10",
                        "description": "Check system resource usage",
                    },
                ],
            },
            "high_response_time": {
                "description": "Tool responding slower than expected",
                "actions": [
                    {
                        "type": "performance_check",
                        "command": "time {tool} --version",
                        "description": "Measure current performance",
                    },
                    {
                        "type": "system_load",
                        "command": "uptime && vm_stat",
                        "description": "Check system load",
                    },
                    {
                        "type": "cache_clear",
                        "command": "Clean {tool} cache if applicable",
                        "description": "Clear tool caches",
                    },
                ],
            },
            "permission_denied": {
                "description": "Permission denied when accessing tool",
                "actions": [
                    {
                        "type": "permission_check",
                        "command": "ls -la $(which {tool})",
                        "description": "Check file permissions",
                    },
                    {
                        "type": "ownership_fix",
                        "command": "sudo chown $(whoami) $(which {tool})",
                        "description": "Fix ownership",
                    },
                    {
                        "type": "executable_check",
                        "command": "chmod +x $(which {tool})",
                        "description": "Make executable",
                    },
                ],
            },
            "disk_space_low": {
                "description": "Low disk space affecting tool performance",
                "actions": [
                    {
                        "type": "disk_check",
                        "command": "df -h",
                        "description": "Check disk usage",
                    },
                    {
                        "type": "cleanup",
                        "command": "find ~/Library/Caches -name '*' -type f -size +50M -delete 2>/dev/null || true",
                        "description": "Clean old cache files",
                    },
                    {
                        "type": "large_files",
                        "command": "du -sh * 2>/dev/null | sort -hr | head -10",
                        "description": "Find large files",
                    },
                ],
            },
            "network_issue": {
                "description": "Network connectivity issues",
                "actions": [
                    {
                        "type": "network_check",
                        "command": "ping -c 3 8.8.8.8",
                        "description": "Test internet connectivity",
                    },
                    {
                        "type": "dns_check",
                        "command": "nslookup github.com",
                        "description": "Check DNS resolution",
                    },
                    {
                        "type": "proxy_check",
                        "command": "echo $http_proxy $https_proxy",
                        "description": "Check proxy settings",
                    },
                ],
            },
        }

        # Risk assessment rules
        self.risk_rules = {
            "critical": ["tool_not_found", "permission_denied"],
            "high": ["tool_timeout", "disk_space_low"],
            "medium": ["high_response_time", "network_issue"],
            "low": [],
        }

    def analyze_current_issues(self):
        """Analyze current system and tool issues"""
        issues = []

        # Check dashboard data for tool health
        try:
            with open(self.dashboard_data_file, "r") as f:
                dashboard_data = json.load(f)

            # Check tool statuses
            tools_details = dashboard_data.get("tools", {}).get("details", {})
            for tool_name, tool_info in tools_details.items():
                status = tool_info.get("status", "unknown")
                if status != "healthy":
                    issues.append(
                        {
                            "type": "tool_unhealthy",
                            "tool": tool_name,
                            "severity": "high",
                            "description": f"Tool {tool_name} is not healthy",
                            "details": tool_info,
                        }
                    )

            # Check system metrics
            system = dashboard_data.get("system", {})
            disk_usage = system.get("disk_usage", {})

            if disk_usage.get("status") == "warning":
                percent = disk_usage.get("percent", 0)
                issues.append(
                    {
                        "type": "disk_space_low",
                        "severity": "high",
                        "description": f"Disk space is {percent}% full",
                        "details": disk_usage,
                    }
                )

        except FileNotFoundError:
            issues.append(
                {
                    "type": "dashboard_unavailable",
                    "severity": "medium",
                    "description": "Dashboard data not available for analysis",
                }
            )

        # Check recent alert logs
        alert_issues = self.analyze_alert_logs()
        issues.extend(alert_issues)

        return issues

    def analyze_alert_logs(self):
        """Analyze recent alert logs for patterns"""
        issues = []

        # Check alerts log
        alerts_file = os.path.join(
            self.logs_dir, f"alerts_{datetime.now().strftime('%Y%m%d')}.log"
        )
        if os.path.exists(alerts_file):
            try:
                with open(alerts_file, "r") as f:
                    content = f.read()

                # Look for common patterns
                if "Disk Space Warning" in content:
                    issues.append(
                        {
                            "type": "disk_space_low",
                            "severity": "high",
                            "description": "Disk space warnings in alert log",
                            "source": "alerts_log",
                        }
                    )

            except Exception as e:
                print(f"Warning: Could not read alerts log: {e}")

        return issues

    def diagnose_issue(self, issue):
        """Diagnose the root cause of an issue"""
        issue_type = issue.get("type", "unknown")
        tool = issue.get("tool", "unknown")

        diagnosis = {
            "issue": issue,
            "possible_causes": [],
            "recommended_actions": [],
            "risk_level": self.assess_risk(issue),
            "automated_actions": [],
        }

        # Diagnose based on issue type
        if issue_type == "tool_unhealthy":
            diagnosis["possible_causes"] = [
                f"{tool} executable not found in PATH",
                f"{tool} installation corrupted",
                f"Permission issues with {tool}",
                f"{tool} dependencies missing",
                f"System resource constraints",
            ]
            diagnosis["recommended_actions"] = self.get_remediation_actions(
                "tool_not_found", tool
            )

        elif issue_type == "disk_space_low":
            diagnosis["possible_causes"] = [
                "Large files accumulating",
                "Cache directories not cleaned",
                "Log files growing unchecked",
                "Old backups not removed",
            ]
            diagnosis["recommended_actions"] = self.get_remediation_actions(
                "disk_space_low", tool
            )

        elif issue_type == "tool_timeout":
            diagnosis["possible_causes"] = [
                f"{tool} process hanging",
                "System resource exhaustion",
                f"{tool} waiting for network response",
                "Deadlock in tool execution",
            ]
            diagnosis["recommended_actions"] = self.get_remediation_actions(
                "tool_timeout", tool
            )

        elif issue_type == "high_response_time":
            diagnosis["possible_causes"] = [
                "High system load",
                f"{tool} cache corruption",
                "Network latency",
                "Memory pressure",
            ]
            diagnosis["recommended_actions"] = self.get_remediation_actions(
                "high_response_time", tool
            )

        return diagnosis

    def get_remediation_actions(self, issue_type, tool=""):
        """Get remediation actions for a specific issue type"""
        if issue_type not in self.remediation_actions:
            return []

        actions = self.remediation_actions[issue_type]["actions"].copy()

        # Customize actions with tool name
        for action in actions:
            action["command"] = action["command"].format(tool=tool)
            action["tool"] = tool

        return actions

    def assess_risk(self, issue):
        """Assess the risk level of an issue"""
        issue_type = issue.get("type", "unknown")
        severity = issue.get("severity", "low")

        # Check risk rules
        for risk_level, issue_types in self.risk_rules.items():
            if issue_type in issue_types:
                return risk_level.upper()

        # Fallback to severity mapping
        severity_map = {
            "critical": "CRITICAL",
            "high": "HIGH",
            "medium": "MEDIUM",
            "low": "LOW",
        }

        return severity_map.get(severity, "MEDIUM")

    def execute_remediation_action(self, action, dry_run=True):
        """Execute a remediation action"""
        result = {
            "action": action,
            "executed": False,
            "success": False,
            "output": "",
            "error": "",
            "dry_run": dry_run,
        }

        command = action.get("command", "")
        action_type = action.get("type", "unknown")

        if (
            not command
            or command.startswith("Install ")
            or command.startswith("Clean ")
        ):
            # These are manual actions, not executable commands
            result["output"] = f"Manual action required: {command}"
            return result

        if dry_run:
            result["output"] = f"[DRY RUN] Would execute: {command}"
            result["executed"] = True
            result["success"] = True  # Assume success in dry run
            return result

        try:
            # Execute the command
            process = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30,  # 30 second timeout
            )

            result["executed"] = True
            result["success"] = process.returncode == 0
            result["output"] = process.stdout
            result["error"] = process.stderr

        except subprocess.TimeoutExpired:
            result["error"] = f"Command timed out after 30 seconds: {command}"
        except Exception as e:
            result["error"] = f"Execution failed: {str(e)}"

        return result

    def generate_remediation_plan(self, issues):
        """Generate a comprehensive remediation plan"""
        plan = {
            "timestamp": datetime.now().isoformat(),
            "issues_found": len(issues),
            "diagnoses": [],
            "action_plan": [],
            "risk_assessment": {"CRITICAL": 0, "HIGH": 0, "MEDIUM": 0, "LOW": 0},
        }

        for issue in issues:
            diagnosis = self.diagnose_issue(issue)
            plan["diagnoses"].append(diagnosis)

            risk_level = diagnosis["risk_level"]
            plan["risk_assessment"][risk_level] += 1

            # Add recommended actions to plan
            for action in diagnosis["recommended_actions"]:
                plan["action_plan"].append(
                    {
                        "issue_type": issue["type"],
                        "tool": issue.get("tool", "system"),
                        "risk_level": risk_level,
                        "action": action,
                        "status": "pending",
                    }
                )

        # Sort action plan by risk level
        risk_priority = {"CRITICAL": 0, "HIGH": 1, "MEDIUM": 2, "LOW": 3}
        plan["action_plan"].sort(key=lambda x: risk_priority.get(x["risk_level"], 4))

        return plan

    def execute_remediation_plan(self, plan, dry_run=True, max_actions=5):
        """Execute remediation actions from the plan"""
        results = {
            "plan_timestamp": plan["timestamp"],
            "executed_actions": 0,
            "successful_actions": 0,
            "failed_actions": 0,
            "action_results": [],
            "dry_run": dry_run,
        }

        print(f"🔧 Executing remediation plan ({'DRY RUN' if dry_run else 'LIVE'})...")

        for i, action_item in enumerate(plan["action_plan"][:max_actions]):
            print(
                f"  Executing action {i+1}/{min(max_actions, len(plan['action_plan']))}: {action_item['action']['description']}"
            )

            result = self.execute_remediation_action(
                action_item["action"], dry_run=dry_run
            )
            results["action_results"].append(
                {"action_item": action_item, "execution_result": result}
            )

            results["executed_actions"] += 1
            if result["success"]:
                results["successful_actions"] += 1
            else:
                results["failed_actions"] += 1

        return results

    def save_remediation_report(self, plan, execution_results=None):
        """Save remediation report to file"""
        report = {
            "generated_at": datetime.now().isoformat(),
            "remediation_plan": plan,
            "execution_results": execution_results,
        }

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"remediation_report_{timestamp}.json"
        filepath = os.path.join(self.logs_dir, filename)

        with open(filepath, "w") as f:
            json.dump(report, f, indent=2, default=str)

        print(f"📄 Remediation report saved to {filepath}")
        return filepath

    def print_summary(self, plan, execution_results=None):
        """Print human-readable summary"""
        print("\n🔧 Automated Remediation Engine Summary")
        print("=" * 50)

        print(f"Issues Found: {plan['issues_found']}")
        print("Risk Assessment:")
        for risk_level, count in plan["risk_assessment"].items():
            if count > 0:
                print(f"  {risk_level}: {count}")

        print(f"\nRecommended Actions: {len(plan['action_plan'])}")

        if execution_results:
            print("\nExecution Results:")
            print(f"  Actions Executed: {execution_results['executed_actions']}")
            print(f"  Successful: {execution_results['successful_actions']}")
            print(f"  Failed: {execution_results['failed_actions']}")

            if execution_results["dry_run"]:
                print("  ⚠️  DRY RUN - No actual changes made")


def main():
    print("🔧 Automated Remediation Engine Starting...")

    engine = AutomatedRemediationEngine()

    # Analyze current issues
    print("🔍 Analyzing current system issues...")
    issues = engine.analyze_current_issues()

    print(f"Found {len(issues)} issues")

    # Generate remediation plan
    print("📋 Generating remediation plan...")
    plan = engine.generate_remediation_plan(issues)

    # Execute remediation (dry run by default)
    execution_results = engine.execute_remediation_plan(
        plan, dry_run=True, max_actions=3
    )

    # Save report
    engine.save_remediation_report(plan, execution_results)

    # Print summary
    engine.print_summary(plan, execution_results)

    print("\n✅ Remediation analysis completed!")


if __name__ == "__main__":
    main()
