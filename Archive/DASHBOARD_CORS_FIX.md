# Dashboard CORS Fix - Quick Reference

## The Problem

**Error:** `Cross origin requests are only supported for HTTP`  
**Cause:** Browsers block `fetch()` requests to local `file://` URLs for security reasons.

---

## ✅ Solution 1: Standalone Dashboard (Easiest)

**No server required! Data embedded directly in HTML.**

```bash
# Generate standalone dashboard
./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open

# Or manually:
cd /Users/danielstevens/Desktop/Quantum-workspace
./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open
```

**File:** `Tools/dashboard_standalone.html`

**Pros:**

- ✅ No server needed
- ✅ Works immediately
- ✅ No CORS issues
- ✅ Can email/share file

**Cons:**

- ⚠️ Must regenerate to refresh data
- ⚠️ No auto-refresh (reload page instead)

---

## ✅ Solution 2: Local HTTP Server (Best for Development)

### Option A: Custom Server Script (Easiest)

```bash
./Tools/Automation/dashboard/serve_dashboard.sh
# Opens http://localhost:8080/Tools/Automation/dashboard/dashboard.html
# Press Ctrl+C to stop
```

### Option B: Python HTTP Server

```bash
# From workspace root
cd /Users/danielstevens/Desktop/Quantum-workspace
python3 -m http.server 8080

# Then open:
open http://localhost:8080/Tools/Automation/dashboard/dashboard.html
```

### Option C: VS Code Live Server

1. Install "Live Server" extension in VS Code
2. Right-click `dashboard.html` → "Open with Live Server"
3. Dashboard opens at `http://127.0.0.1:5500/...`

**Pros:**

- ✅ Auto-refresh works
- ✅ Live data updates
- ✅ Full dashboard features
- ✅ Network accessible

**Cons:**

- ⚠️ Requires server running
- ⚠️ Must stop/start server

---

## Quick Command Comparison

| Task               | Command                                                                                                | Opens In                        |
| ------------------ | ------------------------------------------------------------------------------------------------------ | ------------------------------- |
| **Standalone**     | `./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open`                                 | Browser (file://)               |
| **Serve (custom)** | `./Tools/Automation/dashboard/serve_dashboard.sh`                                                      | Browser (http://localhost:8080) |
| **Serve (Python)** | `python3 -m http.server 8080` → `open http://localhost:8080/Tools/Automation/dashboard/dashboard.html` | Browser (http://localhost:8080) |
| **VS Code**        | Right-click → "Open with Live Server"                                                                  | Browser (http://127.0.0.1:5500) |

---

## Which Solution Should I Use?

### Use **Standalone** if:

- ✅ Quick one-time view
- ✅ Sharing dashboard with others
- ✅ Don't want to run server
- ✅ Don't need auto-refresh

### Use **HTTP Server** if:

- ✅ Active development
- ✅ Need auto-refresh every 30s
- ✅ Want live data updates
- ✅ Multiple people viewing

---

## Daily Workflow

### Option 1: Standalone (Simplest)

```bash
# Morning routine:
./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open

# Check dashboard in browser
# Close when done

# To refresh data later:
./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open
```

### Option 2: HTTP Server (Development)

```bash
# Start server once:
./Tools/Automation/dashboard/serve_dashboard.sh

# Dashboard opens automatically
# Leave terminal running
# Auto-refreshes every 30 seconds

# When done: Ctrl+C to stop server
```

---

## Updating Dashboard Data

### For Standalone Dashboard:

```bash
# Regenerate data AND dashboard
./Tools/Automation/dashboard/generate_dashboard_data.sh
./Tools/Automation/dashboard/generate_standalone_dashboard.sh

# Then reload browser (Cmd+R)
```

### For HTTP Server Dashboard:

```bash
# Just regenerate data (auto-refreshes in 30s)
./Tools/Automation/dashboard/generate_dashboard_data.sh

# Or force refresh in browser (Cmd+Shift+R)
```

---

## Troubleshooting

### Problem: "CORS Error" in console

**Solution:** Use standalone dashboard OR serve over HTTP

### Problem: Standalone dashboard shows old data

**Solution:** Regenerate standalone dashboard

```bash
./Tools/Automation/dashboard/generate_standalone_dashboard.sh
# Then reload browser
```

### Problem: HTTP server port 8080 already in use

**Solution:** Use different port

```bash
python3 -m http.server 8081
# Then open http://localhost:8081/Tools/Automation/dashboard/dashboard.html
```

### Problem: serve_dashboard.sh not found

**Solution:** Make it executable

```bash
chmod +x Tools/Automation/dashboard/serve_dashboard.sh
./Tools/Automation/dashboard/serve_dashboard.sh
```

---

## What Changed?

### Before (Broken)

```bash
# This doesn't work:
open Tools/dashboard.html
# Error: CORS - fetch blocked on file:// URLs
```

### After (Fixed)

```bash
# Option 1: Standalone (no server)
./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open

# Option 2: HTTP server (with auto-refresh)
./Tools/Automation/dashboard/serve_dashboard.sh
```

---

## Files Created

1. ✅ `Tools/Automation/dashboard/serve_dashboard.sh`

   - Starts local HTTP server on port 8080
   - Auto-opens dashboard in browser

2. ✅ `Tools/Automation/dashboard/generate_standalone_dashboard.sh`

   - Generates `Tools/dashboard_standalone.html`
   - Embeds data directly (no CORS)

3. ✅ `Tools/dashboard_standalone.html`

   - Standalone version with embedded data
   - No server required
   - No CORS issues

4. ✅ `DASHBOARD_CORS_FIX.md` (this file)
   - Quick reference guide
   - Solution comparison

---

## Recommendations

### For Daily Monitoring:

**Use standalone dashboard** - Simplest, no server needed

```bash
# Add to daily routine:
./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open
```

### For Active Development:

**Use HTTP server** - Best experience with auto-refresh

```bash
# Start once, leave running:
./Tools/Automation/dashboard/serve_dashboard.sh
```

### For Team Sharing:

**Use standalone dashboard** - Can email HTML file

```bash
# Generate and share:
./Tools/Automation/dashboard/generate_standalone_dashboard.sh
# Share file: Tools/dashboard_standalone.html
```

---

## Automated Integration

### Update Monitoring Guide

The `DISK_MONITORING_GUIDE.md` should reference standalone dashboard:

```bash
# Quick Check
./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open
```

### Nightly Workflow

Consider adding standalone dashboard generation to nightly workflow:

```yaml
- name: Generate Standalone Dashboard
  run: |
    ./Tools/Automation/dashboard/generate_dashboard_data.sh
    ./Tools/Automation/dashboard/generate_standalone_dashboard.sh
    # Commit to repo for easy access
```

---

## Summary

**Problem:** CORS errors when opening `dashboard.html` as file  
**Root Cause:** Browsers block fetch() on file:// URLs  
**Solution 1:** Standalone dashboard with embedded data ✅  
**Solution 2:** Serve over HTTP (Python server) ✅  
**Recommended:** Use standalone for daily monitoring

**Quick Start:**

```bash
./Tools/Automation/dashboard/generate_standalone_dashboard.sh --open
```

Done! 🎉
