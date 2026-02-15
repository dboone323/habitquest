#!/usr/bin/env python3
"""
Create or Update Repository Analytics Issue
"""

import os
import json
from datetime import datetime
from github import Github

def create_or_update_issue(g, repo_name, org_name, report):
    """Create or update analytics issue"""
    repo = g.get_repo(f"{org_name}/{repo_name}")

    title = f"📊 Repository Analytics Report - {datetime.now().strftime('%Y-%m-%d')}"

    # Check if issue already exists
    existing_issues = repo.get_issues(state='open', labels=['analytics'])
    analytics_issue = None

    for issue in existing_issues:
        if 'Analytics Report' in issue.title:
            analytics_issue = issue
            break

    # Generate issue body
    body = generate_issue_body(report)

    if analytics_issue:
        # Update existing issue
        analytics_issue.edit(body=body)
        print(f"Updated analytics issue: {analytics_issue.html_url}")
    else:
        # Create new issue
        issue = repo.create_issue(
            title=title,
            body=body,
            labels=['analytics', 'automated']
        )
        print(f"Created analytics issue: {issue.html_url}")

def generate_issue_body(report):
    """Generate formatted issue body"""
    repo_info = report['repository_info']
    activity = report['activity_metrics']
    workflow = report['workflow_metrics']

    body = f"""# 📊 Repository Analytics Report

**Generated:** {report['generated_at']}
**Health Score:** {report['health_score']}/100

## Repository Overview
- **Stars:** {repo_info['stars']}
- **Forks:** {repo_info['forks']}
- **Open Issues:** {repo_info['open_issues']}
- **Watchers:** {repo_info['watchers']}
- **Primary Language:** {repo_info['language'] or 'Not specified'}
- **Size:** {repo_info['size']} KB

## Activity Metrics (Last 30 Days)
- **Commits:** {activity['commits_last_30_days']}
- **Pull Requests:** {activity['prs_last_30_days']}
- **Issues Created:** {activity['issues_last_30_days']}
- **Average Commits/Day:** {activity['avg_commits_per_day']:.1f}
- **PR Merge Rate:** {activity['pr_merge_rate']:.1%}

## Workflow Metrics
- **Total Runs:** {workflow['total_workflow_runs']}
- **Successful Runs:** {workflow['successful_runs']}
- **Failed Runs:** {workflow['failed_runs']}
- **Success Rate:** {workflow['workflow_success_rate']:.1%}

## Health Assessment

"""

    # Add health assessment
    score = report['health_score']
    if score >= 80:
        body += "🟢 **Excellent Health** - Repository is well-maintained and active.\n"
    elif score >= 60:
        body += "🟡 **Good Health** - Repository is moderately active with room for improvement.\n"
    elif score >= 40:
        body += "🟠 **Fair Health** - Repository needs attention to improve activity and reliability.\n"
    else:
        body += "🔴 **Poor Health** - Repository requires significant improvements.\n"

    body += "\n---\n*This report is automatically generated daily by GitHub Actions.*"

    return body

def main():
    repo_name = os.getenv('GITHUB_REPOSITORY', '').split('/')[-1]
    org_name = os.getenv('GITHUB_REPOSITORY', '').split('/')[0]
    token = os.getenv('GITHUB_TOKEN')

    if not token:
        print("Error: GITHUB_TOKEN environment variable is required")
        return

    try:
        with open('analytics-report.json', 'r') as f:
            report = json.load(f)

        g = Github(token)
        create_or_update_issue(g, repo_name, org_name, report)

    except Exception as e:
        print(f"Error creating analytics issue: {e}")
        exit(1)

if __name__ == '__main__':
    main()
