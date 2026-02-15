#!/usr/bin/env python3
"""
Automated Release Notes Generator for Phase 3
Generates comprehensive release notes from PRs and commits
"""

import os
import requests
from datetime import datetime, timedelta

def generate_release_notes():
    """Generate release notes from recent activity"""
    token = os.getenv('GITHUB_TOKEN')
    repo = os.getenv('GITHUB_REPOSITORY')

    if not token or not repo:
        print("GitHub token or repository not configured")
        return

    # Get recent PRs
    url = f"https://api.github.com/repos/{repo}/pulls"
    headers = {'Authorization': f'token {token}'}
    params = {'state': 'closed', 'sort': 'updated', 'direction': 'desc', 'per_page': 20}

    response = requests.get(url, headers=headers, params=params)
    prs = response.json()

    notes = f"# 🚀 Release Notes - {datetime.now().strftime('%Y-%m-%d')}\n\n"

    features = []
    fixes = []
    other = []

    for pr in prs:
        if not pr.get('merged_at'):
            continue

        title = pr['title']
        number = pr['number']
        labels = [label['name'] for label in pr.get('labels', [])]

        line = f"- {title} (#{number})"

        if 'enhancement' in labels or 'feature' in labels:
            features.append(line)
        elif 'bug' in labels or 'fix' in labels:
            fixes.append(line)
        else:
            other.append(line)

    if features:
        notes += "## ✨ New Features\n"
        notes += '\n'.join(features) + '\n\n'

    if fixes:
        notes += "## 🐛 Bug Fixes\n"
        notes += '\n'.join(fixes) + '\n\n'

    if other:
        notes += "## 🔧 Other Changes\n"
        notes += '\n'.join(other) + '\n\n'

    notes += "---\n*Generated automatically by AI Release Notes Generator*"

    print(notes)

if __name__ == "__main__":
    generate_release_notes()
