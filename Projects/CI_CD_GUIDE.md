# CI/CD Guide for Quantum Workspace

## Overview
This workspace uses GitHub Actions for continuous integration and deployment (CI/CD) across all projects. Each project has a standardized workflow for build, test, lint, formatting, security, and dependency checks. Deployment to TestFlight is supported for iOS/macOS apps.

---

## Workflow Structure

- **Triggers:**
  - On push to `main` and `develop` branches
  - On pull requests targeting `main` or `develop`
  - Manual dispatch (workflow_dispatch)

- **Jobs:**
  - **Build and Test:**
    - Uses latest macOS runner and Xcode
    - Runs `xcodebuild` or project smart scripts
    - Fails on any test or build error
  - **Lint:**
    - Runs SwiftLint with strict mode
    - Fails on any lint error
  - **Format:**
    - Runs SwiftFormat in lint mode
    - Fails if formatting issues are found
  - **Security:**
    - Runs CodeQL or custom security scripts
    - Fails on any critical finding
  - **Dependency Check:**
    - Checks for outdated or vulnerable dependencies
    - Fails if issues are found
  - **Deploy (optional):**
    - Deploys to TestFlight on successful build from `main` (requires secrets)

---

## TestFlight Deployment

To enable TestFlight deployment:
1. Add the following secrets to your GitHub repository:
   - `APP_STORE_CONNECT_API_KEY`
   - `APP_STORE_CONNECT_API_ISSUER_ID`
   - `APP_STORE_CONNECT_API_KEY_ID`
   - `APP_STORE_CONNECT_API_PRIVATE_KEY` (base64-encoded)
2. Ensure your workflow includes a `deploy` job similar to:

```yaml
  deploy:
    name: Deploy to TestFlight
    runs-on: macos-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Set up Xcode
        uses: maxim-lobanov/setup-xcode@1.6.0
        with:
          xcode-version: '15.4'
      - name: Build Archive
        run: |
          xcodebuild -workspace <YourWorkspace>.xcworkspace \
            -scheme <YourScheme> \
            -configuration Release \
            -archivePath ${{ github.workspace }}/build/<YourApp>.xcarchive \
            clean archive
      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath ${{ github.workspace }}/build/<YourApp>.xcarchive \
            -exportOptionsPlist ExportOptions.plist \
            -exportPath ${{ github.workspace }}/build
      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          api-key-id: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          api-issuer-id: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          api-private-key: ${{ secrets.APP_STORE_CONNECT_API_PRIVATE_KEY }}
          ipa-path: ${{ github.workspace }}/build/<YourApp>.ipa
```

---

## Quality Gates
- All jobs must pass for a PR to be merged.
- Lint, format, test, and security checks are enforced.
- Failed jobs block deployment.

---

## Best Practices
- Keep workflows DRY by using reusable steps and actions.
- Use caching for dependencies and build artifacts.
- Regularly update action versions and Xcode versions.
- Document any custom scripts or environment requirements.

---

_Last updated: September 12, 2025_
