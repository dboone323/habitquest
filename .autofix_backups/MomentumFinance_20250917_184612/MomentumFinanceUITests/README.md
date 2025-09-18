# MomentumFinance UI Tests

This directory contains comprehensive UI tests for the MomentumFinance application, covering all major financial management features including transactions, accounts, budgets, and reports.

## Test Structure

### Main Test Files

- **MomentumFinanceUITests.swift** - Core app functionality tests including launch, navigation, and performance
- **TransactionUITests.swift** - Transaction management tests (create, edit, delete, filter, search)
- **AccountUITests.swift** - Account management tests (create, edit, delete, balance tracking, transfers)
- **BudgetUITests.swift** - Budget management tests (create, progress tracking, alerts, reports)

## Test Coverage

### App Launch & Navigation
- ✅ App launches successfully
- ✅ Main navigation tabs work correctly
- ✅ Tab-based navigation between sections

### Transaction Management
- ✅ Create income and expense transactions
- ✅ Edit existing transactions
- ✅ Delete transactions (single and bulk)
- ✅ Filter by category and date range
- ✅ Search transactions
- ✅ Sort by date and amount
- ✅ Recurring transaction setup
- ✅ Input validation and error handling

### Account Management
- ✅ Create checking and savings accounts
- ✅ Display account balances with currency formatting
- ✅ Edit account details
- ✅ Delete accounts
- ✅ Transfer money between accounts
- ✅ Account summary views
- ✅ Filter and search accounts
- ✅ Account validation

### Budget Management
- ✅ Create monthly and category budgets
- ✅ Display budget progress indicators
- ✅ Track budget vs actual spending
- ✅ Edit budget amounts
- ✅ Delete budgets
- ✅ Budget alerts and warnings
- ✅ Budget summary views
- ✅ Filter budgets by period
- ✅ Budget validation

### Reports & Analytics
- ✅ Reports view accessibility
- ✅ Chart display for financial data
- ✅ Date range selection
- ✅ Export functionality (PDF/CSV)

### Settings & Preferences
- ✅ Settings access
- ✅ Currency selection
- ✅ App preferences

### Search & Filter
- ✅ Global search functionality
- ✅ Advanced filtering options

### Data Export
- ✅ Export transactions and reports
- ✅ Multiple export formats

### Performance
- ✅ App launch performance
- ✅ List scrolling performance
- ✅ Bulk operations performance

### Accessibility
- ✅ Proper accessibility labels
- ✅ Screen reader compatibility

### Error Handling
- ✅ Invalid input validation
- ✅ Required field validation
- ✅ Network error handling

## Setup Instructions

### Prerequisites
1. Xcode 15.0 or later
2. iOS Simulator or physical iOS device
3. MomentumFinance app target properly configured

### Xcode Configuration

1. **Add UI Test Target** (if not already present):
   - Open MomentumFinance.xcodeproj in Xcode
   - Select the project in the Project Navigator
   - Click the "+" button at the bottom of the targets list
   - Choose "UI Testing Bundle" template
   - Name it "MomentumFinanceUITests"
   - Select the MomentumFinance app as the target to test

2. **Configure Test Target**:
   - Select the MomentumFinanceUITests target
   - Go to "Build Phases" tab
   - Ensure "MomentumFinance" is in "Target Dependencies"
   - Add any required frameworks to "Link Binary With Libraries"

3. **Set Up Accessibility Identifiers**:
   - In your main app code, add accessibility identifiers to UI elements:
   ```swift
   // Example
   Button("Add Transaction") {
       // action
   }
   .accessibilityIdentifier("Add Transaction")
   ```

### Running Tests

#### Run All UI Tests
```bash
# From terminal
xcodebuild test -project MomentumFinance.xcodeproj -scheme MomentumFinance -destination "platform=iOS Simulator,name=iPhone 15"

# Or from Xcode
# Product → Test (⌘U)
```

