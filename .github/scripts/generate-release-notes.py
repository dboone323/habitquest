#!/usr/bin/env python3
"""
Automated Release Notes Generator for Phase 3
Generates comprehensive release notes from PRs and commits
"""

import os
import re
import requests
from datetime import datetime, timedelta

def generate_release_notes():
    """Generate release notes from recent activity"""
    token = os.getenv('GITHUB_TOKEN')
    repo = os.getenv('GITHUB_REPOSITORY')

    if not token or not repo:
        print("GitHub token or repository not configured")
        return

    # Validate repository name format
    if not re.match(r'^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$', repo):
        print(f"Invalid repository name format: {repo}")
        return

    # Get recent PRs with timeout and validation
    url = f"https://api.github.com/repos/{repo}/pulls"
    headers = {
        'Authorization': f'token {token}',
        'User-Agent': 'Release-Notes-Generator/1.0'
    }
    params = {'state': 'closed', 'sort': 'updated', 'direction': 'desc', 'per_page': 20}

    try:
        response = requests.get(url, headers=headers, params=params, timeout=30, allow_redirects=False)
        response.raise_for_status()
        prs = response.json()
    except requests.RequestException as e:
        print(f"Error fetching PRs: {e}")
        return

    notes = f"# 🚀 Release Notes - {datetime.now().strftime('%Y-%m-%d')}\n\n"

    features = []
    fixes = []
    other = []

    for pr in prs:
        if not isinstance(pr, dict) or not pr.get('merged_at'):
            continue

        title = pr.get('title', '')
        if not isinstance(title, str) or len(title) > 200:  # Reasonable title limit
            continue

        number = pr.get('number', '')
        if not isinstance(number, int):
            continue

        labels = pr.get('labels', [])
        if not isinstance(labels, list):
            continue

        label_names = []
        for label in labels:
            if isinstance(label, dict) and 'name' in label:
                label_name = label['name']
                if isinstance(label_name, str):
                    label_names.append(label_name)

        line = f"- {title} (#{number})"

        if any(label in ['enhancement', 'feature'] for label in label_names):
            features.append(line)
        elif any(label in ['bug', 'fix'] for label in label_names):
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
    try:
        generate_release_notes()
    except Exception as e:
        print(f"Error generating release notes: {e}")
        exit(1)
