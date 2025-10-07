# Disk Usage Monitoring Guide

**Purpose:** Daily monitoring procedures to maintain healthy disk usage (<85%)  
**Target Audience:** Developers, DevOps, System Administrators  
**Updated:** October 6, 2025

---

## Quick Reference

### Daily Check (2 minutes)

```bash
# 1. Open dashboard
open /Users/danielstevens/Desktop/Quantum-workspace/Tools/dashboard.html

# 2. Check "Disk Usage" card
# ✅ GREEN (<85%): Normal
# ⚠️  YELLOW (85-90%): Warning - review soon
# 🔴 RED (>90%): Critical - take action immediately

# 3. If yellow/red, run analysis:
./Tools/Automation/observability/disk_usage_analysis.sh
```

### Emergency Response

```bash
# If disk >90%, run immediate cleanup:
./Tools/Automation/observability/cleanup_agent_backups.sh --force
./Tools/Automation/observability/rotate_logs.sh
```

---

## Dashboard Monitoring

### Access Dashboard

```bash
# Option 1: Open in browser
open /Users/danielstevens/Desktop/Quantum-workspace/Tools/dashboard.html

# Option 2: Via symlink from Tools/
open Tools/dashboard.html

# Option 3: Direct HTML file
open Tools/Automation/dashboard/dashboard.html
```

### Dashboard Cards to Monitor

#### 1. **Disk Usage Card** (Top Priority)

```
┌─────────────────────┐
│ Disk Usage          │
│                     │
│   87%              │
│   warning          │
└─────────────────────┘
```

**Color Indicators:**

- 🟢 **Green** (0-84%): Healthy
- 🟡 **Yellow** (85-89%): Warning - Plan cleanup
- 🔴 **Red** (90-100%): Critical - Immediate action needed

**What to Check:**

- Current percentage
- Status label (healthy/warning/critical)
- Trend over time (increasing/stable/decreasing)

#### 2. **MCP Server Card**

```
┌─────────────────────┐
│ MCP Server          │
│                     │
│   OFFLINE          │
│   23 alerts (24h)  │
└─────────────────────┘
```

**Note:** High alert count may indicate log accumulation

#### 3. **System Health Section**

- Load average
- Uptime
- Agent health percentage

### Auto-Refresh Feature

- Dashboard auto-refreshes every 30 seconds
- Manual refresh: Click "🔄 Refresh" button
- Check browser console (Cmd+Option+J) for detailed logs

---

## Command-Line Monitoring

### Quick Disk Check

```bash
# Check workspace partition
df -h /Users/danielstevens/Desktop/Quantum-workspace

# Output:
# Filesystem    Size   Used  Avail Capacity
# /dev/disk1   460Gi  376Gi   58Gi    87%    ← Monitor this!
```

### Detailed Size Analysis

```bash
# Find largest directories
cd /Users/danielstevens/Desktop/Quantum-workspace
du -sh * | sort -hr | head -20

# Expected top consumers:
# 34G    Tools/Automation  ← If >5GB, investigate backups
# 832M   Projects/MomentumFinance
# 60M    Projects/node_modules
```

### Check Backup Directory

```bash
# Count backups (should be ≤10)
ls -1 Tools/Automation/agents/backups | wc -l

# Check backup size (should be <100MB)
du -sh Tools/Automation/agents/backups

# If count >10 or size >200MB, run cleanup
```

### Check Log Files

```bash
# Find large log files
find Tools/Automation -name "*.log*" -size +10M -exec ls -lh {} \;

# Total log size
find Tools/Automation -name "*.log*" -exec du -ch {} + | tail -1

# If >500MB, consider manual rotation
```

---

## Automated Monitoring

### Nightly Hygiene Workflow

The system automatically runs cleanup tasks daily at **00:00 UTC**:

**Jobs:**

1. **Health Check** - Validates system components
2. **Log Rotation** - Compresses and archives old logs
3. **Backup Cleanup** - Removes old backups (keeps 10 newest)
4. **Branch Cleanup** - Removes stale Git branches
5. **Artifact Cleanup** - Removes old CI/CD artifacts
6. **Daily Report** - Generates health summary

**Verify Workflow:**

