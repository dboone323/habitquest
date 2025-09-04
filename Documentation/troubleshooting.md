# Troubleshooting Guide

## Common Issues

### Build Failures

- Check Xcode version compatibility
- Verify CocoaPods installation
- Clean build folder and rebuild

### Performance Issues

- Run performance report: `./master_automation.sh performance`
- Check system resources
- Review recent changes for bottlenecks

### Security Alerts

- Run security scan: `./master_automation.sh security <project>`
- Review exposed secrets
- Update dependencies