#### Run Specific Test Class
```bash
xcodebuild test -project MomentumFinance.xcodeproj -scheme MomentumFinance -destination "platform=iOS Simulator,name=iPhone 15" -only-testing:MomentumFinanceUITests/TransactionUITests
```

#### Run Individual Test
```bash
xcodebuild test -project MomentumFinance.xcodeproj -scheme MomentumFinance -destination "platform=iOS Simulator,name=iPhone 15" -only-testing:MomentumFinanceUITests/TransactionUITests/testCreateIncomeTransaction
```

### Test Data Setup

For consistent testing, consider setting up test data:

1. **Pre-populated Test Database**: Create a test database with sample transactions, accounts, and budgets
2. **Test User Defaults**: Set up default preferences for testing
3. **Mock Data**: Use mock data for external services (if applicable)

## Best Practices

### Test Organization
- Group related tests in separate files
- Use descriptive test method names
- Add comments explaining complex test scenarios

### Element Identification
- Use accessibility identifiers for reliable element location
- Prefer semantic queries over positional queries
- Handle dynamic content gracefully

### Test Stability
- Use appropriate wait times for UI elements
- Handle asynchronous operations properly
- Test on multiple device sizes and orientations

### Performance Testing
- Use `measure` blocks for performance tests
- Test on actual devices for accurate metrics
- Monitor memory usage during long-running tests

## Troubleshooting

### Common Issues

1. **XCTest Module Not Found**
   - Ensure UI test target is properly configured
   - Check that Xcode version supports UI testing
   - Verify target dependencies are set correctly

2. **Elements Not Found**
   - Add accessibility identifiers to UI elements
   - Check that UI hierarchy matches test expectations
   - Use Xcode's Accessibility Inspector to verify identifiers

3. **Tests Flaking**
   - Add appropriate wait conditions
   - Use `XCTWaiter` for asynchronous operations
   - Test on stable simulator versions

4. **Performance Test Failures**
   - Run tests on dedicated test devices
   - Ensure consistent test environment
   - Monitor for background processes affecting performance

### Debug Tips

1. **Enable UI Test Recording**:
   - In test method, add `let app = XCUIApplication()`
   - Use Xcode's UI test recording feature to generate test code

2. **Inspect App State**:
   ```swift
   print(app.debugDescription) // Print UI hierarchy
   ```

3. **Take Screenshots on Failure**:
   ```swift
   let screenshot = app.screenshot()
   let attachment = XCTAttachment(screenshot: screenshot)
   attachment.name = "Screenshot on Failure"
   add(attachment)
   ```

## Continuous Integration

### CI/CD Integration

Add to your CI pipeline:

```yaml
# Example GitHub Actions
- name: Run UI Tests
  run: |
    xcodebuild test \
      -project MomentumFinance.xcodeproj \
      -scheme MomentumFinance \
      -destination "platform=iOS Simulator,name=iPhone 15" \
      -resultBundlePath TestResults
```

### Test Reporting

- Use Xcode's built-in test reporting
- Integrate with third-party services (TestRail, Zephyr)
- Generate HTML reports for better visualization

## Maintenance

### Regular Updates
- Update tests when UI changes
- Review and update accessibility identifiers
- Keep test data current

### Test Coverage Analysis
- Use Xcode's code coverage reports
- Identify untested UI paths
- Add tests for new features

### Performance Baselines
- Establish performance baselines
- Monitor for regressions
- Update baselines as app evolves

## Contributing

When adding new UI tests:

1. Follow the existing naming conventions
2. Add appropriate comments and documentation
3. Ensure tests are reliable and not flaky
4. Update this README with new test coverage
5. Test on multiple devices and iOS versions

## Resources

- [Xcode UI Testing Documentation](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [UI Testing Best Practices](https://developer.apple.com/documentation/xctest/user_interface_tests/adopting_xctest)
- [Accessibility Programming Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/iPhoneAccessibility/)