```bash
# Check last workflow run
gh run list --workflow=nightly-hygiene.yml --limit 5

# View latest run details
gh run view --workflow=nightly-hygiene.yml
```

### Watchdog Monitor

Continuous monitoring script (`watchdog_monitor.sh`) checks:

- MCP server health
- Disk usage thresholds
- Agent responsiveness
- Ollama availability

**Manual Run:**

```bash
./Tools/Automation/observability/watchdog_monitor.sh
```

---

## Disk Usage Thresholds

### Warning Levels

| Level           | Threshold | Action                      | Urgency |
| --------------- | --------- | --------------------------- | ------- |
| 🟢 **Normal**   | 0-84%     | Continue monitoring         | Low     |
| 🟡 **Warning**  | 85-89%    | Review and plan cleanup     | Medium  |
| 🟠 **High**     | 90-94%    | Execute cleanup scripts     | High    |
| 🔴 **Critical** | 95-100%   | Immediate emergency cleanup | Urgent  |

### Response Times

- **Normal (0-84%):** Weekly review sufficient
- **Warning (85-89%):** Review within 24 hours, plan cleanup
- **High (90-94%):** Take action within 4 hours
- **Critical (95%+):** Immediate action required

---

## Cleanup Procedures

### Automated Cleanup (Recommended)

```bash
# Full automated cleanup sequence
./Tools/Automation/observability/cleanup_agent_backups.sh --force
./Tools/Automation/observability/rotate_logs.sh

# Verify results
df -h /Users/danielstevens/Desktop/Quantum-workspace
```

### Manual Cleanup (If Needed)

#### 1. Remove Old Backups

```bash
cd Tools/Automation/agents/backups

# List backups by age
ls -lt | head -20

# Keep 10 newest, delete rest
ls -1dt */ | tail -n +11 | xargs rm -rf

# Verify
ls -1 | wc -l  # Should show: 10
```

#### 2. Compress Large Logs

```bash
# Find logs >10MB
find Tools/Automation -name "*.log" -size +10M

# Compress them
find Tools/Automation -name "*.log" -size +10M -exec gzip {} \;
```

#### 3. Clean Build Artifacts

```bash
# Remove Xcode derived data (if safe)
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Remove node_modules (can reinstall)
find . -name "node_modules" -type d -prune -exec rm -rf {} \;
```

#### 4. Clean Git Objects

```bash
# Remove unreferenced objects
git gc --aggressive --prune=now

# Clean Git LFS cache
git lfs prune
```

---

## Monitoring Schedule

### Daily (5 minutes)

- [ ] Open dashboard, check Disk Usage card
- [ ] Verify percentage is <85%
- [ ] Check for yellow/red status indicators
- [ ] Review any alerts or warnings

### Weekly (15 minutes)

- [ ] Review disk usage trend (increasing/stable?)
- [ ] Check backup directory size
- [ ] Review log file accumulation
- [ ] Verify nightly workflow success
- [ ] Test manual cleanup scripts

### Monthly (30 minutes)

- [ ] Analyze disk usage patterns
- [ ] Review backup retention policy
- [ ] Optimize storage usage
- [ ] Update monitoring thresholds
- [ ] Document any issues/improvements

---

## Alerting Setup

### Browser Notifications (Optional)

Add to dashboard HTML for browser notifications:

```javascript
if (diskPercent > 85 && Notification.permission === "granted") {
  new Notification("⚠️ Disk Usage Warning", {
    body: `Disk usage at ${diskPercent}%`,
    icon: "/path/to/icon.png",
  });
}
```

### Slack Integration (Future)

```bash
# In watchdog_monitor.sh, add:
if [[ $disk_percent -gt 85 ]]; then
  curl -X POST $SLACK_WEBHOOK \
    -d "{\"text\": \"⚠️ Disk usage: ${disk_percent}%\"}"
fi
```

### Email Alerts (Future)

```bash
# Configure mail command
if [[ $disk_percent -gt 90 ]]; then
  echo "Disk usage critical: ${disk_percent}%" | \
    mail -s "🚨 Disk Alert" admin@example.com
fi
```

---

## Troubleshooting

### Dashboard Shows Old Data

