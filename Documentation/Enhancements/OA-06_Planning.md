# OA-06 Planning: Observability & Hygiene
## Unattended Automation Stability System

**Status:** Planning Phase  
**Priority:** Next after OA-05 validation  
**Estimated Effort:** 2-3 hours implementation

---

## 🎯 Objectives

Establish monitoring and cleanup automation to keep the unattended Quantum Agent running stable:

1. **Watchdog for automation logs** - Monitor and rotate logs, alert on anomalies
2. **Nightly metrics snapshots** - Capture system health and performance data
3. **Branch/PR cleanup** - Automated housekeeping for stale branches
4. **Health monitoring dashboard** - Centralized view of system status

---

## 📋 Scope Definition

### In Scope

✅ **Log Management**
- Automated log rotation for all automation scripts
- Log size monitoring and alerting
- Error pattern detection and alerting
- Historical log archival (30-day retention)

✅ **Metrics Collection**
- Daily snapshots of key performance indicators
- Automation success/failure rates
- MCP alert frequency and patterns
- Ollama usage statistics
- Validation pass/fail trends

✅ **Repository Hygiene**
- Auto-delete merged branches (>7 days old)
- Close stale PRs (>30 days inactive)
- Clean up abandoned feature branches
- Archive old validation reports (>30 days)
- Purge old AI review artifacts (>30 days)

✅ **Health Monitoring**
- System status dashboard
- Service availability checks (Ollama, MCP)
- Disk space monitoring
- Performance threshold alerting

### Out of Scope

❌ Full observability platform (Grafana/Prometheus)  
❌ Real-time alerting (Slack/PagerDuty integration)  
❌ Advanced anomaly detection (ML-based)  
❌ Distributed tracing  

---

## 🏗️ Architecture

### Component Design

```
┌──────────────────────────────────────┐
│  Nightly Cron Job (00:00 UTC)       │
│  - metrics_snapshot.sh               │
│  - cleanup_branches.sh               │
│  - rotate_logs.sh                    │
└─────────────┬────────────────────────┘
              │
              ├─────────────────────────────┐
              │                             │
              ▼                             ▼
┌──────────────────────┐      ┌──────────────────────┐
│  Watchdog Monitor    │      │  Cleanup Engine      │
│  - Log scanning      │      │  - Branch deletion   │
│  - Error detection   │      │  - File archival     │
│  - Alert publishing  │      │  - Report cleanup    │
└──────────┬───────────┘      └─────────┬────────────┘
           │                            │
           └─────────┬──────────────────┘
                     ▼
          ┌──────────────────────┐
          │   MCP Alert System   │
          │   - Store metrics    │
          │   - Publish alerts   │
          └──────────────────────┘
```

### File Structure

```
Tools/Automation/
├── observability/
│   ├── watchdog.sh              # Main watchdog script
│   ├── metrics_snapshot.sh      # Daily metrics collection
│   ├── rotate_logs.sh           # Log rotation handler
│   └── health_check.sh          # System health verification
├── hygiene/
│   ├── cleanup_branches.sh      # Branch cleanup automation
│   ├── cleanup_prs.sh           # Stale PR management
│   ├── archive_artifacts.sh     # Old file archival
│   └── hygiene_report.sh        # Cleanup summary generator
└── dashboard/
    ├── status_dashboard.html    # System status viewer
    ├── metrics_viewer.html      # Historical metrics display
    └── generate_dashboard.sh    # Dashboard data updater

.github/workflows/
└── nightly-hygiene.yml          # Scheduled cleanup workflow
```

---

## 🔧 Implementation Plan

### Phase 1: Log Management & Watchdog (45 min)

