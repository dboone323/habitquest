//
//  FinancialIntelligenceRisk.swift
//  MomentumFinance
//
//  Created by Automated Code Generation
//  Component extracted from AdvancedFinancialIntelligence.swift
//  Contains risk assessment functionality
//

import Foundation

/// Component containing risk assessment methods
/// Extracted from AdvancedFinancialIntelligence to maintain file size limits
struct FinancialIntelligenceRisk {
    let helpers: FinancialIntelligenceHelpers

    // MARK: - Risk Assessment

    func generateRiskAssessment(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) async -> RiskAssessment {
        let monthlyExpenses = self.helpers.calculateMonthlyExpenses(transactions)
        guard monthlyExpenses > 0 else {
            return RiskAssessment(
                overallRiskLevel: .low,
                emergencyFundRisk: .low,
                debtRisk: .low,
                investmentRisk: .low,
                cashFlowRisk: .low
            )
        }

        let coverage = FinancialAnalyticsSharedCore.emergencyCoverage(
            accounts: accounts,
            monthlyExpenses: monthlyExpenses
        )

        let emergencyRisk: RiskLevel
        let overallRisk: RiskLevel

        switch coverage {
        case ..<1:
            emergencyRisk = .critical
            overallRisk = .high
        case 1 ..< 3:
            emergencyRisk = .high
            overallRisk = .medium
        default:
            emergencyRisk = .medium
            overallRisk = .low
        }

        return RiskAssessment(
            overallRiskLevel: overallRisk,
            emergencyFundRisk: emergencyRisk,
            debtRisk: .medium,
            investmentRisk: .moderate,
            cashFlowRisk: coverage < 3 ? .medium : .low
        )
    }
}