```bash
# Regenerate dashboard data
./Tools/Automation/dashboard/generate_dashboard_data.sh

# Verify update time
cat Tools/dashboard_data.json | jq '.generated_at'

# Force browser refresh: Cmd+Shift+R (Chrome/Safari)
```

### Dashboard Shows "Data Unavailable"

```bash
# Check if data file exists
ls -lh Tools/dashboard_data.json

# Check file permissions
chmod 644 Tools/dashboard_data.json

# Regenerate data
./Tools/Automation/dashboard/generate_dashboard_data.sh

# Check browser console for errors (Cmd+Option+J)
```

### Disk Usage Not Decreasing After Cleanup

```bash
# Wait 5-10 minutes for filesystem to update
sleep 300 && df -h

# Check if files are actually deleted
ls -lh Tools/Automation/agents/backups

# Check for open file handles
lsof | grep deleted
```

### Backup Count Still >10 After Cleanup

```bash
# Verify cleanup script ran
cat Tools/Automation/logs/backup_cleanup_*.log | tail -50

# Run cleanup manually with verbose output
./Tools/Automation/observability/cleanup_agent_backups.sh --force 2>&1 | tee cleanup.log

# Check for errors in log
grep -i error cleanup.log
```

---

## Best Practices

### Do's ✅

- Check dashboard daily (2 min habit)
- Respond to warnings within 24 hours
- Keep backups count at ≤10
- Monitor trends, not just snapshots
- Test cleanup scripts regularly
- Document any manual interventions
- Review weekly for patterns

### Don'ts ❌

- Don't ignore yellow/red warnings
- Don't delete backups without verification
- Don't disable automated cleanup
- Don't skip weekly reviews
- Don't delete logs needed for debugging
- Don't modify cleanup scripts without testing
- Don't rely only on automated monitoring

---

## Quick Commands Reference

```bash
# Check disk
df -h /Users/danielstevens/Desktop/Quantum-workspace

# Open dashboard
open Tools/dashboard.html

# Regenerate data
./Tools/Automation/dashboard/generate_dashboard_data.sh

# Run cleanup
./Tools/Automation/observability/cleanup_agent_backups.sh --force

# Rotate logs
./Tools/Automation/observability/rotate_logs.sh

# Check backups
ls -1 Tools/Automation/agents/backups | wc -l

# Backup size
du -sh Tools/Automation/agents/backups

# Large files
du -sh * | sort -hr | head -20

# Workflow status
gh run list --workflow=nightly-hygiene.yml --limit 5
```

---

## Escalation Path

### Level 1: Normal Monitoring

- **Who:** Any team member
- **Frequency:** Daily
- **Action:** Check dashboard, note status
- **Escalate if:** Disk >85%

### Level 2: Warning Response

- **Who:** Developer/DevOps
- **Frequency:** When warned
- **Action:** Run analysis, plan cleanup
- **Escalate if:** Disk >90%

### Level 3: Critical Response

- **Who:** Senior DevOps/Admin
- **Frequency:** When critical
- **Action:** Immediate cleanup, investigation
- **Escalate if:** Disk >95% or cleanup fails

### Level 4: Emergency Response

- **Who:** System Administrator
- **Frequency:** When emergency
- **Action:** Manual intervention, service management
- **Document:** Full incident report required

---

## Related Documentation

- **Cleanup Report:** `DISK_CLEANUP_REPORT_20251006.md`
- **Backup Investigation:** `BACKUP_FREQUENCY_INVESTIGATION_20251006.md`
- **Completion Summary:** `CLEANUP_COMPLETION_SUMMARY_20251006.md`
- **Cleanup Script:** `Tools/Automation/observability/cleanup_agent_backups.sh`
- **Nightly Workflow:** `.github/workflows/nightly-hygiene.yml`

---

## Support Contacts

- **Dashboard Issues:** Check browser console, regenerate data
- **Cleanup Script Issues:** Review logs in `Tools/Automation/logs/`
- **Workflow Issues:** Check GitHub Actions workflow runs
- **Emergency:** Run manual cleanup scripts immediately

---

**Document Owner:** DevOps Team  
**Last Updated:** October 6, 2025  
**Review Cycle:** Monthly  
**Status:** ✅ Active
