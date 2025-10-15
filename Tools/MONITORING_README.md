# Quantum Workspace Tool Monitoring System

## Overview

The Quantum Workspace Tool Monitoring System provides comprehensive health monitoring, alerting, and performance tracking for the optimized 15-core tool ecosystem. This system ensures long-term reliability and performance of essential development tools.

## Components

### 1. Tool Health Monitor (`tool_health_monitor.sh`)

**Purpose**: Automated monitoring of essential tools with dashboard integration.

**Features**:
- Checks 14 essential tools: git, python3, node, npm, brew, ollama, jq, swiftlint, swiftformat, xcodebuild, swift, fastlane, pod, gh
- Real-time status reporting (healthy/unhealthy/missing)
- Dashboard data integration
- Comprehensive logging

**Usage**:
```bash
# Run full health check
./tool_health_monitor.sh check

# Show current status
./tool_health_monitor.sh status

# Show help
./tool_health_monitor.sh help
```

**Exit Codes**:
- `0`: All tools healthy
- `1`: Some tools unhealthy (warnings)
- `2`: Critical tools missing

### 2. Alerting System (`tool_alerts.sh`)

**Purpose**: Notification system for tool health issues and system alerts.

**Features**:
- Critical alerts for missing essential tools
- Warning alerts for unhealthy tools
- System resource monitoring (disk space)
- Historical alert tracking
- Configurable alert levels

**Usage**:
```bash
# Check for alerts
./tool_alerts.sh check

# Show recent alerts (last 24 hours)
./tool_alerts.sh show

# Show alerts from last 7 days
./tool_alerts.sh show 168
```

### 3. Performance Benchmarking (`tool_benchmark.sh`)

**Purpose**: Performance tracking and trend analysis for tool response times.

**Features**:
- Response time measurement for all tools
- Historical performance data
- Trend analysis and reporting
- JSON-based metrics storage

**Usage**:
```bash
# Run performance benchmark
./tool_benchmark.sh run

# Show benchmark history (last 7 days)
./tool_benchmark.sh history

# Show performance trends
./tool_benchmark.sh trends
```

### 4. Monitoring Integration (`monitoring_integration.sh`)

**Purpose**: Unified interface for running all monitoring components.

**Features**:
- Runs all monitoring systems in sequence
- Provides consolidated status report
- Updates dashboard with latest data
- One-command monitoring workflow

**Usage**:
```bash
# Run complete monitoring suite
./monitoring_integration.sh
```

## Dashboard Integration

The monitoring system integrates with the existing Quantum Workspace dashboard:

- **Dashboard URL**: http://localhost:8004/dashboard
- **API Endpoint**: http://localhost:8004/api/dashboard-data
- **Data Location**: `Tools/dashboard_data.json`

### Dashboard Data Structure

```json
{
  "tools": {
    "total": 14,
    "healthy": 14,
    "unhealthy": 0,
    "missing": 0,
    "last_check": "2025-10-15T20:37:26Z",
    "details": {
      "git": {"status": "healthy", "version": "2.50.1"},
      "python3": {"status": "healthy", "version": "3.12.4"},
      // ... other tools
    }
  },
  "alerts": {
    "tools": {
      "critical": 0,
      "warning": 1,
      "info": 0,
      "total": 1,
      "last_check": "2025-10-15T20:37:28Z"
    }
  },
  "benchmark": {
    "timestamp": "2025-10-15T20:37:28Z",
    "total_tools": 14,
    "successful_tests": 14,
    "average_response_time": "0.000",
    "results": [...]
  }
}
```

## File Structure

```
Tools/
├── tool_health_monitor.sh      # Core health monitoring
├── tool_alerts.sh             # Alerting system
├── tool_benchmark.sh          # Performance benchmarking
├── monitoring_integration.sh  # Unified monitoring interface
├── dashboard_data.json        # Dashboard data store
├── logs/                      # Log files
│   ├── tool_health_*.log      # Health check logs
│   ├── alerts_*.log          # Alert logs
│   └── benchmark_*.log        # Benchmark logs
└── metrics/                   # Performance metrics
    └── benchmark_*.json       # Benchmark results
```

## Automation Integration

### Cron Job Setup

Add to crontab for automated monitoring:

```bash
# Run monitoring every 15 minutes
*/15 * * * * cd /Users/danielstevens/Desktop/Quantum-workspace/Tools && ./monitoring_integration.sh >/dev/null 2>&1

# Run performance benchmark hourly
0 * * * * cd /Users/danielstevens/Desktop/Quantum-workspace/Tools && ./tool_benchmark.sh run >/dev/null 2>&1
```

### Master Automation Integration

The monitoring system integrates with the master automation system:

```bash
# Run monitoring as part of master automation
./Tools/Automation/master_automation.sh monitor
```

## Alert Thresholds

### Critical Alerts (Immediate Action Required)
- Essential tools missing from PATH
- Disk usage > 90%

### Warning Alerts (Monitor Closely)
- Tools reporting unhealthy status
- Disk usage > 80%
- Performance degradation trends

### Info Alerts (Informational)
- System status changes
- Performance improvements

## Troubleshooting

### Common Issues

**Dashboard not updating**:
- Check that `jq` is installed
- Verify dashboard_data.json permissions
- Check logs for JSON parsing errors

**Tools showing as missing**:
- Verify tools are installed and in PATH
- Check tool installation: `which <tool>`
- Update PATH if necessary

**Performance benchmarks showing 0.000s**:
- This is normal for fast-executing commands
- Response times are measured in milliseconds
- Focus on trends rather than absolute values

### Log Files

All components generate detailed logs:
- `logs/tool_health_$(date +%Y%m%d).log`
- `logs/alerts_$(date +%Y%m%d).log`
- `logs/benchmark_$(date +%Y%m%d).log`

### Manual Health Check

```bash
# Quick health check
./tool_health_monitor.sh status

# Detailed health check with logging
./tool_health_monitor.sh check

# Check for active alerts
./tool_alerts.sh show 24
```

## Performance Optimization

### Monitoring Frequency
- Health checks: Every 15 minutes
- Performance benchmarks: Hourly
- Alert checks: Continuous (integrated with health checks)

### Resource Usage
- Low CPU overhead (< 1% during checks)
- Minimal disk I/O (JSON updates only)
- Memory efficient (bash scripts)

### Data Retention
- Logs: 30 days rolling
- Metrics: 90 days rolling
- Dashboard data: Real-time updates

## Future Enhancements

### Planned Features
- Email/Slack notifications for critical alerts
- Webhook integration for external monitoring
- Advanced performance analytics
- Predictive failure detection
- Custom alert rules

### Extension Points
- Additional tool monitoring
- Custom health checks
- Third-party integrations
- Advanced reporting

## Support

For issues or questions:
1. Check logs in `Tools/logs/`
2. Run manual health checks
3. Verify tool installations
4. Check dashboard data integrity

---

**Last Updated**: October 15, 2025
**Version**: 3.0.0
**Tools Monitored**: 14 essential development tools