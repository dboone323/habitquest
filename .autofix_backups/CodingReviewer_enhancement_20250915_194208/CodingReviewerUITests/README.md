# CodingReviewer UI Tests

This directory contains comprehensive UI tests for the CodingReviewer application.

## Setup Instructions

To run these UI tests, you need to add a UI Test target to your Xcode project:

### 1. Add UI Test Target to Xcode Project

1. Open `CodingReviewer.xcodeproj` in Xcode
2. Go to File → New → Target
3. Select "UI Testing Bundle" from the iOS/macOS templates
4. Name it "CodingReviewerUITests"
5. Make sure the target is added to the same project as your main app

### 2. Configure Test Files

1. Copy the UI test files from this directory to your new UITests target
2. Ensure the UITests target has access to the main application

### 3. Update Target Dependencies

Make sure the UITests target depends on the main CodingReviewer target so it can launch and test the app.

## Test Coverage

### CodingReviewerUITests.swift
- **App Launch Tests**: Verifies the app launches successfully and basic UI elements exist
- **Navigation Tests**: Tests tab navigation and main app navigation
- **Settings Tests**: Tests access to settings and preferences
- **Performance Tests**: Measures app launch performance and UI responsiveness
- **Accessibility Tests**: Ensures UI elements have proper accessibility labels
- **Error Handling Tests**: Tests error scenarios and user feedback
- **Memory Tests**: Monitors memory usage during normal operations

### FileUploadUITests.swift
- **File Upload UI**: Tests file upload buttons, input fields, and browse functionality
- **File Selection**: Tests single and multiple file selection workflows
- **File Validation**: Tests file type validation and error feedback
- **Drag & Drop**: Tests drag and drop functionality if implemented
- **File Preview**: Tests file preview functionality
- **Upload Progress**: Tests progress indicators during file upload
- **Recent Files**: Tests recent files list functionality
- **Upload Cancellation**: Tests ability to cancel file uploads

### CodeAnalysisUITests.swift
- **Analysis UI**: Tests analysis buttons and basic analysis workflow
- **Progress Indication**: Tests progress indicators during analysis
- **Results Display**: Tests that analysis results are properly displayed
- **Analysis Options**: Tests configuration options for analysis
- **Issue Filtering**: Tests filtering of analysis results by severity
- **Issue Details**: Tests detailed view of individual code issues
- **Code Metrics**: Tests display of code complexity and other metrics
- **Export Functionality**: Tests exporting analysis results
- **Analysis History**: Tests viewing previous analysis sessions
- **Real-time Analysis**: Tests real-time analysis features
- **Cancellation**: Tests cancelling analysis operations
- **Large File Handling**: Tests analysis of large files
- **Performance**: Measures analysis performance

## Running the Tests

### From Xcode
1. Select the UITests target
2. Go to Product → Test (⌘U)
3. Or use the Test Navigator to run individual test classes

### From Command Line
```bash
xcodebuild test -project CodingReviewer.xcodeproj -scheme CodingReviewer -destination 'platform=macOS'
```

## Test Best Practices

1. **Wait for UI Elements**: Use appropriate timeouts and expectations for UI elements to appear
2. **Test on Real Devices**: UI tests work best on real devices or simulators
3. **Handle Async Operations**: Use proper waiting mechanisms for async UI operations
4. **Test Error States**: Include tests for error conditions and edge cases
5. **Accessibility**: Ensure all tests consider accessibility features
6. **Performance**: Include performance measurements for critical user journeys

## Troubleshooting

### Common Issues

1. **XCTest Module Not Found**: Ensure the UITests target is properly configured
2. **App Not Launching**: Check target dependencies and scheme configuration
3. **UI Elements Not Found**: Verify accessibility identifiers match the actual UI
4. **Tests Timing Out**: Increase timeouts for slower operations or async tasks

### Debug Tips

1. Use `XCUIApplication().debugDescription` to see the current UI hierarchy
2. Add screenshots to failed tests for visual debugging
3. Use `print()` statements in test code for debugging
4. Check Console.app for additional error information

## Integration with CI/CD

These UI tests can be integrated into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Run UI Tests
  run: |
    xcodebuild test \
      -project CodingReviewer.xcodeproj \
      -scheme CodingReviewerUITests \
      -destination 'platform=macOS,arch=x86_64'
```

## Future Enhancements

1. **Screenshot Tests**: Add visual regression testing
2. **Network Tests**: Test API interactions and network error handling
3. **Database Tests**: Test data persistence and retrieval
4. **Multi-language Tests**: Test with different language files
5. **Performance Benchmarks**: Add performance regression testing
