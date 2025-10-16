#!/usr/bin/env python3
"""
Test script for alert correlation engine
"""
import sys
import os

sys.path.append(os.path.dirname(__file__))

from enhanced_alerting import EnhancedAlertingSystem
from datetime import datetime, timedelta


def test_correlation_engine():
    """Test the alert correlation engine"""
    print("🧪 Testing Alert Correlation Engine")
    print("=" * 50)

    system = EnhancedAlertingSystem()

    # Create mock alerts for testing correlation
    now = datetime.now()

    # Create alerts that should be correlated (disk issues)
    disk_alerts = [
        {
            "level": "HIGH",
            "title": "Disk Space Warning",
            "message": "Disk usage is at 85%",
            "source": "system_monitor",
            "timestamp": (now - timedelta(minutes=2)).isoformat(),
        },
        {
            "level": "HIGH",
            "title": "Storage Full",
            "message": "Filesystem / is 95% full",
            "source": "system_monitor",
            "timestamp": (now - timedelta(minutes=3)).isoformat(),
        },
        {
            "level": "MEDIUM",
            "title": "Disk I/O High",
            "message": "Disk I/O utilization above 90%",
            "source": "system_monitor",
            "timestamp": (now - timedelta(minutes=4)).isoformat(),
        },
    ]

    # Create alerts that should be correlated (memory issues)
    memory_alerts = [
        {
            "level": "HIGH",
            "title": "Memory Usage High",
            "message": "System memory usage at 92%",
            "source": "system_monitor",
            "timestamp": (now - timedelta(minutes=1)).isoformat(),
        },
        {
            "level": "HIGH",
            "title": "Out of Memory",
            "message": "Process killed due to out of memory",
            "source": "tool_monitor",
            "timestamp": (now - timedelta(minutes=2)).isoformat(),
        },
    ]

    # Create unrelated alert
    network_alert = {
        "level": "MEDIUM",
        "title": "Network Timeout",
        "message": "Connection timeout to external service",
        "source": "tool_monitor",
        "timestamp": now.isoformat(),
    }

    # Combine all alerts
    test_alerts = disk_alerts + memory_alerts + [network_alert]

    print(f"Testing correlation with {len(test_alerts)} alerts:")
    for i, alert in enumerate(test_alerts, 1):
        print(f"  {i}. {alert['level']} - {alert['title']} ({alert['source']})")

    # Apply correlation
    correlated_alerts = system.correlate_alerts(test_alerts)

    print(f"\n📊 Correlation Results:")
    print(f"   Input alerts: {len(test_alerts)}")
    print(f"   Correlated alerts: {len(correlated_alerts)}")
    print(f"   Notifications saved: {len(test_alerts) - len(correlated_alerts)}")

    for i, alert in enumerate(correlated_alerts, 1):
        if "correlation_group" in alert:
            group = alert["correlation_group"]
            print(f"\n  {i}. CORRELATED {alert['level']} - {alert['title']}")
            print(f"     Pattern: {group['pattern']}")
            print(
                f"     Grouped {group['alert_count']} alerts from {len(group['sources'])} sources"
            )
            print(f"     Sources: {', '.join(group['sources'])}")
        else:
            print(
                f"\n  {i}. SINGLE {alert['level']} - {alert['title']} ({alert['source']})"
            )

    print("\n✅ Correlation engine testing complete")


if __name__ == "__main__":
    test_correlation_engine()
