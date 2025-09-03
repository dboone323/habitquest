import SwiftUI

// MARK: - Theme Components Preview

#if DEBUG
    struct ThemeComponentsPreview: View {
        @State private var showDarkMode = false
        @State private var sliderValue = 0.7
        let amounts: [Decimal] = [145.50, 1250.00, -85.75, 5234.89, -350.25]

        var theme: ColorTheme {
            showDarkMode ? ColorTheme.previewDark : ColorTheme.preview
        }

        var components: ThemeComponents {
            ThemeComponents()
        }

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Toggle("Dark Mode", isOn: $showDarkMode)
                            .padding()
                            .background(theme.cardBackground)
                            .cornerRadius(8)

                        previewCards
                        previewButtons
                        previewFinancialItems
                        previewProgress
                    }
                    .padding()
                }
                .background(theme.background)
                .navigationTitle("Theme Components")
                .preferredColorScheme(showDarkMode ? .dark : .light)
            }
        }

        private var previewCards: some View {
            VStack(spacing: 16) {
                Text("Cards")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                components.card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Simple Card")
                            .font(.headline)

                        Text("Cards provide a container for content with proper background and shadows.")
                            .font(.body)
                            .foregroundStyle(theme.secondaryText)
                    }
                }

                components.cardWithHeader(title: "Card With Header") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This card includes a title header with a divider.")
                            .font(.body)
                            .foregroundStyle(theme.secondaryText)

                        Text("Perfect for content sections.")
                            .font(.callout)
                            .foregroundStyle(theme.secondaryText)
                    }
                }

                components.section(title: "Section Container") {
                    Text("Sections are lighter containers with optional headers.")
                        .font(.body)
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }

        private var previewButtons: some View {
            VStack(spacing: 16) {
                Text("Buttons")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                components.primaryButton {
                    Text("Primary Button")
                }

                components.secondaryButton {
                    Text("Secondary Button")
                }

                components.destructiveButton {
                    Text("Destructive Button")
                }

                components.textButton {
                    Text("Text Button")
                }
            }
        }

        private var previewFinancialItems: some View {
            components.cardWithHeader(title: "Financial Displays") {
                VStack(spacing: 16) {
                    ForEach(amounts, id: \.self) { amount in
                        HStack {
                            Text("Amount:")
                            Spacer()
                            components.currencyDisplay(
                                amount: amount,
                                showSign: true,
                                font: .body.weight(.medium)
                            )
                        }
                        .padding(.vertical, 4)

                        if amount != amounts.last {
                            Divider()
                        }
                    }
                }
            }
        }

        private var previewProgress: some View {
            VStack(spacing: 16) {
                Text("Progress Indicators")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
                    components.cardWithHeader(title: "Budget Progress") {
                        VStack(spacing: 16) {
                            components.budgetProgressBar(spent: 800, total: 1000)
                            components.budgetProgressBar(spent: 950, total: 1000)
                            components.budgetProgressBar(spent: 1100, total: 1000)
                        }
                    }

                    HStack(spacing: 20) {
                        components.goalProgressCircle(progress: 0.25)
                        components.goalProgressCircle(progress: 0.5)
                        components.goalProgressCircle(progress: 0.85)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.cardBackground)
                    .cornerRadius(12)

                    VStack(spacing: 8) {
                        Text("Interactive Progress")
                            .font(.headline)

                        components.goalProgressCircle(progress: sliderValue)

                        Slider(value: $sliderValue, in: 0 ... 1)
                    }
                    .padding()
                    .background(theme.cardBackground)
                    .cornerRadius(12)
                }
            }
        }
    }

    #Preview {
        ThemeComponentsPreview()
    }
#endif