**1.1 Create Log Rotation Script**
```bash
Tools/Automation/observability/rotate_logs.sh
```
Features:
- Scan for logs in Tools/Automation/*/logs/
- Rotate logs >10MB
- Compress rotated logs (.gz)
- Delete logs >30 days old
- Publish rotation summary to MCP

**1.2 Create Watchdog Monitor**
```bash
Tools/Automation/observability/watchdog.sh
```
Features:
- Scan recent logs for ERROR patterns
- Detect repeated failures (>3 in 1 hour)
- Check disk space usage (<90% threshold)
- Monitor Ollama/MCP server health
- Publish critical alerts to MCP

**1.3 Schedule Watchdog**
```yaml
.github/workflows/nightly-hygiene.yml
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
```

### Phase 2: Metrics Collection (45 min)

**2.1 Create Metrics Snapshot Script**
```bash
Tools/Automation/observability/metrics_snapshot.sh
```
Collect:
- Validation success rate (last 24h)
- AI review statistics (count, avg time)
- MCP alert breakdown by level
- Ollama usage (requests, avg response time)
- Disk usage by category

**2.2 Store Metrics**
```
Tools/Automation/metrics/
├── snapshots/
│   └── YYYY-MM-DD.json
└── aggregated/
    ├── weekly.json
    └── monthly.json
```

**2.3 Generate Trends**
- Compare day-over-day changes
- Identify performance regressions
- Alert on threshold violations

### Phase 3: Repository Cleanup (30 min)

**3.1 Branch Cleanup Script**
```bash
Tools/Automation/hygiene/cleanup_branches.sh
```
Logic:
- Find merged branches >7 days old
- Exclude: main, develop, release/*
- Delete local and remote (with confirmation)
- Log deleted branches

**3.2 PR Cleanup Script**
```bash
Tools/Automation/hygiene/cleanup_prs.sh
```
Logic:
- Find PRs with no activity >30 days
- Comment with "stale" warning
- Close after 7 more days if no response
- Label with "auto-closed"

**3.3 Artifact Cleanup**
```bash
Tools/Automation/hygiene/archive_artifacts.sh
```
Cleanup:
- validation_reports/ >30 days
- ai_reviews/ >30 days
- mcp_artifacts/ >30 days
- Compress before deletion

### Phase 4: Dashboard & Reporting (30 min)

**4.1 Create Status Dashboard**
```html
Tools/Automation/dashboard/status_dashboard.html
```
Display:
- Current system status (all green/yellow/red)
- Last 24h activity summary
- Active alerts
- Quick links to logs/metrics

**4.2 Metrics Viewer**
```html
Tools/Automation/dashboard/metrics_viewer.html
```
Show:
- Historical charts (last 30 days)
- Success rate trends
- Performance graphs
- Alert frequency

**4.3 Daily Report Generator**
```bash
Tools/Automation/observability/generate_daily_report.sh
```
Output:
```markdown
# Daily System Report - 2025-10-06

## Activity Summary
- Validations: 15 (13 passed, 2 failed)
- AI Reviews: 8 (5 approved, 3 needs changes)
- MCP Alerts: 23 (0 critical, 2 errors, 21 info)

## Performance
- Avg validation time: 1.2 min
- Avg AI review time: 2.5 min
- Ollama uptime: 99.8%

## Cleanup Actions
- Branches deleted: 3
- Logs rotated: 5
- Artifacts archived: 120 files

## Alerts
- ⚠️ Validation failure rate increased 5%
- ✅ All systems operational
```

---

## 📊 Metrics to Track

### Performance Metrics
- Validation execution time (avg, p50, p95, p99)
- AI review generation time
- MCP alert publish latency
- Ollama response time
- Workflow end-to-end duration

### Reliability Metrics
- Validation success rate (%)
- AI review completion rate (%)
- MCP publish success rate (%)
- Ollama availability (%)
- Workflow failure rate (%)

### Quality Metrics
- False positive rate (AI reviews)
- False negative rate (AI reviews)
- Validation accuracy
- Issue detection rate
- Developer satisfaction (survey-based)

### Operational Metrics
- Disk usage (GB, % of total)
- Log file count and size
- Active branches
- Open PRs
- Artifact count

---

## 🚨 Alerting Thresholds

### Critical (Immediate Action)
- Ollama server down >5 minutes
- MCP server down >5 minutes
- Disk usage >95%
- Validation failure rate >80% (in 1 hour)
- AI review failure rate >50% (in 1 hour)

### Warning (Review Soon)
- Disk usage >85%
- Validation failure rate >40% (in 24 hours)
- Log file size >100MB
- Open PRs >20
- Stale branches >50

### Info (Monitoring)
- Daily activity summary
- Cleanup actions completed
- Performance trends
- Capacity planning alerts

---

## 🔐 Security Considerations

### Log Safety
- Never log sensitive data (tokens, passwords)
- Sanitize file paths in logs
- Rotate logs to prevent disk fill
- Restrict log file permissions (600)

### Cleanup Safety
- Always confirm before destructive actions
- Maintain audit trail of deletions
- Allow recovery period (7 days for branches)
- Never auto-delete protected branches

### Dashboard Access
- Read-only view of system status
- No sensitive data exposed
- Local-only access (no external hosting)

---

## 📝 Configuration

### Environment Variables
```bash
# Watchdog
export WATCHDOG_ENABLED="true"
export WATCHDOG_CHECK_INTERVAL=300  # 5 minutes
export DISK_USAGE_THRESHOLD=85      # Percent

# Cleanup
export BRANCH_CLEANUP_ENABLED="true"
export BRANCH_AGE_DAYS=7
export PR_STALE_DAYS=30
export ARTIFACT_RETENTION_DAYS=30

# Metrics
export METRICS_ENABLED="true"
export METRICS_SNAPSHOT_SCHEDULE="0 0 * * *"  # Daily at midnight
```

### Quality Gates
```yaml
# quality-config.yaml additions
observability:
  log_rotation:
    max_size_mb: 10
    retention_days: 30
  
  metrics:
    snapshot_frequency: daily
    retention_days: 90
  
  cleanup:
    merged_branch_age_days: 7
    stale_pr_age_days: 30
    artifact_retention_days: 30
```

---

## 🧪 Testing Strategy

### Test Scenarios

1. **Log Rotation Test**
   - Create >10MB log file
   - Run rotate_logs.sh
   - Verify compression and archival

2. **Watchdog Alert Test**
   - Inject ERROR lines in logs
   - Run watchdog.sh
   - Verify MCP alert published

3. **Branch Cleanup Test**
   - Create old merged branch
   - Run cleanup_branches.sh
   - Verify deletion and logging

4. **Metrics Collection Test**
   - Run metrics_snapshot.sh
   - Verify JSON output format
   - Check all metrics present

5. **Dashboard Generation Test**
   - Generate test metrics data
   - Run generate_dashboard.sh
   - Open dashboard in browser

---

## 📚 Documentation Deliverables

1. **OA-06_Implementation_Summary.md**
   - Complete technical overview
   - Component descriptions
   - Testing procedures

2. **OBSERVABILITY_GUIDE.md**
   - User-facing monitoring guide
   - How to read dashboards
   - Interpreting alerts

3. **HYGIENE_AUTOMATION_GUIDE.md**
   - Cleanup automation overview
   - Manual cleanup procedures
   - Recovery from accidental deletion

4. **Ollama_Autonomy_Issue_List.md**
   - Update OA-06 status to Complete

---

## ✅ Acceptance Criteria

OA-06 is complete when:

- [ ] Watchdog monitors logs and publishes alerts
- [ ] Nightly metrics snapshots are collected
- [ ] Branch/PR cleanup runs automatically
- [ ] Artifact archival prevents disk fill
- [ ] Status dashboard shows system health
- [ ] Daily reports are generated
- [ ] All scripts tested and documented
- [ ] GitHub workflow scheduled and working
- [ ] Alert thresholds tuned and validated

---

## 🚀 Rollout Plan

### Week 1: Core Implementation
- Day 1: Log rotation + watchdog
- Day 2: Metrics collection
- Day 3: Branch/PR cleanup
- Day 4: Testing and refinement

### Week 2: Dashboard & Integration
- Day 1: Status dashboard
- Day 2: Metrics viewer
- Day 3: Daily report generator
- Day 4: GitHub workflow integration

### Week 3: Monitoring & Tuning
- Day 1: Monitor metrics collection
- Day 2: Tune alert thresholds
- Day 3: Refine cleanup logic
- Day 4: Final documentation

---

## 🎯 Success Metrics

After 1 week of operation:
- ✅ Zero disk space issues
- ✅ All logs rotated properly
- ✅ Stale branches cleaned up (>80%)
- ✅ Daily metrics collected (100%)
- ✅ Alerts published (>95% success rate)

After 1 month:
- ✅ Performance trends identified
- ✅ Capacity planning data available
- ✅ Operational overhead reduced
- ✅ System stability improved (>99% uptime)

---

## 💡 Future Enhancements

### Short-Term
- Email notifications for critical alerts
- Slack integration for daily reports
- Custom dashboard widgets

### Medium-Term
- Anomaly detection (ML-based)
- Predictive capacity planning
- Auto-scaling recommendations

### Long-Term
- Full observability platform migration
- Real-time dashboards
- Distributed tracing integration

---

**Status:** Ready to implement after OA-05 validation complete  
**Estimated Time:** 2-3 hours for core functionality  
**Dependencies:** OA-05 must be stable and validated
