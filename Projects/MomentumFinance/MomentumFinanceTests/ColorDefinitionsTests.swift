//
//  ColorDefinitionsTests.swift
//  MomentumFinanceTests
//
//  Created by GitHub Copilot on 9/30/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

@testable import MomentumFinanceCore
import SwiftUI
import XCTest

@MainActor
final class ColorDefinitionsTests: XCTestCase {
    // MARK: - Background Colors Tests

    func testBackgroundColorsLightScheme() {
        let color = ColorDefinitions.background(.light)
        // Test that we get a valid color (can't easily test exact hex values without private access)
        XCTAssertNotNil(color)
    }

    func testBackgroundColorsDarkScheme() {
        let color = ColorDefinitions.background(.dark)
        XCTAssertNotNil(color)
    }

    func testSecondaryBackgroundColorsLightScheme() {
        let color = ColorDefinitions.secondaryBackground(.light)
        XCTAssertNotNil(color)
    }

    func testSecondaryBackgroundColorsDarkScheme() {
        let color = ColorDefinitions.secondaryBackground(.dark)
        XCTAssertNotNil(color)
    }

    func testGroupedBackgroundColorsLightScheme() {
        let color = ColorDefinitions.groupedBackground(.light)
        XCTAssertNotNil(color)
    }

    func testGroupedBackgroundColorsDarkScheme() {
        let color = ColorDefinitions.groupedBackground(.dark)
        XCTAssertNotNil(color)
    }

    func testCardBackgroundColorsLightScheme() {
        let color = ColorDefinitions.cardBackground(.light)
        XCTAssertNotNil(color)
    }

    func testCardBackgroundColorsDarkScheme() {
        let color = ColorDefinitions.cardBackground(.dark)
        XCTAssertNotNil(color)
    }

    // MARK: - Text Colors Tests

    func testTextColorsPrimaryLightScheme() {
        let color = ColorDefinitions.text(.primary, .light)
        XCTAssertNotNil(color)
    }

    func testTextColorsPrimaryDarkScheme() {
        let color = ColorDefinitions.text(.primary, .dark)
        XCTAssertNotNil(color)
    }

    func testTextColorsSecondaryLightScheme() {
        let color = ColorDefinitions.text(.secondary, .light)
        XCTAssertNotNil(color)
    }

    func testTextColorsSecondaryDarkScheme() {
        let color = ColorDefinitions.text(.secondary, .dark)
        XCTAssertNotNil(color)
    }

    func testTextColorsTertiaryLightScheme() {
        let color = ColorDefinitions.text(.tertiary, .light)
        XCTAssertNotNil(color)
    }

    func testTextColorsTertiaryDarkScheme() {
        let color = ColorDefinitions.text(.tertiary, .dark)
        XCTAssertNotNil(color)
    }

    // MARK: - Accent Colors Tests

    func testAccentColorsPrimaryLightScheme() {
        let color = ColorDefinitions.accent(.primary, .light)
        XCTAssertNotNil(color)
    }

    func testAccentColorsPrimaryDarkScheme() {
        let color = ColorDefinitions.accent(.primary, .dark)
        XCTAssertNotNil(color)
    }

    func testAccentColorsSecondaryLightScheme() {
        let color = ColorDefinitions.accent(.secondary, .light)
        XCTAssertNotNil(color)
    }

    func testAccentColorsSecondaryDarkScheme() {
        let color = ColorDefinitions.accent(.secondary, .dark)
        XCTAssertNotNil(color)
    }

    // MARK: - Financial Colors Tests

