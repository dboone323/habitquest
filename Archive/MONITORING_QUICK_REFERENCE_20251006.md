# Monitoring Quick Reference Guide

**Date:** October 6, 2025  
**Purpose:** Quick reference for monitoring all 8 new implementations

---

## 📊 Daily Monitoring Checklist

### Morning Check (5 minutes)

```bash
# 1. Check GitHub Actions for overnight runs
open https://github.com/dboone323/Quantum-workspace/actions

# 2. Check backup frequency (should be <20/day)
ls -lt Shared/Tools/Automation/backups/ | head -20

# 3. Check for SwiftLint commits (after tomorrow)
git log --oneline --grep="SwiftLint" --since="1 day ago"

# 4. Check metrics directory size
du -sh Tools/Automation/observability/snapshots/
```

### Weekly Check (10 minutes)

```bash
# 1. Review weekly health report (Sundays after 02:00 UTC)
cat Tools/Automation/reports/weekly_health_*.md | tail -100

# 2. Check workflow health report
cat Tools/Automation/reports/workflow_health_*.md | tail -100

# 3. Verify backup compression stats
grep "Compression complete" .github/workflows/logs/*.log

# 4. Check for any CRITICAL issues in GitHub
open https://github.com/dboone323/Quantum-workspace/issues?q=is:issue+is:open+label:CRITICAL
```

---

## 🎯 Key Metrics to Track

### Backup Health

| Metric            | Target       | Current       | Status               |
| ----------------- | ------------ | ------------- | -------------------- |
| Daily Backups     | <20          | 608 (before)  | ⏳ Monitor           |
| Backup Size       | <2GB/week    | 34GB (before) | ⏳ Monitor           |
| Compression Ratio | >50% savings | TBD           | ⏳ First run tonight |
| Oldest Backup     | <7 days      | TBD           | ✅ Automated         |

### Code Quality

| Metric                | Target | Current     | Status                |
| --------------------- | ------ | ----------- | --------------------- |
| SwiftLint Warnings    | 0      | 68 (before) | ⏳ First run tomorrow |
| Auto-fix Success Rate | >90%   | TBD         | ⏳ Monitor            |
| Daily Lint Commits    | 0-2    | TBD         | ⏳ Monitor            |

### Disk Usage

| Metric              | Target     | Current       | Status       |
| ------------------- | ---------- | ------------- | ------------ |
| Backups Directory   | <5GB       | 34GB (before) | ⏳ Monitor   |
| Metrics Directory   | <1GB       | ~500MB        | ⏳ Monitor   |
| Compression Savings | >20GB/week | TBD           | ⏳ Calculate |

### System Health

| Metric            | Target | Current | Status     |
| ----------------- | ------ | ------- | ---------- |
| Workflow Failures | 0      | TBD     | ⏳ Monitor |
| Critical Issues   | 0      | 0       | ✅ Good    |
| Response Time     | <24h   | TBD     | ⏳ Monitor |

---

## 📅 Scheduled Execution Times

### Daily (Automated)

- **00:00 UTC** - Nightly hygiene workflow

  - Backup cleanup (keep last 7 days)
  - Backup compression (files >24h old)
  - Metrics cleanup (files >90 days old)
  - Log rotation

- **01:00 UTC** - SwiftLint auto-fix
  - Scan all Swift files
  - Auto-fix violations
  - Commit changes if any

### Weekly (Automated)

- **Sunday 02:00 UTC** - Weekly health check
  - Comprehensive system analysis
  - GitHub issue creation for CRITICAL problems
  - Health report generation

### On-Demand (Manual)

```bash
# Run workflow health monitor manually
./Tools/Automation/observability/workflow_health_monitor.sh

# Run weekly health check manually
./Tools/Automation/observability/weekly_health_check.sh

# Run metrics cleanup manually
./Tools/Automation/observability/cleanup_old_metrics.sh

# Run backup compression manually
./Tools/Automation/observability/compress_old_backups.sh
```

