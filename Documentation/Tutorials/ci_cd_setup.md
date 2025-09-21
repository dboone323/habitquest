# CI/CD Setup Tutorial

Learn how to set up continuous integration and deployment for Quantum workspace projects.

## Overview

The Quantum workspace includes comprehensive CI/CD pipelines using GitHub Actions.

## Prerequisites

- GitHub repository with Actions enabled
- Projects configured with proper build settings
- TestFlight access (for iOS deployment)

## Configuration

### 1. GitHub Actions Setup

Each project includes a `.github/workflows/ci-cd.yml` file with:

- **Build**: Automated compilation for all platforms
- **Test**: Unit and integration tests
- **Lint**: Code quality checks
- **Security**: Security scanning
- **Deploy**: TestFlight deployment

### 2. Required Secrets

Set these in your GitHub repository settings:

```
APP_STORE_CONNECT_PRIVATE_KEY
APP_STORE_CONNECT_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
TESTFLIGHT_EMAIL
```

### 3. Branch Protection

Configure branch protection rules:

1. Go to Settings → Branches
2. Add rule for `main` branch
3. Require status checks to pass
4. Require branches to be up to date

## Workflow Triggers

The CI/CD pipeline runs on:

- Push to main branch
- Pull requests
- Manual workflow dispatch
- Scheduled (weekly security scans)

## Monitoring

### Build Status

Check build status in:
- GitHub Actions tab
- Pull request checks
- Branch protection status

### Test Results

View test results in:
- GitHub Actions logs
- Test summary reports
- Coverage reports (when enabled)

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Xcode version compatibility
   - Verify code signing certificates
   - Review build logs for specific errors

2. **Test Failures**
   - Run tests locally first
   - Check test environment setup
   - Review test logs for failures

3. **Deployment Issues**
   - Verify App Store Connect credentials
   - Check TestFlight permissions
   - Review deployment logs

### Getting Help

- Check the [CI/CD Guide](./../Guides/CI_CD_GUIDE.md)
- Review workflow logs in GitHub Actions
- Create an issue for persistent problems
