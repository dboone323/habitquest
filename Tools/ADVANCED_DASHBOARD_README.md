# Advanced Analytics Dashboard

A comprehensive, interactive web-based dashboard for real-time monitoring and analytics of the Quantum Workspace tool ecosystem.

## 🚀 Features

### 📊 Real-Time Metrics Visualization
- **System Metrics**: CPU, Memory, Disk usage with live updates
- **Interactive Charts**: Time-series graphs using Chart.js
- **Historical Data**: 24-hour trend analysis
- **Auto-refresh**: Updates every 30 seconds

### 🔧 Tool Health Monitoring
- **Status Overview**: Real-time health status of all tools
- **Performance Metrics**: Response times, error rates, uptime percentages
- **Custom Thresholds**: Environment and tool-specific alerting

### 🚨 Advanced Alerting System
- **Live Alerts Panel**: Recent alerts with severity levels
- **Alert Correlation**: Groups related alerts to reduce noise
- **Escalation Policies**: Automatic alert level increases based on patterns
- **Custom Thresholds**: Configurable per environment and tool

### 🔮 Predictive Analytics
- **Failure Predictions**: ML-based risk assessment
- **Trend Analysis**: Performance degradation detection
- **Resource Forecasting**: 24-hour usage predictions

### 📱 Responsive Design
- **Mobile-Friendly**: Works on all device sizes
- **Bootstrap UI**: Clean, professional interface
- **Dark Theme**: Easy on the eyes for long monitoring sessions

## 🛠️ Installation & Setup

### Prerequisites
```bash
# Required Python packages
pip install flask flask-cors psutil
```

### Starting the Dashboard
```bash
# From the Tools directory
./start_advanced_dashboard.sh

# Or directly with Python
python3 dashboard_server.py
```

The dashboard will be available at: **http://localhost:5000**

## 📋 API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /` | Main dashboard page |
| `GET /api/dashboard-data` | Current dashboard metrics |
| `GET /api/metrics/<type>` | Historical metrics data |
| `GET /api/alerts` | Recent alerts |
| `GET /api/predictions` | ML predictions data |
| `GET /api/trends/<timeframe>` | Trend analysis data |
| `GET /api/system-info` | Real-time system information |
| `GET /api/health` | Health check endpoint |

## 🎛️ Dashboard Components

### System Overview Cards
- **CPU Usage**: Current CPU utilization percentage
- **Memory Usage**: RAM usage with total/available breakdown
- **Disk Usage**: Storage utilization across all mounts
- **Tools Healthy**: Count of healthy vs total tools

### Metrics Charts
- **System Metrics Chart**: CPU, Memory, Disk over time
- **Performance Trends**: Response times and throughput trends
- **Custom Metrics**: Tool-specific performance indicators

### Status Panels
- **Tool Status**: Individual tool health and performance
- **Active Alerts**: Recent alerts with severity coloring
- **Predictions**: ML-based failure risk assessments

## ⚙️ Configuration

### Environment-Specific Thresholds
Configure different alert thresholds for development, staging, and production:

```json
{
  "custom_thresholds": {
    "current_environment": "production",
    "environments": {
      "production": {
        "disk_usage_percent": 80,
        "cpu_usage_percent": 70,
        "tool_health_score": 0.9
      }
    }
  }
}
```

### Tool-Specific Thresholds
Set custom thresholds for individual tools:

```json
{
  "tools": {
    "CodingReviewer": {
      "response_time_ms": 2000,
      "error_rate_percent": 2,
      "uptime_percent": 99.9
    }
  }
}
```

## 🔧 Management Commands

### Alerting System
```bash
# Check current status
python3 enhanced_alerting.py status

# View custom thresholds
python3 enhanced_alerting.py thresholds

# Switch environment
python3 enhanced_alerting.py set-env production

# Process alerts manually
python3 enhanced_alerting.py check
```

### Dashboard Server
```bash
# Start dashboard
./start_advanced_dashboard.sh

# Check server health
curl http://localhost:5000/api/health
```

## 📊 Data Sources

The dashboard aggregates data from multiple sources:

- **dashboard_data.json**: Current system and tool metrics
- **logs/alert_history.json**: Historical alerts and notifications
- **logs/predictions_*.json**: ML model predictions
- **metrics/*.json**: Time-series performance data
- **Real-time APIs**: Live system information via psutil

## 🚨 Alert Integration

The dashboard integrates with the advanced alerting system featuring:

- **Correlation Engine**: Groups related alerts automatically
- **Escalation Policies**: Increases alert severity based on patterns
- **Custom Thresholds**: Environment-aware alerting
- **Multi-channel Notifications**: Email, Slack, and dashboard alerts

## 🔍 Troubleshooting

### Dashboard Not Loading
1. Check if Flask server is running: `ps aux | grep dashboard_server`
2. Verify port 5000 is available: `lsof -i :5000`
3. Check Python dependencies: `python3 -c "import flask, flask_cors"`

### No Data Displayed
1. Verify data files exist: `ls -la dashboard_data.json`
2. Check file permissions: `ls -la *.json`
3. Run data collection: `./tool_health_monitor.sh`

### Performance Issues
1. Reduce refresh interval in dashboard.js
2. Limit historical data points in API responses
3. Check system resources: `top` or `htop`

## 🎯 Use Cases

### Development Monitoring
- Track tool performance during development
- Monitor resource usage of development tools
- Get alerts for development environment issues

### Production Oversight
- Real-time production system monitoring
- Predictive failure detection
- Automated alert escalation

### Performance Analysis
- Historical trend analysis
- Capacity planning insights
- Bottleneck identification

---

**Dashboard URL**: http://localhost:5000
**API Documentation**: See `/api/` endpoints above
**Configuration**: `enhanced_alerting.py` commands