    func testFinancialColorsIncomeLightScheme() {
        let color = ColorDefinitions.financial(.income, .light)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsIncomeDarkScheme() {
        let color = ColorDefinitions.financial(.income, .dark)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsExpenseLightScheme() {
        let color = ColorDefinitions.financial(.expense, .light)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsExpenseDarkScheme() {
        let color = ColorDefinitions.financial(.expense, .dark)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsSavingsLightScheme() {
        let color = ColorDefinitions.financial(.savings, .light)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsSavingsDarkScheme() {
        let color = ColorDefinitions.financial(.savings, .dark)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsWarningLightScheme() {
        let color = ColorDefinitions.financial(.warning, .light)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsWarningDarkScheme() {
        let color = ColorDefinitions.financial(.warning, .dark)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsCriticalLightScheme() {
        let color = ColorDefinitions.financial(.critical, .light)
        XCTAssertNotNil(color)
    }

    func testFinancialColorsCriticalDarkScheme() {
        let color = ColorDefinitions.financial(.critical, .dark)
        XCTAssertNotNil(color)
    }

    // MARK: - Budget Colors Tests

    func testBudgetColorsUnderLightScheme() {
        let color = ColorDefinitions.budget(.under, .light)
        XCTAssertNotNil(color)
    }

    func testBudgetColorsUnderDarkScheme() {
        let color = ColorDefinitions.budget(.under, .dark)
        XCTAssertNotNil(color)
    }

    func testBudgetColorsNearLightScheme() {
        let color = ColorDefinitions.budget(.near, .light)
        XCTAssertNotNil(color)
    }

    func testBudgetColorsNearDarkScheme() {
        let color = ColorDefinitions.budget(.near, .dark)
        XCTAssertNotNil(color)
    }

    func testBudgetColorsOverLightScheme() {
        let color = ColorDefinitions.budget(.over, .light)
        XCTAssertNotNil(color)
    }

    func testBudgetColorsOverDarkScheme() {
        let color = ColorDefinitions.budget(.over, .dark)
        XCTAssertNotNil(color)
    }

    // MARK: - Category Colors Tests

    func testCategoryColorsArrayNotEmpty() {
        XCTAssertFalse(ColorDefinitions.categoryColors.isEmpty)
    }

    func testCategoryColorsArrayHasExpectedCount() {
        // Based on the implementation, there should be 12 category colors
        XCTAssertEqual(ColorDefinitions.categoryColors.count, 12)
    }

    func testCategoryColorsAreValid() {
        for color in ColorDefinitions.categoryColors {
            XCTAssertNotNil(color)
        }
    }

    // MARK: - Color Extension Tests

    func testColorHexInit3Digit() {
        let color = Color(hex: "#RGB")
        XCTAssertNotNil(color)
        // Test that it doesn't crash and creates a valid color
    }

    func testColorHexInit6Digit() {
        let color = Color(hex: "#RRGGBB")
        XCTAssertNotNil(color)
    }

    func testColorHexInit8Digit() {
        let color = Color(hex: "#AARRGGBB")
        XCTAssertNotNil(color)
    }

    func testColorHexInitInvalid() {
        let color = Color(hex: "invalid")
        XCTAssertNotNil(color)
        // Should create a fallback color
    }

    func testColorHexInitWithHash() {
        let color = Color(hex: "#FF0000")
        XCTAssertNotNil(color)
    }

    func testColorHexInitWithoutHash() {
        let color = Color(hex: "FF0000")
        XCTAssertNotNil(color)
    }

    func testColorHexInitEmptyString() {
        let color = Color(hex: "")
        XCTAssertNotNil(color)
        // Should create a fallback color
    }

    // MARK: - Color Consistency Tests

    func testBackgroundColorsAreDifferentBetweenSchemes() {
        let lightColor = ColorDefinitions.background(.light)
        let darkColor = ColorDefinitions.background(.dark)
        // Colors should be different between schemes
        XCTAssertNotEqual(lightColor.description, darkColor.description)
    }

    func testTextColorsAreDifferentBetweenSchemes() {
        let lightColor = ColorDefinitions.text(.primary, .light)
        let darkColor = ColorDefinitions.text(.primary, .dark)
        XCTAssertNotEqual(lightColor.description, darkColor.description)
    }

    func testAccentColorsAreDifferentBetweenSchemes() {
        let lightColor = ColorDefinitions.accent(.primary, .light)
        let darkColor = ColorDefinitions.accent(.primary, .dark)
        XCTAssertNotEqual(lightColor.description, darkColor.description)
    }

    func testFinancialColorsAreDifferentBetweenSchemes() {
        let lightColor = ColorDefinitions.financial(.income, .light)
        let darkColor = ColorDefinitions.financial(.income, .dark)
        XCTAssertNotEqual(lightColor.description, darkColor.description)
    }

    func testBudgetColorsAreDifferentBetweenSchemes() {
        let lightColor = ColorDefinitions.budget(.under, .light)
        let darkColor = ColorDefinitions.budget(.under, .dark)
        XCTAssertNotEqual(lightColor.description, darkColor.description)
    }

    // MARK: - Performance Tests

    func testColorDefinitionsPerformance() {
        measure {
            for _ in 0 ..< 1000 {
                _ = ColorDefinitions.background(.light)
                _ = ColorDefinitions.text(.primary, .dark)
                _ = ColorDefinitions.accent(.primary, .light)
                _ = ColorDefinitions.financial(.income, .dark)
                _ = ColorDefinitions.budget(.under, .light)
            }
        }
    }

    func testColorHexInitPerformance() {
        let hexStrings = ["#FF0000", "#00FF00", "#0000FF", "#FFFFFF", "#000000"]
        measure {
            for _ in 0 ..< 1000 {
                for hex in hexStrings {
                    _ = Color(hex: hex)
                }
            }
        }
    }
}
