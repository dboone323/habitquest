//
//  DashboardWelcomeHeader.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftUI

extension Features.Dashboard {
    struct DashboardWelcomeHeader: View {
        let colorTheme: ColorTheme

        private var timeOfDayGreeting: String {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 12 {
                return "Morning"
            } else if hour < 17 {
                return "Afternoon"
            } else {
                return "Evening"
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Good \(timeOfDayGreeting)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()

                    Menu {
                        Button(action: {
                            // Refresh action
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }

                Text("Here's a summary of your finances")
                    .font(.subheadline)
                    .foregroundStyle(colorTheme.secondaryText)
                    .padding(.bottom, 8)

                // Financial Wellness Score
                HStack(spacing: 16) {
                    Text("Financial Wellness")
                        .font(.caption)
                        .foregroundStyle(colorTheme.secondaryText)

                    Spacer()

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorTheme.secondaryBackground)
                            .frame(width: 170, height: 8)

                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorTheme.savings)
                            .frame(width: 170 * Double(70) / 100, height: 8)
                    }

                    Text("70%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(colorTheme.primaryText)
                }
                .padding(.vertical, 2)
            }
        }
    }
}
