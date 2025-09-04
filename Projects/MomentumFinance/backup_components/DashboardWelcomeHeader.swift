//
// DashboardWelcomeHeader.swift
// MomentumFinance
//
// Created by Dashboard Refactoring on 8/19/25.
//

import SwiftUI

struct DashboardWelcomeHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good \(timeOfDayGreeting)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("Here's a summary of your finances")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Financial wellness indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Wellness")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Text("85%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.mint)

                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                            .foregroundStyle(.mint)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0 ..< 12:
            return "Morning"
        case 12 ..< 17:
            return "Afternoon"
        default:
            return "Evening"
        }
    }
}

#Preview {
    DashboardWelcomeHeader()
        .padding()
}
