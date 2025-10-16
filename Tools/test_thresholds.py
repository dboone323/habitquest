#!/usr/bin/env python3
"""
Test script for custom alert thresholds
"""
import sys
import os

sys.path.append(os.path.dirname(__file__))

from enhanced_alerting import EnhancedAlertingSystem


def test_custom_thresholds():
    """Test the custom alert thresholds functionality"""
    print("🧪 Testing Custom Alert Thresholds")
    print("=" * 50)

    system = EnhancedAlertingSystem()

    # Test environment thresholds
    print("Testing environment thresholds...")
    dev_thresholds = system.get_environment_thresholds("development")
    prod_thresholds = system.get_environment_thresholds("production")

    print(f"Development disk threshold: {dev_thresholds.get('disk_usage_percent')}%")
    print(f"Production disk threshold: {prod_thresholds.get('disk_usage_percent')}%")

    # Test tool thresholds
    print("\nTesting tool thresholds...")
    coding_reviewer_thresholds = system.get_tool_thresholds("CodingReviewer")
    default_thresholds = system.get_tool_thresholds("UnknownTool")

    print(
        f"CodingReviewer response time threshold: {coding_reviewer_thresholds.get('response_time_ms')}ms"
    )
    print(
        f"Default response time threshold: {default_thresholds.get('response_time_ms')}ms"
    )

    # Test threshold checking
    print("\nTesting threshold checking...")

    # Test system metrics that should trigger alerts
    system_metrics = {
        "disk_usage_percent": 95,  # Above development threshold of 90
        "memory_usage_percent": 70,  # Below threshold
        "cpu_usage_percent": 85,  # Above development threshold of 80
    }

    system_alerts = system.check_custom_thresholds(system_metrics)
    print(f"System alerts generated: {len(system_alerts)}")
    for alert in system_alerts:
        print(
            f"  - {alert['level']}: {alert['title']} ({alert['value']} >= {alert['threshold']})"
        )

    # Test tool metrics
    tool_metrics = {
        "response_time_ms": 2500,  # Above CodingReviewer threshold of 2000
        "error_rate_percent": 1,  # Below threshold
        "uptime_percent": 99.0,  # Below threshold of 99.9
    }

    tool_alerts = system.check_custom_thresholds(
        tool_metrics, tool_name="CodingReviewer"
    )
    print(f"\nTool alerts generated: {len(tool_alerts)}")
    for alert in tool_alerts:
        print(
            f"  - {alert['level']}: {alert['title']} ({alert['value']} vs {alert['threshold']})"
        )

    # Test environment switching
    print("\nTesting environment switching...")
    system.set_environment("production")
    prod_alerts = system.check_custom_thresholds(system_metrics)
    print(
        f"Production environment alerts: {len(prod_alerts)} (should be fewer due to higher thresholds)"
    )

    # Switch back
    system.set_environment("development")

    print("\n✅ Custom thresholds testing complete")


if __name__ == "__main__":
    test_custom_thresholds()
