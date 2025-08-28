#!/usr/bin/env python3
"""Simple workflow monitor that listens for repository_dispatch-like payloads
or polls the GitHub Actions API for failed runs and forwards alerts to the MCP
server so agents can take action automatically.

Usage:
  export GITHUB_TOKEN=...
  export MCP_URL=http://127.0.0.1:5005
  python Automation/github_workflow_monitor.py
"""
import os
import time
import requests

GITHUB_OWNER = os.getenv('GITHUB_OWNER', 'dboone323')
GITHUB_REPO = os.getenv('GITHUB_REPO', 'Quantum-workspace')
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
MCP_URL = os.getenv('MCP_URL', 'http://127.0.0.1:5005')

HEADERS = {'Authorization': f'token {GITHUB_TOKEN}'} if GITHUB_TOKEN else {}


def fetch_recent_workflow_runs(status='failure'):
    url = f'https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/actions/runs'
    params = {'per_page': 10}
    r = requests.get(url, headers=HEADERS, params=params, timeout=15)
    r.raise_for_status()
    runs = r.json().get('workflow_runs', [])
    return [r for r in runs if r.get('conclusion') != 'success']


def notify_mcp(run):
    payload = {
        'workflow': run.get('name'),
        'conclusion': run.get('conclusion'),
        'url': run.get('html_url'),
        'head_branch': run.get('head_branch'),
        'run_id': run.get('id'),
    }
    try:
        r = requests.post(f'{MCP_URL}/workflow_alert', json=payload, timeout=10)
        print('notified mcp:', r.status_code)
    except Exception as e:
        print('failed to notify mcp', e)


def main(poll_interval=60):
    seen = set()
    while True:
        try:
            runs = fetch_recent_workflow_runs()
            for run in runs:
                rid = run.get('id')
                if rid in seen:
                    continue
                seen.add(rid)
                print('found failed run:', run.get('name'), run.get('html_url'))
                notify_mcp(run)
        except Exception as e:
            print('monitor error:', e)
        time.sleep(poll_interval)


if __name__ == '__main__':
    interval = int(os.getenv('MONITOR_POLL_INTERVAL', '60'))
    main(interval)
