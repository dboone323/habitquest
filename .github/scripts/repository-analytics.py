#!/usr/bin/env python3
"""
Repository Analytics Script
Generates comprehensive analytics for repository health and activity
"""

import os
import json
import requests
from datetime import datetime, timedelta
from github import Github
import pandas as pd

def get_github_client():
    token = os.getenv('GITHUB_TOKEN')
    if not token:
        raise ValueError("GITHUB_TOKEN environment variable is required")
    return Github(token)

def get_repository_info(g, repo_name, org_name):
    """Get basic repository information"""
    repo = g.get_repo(f"{org_name}/{repo_name}")

    return {
        'name': repo.name,
        'stars': repo.stargazers_count,
        'forks': repo.forks_count,
        'open_issues': repo.open_issues_count,
        'watchers': repo.watchers_count,
        'language': repo.language,
        'created_at': repo.created_at.isoformat(),
        'updated_at': repo.updated_at.isoformat(),
        'size': repo.size
    }

def get_recent_activity(g, repo_name, org_name, days=30):
    """Get recent repository activity"""
    repo = g.get_repo(f"{org_name}/{repo_name}")
    since = datetime.now() - timedelta(days=days)

    # Get recent commits
    commits = list(repo.get_commits(since=since))
    commit_count = len(commits)

    # Get recent pull requests
    prs = list(repo.get_pulls(state='all', sort='created', direction='desc'))
    recent_prs = [pr for pr in prs if pr.created_at > since]

    # Get recent issues
    issues = list(repo.get_issues(state='all', since=since))

    return {
        'commits_last_30_days': commit_count,
        'prs_last_30_days': len(recent_prs),
        'issues_last_30_days': len(issues),
        'avg_commits_per_day': commit_count / days,
        'pr_merge_rate': len([pr for pr in recent_prs if pr.merged]) / len(recent_prs) if recent_prs else 0
    }

def get_workflow_metrics(repo_name, org_name):
    """Get GitHub Actions workflow metrics"""
    token = os.getenv('GITHUB_TOKEN')
    headers = {'Authorization': f'token {token}'}

    # Get workflow runs
    url = f"https://api.github.com/repos/{org_name}/{repo_name}/actions/runs"
    response = requests.get(url, headers=headers)
    runs = response.json().get('workflow_runs', [])

    total_runs = len(runs)
    successful_runs = len([r for r in runs if r['conclusion'] == 'success'])
    failed_runs = len([r for r in runs if r['conclusion'] == 'failure'])

    success_rate = successful_runs / total_runs if total_runs > 0 else 0

    return {
        'total_workflow_runs': total_runs,
        'successful_runs': successful_runs,
        'failed_runs': failed_runs,
        'workflow_success_rate': success_rate
    }

def generate_report(repo_name, org_name):
    """Generate comprehensive analytics report"""
    g = get_github_client()

    report = {
        'generated_at': datetime.now().isoformat(),
        'repository': repo_name,
        'organization': org_name,
        'repository_info': get_repository_info(g, repo_name, org_name),
        'activity_metrics': get_recent_activity(g, repo_name, org_name),
        'workflow_metrics': get_workflow_metrics(repo_name, org_name)
    }

    # Calculate health score
    health_score = calculate_health_score(report)
    report['health_score'] = health_score

    return report

def calculate_health_score(report):
    """Calculate repository health score (0-100)"""
    score = 0

    # Activity score (30 points)
    activity = report['activity_metrics']
    if activity['commits_last_30_days'] > 0:
        score += 15
    if activity['prs_last_30_days'] > 0:
        score += 10
    if activity['pr_merge_rate'] > 0.5:
        score += 5

    # Workflow score (40 points)
    workflow = report['workflow_metrics']
    if workflow['workflow_success_rate'] > 0.8:
        score += 40
    elif workflow['workflow_success_rate'] > 0.6:
        score += 30
    elif workflow['workflow_success_rate'] > 0.4:
        score += 20
    else:
        score += 10

    # Repository metrics (30 points)
    repo_info = report['repository_info']
    if repo_info['stars'] > 0:
        score += 10
    if repo_info['open_issues'] < 50:
        score += 10
    if repo_info['watchers'] > 0:
        score += 10

    return min(score, 100)

def main():
    repo_name = os.getenv('GITHUB_REPOSITORY', '').split('/')[-1]
    org_name = os.getenv('GITHUB_REPOSITORY', '').split('/')[0]

    if not repo_name or not org_name:
        print("Error: Unable to determine repository and organization from environment")
        return

    try:
        report = generate_report(repo_name, org_name)

        # Save report to file
        with open('analytics-report.json', 'w') as f:
            json.dump(report, f, indent=2)

        print(f"Analytics report generated for {org_name}/{repo_name}")
        print(f"Health Score: {report['health_score']}/100")

    except Exception as e:
        print(f"Error generating analytics report: {e}")
        exit(1)

if __name__ == '__main__':
    main()
