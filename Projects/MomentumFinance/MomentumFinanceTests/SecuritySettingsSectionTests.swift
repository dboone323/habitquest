import XCTest
import SwiftUI
@testable import MomentumFinanceCore

@MainActor
final class SecuritySettingsSectionTests: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults for clean test state
        UserDefaults.standard.removeObject(forKey: "biometricEnabled")
        UserDefaults.standard.removeObject(forKey: "authenticationTimeout")
    }

    override func tearDown() async throws {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "biometricEnabled")
        UserDefaults.standard.removeObject(forKey: "authenticationTimeout")
        try await super.tearDown()
    }

    // MARK: - Biometric Authentication Tests

    func testBiometricAuthenticationToggleInitialState() {
        // Given: Default state (should be false)
        let viewModel = SecuritySettingsViewModel()

        // When: View is created
        let binding = viewModel.biometricEnabledBinding

        // Then: Initial state should be false
        XCTAssertFalse(binding.wrappedValue, "Biometric authentication should be disabled by default")
    }

    func testBiometricAuthenticationToggleOn() {
        // Given: ViewModel with biometric toggle
        let viewModel = SecuritySettingsViewModel()

        // When: Toggle is turned on
        viewModel.biometricEnabledBinding.wrappedValue = true

        // Then: State should be persisted and retrievable
        XCTAssertTrue(viewModel.biometricEnabledBinding.wrappedValue, "Biometric authentication should be enabled")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "biometricEnabled"), "Setting should be persisted to UserDefaults")
    }

    func testBiometricAuthenticationToggleOff() {
        // Given: ViewModel with biometric enabled
        let viewModel = SecuritySettingsViewModel()
        viewModel.biometricEnabledBinding.wrappedValue = true

        // When: Toggle is turned off
        viewModel.biometricEnabledBinding.wrappedValue = false

        // Then: State should be updated and persisted
        XCTAssertFalse(viewModel.biometricEnabledBinding.wrappedValue, "Biometric authentication should be disabled")
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "biometricEnabled"), "Setting should be persisted to UserDefaults")
    }

    func testBiometricAuthenticationPersistence() {
        // Given: UserDefaults has biometric enabled
        UserDefaults.standard.set(true, forKey: "biometricEnabled")

        // When: New ViewModel is created
        let viewModel = SecuritySettingsViewModel()

        // Then: Should load persisted state
        XCTAssertTrue(viewModel.biometricEnabledBinding.wrappedValue, "Should load persisted biometric state")
    }

    // MARK: - Authentication Timeout Tests

    func testAuthenticationTimeoutInitialState() {
        // Given: Default state
        let viewModel = SecuritySettingsViewModel()

        // When: View is created
        let binding = viewModel.authenticationTimeoutBinding

        // Then: Initial timeout should be 300 seconds (5 minutes)
        XCTAssertEqual(binding.wrappedValue, 300, "Default authentication timeout should be 300 seconds")
    }

    func testAuthenticationTimeoutOneMinute() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Timeout is set to 1 minute
        viewModel.authenticationTimeoutBinding.wrappedValue = 60

        // Then: State should be updated and persisted
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 60, "Authentication timeout should be 60 seconds")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "authenticationTimeout"), "60", "Setting should be persisted as string")
    }

    func testAuthenticationTimeoutFiveMinutes() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Timeout is set to 5 minutes
        viewModel.authenticationTimeoutBinding.wrappedValue = 300

        // Then: State should be updated and persisted
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 300, "Authentication timeout should be 300 seconds")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "authenticationTimeout"), "300", "Setting should be persisted as string")
    }

    func testAuthenticationTimeoutFifteenMinutes() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Timeout is set to 15 minutes
        viewModel.authenticationTimeoutBinding.wrappedValue = 900

        // Then: State should be updated and persisted
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 900, "Authentication timeout should be 900 seconds")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "authenticationTimeout"), "900", "Setting should be persisted as string")
    }

    func testAuthenticationTimeoutOneHour() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Timeout is set to 1 hour
        viewModel.authenticationTimeoutBinding.wrappedValue = 3600

        // Then: State should be updated and persisted
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 3600, "Authentication timeout should be 3600 seconds")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "authenticationTimeout"), "3600", "Setting should be persisted as string")
    }

    func testAuthenticationTimeoutPersistence() {
        // Given: UserDefaults has timeout set to 900
        UserDefaults.standard.set("900", forKey: "authenticationTimeout")

        // When: New ViewModel is created
        let viewModel = SecuritySettingsViewModel()

        // Then: Should load persisted state
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 900, "Should load persisted timeout state")
    }

    func testAuthenticationTimeoutInvalidPersistence() {
        // Given: UserDefaults has invalid timeout value
        UserDefaults.standard.set("invalid", forKey: "authenticationTimeout")

        // When: New ViewModel is created
        let viewModel = SecuritySettingsViewModel()

        // Then: Should fall back to default (300)
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 300, "Should fall back to default timeout on invalid persistence")
    }

    // MARK: - Combined Settings Tests

    func testCombinedSettingsPersistence() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Both settings are configured
        viewModel.biometricEnabledBinding.wrappedValue = true
        viewModel.authenticationTimeoutBinding.wrappedValue = 900

        // Then: Both should be persisted correctly
        XCTAssertTrue(viewModel.biometricEnabledBinding.wrappedValue)
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 900)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "biometricEnabled"))
        XCTAssertEqual(UserDefaults.standard.string(forKey: "authenticationTimeout"), "900")
    }

    func testCombinedSettingsReload() {
        // Given: UserDefaults has both settings configured
        UserDefaults.standard.set(true, forKey: "biometricEnabled")
        UserDefaults.standard.set("900", forKey: "authenticationTimeout")

        // When: New ViewModel is created
        let viewModel = SecuritySettingsViewModel()

        // Then: Both settings should be loaded
        XCTAssertTrue(viewModel.biometricEnabledBinding.wrappedValue)
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 900)
    }

    // MARK: - UI State Tests

    func testBiometricToggleAccessibility() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Biometric toggle is created
        let toggle = Toggle("Biometric Authentication", isOn: viewModel.biometricEnabledBinding)

        // Then: Toggle should be created successfully and have correct initial state
        XCTAssertNotNil(toggle, "Toggle should be created successfully")
        XCTAssertFalse(viewModel.biometricEnabledBinding.wrappedValue, "Biometric should be disabled by default")
    }

    func testAuthenticationTimeoutPickerValues() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Picker is created with different values
        let picker = Picker("Authentication Timeout", selection: viewModel.authenticationTimeoutBinding) {
            Text("1 minute").tag(60)
            Text("5 minutes").tag(300)
            Text("15 minutes").tag(900)
            Text("1 hour").tag(3600)
        }

        // Then: Picker should be created successfully and binding should have correct initial value
        XCTAssertNotNil(picker, "Picker should be created successfully")
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 300, "Picker binding should have correct initial selection")
    }

    // MARK: - Edge Cases

    func testAuthenticationTimeoutZeroValue() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Timeout is set to 0 (shouldn't happen in UI but test robustness)
        viewModel.authenticationTimeoutBinding.wrappedValue = 0

        // Then: Should handle zero value
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 0)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "authenticationTimeout"), "0")
    }

    func testAuthenticationTimeoutLargeValue() {
        // Given: ViewModel
        let viewModel = SecuritySettingsViewModel()

        // When: Timeout is set to a very large value
        viewModel.authenticationTimeoutBinding.wrappedValue = 86400 // 24 hours

        // Then: Should handle large value
        XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 86400)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "authenticationTimeout"), "86400")
    }

    // MARK: - Performance Tests

    func testSecuritySettingsPerformance() {
        // Given: Clean state
        UserDefaults.standard.removeObject(forKey: "biometricEnabled")
        UserDefaults.standard.removeObject(forKey: "authenticationTimeout")

        measure {
            // When: Creating and configuring security settings
            let viewModel = SecuritySettingsViewModel()
            viewModel.biometricEnabledBinding.wrappedValue = true
            viewModel.authenticationTimeoutBinding.wrappedValue = 900

            // Then: Operations should complete quickly
            XCTAssertTrue(viewModel.biometricEnabledBinding.wrappedValue)
            XCTAssertEqual(viewModel.authenticationTimeoutBinding.wrappedValue, 900)
        }
    }

    func testSecuritySettingsPersistencePerformance() {
        measure {
            // Given: Multiple settings changes
            let viewModel = SecuritySettingsViewModel()

            // When: Rapidly changing settings
            for i in 0..<100 {
                viewModel.biometricEnabledBinding.wrappedValue = (i % 2 == 0)
                viewModel.authenticationTimeoutBinding.wrappedValue = 60 + (i * 10)
            }

            // Then: Should handle rapid changes efficiently
            XCTAssertNotNil(viewModel)
        }
    }
}

// MARK: - Test ViewModel

@MainActor
private class SecuritySettingsViewModel {
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("authenticationTimeout") private var authenticationTimeoutRaw: String = "300"

    var biometricEnabledBinding: Binding<Bool> {
        Binding(
            get: { self.biometricEnabled },
            set: { self.biometricEnabled = $0 }
        )
    }

    var authenticationTimeoutBinding: Binding<Int> {
        Binding(
            get: {
                Int(self.authenticationTimeoutRaw) ?? 300
            },
            set: { newVal in
                self.authenticationTimeoutRaw = String(newVal)
            }
        )
    }
}
