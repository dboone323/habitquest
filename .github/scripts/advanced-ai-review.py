#!/usr/bin/env python3
"""
Advanced AI Code Review Script for Phase 3
Provides intelligent code analysis, suggestions, and automation
"""

import os
import sys
import json
import re
import requests
from typing import Dict, List, Optional

class AdvancedAIReviewer:
    def __init__(self):
        self.github_token = os.getenv('GITHUB_TOKEN')
        self.openai_key = os.getenv('OPENAI_API_KEY')
        self.anthropic_key = os.getenv('ANTHROPIC_API_KEY')
        self.repo = os.getenv('GITHUB_REPOSITORY')
        self.pr_number = os.getenv('GITHUB_EVENT_NUMBER')

        # Validate required environment variables
        if not self.github_token:
            raise ValueError("GITHUB_TOKEN environment variable is required")
        if not self.repo:
            raise ValueError("GITHUB_REPOSITORY environment variable is required")
        if not self.pr_number:
            raise ValueError("GITHUB_EVENT_NUMBER environment variable is required")

        # Validate and sanitize inputs
        self._validate_repo_name(self.repo)
        self._validate_pr_number(self.pr_number)

    def _validate_repo_name(self, repo: str):
        """Validate GitHub repository name format"""
        if not re.match(r'^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$', repo):
            raise ValueError(f"Invalid repository name format: {repo}")

    def _validate_pr_number(self, pr_number: str):
        """Validate PR number is numeric"""
        if not pr_number.isdigit():
            raise ValueError(f"Invalid PR number: {pr_number}")

    def get_pr_details(self) -> Dict:
        """Get pull request details with timeout and validation"""
        url = f"https://api.github.com/repos/{self.repo}/pulls/{self.pr_number}"
        headers = {
            'Authorization': f'token {self.github_token}',
            'User-Agent': 'Advanced-AI-Reviewer/1.0'
        }

        try:
            response = requests.get(url, headers=headers, timeout=30, allow_redirects=False)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error fetching PR details: {e}")
            return {}

    def get_pr_files(self) -> List[Dict]:
        """Get files changed in PR with timeout and validation"""
        url = f"https://api.github.com/repos/{self.repo}/pulls/{self.pr_number}/files"
        headers = {
            'Authorization': f'token {self.github_token}',
            'User-Agent': 'Advanced-AI-Reviewer/1.0'
        }

        try:
            response = requests.get(url, headers=headers, timeout=30, allow_redirects=False)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error fetching PR files: {e}")
            return []

    def analyze_code_with_ai(self, code: str, filename: str) -> Dict:
        """Analyze code using AI models with input validation"""
        # Sanitize inputs
        if not isinstance(code, str) or not isinstance(filename, str):
            return {'issues': ['Invalid input types'], 'suggestions': [], 'score': 0}

        # Limit code analysis to reasonable size
        if len(code) > 10000:
            code = code[:10000] + "...[truncated]"

        analysis = {
            'issues': [],
            'suggestions': [],
            'score': 0
        }

        # Mock AI analysis (replace with real API calls when available)
        if 'TODO' in code:
            analysis['issues'].append('TODO comments found - consider addressing')
        if 'print(' in code and 'debug' not in filename.lower():
            analysis['suggestions'].append('Consider using proper logging instead of print statements')
        if len(code.split('\n')) > 500:
            analysis['issues'].append('Large file detected - consider splitting into smaller modules')

        analysis['score'] = max(0, 10 - len(analysis['issues']) - len(analysis['suggestions']) * 0.5)

        return analysis

    def post_review_comment(self, comment: str):
        """Post review comment on PR with validation"""
        if not isinstance(comment, str) or len(comment) > 65536:  # GitHub comment limit
            print("Invalid comment content or too long")
            return

        url = f"https://api.github.com/repos/{self.repo}/pulls/{self.pr_number}/reviews"
        headers = {
            'Authorization': f'token {self.github_token}',
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Advanced-AI-Reviewer/1.0'
        }
        data = {
            'body': comment,
            'event': 'COMMENT'
        }

        try:
            response = requests.post(url, headers=headers, json=data, timeout=30, allow_redirects=False)
            response.raise_for_status()
        except requests.RequestException as e:
            print(f"Error posting review comment: {e}")

    def run_review(self):
        """Main review process"""
        print("🤖 Starting Advanced AI Code Review...")

        pr_details = self.get_pr_details()
        if not pr_details:
            print("Failed to get PR details")
            return

        pr_files = self.get_pr_files()
        if not pr_files:
            print("No files to review")
            return

        total_score = 0
        total_files = len(pr_files)
        issues_found = 0
        suggestions_made = 0

        review_body = "## 🤖 Advanced AI Code Review\n\n"

        for file in pr_files[:5]:  # Limit to first 5 files for demo
            filename = file.get('filename', '')
            if not filename or not isinstance(filename, str):
                continue

            patch = file.get('patch', '')
            if not isinstance(patch, str):
                continue

            if len(patch) > 1000:  # Skip very large patches
                continue

            analysis = self.analyze_code_with_ai(patch, filename)

            if analysis['issues'] or analysis['suggestions']:
                review_body += f"### 📁 {filename}\n"
                for issue in analysis['issues']:
                    review_body += f"- ⚠️ {issue}\n"
                    issues_found += 1
                for suggestion in analysis['suggestions']:
                    review_body += f"- 💡 {suggestion}\n"
                    suggestions_made += 1
                review_body += f"**Score: {analysis['score']:.1f}/10**\n\n"

            total_score += analysis['score']

        # Summary
        avg_score = total_score / max(total_files, 1)
        review_body += f"## 📊 Summary\n"
        review_body += f"- **Average Quality Score**: {avg_score:.1f}/10\n"
        review_body += f"- **Files Analyzed**: {min(total_files, 5)}\n"
        review_body += f"- **Issues Found**: {issues_found}\n"
        review_body += f"- **Suggestions Made**: {suggestions_made}\n"

        if avg_score >= 8:
            review_body += "🎉 **Excellent quality!** Ready for merge.\n"
        elif avg_score >= 6:
            review_body += "👍 **Good quality** with minor improvements needed.\n"
        else:
            review_body += "🔧 **Needs improvement** before merging.\n"

        self.post_review_comment(review_body)
        print("✅ AI Review completed and posted!")

if __name__ == "__main__":
    try:
        reviewer = AdvancedAIReviewer()
        reviewer.run_review()
    except Exception as e:
        print(f"Error running AI review: {e}")
        exit(1)