---

## 🔍 Where to Find Results

### GitHub Actions Logs

```
https://github.com/dboone323/Quantum-workspace/actions

Key Workflows:
- nightly-hygiene (daily at 00:00 UTC)
- swiftlint-auto-fix (daily at 01:00 UTC)
- weekly-health-check (Sunday at 02:00 UTC)
```

### Local Report Files

```bash
# Weekly health reports
Tools/Automation/reports/weekly_health_YYYYMMDD.md

# Workflow health reports
Tools/Automation/reports/workflow_health_YYYYMMDD.md

# Metrics snapshots
Tools/Automation/observability/snapshots/metrics_*.json

# Backup directory
Shared/Tools/Automation/backups/
```

### GitHub Issues

```
https://github.com/dboone323/Quantum-workspace/issues

Labels to watch:
- CRITICAL (auto-created by weekly health check)
- automation
- infrastructure
- code-quality
```

---

## 🚨 Alert Conditions & Responses

### CRITICAL Alerts (Immediate Action)

#### 1. Backup Explosion Returns (>50 backups/day)

**Symptoms:**

- Backups directory growing rapidly
- Multiple backups within minutes

**Immediate Actions:**

```bash
# 1. Check deduplication is working
grep "Skipping backup" Shared/Tools/Automation/ai_enhancement_system.sh

# 2. Check last backup timestamp
ls -lt Shared/Tools/Automation/backups/ | head -5

# 3. Verify cooldown period
grep "BACKUP_COOLDOWN" Shared/Tools/Automation/ai_enhancement_system.sh
```

**Resolution:**

- Should self-correct with 1-hour cooldown
- If not, check for infinite loops in automation scripts
- Review BACKUP_FREQUENCY_INVESTIGATION_20251006.md

#### 2. Disk Space <10GB

**Symptoms:**

- Low disk space warnings
- Backup compression failing
- Metrics cleanup failing

**Immediate Actions:**

```bash
# 1. Check disk usage
df -h

# 2. Find largest directories
du -sh */ | sort -rh | head -10

# 3. Manual cleanup if needed
./Tools/Automation/observability/compress_old_backups.sh
./Tools/Automation/observability/cleanup_old_metrics.sh
```

**Resolution:**

- Run manual compression/cleanup
- Verify automated cleanup is working
- Check for unexpected large files

#### 3. Workflow Failures (3+ consecutive)

**Symptoms:**

- Multiple failed workflow runs
- No successful runs in 24h

**Immediate Actions:**

```bash
# 1. Check workflow status
gh run list --limit 10

# 2. View failure logs
gh run view <run-id> --log-failed

# 3. Check for common issues
grep "error\|failed\|fatal" .github/workflows/*.yml
```

**Resolution:**

- Review error logs for root cause
- Check for dependency issues
- Verify GitHub Actions quota not exceeded

### WARNING Alerts (Monitor Closely)

#### 1. Backup Frequency 20-50/day

- Monitor for increasing trend
- Review backup deduplication logic
- Check for new automation scripts creating backups

#### 2. Metrics Directory >2GB

- Verify cleanup_old_metrics.sh running
- Check retention period (90 days default)
- Consider reducing retention if needed

#### 3. SwiftLint Auto-fix Commits >5/day

- May indicate new code quality issues
- Review what's being auto-fixed
- Consider updating SwiftLint rules

---

## 📈 Success Indicators (Week 1)

### By October 13, 2025, we should see:

✅ **Backup System:**

- Daily backup count: <20 (down from 608)
- Backups directory size: <5GB (down from 34GB)
- Compression ratio: >50% for old backups
- No manual intervention needed

✅ **Code Quality:**

- SwiftLint warnings: 0 (down from 68)
- Daily auto-fix commits: 0-2
- No build failures from lint issues

✅ **Disk Management:**

- No disk space alerts
- Metrics directory: <1GB
- Backup compression working automatically

✅ **Monitoring:**

- Weekly health reports generating
- Workflow health reports generating
- GitHub issues created for CRITICAL items only
- No workflow failures

---

## 🛠️ Troubleshooting Commands

### Debug Backup Issues

```bash
# Check backup deduplication logic
cat Shared/Tools/Automation/ai_enhancement_system.sh | grep -A 20 "should_create_backup"

# List recent backups with timestamps
ls -lth Shared/Tools/Automation/backups/ | head -20

# Check backup file sizes
du -h Shared/Tools/Automation/backups/*.tar.gz | sort -rh

# Verify compression is working
file Shared/Tools/Automation/backups/*.tar.gz
```

### Debug Workflow Issues

```bash
# Check workflow syntax
actionlint .github/workflows/*.yml

# View recent workflow runs
gh run list --workflow=nightly-hygiene.yml --limit 10

# Check workflow triggers
grep -r "on:" .github/workflows/*.yml

# View workflow logs
gh run view --log
```

### Debug Metrics Issues

```bash
# Check metrics directory
ls -lth Tools/Automation/observability/snapshots/ | head -20

# Verify cleanup script
bash -n Tools/Automation/observability/cleanup_old_metrics.sh

# Run cleanup in dry-run mode
# (modify script to add --dry-run flag if needed)

# Check metrics file sizes
du -sh Tools/Automation/observability/snapshots/*
```

### Debug SwiftLint Issues

```bash
# Check SwiftLint configuration
cat .swiftlint.yml

# Run SwiftLint manually
swiftlint lint --strict

# Check auto-fixable issues
swiftlint lint --fix --format

# View SwiftLint version
swiftlint version
```

---

## 📞 Support & Documentation

### Implementation Documentation

- **IMPLEMENTATION_SUMMARY_20251006.md** - Phase 1 details
- **IMPLEMENTATION_COMPLETE_20251006.md** - Phase 1 executive summary
- **ADDITIONAL_IMPROVEMENTS_PLAN_20251006.md** - Phase 2 planning & status
- **COMPLETE_IMPLEMENTATION_SUMMARY_20251006.md** - Comprehensive all-phases summary
- **MONITORING_QUICK_REFERENCE_20251006.md** - This file

### Root Cause Analysis

- **BACKUP_FREQUENCY_INVESTIGATION_20251006.md** - Original problem analysis

### Automation Scripts

- **compress_old_backups.sh** - Backup compression automation
- **cleanup_old_metrics.sh** - Metrics retention policy
- **weekly_health_check.sh** - Weekly health monitoring
- **workflow_health_monitor.sh** - Workflow analysis

### Workflows

- **.github/workflows/nightly-hygiene.yml** - Daily maintenance
- **.github/workflows/swiftlint-auto-fix.yml** - Daily lint fixing
- **.github/workflows/weekly-health-check.yml** - Weekly reporting

---

## 🎯 Next Steps

### This Week (October 7-13, 2025)

- [ ] Monitor first backup compression run (tonight)
- [ ] Monitor first metrics cleanup run (tonight)
- [ ] Monitor first SwiftLint auto-fix run (tomorrow)
- [ ] Monitor first weekly health report (Sunday)
- [ ] Validate backup frequency reduction
- [ ] Verify compression effectiveness
- [ ] Check for any unexpected issues

### Week 2 (October 14-20, 2025)

- [ ] Review Week 1 metrics
- [ ] Fine-tune alert thresholds if needed
- [ ] Create workflow consolidation analysis
- [ ] Document baseline performance metrics
- [ ] Plan Phase 3 enhancements

### Week 3-4 (October 21 - November 3, 2025)

- [ ] Implement workflow consolidation (if needed)
- [ ] Add dashboard trend visualization
- [ ] Consider performance regression detection
- [ ] Evaluate Phase 3 priorities
- [ ] Plan long-term improvements

---

**Last Updated:** October 6, 2025  
**Next Review:** October 13, 2025  
**Status:** ✅ All implementations complete and monitoring active
